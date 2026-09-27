import React, { useState, useEffect, useMemo } from 'react';
import {
  Save,
  Send,
  Eye,
  ArrowLeft,
  AlertTriangle,
  Archive,
  CheckCircle2,
  Calendar,
  Users,
  Award,
  DollarSign,
  Link as LinkIcon,
  HelpCircle,
  BookOpen,
  Globe,
  Bell,
  Check,
  ChevronDown,
  ChevronUp,
  Building,
  Briefcase,
  MapPin,
  Clock,
  Phone,
  Mail,
  MessageSquare,
  Landmark,
  FileCheck,
  CheckSquare,
  Newspaper,
  ChevronRight,
  Megaphone,
  Zap,
  GraduationCap,
  Layers,
  ArrowRight,
  FileText,
  Plus,
  Trash2,
  Copy,
  ExternalLink,
  Shield,
  Sliders,
  CheckCheck,
} from 'lucide-react';
import {
  ContentItem,
  ContentType,
  JobType,
  ContentStatus,
  StatusOverride,
  Category,
  ImportantDateItem,
  VacancyItem,
  AgeLimitItem,
  ApplicationFeeItem,
  SelectionStepItem,
  ExamPatternItem,
  ImportantLinkItem,
  FAQItem,
  JobTypeItem,
  PostItem,
  VacancyBreakup,
  DocumentItem,
  UploadRequirements,
  ExamDetails,
  SyllabusTopicItem,
  SelectionRules,
  SourceVerification,
  AppDisplayControls,
} from '../types';
import { fetchJobTypes } from '../services/jobTypeService';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';
import { AdminButton } from '../components/common/AdminButton';
import { AdminCard } from '../components/common/AdminCard';
import { AdminCategorySelector } from '../components/common/AdminCategorySelector';
import { PostVacancyBuilder, calculateVacancyTotal } from '../components/editor/PostVacancyBuilder';
import { ParentRecruitmentSelector } from '../components/editor/ParentRecruitmentSelector';
import { MobilePreviewModal } from '../components/preview/MobilePreviewModal';
import { AdminModal } from '../components/common/AdminModal';

export type JobEditorTabId =
  | 'basic'
  | 'categories_visibility'
  | 'posts_vacancies'
  | 'eligibility'
  | 'age_limit'
  | 'important_dates'
  | 'application_fee'
  | 'salary_pay'
  | 'application_process'
  | 'documents'
  | 'exam_details'
  | 'exam_pattern'
  | 'syllabus'
  | 'selection_process'
  | 'important_links'
  | 'faq'
  | 'source_verification'
  | 'publishing_display';

export type NonJobTabId =
  | 'basic'
  | 'categories_visibility'
  | 'type_specific'
  | 'important_links'
  | 'source_verification'
  | 'publishing_display';

export type EditorTabId = JobEditorTabId | NonJobTabId;

interface ContentEditorPageProps {
  initialItem?: ContentItem | null;
  presetType?: ContentType;
  categories: Category[];
  userEmail: string;
  onSave: (item: Partial<ContentItem>, sendPush: boolean, pushTopic: string) => Promise<void>;
  onCancel: () => void;
}

