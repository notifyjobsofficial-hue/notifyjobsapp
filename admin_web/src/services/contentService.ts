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

// Pure Firestore content service (Zero fake/demo data in production)
let memoryContent: ContentItem[] = [];

export async function fetchContentList(options: {
  contentType?: ContentType | 'all';
  status?: ContentStatus | 'all';
  categoryId?: string;
  searchTerm?: string;
  limitCount?: number;
}): Promise<ContentItem[]> {
  try {
    const contentRef = collection(db, COLLECTION_NAME);
    let q = query(contentRef, orderBy('updatedAt', 'desc'), limit(options.limitCount || 100));

    if (options.status && options.status !== 'all') {
      q = query(contentRef, where('status', '==', options.status), limit(options.limitCount || 100));
    }

    const snapshot = await getDocs(q);
    let items: ContentItem[] = [];
    snapshot.forEach((docSnap) => {
      items.push({ id: docSnap.id, ...docSnap.data() } as ContentItem);
    });

    // Apply client-side filters for contentType, categoryId, and search if specified
    if (options.contentType && options.contentType !== 'all') {
      items = items.filter((i) => i.contentType === options.contentType);
    }
    if (options.categoryId) {
      items = items.filter((i) => i.categoryIds && i.categoryIds.includes(options.categoryId!));
    }
    if (options.searchTerm) {
      const term = options.searchTerm.toLowerCase();
      items = items.filter(
        (i) =>
          (i.title && i.title.toLowerCase().includes(term)) ||
          (i.organization && i.organization.toLowerCase().includes(term)) ||
          (i.jobRole && i.jobRole.toLowerCase().includes(term))
      );
    }

    memoryContent = items;
    return items;
  } catch (err) {
    console.error('Failed to fetch content from Firestore:', err);
    // Return empty list - never inject fake data
    return [];
  }
}

export async function getContentById(id: string): Promise<ContentItem | null> {
  try {
    const docRef = doc(db, COLLECTION_NAME, id);
    const snap = await getDoc(docRef);
    if (snap.exists()) {
      return { id: snap.id, ...snap.data() } as ContentItem;
    }
    return null;
  } catch (err) {
    console.error('Failed to get content by ID:', err);
    return null;
  }
}

export async function saveContent(
  content: Partial<ContentItem>,
  userEmail: string
): Promise<string> {
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

  const docRef = doc(db, COLLECTION_NAME, id);
  await setDoc(docRef, payload, { merge: true });

  const idx = memoryContent.findIndex((i) => i.id === id);
  if (idx >= 0) memoryContent[idx] = payload;
  else memoryContent.unshift(payload);

  return id;
}

export async function archiveContent(id: string): Promise<void> {
  const docRef = doc(db, COLLECTION_NAME, id);
  await updateDoc(docRef, {
    status: 'archived',
    isPublished: false,
    updatedAt: new Date().toISOString(),
  });

  const item = memoryContent.find((i) => i.id === id);
  if (item) {
    item.status = 'archived';
    item.isPublished = false;
  }
}

export async function toggleContentPublish(id: string, isPublished: boolean): Promise<void> {
  const docRef = doc(db, COLLECTION_NAME, id);
  const now = new Date().toISOString();
  await updateDoc(docRef, {
    status: isPublished ? 'published' : 'draft',
    isPublished,
    updatedAt: now,
    ...(isPublished ? { publishedAt: now } : {}),
  });

  const item = memoryContent.find((i) => i.id === id);
  if (item) {
    item.status = isPublished ? 'published' : 'draft';
    item.isPublished = isPublished;
    item.updatedAt = now;
    if (isPublished && !item.publishedAt) {
      item.publishedAt = now;
    }
  }
}

/**
 * Shared category and tag matcher for content list filtering and real-time counts
 */
export function isCategoryMatch(item: ContentItem, categoryFilter: string): boolean {
  if (categoryFilter === 'all') return true;
  const f = categoryFilter.toLowerCase();
  if (item.categoryIds?.includes(categoryFilter)) return true;

  if (f === 'ssc') {
    if (item.categoryIds?.includes('ssc')) return true;
    if (item.tags?.some((t) => t.toLowerCase().includes('ssc'))) return true;
    if (item.organization?.toLowerCase().includes('ssc')) return true;
    if (item.title?.toLowerCase().includes('ssc')) return true;
  }
  if (f === 'railway') {
    if (item.categoryIds?.includes('railway') || item.categoryIds?.includes('railways')) return true;
    if (item.tags?.some((t) => t.toLowerCase().includes('railway') || t.toLowerCase().includes('rrb'))) return true;
    if (item.organization?.toLowerCase().includes('railway') || item.organization?.toLowerCase().includes('rrb')) return true;
    if (item.title?.toLowerCase().includes('railway') || item.title?.toLowerCase().includes('rrb')) return true;
  }
  if (f === 'banking') {
    if (item.categoryIds?.includes('banking') || item.categoryIds?.includes('bank')) return true;
    if (item.tags?.some((t) => t.toLowerCase().includes('bank') || t.toLowerCase().includes('ibps') || t.toLowerCase().includes('sbi'))) return true;
    if (item.organization?.toLowerCase().includes('bank') || item.organization?.toLowerCase().includes('ibps') || item.organization?.toLowerCase().includes('sbi')) return true;
    if (item.title?.toLowerCase().includes('bank') || item.title?.toLowerCase().includes('ibps') || item.title?.toLowerCase().includes('sbi')) return true;
  }
  if (f === 'police-defence' || f === 'police' || f === 'defence') {
    if (item.categoryIds?.includes('police-defence') || item.categoryIds?.includes('police') || item.categoryIds?.includes('defence')) return true;
    if (item.tags?.some((t) => t.toLowerCase().includes('police') || t.toLowerCase().includes('defence') || t.toLowerCase().includes('army') || t.toLowerCase().includes('navy') || t.toLowerCase().includes('air force'))) return true;
    if (item.organization?.toLowerCase().includes('police') || item.organization?.toLowerCase().includes('defence') || item.organization?.toLowerCase().includes('crpf') || item.organization?.toLowerCase().includes('bsf') || item.organization?.toLowerCase().includes('cisf')) return true;
    if (item.title?.toLowerCase().includes('police') || item.title?.toLowerCase().includes('defence') || item.title?.toLowerCase().includes('constable') || item.title?.toLowerCase().includes('si ') || item.title?.toLowerCase().includes('sub inspector')) return true;
  }

  return Boolean(
    item.categoryIds?.includes(categoryFilter) ||
    item.tags?.some((t) => t.toLowerCase() === f || t.toLowerCase().includes(f)) ||
    item.organization?.toLowerCase().includes(f) ||
    item.title?.toLowerCase().includes(f)
  );
}

export async function deleteContentPermanently(id: string): Promise<void> {
  const docRef = doc(db, COLLECTION_NAME, id);
  await deleteDoc(docRef);
  memoryContent = memoryContent.filter((i) => i.id !== id);
}

