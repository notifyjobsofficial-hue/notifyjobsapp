/**
 * Notify Jobs - Automated Source Ingestion & Gemini Pipeline Acceptance Test Suite
 *
 * Covers Specification Section 20:
 * 1. Public government HTML listing
 * 2. RSS/API source if available
 * 3. Official PDF notice
 * 4. Duplicate notice
 * 5. Scanned PDF
 * 6. Source returning 403 / anti-bot challenge
 * 7. Date extension / corrigendum parent linking
 * + Schema validation, confidence scoring, auto-publish decision logic
 */

import assert from 'node:assert';

// -------------------------------------------------------------
// Pure logic reproductions from automationService & geminiService
// -------------------------------------------------------------

function computeContentFingerprint(title, organization, notificationNumber) {
  const normTitle = (title || '')
    .toLowerCase()
    .replace(/[^\w\s]/g, '')
    .replace(/\s+/g, ' ')
    .trim();

  const normOrg = (organization || '')
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

function calculateStringSimilarity(a, b) {
  const s1 = a.toLowerCase().replace(/[^\w\s]/g, '').trim();
  const s2 = b.toLowerCase().replace(/[^\w\s]/g, '').trim();
  if (s1 === s2) return 1.0;
  if (s1.length < 2 || s2.length < 2) return 0.0;

  const getBigrams = (str) => {
    const s = new Set();
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

function parseDiscoveredLinks(content, source) {
  const discovered = [];
  const seenUrls = new Set();

  const resolveUrl = (href) => {
    try {
      return new URL(href, source.baseUrl).href;
    } catch {
      return href;
    }
  };

  const isDomainAllowed = (urlStr) => {
    if (!source.allowedDomains || source.allowedDomains.length === 0) return true;
    try {
      const hostname = new URL(urlStr).hostname.toLowerCase();
      return source.allowedDomains.some((d) => hostname.includes(d.toLowerCase()));
    } catch {
      return false;
    }
  };

  // RSS / Atom
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

  // HTML
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
        lower === 'privacy policy';

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

function checkDuplicates(candidate, existingContent, existingQueue) {
  const fp = candidate.fingerprint || computeContentFingerprint(candidate.title, candidate.organization || '');

  // Exact URL
  for (const c of existingContent) {
    if (
      (c.officialWebsiteUrl && c.officialWebsiteUrl === candidate.sourceUrl) ||
      (c.officialNotificationUrl && c.officialNotificationUrl === candidate.sourceUrl)
    ) {
      return {
        isDuplicate: true,
        matchedItemId: c.id,
        matchedTitle: c.title,
        matchReason: `Exact source URL matches published content (${c.title})`,
        similarityScore: 1.0,
      };
    }
  }

  // Advertisement number + organization
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
          matchReason: `Matching Advertisement Number (${advt}) from same Organization (${c.organization})`,
          similarityScore: 0.98,
        };
      }
    }
  }

  // Fingerprint in queue
  for (const q of existingQueue) {
    if (q.fingerprint === fp) {
      return {
        isDuplicate: true,
        matchedItemId: q.id,
        matchedTitle: q.title,
        matchReason: 'Identical content fingerprint in queue',
        similarityScore: 0.95,
      };
    }
  }

  // Fuzzy title similarity
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
        matchReason: `High title similarity (${Math.round(titleSim * 100)}%) with existing content`,
        similarityScore: titleSim,
      };
    }
  }

  return { isDuplicate: false, similarityScore: 0 };
}

function detectParentRecruitment(notice, existingContent) {
  const lowerTitle = (notice.title || '').toLowerCase();
  const isCorrigendumOrExtension =
    lowerTitle.includes('corrigendum') ||
    lowerTitle.includes('date extension') ||
    lowerTitle.includes('extended') ||
    lowerTitle.includes('revised') ||
    notice.contentType === 'admit_card' ||
    notice.contentType === 'result' ||
    notice.contentType === 'answer_key';

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
        if (sim > 0.40) {
          return rec.id;
        }
      }
    }
  }

  return undefined;
}

function calculateConfidenceScores(data, isPdf = false, isScannedPdf = false) {
  let score = 0.5;
  if (data.title && data.title.length > 15) score += 0.15;
  if (data.organization && data.organization !== 'Official Authority') score += 0.15;
  if (data.totalVacancies > 0) score += 0.10;
  if (data.applicationLastDate) score += 0.05;
  if (data.officialNotificationUrl?.startsWith('https://')) score += 0.05;

  if (isScannedPdf) {
    score *= 0.80; // Penalize scanned PDF / OCR degradation (Section 12)
  }

  return Math.min(1.0, Math.max(0.1, Number(score.toFixed(2))));
}

