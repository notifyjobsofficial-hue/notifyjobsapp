export type ContentType =
  | 'government_job'
  | 'private_job'
  | 'admit_card'
  | 'result'
  | 'answer_key'
  | 'syllabus'
  | 'admission'
  | 'scheme'
  | 'article';

export type ContentStatus = 'draft' | 'published' | 'archived';

export type StatusOverride = 'auto' | 'open' | 'closing_soon' | 'closing_today' | 'closed';

export interface ImportantDateItem {
  id: string;
  label: string;
  date: string;
  isTentative?: boolean;
}

export interface VacancyItem {
  id: string;
  postName: string;
  category: string;
  count: number | string;
  payLevel?: string;
}

export interface AgeLimitItem {
  id: string;
  category: string;
  relaxationYears: string;
  maxAge?: string;
}

export interface ApplicationFeeItem {
  id: string;
  category: string;
  fee: string;
  paymentMode?: string;
}

export interface SelectionStepItem {
  id: string;
  stageNumber: number;
  name: string;
  description: string;
}

export interface ExamPatternItem {
  id: string;
  subject: string;
  questions: string | number;
  marks: string | number;
  duration?: string;
}

export interface ImportantLinkItem {
  id: string;
  title: string;
  url: string;
  type: 'apply_online' | 'official_notification' | 'official_website' | 'download_pdf' | 'result' | 'admit_card' | 'custom';
}

export interface FAQItem {
  id: string;
  question: string;
  answer: string;
}

export interface ContentItem {
  id: string;
  contentType: ContentType;
  title: string;
  slug: string;
  excerpt: string;
  body: string;
  featuredImageUrl?: string;

  // Job specific fields
  organization: string;
  department?: string;
  jobRole: string;
  vacancies: string;
  qualification: string;
  salary: string;
  location: string;
  jobType?: string; // Full Time, Contractual, Apprenticeship

  // Application dates
  applicationStartDate?: string;
  applicationLastDate?: string;
  statusOverride?: StatusOverride;

  // Official links
  officialWebsiteUrl?: string;
  officialNotificationUrl?: string;
  applyUrl?: string;

  // Structured breakdown arrays
  importantDates: ImportantDateItem[];
  vacanciesBreakdown: VacancyItem[];
  ageLimits: AgeLimitItem[];
  applicationFees: ApplicationFeeItem[];
  selectionProcess: SelectionStepItem[];
  examPattern: ExamPatternItem[];
  importantLinks: ImportantLinkItem[];
  faqs: FAQItem[];

  // Trust / source verification
  sourceOrg?: string;
  sourceUrl?: string;
  lastVerifiedAt?: string;

  // Status & meta
  status: ContentStatus;
  isPublished: boolean;
  publishedAt?: string;
  updatedAt?: string;
  createdAt?: string;
  createdBy?: string;
  updatedBy?: string;

  views: number;
  categoryIds: string[];
  tags: string[];
  searchKeywords: string[];

  seoTitle?: string;
  seoDescription?: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  icon: string;
  color: string;
  order: number;
  isActive: boolean;
}

export interface HomepageSection {
  id: string;
  key: string;
  title: string;
  subtitle?: string;
  contentType?: ContentType | '';
  categoryId?: string;
  enabled: boolean;
  order: number;
  limit: number;
  sort: 'publishedAt_desc' | 'views_desc' | 'deadline_asc' | 'order_asc';
}

export interface AppSettings {
  appTitle: string;
  tagline: string;
  maintenanceMode: boolean;
  maintenanceMessage: string;
  minimumAppVersion: string;
  latestAppVersion: string;
  forceUpdateUrl: string;

  supportEmail: string;
  supportWebsite: string;

  whatsappUrl: string;
  whatsappEnabled: boolean;
  telegramUrl: string;
  telegramEnabled: boolean;
  youtubeUrl: string;
  youtubeEnabled: boolean;
  facebookUrl: string;
  facebookEnabled: boolean;
  instagramUrl: string;
  instagramEnabled: boolean;
  xUrl: string;
  xEnabled: boolean;

  privacyUrl: string;
  termsUrl: string;
  disclaimerUrl: string;
  contactUrl: string;

  rewardedAdsEnabled: boolean;
  rewardNotificationEnabled: boolean;
  rewardUnlockMinutes: number;
  rewardPromptText: string;
  rewardButtonText: string;

  shareBaseUrl: string;
  playStoreUrl: string;
  disclaimer: string;
}

export interface AdminUser {
  uid: string;
  email: string;
  displayName: string;
  role: 'super_admin' | 'editor';
  active: boolean;
  createdAt: string;
  lastLoginAt?: string;
}

export interface NotificationLog {
  id: string;
  title: string;
  body: string;
  topic: string;
  contentId?: string;
  imageUrl?: string;
  sentAt: string;
  sentBy: string;
  status: 'success' | 'failed';
  messageId?: string;
  error?: string;
}