export const ContentEditorPage: React.FC<ContentEditorPageProps> = ({
  initialItem,
  presetType,
  categories,
  userEmail,
  onSave,
  onCancel,
}) => {
  const isEditing = Boolean(initialItem?.id);
  const [showTypeSelector, setShowTypeSelector] = useState(!isEditing && !presetType);

  // Content & Type
  const [contentType, setContentType] = useState<ContentType>(
    initialItem?.contentType || presetType || 'government_job'
  );
  const isJobType =
    contentType === 'government_job' ||
    contentType === 'andaman_job' ||
    contentType === 'private_job';

  // Active Tab State
  const [activeTab, setActiveTab] = useState<EditorTabId>('basic');

  // Dynamic Job Types from Firestore
  const [availableJobTypes, setAvailableJobTypes] = useState<JobTypeItem[]>([]);
  const [selectedJobTypeId, setSelectedJobTypeId] = useState<string>(
    initialItem?.jobTypeId || (initialItem?.jobType as string) || 'government'
  );
  const [selectedJobTypeName, setSelectedJobTypeName] = useState<string>(
    initialItem?.jobTypeName || ''
  );

  useEffect(() => {
    fetchJobTypes().then((types) => {
      setAvailableJobTypes(types);
      if (!selectedJobTypeName && types.length > 0) {
        const found = types.find((t) => t.slug === selectedJobTypeId || t.id === selectedJobTypeId);
        if (found) setSelectedJobTypeName(found.shortName || found.name);
      }
    });
  }, [selectedJobTypeId, selectedJobTypeName]);

  // 1. Basic Information State
  const [title, setTitle] = useState(initialItem?.title || '');
  const [organization, setOrganization] = useState(initialItem?.organization || '');
  const [department, setDepartment] = useState(initialItem?.department || '');
  const [notificationNumber, setNotificationNumber] = useState(
    initialItem?.notificationNumber || ''
  );
  const [advtNumber, setAdvtNumber] = useState(initialItem?.advtNumber || '');
  const [recruitmentYear, setRecruitmentYear] = useState(
    initialItem?.recruitmentYear || String(new Date().getFullYear())
  );
  const [location, setLocation] = useState(initialItem?.location || 'All India');
  const [employmentType, setEmploymentType] = useState(
    initialItem?.employmentType || 'Regular / Permanent'
  );
  const [recruitmentType, setRecruitmentType] = useState(
    initialItem?.recruitmentType || 'Direct Recruitment'
  );
  const [excerpt, setExcerpt] = useState(initialItem?.excerpt || '');
  const [featuredImageUrl, setFeaturedImageUrl] = useState(initialItem?.featuredImageUrl || '');
  const [officialLanguage, setOfficialLanguage] = useState(
    initialItem?.officialLanguage || 'English & Hindi'
  );
  const [tagsText, setTagsText] = useState(initialItem?.tags?.join(', ') || '');
  const [searchKeywordsText, setSearchKeywordsText] = useState(
    initialItem?.searchKeywords?.join(', ') || ''
  );
  const [slug, setSlug] = useState(initialItem?.slug || '');
  const [isSlugManual, setIsSlugManual] = useState(Boolean(initialItem?.slug));

  // Andaman Job Segment: Govt vs Private
  const [andamanSubtype, setAndamanSubtype] = useState<'govt' | 'private'>(
    initialItem?.jobType === 'private' ? 'private' : 'govt'
  );

  // Auto-generate slug from title if not manual
  useEffect(() => {
    if (!isSlugManual && title) {
      const generated = title
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)+/g, '');
      setSlug(generated);
    }
  }, [title, isSlugManual]);

  // 2. Categories & Visibility Controls (Part 4, 5, 6, 33)
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<string[]>(
    initialItem?.categoryIds && initialItem.categoryIds.length > 0
      ? initialItem.categoryIds
      : ['latest-jobs']
  );
  const [selectedCategoryNames, setSelectedCategoryNames] = useState<string[]>(
    initialItem?.categoryNames || []
  );

  // Content Visibility Controls
  const [showInUserApp, setShowInUserApp] = useState<boolean>(
    initialItem?.showInUserApp ?? true
  );
  const [showOnHome, setShowOnHome] = useState<boolean>(initialItem?.showOnHome ?? true);
  const [featured, setFeatured] = useState<boolean>(initialItem?.featured ?? false);
  const [urgent, setUrgent] = useState<boolean>(initialItem?.urgent ?? false);
  const [showInLatestJobs, setShowInLatestJobs] = useState<boolean>(
    initialItem?.showInLatestJobs ?? true
  );
  const [showInAndamanSection, setShowInAndamanSection] = useState<boolean>(
    initialItem?.showInAndamanSection ?? (contentType === 'andaman_job')
  );
  const [showInClosingSoon, setShowInClosingSoon] = useState<boolean>(
    initialItem?.showInClosingSoon ?? true
  );
  const [showInSearch, setShowInSearch] = useState<boolean>(initialItem?.showInSearch ?? true);
  const [allowNotifications, setAllowNotifications] = useState<boolean>(
    initialItem?.allowNotifications ?? true
  );

  // 3. Posts & Vacancies State (Part 7, 8, 9, 10, 40)
  const [vacancyMode, setVacancyMode] = useState<'simple' | 'detailed'>(
    initialItem?.vacancyMode ||
      (initialItem?.posts && initialItem.posts.length > 0 ? 'detailed' : 'detailed')
  );
  const [posts, setPosts] = useState<PostItem[]>(initialItem?.posts || []);
  const [simpleTotalVacancies, setSimpleTotalVacancies] = useState<string | number>(
    initialItem?.totalVacancies ?? initialItem?.vacancies ?? ''
  );
  const [simpleBreakup, setSimpleBreakup] = useState<VacancyBreakup>({
    ur: 0,
    obc: 0,
    ews: 0,
    sc: 0,
    st: 0,
    pwbd: 0,
    esm: 0,
    msp: 0,
    other: 0,
    total: 0,
  });

  // Calculate detailed total
  const overallTotalDetailed = posts.reduce(
    (sum, p) => sum + (p.vacancies?.total ?? calculateVacancyTotal(p.vacancies)),
    0
  );

  // 4. Eligibility State (Part 11, 12)
  const [minimumQualification, setMinimumQualification] = useState(
    initialItem?.minimumQualification || initialItem?.qualification || ''
  );
  const [eligibilitySummary, setEligibilitySummary] = useState(
    initialItem?.eligibilitySummary || initialItem?.qualificationDetails || ''
  );
  const [experienceRequired, setExperienceRequired] = useState(
    initialItem?.experienceRequired || initialItem?.experience || ''
  );
  const [nationality, setNationality] = useState(
    initialItem?.nationality || 'Citizen of India'
  );
  const [registrationRequirement, setRegistrationRequirement] = useState(
    initialItem?.registrationRequirement || ''
  );
  const [otherEligibility, setOtherEligibility] = useState(
    initialItem?.otherEligibility || ''
  );

  // 5. Age Limit & Relaxation State (Part 13, 14)
  const [ageAsOn, setAgeAsOn] = useState(initialItem?.ageAsOn || '');
  const [defaultMinimumAge, setDefaultMinimumAge] = useState<string | number>(
    initialItem?.defaultMinimumAge || '18'
  );
  const [defaultMaximumAge, setDefaultMaximumAge] = useState<string | number>(
    initialItem?.defaultMaximumAge || '30'
  );
  const [ageRelaxations, setAgeRelaxations] = useState<AgeLimitItem[]>(
    initialItem?.ageRelaxations && initialItem.ageRelaxations.length > 0
      ? initialItem.ageRelaxations
      : [
          { id: '1', category: 'General / UR', relaxationYears: '0 Years', notes: 'No relaxation' },
          { id: '2', category: 'OBC', relaxationYears: '3 Years', notes: 'As per Govt rules' },
          { id: '3', category: 'SC / ST', relaxationYears: '5 Years', notes: 'As per Govt rules' },
          { id: '4', category: 'PwBD', relaxationYears: '10 Years', notes: 'Benchmark disabilities' },
          { id: '5', category: 'Ex-Servicemen', relaxationYears: 'As per Rules', notes: 'Military service deduction' },
        ]
  );

  // 6. Important Dates State (Part 15, 16)
  const [notificationDate, setNotificationDate] = useState(
    initialItem?.publishedAt?.split('T')[0] || ''
  );
  const [applicationStartDate, setApplicationStartDate] = useState(
    initialItem?.applicationStartDate || ''
  );
  const [applicationLastDate, setApplicationLastDate] = useState(
    initialItem?.applicationLastDate || ''
  );
  const [feePaymentLastDate, setFeePaymentLastDate] = useState(
    initialItem?.feePaymentLastDate || ''
  );
  const [correctionStartDate, setCorrectionStartDate] = useState(
    initialItem?.correctionStartDate || ''
  );
  const [correctionEndDate, setCorrectionEndDate] = useState(
    initialItem?.correctionEndDate || ''
  );
  const [examDate, setExamDate] = useState(initialItem?.examDate || '');
  const [admitCardReleaseDate, setAdmitCardReleaseDate] = useState(
    initialItem?.admitCardReleaseDate || ''
  );
  const [resultDate, setResultDate] = useState(initialItem?.resultDate || '');
  const [customMilestones, setCustomMilestones] = useState<ImportantDateItem[]>(
    initialItem?.importantDates || []
  );

  // 7. Application Fee State (Part 17)
  const [applicationFees, setApplicationFees] = useState<ApplicationFeeItem[]>(
    initialItem?.applicationFees && initialItem.applicationFees.length > 0
      ? initialItem.applicationFees
      : [
          { id: '1', category: 'General / OBC / EWS', fee: '100', currency: '₹', notes: 'Online' },
          { id: '2', category: 'SC / ST / PwBD / Female', fee: '0', currency: '₹', notes: 'Exempted' },
        ]
  );
  const [paymentMethods, setPaymentMethods] = useState<string[]>(
    initialItem?.applicationFees?.[0]?.paymentMode
      ? [initialItem.applicationFees[0].paymentMode]
      : ['Debit Card', 'Credit Card', 'UPI', 'Net Banking']
  );

  // 8. Salary & Pay Level State (Part 18)
  const [payLevel, setPayLevel] = useState(initialItem?.payLevel || 'Level 6');
  const [payScale, setPayScale] = useState(initialItem?.payScale || '');
  const [salaryMin, setSalaryMin] = useState<number | string>(initialItem?.salaryMin || '');
  const [salaryMax, setSalaryMax] = useState<number | string>(initialItem?.salaryMax || '');
  const [salaryText, setSalaryText] = useState(
    initialItem?.salaryText || initialItem?.salary || ''
  );

  // 9. Application Process State (Part 19)
  const [applicationMode, setApplicationMode] = useState(
    initialItem?.applicationMode || 'Online via Portal'
  );
  const [registrationRequired, setRegistrationRequired] = useState(
    initialItem?.registrationRequired ?? true
  );
  const [oneTimeRegistration, setOneTimeRegistration] = useState(
    initialItem?.oneTimeRegistration ?? false
  );
  const [applicationInstructions, setApplicationInstructions] = useState(
    initialItem?.applicationInstructions || ''
  );
  const [howToApplySteps, setHowToApplySteps] = useState<string[]>(
    initialItem?.howToApplySteps && initialItem.howToApplySteps.length > 0
      ? initialItem.howToApplySteps
      : [
          'Visit the official recruitment portal.',
          'Complete candidate registration with a valid email and mobile number.',
          'Fill in personal, educational, and communication details.',
          'Upload required documents, signature, and photograph in specified format.',
          'Pay the required application fee online (if applicable).',
          'Submit the application and print the confirmation page for reference.',
        ]
  );

  // 10. Documents Required State (Part 20, 21)
  const [documents, setDocuments] = useState<DocumentItem[]>(
    initialItem?.documents && initialItem.documents.length > 0
      ? initialItem.documents
      : [
          { id: '1', documentName: 'Recent Passport Size Photograph', required: true, notes: 'White background' },
          { id: '2', documentName: 'Scanned Signature', required: true, notes: 'Black ink' },
          { id: '3', documentName: '10th / Matriculation Certificate', required: true, notes: 'For Date of Birth proof' },
          { id: '4', documentName: 'Educational Degree / Diploma Certificate', required: true, notes: 'Self-attested' },
          { id: '5', documentName: 'Category / Caste Certificate (if applicable)', required: false, notes: 'OBC / EWS / SC / ST' },
        ]
  );
  const [uploadRequirements, setUploadRequirements] = useState<UploadRequirements>(
    initialItem?.uploadRequirements || {
      photographFormat: 'JPEG / JPG',
      photographMaxSize: '50 KB',
      signatureFormat: 'JPEG / JPG',
      signatureMaxSize: '20 KB',
      certificateFormat: 'PDF',
      certificateMaxSize: '300 KB',
    }
  );

  // 11. Exam Details State (Part 22)
  const [examDetails, setExamDetails] = useState<ExamDetails>(
    initialItem?.examDetails || {
      hasExam: true,
      examMode: 'Computer Based Test (CBT)',
      examType: 'Objective Multiple Choice Questions (MCQ)',
      examCentre: 'Port Blair / South Andaman',
      examLanguage: 'English & Hindi',
      examDuration: '120 Minutes (2 Hours)',
      negativeMarking: '0.25 mark per incorrect answer',
      minimumQualifyingMarks: 'UR: 40%, OBC: 35%, SC/ST: 30%',
      admitCardMethod: 'Online download via official portal',
    }
  );

  // 12. Exam Pattern State (Part 23)
  const [examPattern, setExamPattern] = useState<ExamPatternItem[]>(
    initialItem?.examPattern && initialItem.examPattern.length > 0
      ? initialItem.examPattern
      : [
          {
            id: '1',
            paperName: 'Paper I',
            subject: 'General Intelligence & Reasoning',
            questions: 25,
            marks: 50,
            duration: '60 Mins',
            negativeMarking: '0.50',
          },
          {
            id: '2',
            paperName: 'Paper I',
            subject: 'General Awareness',
            questions: 25,
            marks: 50,
            duration: '60 Mins',
            negativeMarking: '0.50',
          },
          {
            id: '3',
            paperName: 'Paper I',
            subject: 'Quantitative Aptitude',
            questions: 25,
            marks: 50,
            duration: '60 Mins',
            negativeMarking: '0.50',
          },
          {
            id: '4',
            paperName: 'Paper I',
            subject: 'English Comprehension',
            questions: 25,
            marks: 50,
            duration: '60 Mins',
            negativeMarking: '0.50',
          },
        ]
  );

  // 13. Syllabus State (Part 24)
  const [syllabusTopics, setSyllabusTopics] = useState<SyllabusTopicItem[]>(
    initialItem?.syllabusTopics && initialItem.syllabusTopics.length > 0
      ? initialItem.syllabusTopics
      : [
          { id: '1', subject: 'General Awareness', topicName: 'Current Affairs & General Science', details: 'National, international events, and everyday science' },
          { id: '2', subject: 'Reasoning', topicName: 'Analogies, Series & Puzzles', details: 'Verbal and non-verbal reasoning questions' },
        ]
  );
  const [syllabusPdfUrl, setSyllabusPdfUrl] = useState(
    initialItem?.syllabusPdfUrl || initialItem?.syllabusUrl || ''
  );

  // 14. Selection Process State (Part 25, 26, 27)
  const [selectionProcess, setSelectionProcess] = useState<SelectionStepItem[]>(
    initialItem?.selectionProcess && initialItem.selectionProcess.length > 0
      ? initialItem.selectionProcess
      : [
          { id: '1', stageNumber: 1, name: 'Written Examination (CBT)', description: 'Merit basis qualifying stage', mandatory: true },
          { id: '2', stageNumber: 2, name: 'Document Verification', description: 'Original certificates checking', mandatory: true },
          { id: '3', stageNumber: 3, name: 'Medical Fitness Examination', description: 'Standard UT medical board assessment', mandatory: true },
        ]
  );
  const [selectionRules, setSelectionRules] = useState<SelectionRules>(
    initialItem?.selectionRules || {
      selectionBasis: 'Total score in Written Examination (CBT)',
      meritCalculation: 'Normalized score based on multi-shift examination formula',
      qualifyingCriteria: 'Minimum cut-off score as per reservation category',
      documentVerificationRule: '1:3 ratio based on merit list order',
      waitingListRule: 'Valid for 1 year from the date of final publication',
      reservationRule: 'As per Andaman & Nicobar Administration reservation policy',
      tieBreakingRules: [
        '1. Candidate older in age gets preference in merit order.',
        '2. Candidate with higher educational marks gets preference.',
        '3. Alphabetical order of candidate first name as per 10th certificate.',
      ],
    }
  );

  // 15. Important Links State (Part 28)
  const [applyUrl, setApplyUrl] = useState(initialItem?.applyUrl || '');
  const [officialNotificationUrl, setOfficialNotificationUrl] = useState(
    initialItem?.officialNotificationUrl || ''
  );
  const [officialWebsiteUrl, setOfficialWebsiteUrl] = useState(
    initialItem?.officialWebsiteUrl || ''
  );
  const [pressNoteUrl, setPressNoteUrl] = useState(initialItem?.pressNoteUrl || '');
  const [admitCardUrl, setAdmitCardUrl] = useState(initialItem?.admitCardUrl || '');
  const [resultUrl, setResultUrl] = useState(initialItem?.resultUrl || '');
  const [importantLinks, setImportantLinks] = useState<ImportantLinkItem[]>(
    initialItem?.importantLinks || []
  );

  // 16. FAQ State
  const [faqs, setFaqs] = useState<FAQItem[]>(
    initialItem?.faqs && initialItem.faqs.length > 0
      ? initialItem.faqs
      : [
          {
            id: '1',
            question: 'What is the last date to apply online?',
            answer: 'Please check the Important Dates section above for the official deadline.',
          },
          {
            id: '2',
            question: 'Is there any application fee exemption?',
            answer: 'Female, SC, ST, and PwBD candidates are exempted from the application fee.',
          },
        ]
  );

  // 17. Source Verification State (Part 29)
  const [sourceOrg, setSourceOrg] = useState(
    initialItem?.sourceOrg || initialItem?.organization || ''
  );
  const [gazetteNumber, setGazetteNumber] = useState(initialItem?.sourceVerification?.gazetteNumber || '');
  const [circularNumber, setCircularNumber] = useState(initialItem?.sourceVerification?.circularNumber || '');
  const [sourceWebsiteUrl, setSourceWebsiteUrl] = useState(
    initialItem?.sourceVerification?.sourceWebsiteUrl || initialItem?.sourceUrl || ''
  );
  const [sourcePdfUrl, setSourcePdfUrl] = useState(
    initialItem?.sourceVerification?.sourcePdfUrl || ''
  );
  const [sourcePublishedDate, setSourcePublishedDate] = useState(
    initialItem?.sourceVerification?.sourcePublishedDate || ''
  );
  const [sourceVerified, setSourceVerified] = useState(
    initialItem?.sourceVerification?.sourceVerified ?? true
  );

  // 18. Publishing & App Display Controls (Part 31, 32, 38, 39)
  const [status, setStatus] = useState<ContentStatus>(initialItem?.status || 'published');
  const [statusOverride, setStatusOverride] = useState<StatusOverride>(
    initialItem?.statusOverride || 'auto'
  );
  const [appDisplayControls, setAppDisplayControls] = useState<AppDisplayControls>(
    initialItem?.appDisplayControls || {
      showOverview: true,
      showImportantDates: true,
      showPosts: true,
      showVacancies: true,
      showQualification: true,
      showAgeLimit: true,
      showFees: true,
      showSalary: true,
      showApplicationProcess: true,
      showDocuments: true,
      showExamDetails: true,
      showExamPattern: true,
      showSyllabus: true,
      showSelectionProcess: true,
      showImportantLinks: true,
      showFAQ: true,
      showSourceInformation: true,
      showDisclaimer: true,
    }
  );
  const [body, setBody] = useState(initialItem?.body || '');
  const [parentRecruitmentId, setParentRecruitmentId] = useState(
    initialItem?.parentRecruitmentId || ''
  );
  const [parentRecruitmentTitle, setParentRecruitmentTitle] = useState(
    initialItem?.parentRecruitmentTitle || ''
  );

  // UI States
  const [saving, setSaving] = useState(false);
  const [publishModalOpen, setPublishModalOpen] = useState(false);
  const [previewOpen, setPreviewOpen] = useState(false);
  const [sendPush, setSendPush] = useState(false);
  const [pushTopic, setPushTopic] = useState('all');
  const [lastAutosavedAt, setLastAutosavedAt] = useState<string | null>(null);

  // AUTOSAVE DRAFT TO LOCALSTORAGE (Correction 7)
  const draftKey = `notifyjobs_editor_draft_${initialItem?.id || 'new'}`;
  useEffect(() => {
    const timer = setTimeout(() => {
      if (title || organization) {
        try {
          const draftPayload = {
            title,
            organization,
            department,
            contentType,
            posts,
            applicationStartDate,
            applicationLastDate,
            savedAt: new Date().toISOString(),
          };
          localStorage.setItem(draftKey, JSON.stringify(draftPayload));
          setLastAutosavedAt(new Date().toLocaleTimeString());
        } catch (_) {}
      }
    }, 2500);
    return () => clearTimeout(timer);
  }, [title, organization, department, posts, applicationStartDate, applicationLastDate, draftKey]);

  // DATE & VACANCY VALIDATION (Corrections 8 & 9)
  const validationIssues = useMemo(() => {
    const errors: string[] = [];
    const warnings: string[] = [];

    if (!title.trim()) errors.push('Recruitment title is required.');
    if (!organization.trim()) errors.push('Organization/Board name is required.');
    if (selectedCategoryIds.length === 0) errors.push('At least one category must be selected.');

    // Date chronology checks
    if (applicationStartDate && applicationLastDate) {
      const start = new Date(applicationStartDate);
      const last = new Date(applicationLastDate);
      if (last < start) {
        errors.push('Application Last Date cannot precede Start Date.');
      }
    }

    if (correctionStartDate && correctionEndDate) {
      const cStart = new Date(correctionStartDate);
      const cEnd = new Date(correctionEndDate);
      if (cEnd < cStart) {
        errors.push('Correction Window End Date cannot precede Correction Start Date.');
      }
    }

    if (applicationLastDate && examDate) {
      const last = new Date(applicationLastDate);
      const exam = new Date(examDate);
      if (exam < last) {
        warnings.push('Exam Date is scheduled before Application Last Date.');
      }
    }

    // Vacancy checks
    if (isJobType) {
      if (vacancyMode === 'detailed') {
        if (posts.length === 0) {
          errors.push('At least one post must be added in detailed mode.');
        } else if (overallTotalDetailed <= 0) {
          warnings.push('Overall total vacancies sum to 0.');
        }
      } else {
        if (!simpleTotalVacancies || Number(simpleTotalVacancies) <= 0) {
          warnings.push('Total vacancies is 0 or unassigned.');
        }
      }
    }

    // Links check
    if (!officialNotificationUrl && !applyUrl && !officialWebsiteUrl) {
      warnings.push('No official URL has been provided.');
    }

    return { errors, warnings, isValid: errors.length === 0 };
  }, [
    title,
    organization,
    selectedCategoryIds,
    applicationStartDate,
    applicationLastDate,
    correctionStartDate,
    correctionEndDate,
    examDate,
    isJobType,
    vacancyMode,
    posts.length,
    overallTotalDetailed,
    simpleTotalVacancies,
    officialNotificationUrl,
    applyUrl,
    officialWebsiteUrl,
  ]);

  // COMPLETENESS SCORE (Part 37)
  const completenessScore = useMemo(() => {
    let score = 0;
    if (title.trim()) score += 10;
    if (organization.trim()) score += 10;
    if (selectedCategoryIds.length > 0) score += 10;
    if (isJobType) {
      if (posts.length > 0 && overallTotalDetailed > 0) score += 15;
      else if (simpleTotalVacancies) score += 10;
    } else {
      score += 15;
    }
    if (applicationStartDate || applicationLastDate) score += 10;
    if (minimumQualification.trim()) score += 10;
    if (defaultMinimumAge || defaultMaximumAge) score += 10;
    if (applicationFees.length > 0) score += 5;
    if (examPattern.length > 0 || examDetails.hasExam) score += 10;
    if (applyUrl || officialNotificationUrl || officialWebsiteUrl) score += 10;
    return Math.min(100, score);
  }, [
    title,
    organization,
    selectedCategoryIds,
    isJobType,
    posts,
    overallTotalDetailed,
    simpleTotalVacancies,
    applicationStartDate,
    applicationLastDate,
    minimumQualification,
    defaultMinimumAge,
    defaultMaximumAge,
    applicationFees,
    examPattern,
    examDetails,
    applyUrl,
    officialNotificationUrl,
    officialWebsiteUrl,
  ]);

  // CLONE RECRUITMENT FEATURE (Correction 11)
  const handleCloneRecruitment = () => {
    setTitle((prev) => `${prev} (Copy)`);
    setSlug((prev) => `${prev}-copy`);
    setIsSlugManual(true);
    setStatus('draft');
    alert('Recruitment cloned into editor! You can modify details and save as a new post.');
  };

  // CONSTRUCT COMPLETE PAYLOAD
  const constructPayload = (overrideStatus?: ContentStatus): Partial<ContentItem> => {
    const finalStatus = overrideStatus || status;
    const isNowPublished = finalStatus === 'published';
    const computedTotal =
      vacancyMode === 'detailed' ? overallTotalDetailed : simpleTotalVacancies || '';

    return {
      title: title.trim(),
      slug: slug.trim(),
      excerpt: excerpt.trim(),
      body: body.trim(),
      contentType,
      jobType: contentType === 'andaman_job' && andamanSubtype === 'private' ? 'private' : 'government',
      organization: organization.trim(),
      department: department.trim(),
      jobRole: posts.length > 0 ? posts[0].postName : title,
      vacancies: String(computedTotal),
      totalVacancies: computedTotal,
      vacancyMode,
      posts,
      qualification: minimumQualification.trim(),
      qualificationDetails: eligibilitySummary.trim(),
      minimumQualification: minimumQualification.trim(),
      eligibilitySummary: eligibilitySummary.trim(),
      experienceRequired: experienceRequired.trim(),
      nationality: nationality.trim(),
      registrationRequirement: registrationRequirement.trim(),
      otherEligibility: otherEligibility.trim(),
      salary: salaryText.trim(),
      salaryText: salaryText.trim(),
      payLevel: payLevel.trim(),
      payScale: payScale.trim(),
      salaryMin: salaryMin ? Number(salaryMin) : undefined,
      salaryMax: salaryMax ? Number(salaryMax) : undefined,
      location: location.trim(),
      featuredImageUrl: featuredImageUrl.trim(),

      // Classification & Metadata
      categoryIds: selectedCategoryIds,
      categoryNames: selectedCategoryNames,
      recruitmentYear,
      notificationNumber,
      advtNumber,
      recruitmentType,
      officialLanguage,

      // Visibility & App Placement Controls (Part 6, 31, 33)
      showInUserApp,
      showOnHome,
      featured,
      urgent,
      showInLatestJobs,
      showInAndamanSection,
      showInClosingSoon,
      showInSearch,
      allowNotifications,
      appDisplayControls,

      // Age rules
      ageAsOn,
      defaultMinimumAge,
      defaultMaximumAge,
      ageLimits: ageRelaxations,
      ageRelaxations,

      // Dates
      applicationStartDate,
      applicationLastDate,
      feePaymentLastDate,
      correctionStartDate,
      correctionEndDate,
      examDate,
      admitCardReleaseDate,
      resultDate,
      importantDates: customMilestones,

      // Fees
      applicationFees,

      // Application
      applicationMode,
      registrationRequired,
      oneTimeRegistration,
      applicationInstructions,
      howToApplySteps,

      // Documents
      documents,
      uploadRequirements,

      // Exam & Syllabus
      examDetails,
      examPattern,
      syllabusTopics,
      syllabusPdfUrl,

      // Selection
      selectionProcess,
      selectionRules,
      tieBreakingRules: selectionRules.tieBreakingRules,

      // Links
      applyUrl: applyUrl.trim(),
      officialNotificationUrl: officialNotificationUrl.trim(),
      officialWebsiteUrl: officialWebsiteUrl.trim(),
      pressNoteUrl: pressNoteUrl.trim(),
      admitCardUrl: admitCardUrl.trim(),
      resultUrl: resultUrl.trim(),
      importantLinks: importantLinks.filter((l) => l.url.trim().length > 0),

      // FAQs
      faqs: faqs.filter((f) => f.question.trim().length > 0),

      // Source verification
      sourceOrg: sourceOrg || organization,
      sourceVerification: {
        sourceOrg,
        notificationNumber,
        gazetteNumber,
        circularNumber,
        sourcePdfUrl,
        sourceWebsiteUrl,
        sourcePublishedDate,
        sourceVerified,
      },

      // Parent link
      parentRecruitmentId: parentRecruitmentId.trim() || undefined,
      parentRecruitmentTitle: parentRecruitmentTitle.trim() || undefined,

      // Publishing state
      status: finalStatus,
      statusOverride,
      isPublished: isNowPublished,
      publishedAt: isNowPublished
        ? initialItem?.publishedAt || new Date().toISOString()
        : initialItem?.publishedAt,
      updatedAt: new Date().toISOString(),
      updatedBy: userEmail,
      tags: tagsText.split(',').map((t) => t.trim()).filter(Boolean),
      searchKeywords: searchKeywordsText.split(',').map((k) => k.trim()).filter(Boolean),
    };
  };

  const handleSaveDraft = async () => {
    if (saving) return;
    setSaving(true);
    try {
      await onSave(constructPayload('draft'), false, '');
      localStorage.removeItem(draftKey);
    } finally {
      setSaving(false);
    }
  };

  const handleConfirmPublish = async () => {
    if (saving) return;
    if (!validationIssues.isValid) {
      alert(`Please fix errors before publishing:\n${validationIssues.errors.join('\n')}`);
      return;
    }
    setSaving(true);
    try {
      await onSave(constructPayload('published'), sendPush, pushTopic);
      localStorage.removeItem(draftKey);
      setPublishModalOpen(false);
    } finally {
      setSaving(false);
    }
  };

  // JOB 18 TABS DEFINITION
  const JOB_TABS: { id: JobEditorTabId; label: string; number: number }[] = [
    { id: 'basic', label: 'Basic Info', number: 1 },
    { id: 'categories_visibility', label: 'Categories & Visibility', number: 2 },
    { id: 'posts_vacancies', label: 'Posts & Vacancies', number: 3 },
    { id: 'eligibility', label: 'Eligibility', number: 4 },
    { id: 'age_limit', label: 'Age Limit', number: 5 },
    { id: 'important_dates', label: 'Important Dates', number: 6 },
    { id: 'application_fee', label: 'Application Fee', number: 7 },
    { id: 'salary_pay', label: 'Salary & Pay', number: 8 },
    { id: 'application_process', label: 'How to Apply', number: 9 },
    { id: 'documents', label: 'Documents', number: 10 },
    { id: 'exam_details', label: 'Exam Details', number: 11 },
    { id: 'exam_pattern', label: 'Exam Pattern', number: 12 },
    { id: 'syllabus', label: 'Syllabus', number: 13 },
    { id: 'selection_process', label: 'Selection Process', number: 14 },
    { id: 'important_links', label: 'Official Links', number: 15 },
    { id: 'faq', label: 'FAQ', number: 16 },
    { id: 'source_verification', label: 'Source Verification', number: 17 },
    { id: 'publishing_display', label: 'Publishing & Display', number: 18 },
  ];

  // NON-JOB TYPE TABS DEFINITION (Correction 2)
  const NON_JOB_TABS: { id: NonJobTabId; label: string; number: number }[] = [
    { id: 'basic', label: 'Basic Info', number: 1 },
    { id: 'categories_visibility', label: 'Categories & Visibility', number: 2 },
    { id: 'type_specific', label: `${contentType.replace('_', ' ').toUpperCase()} Details`, number: 3 },
    { id: 'important_links', label: 'Official Links', number: 4 },
    { id: 'source_verification', label: 'Source Verification', number: 5 },
    { id: 'publishing_display', label: 'Publishing & Display', number: 6 },
  ];

  const currentTabs = isJobType ? JOB_TABS : NON_JOB_TABS;

  return (
    <div className="space-y-6 pb-28">
      {/* Top Header & Global Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-200">
        <div className="flex items-center gap-3">
          <button
            onClick={onCancel}
            className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2.5">
              <h2 className="text-xl font-bold text-slate-900">
                {isEditing ? 'Edit Recruitment' : 'One-Stop Recruitment Editor'}
              </h2>
              <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-emerald-50 text-[#159B76] border border-emerald-200">
                {contentType.replace('_', ' ').toUpperCase()}
              </span>
              {lastAutosavedAt && (
                <span className="text-[10px] text-slate-400 font-medium hidden sm:inline">
                  Autosaved {lastAutosavedAt}
                </span>
              )}
            </div>
            <p className="text-xs text-slate-500 mt-0.5">
              Enterprise structured recruitment authoring • Real-time auto totals & Flutter contract compliance
            </p>
          </div>
        </div>

        {/* Global Save / Preview Actions */}
        <div className="flex items-center gap-2">
          {isEditing && (
            <AdminButton
              type="button"
              variant="outline"
              size="sm"
              icon={<Copy className="w-4 h-4 text-indigo-600" />}
              onClick={handleCloneRecruitment}
              title="Duplicate this recruitment as a new draft"
            >
              Clone Post
            </AdminButton>
          )}
          <AdminButton
            type="button"
            variant="outline"
            size="sm"
            icon={<Eye className="w-4 h-4 text-slate-600" />}
            onClick={() => setPreviewOpen(true)}
          >
            Mobile Preview
          </AdminButton>
          <AdminButton
            type="button"
            variant="secondary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
            disabled={saving}
            onClick={handleSaveDraft}
          >
            Save Draft
          </AdminButton>
          <AdminButton
            type="button"
            variant="primary"
            size="sm"
            icon={<Send className="w-4 h-4" />}
            loading={saving}
            disabled={saving}
            onClick={() => setPublishModalOpen(true)}
          >
            {isEditing ? 'Update Post' : 'Publish Post'}
          </AdminButton>
        </div>
      </div>

      {/* Completeness Bar & Warnings Alert */}
      <div className="p-3.5 bg-white rounded-2xl border border-slate-200 shadow-2xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-emerald-50 text-[#159B76] font-black text-xs flex items-center justify-center border border-emerald-200">
            {completenessScore}%
          </div>
          <div>
            <div className="text-xs font-bold text-slate-900">
              Recruitment Completeness Score: {completenessScore}%
            </div>
            <div className="text-[11px] text-slate-500">
              {completenessScore >= 80
                ? 'Excellent: All key structured sections are fully populated.'
                : 'Tip: Add missing dates, post breakups, or links to reach full completeness.'}
            </div>
          </div>
        </div>

        {validationIssues.warnings.length > 0 && (
          <div className="flex items-center gap-2 text-xs font-semibold text-amber-700 bg-amber-50 px-3 py-1.5 rounded-xl border border-amber-200">
            <AlertTriangle className="w-4 h-4 shrink-0 text-amber-600" />
            <span className="truncate">{validationIssues.warnings[0]}</span>
          </div>
        )}
      </div>

      {/* STRUCTURED TABS NAVIGATION (Sticky Header) */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-2xs p-1.5 sticky top-2 z-10 overflow-x-auto">
        <div className="flex items-center gap-1 min-w-max">
          {currentTabs.map((tab) => {
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold transition-all ${
                  isActive
                    ? 'bg-[#159B76] text-white shadow-2xs'
                    : 'text-slate-600 hover:bg-slate-100/70 hover:text-slate-900'
                }`}
              >
                <span
                  className={`w-4 h-4 rounded-full flex items-center justify-center text-[10px] font-black ${
                    isActive ? 'bg-white/20 text-white' : 'bg-slate-200 text-slate-700'
                  }`}
                >
                  {tab.number}
                </span>
                <span className="truncate">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* ========================================================================= */}
      {/* TAB 1: BASIC INFORMATION (Part 2, 3) */}
      {/* ========================================================================= */}
      {activeTab === 'basic' && (
        <AdminCard
          title="1. Basic Recruitment Information"
          subtitle="Official title, conducting board, classification, and URL slug"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="sm:col-span-2">
                <AdminInput
                  label="Recruitment / Notification Title *"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g. Directorate of Agriculture Recruitment 2026"
                />
              </div>
              <AdminInput
                label="Recruitment Year"
                value={recruitmentYear}
                onChange={(e) => setRecruitmentYear(e.target.value)}
                placeholder="e.g. 2026"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <AdminInput
                label="Organization / Board Name *"
                required
                value={organization}
                onChange={(e) => setOrganization(e.target.value)}
                placeholder="e.g. Directorate of Agriculture / SSC / UPSC"
              />
              <AdminInput
                label="Department / Ministry (Optional)"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                placeholder="e.g. A&N Administration / Ministry of Agriculture"
              />
              <AdminInput
                label="Job Location"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g. Port Blair / South Andaman / All India"
              />
            </div>

            {/* Andaman Job Subtype Segment (Part 3) */}
            {contentType === 'andaman_job' && (
              <div className="p-3.5 bg-teal-50 border border-teal-200 rounded-xl space-y-2">
                <span className="text-xs font-bold text-teal-900 block">
                  Andaman & Nicobar Vacancy Classification:
                </span>
                <div className="inline-flex rounded-lg border border-teal-300 bg-white p-0.5">
                  <button
                    type="button"
                    onClick={() => setAndamanSubtype('govt')}
                    className={`px-3 py-1 text-xs font-bold rounded-md transition-colors ${
                      andamanSubtype === 'govt'
                        ? 'bg-[#0D9488] text-white shadow-2xs'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    A&N Government Vacancy
                  </button>
                  <button
                    type="button"
                    onClick={() => setAndamanSubtype('private')}
                    className={`px-3 py-1 text-xs font-bold rounded-md transition-colors ${
                      andamanSubtype === 'private'
                        ? 'bg-[#0D9488] text-white shadow-2xs'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    A&N Private Job
                  </button>
                </div>
              </div>
            )}

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <AdminInput
                label="Notification Number"
                value={notificationNumber}
                onChange={(e) => setNotificationNumber(e.target.value)}
                placeholder="e.g. 4-11/Agri/Estt/2026"
              />
              <AdminInput
                label="Advertisement Number"
                value={advtNumber}
                onChange={(e) => setAdvtNumber(e.target.value)}
                placeholder="e.g. Advt. No. 01/2026"
              />
              <AdminSelect
                label="Recruitment Type"
                value={recruitmentType}
                onChange={(e) => setRecruitmentType(e.target.value)}
                options={[
                  { value: 'Direct Recruitment', label: 'Direct Recruitment' },
                  { value: 'Deputation', label: 'Deputation' },
                  { value: 'Contractual', label: 'Contractual' },
                  { value: 'Special Recruitment Drive', label: 'Special Recruitment Drive' },
                  { value: 'Apprenticeship', label: 'Apprenticeship' },
                ]}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Employment Type"
                value={employmentType}
                onChange={(e) => setEmploymentType(e.target.value)}
                placeholder="e.g. Regular / Permanent, Contractual"
              />
              <AdminInput
                label="Official Language"
                value={officialLanguage}
                onChange={(e) => setOfficialLanguage(e.target.value)}
                placeholder="e.g. English & Hindi"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Short Summary / Excerpt *
              </label>
              <textarea
                rows={2}
                value={excerpt}
                onChange={(e) => setExcerpt(e.target.value)}
                placeholder="Brief summary displayed on mobile feed cards..."
                className="w-full text-xs rounded-xl border border-slate-200 bg-white p-3 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Featured Image / Department Logo URL"
                value={featuredImageUrl}
                onChange={(e) => setFeaturedImageUrl(e.target.value)}
                placeholder="https://..."
              />
              <div>
                <AdminInput
                  label="URL Slug (Auto-generated)"
                  value={slug}
                  onChange={(e) => {
                    setSlug(e.target.value);
                    setIsSlugManual(true);
                  }}
                  placeholder="directorate-of-agriculture-recruitment-2026"
                />
                <span className="text-[10px] text-slate-400">
                  {isSlugManual ? 'Manual override active' : 'Auto-generating from title'}
                </span>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Tags (Comma separated)"
                value={tagsText}
                onChange={(e) => setTagsText(e.target.value)}
                placeholder="Andaman Jobs, Agriculture, Group B, Group C"
              />
              <AdminInput
                label="Search Keywords (Comma separated)"
                value={searchKeywordsText}
                onChange={(e) => setSearchKeywordsText(e.target.value)}
                placeholder="agriculture officer, assistant, port blair vacancy"
              />
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 2: CATEGORIES & VISIBILITY (Part 4, 5, 6, 33) */}
      {/* ========================================================================= */}
      {activeTab === 'categories_visibility' && (
        <div className="space-y-4">
          <AdminCard
            title="2. Categories & Remote Visibility Controls"
            subtitle="Categorize this recruitment and control exactly where it appears in user feeds"
          >
            <div className="space-y-5">
              {/* Category Multi-Selector */}
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  Select Applicable Categories *
                </label>
                <AdminCategorySelector
                  categories={categories}
                  selectedCategoryIds={selectedCategoryIds}
                  onChange={(ids, names) => {
                    setSelectedCategoryIds(ids);
                    setSelectedCategoryNames(names);
                  }}
                />
              </div>

              {/* Master Visibility & Home Placement Toggles */}
              <div className="pt-4 border-t border-slate-100 space-y-3">
                <span className="text-xs font-bold text-slate-900 block">
                  Content Visibility & Placement Switches
                </span>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showInUserApp}
                      onChange={(e) => setShowInUserApp(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Show in User App (Master Switch)
                      </span>
                      <span className="text-[11px] text-slate-500">
                        If unchecked, post is completely hidden from mobile feeds and search without deletion.
                      </span>
                    </div>
                  </label>

                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showOnHome}
                      onChange={(e) => setShowOnHome(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Show on Home Screen
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Display this recruitment in Home screen sections.
                      </span>
                    </div>
                  </label>

                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={featured}
                      onChange={(e) => setFeatured(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Featured Opportunity
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Highlight with featured badge on mobile screens.
                      </span>
                    </div>
                  </label>

                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={urgent}
                      onChange={(e) => setUrgent(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Urgent Alert (Home Carousel)
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Force inclusion into Home URGENT UPDATES section.
                      </span>
                    </div>
                  </label>

                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showInLatestJobs}
                      onChange={(e) => setShowInLatestJobs(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Show in Latest Jobs Section
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Include in Home Latest Jobs feed.
                      </span>
                    </div>
                  </label>

                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showInAndamanSection}
                      onChange={(e) => setShowInAndamanSection(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Show in Andaman & Nicobar Section
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Include in Home Island Vacancies feed.
                      </span>
                    </div>
                  </label>

                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showInClosingSoon}
                      onChange={(e) => setShowInClosingSoon(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Eligible for Closing Soon Feed
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Highlight automatically when deadline is within 3 days.
                      </span>
                    </div>
                  </label>

                  <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showInSearch}
                      onChange={(e) => setShowInSearch(e.target.checked)}
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">
                        Search Discoverability
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Allow users to find this post via keyword search.
                      </span>
                    </div>
                  </label>
                </div>
              </div>
            </div>
          </AdminCard>
        </div>
      )}

      {/* ========================================================================= */}
      {/* TAB 3: POSTS & VACANCIES (Part 7, 8, 9, 10, 40, 44) */}
      {/* ========================================================================= */}
      {activeTab === 'posts_vacancies' && (
        <AdminCard
          title="3. Posts & Vacancy Builder"
          subtitle="Detailed post designations, reservation breakdown, and automated totals"
        >
          <PostVacancyBuilder
            mode={vacancyMode}
            onModeChange={setVacancyMode}
            posts={posts}
            onPostsChange={setPosts}
            simpleTotalVacancies={simpleTotalVacancies}
            onSimpleTotalChange={setSimpleTotalVacancies}
            simpleBreakup={simpleBreakup}
            onSimpleBreakupChange={setSimpleBreakup}
            categories={categories}
            defaultDepartment={department || organization}
            defaultLocation={location}
            defaultPayLevel={payLevel}
            defaultQualification={minimumQualification}
            defaultMinAge={defaultMinimumAge}
            defaultMaxAge={defaultMaximumAge}
          />
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 4: ELIGIBILITY & QUALIFICATION (Part 11, 12) */}
      {/* ========================================================================= */}
      {activeTab === 'eligibility' && (
        <AdminCard
          title="4. Eligibility & Educational Qualification"
          subtitle="Recruitment-level qualifications and general eligibility requirements"
        >
          <div className="space-y-4">
            <div className="p-3 bg-blue-50 border border-blue-200 rounded-xl text-xs text-blue-800">
              ℹ️ <strong>Inheritance Note:</strong> If post-level qualifications are specified in the Posts & Vacancies tab, they will take precedence for individual post cards in the app.
            </div>

            <AdminInput
              label="Minimum Educational Qualification *"
              required
              value={minimumQualification}
              onChange={(e) => setMinimumQualification(e.target.value)}
              placeholder="e.g. Bachelor Degree in Agriculture / Engineering / Diploma / 12th Pass"
            />

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Detailed Eligibility Summary
              </label>
              <textarea
                rows={3}
                value={eligibilitySummary}
                onChange={(e) => setEligibilitySummary(e.target.value)}
                placeholder="Comprehensive eligibility requirements, subject disciplines, and minimum percentage criteria..."
                className="w-full text-xs rounded-xl border border-slate-200 bg-white p-3 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Experience Required (if applicable)"
                value={experienceRequired}
                onChange={(e) => setExperienceRequired(e.target.value)}
                placeholder="e.g. 2 Years experience in relevant field or Fresher"
              />
              <AdminInput
                label="Nationality Requirement"
                value={nationality}
                onChange={(e) => setNationality(e.target.value)}
                placeholder="Citizen of India"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Local Registration Requirement (e.g. Employment Exchange)"
                value={registrationRequirement}
                onChange={(e) => setRegistrationRequirement(e.target.value)}
                placeholder="e.g. Registered with A&N Employment Exchange"
              />
              <AdminInput
                label="Other Eligibility Conditions"
                value={otherEligibility}
                onChange={(e) => setOtherEligibility(e.target.value)}
                placeholder="e.g. Valid Driver License, Computer Certificate"
              />
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 5: AGE LIMIT & RELAXATION (Part 13, 14) */}
      {/* ========================================================================= */}
      {activeTab === 'age_limit' && (
        <AdminCard
          title="5. Age Limit & Category Relaxation"
          subtitle="Reference cut-off date, standard minimum/maximum age, and category relaxations"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <AdminInput
                label="Age Calculated As On (Reference Date)"
                value={ageAsOn}
                onChange={(e) => setAgeAsOn(e.target.value)}
                placeholder="e.g. 01 Jan 2026 or Closing Date"
              />
              <AdminInput
                label="Default Minimum Age"
                type="number"
                value={String(defaultMinimumAge)}
                onChange={(e) => setDefaultMinimumAge(e.target.value)}
                placeholder="18"
              />
              <AdminInput
                label="Default Maximum Age"
                type="number"
                value={String(defaultMaximumAge)}
                onChange={(e) => setDefaultMaximumAge(e.target.value)}
                placeholder="30"
              />
            </div>

            {/* Repeatable Age Relaxation Table */}
            <div className="pt-2">
              <span className="block text-xs font-bold text-slate-900 mb-2">
                Category-wise Age Relaxation Rules
              </span>

              <div className="space-y-2.5">
                {ageRelaxations.map((rel, idx) => (
                  <div
                    key={rel.id}
                    className="grid grid-cols-1 sm:grid-cols-12 gap-2 p-2.5 bg-slate-50 border border-slate-200 rounded-xl items-center"
                  >
                    <div className="sm:col-span-4">
                      <input
                        type="text"
                        value={rel.category}
                        onChange={(e) => {
                          const next = [...ageRelaxations];
                          next[idx] = { ...next[idx], category: e.target.value };
                          setAgeRelaxations(next);
                        }}
                        placeholder="Category (e.g. OBC)"
                        className="w-full text-xs font-semibold px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                      />
                    </div>
                    <div className="sm:col-span-3">
                      <input
                        type="text"
                        value={rel.relaxationYears}
                        onChange={(e) => {
                          const next = [...ageRelaxations];
                          next[idx] = { ...next[idx], relaxationYears: e.target.value };
                          setAgeRelaxations(next);
                        }}
                        placeholder="Relaxation (e.g. 3 Years)"
                        className="w-full text-xs font-semibold px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                      />
                    </div>
                    <div className="sm:col-span-4">
                      <input
                        type="text"
                        value={rel.notes || ''}
                        onChange={(e) => {
                          const next = [...ageRelaxations];
                          next[idx] = { ...next[idx], notes: e.target.value };
                          setAgeRelaxations(next);
                        }}
                        placeholder="Notes (e.g. Non-creamy layer only)"
                        className="w-full text-xs px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                      />
                    </div>
                    <div className="sm:col-span-1 flex justify-end">
                      <button
                        type="button"
                        onClick={() =>
                          setAgeRelaxations(ageRelaxations.filter((_, i) => i !== idx))
                        }
                        className="p-1.5 text-rose-500 hover:bg-rose-50 rounded-lg"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))}

                <AdminButton
                  type="button"
                  variant="outline"
                  size="sm"
                  icon={<Plus className="w-4 h-4" />}
                  onClick={() =>
                    setAgeRelaxations([
                      ...ageRelaxations,
                      {
                        id: `age_${Date.now()}`,
                        category: '',
                        relaxationYears: '',
                        notes: '',
                      },
                    ])
                  }
                >
                  Add Age Relaxation Row
                </AdminButton>
              </div>
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 6: IMPORTANT DATES (Part 15, 16) */}
      {/* ========================================================================= */}
      {activeTab === 'important_dates' && (
        <AdminCard
          title="6. Important Dates & Schedule"
          subtitle="Canonical schedule milestones formatted cleanly in the mobile app"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <AdminInput
                label="Notification Published Date"
                type="date"
                value={notificationDate}
                onChange={(e) => setNotificationDate(e.target.value)}
              />
              <AdminInput
                label="Application Start Date"
                type="date"
                value={applicationStartDate}
                onChange={(e) => setApplicationStartDate(e.target.value)}
              />
              <AdminInput
                label="Application Last Date *"
                required
                type="date"
                value={applicationLastDate}
                onChange={(e) => setApplicationLastDate(e.target.value)}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <AdminInput
                label="Fee Payment Last Date"
                type="date"
                value={feePaymentLastDate}
                onChange={(e) => setFeePaymentLastDate(e.target.value)}
              />
              <AdminInput
                label="Correction Window Starts"
                type="date"
                value={correctionStartDate}
                onChange={(e) => setCorrectionStartDate(e.target.value)}
              />
              <AdminInput
                label="Correction Window Ends"
                type="date"
                value={correctionEndDate}
                onChange={(e) => setCorrectionEndDate(e.target.value)}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <AdminInput
                label="Examination Date (or Tentative Month)"
                value={examDate}
                onChange={(e) => setExamDate(e.target.value)}
                placeholder="e.g. 2026-11-15 or November 2026"
              />
              <AdminInput
                label="Admit Card Release Date"
                value={admitCardReleaseDate}
                onChange={(e) => setAdmitCardReleaseDate(e.target.value)}
                placeholder="e.g. 7 Days before examination"
              />
              <AdminInput
                label="Result / Merit List Date"
                value={resultDate}
                onChange={(e) => setResultDate(e.target.value)}
                placeholder="To be announced"
              />
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 7: APPLICATION FEE (Part 17) */}
      {/* ========================================================================= */}
      {activeTab === 'application_fee' && (
        <AdminCard
          title="7. Application Fee & Payment Mode"
          subtitle="Category-wise application fee structure and supported payment methods"
        >
          <div className="space-y-4">
            <div className="space-y-2.5">
              {applicationFees.map((fee, idx) => (
                <div
                  key={fee.id}
                  className="grid grid-cols-1 sm:grid-cols-12 gap-2 p-2.5 bg-slate-50 border border-slate-200 rounded-xl items-center"
                >
                  <div className="sm:col-span-5">
                    <input
                      type="text"
                      value={fee.category}
                      onChange={(e) => {
                        const next = [...applicationFees];
                        next[idx] = { ...next[idx], category: e.target.value };
                        setApplicationFees(next);
                      }}
                      placeholder="Category (e.g. General / OBC)"
                      className="w-full text-xs font-semibold px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-3">
                    <input
                      type="text"
                      value={fee.fee}
                      onChange={(e) => {
                        const next = [...applicationFees];
                        next[idx] = { ...next[idx], fee: e.target.value };
                        setApplicationFees(next);
                      }}
                      placeholder="Fee (e.g. 100 or 0)"
                      className="w-full text-xs font-bold px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-3">
                    <input
                      type="text"
                      value={fee.notes || ''}
                      onChange={(e) => {
                        const next = [...applicationFees];
                        next[idx] = { ...next[idx], notes: e.target.value };
                        setApplicationFees(next);
                      }}
                      placeholder="Notes (e.g. Non-refundable)"
                      className="w-full text-xs px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-1 flex justify-end">
                    <button
                      type="button"
                      onClick={() =>
                        setApplicationFees(applicationFees.filter((_, i) => i !== idx))
                      }
                      className="p-1.5 text-rose-500 hover:bg-rose-50 rounded-lg"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}

              <AdminButton
                type="button"
                variant="outline"
                size="sm"
                icon={<Plus className="w-4 h-4" />}
                onClick={() =>
                  setApplicationFees([
                    ...applicationFees,
                    {
                      id: `fee_${Date.now()}`,
                      category: '',
                      fee: '0',
                      currency: '₹',
                      notes: '',
                    },
                  ])
                }
              >
                Add Fee Row
              </AdminButton>
            </div>

            <div className="pt-3 border-t border-slate-100">
              <label className="block text-xs font-semibold text-slate-700 mb-2">
                Supported Payment Methods
              </label>
              <div className="flex flex-wrap gap-2">
                {[
                  'Debit Card',
                  'Credit Card',
                  'UPI',
                  'Net Banking',
                  'IMPS',
                  'Wallet',
                  'Challan / Offline',
                ].map((pm) => {
                  const isSelected = paymentMethods.includes(pm);
                  return (
                    <button
                      key={pm}
                      type="button"
                      onClick={() => {
                        if (isSelected) {
                          setPaymentMethods(paymentMethods.filter((m) => m !== pm));
                        } else {
                          setPaymentMethods([...paymentMethods, pm]);
                        }
                      }}
                      className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all border ${
                        isSelected
                          ? 'bg-[#159B76] text-white border-[#159B76]'
                          : 'bg-white text-slate-600 border-slate-200 hover:border-slate-300'
                      }`}
                    >
                      {pm}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 8: SALARY & PAY LEVEL (Part 18) */}
      {/* ========================================================================= */}
      {activeTab === 'salary_pay' && (
        <AdminCard
          title="8. Salary & Pay Matrix"
          subtitle="Recruitment-level compensation details (Individual posts may override)"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Pay Level (e.g. 7th CPC Matrix)"
                value={payLevel}
                onChange={(e) => setPayLevel(e.target.value)}
                placeholder="e.g. Level 6, Level 7"
              />
              <AdminInput
                label="Pay Scale"
                value={payScale}
                onChange={(e) => setPayScale(e.target.value)}
                placeholder="e.g. ₹35,400 - ₹1,12,400"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Minimum Approximate Salary (₹/month)"
                type="number"
                value={String(salaryMin)}
                onChange={(e) => setSalaryMin(e.target.value)}
                placeholder="e.g. 35400"
              />
              <AdminInput
                label="Maximum Approximate Salary (₹/month)"
                type="number"
                value={String(salaryMax)}
                onChange={(e) => setSalaryMax(e.target.value)}
                placeholder="e.g. 112400"
              />
            </div>

            <AdminInput
              label="Salary Summary Text"
              value={salaryText}
              onChange={(e) => setSalaryText(e.target.value)}
              placeholder="e.g. Level 6 (₹35,400 - ₹1,12,400) plus DA, HRA as admissible"
            />
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 9: HOW TO APPLY (Part 19) */}
      {/* ========================================================================= */}
      {activeTab === 'application_process' && (
        <AdminCard
          title="9. Application Process & Steps"
          subtitle="Step-by-step instructions presented as numbered badges in Flutter"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <AdminSelect
                label="Application Mode"
                value={applicationMode}
                onChange={(e) => setApplicationMode(e.target.value)}
                options={[
                  { value: 'Online via Portal', label: 'Online via Official Portal' },
                  { value: 'Offline / By Post', label: 'Offline / Registered Post' },
                  { value: 'Email Submission', label: 'Email Submission' },
                  { value: 'Walk-in Interview', label: 'Walk-in Interview' },
                ]}
              />
              <div className="flex items-center gap-2 pt-6">
                <input
                  type="checkbox"
                  id="otr"
                  checked={oneTimeRegistration}
                  onChange={(e) => setOneTimeRegistration(e.target.checked)}
                  className="w-4 h-4 rounded text-[#159B76]"
                />
                <label htmlFor="otr" className="text-xs font-semibold text-slate-800 cursor-pointer">
                  Requires One Time Registration (OTR)
                </label>
              </div>
            </div>

            {/* Ordered Steps Repeater */}
            <div>
              <span className="block text-xs font-bold text-slate-900 mb-2">
                Numbered Application Steps:
              </span>
              <div className="space-y-2">
                {howToApplySteps.map((step, idx) => (
                  <div key={idx} className="flex items-center gap-2">
                    <span className="w-6 h-6 rounded-md bg-[#159B76] text-white text-xs font-bold flex items-center justify-center shrink-0">
                      {idx + 1}
                    </span>
                    <input
                      type="text"
                      value={step}
                      onChange={(e) => {
                        const next = [...howToApplySteps];
                        next[idx] = e.target.value;
                        setHowToApplySteps(next);
                      }}
                      className="w-full text-xs px-3 py-2 rounded-xl border border-slate-200 bg-white"
                    />
                    <button
                      type="button"
                      onClick={() =>
                        setHowToApplySteps(howToApplySteps.filter((_, i) => i !== idx))
                      }
                      className="p-2 text-rose-500 hover:bg-rose-50 rounded-lg shrink-0"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}

                <AdminButton
                  type="button"
                  variant="outline"
                  size="sm"
                  icon={<Plus className="w-4 h-4" />}
                  onClick={() => setHowToApplySteps([...howToApplySteps, ''])}
                >
                  Add Step
                </AdminButton>
              </div>
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 10: DOCUMENTS REQUIRED (Part 20, 21) */}
      {/* ========================================================================= */}
      {activeTab === 'documents' && (
        <AdminCard
          title="10. Documents Required & Upload Specifications"
          subtitle="Checklist of certificates and photo/signature upload limits"
        >
          <div className="space-y-5">
            <div className="space-y-2.5">
              <span className="block text-xs font-bold text-slate-900">
                Document Checklist:
              </span>
              {documents.map((doc, idx) => (
                <div
                  key={doc.id}
                  className="grid grid-cols-1 sm:grid-cols-12 gap-2 p-2.5 bg-slate-50 border border-slate-200 rounded-xl items-center"
                >
                  <div className="sm:col-span-6">
                    <input
                      type="text"
                      value={doc.documentName}
                      onChange={(e) => {
                        const next = [...documents];
                        next[idx] = { ...next[idx], documentName: e.target.value };
                        setDocuments(next);
                      }}
                      placeholder="Document Name (e.g. 10th Certificate)"
                      className="w-full text-xs font-semibold px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-3 flex items-center gap-2">
                    <input
                      type="checkbox"
                      id={`req_${doc.id}`}
                      checked={doc.required}
                      onChange={(e) => {
                        const next = [...documents];
                        next[idx] = { ...next[idx], required: e.target.checked };
                        setDocuments(next);
                      }}
                      className="w-4 h-4 rounded text-[#159B76]"
                    />
                    <label htmlFor={`req_${doc.id}`} className="text-xs text-slate-700">
                      Mandatory
                    </label>
                  </div>
                  <div className="sm:col-span-2">
                    <input
                      type="text"
                      value={doc.notes || ''}
                      onChange={(e) => {
                        const next = [...documents];
                        next[idx] = { ...next[idx], notes: e.target.value };
                        setDocuments(next);
                      }}
                      placeholder="Notes"
                      className="w-full text-xs px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-1 flex justify-end">
                    <button
                      type="button"
                      onClick={() => setDocuments(documents.filter((_, i) => i !== idx))}
                      className="p-1.5 text-rose-500 hover:bg-rose-50 rounded-lg"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}

              <AdminButton
                type="button"
                variant="outline"
                size="sm"
                icon={<Plus className="w-4 h-4" />}
                onClick={() =>
                  setDocuments([
                    ...documents,
                    {
                      id: `doc_${Date.now()}`,
                      documentName: '',
                      required: true,
                      notes: '',
                    },
                  ])
                }
              >
                Add Document
              </AdminButton>
            </div>

            {/* Upload Specifications */}
            <div className="pt-3 border-t border-slate-100">
              <span className="block text-xs font-bold text-slate-900 mb-2">
                File Format & Size Constraints
              </span>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <AdminInput
                  label="Photograph Max Size"
                  value={uploadRequirements.photographMaxSize || ''}
                  onChange={(e) =>
                    setUploadRequirements({
                      ...uploadRequirements,
                      photographMaxSize: e.target.value,
                    })
                  }
                  placeholder="e.g. 50 KB"
                />
                <AdminInput
                  label="Signature Max Size"
                  value={uploadRequirements.signatureMaxSize || ''}
                  onChange={(e) =>
                    setUploadRequirements({
                      ...uploadRequirements,
                      signatureMaxSize: e.target.value,
                    })
                  }
                  placeholder="e.g. 20 KB"
                />
                <AdminInput
                  label="Certificates Max Size"
                  value={uploadRequirements.certificateMaxSize || ''}
                  onChange={(e) =>
                    setUploadRequirements({
                      ...uploadRequirements,
                      certificateMaxSize: e.target.value,
                    })
                  }
                  placeholder="e.g. 300 KB"
                />
              </div>
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 11: EXAM DETAILS (Part 22) */}
      {/* ========================================================================= */}
      {activeTab === 'exam_details' && (
        <AdminCard
          title="11. Examination Logistics & Rules"
          subtitle="Exam mode, test locations, duration, and marking schemes"
        >
          <div className="space-y-4">
            <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
              <input
                type="checkbox"
                id="hasExam"
                checked={examDetails.hasExam}
                onChange={(e) =>
                  setExamDetails({ ...examDetails, hasExam: e.target.checked })
                }
                className="w-4 h-4 rounded text-[#159B76]"
              />
              <label htmlFor="hasExam" className="text-xs font-bold text-slate-900 cursor-pointer">
                This recruitment includes a competitive written/online examination
              </label>
            </div>

            {examDetails.hasExam && (
              <div className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <AdminInput
                    label="Exam Mode"
                    value={examDetails.examMode || ''}
                    onChange={(e) =>
                      setExamDetails({ ...examDetails, examMode: e.target.value })
                    }
                    placeholder="e.g. CBT (Computer Based Test)"
                  />
                  <AdminInput
                    label="Exam Type"
                    value={examDetails.examType || ''}
                    onChange={(e) =>
                      setExamDetails({ ...examDetails, examType: e.target.value })
                    }
                    placeholder="e.g. Objective MCQ"
                  />
                  <AdminInput
                    label="Exam Centre / Location"
                    value={examDetails.examCentre || ''}
                    onChange={(e) =>
                      setExamDetails({ ...examDetails, examCentre: e.target.value })
                    }
                    placeholder="e.g. Port Blair / South Andaman"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <AdminInput
                    label="Exam Language / Medium"
                    value={examDetails.examLanguage || ''}
                    onChange={(e) =>
                      setExamDetails({ ...examDetails, examLanguage: e.target.value })
                    }
                    placeholder="e.g. English & Hindi"
                  />
                  <AdminInput
                    label="Exam Duration"
                    value={examDetails.examDuration || ''}
                    onChange={(e) =>
                      setExamDetails({ ...examDetails, examDuration: e.target.value })
                    }
                    placeholder="e.g. 120 Minutes (2 Hours)"
                  />
                  <AdminInput
                    label="Negative Marking"
                    value={examDetails.negativeMarking || ''}
                    onChange={(e) =>
                      setExamDetails({ ...examDetails, negativeMarking: e.target.value })
                    }
                    placeholder="e.g. 0.25 mark per wrong answer"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <AdminInput
                    label="Minimum Qualifying Marks"
                    value={examDetails.minimumQualifyingMarks || ''}
                    onChange={(e) =>
                      setExamDetails({
                        ...examDetails,
                        minimumQualifyingMarks: e.target.value,
                      })
                    }
                    placeholder="e.g. UR: 40%, OBC: 35%, SC/ST: 30%"
                  />
                  <AdminInput
                    label="Admit Card Issuance Method"
                    value={examDetails.admitCardMethod || ''}
                    onChange={(e) =>
                      setExamDetails({
                        ...examDetails,
                        admitCardMethod: e.target.value,
                      })
                    }
                    placeholder="e.g. Online download via candidate portal"
                  />
                </div>
              </div>
            )}
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 12: EXAM PATTERN (Part 23) */}
      {/* ========================================================================= */}
      {activeTab === 'exam_pattern' && (
        <AdminCard
          title="12. Examination Pattern & Subject Breakdown"
          subtitle="Subject-wise questions, marks, and duration formatted into a responsive mobile table"
        >
          <div className="space-y-4">
            <div className="space-y-2.5">
              {examPattern.map((p, idx) => (
                <div
                  key={p.id}
                  className="grid grid-cols-1 sm:grid-cols-12 gap-2 p-2.5 bg-slate-50 border border-slate-200 rounded-xl items-center"
                >
                  <div className="sm:col-span-2">
                    <input
                      type="text"
                      value={p.paperName || ''}
                      onChange={(e) => {
                        const next = [...examPattern];
                        next[idx] = { ...next[idx], paperName: e.target.value };
                        setExamPattern(next);
                      }}
                      placeholder="Paper (e.g. Tier 1)"
                      className="w-full text-xs font-bold px-2 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-4">
                    <input
                      type="text"
                      value={p.subject}
                      onChange={(e) => {
                        const next = [...examPattern];
                        next[idx] = { ...next[idx], subject: e.target.value };
                        setExamPattern(next);
                      }}
                      placeholder="Subject (e.g. General Awareness)"
                      className="w-full text-xs font-semibold px-2 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-2">
                    <input
                      type="number"
                      value={String(p.questions)}
                      onChange={(e) => {
                        const next = [...examPattern];
                        next[idx] = { ...next[idx], questions: e.target.value };
                        setExamPattern(next);
                      }}
                      placeholder="Questions"
                      className="w-full text-xs text-center font-bold px-2 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-2">
                    <input
                      type="number"
                      value={String(p.marks)}
                      onChange={(e) => {
                        const next = [...examPattern];
                        next[idx] = { ...next[idx], marks: e.target.value };
                        setExamPattern(next);
                      }}
                      placeholder="Marks"
                      className="w-full text-xs text-center font-bold px-2 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-1">
                    <input
                      type="text"
                      value={p.duration || ''}
                      onChange={(e) => {
                        const next = [...examPattern];
                        next[idx] = { ...next[idx], duration: e.target.value };
                        setExamPattern(next);
                      }}
                      placeholder="Duration"
                      className="w-full text-xs px-2 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                  <div className="sm:col-span-1 flex justify-end">
                    <button
                      type="button"
                      onClick={() => setExamPattern(examPattern.filter((_, i) => i !== idx))}
                      className="p-1.5 text-rose-500 hover:bg-rose-50 rounded-lg"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}

              <AdminButton
                type="button"
                variant="outline"
                size="sm"
                icon={<Plus className="w-4 h-4" />}
                onClick={() =>
                  setExamPattern([
                    ...examPattern,
                    {
                      id: `ep_${Date.now()}`,
                      paperName: 'Paper I',
                      subject: '',
                      questions: 25,
                      marks: 25,
                      duration: '60 Mins',
                    },
                  ])
                }
              >
                Add Subject Row
              </AdminButton>
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 13: SYLLABUS (Part 24) */}
      {/* ========================================================================= */}
      {activeTab === 'syllabus' && (
        <AdminCard
          title="13. Detailed Examination Syllabus"
          subtitle="Subject topics list and downloadable syllabus PDF link"
        >
          <div className="space-y-4">
            <AdminInput
              label="Official Syllabus PDF Link (Direct Download)"
              value={syllabusPdfUrl}
              onChange={(e) => setSyllabusPdfUrl(e.target.value)}
              placeholder="https://..."
            />

            <div>
              <span className="block text-xs font-bold text-slate-900 mb-2">
                Core Syllabus Topics:
              </span>
              <div className="space-y-2.5">
                {syllabusTopics.map((st, idx) => (
                  <div
                    key={st.id}
                    className="p-3 bg-slate-50 border border-slate-200 rounded-xl space-y-2"
                  >
                    <div className="flex items-center justify-between gap-2">
                      <input
                        type="text"
                        value={st.subject || ''}
                        onChange={(e) => {
                          const next = [...syllabusTopics];
                          next[idx] = { ...next[idx], subject: e.target.value };
                          setSyllabusTopics(next);
                        }}
                        placeholder="Subject (e.g. Agriculture Science)"
                        className="text-xs font-bold px-2 py-1 rounded-lg border border-slate-200 bg-white"
                      />
                      <button
                        type="button"
                        onClick={() =>
                          setSyllabusTopics(syllabusTopics.filter((_, i) => i !== idx))
                        }
                        className="p-1 text-rose-500 hover:bg-rose-50 rounded"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                    <input
                      type="text"
                      value={st.topicName}
                      onChange={(e) => {
                        const next = [...syllabusTopics];
                        next[idx] = { ...next[idx], topicName: e.target.value };
                        setSyllabusTopics(next);
                      }}
                      placeholder="Topic Title (e.g. Agronomy, Soil Science & Plant Pathology)"
                      className="w-full text-xs font-semibold px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                    <textarea
                      rows={2}
                      value={st.details || ''}
                      onChange={(e) => {
                        const next = [...syllabusTopics];
                        next[idx] = { ...next[idx], details: e.target.value };
                        setSyllabusTopics(next);
                      }}
                      placeholder="Subtopics and specific areas covered..."
                      className="w-full text-xs p-2 rounded-lg border border-slate-200 bg-white"
                    />
                  </div>
                ))}

                <AdminButton
                  type="button"
                  variant="outline"
                  size="sm"
                  icon={<Plus className="w-4 h-4" />}
                  onClick={() =>
                    setSyllabusTopics([
                      ...syllabusTopics,
                      {
                        id: `syl_${Date.now()}`,
                        subject: '',
                        topicName: '',
                        details: '',
                      },
                    ])
                  }
                >
                  Add Syllabus Topic
                </AdminButton>
              </div>
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 14: SELECTION PROCESS (Part 25, 26, 27) */}
      {/* ========================================================================= */}
      {activeTab === 'selection_process' && (
        <AdminCard
          title="14. Selection Process & Merit Criteria"
          subtitle="Sequential selection stages, merit calculation basis, and tie-breaking rules"
        >
          <div className="space-y-4">
            <div>
              <span className="block text-xs font-bold text-slate-900 mb-2">
                Selection Process Stages:
              </span>
              <div className="space-y-2">
                {selectionProcess.map((sp, idx) => (
                  <div
                    key={sp.id}
                    className="flex items-center gap-2 p-2.5 bg-slate-50 border border-slate-200 rounded-xl"
                  >
                    <span className="w-6 h-6 rounded-md bg-[#159B76] text-white text-xs font-bold flex items-center justify-center shrink-0">
                      {idx + 1}
                    </span>
                    <input
                      type="text"
                      value={sp.name}
                      onChange={(e) => {
                        const next = [...selectionProcess];
                        next[idx] = { ...next[idx], name: e.target.value };
                        setSelectionProcess(next);
                      }}
                      placeholder="Stage Name (e.g. CBT Exam)"
                      className="w-1/3 text-xs font-bold px-2 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                    <input
                      type="text"
                      value={sp.description}
                      onChange={(e) => {
                        const next = [...selectionProcess];
                        next[idx] = { ...next[idx], description: e.target.value };
                        setSelectionProcess(next);
                      }}
                      placeholder="Description"
                      className="w-full text-xs px-2 py-1.5 rounded-lg border border-slate-200 bg-white"
                    />
                    <button
                      type="button"
                      onClick={() =>
                        setSelectionProcess(selectionProcess.filter((_, i) => i !== idx))
                      }
                      className="p-1.5 text-rose-500 hover:bg-rose-50 rounded-lg shrink-0"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}

                <AdminButton
                  type="button"
                  variant="outline"
                  size="sm"
                  icon={<Plus className="w-4 h-4" />}
                  onClick={() =>
                    setSelectionProcess([
                      ...selectionProcess,
                      {
                        id: `sp_${Date.now()}`,
                        stageNumber: selectionProcess.length + 1,
                        name: '',
                        description: '',
                        mandatory: true,
                      },
                    ])
                  }
                >
                  Add Selection Stage
                </AdminButton>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-3 border-t border-slate-100">
              <AdminInput
                label="Selection Basis"
                value={selectionRules.selectionBasis || ''}
                onChange={(e) =>
                  setSelectionRules({ ...selectionRules, selectionBasis: e.target.value })
                }
                placeholder="e.g. Written Exam Marks + Document Verification"
              />
              <AdminInput
                label="Merit Calculation Rule"
                value={selectionRules.meritCalculation || ''}
                onChange={(e) =>
                  setSelectionRules({ ...selectionRules, meritCalculation: e.target.value })
                }
                placeholder="e.g. Normalized score out of 100"
              />
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 15: IMPORTANT LINKS (Part 28) */}
      {/* ========================================================================= */}
      {activeTab === 'important_links' && (
        <AdminCard
          title="15. Official Links & Documents"
          subtitle="Verified HTTPS official links for Apply Online, PDF notification, and official department portal"
        >
          <div className="space-y-4">
            <AdminInput
              label="Apply Online URL"
              value={applyUrl}
              onChange={(e) => setApplyUrl(e.target.value)}
              placeholder="https://..."
            />
            <AdminInput
              label="Official Notification PDF URL"
              value={officialNotificationUrl}
              onChange={(e) => setOfficialNotificationUrl(e.target.value)}
              placeholder="https://..."
            />
            <AdminInput
              label="Official Department Website URL"
              value={officialWebsiteUrl}
              onChange={(e) => setOfficialWebsiteUrl(e.target.value)}
              placeholder="https://..."
            />
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Press Note / Short Notice URL (Optional)"
                value={pressNoteUrl}
                onChange={(e) => setPressNoteUrl(e.target.value)}
                placeholder="https://..."
              />
              <AdminInput
                label="Admit Card / Download Portal URL (Optional)"
                value={admitCardUrl}
                onChange={(e) => setAdmitCardUrl(e.target.value)}
                placeholder="https://..."
              />
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 16: FAQ (Frequently Asked Questions) */}
      {/* ========================================================================= */}
      {activeTab === 'faq' && (
        <AdminCard
          title="16. Frequently Asked Questions (FAQ)"
          subtitle="Answers to common aspirant questions rendered as an expandable FAQ accordion"
        >
          <div className="space-y-3">
            {faqs.map((faq, idx) => (
              <div
                key={faq.id}
                className="p-3 bg-slate-50 border border-slate-200 rounded-xl space-y-2"
              >
                <div className="flex items-center justify-between gap-2">
                  <span className="text-xs font-bold text-slate-800">Q{idx + 1}</span>
                  <button
                    type="button"
                    onClick={() => setFaqs(faqs.filter((_, i) => i !== idx))}
                    className="p-1 text-rose-500 hover:bg-rose-50 rounded"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
                <input
                  type="text"
                  value={faq.question}
                  onChange={(e) => {
                    const next = [...faqs];
                    next[idx] = { ...next[idx], question: e.target.value };
                    setFaqs(next);
                  }}
                  placeholder="Question..."
                  className="w-full text-xs font-semibold px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                />
                <textarea
                  rows={2}
                  value={faq.answer}
                  onChange={(e) => {
                    const next = [...faqs];
                    next[idx] = { ...next[idx], answer: e.target.value };
                    setFaqs(next);
                  }}
                  placeholder="Answer..."
                  className="w-full text-xs p-2 rounded-lg border border-slate-200 bg-white"
                />
              </div>
            ))}

            <AdminButton
              type="button"
              variant="outline"
              size="sm"
              icon={<Plus className="w-4 h-4" />}
              onClick={() =>
                setFaqs([
                  ...faqs,
                  {
                    id: `faq_${Date.now()}`,
                    question: '',
                    answer: '',
                  },
                ])
              }
            >
              Add FAQ
            </AdminButton>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 17: SOURCE VERIFICATION (Part 29, Correction 12) */}
      {/* ========================================================================= */}
      {activeTab === 'source_verification' && (
        <AdminCard
          title="17. Source Verification & Trust Metadata"
          subtitle="Official issuing department, gazette reference, and editorial review verification"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Issuing Authority / Source Org"
                value={sourceOrg}
                onChange={(e) => setSourceOrg(e.target.value)}
                placeholder="e.g. Directorate of Agriculture, A&N Administration"
              />
              <AdminInput
                label="Gazette / Notification Number"
                value={gazetteNumber}
                onChange={(e) => setGazetteNumber(e.target.value)}
                placeholder="e.g. Extraordinary Gazette No. 42"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Source Official Website Portal"
                value={sourceWebsiteUrl}
                onChange={(e) => setSourceWebsiteUrl(e.target.value)}
                placeholder="https://..."
              />
              <AdminInput
                label="Original Circular Reference"
                value={circularNumber}
                onChange={(e) => setCircularNumber(e.target.value)}
                placeholder="e.g. Circular F.No. 12/2026"
              />
            </div>

            <div className="p-3 bg-slate-50 border border-slate-200 rounded-xl flex items-center gap-2.5">
              <input
                type="checkbox"
                id="sourceVerified"
                checked={sourceVerified}
                onChange={(e) => setSourceVerified(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76]"
              />
              <label htmlFor="sourceVerified" className="text-xs font-bold text-slate-800 cursor-pointer">
                Verified Source checked by Notify Jobs (Displays trust badge on post)
              </label>
            </div>
          </div>
        </AdminCard>
      )}

      {/* ========================================================================= */}
      {/* TAB 18: PUBLISHING & APP DISPLAY CONTROLS (Part 31, 32, 38, 39) */}
      {/* ========================================================================= */}
      {activeTab === 'publishing_display' && (
        <div className="space-y-4">
          {/* App Display Controls (Section Toggles) */}
          <AdminCard
            title="App Display Controls (Remote Section Visibility)"
            subtitle="Admin controls which sections appear in Flutter Job Details for this recruitment"
          >
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2.5">
              {(
                [
                  ['showImportantDates', 'Important Dates'],
                  ['showPosts', 'Post-wise Cards'],
                  ['showVacancies', 'Vacancy Breakdown'],
                  ['showQualification', 'Educational Qualification'],
                  ['showAgeLimit', 'Age Limit & Relaxation'],
                  ['showFees', 'Application Fee'],
                  ['showSalary', 'Salary & Pay Level'],
                  ['showApplicationProcess', 'How to Apply Steps'],
                  ['showDocuments', 'Documents Checklist'],
                  ['showExamDetails', 'Exam Details'],
                  ['showExamPattern', 'Exam Pattern Table'],
                  ['showSyllabus', 'Syllabus Topics'],
                  ['showSelectionProcess', 'Selection Process'],
                  ['showImportantLinks', 'Official Links'],
                  ['showFAQ', 'FAQ Section'],
                  ['showSourceInformation', 'Source Verification Info'],
                  ['showOverview', 'Overview / Notes'],
                  ['showDisclaimer', 'Government Disclaimer'],
                ] as [keyof AppDisplayControls, string][]
              ).map(([fieldKey, label]) => {
                const isEnabled = appDisplayControls[fieldKey] !== false;
                return (
                  <label
                    key={fieldKey}
                    className="flex items-center gap-2 p-2 rounded-lg border border-slate-200 bg-slate-50 cursor-pointer hover:bg-slate-100"
                  >
                    <input
                      type="checkbox"
                      checked={isEnabled}
                      onChange={(e) =>
                        setAppDisplayControls({
                          ...appDisplayControls,
                          [fieldKey]: e.target.checked,
                        })
                      }
                      className="w-3.5 h-3.5 rounded text-[#159B76]"
                    />
                    <span className="text-xs font-semibold text-slate-800 truncate">
                      {label}
                    </span>
                  </label>
                );
              })}
            </div>
            <p className="text-[11px] text-slate-500 mt-2">
              Note: Even if a section toggle is ON, Flutter will automatically hide empty sections without broken text.
            </p>
          </AdminCard>

          {/* Publishing Status & Fallback Body */}
          <AdminCard
            title="Publishing Status & Editorial Overview"
            subtitle="Release state, status override, and supplementary rich text"
          >
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <AdminSelect
                  label="Publishing State"
                  value={status}
                  onChange={(e) => setStatus(e.target.value as ContentStatus)}
                  options={[
                    { value: 'published', label: 'Published (Live in App)' },
                    { value: 'draft', label: 'Draft (Admin Only)' },
                    { value: 'scheduled', label: 'Scheduled' },
                    { value: 'archived', label: 'Archived' },
                  ]}
                />
                <AdminSelect
                  label="Status Override Badge"
                  value={statusOverride}
                  onChange={(e) => setStatusOverride(e.target.value as StatusOverride)}
                  options={[
                    { value: 'auto', label: 'Auto (Calculate from Deadline)' },
                    { value: 'open', label: 'Force Open' },
                    { value: 'closing_soon', label: 'Force Closing Soon' },
                    { value: 'closed', label: 'Force Closed' },
                  ]}
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Supplementary Overview (Optional Markdown)
                </label>
                <textarea
                  rows={4}
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  placeholder="Supplementary editorial overview (Structured data will always take precedence over raw body)..."
                  className="w-full text-xs rounded-xl border border-slate-200 bg-white p-3 font-mono focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
                />
              </div>
            </div>
          </AdminCard>
        </div>
      )}

      {/* ========================================================================= */}
      {/* NON-JOB TYPE SPECIFIC TAB (Admit Card, Result, Answer Key, Syllabus, Article) */}
      {/* ========================================================================= */}
      {!isJobType && activeTab === 'type_specific' && (
        <AdminCard
          title={`${contentType.replace('_', ' ').toUpperCase()} Specific Details`}
          subtitle="Link to parent recruitment and enter specific exam update parameters"
        >
          <div className="space-y-4">
            {/* Searchable Parent Recruitment Selector (Correction 4) */}
            <ParentRecruitmentSelector
              selectedId={parentRecruitmentId}
              selectedTitle={parentRecruitmentTitle}
              onSelect={(id, parentTitle) => {
                setParentRecruitmentId(id);
                setParentRecruitmentTitle(parentTitle);
              }}
              onClear={() => {
                setParentRecruitmentId('');
                setParentRecruitmentTitle('');
              }}
            />

            {contentType === 'admit_card' && (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <AdminInput
                  label="Admit Card Release Date"
                  value={admitCardReleaseDate}
                  onChange={(e) => setAdmitCardReleaseDate(e.target.value)}
                  placeholder="e.g. 24 Sep 2026"
                />
                <AdminInput
                  label="Examination Date"
                  value={examDate}
                  onChange={(e) => setExamDate(e.target.value)}
                  placeholder="e.g. 15 Oct 2026"
                />
              </div>
            )}

            {contentType === 'result' && (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <AdminInput
                  label="Result / Merit List Declaration Date"
                  value={resultDate}
                  onChange={(e) => setResultDate(e.target.value)}
                  placeholder="e.g. 24 Sep 2026"
                />
                <AdminInput
                  label="Result / Merit List PDF Link"
                  value={resultUrl}
                  onChange={(e) => setResultUrl(e.target.value)}
                  placeholder="https://..."
                />
              </div>
            )}

            {contentType === 'answer_key' && (
              <div className="space-y-3">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <AdminInput
                    label="Answer Key Release Date"
                    value={admitCardReleaseDate}
                    onChange={(e) => setAdmitCardReleaseDate(e.target.value)}
                    placeholder="e.g. 24 Sep 2026"
                  />
                  <AdminInput
                    label="Objection Window End Date"
                    value={applicationLastDate}
                    onChange={(e) => setApplicationLastDate(e.target.value)}
                    placeholder="e.g. 30 Sep 2026"
                  />
                </div>
              </div>
            )}

            {contentType === 'article' && (
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Article Body (Full Markdown)
                </label>
                <textarea
                  rows={10}
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  placeholder="Write comprehensive article content in markdown..."
                  className="w-full text-xs rounded-xl border border-slate-200 bg-white p-3 font-mono"
                />
              </div>
            )}
          </div>
        </AdminCard>
      )}

      {/* MODAL: MOBILE PREVIEW (Part 36) */}
      <MobilePreviewModal
        isOpen={previewOpen}
        onClose={() => setPreviewOpen(false)}
        item={constructPayload()}
      />

      {/* MODAL: PUBLISH CONFIRMATION */}
      <AdminModal
        isOpen={publishModalOpen}
        onClose={() => setPublishModalOpen(false)}
        title={isEditing ? 'Confirm Post Update' : 'Confirm Publish Recruitment'}
      >
        <div className="space-y-4">
          <p className="text-xs text-slate-600">
            You are about to publish <strong>{title || 'this recruitment'}</strong> live to the Notify Jobs user app.
          </p>

          <div className="p-3 bg-slate-50 border border-slate-200 rounded-xl space-y-1.5 text-xs">
            <div>
              <span className="font-bold text-slate-700">Categories:</span>{' '}
              {selectedCategoryNames.join(', ') || 'None selected'}
            </div>
            {isJobType && (
              <div>
                <span className="font-bold text-slate-700">Total Vacancies:</span>{' '}
                {vacancyMode === 'detailed' ? overallTotalDetailed : simpleTotalVacancies}
              </div>
            )}
            <div>
              <span className="font-bold text-slate-700">Visibility:</span>{' '}
              {showInUserApp ? 'Visible in User App' : 'Hidden from User App'}
            </div>
          </div>

          <div className="flex items-center gap-2 pt-2 border-t border-slate-100">
            <input
              type="checkbox"
              id="sendPush"
              checked={sendPush}
              onChange={(e) => setSendPush(e.target.checked)}
              className="w-4 h-4 rounded text-[#159B76]"
            />
            <label htmlFor="sendPush" className="text-xs font-bold text-slate-800 cursor-pointer">
              Send Push Notification to Aspirants
            </label>
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <AdminButton
              type="button"
              variant="outline"
              onClick={() => setPublishModalOpen(false)}
            >
              Cancel
            </AdminButton>
            <AdminButton
              type="button"
              variant="primary"
              loading={saving}
              onClick={handleConfirmPublish}
            >
              Confirm & Publish
            </AdminButton>
          </div>
        </div>
      </AdminModal>
    </div>
  );
};
