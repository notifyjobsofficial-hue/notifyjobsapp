import {
  collection,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
} from 'firebase/firestore';
import { db } from '../firebase/config';
import { ContentItem, ContentType } from '../types';
import {
  SourceConfig,
  DiscoveredItem,
  AutomationLog,
  GeminiSettings,
  QueueItemStatus,
  ValidationResult,
  DuplicateCheckResult,
  FieldConfidence,
  SourceStatus,
} from '../types/automation';
import { saveContent, fetchContentList } from './contentService';
import { extractNoticeWithGemini } from './geminiService';

const WORKER_URL = import.meta.env.VITE_FCM_WORKER_URL || 'https://notify-jobs-fcm-worker.workers.dev';

// Default Gemini Settings
export const defaultGeminiSettings: GeminiSettings = {
  geminiEnabled: false,
  geminiApiKey: '',
  geminiModel: 'gemini-1.5-flash',
  temperature: 0.1,
  confidenceThreshold: 0.85,
  autoPublishDefault: false,
};

// ==========================================
// 1. FIRESTORE CRUD FOR SOURCES
// ==========================================

export async function fetchSources(): Promise<SourceConfig[]> {
  try {
    const q = query(collection(db, 'automation_sources'), orderBy('createdAt', 'desc'));
    const snap = await getDocs(q);
    const list: SourceConfig[] = [];
    snap.forEach((d) => list.push({ id: d.id, ...d.data() } as SourceConfig));
    return list;
  } catch (err) {
    console.error('Error fetching automation sources:', err);
    return [];
  }
}

export async function saveSource(source: Partial<SourceConfig>): Promise<SourceConfig> {
  const id = source.id || `src_${Date.now()}`;
  const now = new Date().toISOString();

  const fullSource: SourceConfig = {
    id,
    name: source.name || 'Untitled Source',
    baseUrl: source.baseUrl || '',
    sourceType: source.sourceType || 'HTML',
    enabled: source.enabled ?? true,
    contentTypes: source.contentTypes || ['government_job'],
    crawlPath: source.crawlPath || '',
    allowedDomains: source.allowedDomains || [],
    checkFrequency: source.checkFrequency || 'daily',
    autoPublish: source.autoPublish ?? false,
    confidenceThreshold: source.confidenceThreshold ?? 0.85,
    defaultCategories: source.defaultCategories || [],
    defaultLocation: source.defaultLocation || 'All India',
    defaultOrganization: source.defaultOrganization || '',
    status: source.status || 'healthy',
    itemsFound: source.itemsFound ?? 0,
    itemsPublished: source.itemsPublished ?? 0,
    itemsInReview: source.itemsInReview ?? 0,
    createdAt: source.createdAt || now,
    updatedAt: now,
  };

  await setDoc(doc(db, 'automation_sources', id), fullSource, { merge: true });
  return fullSource;
}

export async function deleteSource(sourceId: string): Promise<void> {
  await deleteDoc(doc(db, 'automation_sources', sourceId));
}

// ==========================================
// 2. FIRESTORE CRUD FOR QUEUE ITEMS
// ==========================================

export async function fetchQueueItems(statusFilter?: QueueItemStatus | 'ALL'): Promise<DiscoveredItem[]> {
  try {
    let q = query(collection(db, 'automation_items'), orderBy('discoveredAt', 'desc'), limit(200));
    if (statusFilter && statusFilter !== 'ALL') {
      q = query(
        collection(db, 'automation_items'),
        where('status', '==', statusFilter),
        orderBy('discoveredAt', 'desc'),
        limit(100)
      );
    }
    const snap = await getDocs(q);
    const list: DiscoveredItem[] = [];
    snap.forEach((d) => list.push({ id: d.id, ...d.data() } as DiscoveredItem));
    return list;
  } catch (err) {
    console.error('Error fetching queue items:', err);
    return [];
  }
}

export async function saveQueueItem(item: DiscoveredItem): Promise<void> {
  await setDoc(doc(db, 'automation_items', item.id), item, { merge: true });
}

export async function deleteQueueItem(itemId: string): Promise<void> {
  await deleteDoc(doc(db, 'automation_items', itemId));
}

// ==========================================
// 3. FIRESTORE LOGGING & SETTINGS
// ==========================================