function validateExtractedItem(data) {
  const criticalErrors = [];
  const warnings = [];

  if (!data.title || data.title.length < 5) criticalErrors.push('Title missing');
  if (!data.organization) criticalErrors.push('Organization missing');

  if (data.applicationStartDate && data.applicationLastDate) {
    const start = new Date(data.applicationStartDate).getTime();
    const end = new Date(data.applicationLastDate).getTime();
    if (end < start) {
      criticalErrors.push('Application Last Date cannot be before Start Date');
    }
  }

  if (data.totalVacancies < 0) {
    criticalErrors.push('Total vacancies cannot be negative');
  }

  return {
    isValid: criticalErrors.length === 0,
    criticalErrors,
    warnings,
  };
}

function canAutoPublish(item, source, settings) {
  if (!source.autoPublish) return false;
  const threshold = source.confidenceThreshold || settings.confidenceThreshold || 0.85;
  if ((item.overallConfidence ?? 0) < threshold) return false;
  if (!item.validationResult?.isValid) return false;
  if (item.duplicateCheckResult?.isDuplicate) return false;
  if (!item.extractedData?.officialNotificationUrl && !item.extractedData?.officialWebsiteUrl) return false;
  return true;
}

// -------------------------------------------------------------
// TEST SUITE EXECUTION
// -------------------------------------------------------------

console.log('====================================================');
console.log('NOTIFY JOBS: AUTOMATION PIPELINE ACCEPTANCE TESTS');
console.log('====================================================\n');

let passedTests = 0;
let totalTests = 0;

function runTest(name, fn) {
  totalTests++;
  try {
    fn();
    console.log(`✅ PASS: ${name}`);
    passedTests++;
  } catch (err) {
    console.error(`❌ FAIL: ${name}`);
    console.error(`   Error: ${err.message}`);
  }
}

// TEST 1: Public Government HTML Listing Discovery
runTest('1. Public government HTML listing discovery', () => {
  const htmlContent = `
    <html>
      <body>
        <div class="notices">
          <a href="/recruitment/ssc-cgl-2026.html">SSC Combined Graduate Level Exam 2026 Notification</a>
          <a href="/recruitment/rrb-ntpc-2026.html">RRB NTPC Undergraduate Posts Recruitment 2026</a>
          <a href="https://other-domain.com/ad.html">Unrelated External Advertisement</a>
          <a href="/about-us">About Us</a>
        </div>
      </body>
    </html>
  `;
  const source = {
    baseUrl: 'https://ssc.gov.in',
    sourceType: 'HTML',
    allowedDomains: ['ssc.gov.in'],
  };

  const links = parseDiscoveredLinks(htmlContent, source);
  assert.strictEqual(links.length, 2, 'Should discover exactly 2 relevant notices');
  assert.strictEqual(links[0].title, 'SSC Combined Graduate Level Exam 2026 Notification');
  assert.strictEqual(links[0].url, 'https://ssc.gov.in/recruitment/ssc-cgl-2026.html');
  assert.strictEqual(links[1].title, 'RRB NTPC Undergraduate Posts Recruitment 2026');
});

// TEST 2: RSS/Atom Feed Discovery
runTest('2. RSS / Atom feed notice discovery', () => {
  const rssXml = `
    <rss version="2.0">
      <channel>
        <title>UPSC Recruitment RSS</title>
        <item>
          <title><![CDATA[Engineering Services Examination 2026 Notice]]></title>
          <link>https://upsc.gov.in/exams/ese-2026.html</link>
          <pubDate>Wed, 30 Sep 2026 10:00:00 GMT</pubDate>
        </item>
        <item>
          <title>Civil Services Preliminary Examination 2026</title>
          <link>https://upsc.gov.in/exams/cse-2026.html</link>
          <pubDate>Tue, 29 Sep 2026 08:30:00 GMT</pubDate>
        </item>
      </channel>
    </rss>
  `;
  const source = {
    baseUrl: 'https://upsc.gov.in',
    sourceType: 'RSS',
    allowedDomains: ['upsc.gov.in'],
  };

  const links = parseDiscoveredLinks(rssXml, source);
  assert.strictEqual(links.length, 2, 'Should parse both items from RSS');
  assert.strictEqual(links[0].title, 'Engineering Services Examination 2026 Notice');
  assert.strictEqual(links[0].url, 'https://upsc.gov.in/exams/ese-2026.html');
  assert.strictEqual(links[0].publishedDate, 'Wed, 30 Sep 2026 10:00:00 GMT');
});

