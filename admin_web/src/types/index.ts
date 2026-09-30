export type ContentType =
  | 'government_job'
  | 'private_job'
  | 'andaman_job'
  | 'admit_card'
  | 'result'
  | 'answer_key'
  | 'syllabus'
  | 'admission'
  | 'scheme'
  | 'article'
  | 'announcement'
  | 'quick_update';

export type JobType = 'government' | 'private' | string;

export interface JobTypeItem {
  id: string;
  name: string;
  shortName: string;
  slug: string;
  description?: string;
  icon?: string;
  order: number;
  isActive: boolean;
  colorToken?: string;
}

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

export interface VacancyBreakup {
  ur: number;
  obc: number;
  ews: number;
  sc: number;
  st: number;
  pwbd: number;
  esm?: number;
  msp?: number;
  other: number;
  total: number;
}

export interface PostItem {
  id: string;
  postName: string;
  postCode?: string;
  group?: string;
  cadre?: string;
  department?: string;
  categoryId?: string;
  categoryName?: string;
  qualification?: string;
  qualificationDetails?: string;
  desirableQualification?: string;
  location?: string;
  jobType?: string;
  payLevel?: string;
  payScale?: string;
  salaryMin?: number | string;
  salaryMax?: number | string;
  salaryText?: string;
  ageMin?: number | string;
  ageMax?: number | string;
  maleMaxAge?: number | string;
  femaleMaxAge?: number | string;
  ageAsOn?: string;
  ageRelaxation?: string;
  vacancies: VacancyBreakup;
}

export interface AgeLimitItem {
  id: string;
  category: string;
  relaxationYears: string;
  maxAge?: string;
  maximumAgeOverride?: string;
  notes?: string;
}

export interface ApplicationFeeItem {
  id: string;
  category: string;
  fee: string;
  currency?: string;
  notes?: string;
  paymentMode?: string;
}

export interface SelectionStepItem {
  id: string;
  stageNumber: number;
  name: string;
  description: string;
  mandatory?: boolean;
}

export interface SelectionRules {
  selectionBasis?: string;
  meritCalculation?: string;
  qualifyingCriteria?: string;
  documentVerificationRule?: string;
  waitingListRule?: string;
  reservationRule?: string;
  tieBreakingRules?: string[];
}

export interface DocumentItem {
  id: string;
  documentName: string;
  required: boolean;
  notes?: string;
}

export interface UploadRequirements {
  photographFormat?: string;
  photographMaxSize?: string;
  signatureFormat?: string;
  signatureMaxSize?: string;
  certificateFormat?: string;
  certificateMaxSize?: string;
}

export interface ExamDetails {
  hasExam: boolean;
  examMode?: string;
  examType?: string;
  examCentre?: string;
  examLocation?: string;
  examLanguage?: string;
  examDuration?: string;
  negativeMarking?: string;
  minimumQualifyingMarks?: string;
  admitCardMethod?: string;
}

export interface ExamPatternItem {
  id: string;
  paperName?: string;
  subject: string;
  questions: string | number;
  marks: string | number;
  duration?: string;
  negativeMarking?: string;
  minimumQualifyingMarks?: string;
  notes?: string;
}

export interface SyllabusTopicItem {
  id: string;
  subject?: string;
  topicName: string;
  details?: string;
}

export interface SyllabusPostItem {
  postId?: string;
  postName?: string;
  syllabusTitle?: string;
  topics: string[];
  syllabusPdfUrl?: string;
}

export interface SourceVerification {
  sourceOrg?: string;
  notificationNumber?: string;
  gazetteNumber?: string;
  circularNumber?: string;
  sourcePdfUrl?: string;
  sourceWebsiteUrl?: string;
  sourcePublishedDate?: string;
  sourceLanguage?: string;
  sourceVerified?: boolean;
}