export async function addAutomationLog(
  log: Omit<AutomationLog, 'id' | 'timestamp'>
): Promise<void> {
  const id = `log_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;
  const fullLog: AutomationLog = {
    ...log,
    id,
    timestamp: new Date().toISOString(),
  };

  try {
    await setDoc(doc(db, 'automation_logs', id), fullLog);
  } catch (err) {
    console.warn('Could not write automation log:', err);
  }
}

export async function fetchAutomationLogs(limitCount = 100): Promise<AutomationLog[]> {
  try {
    const q = query(
      collection(db, 'automation_logs'),
      orderBy('timestamp', 'desc'),
      limit(limitCount)
    );
    const snap = await getDocs(q);
    const list: AutomationLog[] = [];
    snap.forEach((d) => list.push({ id: d.id, ...d.data() } as AutomationLog));
    return list;
  } catch (err) {
    console.error('Error fetching automation logs:', err);
    return [];
  }
}

export async function fetchGeminiSettings(): Promise<GeminiSettings> {
  try {
    const snap = await getDoc(doc(db, 'automation_settings', 'main'));
    if (snap.exists()) {
      return { ...defaultGeminiSettings, ...snap.data() } as GeminiSettings;
    }
    return defaultGeminiSettings;
  } catch (err) {
    console.error('Error fetching gemini settings:', err);
    return defaultGeminiSettings;
  }
}

export async function saveGeminiSettings(settings: Partial<GeminiSettings>): Promise<void> {
  await setDoc(doc(db, 'automation_settings', 'main'), settings, { merge: true });
}

// ==========================================
// 4. RESPECTFUL FETCHER & ANTI-BOT DETECTION
// ==========================================

export interface FetchNoticeResult {
  content: string;
  statusCode: number;
  contentType: string;
  isBlocked: boolean;
  blockReason?: string;
  isPdf?: boolean;
}

export async function fetchUrlRespectful(url: string): Promise<FetchNoticeResult> {
  try {
    const workerProxyUrl = `${WORKER_URL}/api/automation/crawl?url=${encodeURIComponent(url)}`;
    let response: Response;

    try {
      response = await fetch(workerProxyUrl, {
        headers: { 'User-Agent': 'NotifyJobs-Bot/1.0 (+https://notifyjobs.in/bot)' },
      });
    } catch {
      response = await fetch(url);
    }

    const statusCode = response.status;
    const contentType = response.headers.get('content-type') || '';
    const isPdf = contentType.includes('application/pdf') || url.toLowerCase().endsWith('.pdf');

    if (statusCode === 403 || statusCode === 401) {
      return {
        content: '',
        statusCode,
        contentType,
        isBlocked: true,
        blockReason: `HTTP ${statusCode} Forbidden: Server blocks automated requests`,
      };
    }

    if (statusCode === 429) {
      return {
        content: '',
        statusCode,
        contentType,
        isBlocked: true,
        blockReason: 'HTTP 429 Rate Limit: Rate limiting active on source',
      };
    }

    const text = isPdf ? '[PDF Content Binary]' : await response.text();

    const lowerText = text.toLowerCase();
    const hasCaptcha =
      lowerText.includes('cf-mitigated') ||
      lowerText.includes('turnstile') ||
      lowerText.includes('challenges.cloudflare.com') ||
      lowerText.includes('g-recaptcha') ||
      lowerText.includes('hcaptcha') ||
      lowerText.includes('please verify you are human') ||
      lowerText.includes('access denied | dd-os protection');

    if (hasCaptcha) {
      return {
        content: '',
        statusCode: 403,
        contentType,
        isBlocked: true,
        blockReason: 'Anti-bot / CAPTCHA challenge detected on portal',
      };
    }

    return {
      content: text,
      statusCode,
      contentType,
      isBlocked: false,
      isPdf,
    };
  } catch (err: any) {
    return {
      content: '',
      statusCode: 0,
      contentType: '',
      isBlocked: false,
      blockReason: err?.message || 'Network connection failed',
    };
  }
}

// ==========================================
// 5. DISCOVERY PARSER (HTML / RSS / API / PDF)
// ==========================================

export interface DiscoveredLink {
  title: string;
  url: string;
  publishedDate?: string;
  isPdf?: boolean;
}

export function parseDiscoveredLinks(
  content: string,
  source: SourceConfig
): DiscoveredLink[] {
  const discovered: DiscoveredLink[] = [];
  const seenUrls = new Set<string>();

  const resolveUrl = (href: string): string => {
    try {
      return new URL(href, source.baseUrl).href;
    } catch {
      return href;
    }
  };

  const isDomainAllowed = (urlStr: string): boolean => {
    if (!source.allowedDomains || source.allowedDomains.length === 0) return true;
    try {
      const hostname = new URL(urlStr).hostname.toLowerCase();
      return source.allowedDomains.some((d) => hostname.includes(d.toLowerCase()));
    } catch {
      return false;
    }
  };

  // 1. RSS / Atom feed
  if (source.sourceType === 'RSS' || content.includes('<rss') || content.includes('<feed')) {
    const itemRegex = /<item>([\s\S]*?)<\/item>|<entry>([\s\S]*?)<\/entry>/gi;
    let match;
    while ((match = itemRegex.exec(content)) !== null) {
      const block = match[1] || match[2] || '';
      const titleMatch = /<title[^>]*>(?:<!\[CDATA\[)?([\s\S]*?)(?:\]\]>)?<\/title>/i.exec(block);
      const linkMatch = /<link[^>]*>(?:<!\[CDATA\[)?([\s\S]*?)(?:\]\]>)?<\/link>|<link[^>]*href=["']([^"']+)["']/i.exec(block);
      const dateMatch = /<pubDate[^>]*>([\s\S]*?)<\/pubDate>|<updated[^>]*>([\s\S]*?)<\/updated>/i.exec(block);

      const title = titleMatch ? titleMatch[1].trim() : '';
      const rawLink = linkMatch ? (linkMatch[1] || linkMatch[2] || '').trim() : '';
      const url = resolveUrl(rawLink);

      if (title && url && !seenUrls.has(url) && isDomainAllowed(url)) {
        seenUrls.add(url);
        discovered.push({
          title,
          url,
          publishedDate: dateMatch ? dateMatch[1] || dateMatch[2] : undefined,
          isPdf: url.toLowerCase().endsWith('.pdf'),
        });
      }
    }
    return discovered;
  }

  // 2. API JSON output
  if (source.sourceType === 'API') {
    try {
      const parsed = JSON.parse(content);
      const list = Array.isArray(parsed) ? parsed : parsed.items || parsed.data || parsed.notices || [];
      for (const item of list) {
        const title = item.title || item.subject || item.name || '';
        const rawLink = item.url || item.link || item.pdfUrl || '';
        const url = resolveUrl(rawLink);
        if (title && url && !seenUrls.has(url) && isDomainAllowed(url)) {
          seenUrls.add(url);
          discovered.push({
            title,
            url,
            publishedDate: item.date || item.publishedDate,
            isPdf: url.toLowerCase().endsWith('.pdf'),
          });
        }
      }
      return discovered;
    } catch {
      // Fallback to HTML if JSON fails
    }
  }

  // 3. Public HTML Listing / PDF Index
  const anchorRegex = /<a\s+[^>]*href=["']([^"']+)["'][^>]*>([\s\S]*?)<\/a>/gi;
  let aMatch;
  while ((aMatch = anchorRegex.exec(content)) !== null) {
    const rawHref = aMatch[1].trim();
    const rawText = aMatch[2].replace(/<[^>]+>/g, '').trim();

    if (!rawHref || rawHref.startsWith('#') || rawHref.startsWith('javascript:')) {
      continue;
    }

    const fullUrl = resolveUrl(rawHref);
    const isPdf = fullUrl.toLowerCase().endsWith('.pdf');

    if (rawText.length > 5 && isDomainAllowed(fullUrl) && !seenUrls.has(fullUrl)) {
      const lower = rawText.toLowerCase();
      const isNav =
        lower === 'home' ||
        lower === 'about us' ||
        lower === 'contact us' ||
        lower === 'login' ||
        lower === 'privacy policy' ||
        lower === 'terms of service';

      if (!isNav) {
        seenUrls.add(fullUrl);
        discovered.push({
          title: rawText,
          url: fullUrl,
          isPdf,
        });
      }
    }
  }

  return discovered;
}

// ==========================================
// 6. CONTENT FINGERPRINTING & HASHING
// ==========================================

export function computeContentFingerprint(
  title: string,
  organization: string,
  notificationNumber?: string
): string {
  const normTitle = title
    .toLowerCase()
    .replace(/[^\w\s]/g, '')
    .replace(/\s+/g, ' ')
    .trim();

  const normOrg = organization
    .toLowerCase()
    .replace(/[^\w\s]/g, '')
    .trim();

  const normNotif = (notificationNumber || '')
    .toLowerCase()
    .replace(/[^\w]/g, '')
    .trim();

  const combined = `${normTitle}__${normOrg}__${normNotif}`;

  let hash = 2166136261;
  for (let i = 0; i < combined.length; i++) {
    hash ^= combined.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return `fp_${(hash >>> 0).toString(16)}`;
}

export function calculateStringSimilarity(a: string, b: string): number {
  const s1 = a.toLowerCase().replace(/[^\w\s]/g, '').trim();
  const s2 = b.toLowerCase().replace(/[^\w\s]/g, '').trim();
  if (s1 === s2) return 1.0;
  if (s1.length < 2 || s2.length < 2) return 0.0;

  const getBigrams = (str: string) => {
    const s = new Set<string>();
    for (let i = 0; i < str.length - 1; i++) {
      s.add(str.slice(i, i + 2));
    }
    return s;
  };

  const b1 = getBigrams(s1);
  const b2 = getBigrams(s2);
  let intersection = 0;
  b1.forEach((val) => {
    if (b2.has(val)) intersection++;
  });

  return (2.0 * intersection) / (b1.size + b2.size);
}

// ==========================================
// 7. DUPLICATE DETECTION ENGINE (SECTION 5)
// ==========================================

export function checkDuplicates(
  candidate: {
    title: string;
    organization?: string;
    notificationNumber?: string;
    advtNumber?: string;
    sourceUrl: string;
    fingerprint?: string;
  },
  existingContent: ContentItem[],
  existingQueue: DiscoveredItem[],
  currentCandidateId?: string
): DuplicateCheckResult {
  const fp = candidate.fingerprint || computeContentFingerprint(candidate.title, candidate.organization || '');

  // 1. Check exact source URL
  for (const c of existingContent) {
    if (
      (c.officialWebsiteUrl && c.officialWebsiteUrl === candidate.sourceUrl) ||
      (c.officialNotificationUrl && c.officialNotificationUrl === candidate.sourceUrl) ||
      (c.sourceUrl && c.sourceUrl === candidate.sourceUrl)
    ) {
      return {
        isDuplicate: true,
        matchedItemId: c.id,
        matchedTitle: c.title,
        matchedSource: 'firestore_content',
        matchReason: `Exact source URL matches published content (${c.title})`,
        similarityScore: 1.0,
      };
    }
  }

  for (const q of existingQueue) {
    if (q.id !== currentCandidateId && q.sourceUrl === candidate.sourceUrl) {
      return {
        isDuplicate: true,
        matchedItemId: q.id,
        matchedTitle: q.title,
        matchedSource: 'automation_queue',
        matchReason: `Exact source URL already in queue (${q.title})`,
        similarityScore: 1.0,
      };
    }
  }

  // 2. Check advertisement number + organization
  const advt = candidate.advtNumber || candidate.notificationNumber;
  if (advt && candidate.organization) {
    for (const c of existingContent) {
      const cAdvt = c.advtNumber || c.notificationNumber;
      if (
        cAdvt &&
        cAdvt.toLowerCase().trim() === advt.toLowerCase().trim() &&
        c.organization.toLowerCase().trim() === candidate.organization.toLowerCase().trim()
      ) {
        return {
          isDuplicate: true,
          matchedItemId: c.id,
          matchedTitle: c.title,
          matchedSource: 'firestore_content',
          matchReason: `Matching Advertisement Number (${advt}) from same Organization (${c.organization})`,
          similarityScore: 0.98,
        };
      }
    }
  }

  // 3. Check fingerprint match
  for (const q of existingQueue) {
    if (q.id !== currentCandidateId && q.fingerprint === fp) {
      return {
        isDuplicate: true,
        matchedItemId: q.id,
        matchedTitle: q.title,
        matchedSource: 'automation_queue',
        matchReason: 'Identical content fingerprint in queue',
        similarityScore: 0.95,
      };
    }
  }

  // 4. Fuzzy title similarity with matching organization
  for (const c of existingContent) {
    const titleSim = calculateStringSimilarity(c.title, candidate.title);
    const sameOrg =
      candidate.organization &&
      c.organization.toLowerCase().includes(candidate.organization.toLowerCase().trim());

    if (titleSim > 0.88 || (titleSim > 0.78 && sameOrg)) {
      return {
        isDuplicate: true,
        matchedItemId: c.id,
        matchedTitle: c.title,
        matchedSource: 'firestore_content',
        matchReason: `High title similarity (${Math.round(titleSim * 100)}%) with existing content`,
        similarityScore: titleSim,
      };
    }
  }

  return { isDuplicate: false, similarityScore: 0 };
}

// ==========================================
// 8. PARENT RECRUITMENT LINKER (SECTION 13)
// ==========================================

export function detectParentRecruitment(
  notice: {
    title: string;
    organization?: string;
    notificationNumber?: string;
    contentType?: ContentType;
  },
  existingContent: ContentItem[]
): string | undefined {
  const isUpdate =
    notice.contentType === 'admit_card' ||
    notice.contentType === 'result' ||
    notice.contentType === 'answer_key' ||
    notice.contentType === 'syllabus';

  const lowerTitle = notice.title.toLowerCase();
  const isCorrigendumOrExtension =
    lowerTitle.includes('corrigendum') ||
    lowerTitle.includes('date extension') ||
    lowerTitle.includes('extended') ||
    lowerTitle.includes('revised') ||
    isUpdate;

  if (!isCorrigendumOrExtension) return undefined;

  const recruitmentDocs = existingContent.filter(
    (c) => c.contentType === 'government_job' || c.contentType === 'andaman_job'
  );

  if (notice.notificationNumber) {
    const notifClean = notice.notificationNumber.toLowerCase().trim();
    const match = recruitmentDocs.find(
      (c) =>
        (c.notificationNumber && c.notificationNumber.toLowerCase().trim() === notifClean) ||
        (c.advtNumber && c.advtNumber.toLowerCase().trim() === notifClean)
    );
    if (match) return match.id;
  }

  if (notice.organization) {
    const orgClean = notice.organization.toLowerCase().trim();
    for (const rec of recruitmentDocs) {
      if (rec.organization.toLowerCase().includes(orgClean)) {
        const sim = calculateStringSimilarity(rec.title, notice.title);
        if (sim > 0.45) {
          return rec.id;
        }
      }
    }
  }

  return undefined;
}

// ==========================================
// 9. CONFIDENCE SCORER (SECTION 7)
// ==========================================

export function calculateConfidenceScores(
  data: Partial<ContentItem>,
  isPdf = false,
  isScannedPdf = false
): { overallConfidence: number; fieldConfidence: FieldConfidence } {
  const scores: FieldConfidence = {
    title: 0,
    organization: 0,
    vacancies: 0,
    lastDate: 0,
    qualification: 0,
    officialLinks: 0,
    notificationNumber: 0,
  };

  // Title: exists and proper length
  if (data.title && data.title.length >= 10 && !data.title.includes('Untitled')) {
    scores.title = data.title.length > 25 ? 0.98 : 0.85;
  }

  // Organization: recognized non-placeholder
  if (data.organization && data.organization !== 'Official Authority' && data.organization.length >= 3) {
    scores.organization = 0.95;
  } else if (data.organization) {
    scores.organization = 0.70;
  }

  // Vacancies: positive and consistent
  const numVacancies = typeof data.totalVacancies === 'number' ? data.totalVacancies : Number(data.totalVacancies || 0);
  if (numVacancies > 0) {
    scores.vacancies = 0.95;
  } else if (data.posts && data.posts.length > 0) {
    scores.vacancies = 0.85;
  } else {
    const isJob = data.contentType === 'government_job' || data.contentType === 'andaman_job' || data.contentType === 'private_job';
    scores.vacancies = isJob ? 0.40 : 0.90;
  }

  // Last Date: valid ISO date
  if (data.applicationLastDate && /^\d{4}-\d{2}-\d{2}$/.test(data.applicationLastDate)) {
    scores.lastDate = 0.95;
  } else if (data.importantDates && data.importantDates.length > 0) {
    scores.lastDate = 0.80;
  } else {
    scores.lastDate = 0.50;
  }

  // Qualification
  if (data.qualification && data.qualification.length > 5) {
    scores.qualification = 0.92;
  } else if (data.posts?.some((p) => p.qualification && p.qualification.length > 3)) {
    scores.qualification = 0.90;
  } else {
    scores.qualification = 0.60;
  }

  // Official links: HTTPS links present
  if (
    (data.officialNotificationUrl && data.officialNotificationUrl.startsWith('https://')) ||
    (data.applyUrl && data.applyUrl.startsWith('https://'))
  ) {
    scores.officialLinks = 0.98;
  } else if (data.officialWebsiteUrl && data.officialWebsiteUrl.startsWith('http')) {
    scores.officialLinks = 0.85;
  } else {
    scores.officialLinks = 0.50;
  }

  // Notification Number
  if (data.notificationNumber || data.advtNumber) {
    scores.notificationNumber = 0.95;
  } else {
    scores.notificationNumber = 0.50;
  }

  let weighted =
    scores.title * 0.20 +
    scores.organization * 0.20 +
    scores.officialLinks * 0.15 +
    scores.vacancies * 0.15 +
    scores.lastDate * 0.15 +
    scores.qualification * 0.10 +
    scores.notificationNumber * 0.05;

  if (isScannedPdf) {
    weighted *= 0.80;
  } else if (isPdf) {
    weighted *= 0.95;
  }

  const overallConfidence = Math.min(1.0, Math.max(0.1, Number(weighted.toFixed(2))));

  return {
    overallConfidence,
    fieldConfidence: scores,
  };
}

// ==========================================
// 10. MULTI-RULE STRICT VALIDATOR (SECTION 8)
// ==========================================

export function validateExtractedItem(
  data: Partial<ContentItem>,
  source?: SourceConfig
): ValidationResult {
  const criticalErrors: string[] = [];
  const warnings: string[] = [];
  const failedRules: string[] = [];

  // Rule 1: Title exists and is valid
  if (!data.title || data.title.trim().length < 5 || data.title.includes('Untitled')) {
    criticalErrors.push('Title is missing or contains a placeholder');
    failedRules.push('title_required');
  }

  // Rule 2: Organization exists
  if (!data.organization || data.organization.trim().length < 2) {
    criticalErrors.push('Organization / Authority name is missing');
    failedRules.push('organization_required');
  }

  // Rule 3: Valid HTTPS URLs
  const checkUrl = (url: string | undefined, label: string) => {
    if (!url) return;
    try {
      const u = new URL(url);
      if (u.protocol !== 'http:' && u.protocol !== 'https:') {
        criticalErrors.push(`${label} must use HTTP/HTTPS protocol: ${url}`);
        failedRules.push('invalid_url_protocol');
      }
    } catch {
      criticalErrors.push(`Malformed URL for ${label}: ${url}`);
      failedRules.push('malformed_url');
    }
  };

  checkUrl(data.officialWebsiteUrl, 'Official Website URL');
  checkUrl(data.officialNotificationUrl, 'Official Notification URL');
  checkUrl(data.applyUrl, 'Apply Online URL');

  // Rule 4: Dates consistency (applicationLastDate >= applicationStartDate)
  if (data.applicationStartDate && data.applicationLastDate) {
    const start = new Date(data.applicationStartDate).getTime();
    const end = new Date(data.applicationLastDate).getTime();
    if (!isNaN(start) && !isNaN(end) && end < start) {
      criticalErrors.push(
        `Application Last Date (${data.applicationLastDate}) cannot be before Start Date (${data.applicationStartDate})`
      );
      failedRules.push('date_inversion');
    }
  }

  // Rule 5: Non-negative vacancies & post totals check
  if (data.totalVacancies !== undefined) {
    const totalVacNum = Number(data.totalVacancies);
    if (!isNaN(totalVacNum) && totalVacNum < 0) {
      criticalErrors.push(`Total vacancies cannot be negative: ${data.totalVacancies}`);
      failedRules.push('negative_vacancies');
    }
  }

  if (data.posts && data.posts.length > 0) {
    for (const post of data.posts) {
      const pVac = post.vacancies?.total ?? 0;
      if (pVac < 0) {
        criticalErrors.push(`Post '${post.postName}' has negative vacancies: ${pVac}`);
        failedRules.push('negative_post_vacancies');
      }
    }
  }

  // Rule 6: Allowed domain verification where configured
  if (source && source.allowedDomains && source.allowedDomains.length > 0) {
    const urlsToCheck = [data.officialNotificationUrl, data.applyUrl, data.officialWebsiteUrl].filter(Boolean) as string[];
    for (const u of urlsToCheck) {
      try {
        const host = new URL(u).hostname.toLowerCase();
        const isAllowed = source.allowedDomains.some((d) => host.includes(d.toLowerCase()));
        if (!isAllowed) {
          warnings.push(`Official link domain (${host}) does not match configured allowedDomains`);
          failedRules.push('domain_not_in_allowed_list');
        }
      } catch {
        // Handled in Rule 3
      }
    }
  }

  // Rule 7: Valid ContentType
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
  if (!data.contentType || !validTypes.includes(data.contentType)) {
    criticalErrors.push(`Invalid content type: ${data.contentType}`);
    failedRules.push('invalid_content_type');
  }

  // Warnings
  if (!data.excerpt || data.excerpt.length < 20) {
    warnings.push('Summary/excerpt is brief or absent');
  }
  if (!data.officialNotificationUrl && !data.officialWebsiteUrl && !data.applyUrl) {
    warnings.push('No official links extracted');
  }

  return {
    isValid: criticalErrors.length === 0,
    criticalErrors,
    warnings,
    failedRules,
  };
}

// ==========================================
// 11. AUTO-PUBLISH DECISION ENGINE (SECTION 9)
// ==========================================

export function canAutoPublish(
  item: DiscoveredItem,
  source: SourceConfig,
  geminiSettings: GeminiSettings
): boolean {
  if (!source.autoPublish) return false;

  const threshold = source.confidenceThreshold || geminiSettings.confidenceThreshold || 0.85;
  if ((item.overallConfidence ?? 0) < threshold) return false;

  if (!item.validationResult || !item.validationResult.isValid) return false;

  if (item.duplicateCheckResult?.isDuplicate) return false;

  const extracted = item.extractedData;
  if (!extracted) return false;
  const hasOfficialLink = Boolean(
    extracted.officialNotificationUrl || extracted.applyUrl || extracted.officialWebsiteUrl
  );
  if (!hasOfficialLink) return false;

  return true;
}

// ==========================================
// 12. REVIEW QUEUE ACTIONS
// ==========================================

export async function approveAndPublishItem(
  item: DiscoveredItem,
  adminEmail: string
): Promise<string> {
  if (!item.extractedData) {
    throw new Error('No extracted data to publish');
  }

  const contentId = item.publishedContentId || `auto_${Date.now()}`;
  const now = new Date().toISOString();

  const finalContent: ContentItem = {
    ...(item.extractedData as ContentItem),
    id: contentId,
    status: 'published',
    isPublished: true,
    publishedAt: now,
    updatedAt: now,
    createdBy: adminEmail,
    updatedBy: adminEmail,
    sourceVerification: {
      sourceOrg: item.sourceName || item.extractedData?.organization,
      notificationNumber: item.extractedData?.notificationNumber || item.extractedData?.advtNumber,
      sourceWebsiteUrl: item.sourceUrl,
      sourcePdfUrl: item.extractedData?.officialNotificationUrl,
      sourcePublishedDate: now,
      sourceVerified: true,
    },
    parentRecruitmentId: item.parentRecruitmentId,
    viewCount: 0,
    views: 0,
  };

  await saveContent(finalContent, adminEmail);

  const updatedItem: DiscoveredItem = {
    ...item,
    status: 'PUBLISHED',
    publishedContentId: contentId,
    reviewedBy: adminEmail,
    reviewedAt: now,
  };
  await saveQueueItem(updatedItem);

  try {
    const srcDoc = await getDoc(doc(db, 'automation_sources', item.sourceId));
    if (srcDoc.exists()) {
      const data = srcDoc.data() as SourceConfig;
      await updateDoc(doc(db, 'automation_sources', item.sourceId), {
        itemsPublished: (data.itemsPublished || 0) + 1,
        itemsInReview: Math.max(0, (data.itemsInReview || 1) - 1),
        lastSuccessAt: now,
        updatedAt: now,
      });
    }
  } catch (e) {
    console.warn('Could not update source stats:', e);
  }

  await addAutomationLog({
    sourceId: item.sourceId,
    sourceName: item.sourceName,
    itemId: item.id,
    itemTitle: item.title,
    eventType: 'published',
    severity: 'success',
    message: `Notice '${item.title}' approved & published by ${adminEmail}`,
    details: { contentId, confidence: item.overallConfidence },
  });

  return contentId;
}

export async function rejectItem(
  item: DiscoveredItem,
  reason: string,
  adminEmail: string
): Promise<void> {
  const updated: DiscoveredItem = {
    ...item,
    status: 'FAILED',
    errorMessage: `Rejected: ${reason}`,
    reviewedBy: adminEmail,
    reviewedAt: new Date().toISOString(),
  };
  await saveQueueItem(updated);

  await addAutomationLog({
    sourceId: item.sourceId,
    sourceName: item.sourceName,
    itemId: item.id,
    itemTitle: item.title,
    eventType: 'failed',
    severity: 'warning',
    message: `Notice '${item.title}' rejected by ${adminEmail}: ${reason}`,
  });
}

export async function markDuplicateItem(
  item: DiscoveredItem,
  matchedItemId: string,
  adminEmail: string
): Promise<void> {
  const updated: DiscoveredItem = {
    ...item,
    status: 'DUPLICATE',
    duplicateCheckResult: {
      isDuplicate: true,
      matchedItemId,
      matchReason: `Manually marked as duplicate by ${adminEmail}`,
    },
    reviewedBy: adminEmail,
    reviewedAt: new Date().toISOString(),
  };
  await saveQueueItem(updated);

  await addAutomationLog({
    sourceId: item.sourceId,
    sourceName: item.sourceName,
    itemId: item.id,
    itemTitle: item.title,
    eventType: 'duplicate_detected',
    severity: 'info',
    message: `Notice '${item.title}' marked duplicate by ${adminEmail}`,
    details: { matchedItemId },
  });
}

// ==========================================
// 13. FULL PIPELINE RUNNER FOR A SOURCE
// ==========================================

export interface PipelineRunReport {
  sourceId: string;
  sourceName: string;
  linksDiscovered: number;
  itemsProcessed: number;
  itemsAutoPublished: number;
  itemsSentToReview: number;
  itemsMarkedDuplicate: number;
  status: SourceStatus;
  error?: string;
}

export async function runSourcePipeline(
  source: SourceConfig,
  adminEmail = 'system@notifyjobs.in'
): Promise<PipelineRunReport> {
  const now = new Date().toISOString();
  const report: PipelineRunReport = {
    sourceId: source.id,
    sourceName: source.name,
    linksDiscovered: 0,
    itemsProcessed: 0,
    itemsAutoPublished: 0,
    itemsSentToReview: 0,
    itemsMarkedDuplicate: 0,
    status: 'healthy',
  };

  await addAutomationLog({
    sourceId: source.id,
    sourceName: source.name,
    eventType: 'source_checked',
    severity: 'info',
    message: `Starting automated check for portal: ${source.name}`,
    details: { baseUrl: source.baseUrl, crawlPath: source.crawlPath },
  });

  const targetUrl = source.crawlPath
    ? (source.crawlPath.startsWith('http') ? source.crawlPath : `${source.baseUrl}/${source.crawlPath}`.replace(/([^:]\/)\/+/g, '$1'))
    : source.baseUrl;

  const fetchRes = await fetchUrlRespectful(targetUrl);

  if (fetchRes.isBlocked) {
    const updatedSource: Partial<SourceConfig> = {
      status: 'blocked',
      lastCheckedAt: now,
      lastError: fetchRes.blockReason || 'Blocked by anti-bot / 403',
      updatedAt: now,
    };
    await updateDoc(doc(db, 'automation_sources', source.id), updatedSource);

    await addAutomationLog({
      sourceId: source.id,
      sourceName: source.name,
      eventType: 'blocked',
      severity: 'error',
      message: `Source portal BLOCKED automated access: ${fetchRes.blockReason}. Marked as BLOCKED / MANUAL REQUIRED.`,
    });

    report.status = 'blocked';
    report.error = fetchRes.blockReason;
    return report;
  }

  if (fetchRes.statusCode >= 400 || !fetchRes.content) {
    const errText = `Failed to fetch portal (HTTP ${fetchRes.statusCode}): ${fetchRes.blockReason || 'Empty response'}`;
    await updateDoc(doc(db, 'automation_sources', source.id), {
      status: 'failed',
      lastCheckedAt: now,
      lastError: errText,
      updatedAt: now,
    });

    await addAutomationLog({
      sourceId: source.id,
      sourceName: source.name,
      eventType: 'failed',
      severity: 'error',
      message: errText,
    });

    report.status = 'failed';
    report.error = errText;
    return report;
  }

  const discoveredLinks = parseDiscoveredLinks(fetchRes.content, source);
  report.linksDiscovered = discoveredLinks.length;

  await addAutomationLog({
    sourceId: source.id,
    sourceName: source.name,
    eventType: 'items_discovered',
    severity: 'info',
    message: `Discovered ${discoveredLinks.length} notice links from ${source.name}`,
  });

  const [existingContent, existingQueue, geminiSettings] = await Promise.all([
    fetchContentList({}),
    fetchQueueItems('ALL'),
    fetchGeminiSettings(),
  ]);

  const itemsToProcess = discoveredLinks.slice(0, 5);

  for (const link of itemsToProcess) {
    const fingerprint = computeContentFingerprint(link.title, source.defaultOrganization);
    const itemId = `item_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`;

    const dupCheck = checkDuplicates(
      {
        title: link.title,
        organization: source.defaultOrganization,
        sourceUrl: link.url,
        fingerprint,
      },
      existingContent,
      existingQueue
    );

    if (dupCheck.isDuplicate) {
      report.itemsMarkedDuplicate++;
      const dupItem: DiscoveredItem = {
        id: itemId,
        sourceId: source.id,
        sourceName: source.name,
        sourceUrl: link.url,
        title: link.title,
        discoveredAt: now,
        fingerprint,
        status: 'DUPLICATE',
        duplicateCheckResult: dupCheck,
        isPdf: link.isPdf,
      };
      await saveQueueItem(dupItem);
      continue;
    }

    const noticeFetch = await fetchUrlRespectful(link.url);
    if (noticeFetch.isBlocked) {
      const blockedItem: DiscoveredItem = {
        id: itemId,
        sourceId: source.id,
        sourceName: source.name,
        sourceUrl: link.url,
        title: link.title,
        discoveredAt: now,
        fingerprint,
        status: 'BLOCKED',
        errorMessage: noticeFetch.blockReason,
        isPdf: link.isPdf,
      };
      await saveQueueItem(blockedItem);
      continue;
    }

    const rawNoticeText = noticeFetch.content || link.title;

    let extracted: Partial<ContentItem> = {
      title: link.title,
      organization: source.defaultOrganization || 'Official Authority',
      location: source.defaultLocation || 'All India',
      contentType: source.contentTypes[0] || 'government_job',
      officialWebsiteUrl: link.url,
      officialNotificationUrl: link.isPdf ? link.url : undefined,
    };

    if (geminiSettings.geminiEnabled && geminiSettings.geminiApiKey) {
      try {
        const aiResult = await extractNoticeWithGemini(
          rawNoticeText,
          geminiSettings,
          WORKER_URL,
          {
            defaultOrg: source.defaultOrganization,
            defaultLocation: source.defaultLocation,
          }
        );
        extracted = {
          ...extracted,
          ...aiResult.extractedData,
          officialWebsiteUrl: extracted.officialWebsiteUrl || link.url,
        };
      } catch (geminiErr: any) {
        console.warn(`Gemini extraction failed for ${link.title}:`, geminiErr);
        await addAutomationLog({
          sourceId: source.id,
          sourceName: source.name,
          itemId,
          itemTitle: link.title,
          eventType: 'failed',
          severity: 'warning',
          message: `Gemini extraction failed for '${link.title}': ${geminiErr?.message || geminiErr}`,
        });
      }
    }

    const { overallConfidence, fieldConfidence } = calculateConfidenceScores(
      extracted,
      link.isPdf,
      false
    );

    const validationResult = validateExtractedItem(extracted, source);

    const parentRecruitmentId = detectParentRecruitment(
      {
        title: extracted.title || link.title,
        organization: extracted.organization,
        notificationNumber: extracted.notificationNumber,
        contentType: extracted.contentType,
      },
      existingContent
    );

    const fullDupCheck = checkDuplicates(
      {
        title: extracted.title || link.title,
        organization: extracted.organization,
        notificationNumber: extracted.notificationNumber,
        advtNumber: extracted.advtNumber,
        sourceUrl: link.url,
        fingerprint,
      },
      existingContent,
      existingQueue,
      itemId
    );

    const queueItem: DiscoveredItem = {
      id: itemId,
      sourceId: source.id,
      sourceName: source.name,
      sourceUrl: link.url,
      title: extracted.title || link.title,
      discoveredAt: now,
      fingerprint,
      status: fullDupCheck.isDuplicate ? 'DUPLICATE' : 'REVIEW',
      contentType: extracted.contentType,
      rawContent: rawNoticeText.slice(0, 10000),
      isPdf: link.isPdf,
      extractedData: extracted,
      overallConfidence,
      fieldConfidence,
      validationResult,
      duplicateCheckResult: fullDupCheck,
      parentRecruitmentId,
    };

    if (canAutoPublish(queueItem, source, geminiSettings)) {
      try {
        await approveAndPublishItem(queueItem, adminEmail);
        report.itemsAutoPublished++;
      } catch (pubErr) {
        console.warn('Auto publish failed, saving to Review Queue instead:', pubErr);
        queueItem.status = 'REVIEW';
        await saveQueueItem(queueItem);
        report.itemsSentToReview++;
      }
    } else {
      if (fullDupCheck.isDuplicate) {
        report.itemsMarkedDuplicate++;
      } else {
        report.itemsSentToReview++;
      }
      await saveQueueItem(queueItem);
    }

    report.itemsProcessed++;
  }

  const updatedSourceStatus: SourceStatus = report.error ? 'warning' : 'healthy';
  await updateDoc(doc(db, 'automation_sources', source.id), {
    status: updatedSourceStatus,
    lastCheckedAt: now,
    lastSuccessAt: now,
    itemsFound: (source.itemsFound || 0) + report.linksDiscovered,
    itemsPublished: (source.itemsPublished || 0) + report.itemsAutoPublished,
    itemsInReview: (source.itemsInReview || 0) + report.itemsSentToReview,
    lastError: '',
    updatedAt: now,
  });

  return report;
}