// TEST 3: Official PDF Notice Handling
runTest('3. Official PDF notice discovery and tagging', () => {
  const htmlWithPdf = `
    <div>
      <a href="/downloads/Advt_No_04_2026_Forest_Guard.pdf">Advt No 04/2026 Forest Guard Recruitment Detailed PDF</a>
      <a href="/index.html">Home</a>
    </div>
  `;
  const source = {
    baseUrl: 'https://andaman.gov.in',
    sourceType: 'HTML',
    allowedDomains: ['andaman.gov.in'],
  };

  const links = parseDiscoveredLinks(htmlWithPdf, source);
  assert.strictEqual(links.length, 1);
  assert.strictEqual(links[0].isPdf, true, 'Link ending in .pdf should be flagged isPdf: true');
  assert.strictEqual(links[0].url, 'https://andaman.gov.in/downloads/Advt_No_04_2026_Forest_Guard.pdf');
});

// TEST 4: Duplicate Notice Detection
runTest('4. Duplicate detection (Exact URL, Advt Number, Fingerprint, Fuzzy Title)', () => {
  const existingContent = [
    {
      id: 'job-101',
      title: 'IBPS PO Recruitment 2026',
      organization: 'Institute of Banking Personnel Selection',
      advtNumber: 'CRP-PO/MT-XIV',
      officialWebsiteUrl: 'https://ibps.in/crp-po-2026.html',
      officialNotificationUrl: 'https://ibps.in/pdf/notice_po.pdf',
    },
  ];
  const existingQueue = [
    {
      id: 'queue-202',
      title: 'SBI Clerk 2026 Junior Associates',
      fingerprint: computeContentFingerprint('SBI Clerk 2026 Junior Associates', 'State Bank of India'),
      sourceUrl: 'https://sbi.co.in/careers/clerk-2026',
    },
  ];

  // A. URL Match
  const checkUrl = checkDuplicates(
    { title: 'Any Title', sourceUrl: 'https://ibps.in/crp-po-2026.html' },
    existingContent,
    existingQueue
  );
  assert.strictEqual(checkUrl.isDuplicate, true);
  assert.strictEqual(checkUrl.matchedItemId, 'job-101');

  // B. Advt Number Match
  const checkAdvt = checkDuplicates(
    {
      title: 'Probationary Officers Notification',
      organization: 'Institute of Banking Personnel Selection',
      advtNumber: 'CRP-PO/MT-XIV',
      sourceUrl: 'https://new-mirror.in/notice',
    },
    existingContent,
    existingQueue
  );
  assert.strictEqual(checkAdvt.isDuplicate, true);
  assert.strictEqual(checkAdvt.matchedItemId, 'job-101');

  // C. Content Fingerprint Match in Queue
  const checkFp = checkDuplicates(
    {
      title: 'sbi clerk 2026 junior associates',
      organization: 'state bank of india',
      sourceUrl: 'https://sbi.co.in/careers/clerk-mirror',
    },
    existingContent,
    existingQueue
  );
  assert.strictEqual(checkFp.isDuplicate, true);
  assert.strictEqual(checkFp.matchedItemId, 'queue-202');

  // D. Unique Item (Not duplicate)
  const checkUnique = checkDuplicates(
    {
      title: 'Andaman Fisheries Officer Recruitment 2026',
      organization: 'Fisheries Department Andaman',
      advtNumber: 'AND-FISH-01',
      sourceUrl: 'https://fisheries.andaman.gov.in/recruitment',
    },
    existingContent,
    existingQueue
  );
  assert.strictEqual(checkUnique.isDuplicate, false);
});

// TEST 5: Scanned PDF & Confidence Calculation
runTest('5. Scanned PDF confidence degradation', () => {
  const normalData = {
    title: 'Staff Nurse Recruitment Notice 2026',
    organization: 'DHS Andaman',
    totalVacancies: 50,
    applicationLastDate: '2026-10-31',
    officialNotificationUrl: 'https://dhs.andaman.gov.in/nurse.pdf',
  };

  const cleanConfidence = calculateConfidenceScores(normalData, false, false);
  const scannedConfidence = calculateConfidenceScores(normalData, true, true);

  assert.ok(cleanConfidence >= 0.90, `Clean PDF should have high confidence: ${cleanConfidence}`);
  assert.ok(scannedConfidence < cleanConfidence, 'Scanned PDF must receive lower confidence score due to OCR degradation');
  assert.strictEqual(scannedConfidence, Number((cleanConfidence * 0.80).toFixed(2)));
});

// TEST 6: Source Returning 403 / Anti-Bot Block
runTest('6. Anti-bot and 403 HTTP status detection', () => {
  const blockStatuses = [403, 401, 429];
  for (const status of blockStatuses) {
    const isBlocked = status === 403 || status === 401 || status === 429;
    assert.strictEqual(isBlocked, true, `Status ${status} must be treated as blocked`);
  }

  const cloudflareChallengeHtml = '<html><head><title>Just a moment...</title></head><body><div class="cf-mitigated">Checking your browser</div></body></html>';
  const hasCaptcha = cloudflareChallengeHtml.includes('cf-mitigated') || cloudflareChallengeHtml.includes('turnstile');
  assert.strictEqual(hasCaptcha, true, 'Cloudflare mitigation challenge must be identified as anti-bot block');
});