export interface PhysicalStandardItem {
  id: string;
  category: string;
  gender: 'male' | 'female' | 'all';
  height?: string;
  chest?: string;
  chestExpanded?: string;
  weight?: string;
  notes?: string;
}

export interface PETEventItem {
  id: string;
  eventName: string;
  gender: 'male' | 'female' | 'all';
  standard: string;
  qualifyingTime?: string;
  notes?: string;
}

export interface TradeTestItem {
  id: string;
  postOrTrade: string;
  testName: string;
  duration?: string;
  qualifyingMarks?: string;
  criteria: string;
}

export interface MedicalStandardItem {
  id: string;
  stage: 'DME' | 'RME' | 'General';
  standardName: string;
  criteria: string;
  eyesightStandard?: string;
}

export interface DeputationConditions {
  parentDepartment?: string;
  minimumServiceYears?: string;
  deputationTenure?: string;
  maximumAge?: string;
  forwardingRules?: string;
  coolingOffPeriod?: string;
}

export interface OtherConditionItem {
  id: string;
  title: string;
  description: string;
}

export interface AppDisplayControls {
  showOverview?: boolean;
  showImportantDates?: boolean;
  showPosts?: boolean;
  showVacancies?: boolean;
  showQualification?: boolean;
  showAgeLimit?: boolean;
  showFees?: boolean;
  showSalary?: boolean;
  showApplicationProcess?: boolean;
  showDocuments?: boolean;
  showExamDetails?: boolean;
  showExamPattern?: boolean;
  showSyllabus?: boolean;
  showPhysicalStandards?: boolean;
  showPETPST?: boolean;
  showTradeTest?: boolean;
  showMedicalStandards?: boolean;
  showDeputationConditions?: boolean;
  showSelectionProcess?: boolean;
  showImportantLinks?: boolean;
  showFAQ?: boolean;
  showSourceInformation?: boolean;
  showDisclaimer?: boolean;
  showOtherConditions?: boolean;
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
  qualificationDetails?: string;
  salary: string;
  location: string;
  jobType?: 'government' | 'private' | string;
  jobTypeId?: string;
  jobTypeName?: string;
  showInLiveUpdates?: boolean;
  showOnHome?: boolean;

  // Structured Recruitment Model (v1.2)
  vacancyMode?: 'simple' | 'detailed';
  totalVacancies?: number | string;
  posts?: PostItem[];
  categoryNames?: string[];
  howToApplySteps?: string[];
  feePaymentLastDate?: string;
  correctionStartDate?: string;
  correctionEndDate?: string;
  notificationDate?: string;
  admitCardDate?: string;
  answerKeyDate?: string;
  paymentMethods?: string[];

  // One-Stop Recruitment Enhancements
  recruitmentYear?: string;
  notificationNumber?: string;
  advtNumber?: string;
  recruitmentType?: string;
  officialLanguage?: string;
  minimumQualification?: string;
  eligibilitySummary?: string;
  experienceRequired?: string;
  nationality?: string;
  registrationRequirement?: string;
  otherEligibility?: string;
  defaultMinimumAge?: string | number;
  defaultMaximumAge?: string | number;
  ageAsOn?: string;
  payLevel?: string;
  payScale?: string;
  salaryMin?: number | string;
  salaryMax?: number | string;
  salaryText?: string;
  applicationMode?: string;
  registrationRequired?: boolean;
  oneTimeRegistration?: boolean;
  applicationInstructions?: string;

  // Repeatable modules
  documents?: DocumentItem[];
  uploadRequirements?: UploadRequirements;
  examDetails?: ExamDetails;
  syllabusTopics?: SyllabusTopicItem[];
  syllabusPosts?: SyllabusPostItem[];
  syllabusPdfUrl?: string;
  selectionRules?: SelectionRules;
  tieBreakingRules?: string[];
  ageRelaxations?: AgeLimitItem[];
  appDisplayControls?: AppDisplayControls;
  sourceVerification?: SourceVerification;

