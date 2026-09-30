import { ContentItem, ContentType, PostItem, VacancyBreakup } from '../types';
import { GeminiSettings } from '../types/automation';

export interface ExtractedNoticeResult {
  extractedData: Partial<ContentItem>;
  rawResponseText: string;
  tokensUsed?: number;
  model: string;
}

const SYSTEM_INSTRUCTION = `
You are the official recruitment notice extraction engine for Notify Jobs (an exam & recruitment notification service).
Your task is to extract recruitment and examination details from the given source notice and return ONLY a valid, strictly structured JSON object.

CRITICAL ZERO-HALLUCINATION RULES:
1. DO NOT invent, infer, or hallucinate missing facts, numbers, dates, or URLs.
2. If any piece of information is absent in the source text, you MUST return null or an empty array/string.
3. NEVER make up post numbers, vacancies, salary scales, age limits, or qualifications.
4. If a date is not explicitly mentioned, leave it null.
5. All official links (PDF notices, application links, portal URLs) must strictly come from the source text.
6. The output must be pure JSON without markdown backticks or explanations.
`;

const PROMPT_TEMPLATE = (rawContent: string, defaultOrg?: string, defaultLocation?: string) => `
Extract the recruitment / examination notice details into the specified JSON format.
Default Organization (if not specified): ${defaultOrg || 'Government of India'}
Default Location (if not specified): ${defaultLocation || 'All India'}

Notice Text:
---
${rawContent.slice(0, 25000)}
---

Required JSON Schema:
{
  "contentType": "government_job" | "andaman_job" | "admit_card" | "result" | "answer_key" | "syllabus" | "article",
  "title": string,
  "seoTitle": string,
  "organization": string,
  "department": string | null,
  "notificationNumber": string | null,
  "advtNumber": string | null,
  "recruitmentYear": string | null,
  "location": string,
  "employmentType": string,
  "recruitmentType": string,
  "excerpt": string,
  "body": string,
  "totalVacancies": number | null,
  "posts": [
    {
      "id": string,
      "postName": string,
      "postCode": string | null,
      "group": string | null,
      "cadre": string | null,
      "payLevel": string | null,
      "payScale": string | null,
      "qualification": string | null,
      "desirableQualification": string | null,
      "ageMin": number | null,
      "ageMax": number | null,
      "vacancies": {
        "ur": number,
        "obc": number,
        "ews": number,
        "sc": number,
        "st": number,
        "pwbd": number,
        "esm": number,
        "msp": number,
        "other": number,
        "total": number
      }
    }
  ],
  "importantDates": [
    {
      "id": string,
      "label": string,
      "date": string,
      "isImportant": boolean
    }
  ],
  "applicationStartDate": string | null (YYYY-MM-DD),
  "applicationLastDate": string | null (YYYY-MM-DD),
  "feePaymentLastDate": string | null (YYYY-MM-DD),
  "examDate": string | null,
  "admitCardDate": string | null,
  "resultDate": string | null,
  "answerKeyDate": string | null,
  "applicationFees": [
    {
      "id": string,
      "category": string,
      "fee": string,
      "exempted": boolean
    }
  ],
  "howToApplySteps": string[],
  "officialWebsiteUrl": string | null,
  "officialNotificationUrl": string | null,
  "applyUrl": string | null
}
`;

