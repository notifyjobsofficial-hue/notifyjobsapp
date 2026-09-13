import {
  collection,
  doc,
  getDocs,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  serverTimestamp,
  startAfter,
  QueryDocumentSnapshot,
} from 'firebase/firestore';
import { db, isFirebaseConfigured } from '../firebase/config';
import { ContentItem, ContentStatus, ContentType, StatusOverride } from '../types';

const COLLECTION_NAME = 'content';

/**
 * Generate normalized search keywords array for fast tokenized Firestore queries
 */
export function generateSearchKeywords(item: Partial<ContentItem>): string[] {
  const parts = [
    item.title || '',
    item.organization || '',
    item.jobRole || '',
    item.qualification || '',
    item.location || '',
    item.department || '',
  ];

  const rawText = parts.join(' ').toLowerCase();
  // Split on punctuation/spaces and keep tokens of 2+ chars
  const tokens = rawText
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter((t) => t.length >= 2);

  return Array.from(new Set(tokens)).slice(0, 30);
}

/**
 * Calculate dynamic status according to Specification 63
 * - Future deadline (> 3 days): Open
 * - Within 3 days: Closing Soon
 * - Today: Closing Today
 * - Past: Closed
 * - statusOverride takes precedence if set to non-auto
 */
export function calculateJobStatus(
  applicationLastDate?: string,
  statusOverride?: StatusOverride
): { status: 'open' | 'closing_soon' | 'closing_today' | 'closed'; label: string; color: string } {
  if (statusOverride && statusOverride !== 'auto') {
    switch (statusOverride) {
      case 'open':
        return { status: 'open', label: 'Open', color: '#159B76' };
      case 'closing_soon':
        return { status: 'closing_soon', label: 'Closing Soon', color: '#F59E0B' };
      case 'closing_today':
        return { status: 'closing_today', label: 'Closing Today', color: '#DC2626' };
      case 'closed':
        return { status: 'closed', label: 'Closed', color: '#64748B' };
    }
  }

  if (!applicationLastDate) {
    return { status: 'open', label: 'Open', color: '#159B76' };
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const deadline = new Date(applicationLastDate);
  deadline.setHours(0, 0, 0, 0);

  const diffDays = Math.round((deadline.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

  if (diffDays < 0) {
    return { status: 'closed', label: 'Closed', color: '#64748B' };
  } else if (diffDays === 0) {
    return { status: 'closing_today', label: 'Closing Today', color: '#DC2626' };
  } else if (diffDays <= 3) {
    return { status: 'closing_soon', label: `Closing in ${diffDays}d`, color: '#F59E0B' };
  } else {
    return { status: 'open', label: 'Open', color: '#159B76' };
  }
}

// Local in-memory mock store for preview / initial testing if Firebase is not connected yet
let memoryContent: ContentItem[] = [
  {
    id: 'ssc-cgl-2026',
    contentType: 'government_job',
    title: 'SSC CGL 2026 Notification - 8,200 Group B & C Vacancies',
    slug: 'ssc-cgl-2026-notification',
    excerpt: 'Staff Selection Commission has announced 8,200 vacancies for Assistant Section Officer, Inspector, and Tax Assistant.',
    body: '## SSC Combined Graduate Level Examination 2026\n\nStaff Selection Commission (SSC) conducts the Combined Graduate Level (CGL) examination for recruitment to various Group B and Group C posts in ministries, departments, and organizations of the Government of India.\n\n### Key Highlights\n- **Post Names**: Assistant Section Officer, Inspector of Central Excise, Preventive Officer, Sub Inspector (CBI), Tax Assistant.\n- **Eligibility**: Bachelor Degree from any recognized university.\n- **Mode of Exam**: Computer Based Test (Tier 1 and Tier 2).',
    organization: 'Staff Selection Commission (SSC)',
    department: 'Department of Personnel and Training (DoPT)',
    jobRole: 'Group B & C Officers',
    vacancies: '8,200',
    qualification: 'Graduation in any stream',
    salary: '₹35,400 - ₹1,12,400 (Level 4 to Level 7)',
    location: 'All India',
    jobType: 'Regular Central Govt',
    applicationStartDate: '2026-09-01',
    applicationLastDate: '2026-09-30',
    statusOverride: 'auto',
    officialWebsiteUrl: 'https://ssc.gov.in',
    officialNotificationUrl: 'https://ssc.gov.in/notices/cgl_2026.pdf',
    applyUrl: 'https://ssc.gov.in/apply',
    importantDates: [
      { id: '1', label: 'Notification Release', date: '01 Sep 2026' },
      { id: '2', label: 'Application Start', date: '01 Sep 2026' },
      { id: '3', label: 'Last Date to Apply', date: '30 Sep 2026' },
      { id: '4', label: 'Tier 1 Exam Date', date: 'Nov/Dec 2026', isTentative: true },
    ],
    vacanciesBreakdown: [
      { id: '1', postName: 'Assistant Section Officer', category: 'UR/OBC/SC/ST/EWS', count: '1,850', payLevel: 'Level 7' },
      { id: '2', postName: 'Inspector (Central Excise)', category: 'UR/OBC/SC/ST/EWS', count: '2,200', payLevel: 'Level 7' },
      { id: '3', postName: 'Tax Assistant', category: 'UR/OBC/SC/ST/EWS', count: '1,450', payLevel: 'Level 4' },
      { id: '4', postName: 'Sub Inspector (CBI)', category: 'UR/OBC/SC/ST/EWS', count: '320', payLevel: 'Level 7' },
    ],
    ageLimits: [
      { id: '1', category: 'General / UR', relaxationYears: 'None', maxAge: '30 Years' },
      { id: '2', category: 'OBC (Non-Creamy Layer)', relaxationYears: '3 Years', maxAge: '33 Years' },
      { id: '3', category: 'SC / ST', relaxationYears: '5 Years', maxAge: '35 Years' },
      { id: '4', category: 'PwD', relaxationYears: '10 Years', maxAge: '40 Years' },
    ],
    applicationFees: [
      { id: '1', category: 'General / OBC / EWS (Male)', fee: '₹100', paymentMode: 'Online Netbanking / UPI / Card' },
      { id: '2', category: 'SC / ST / PwD / ESM / All Females', fee: 'Exempted (₹0)', paymentMode: 'N/A' },
    ],
    selectionProcess: [
      { id: '1', stageNumber: 1, name: 'Tier 1 Examination', description: 'Objective Computer Based Test (CBT) covering Reasoning, GA, Quant, and English.' },
      { id: '2', stageNumber: 2, name: 'Tier 2 Examination', description: 'Subject Paper CBT + Computer Proficiency Test (DEST) Data Entry Speed Test.' },
      { id: '3', stageNumber: 3, name: 'Document Verification', description: 'Scrutiny of original educational and caste certificates by user departments.' },
    ],
    examPattern: [
      { id: '1', subject: 'General Intelligence & Reasoning', questions: 25, marks: 50, duration: '60 Mins Total' },
      { id: '2', subject: 'General Awareness', questions: 25, marks: 50 },
      { id: '3', subject: 'Quantitative Aptitude', questions: 25, marks: 50 },
      { id: '4', subject: 'English Comprehension', questions: 25, marks: 50 },
    ],
    importantLinks: [
      { id: '1', title: 'Apply Online', url: 'https://ssc.gov.in/apply', type: 'apply_online' },
      { id: '2', title: 'Official Notification PDF', url: 'https://ssc.gov.in/notices/cgl_2026.pdf', type: 'official_notification' },
      { id: '3', title: 'Official SSC Portal', url: 'https://ssc.gov.in', type: 'official_website' },
    ],
    faqs: [
      { id: '1', question: 'What is the minimum qualification for SSC CGL?', answer: 'Candidates must possess a Bachelor Degree in any discipline from a recognized University.' },
      { id: '2', question: 'Is there any negative marking in Tier 1?', answer: 'Yes, 0.50 marks will be deducted for each incorrect answer.' },
    ],
    sourceOrg: 'Staff Selection Commission (Official Website)',
    sourceUrl: 'https://ssc.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-01T10:00:00.000Z',
    updatedAt: '2026-09-10T14:30:00.000Z',
    views: 14280,
    categoryIds: ['latest-jobs', 'ssc'],
    tags: ['ssc', 'cgl', 'graduate', 'central-govt'],
    searchKeywords: ['ssc', 'cgl', '2026', 'staff', 'selection', 'commission', 'group', 'officers', 'graduation'],
    seoTitle: 'SSC CGL 2026 Notification, Vacancies, Exam Date & Apply Online',
    seoDescription: 'Apply online for SSC CGL 2026 recruitment. Check 8200 vacancies, eligibility, qualification, salary, and last date.',
  },
  {
    id: 'andaman-police-si-2026',
    contentType: 'government_job',
    title: 'Andaman & Nicobar Police SI & Constable Recruitment 2026',
    slug: 'andaman-nicobar-police-recruitment-2026',
    excerpt: 'Andaman & Nicobar Police Department announces vacancies for Sub-Inspector and Police Constable posts in Port Blair.',
    body: '## Andaman and Nicobar Police Recruitment 2026\n\nApplications are invited from eligible candidates for filling up Sub-Inspector and Constable vacancies in Andaman & Nicobar Police Force.\n\n### Eligibility Criteria\n- Local candidates possessing valid residency certificate of A&N Islands.\n- Physical measurement and fitness tests apply as per standard service rules.',
    organization: 'Andaman & Nicobar Police',
    department: 'Director General of Police, Port Blair',
    jobRole: 'Sub-Inspector & Constable',
    vacancies: '340',
    qualification: '12th Pass / Graduate',
    salary: '₹21,700 - ₹69,100 (Level 3 to Level 6)',
    location: 'Port Blair, Andaman & Nicobar',
    jobType: 'UT Administration Regular',
    applicationStartDate: '2026-09-05',
    applicationLastDate: '2026-10-05',
    statusOverride: 'auto',
    officialWebsiteUrl: 'https://police.andaman.gov.in',
    officialNotificationUrl: 'https://police.andaman.gov.in/recruitment_2026.pdf',
    applyUrl: 'https://police.andaman.gov.in/online',
    importantDates: [
      { id: '1', label: 'Online Application Opens', date: '05 Sep 2026' },
      { id: '2', label: 'Last Date to Submit Online', date: '05 Oct 2026' },
      { id: '3', label: 'Physical Endurance Test', date: 'November 2026', isTentative: true },
    ],
    vacanciesBreakdown: [
      { id: '1', postName: 'Sub-Inspector (Executive)', category: 'Island Residents', count: '45', payLevel: 'Level 6' },
      { id: '2', postName: 'Police Constable', category: 'Island Residents', count: '295', payLevel: 'Level 3' },
    ],
    ageLimits: [
      { id: '1', category: 'Male (General)', relaxationYears: 'Standard', maxAge: '25 Years' },
      { id: '2', category: 'Female (General)', relaxationYears: 'Standard', maxAge: '28 Years' },
      { id: '3', category: 'OBC / Tribals of A&N', relaxationYears: '3 to 5 Years', maxAge: '30 Years' },
    ],
    applicationFees: [
      { id: '1', category: 'All Applicants', fee: '₹0 (No Application Fee)', paymentMode: 'Exempted' },
    ],
    selectionProcess: [
      { id: '1', stageNumber: 1, name: 'Physical Endurance & Measurement Test (PE&MT)', description: 'Running, Long Jump, High Jump.' },
      { id: '2', stageNumber: 2, name: 'Written Examination', description: 'Objective test of 100 marks covering GK, Reasoning, and Elementary Mathematics.' },
      { id: '3', stageNumber: 3, name: 'Medical Examination', description: 'Fitness verification at GB Pant Hospital, Port Blair.' },
    ],
    examPattern: [
      { id: '1', subject: 'General Knowledge & Current Affairs', questions: 40, marks: 40, duration: '90 Mins' },
      { id: '2', subject: 'Reasoning & Aptitude', questions: 30, marks: 30 },
      { id: '3', subject: 'Elementary Mathematics', questions: 30, marks: 30 },
    ],
    importantLinks: [
      { id: '1', title: 'Apply Online', url: 'https://police.andaman.gov.in/online', type: 'apply_online' },
      { id: '2', title: 'Official Notification PDF', url: 'https://police.andaman.gov.in/recruitment_2026.pdf', type: 'official_notification' },
      { id: '3', title: 'Police Website', url: 'https://police.andaman.gov.in', type: 'official_website' },
    ],
    faqs: [
      { id: '1', question: 'Who can apply for A&N Police Constable?', answer: 'Candidates must be 12th pass and permanent residents of Andaman and Nicobar Islands.' },
    ],
    sourceOrg: 'A&N Police Headquarters, Port Blair',
    sourceUrl: 'https://police.andaman.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-05T09:00:00.000Z',
    updatedAt: '2026-09-11T12:00:00.000Z',
    views: 8940,
    categoryIds: ['latest-jobs', 'andaman-nicobar', 'police-defence'],
    tags: ['andaman', 'police', 'port-blair', 'constable'],
    searchKeywords: ['andaman', 'nicobar', 'police', 'port', 'blair', 'constable', 'sub', 'inspector'],
    seoTitle: 'Andaman & Nicobar Police Recruitment 2026 Notification',
    seoDescription: 'Apply for 340 A&N Police Constable and SI posts. Check eligibility and apply online.',
  },
  {
    id: 'rrb-ntpc-2026-admit-card',
    contentType: 'admit_card',
    title: 'RRB NTPC CBT 1 Admit Card 2026 Released',
    slug: 'rrb-ntpc-cbt-1-admit-card-2026',
    excerpt: 'Railway Recruitment Board (RRB) has released CBT 1 e-call letters for Non-Technical Popular Categories.',
    body: '## RRB NTPC E-Call Letter 2026\n\nCandidates appearing for RRB NTPC CBT 1 can now download their city intimation slip and admit card using their Registration Number and Date of Birth.',
    organization: 'Railway Recruitment Boards (RRB)',
    jobRole: 'NTPC Graduate & Undergraduate',
    vacancies: '11,558',
    qualification: '12th / Graduate',
    salary: 'Level 2 to Level 6',
    location: 'All India',
    applicationStartDate: '',
    applicationLastDate: '',
    importantDates: [
      { id: '1', label: 'Admit Card Release Date', date: '10 Sep 2026' },
      { id: '2', label: 'CBT 1 Exam Dates', date: '20 Sep to 15 Oct 2026' },
    ],
    vacanciesBreakdown: [],
    ageLimits: [],
    applicationFees: [],
    selectionProcess: [],
    examPattern: [],
    importantLinks: [
      { id: '1', title: 'Download Admit Card', url: 'https://rrbcdg.gov.in/admit-card', type: 'admit_card' },
      { id: '2', title: 'Official RRB Notice', url: 'https://rrbcdg.gov.in/notice_cbt1.pdf', type: 'official_notification' },
    ],
    faqs: [],
    sourceOrg: 'Railway Recruitment Control Board',
    sourceUrl: 'https://rrbcdg.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-10T08:00:00.000Z',
    updatedAt: '2026-09-10T08:00:00.000Z',
    views: 19820,
    categoryIds: ['admit-cards', 'railway'],
    tags: ['rrb', 'ntpc', 'admit-card', 'railway'],
    searchKeywords: ['rrb', 'ntpc', 'admit', 'card', '2026', 'railway', 'recruitment', 'board', 'cbt1'],
  },
  {
    id: 'upsc-civil-services-2026-result',
    contentType: 'result',
    title: 'UPSC Civil Services Prelims 2026 Result Declared',
    slug: 'upsc-civil-services-prelims-2026-result',
    excerpt: 'Union Public Service Commission has announced the results for Civil Services Preliminary Examination 2026 with roll-wise qualified candidates list.',
    body: '## UPSC CSE Prelims 2026 Result\n\nThe Union Public Service Commission (UPSC) has published the PDF containing the roll numbers of candidates who qualified for the Civil Services (Mains) Examination 2026.',
    organization: 'Union Public Service Commission (UPSC)',
    jobRole: 'IAS, IPS, IFS & Central Group A Services',
    vacancies: '1,056',
    qualification: 'Graduate',
    salary: 'Level 10 onwards',
    location: 'New Delhi / All India',
    importantDates: [
      { id: '1', label: 'Prelims Exam Date', date: '24 May 2026' },
      { id: '2', label: 'Result Declaration Date', date: '08 Sep 2026' },
      { id: '3', label: 'Mains Exam Starts', date: '18 Sep 2026' },
    ],
    vacanciesBreakdown: [],
    ageLimits: [],
    applicationFees: [],
    selectionProcess: [],
    examPattern: [],
    importantLinks: [
      { id: '1', title: 'Download Result PDF', url: 'https://upsc.gov.in/results/cse_prelims_2026.pdf', type: 'result' },
      { id: '2', title: 'Official UPSC Portal', url: 'https://upsc.gov.in', type: 'official_website' },
    ],
    faqs: [],
    sourceOrg: 'UPSC Dholpur House, New Delhi',
    sourceUrl: 'https://upsc.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-08T15:00:00.000Z',
    updatedAt: '2026-09-08T15:00:00.000Z',
    views: 31200,
    categoryIds: ['results'],
    tags: ['upsc', 'cse', 'result', 'prelims', 'ias'],
    searchKeywords: ['upsc', 'civil', 'services', 'prelims', 'result', '2026', 'merit', 'list'],
  },
  {
    id: 'how-to-prepare-for-ssc-cgl-article',
    contentType: 'article',
    title: 'How to Clear SSC CGL in First Attempt: Complete Strategy & Booklist',
    slug: 'how-to-clear-ssc-cgl-first-attempt-strategy',
    excerpt: 'Detailed 6-month roadmap, daily schedule, section-wise strategy, and best books recommended by previous year toppers.',
    body: '## Comprehensive Preparation Guide for SSC CGL\n\nCracking SSC CGL requires a disciplined approach balancing accuracy and speed across four key pillars: Quantitative Aptitude, Reasoning, English Comprehension, and General Awareness.\n\n### 1. Mathematics / Quantitative Aptitude\nFocus on Arithmetic fundamentals first (Percentage, Ratio, Profit & Loss, Time & Work), followed by Advanced Maths (Algebra, Trigonometry, Geometry, Mensuration).\n\n### 2. English Comprehension\nDaily reading of newspaper editorials enhances comprehension and vocabulary. Practice previous year error spotting and sentence improvement daily.\n\n### 3. General Intelligence & Reasoning\nSolve 50 questions daily covering coding-decoding, series, syllogisms, and analogies.\n\n### 4. General Awareness\nDedicate 1 hour daily to current affairs and revise static GK notes systematically.',
    organization: 'Notify Jobs Editorial Desk',
    jobRole: 'Article / Guide',
    vacancies: '',
    qualification: '',
    salary: '',
    location: '',
    importantDates: [],
    vacanciesBreakdown: [],
    ageLimits: [],
    applicationFees: [],
    selectionProcess: [],
    examPattern: [],
    importantLinks: [
      { id: '1', title: 'Download Study Timetable PDF', url: 'https://notifyjobs.in/guides/ssc-roadmap.pdf', type: 'download_pdf' },
    ],
    faqs: [
      { id: '1', question: 'How many hours daily are required for SSC CGL?', answer: 'A dedicated 6 to 8 hours daily for 6 months is generally sufficient for comprehensive coverage and multiple mock tests.' },
    ],
    sourceOrg: 'Notify Jobs Editorial',
    sourceUrl: 'https://notifyjobs.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-02T12:00:00.000Z',
    updatedAt: '2026-09-02T12:00:00.000Z',
    views: 6420,
    categoryIds: ['articles', 'ssc'],
    tags: ['ssc', 'cgl', 'preparation', 'strategy', 'study-plan'],
    searchKeywords: ['how', 'to', 'prepare', 'ssc', 'cgl', 'strategy', 'booklist', 'topper', 'roadmap'],
    seoTitle: 'How to Prepare for SSC CGL: Section-wise Strategy & Books',
    seoDescription: 'Master the SSC CGL exam with our comprehensive guide, daily study timetable, and recommended booklist.',
  }
];

export async function fetchContentList(options: {
  contentType?: ContentType | 'all';
  status?: ContentStatus | 'all';
  categoryId?: string;
  searchTerm?: string;
  limitCount?: number;
}): Promise<ContentItem[]> {
  if (!isFirebaseConfigured) {
    // Return filtered memory data
    let list = [...memoryContent];
    if (options.contentType && options.contentType !== 'all') {
      list = list.filter((i) => i.contentType === options.contentType);
    }
    if (options.status && options.status !== 'all') {
      list = list.filter((i) => i.status === options.status);
    }
    if (options.categoryId) {
      list = list.filter((i) => i.categoryIds.includes(options.categoryId!));
    }
    if (options.searchTerm) {
      const q = options.searchTerm.toLowerCase();
      list = list.filter(
        (i) =>
          i.title.toLowerCase().includes(q) ||
          i.organization.toLowerCase().includes(q) ||
          i.jobRole.toLowerCase().includes(q)
      );
    }
    return list;
  }

  try {
    const contentRef = collection(db, COLLECTION_NAME);
    let q = query(contentRef, orderBy('updatedAt', 'desc'), limit(options.limitCount || 50));

    if (options.status && options.status !== 'all') {
      q = query(contentRef, where('status', '==', options.status), limit(options.limitCount || 50));
    }

    const snapshot = await getDocs(q);
    const items: ContentItem[] = [];
    snapshot.forEach((docSnap) => {
      items.push({ id: docSnap.id, ...docSnap.data() } as ContentItem);
    });
    return items;
  } catch (err) {
    console.error('Failed to fetch content from Firestore, using fallback:', err);
    return memoryContent;
  }
}

export async function getContentById(id: string): Promise<ContentItem | null> {
  if (!isFirebaseConfigured) {
    return memoryContent.find((i) => i.id === id) || null;
  }

  try {
    const docRef = doc(db, COLLECTION_NAME, id);
    const snap = await getDoc(docRef);
    if (snap.exists()) {
      return { id: snap.id, ...snap.data() } as ContentItem;
    }
    return null;
  } catch (err) {
    console.error('Failed to get content by ID:', err);
    return memoryContent.find((i) => i.id === id) || null;
  }
}

export async function saveContent(
  content: Partial<ContentItem>,
  userEmail: string
): Promise<string> {
  const isNew = !content.id;
  const id = content.id || content.slug || `job-${Date.now()}`;
  const now = new Date().toISOString();

  const keywords = generateSearchKeywords(content);

  const payload: ContentItem = {
    id,
    contentType: content.contentType || 'government_job',
    title: content.title || '',
    slug: content.slug || id,
    excerpt: content.excerpt || '',
    body: content.body || '',
    featuredImageUrl: content.featuredImageUrl || '',

    organization: content.organization || '',
    department: content.department || '',
    jobRole: content.jobRole || '',
    vacancies: content.vacancies || '',
    qualification: content.qualification || '',
    salary: content.salary || '',
    location: content.location || '',
    jobType: content.jobType || 'Regular Govt',

    applicationStartDate: content.applicationStartDate || '',
    applicationLastDate: content.applicationLastDate || '',
    statusOverride: content.statusOverride || 'auto',

    officialWebsiteUrl: content.officialWebsiteUrl || '',
    officialNotificationUrl: content.officialNotificationUrl || '',
    applyUrl: content.applyUrl || '',

    importantDates: content.importantDates || [],
    vacanciesBreakdown: content.vacanciesBreakdown || [],
    ageLimits: content.ageLimits || [],
    applicationFees: content.applicationFees || [],
    selectionProcess: content.selectionProcess || [],
    examPattern: content.examPattern || [],
    importantLinks: content.importantLinks || [],
    faqs: content.faqs || [],

    sourceOrg: content.sourceOrg || '',
    sourceUrl: content.sourceUrl || '',
    lastVerifiedAt: content.lastVerifiedAt || new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' }),

    status: content.status || 'published',
    isPublished: content.status === 'published',
    publishedAt: content.publishedAt || (content.status === 'published' ? now : undefined),
    updatedAt: now,
    createdAt: content.createdAt || now,
    createdBy: content.createdBy || userEmail,
    updatedBy: userEmail,

    views: content.views || 0,
    categoryIds: content.categoryIds || ['latest-jobs'],
    tags: content.tags || [],
    searchKeywords: keywords,

    seoTitle: content.seoTitle || content.title,
    seoDescription: content.seoDescription || content.excerpt,
  };

  if (!isFirebaseConfigured) {
    const existingIndex = memoryContent.findIndex((i) => i.id === id);
    if (existingIndex >= 0) {
      memoryContent[existingIndex] = payload;
    } else {
      memoryContent.unshift(payload);
    }
    return id;
  }

  try {
    const docRef = doc(db, COLLECTION_NAME, id);
    await setDoc(docRef, payload, { merge: true });
    return id;
  } catch (err) {
    console.error('Failed to save to Firestore, updating local memory:', err);
    const existingIndex = memoryContent.findIndex((i) => i.id === id);
    if (existingIndex >= 0) {
      memoryContent[existingIndex] = payload;
    } else {
      memoryContent.unshift(payload);
    }
    return id;
  }
}

export async function archiveContent(id: string): Promise<void> {
  if (!isFirebaseConfigured) {
    const item = memoryContent.find((i) => i.id === id);
    if (item) {
      item.status = 'archived';
      item.isPublished = false;
    }
    return;
  }

  try {
    const docRef = doc(db, COLLECTION_NAME, id);
    await updateDoc(docRef, { status: 'archived', isPublished: false, updatedAt: new Date().toISOString() });
  } catch (err) {
    console.error('Error archiving document:', err);
  }
}

export async function deleteContentPermanently(id: string): Promise<void> {
  if (!isFirebaseConfigured) {
    memoryContent = memoryContent.filter((i) => i.id !== id);
    return;
  }

  try {
    const docRef = doc(db, COLLECTION_NAME, id);
    await deleteDoc(docRef);
  } catch (err) {
    console.error('Error deleting document:', err);
  }
}