  // Optional Structured Modules (Smart Universal Editor)
  physicalStandards?: PhysicalStandardItem[];
  petEvents?: PETEventItem[];
  tradeTests?: TradeTestItem[];
  medicalStandards?: MedicalStandardItem[];
  deputationConditions?: DeputationConditions;
  serviceRequirements?: string;
  reservationNotes?: string[];
  probationPeriod?: string;
  trainingPeriod?: string;
  serviceBond?: string;
  otherConditions?: OtherConditionItem[];
  enabledOptionalModules?: string[];

  // Exam & Selection Smart Toggles
  hasExamination?: boolean;
  hasPhysicalTest?: boolean;
  hasTradeTest?: boolean;
  hasInterview?: boolean;
  hasMedicalExam?: boolean;

  // Visibility & Placement Controls
  showInUserApp?: boolean;
  featured?: boolean;
  urgent?: boolean;
  showInLatestJobs?: boolean;
  showInAndamanSection?: boolean;
  showInClosingSoon?: boolean;
  showInSearch?: boolean;
  allowNotifications?: boolean;

  // Content-type specific modules & Parent Recruitment Link
  parentRecruitmentId?: string;
  parentRecruitmentTitle?: string;
  pressNoteUrl?: string;
  syllabusUrl?: string;
  admitCardUrl?: string;
  resultUrl?: string;

  // Private / Andaman specific fields
  companyName?: string;
  island?: string;
  salaryRange?: string;
  experience?: string;
  skills?: string[];
  employmentType?: string;
  workingHours?: string;
  applicationMethod?: string;
  contactEmail?: string;
  contactPhone?: string;
  whatsappApplyUrl?: string;
  jobDescription?: string;
  requirements?: string;

  // Application dates
  applicationStartDate?: string;
  applicationLastDate?: string;
  statusOverride?: StatusOverride;

  // Exam Update Specifics (Admit Card, Result, Answer Key, Syllabus)
  examDate?: string;
  admitCardReleaseDate?: string;
  reportingTime?: string;
  examCenterInfo?: string;
  resultDate?: string;
  answerKeyReleaseDate?: string;
  objectionStartDate?: string;
  objectionLastDate?: string;
  objectionFee?: string;
  instructions?: string;
  updateStatus?: string;

  // Per-Post Share Settings Override
  shareTargetModeOverride?: 'GLOBAL' | 'PLAY_STORE' | 'WEBSITE' | 'CUSTOM_URL';
  customShareUrl?: string;
  customShareText?: string;

  // Editorial Article specifics
  articleCategory?: string;
  authorName?: string;
  readingTimeMinutes?: number;

  // Announcement / Notice specifics
  announcementPriority?: 'general' | 'important' | 'urgent' | 'new';
  announcementStartAt?: string;
  announcementEndAt?: string;
  ctaLabel?: string;
  isDismissible?: boolean;

  // Quick Update alert specifics
  alertType?: string;
  expiresAt?: string;

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
  isReviewed?: boolean;
  reviewedAt?: string;
  reviewedBy?: string;
  customSectionHeadings?: Record<string, string>;

  // Status & meta
  status: ContentStatus;
  isPublished: boolean;
  publishedAt?: string;
  scheduledPublishAt?: string;
  updatedAt?: string;
  createdAt?: string;
  createdBy?: string;
  updatedBy?: string;

  views: number;
  viewCount?: number;
  categoryIds: string[];
  tags: string[];
  searchKeywords: string[];

  seoTitle?: string;
  seoDescription?: string;
}

export interface Category {
  id: string;
  name: string;
  shortName?: string;
  slug: string;
  icon: string;
  color: string;
  order: number;
  isActive: boolean;
  showOnHome?: boolean;
  showInUserApp?: boolean;
  showInQuickCategories?: boolean;
  showInJobsFilters?: boolean;
  showInUpdates?: boolean;
  showInSearch?: boolean;
  showInAdminSidebar?: boolean;
  destination?: string;
  contentScope?: 'job' | 'update' | 'article' | 'all';
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

