import { ContentItem, ContentType } from './index';

export type SourceType = 'HTML' | 'RSS' | 'API' | 'PDF_INDEX' | 'MANUAL';

export type SourceStatus = 'healthy' | 'warning' | 'blocked' | 'failed';

export type QueueItemStatus =
  | 'NEW'
  | 'FETCHED'
  | 'PROCESSING'
  | 'REVIEW'
  | 'APPROVED'
  | 'PUBLISHED'
  | 'DUPLICATE'
  | 'FAILED'
  | 'BLOCKED';

export type CheckFrequency =
  | 'manual'
  | 'hourly'
  | 'every_3_hours'
  | 'every_6_hours'
  | 'daily';

export interface SourceConfig {
  id: string;
  name: string;
  baseUrl: string;
  sourceType: SourceType;
  enabled: boolean;
  contentTypes: ContentType[];
  crawlPath: string; // Listing URL or endpoint path
  allowedDomains: string[];
  checkFrequency: CheckFrequency;
  autoPublish: boolean;
  confidenceThreshold: number; // e.g. 0.85
  defaultCategories: string[];
  defaultLocation: string;
  defaultOrganization: string;
  lastCheckedAt?: string;
  lastSuccessAt?: string;
  lastError?: string;
  status: SourceStatus;
  itemsFound: number;
  itemsPublished: number;
  itemsInReview: number;
  createdAt: string;
  updatedAt: string;
}

export interface FieldConfidence {
  title: number;
  organization: number;
  vacancies: number;
  lastDate: number;
  qualification: number;
  officialLinks: number;
  notificationNumber: number;
}

export interface ValidationResult {
  isValid: boolean;
  criticalErrors: string[];
  warnings: string[];
  failedRules: string[];
}

export interface DuplicateCheckResult {
  isDuplicate: boolean;
  matchedItemId?: string;
  matchedTitle?: string;
  matchedSource?: 'firestore_content' | 'automation_queue';
  matchReason?: string;
  similarityScore?: number; // 0.0 to 1.0
}

export interface DiscoveredItem {
  id: string;
  sourceId: string;
  sourceName: string;
  sourceUrl: string;
  title: string;
  discoveredAt: string;
  fingerprint: string;
  status: QueueItemStatus;
  contentType?: ContentType;
  rawContent?: string;
  isPdf?: boolean;
  isScannedPdf?: boolean;
  extractedData?: Partial<ContentItem>;
  overallConfidence?: number;
  fieldConfidence?: FieldConfidence;
  validationResult?: ValidationResult;
  duplicateCheckResult?: DuplicateCheckResult;
  parentRecruitmentId?: string;
  publishedContentId?: string;
  errorMessage?: string;
  reviewedBy?: string;
  reviewedAt?: string;
  retryCount?: number;
}

export type AutomationEventType =
  | 'source_checked'
  | 'items_discovered'
  | 'item_fetched'
  | 'ai_processed'
  | 'validation_failed'
  | 'duplicate_detected'
  | 'approved'
  | 'published'
  | 'failed'
  | 'blocked';

export type LogSeverity = 'info' | 'warning' | 'error' | 'success';

export interface AutomationLog {
  id: string;
  sourceId?: string;
  sourceName?: string;
  itemId?: string;
  itemTitle?: string;
  eventType: AutomationEventType;
  severity: LogSeverity;
  message: string;
  details?: Record<string, any>;
  timestamp: string;
}

export interface GeminiSettings {
  geminiEnabled: boolean;
  geminiApiKey: string; // Server/admin stored
  geminiModel: string; // 'gemini-1.5-flash' | 'gemini-2.5-flash' | 'gemini-1.5-pro'
  temperature: number; // 0.0 - 0.5 (low temperature for strict factual accuracy)
  confidenceThreshold: number; // 0.50 - 0.99
  autoPublishDefault: boolean; // default false
  maxDailyExtractions?: number;
}