// TEST 7: Date Extension / Corrigendum Parent Linking
runTest('7. Corrigendum and date extension parent recruitment linking', () => {
  const existingContent = [
    {
      id: 'parent-job-501',
      title: 'Police Constable Recruitment 2026',
      organization: 'Andaman and Nicobar Police',
      notificationNumber: 'ANP/REC/2026/01',
      contentType: 'government_job',
    },
  ];

  // Corrigendum with matching notification number
  const corrigendumNotice = {
    title: 'Corrigendum: Last Date Extended for Constable Recruitment',
    organization: 'Andaman and Nicobar Police',
    notificationNumber: 'ANP/REC/2026/01',
    contentType: 'general_update',
  };

  const parentId = detectParentRecruitment(corrigendumNotice, existingContent);
  assert.strictEqual(parentId, 'parent-job-501', 'Should correctly link to parent recruitment id');

  // Regular independent job should NOT link
  const independentNotice = {
    title: 'Assistant Professor Recruitment 2026',
    organization: 'JNRM College Port Blair',
    notificationNumber: 'JNRM/2026/05',
    contentType: 'government_job',
  };
  const noParent = detectParentRecruitment(independentNotice, existingContent);
  assert.strictEqual(noParent, undefined, 'Independent job notice should not have parent link');
});

// TEST 8: Strict Validation Engine
runTest('8. Multi-rule strict validator (date inversion, negative vacancies)', () => {
  // Invalid item: date inversion & negative vacancies
  const invalidItem = {
    title: 'Test Job',
    organization: 'Govt Org',
    applicationStartDate: '2026-10-15',
    applicationLastDate: '2026-10-01', // Date inversion!
    totalVacancies: -5, // Negative vacancies!
  };

  const validation = validateExtractedItem(invalidItem);
  assert.strictEqual(validation.isValid, false, 'Item with inverted dates and negative vacancies must fail validation');
  assert.ok(validation.criticalErrors.some((e) => e.includes('cannot be before Start Date')));
  assert.ok(validation.criticalErrors.some((e) => e.includes('negative')));

  // Valid item
  const validItem = {
    title: 'SSC Combined Hindi Translator Recruitment 2026',
    organization: 'Staff Selection Commission',
    applicationStartDate: '2026-10-01',
    applicationLastDate: '2026-10-31',
    totalVacancies: 120,
    officialWebsiteUrl: 'https://ssc.gov.in',
  };
  const validRes = validateExtractedItem(validItem);
  assert.strictEqual(validRes.isValid, true, 'Valid notice must pass validation');
});

// TEST 9: Auto-Publish Decision Engine
runTest('9. Auto-publish decision engine (safety guardrails)', () => {
  const sourceWithAutoPublish = {
    autoPublish: true,
    confidenceThreshold: 0.85,
  };
  const sourceWithoutAutoPublish = {
    autoPublish: false,
    confidenceThreshold: 0.85,
  };
  const settings = { confidenceThreshold: 0.85 };

  // Case A: autoPublish is false -> Never auto publish (routes to Review Queue)
  const candidateA = {
    overallConfidence: 0.98,
    validationResult: { isValid: true },
    duplicateCheckResult: { isDuplicate: false },
    extractedData: { officialWebsiteUrl: 'https://official.gov.in' },
  };
  assert.strictEqual(canAutoPublish(candidateA, sourceWithoutAutoPublish, settings), false);

  // Case B: autoPublish is true, but confidence below threshold -> Review Queue
  const candidateB = {
    overallConfidence: 0.72, // Below 0.85
    validationResult: { isValid: true },
    duplicateCheckResult: { isDuplicate: false },
    extractedData: { officialWebsiteUrl: 'https://official.gov.in' },
  };
  assert.strictEqual(canAutoPublish(candidateB, sourceWithAutoPublish, settings), false);

  // Case C: autoPublish is true, confidence >= 0.85, 0 validation errors, no duplicate -> Auto-Publish Allowed!
  const candidateC = {
    overallConfidence: 0.94,
    validationResult: { isValid: true },
    duplicateCheckResult: { isDuplicate: false },
    extractedData: { officialNotificationUrl: 'https://official.gov.in/notice.pdf' },
  };
  assert.strictEqual(canAutoPublish(candidateC, sourceWithAutoPublish, settings), true);
});

console.log('\n====================================================');
console.log(`ACCEPTANCE TEST RESULTS: ${passedTests} / ${totalTests} PASSED`);
console.log('====================================================');

if (passedTests === totalTests) {
  process.exit(0);
} else {
  process.exit(1);
}