  // Central Ad Controls (Part 13)
  adsEnabled?: boolean;
  rewardedAdsEnabled: boolean;
  supportRewardedEnabled?: boolean;
  applyRewardedEnabled?: boolean;
  notificationDownloadRewardedEnabled?: boolean;
  officialWebsiteRewardedEnabled?: boolean;
  allowSkipRewarded?: boolean;
  rewardedCooldownMinutes?: number;
  rewardedAdUnitAndroid?: string;
  testMode?: boolean;

  rewardNotificationEnabled: boolean;
  rewardUnlockMinutes: number;
  rewardPromptText: string;
  rewardButtonText: string;

  shareBaseUrl: string;
  websiteUrl?: string;
  playStoreUrl: string;
  shareEnabled?: boolean;
  shareTargetMode?: 'PLAY_STORE' | 'WEBSITE' | 'SMART';
  shareMessageTemplate?: string;
  disclaimer: string;

  // Announcement Banner (v1.1)
  announcementEnabled: boolean;
  announcementType: 'General' | 'Important' | 'Urgent' | 'New';
  announcementText: string;
  announcementUrl: string;
  announcementStartAt: string;
  announcementEndAt: string;
  announcementPriority: number;

  // Live Updates (v1.1)
  liveUpdatesEnabled: boolean;
  liveUpdatesTitle: string;
  liveUpdatesMaxItems: number;
  liveUpdatesAutoSlideEnabled: boolean;
  liveUpdatesAutoSlideSeconds: number;

  // Closing Soon (v1.1)
  closingSoonEnabled: boolean;
  closingSoonTitle: string;
  closingSoonDaysThreshold: number;
  closingSoonMaxItems: number;

  // Popular This Week (v1.1)
  popularEnabled: boolean;
  popularTitle: string;
  popularMaxItems: number;

  // Latest Jobs (v1.1)
  latestJobsEnabled: boolean;
  latestJobsTitle: string;
  latestJobsMaxItems: number;

  // Quick Categories (v1.1)
  quickCategoriesEnabled: boolean;
  quickCategoriesTitle: string;

  // Central Feature Flags (v1.1)
  proPageEnabled: boolean;
  supportPageEnabled: boolean;
  notificationPreferencesEnabled: boolean;
  socialSectionEnabled: boolean;

  // NEW Badge duration in days
  newBadgeDurationDays: number;

  // Additional dynamic section titles & subtitles
  andamanJobsTitle: string;
  andamanJobsSubtitle: string;
  importantUpdatesTitle: string;
  importantUpdatesSubtitle: string;
  articlesTitle: string;
  articlesSubtitle: string;

  // Merged Support & Ad-Free Settings
  supportPageHeading: string;
  supportPageSubtitle: string;
  adFreeProductLabel: string;
  adFreeProductDescription: string;
  adFreeProductId: string;
  supportProducts: SupportProductItem[];
  thankYouMessage: string;

  // Safe Predefined Ad Slots
  adSlots: AdSlotsConfig;
}

export interface SupportProductItem {
  id: string;
  label: string;
  description: string;
  productId: string;
  order: number;
  enabled: boolean;
  isRecommended?: boolean;
  icon?: string;
}

export interface AdSlotItem {
  id: string;
  name: string;
  format: 'rewarded';
  adUnitId: string;
  enabled: boolean;
  freeUserOnly: boolean;
}

export interface AdSlotsConfig {
  officialNotificationRewarded: AdSlotItem;
  downloadAdmitCardRewarded?: AdSlotItem;
  viewResultRewarded?: AdSlotItem;
  viewAnswerKeyRewarded?: AdSlotItem;
  viewSyllabusRewarded?: AdSlotItem;
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

export * from './automation';