export async function extractNoticeWithGemini(
  rawContent: string,
  settings: GeminiSettings,
  workerUrl?: string,
  options?: { defaultOrg?: string; defaultLocation?: string }
): Promise<ExtractedNoticeResult> {
  const modelName = settings.geminiModel || 'gemini-1.5-flash';
  const temperature = settings.temperature ?? 0.1;

  // 1. Try Cloudflare Worker endpoint if workerUrl is configured
  if (workerUrl) {
    try {
      const workerRes = await fetch(`${workerUrl}/api/automation/extract`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          rawContent,
          model: modelName,
          temperature,
          defaultOrg: options?.defaultOrg,
          defaultLocation: options?.defaultLocation,
        }),
      });

      if (workerRes.ok) {
        const data = await workerRes.json();
        return {
          extractedData: data.extractedData,
          rawResponseText: data.rawResponseText || JSON.stringify(data.extractedData),
          tokensUsed: data.tokensUsed,
          model: modelName,
        };
      }
    } catch (workerErr) {
      console.warn('Worker Gemini extraction unavailable, falling back to direct API:', workerErr);
    }
  }

  // 2. Direct Gemini REST API call using configured admin API key
  if (!settings.geminiApiKey) {
    throw new Error('Gemini API key is not configured. Please set it in Automation > AI Settings.');
  }

  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${encodeURIComponent(
    settings.geminiApiKey
  )}`;

  const prompt = PROMPT_TEMPLATE(rawContent, options?.defaultOrg, options?.defaultLocation);

  const payload = {
    contents: [
      {
        parts: [
          { text: SYSTEM_INSTRUCTION },
          { text: prompt },
        ],
      },
    ],
    generationConfig: {
      temperature,
      responseMimeType: 'application/json',
    },
  };

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    if (response.status === 429) {
      throw new Error('Gemini API rate limit / quota exceeded (HTTP 429).');
    }
    if (response.status === 403 || response.status === 401) {
      throw new Error('Invalid or unauthorized Gemini API key.');
    }
    throw new Error(`Gemini API error (HTTP ${response.status}): ${errorBody.slice(0, 300)}`);
  }

  const result = await response.json();
  const candidateText = result.candidates?.[0]?.content?.parts?.[0]?.text;

  if (!candidateText) {
    throw new Error('Gemini returned an empty response candidate.');
  }

  // Parse extracted JSON
  let extractedJson: any;
  try {
    const cleanText = candidateText
      .replace(/^```json\s*/i, '')
      .replace(/^```\s*/i, '')
      .replace(/\s*```$/, '')
      .trim();

    extractedJson = JSON.parse(cleanText);
  } catch (parseErr) {
    throw new Error(`Failed to parse Gemini output as JSON: ${String(parseErr)}. Snippet: ${candidateText.slice(0, 200)}`);
  }

  const normalized = normalizeExtractedData(extractedJson);

  return {
    extractedData: normalized,
    rawResponseText: candidateText,
    tokensUsed: result.usageMetadata?.totalTokenCount,
    model: modelName,
  };
}

/**
 * Normalizes raw Gemini JSON into valid Partial<ContentItem> adhering strictly to Notify Jobs schema
 */
export function normalizeExtractedData(data: any): Partial<ContentItem> {
  if (!data || typeof data !== 'object') return {};

  const cleanString = (v: any): string => (v != null ? String(v).trim() : '');
  const cleanNumber = (v: any): number => {
    if (v == null || v === '') return 0;
    const n = Number(v);
    return isNaN(n) ? 0 : Math.max(0, Math.floor(n));
  };

  // Content type validation
  const validTypes: ContentType[] = [
    'government_job',
    'andaman_job',
    'private_job',
    'admit_card',
    'result',
    'answer_key',
    'syllabus',
    'article',
  ];
  let contentType: ContentType = 'government_job';
  if (data.contentType && validTypes.includes(data.contentType)) {
    contentType = data.contentType;
  }

  // Post items
  const rawPosts = Array.isArray(data.posts) ? data.posts : [];
  const posts: PostItem[] = rawPosts.map((p: any, idx: number) => {
    const vb = p.vacancies || {};
    const ur = cleanNumber(vb.ur);
    const obc = cleanNumber(vb.obc);
    const ews = cleanNumber(vb.ews);
    const sc = cleanNumber(vb.sc);
    const st = cleanNumber(vb.st);
    const pwbd = cleanNumber(vb.pwbd);
    const esm = cleanNumber(vb.esm);
    const msp = cleanNumber(vb.msp);
    const other = cleanNumber(vb.other);
    const total = cleanNumber(vb.total) || (ur + obc + ews + sc + st + pwbd + esm + msp + other);

    const vacancyBreakup: VacancyBreakup = {
      ur,
      obc,
      ews,
      sc,
      st,
      pwbd,
      esm,
      msp,
      other,
      total,
    };

    return {
      id: cleanString(p.id) || `post-${idx + 1}`,
      postName: cleanString(p.postName || p.name) || 'Recruitment Post',
      postCode: cleanString(p.postCode) || undefined,
      group: cleanString(p.group) || undefined,
      cadre: cleanString(p.cadre) || undefined,
      payLevel: cleanString(p.payLevel) || undefined,
      payScale: cleanString(p.payScale) || undefined,
      qualification: cleanString(p.qualification) || undefined,
      desirableQualification: cleanString(p.desirableQualification) || undefined,
      ageMin: cleanNumber(p.ageMin) || undefined,
      ageMax: cleanNumber(p.ageMax) || undefined,
      vacancies: vacancyBreakup,
    };
  });

  // Important Dates
  const rawDates = Array.isArray(data.importantDates) ? data.importantDates : [];
  const importantDates = rawDates.map((d: any, idx: number) => ({
    id: cleanString(d.id) || `date-${idx + 1}`,
    label: cleanString(d.label || d.title || d.name) || 'Important Date',
    date: cleanString(d.date),
    isImportant: Boolean(d.isImportant ?? true),
  }));

  // Application Fees
  const rawFees = Array.isArray(data.applicationFees || data.fees) ? (data.applicationFees || data.fees) : [];
  const applicationFees = rawFees.map((f: any, idx: number) => ({
    id: cleanString(f.id) || `fee-${idx + 1}`,
    category: cleanString(f.category) || 'General',
    fee: cleanString(f.fee || f.amount || '0'),
    exempted: Boolean(f.exempted),
  }));

  // How to apply steps
  const howToApplySteps = Array.isArray(data.howToApplySteps)
    ? data.howToApplySteps.map(cleanString).filter(Boolean)
    : [];

  const postTotalSum = posts.reduce((acc, p) => acc + (p.vacancies.total || 0), 0);
  const totalVacancies = cleanNumber(data.totalVacancies) || postTotalSum || 0;

  return {
    contentType,
    title: cleanString(data.title) || 'Untitled Recruitment Notice',
    seoTitle: cleanString(data.seoTitle) || cleanString(data.title).slice(0, 60),
    organization: cleanString(data.organization) || 'Official Authority',
    department: cleanString(data.department) || undefined,
    notificationNumber: cleanString(data.notificationNumber) || undefined,
    advtNumber: cleanString(data.advtNumber || data.advertisementNumber) || undefined,
    recruitmentYear: cleanString(data.recruitmentYear) || String(new Date().getFullYear()),
    location: cleanString(data.location) || 'All India',
    jobRole: posts[0]?.postName || 'Recruitment',
    vacancies: String(totalVacancies),
    totalVacancies,
    qualification: posts[0]?.qualification || cleanString(data.qualificationSummary) || 'See Details',
    salary: posts[0]?.payScale || posts[0]?.payLevel || 'As per norms',
    recruitmentType: cleanString(data.recruitmentType) || 'Government Regular',
    excerpt: cleanString(data.excerpt || data.summary),
    body: cleanString(data.body || data.summary),
    posts,
    importantDates,
    applicationStartDate: cleanString(data.applicationStartDate) || undefined,
    applicationLastDate: cleanString(data.applicationLastDate) || undefined,
    feePaymentLastDate: cleanString(data.feePaymentLastDate) || undefined,
    examDate: cleanString(data.examDate) || undefined,
    admitCardDate: cleanString(data.admitCardDate) || undefined,
    resultDate: cleanString(data.resultDate) || undefined,
    answerKeyDate: cleanString(data.answerKeyDate) || undefined,
    applicationFees,
    howToApplySteps,
    officialWebsiteUrl: cleanString(data.officialWebsiteUrl) || undefined,
    officialNotificationUrl: cleanString(data.officialNotificationUrl || data.notificationPdfUrl) || undefined,
    applyUrl: cleanString(data.applyUrl || data.applyOnlineUrl) || undefined,
    status: 'draft',
    isPublished: false,
    views: 0,
    viewCount: 0,
    vacanciesBreakdown: [],
    ageLimits: [],
    selectionProcess: [],
    examPattern: [],
    importantLinks: [],
    faqs: [],
    categoryIds: ['latest-jobs'],
    tags: [],
    searchKeywords: [],
  };
}
