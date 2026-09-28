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
  Activity,
  Stethoscope,
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
  PhysicalStandardItem,
  PETEventItem,
  TradeTestItem,
  MedicalStandardItem,
  DeputationConditions,
  OtherConditionItem,
} from '../types';
import { fetchJobTypes } from '../services/jobTypeService';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';
import { AdminButton } from '../components/common/AdminButton';
import { AdminCard } from '../components/common/AdminCard';
import { AdminCategorySelector } from '../components/common/AdminCategorySelector';
import { PostVacancyBuilder, calculateVacancyTotal } from '../components/editor/PostVacancyBuilder';
import {
  OptionalModulesBuilder,
  OptionalModuleType,
} from '../components/editor/OptionalModulesBuilder';
import { ParentRecruitmentSelector } from '../components/editor/ParentRecruitmentSelector';
import { MobilePreviewModal } from '../components/preview/MobilePreviewModal';
import { AdminModal } from '../components/common/AdminModal';

// =============================================================================
// 6 CORE SMART UNIVERSAL STEPS
// =============================================================================

export type UniversalStepId =
  | 'basic_details'
  | 'vacancy_eligibility'
  | 'dates_application'
  | 'exam_selection'
  | 'content_links'
  | 'publish_display';

export interface UniversalStepConfig {
  id: UniversalStepId;
  label: string;
  stepNumber: number;
  icon: React.ComponentType<{ className?: string }>;
  description: string;
}

export const UNIVERSAL_STEPS: UniversalStepConfig[] = [
  {
    id: 'basic_details',
    label: 'Basic Details',
    stepNumber: 1,
    icon: Building,
    description: 'Recruitment type, titles, departments, and taxonomy',
  },
  {
    id: 'vacancy_eligibility',
    label: 'Vacancy & Eligibility',
    stepNumber: 2,
    icon: Users,
    description: 'Post builder, vacancy totals, qualifications, and optional rules',
  },
  {
    id: 'dates_application',
    label: 'Dates & Application',
    stepNumber: 3,
    icon: Calendar,
    description: 'Canonical dates, application mode, fee breakdown, and checklist',
  },
  {
    id: 'exam_selection',
    label: 'Exam & Selection',
    stepNumber: 4,
    icon: Award,
    description: 'Conditional exam pattern, syllabus topics, and selection stages',
  },
  {
    id: 'content_links',
    label: 'Content & Official Links',
    stepNumber: 5,
    icon: LinkIcon,
    description: 'Supplementary overview, validated official URLs, and source badge',
  },
  {
    id: 'publish_display',
    label: 'Publish & App Display',
    stepNumber: 6,
    icon: Send,
    description: 'Dynamic section controls, publication status, and preview',
  },
];

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

  // Active Step State (1 of 6)
  const [currentStep, setCurrentStep] = useState<UniversalStepId>('basic_details');

  // Content Type & Subtype
  const [contentType, setContentType] = useState<ContentType>(
    initialItem?.contentType || presetType || 'government_job'
  );
  const isJobType =
    contentType === 'government_job' ||
    contentType === 'andaman_job' ||
    contentType === 'private_job';

  // Recruitment Subtype taxonomy
  const [recruitmentSubtype, setRecruitmentSubtype] = useState<string>(
    initialItem?.recruitmentType ||
      (contentType === 'private_job' ? 'Private' : 'Government Regular')
  );

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

  // ===========================================================================
  // STEP 1: BASIC DETAILS STATE
  // ===========================================================================
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
  const [excerpt, setExcerpt] = useState(initialItem?.excerpt || '');
  const [featuredImageUrl, setFeaturedImageUrl] = useState(initialItem?.featuredImageUrl || '');
  const [tagsText, setTagsText] = useState(initialItem?.tags?.join(', ') || '');
  const [searchKeywordsText, setSearchKeywordsText] = useState(
    initialItem?.searchKeywords?.join(', ') || ''
  );
  const [slug, setSlug] = useState(initialItem?.slug || '');
  const [isSlugManual, setIsSlugManual] = useState(Boolean(initialItem?.slug));

  // Auto-generate slug
  useEffect(() => {
    if (!isSlugManual && title) {
      const generated = title
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)+/g, '');
      setSlug(generated);
    }
  }, [title, isSlugManual]);

  // Categories & Taxonomy
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<string[]>(
    initialItem?.categoryIds && initialItem.categoryIds.length > 0
      ? initialItem.categoryIds
      : ['latest-jobs']
  );
  const [selectedCategoryNames, setSelectedCategoryNames] = useState<string[]>(
    initialItem?.categoryNames || []
  );

  // Parent Recruitment Selector
  const [parentRecruitmentId, setParentRecruitmentId] = useState<string>(
    initialItem?.parentRecruitmentId || ''
  );
  const [parentRecruitmentTitle, setParentRecruitmentTitle] = useState<string>(
    initialItem?.parentRecruitmentTitle || ''
  );

  // Private / Andaman specifics
  const [companyName, setCompanyName] = useState(initialItem?.companyName || '');
  const [island, setIsland] = useState(initialItem?.island || 'South Andaman');

  // ===========================================================================
  // STEP 2: VACANCY & ELIGIBILITY STATE
  // ===========================================================================
  // Recruitment-level default inheritance values
  const [defaultQualification, setDefaultQualification] = useState(
    initialItem?.minimumQualification || initialItem?.qualification || ''
  );
  const [defaultExperience, setDefaultExperience] = useState(
    initialItem?.experienceRequired || initialItem?.experience || ''
  );
  const [defaultMinAge, setDefaultMinAge] = useState<string | number>(
    initialItem?.defaultMinimumAge || '18'
  );
  const [defaultMaxAge, setDefaultMaxAge] = useState<string | number>(
    initialItem?.defaultMaximumAge || '33'
  );
  const [ageAsOn, setAgeAsOn] = useState(initialItem?.ageAsOn || '');
  const [defaultPayLevel, setDefaultPayLevel] = useState(initialItem?.payLevel || '');
  const [defaultPayScale, setDefaultPayScale] = useState(initialItem?.payScale || '');
  const [defaultSalaryText, setDefaultSalaryText] = useState(
    initialItem?.salaryText || initialItem?.salary || ''
  );
  const [nationality, setNationality] = useState(
    initialItem?.nationality || 'Citizen of India'
  );
  const [registrationRequirement, setRegistrationRequirement] = useState(
    initialItem?.registrationRequirement || ''
  );

  // Post Builder State
  const [vacancyMode, setVacancyMode] = useState<'simple' | 'detailed'>(
    initialItem?.vacancyMode || (initialItem?.posts && initialItem.posts.length > 0 ? 'detailed' : 'detailed')
  );
  const [posts, setPosts] = useState<PostItem[]>(initialItem?.posts || []);
  const [simpleTotalVacancies, setSimpleTotalVacancies] = useState<string | number>(
    initialItem?.totalVacancies ?? initialItem?.vacancies ?? ''
  );

  // Enabled Optional Modules
  const [enabledOptionalModules, setEnabledOptionalModules] = useState<OptionalModuleType[]>(
    (initialItem?.enabledOptionalModules as OptionalModuleType[]) || [
      ...(initialItem?.ageRelaxations && initialItem.ageRelaxations.length > 0
        ? (['age_relaxation'] as OptionalModuleType[])
        : []),
    ]
  );

  // Optional Module Data States
  const [ageRelaxations, setAgeRelaxations] = useState<AgeLimitItem[]>(
    initialItem?.ageRelaxations || []
  );
  const [physicalStandards, setPhysicalStandards] = useState<PhysicalStandardItem[]>(
    initialItem?.physicalStandards || []
  );
  const [petEvents, setPETEvents] = useState<PETEventItem[]>(initialItem?.petEvents || []);
  const [tradeTests, setTradeTests] = useState<TradeTestItem[]>(initialItem?.tradeTests || []);
  const [medicalStandards, setMedicalStandards] = useState<MedicalStandardItem[]>(
    initialItem?.medicalStandards || []
  );
  const [deputationConditions, setDeputationConditions] = useState<DeputationConditions>(
    initialItem?.deputationConditions || {}
  );
  const [serviceRequirements, setServiceRequirements] = useState(
    initialItem?.serviceRequirements || ''
  );
  const [reservationNotes, setReservationNotes] = useState<string[]>(
    initialItem?.reservationNotes || []
  );
  const [probationPeriod, setProbationPeriod] = useState(initialItem?.probationPeriod || '');
  const [trainingPeriod, setTrainingPeriod] = useState(initialItem?.trainingPeriod || '');
  const [serviceBond, setServiceBond] = useState(initialItem?.serviceBond || '');
  const [otherConditions, setOtherConditions] = useState<OtherConditionItem[]>(
    initialItem?.otherConditions || []
  );

  // ===========================================================================
  // STEP 3: DATES & APPLICATION STATE
  // ===========================================================================
  const [notificationDate, setNotificationDate] = useState(initialItem?.notificationDate || '');
  const [applicationStartDate, setApplicationStartDate] = useState(
    initialItem?.applicationStartDate || ''
  );
  const [applicationLastDate, setApplicationLastDate] = useState(
    initialItem?.applicationLastDate || (initialItem as any)?.lastDate || ''
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
  const [admitCardDate, setAdmitCardDate] = useState(initialItem?.admitCardDate || '');
  const [answerKeyDate, setAnswerKeyDate] = useState(initialItem?.answerKeyDate || '');
  const [resultDate, setResultDate] = useState(initialItem?.resultDate || '');
  const [customDates, setCustomDates] = useState<ImportantDateItem[]>(
    initialItem?.importantDates || []
  );

  // Application Method & Fees
  const [applicationMode, setApplicationMode] = useState(
    initialItem?.applicationMode || 'Online'
  );
  const [oneTimeRegistration, setOneTimeRegistration] = useState(
    initialItem?.oneTimeRegistration || false
  );
  const [howToApplySteps, setHowToApplySteps] = useState<string[]>(
    initialItem?.howToApplySteps || []
  );
  const [applicationFees, setApplicationFees] = useState<ApplicationFeeItem[]>(
    initialItem?.applicationFees || []
  );
  const [paymentMethods, setPaymentMethods] = useState<string[]>(
    initialItem?.paymentMethods || ['Debit Card', 'Credit Card', 'Net Banking', 'UPI']
  );
  const [documents, setDocuments] = useState<DocumentItem[]>(
    initialItem?.documents || [
      { id: 'doc-1', documentName: 'Aadhaar Card / Photo Identity Proof', required: true },
      { id: 'doc-2', documentName: 'Educational Qualification Certificates & Marksheets', required: true },
      { id: 'doc-3', documentName: 'Category / Caste Certificate (if applicable)', required: false },
      { id: 'doc-4', documentName: 'Recent Passport Size Photograph', required: true },
      { id: 'doc-5', documentName: 'Scanned Signature', required: true },
    ]
  );
  const [uploadRequirements, setUploadRequirements] = useState<UploadRequirements>(
    initialItem?.uploadRequirements || {
      photographFormat: 'JPG/JPEG',
      photographMaxSize: '20 KB - 50 KB',
      signatureFormat: 'JPG/JPEG',
      signatureMaxSize: '10 KB - 20 KB',
      certificateFormat: 'PDF',
      certificateMaxSize: '100 KB - 300 KB',
    }
  );

  // ===========================================================================
  // STEP 4: EXAM & SELECTION STATE
  // ===========================================================================
  const [hasExamination, setHasExamination] = useState(
    initialItem?.hasExamination ?? initialItem?.examDetails?.hasExam ?? true
  );
  const [hasPhysicalTest, setHasPhysicalTest] = useState(
    initialItem?.hasPhysicalTest ??
      (physicalStandards.length > 0 || petEvents.length > 0)
  );
  const [hasTradeTest, setHasTradeTest] = useState(
    initialItem?.hasTradeTest ?? tradeTests.length > 0
  );
  const [hasInterview, setHasInterview] = useState(initialItem?.hasInterview ?? false);
  const [hasMedicalExam, setHasMedicalExam] = useState(
    initialItem?.hasMedicalExam ?? medicalStandards.length > 0
  );

  // Exam Details
  const [examDetails, setExamDetails] = useState<ExamDetails>(
    initialItem?.examDetails || {
      hasExam: true,
      examMode: 'Online CBT',
      examType: 'Multiple Choice Questions (MCQ)',
      examDuration: '120 Minutes',
      negativeMarking: '0.25 Marks for each wrong answer',
      examLanguage: 'Bilingual (English & Hindi)',
      minimumQualifyingMarks: 'UR: 35%, OBC/SC/ST: 33%',
    }
  );
  const [examPatternItems, setExamPatternItems] = useState<ExamPatternItem[]>(
    initialItem?.examPattern || []
  );
  const [syllabusTopics, setSyllabusTopics] = useState<SyllabusTopicItem[]>(
    initialItem?.syllabusTopics || []
  );
  const [syllabusPdfUrl, setSyllabusPdfUrl] = useState(
    initialItem?.syllabusPdfUrl || initialItem?.syllabusUrl || ''
  );
  const [selectionStages, setSelectionStages] = useState<SelectionStepItem[]>(
    initialItem?.selectionProcess || [
      { id: 'stg-1', stageNumber: 1, name: 'Computer Based Test (CBT)', description: 'Objective type examination', mandatory: true },
      { id: 'stg-2', stageNumber: 2, name: 'Document Verification', description: 'Scrutiny of original certificates', mandatory: true },
      { id: 'stg-3', stageNumber: 3, name: 'Medical Examination', description: 'Pre-appointment fitness test', mandatory: true },
    ]
  );
  const [selectionRules, setSelectionRules] = useState<SelectionRules>(
    initialItem?.selectionRules || {
      selectionBasis: 'Merit in Written Examination subject to qualifying verification',
      meritCalculation: 'Normalized scores in CBT',
    }
  );

  // ===========================================================================
  // STEP 5: CONTENT & OFFICIAL LINKS STATE
  // ===========================================================================
  const [body, setBody] = useState(initialItem?.body || '');
  const [applyUrl, setApplyUrl] = useState(initialItem?.applyUrl || '');
  const [officialNotificationUrl, setOfficialNotificationUrl] = useState(
    initialItem?.officialNotificationUrl || ''
  );
  const [officialWebsiteUrl, setOfficialWebsiteUrl] = useState(
    initialItem?.officialWebsiteUrl || ''
  );
  const [customLinks, setCustomLinks] = useState<ImportantLinkItem[]>(
    initialItem?.importantLinks || []
  );
  const [sourceVerification, setSourceVerification] = useState<SourceVerification>(
    initialItem?.sourceVerification || {
      sourceOrg: organization || 'Official Recruitment Portal',
      sourceVerified: true,
      sourcePublishedDate: notificationDate || new Date().toISOString().split('T')[0],
    }
  );

  // ===========================================================================
  // STEP 6: PUBLISH & APP DISPLAY STATE
  // ===========================================================================
  const [status, setStatus] = useState<ContentStatus>(initialItem?.status || 'draft');
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

  // Dynamic Section Controls State
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
      showPhysicalStandards: true,
      showPETPST: true,
      showTradeTest: true,
      showMedicalStandards: true,
      showDeputationConditions: true,
      showSelectionProcess: true,
      showImportantLinks: true,
      showFAQ: true,
      showSourceInformation: true,
      showDisclaimer: true,
    }
  );

  // Mobile Preview State
  const [showPreviewModal, setShowPreviewModal] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccessMessage, setSaveSuccessMessage] = useState('');

  // Automatic Overall Total Vacancies Calculation
  const calculatedTotalVacancies = useMemo(() => {
    if (posts.length === 0) return Number(simpleTotalVacancies) || 0;
    return posts.reduce((sum, p) => sum + calculateVacancyTotal(p.vacancies), 0);
  }, [posts, simpleTotalVacancies]);

  // Evaluate which modules actually have data for Dynamic App Section Controls
  const populatedModules = useMemo(() => {
    return {
      hasDates: Boolean(
        notificationDate ||
          applicationStartDate ||
          applicationLastDate ||
          examDate ||
          customDates.length > 0
      ),
      hasPosts: posts.length > 0,
      hasVacancies: calculatedTotalVacancies > 0,
      hasQualification: Boolean(defaultQualification || posts.some((p) => p.qualification)),
      hasAgeLimit: Boolean(defaultMaxAge || ageRelaxations.length > 0),
      hasFees: applicationFees.length > 0,
      hasSalary: Boolean(defaultSalaryText || defaultPayLevel || posts.some((p) => p.payLevel || p.salaryText)),
      hasHowToApply: howToApplySteps.length > 0,
      hasDocuments: documents.length > 0,
      hasExam: hasExamination && (Boolean(examDetails.examMode) || examPatternItems.length > 0),
      hasSyllabus: syllabusTopics.length > 0 || Boolean(syllabusPdfUrl),
      hasPhysicalStandards: physicalStandards.length > 0,
      hasPETPST: petEvents.length > 0,
      hasTradeTest: tradeTests.length > 0,
      hasMedical: medicalStandards.length > 0,
      hasDeputation: Boolean(deputationConditions.parentDepartment || deputationConditions.deputationTenure),
      hasSelection: selectionStages.length > 0,
      hasLinks: Boolean(applyUrl || officialNotificationUrl || officialWebsiteUrl || customLinks.length > 0),
      hasSource: Boolean(sourceVerification.sourceOrg || sourceVerification.notificationNumber),
    };
  }, [
    notificationDate,
    applicationStartDate,
    applicationLastDate,
    examDate,
    customDates,
    posts,
    calculatedTotalVacancies,
    defaultQualification,
    defaultMaxAge,
    ageRelaxations,
    applicationFees,
    defaultSalaryText,
    defaultPayLevel,
    howToApplySteps,
    documents,
    hasExamination,
    examDetails,
    examPatternItems,
    syllabusTopics,
    syllabusPdfUrl,
    physicalStandards,
    petEvents,
    tradeTests,
    medicalStandards,
    deputationConditions,
    selectionStages,
    applyUrl,
    officialNotificationUrl,
    officialWebsiteUrl,
    customLinks,
    sourceVerification,
  ]);

  // Completeness score
  const completenessScore = useMemo(() => {
    let score = 0;
    if (title.trim()) score += 15;
    if (organization.trim()) score += 10;
    if (selectedCategoryIds.length > 0) score += 10;
    if (applicationLastDate) score += 15;
    if (calculatedTotalVacancies > 0 || posts.length > 0) score += 15;
    if (defaultQualification || posts.some((p) => p.qualification)) score += 15;
    if (applyUrl || officialNotificationUrl) score += 10;
    if (selectionStages.length > 0) score += 10;
    return Math.min(score, 100);
  }, [
    title,
    organization,
    selectedCategoryIds,
    applicationLastDate,
    calculatedTotalVacancies,
    posts,
    defaultQualification,
    applyUrl,
    officialNotificationUrl,
    selectionStages,
  ]);

  // Helper to toggle optional modules in Step 2
  const handleToggleOptionalModule = (type: OptionalModuleType, enable: boolean) => {
    if (enable) {
      setEnabledOptionalModules((prev) => [...prev, type]);
    } else {
      setEnabledOptionalModules((prev) => prev.filter((m) => m !== type));
    }
  };

  // Build Payload
  const buildPayload = (): Partial<ContentItem> => {
    return {
      contentType,
      title: title.trim(),
      slug: slug.trim(),
      excerpt: excerpt.trim(),
      body: body.trim(),
      featuredImageUrl: featuredImageUrl.trim(),

      organization: organization.trim(),
      department: department.trim(),
      jobRole: title.trim(),
      vacancies: String(calculatedTotalVacancies),
      totalVacancies: calculatedTotalVacancies,
      qualification: defaultQualification.trim(),
      minimumQualification: defaultQualification.trim(),
      experienceRequired: defaultExperience.trim(),
      salary: defaultSalaryText.trim(),
      salaryText: defaultSalaryText.trim(),
      payLevel: defaultPayLevel.trim(),
      payScale: defaultPayScale.trim(),
      location: location.trim(),
      jobType: contentType === 'private_job' ? 'private' : 'government',
      jobTypeId: selectedJobTypeId,
      jobTypeName: selectedJobTypeName,
      recruitmentType: recruitmentSubtype,
      recruitmentYear,
      notificationNumber: notificationNumber.trim(),
      advtNumber: advtNumber.trim(),
      defaultMinimumAge: defaultMinAge,
      defaultMaximumAge: defaultMaxAge,
      ageAsOn,
      nationality,
      registrationRequirement,

      // Posts & Vacancies
      vacancyMode: posts.length > 0 ? 'detailed' : 'simple',
      posts,

      // Optional Modules
      enabledOptionalModules,
      ageRelaxations: enabledOptionalModules.includes('age_relaxation') ? ageRelaxations : [],
      physicalStandards: enabledOptionalModules.includes('physical_standards') ? physicalStandards : [],
      petEvents: enabledOptionalModules.includes('pet_pst') ? petEvents : [],
      tradeTests: enabledOptionalModules.includes('trade_test') ? tradeTests : [],
      medicalStandards: enabledOptionalModules.includes('medical_standards') ? medicalStandards : [],
      deputationConditions: enabledOptionalModules.includes('deputation_conditions') ? deputationConditions : {},
      serviceRequirements: enabledOptionalModules.includes('service_requirements') ? serviceRequirements : '',
      reservationNotes: enabledOptionalModules.includes('reservation_notes') ? reservationNotes : [],
      probationPeriod: enabledOptionalModules.includes('probation_training_bond') ? probationPeriod : '',
      trainingPeriod: enabledOptionalModules.includes('probation_training_bond') ? trainingPeriod : '',
      serviceBond: enabledOptionalModules.includes('probation_training_bond') ? serviceBond : '',
      otherConditions: enabledOptionalModules.includes('other_conditions') ? otherConditions : [],

      // Dates & Application
      notificationDate,
      applicationStartDate,
      applicationLastDate,
      feePaymentLastDate,
      correctionStartDate,
      correctionEndDate,
      examDate,
      admitCardDate,
      answerKeyDate,
      resultDate,
      importantDates: customDates,
      applicationMode,
      oneTimeRegistration,
      howToApplySteps,
      applicationFees,
      paymentMethods,
      documents,
      uploadRequirements,

      // Exam & Selection
      hasExamination,
      hasPhysicalTest,
      hasTradeTest,
      hasInterview,
      hasMedicalExam,
      examDetails: hasExamination ? examDetails : undefined,
      examPattern: hasExamination ? examPatternItems : [],
      syllabusTopics: hasExamination ? syllabusTopics : [],
      syllabusPdfUrl: hasExamination ? syllabusPdfUrl : '',
      selectionProcess: selectionStages,
      selectionRules,

      // Links & Verification
      applyUrl: applyUrl.trim(),
      officialNotificationUrl: officialNotificationUrl.trim(),
      officialWebsiteUrl: officialWebsiteUrl.trim(),
      importantLinks: customLinks,
      sourceVerification,

      // Taxonomy & Categories
      categoryIds: selectedCategoryIds,
      categoryNames: selectedCategoryNames,
      tags: tagsText
        .split(',')
        .map((t) => t.trim())
        .filter(Boolean),
      searchKeywords: searchKeywordsText
        .split(',')
        .map((t) => t.trim())
        .filter(Boolean),

      // Publishing & App Controls
      status,
      isPublished: status === 'published',
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

      // Parent Link
      parentRecruitmentId,
      parentRecruitmentTitle,
      companyName,
      island,
      updatedAt: new Date().toISOString(),
    };
  };

  const handleSave = async (targetStatus?: ContentStatus) => {
    if (!title.trim()) {
      alert('Please provide a Title in Step 1 (Basic Details).');
      setCurrentStep('basic_details');
      return;
    }
    if (!organization.trim()) {
      alert('Please provide an Organization in Step 1 (Basic Details).');
      setCurrentStep('basic_details');
      return;
    }

    setIsSaving(true);
    try {
      const payload = buildPayload();
      if (targetStatus) {
        payload.status = targetStatus;
        payload.isPublished = targetStatus === 'published';
      }
      await onSave(payload, allowNotifications && payload.isPublished === true, 'all_jobs');
      setSaveSuccessMessage('Saved successfully!');
      setTimeout(() => setSaveSuccessMessage(''), 3000);
    } catch (err: any) {
      console.error('Failed to save recruitment:', err);
      alert(`Save failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-24">
      {/* 1. STICKY TOP APP BAR */}
      <div className="sticky top-0 z-30 bg-white border-b border-slate-200 px-6 py-3.5 shadow-sm">
        <div className="max-w-7xl mx-auto flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={onCancel}
              className="p-2 hover:bg-slate-100 rounded-lg text-slate-500 transition-colors"
              title="Return to CMS list"
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-xs px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider bg-[#FFF0EB] text-[#FF5A00]">
                  {contentType.replace('_', ' ')}
                </span>
                <span className="text-xs text-slate-400">•</span>
                <span className="text-xs font-semibold text-slate-500">{recruitmentSubtype}</span>
              </div>
              <h1 className="text-lg font-bold text-slate-900 truncate max-w-md sm:max-w-xl">
                {title || 'New Content Entry'}
              </h1>
            </div>
          </div>

          <div className="flex items-center gap-2.5">
            {saveSuccessMessage && (
              <span className="text-xs text-emerald-600 font-bold bg-emerald-50 px-3 py-1.5 rounded-lg border border-emerald-200 animate-pulse flex items-center gap-1">
                <Check className="w-3.5 h-3.5" /> {saveSuccessMessage}
              </span>
            )}
            <AdminButton
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setShowPreviewModal(true)}
              className="text-xs"
            >
              <Eye className="w-4 h-4 mr-1.5 text-slate-500" /> Preview
            </AdminButton>
            <AdminButton
              type="button"
              variant="secondary"
              size="sm"
              loading={isSaving}
              onClick={() => handleSave('draft')}
              className="text-xs"
            >
              <Save className="w-4 h-4 mr-1.5" /> Save Draft
            </AdminButton>
            <AdminButton
              type="button"
              variant="primary"
              size="sm"
              loading={isSaving}
              onClick={() => handleSave('published')}
              className="text-xs bg-[#FF5A00] hover:bg-[#E04E00]"
            >
              <Send className="w-4 h-4 mr-1.5" /> Publish
            </AdminButton>
          </div>
        </div>
      </div>

      {/* 2. MAIN 6-STEP WORKSPACE */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 pt-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          {/* A. STICKY LEFT STEP NAVIGATOR */}
          <div className="lg:col-span-3 sticky top-20 bg-white border border-slate-200 rounded-2xl p-3 shadow-sm space-y-1">
            <div className="px-3 py-2 border-b border-slate-100 mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                Workflow Steps (6)
              </span>
              <div className="flex items-center justify-between mt-1">
                <span className="text-xs font-semibold text-slate-700">Completeness</span>
                <span className="text-xs font-bold text-[#FF5A00]">{completenessScore}%</span>
              </div>
              <div className="w-full h-1.5 bg-slate-100 rounded-full mt-1.5 overflow-hidden">
                <div
                  className="h-full bg-[#FF5A00] transition-all duration-300 rounded-full"
                  style={{ width: `${completenessScore}%` }}
                />
              </div>
            </div>

            {UNIVERSAL_STEPS.map((step) => {
              const Icon = step.icon;
              const isActive = currentStep === step.id;

              return (
                <button
                  key={step.id}
                  type="button"
                  onClick={() => setCurrentStep(step.id)}
                  className={`w-full text-left p-3 rounded-xl transition-all flex items-start gap-3 ${
                    isActive
                      ? 'bg-[#FFF0EB] text-[#FF5A00] font-bold shadow-xs border border-[#FFD8CC]'
                      : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900 font-medium'
                  }`}
                >
                  <div
                    className={`w-7 h-7 rounded-lg flex items-center justify-center shrink-0 text-xs font-bold ${
                      isActive
                        ? 'bg-[#FF5A00] text-white shadow-sm'
                        : 'bg-slate-100 text-slate-500'
                    }`}
                  >
                    {step.stepNumber}
                  </div>
                  <div className="min-w-0">
                    <div className="text-sm truncate leading-tight">{step.label}</div>
                    <div
                      className={`text-[11px] truncate mt-0.5 ${
                        isActive ? 'text-[#FF5A00]/80' : 'text-slate-400'
                      }`}
                    >
                      {step.description}
                    </div>
                  </div>
                </button>
              );
            })}
          </div>

          {/* B. ACTIVE STEP WORKSPACE */}
          <div className="lg:col-span-9 space-y-6">
            {/* =============================================================== */}
            {/* STEP 1: BASIC DETAILS */}
            {/* =============================================================== */}
            {currentStep === 'basic_details' && (
              <div className="space-y-6">
                <AdminCard
                  title="1. Content Type & Subtype"
                  subtitle="Select the classification and nature of this publication"
                >
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-slate-600 mb-1">
                        Content Type *
                      </label>
                      <select
                        value={contentType}
                        onChange={(e) => setContentType(e.target.value as ContentType)}
                        className="w-full text-sm px-3 py-2.5 bg-white border border-slate-300 rounded-xl font-semibold text-slate-800 focus:ring-2 focus:ring-[#FF5A00]"
                      >
                        <option value="government_job">Government Job (All India)</option>
                        <option value="andaman_job">Andaman & Nicobar Islands Job</option>
                        <option value="private_job">Private Job Vacancy</option>
                        <option value="admit_card">Admit Card / Hall Ticket</option>
                        <option value="result">Result / Merit List</option>
                        <option value="answer_key">Answer Key / Objection Key</option>
                        <option value="syllabus">Syllabus & Exam Pattern</option>
                        <option value="article">Article / Preparation Guide</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-600 mb-1">
                        Recruitment Subtype *
                      </label>
                      <select
                        value={recruitmentSubtype}
                        onChange={(e) => setRecruitmentSubtype(e.target.value)}
                        className="w-full text-sm px-3 py-2.5 bg-white border border-slate-300 rounded-xl font-semibold text-slate-800 focus:ring-2 focus:ring-[#FF5A00]"
                      >
                        <option value="Government Regular">Government Regular / Permanent</option>
                        <option value="A&N Government">A&N Government Local</option>
                        <option value="Private">Private / Corporate</option>
                        <option value="Deputation">Deputation Basis</option>
                        <option value="Contractual">Contractual / Project</option>
                        <option value="Temporary">Temporary / Ad-hoc</option>
                        <option value="Apprenticeship">Apprenticeship</option>
                        <option value="Walk-in">Walk-in Interview</option>
                        <option value="Other">Other Category</option>
                      </select>
                    </div>
                  </div>

                  {/* Related Recruitment selector if not a root job */}
                  {!isJobType && (
                    <div className="mt-4 pt-4 border-t border-slate-100">
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
                    </div>
                  )}
                </AdminCard>

                <AdminCard
                  title="2. Notification Metadata"
                  subtitle="Primary titles, issuing authority, and reference numbers"
                >
                  <div className="space-y-4">
                    <AdminInput
                      label="Title *"
                      placeholder="e.g. Assam Rifles Technical & Tradesman Recruitment Rally 2026"
                      value={title}
                      onChange={(e) => setTitle(e.target.value)}
                    />

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <AdminInput
                        label="Organization / Authority *"
                        placeholder="e.g. Office of the Directorate General Assam Rifles"
                        value={organization}
                        onChange={(e) => setOrganization(e.target.value)}
                      />
                      <AdminInput
                        label="Department / Ministry"
                        placeholder="e.g. Ministry of Home Affairs"
                        value={department}
                        onChange={(e) => setDepartment(e.target.value)}
                      />
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                      <AdminInput
                        label="Notification / Circular No"
                        placeholder="e.g. Rec-Branch/2026/354"
                        value={notificationNumber}
                        onChange={(e) => setNotificationNumber(e.target.value)}
                      />
                      <AdminInput
                        label="Advt Number"
                        placeholder="e.g. Advt No. 04/2026"
                        value={advtNumber}
                        onChange={(e) => setAdvtNumber(e.target.value)}
                      />
                      <AdminInput
                        label="Recruitment Year"
                        placeholder="2026"
                        value={recruitmentYear}
                        onChange={(e) => setRecruitmentYear(e.target.value)}
                      />
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <AdminInput
                        label="Job Location"
                        placeholder="e.g. Across India / Port Blair"
                        value={location}
                        onChange={(e) => setLocation(e.target.value)}
                      />
                      <AdminInput
                        label="Employment Type"
                        placeholder="e.g. Full Time, Regular"
                        value={employmentType}
                        onChange={(e) => setEmploymentType(e.target.value)}
                      />
                    </div>

                    <AdminInput
                      label="Short Summary (Excerpt)"
                      placeholder="Concise overview shown in app feeds and notification previews..."
                      value={excerpt}
                      onChange={(e) => setExcerpt(e.target.value)}
                    />

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <AdminInput
                        label="Tags (Comma separated)"
                        placeholder="defence, tradesman, 10th pass, it"
                        value={tagsText}
                        onChange={(e) => setTagsText(e.target.value)}
                      />
                      <AdminInput
                        label="URL Slug (Auto-generated)"
                        placeholder="assam-rifles-technical-tradesman-2026"
                        value={slug}
                        onChange={(e) => {
                          setIsSlugManual(true);
                          setSlug(e.target.value);
                        }}
                      />
                    </div>

                    <AdminInput
                      label="Featured Image / Header Banner URL (Optional)"
                      placeholder="https://..."
                      value={featuredImageUrl}
                      onChange={(e) => setFeaturedImageUrl(e.target.value)}
                    />
                  </div>
                </AdminCard>

                <AdminCard
                  title="3. Category Assignment"
                  subtitle="Select categories where this publication should appear"
                >
                  <AdminCategorySelector
                    categories={categories}
                    selectedCategoryIds={selectedCategoryIds}
                    onChange={(ids, names) => {
                      setSelectedCategoryIds(ids);
                      setSelectedCategoryNames(names);
                    }}
                  />
                </AdminCard>

                {/* Step navigation bottom bar */}
                <div className="flex justify-end pt-2">
                  <AdminButton
                    type="button"
                    variant="primary"
                    onClick={() => setCurrentStep('vacancy_eligibility')}
                    className="bg-[#FF5A00] hover:bg-[#E04E00]"
                  >
                    Next: Vacancy & Eligibility <ArrowRight className="w-4 h-4 ml-1.5" />
                  </AdminButton>
                </div>
              </div>
            )}

            {/* =============================================================== */}
            {/* STEP 2: VACANCY & ELIGIBILITY */}
            {/* =============================================================== */}
            {currentStep === 'vacancy_eligibility' && (
              <div className="space-y-6">
                {isJobType ? (
                  <>
                    {/* Default Inheritance Values Banner */}
                    <AdminCard
                      title="1. Recruitment-Level Defaults (Inheritance)"
                      subtitle="Values entered here automatically apply across all posts unless specifically overridden"
                    >
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <AdminInput
                          label="Default Minimum Qualification"
                          placeholder="e.g. 10th Pass / B.Sc / Any Degree"
                          value={defaultQualification}
                          onChange={(e) => setDefaultQualification(e.target.value)}
                        />
                        <AdminInput
                          label="Default Experience Required"
                          placeholder="e.g. Freshers eligible / 2 years relevant experience"
                          value={defaultExperience}
                          onChange={(e) => setDefaultExperience(e.target.value)}
                        />
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-4">
                        <AdminInput
                          label="Default Min Age"
                          placeholder="18"
                          value={String(defaultMinAge)}
                          onChange={(e) => setDefaultMinAge(e.target.value)}
                        />
                        <AdminInput
                          label="Default Max Age"
                          placeholder="33"
                          value={String(defaultMaxAge)}
                          onChange={(e) => setDefaultMaxAge(e.target.value)}
                        />
                        <AdminInput
                          label="Age As On Date"
                          placeholder="e.g. 01/01/2026"
                          value={ageAsOn}
                          onChange={(e) => setAgeAsOn(e.target.value)}
                        />
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-4">
                        <AdminInput
                          label="Pay Level"
                          placeholder="e.g. Level-7"
                          value={defaultPayLevel}
                          onChange={(e) => setDefaultPayLevel(e.target.value)}
                        />
                        <AdminInput
                          label="Pay Scale"
                          placeholder="e.g. ₹44,900 - ₹1,42,400"
                          value={defaultPayScale}
                          onChange={(e) => setDefaultPayScale(e.target.value)}
                        />
                        <AdminInput
                          label="Salary Note / Range"
                          placeholder="e.g. Approx ₹65,000/- Gross"
                          value={defaultSalaryText}
                          onChange={(e) => setDefaultSalaryText(e.target.value)}
                        />
                      </div>
                    </AdminCard>

                    {/* Post & Trade Vacancy Builder */}
                    <AdminCard
                      title="2. Post & Trade Vacancies Builder"
                      subtitle="Add individual designations, trades, and category-wise breakdowns. Vacancy totals calculate automatically."
                    >
                      <PostVacancyBuilder
                        mode={vacancyMode}
                        onModeChange={(newMode) => setVacancyMode(newMode)}
                        posts={posts}
                        onPostsChange={(updatedPosts: PostItem[]) => setPosts(updatedPosts)}
                        simpleTotalVacancies={simpleTotalVacancies}
                        onSimpleTotalChange={(total) => setSimpleTotalVacancies(total)}
                        simpleBreakup={{ ur: 0, obc: 0, ews: 0, sc: 0, st: 0, pwbd: 0, other: 0, total: 0 }}
                        onSimpleBreakupChange={() => {}}
                        categories={categories}
                        defaultDepartment={department}
                        defaultLocation={location}
                        defaultPayLevel={defaultPayLevel}
                        defaultQualification={defaultQualification}
                        defaultMinAge={defaultMinAge}
                        defaultMaxAge={defaultMaxAge}
                      />
                    </AdminCard>

                    {/* Extensible Optional Modules */}
                    <AdminCard
                      title="3. Extensible Modular Specifications"
                      subtitle="Add specialized recruitment criteria (Age relaxation, PST/PET standards, Trade tests, Medical DME/RME, Deputation conditions)"
                    >
                      <OptionalModulesBuilder
                        enabledModules={enabledOptionalModules}
                        onToggleModule={handleToggleOptionalModule}
                        ageRelaxations={ageRelaxations}
                        onAgeRelaxationsChange={setAgeRelaxations}
                        physicalStandards={physicalStandards}
                        onPhysicalStandardsChange={setPhysicalStandards}
                        petEvents={petEvents}
                        onPETEventsChange={setPETEvents}
                        tradeTests={tradeTests}
                        onTradeTestsChange={setTradeTests}
                        medicalStandards={medicalStandards}
                        onMedicalStandardsChange={setMedicalStandards}
                        deputationConditions={deputationConditions}
                        onDeputationConditionsChange={setDeputationConditions}
                        serviceRequirements={serviceRequirements}
                        onServiceRequirementsChange={setServiceRequirements}
                        reservationNotes={reservationNotes}
                        onReservationNotesChange={setReservationNotes}
                        probationPeriod={probationPeriod}
                        onProbationPeriodChange={setProbationPeriod}
                        trainingPeriod={trainingPeriod}
                        onTrainingPeriodChange={setTrainingPeriod}
                        serviceBond={serviceBond}
                        onServiceBondChange={setServiceBond}
                        otherConditions={otherConditions}
                        onOtherConditionsChange={setOtherConditions}
                      />
                    </AdminCard>
                  </>
                ) : (
                  /* Compact Type-Specific Editor for Result / Admit Card / Answer Key */
                  <AdminCard
                    title="Type-Specific Details"
                    subtitle={`Enter specifications for ${contentType.replace('_', ' ').toUpperCase()}`}
                  >
                    <div className="p-4 bg-slate-50 rounded-xl space-y-4">
                      <p className="text-xs text-slate-600">
                        This content type is linked to a recruitment and does not require a post/vacancy table.
                      </p>
                      <AdminInput
                        label="Summary Notes"
                        placeholder="Provide details regarding download procedure, release notes or merit cutoffs..."
                        value={excerpt}
                        onChange={(e) => setExcerpt(e.target.value)}
                      />
                    </div>
                  </AdminCard>
                )}

                {/* Step navigation bottom bar */}
                <div className="flex justify-between pt-2">
                  <AdminButton
                    type="button"
                    variant="outline"
                    onClick={() => setCurrentStep('basic_details')}
                  >
                    <ArrowLeft className="w-4 h-4 mr-1.5" /> Back: Basic Details
                  </AdminButton>
                  <AdminButton
                    type="button"
                    variant="primary"
                    onClick={() => setCurrentStep('dates_application')}
                    className="bg-[#FF5A00] hover:bg-[#E04E00]"
                  >
                    Next: Dates & Application <ArrowRight className="w-4 h-4 ml-1.5" />
                  </AdminButton>
                </div>
              </div>
            )}

            {/* =============================================================== */}
            {/* STEP 3: DATES & APPLICATION */}
            {/* =============================================================== */}
            {currentStep === 'dates_application' && (
              <div className="space-y-6">
                <AdminCard
                  title="1. Important Dates"
                  subtitle="Canonical recruitment schedule. Stored as structured milestones."
                >
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    <AdminInput
                      label="Notification Published Date"
                      placeholder="e.g. 15/02/2026"
                      value={notificationDate}
                      onChange={(e) => setNotificationDate(e.target.value)}
                    />
                    <AdminInput
                      label="Application Start Date"
                      placeholder="e.g. 20/02/2026"
                      value={applicationStartDate}
                      onChange={(e) => setApplicationStartDate(e.target.value)}
                    />
                    <AdminInput
                      label="Application Last Date *"
                      placeholder="e.g. 20/03/2026"
                      value={applicationLastDate}
                      onChange={(e) => setApplicationLastDate(e.target.value)}
                    />
                    <AdminInput
                      label="Fee Payment Last Date"
                      placeholder="e.g. 22/03/2026"
                      value={feePaymentLastDate}
                      onChange={(e) => setFeePaymentLastDate(e.target.value)}
                    />
                    <AdminInput
                      label="Correction Window"
                      placeholder="e.g. 25/03/2026 to 28/03/2026"
                      value={correctionStartDate ? `${correctionStartDate} - ${correctionEndDate}` : ''}
                      onChange={(e) => setCorrectionStartDate(e.target.value)}
                    />
                    <AdminInput
                      label="Exam Date"
                      placeholder="e.g. May 2026 / TBA"
                      value={examDate}
                      onChange={(e) => setExamDate(e.target.value)}
                    />
                    <AdminInput
                      label="Admit Card Release Date"
                      placeholder="e.g. 10 Days before Exam"
                      value={admitCardDate}
                      onChange={(e) => setAdmitCardDate(e.target.value)}
                    />
                    <AdminInput
                      label="Answer Key Date"
                      placeholder="e.g. Tentative / TBA"
                      value={answerKeyDate}
                      onChange={(e) => setAnswerKeyDate(e.target.value)}
                    />
                    <AdminInput
                      label="Result Date"
                      placeholder="e.g. June 2026"
                      value={resultDate}
                      onChange={(e) => setResultDate(e.target.value)}
                    />
                  </div>

                  {/* Custom Dates Repeater */}
                  <div className="mt-4 pt-4 border-t border-slate-100 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-bold text-slate-700">
                        Custom Schedule Milestones
                      </span>
                      <AdminButton
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() =>
                          setCustomDates([
                            ...customDates,
                            { id: `dt-${Date.now()}`, label: '', date: '', isTentative: false },
                          ])
                        }
                      >
                        <Plus className="w-3.5 h-3.5 mr-1" /> Add Custom Date
                      </AdminButton>
                    </div>

                    {customDates.map((cd, idx) => (
                      <div key={cd.id || idx} className="flex items-center gap-2">
                        <AdminInput
                          label=""
                          placeholder="Milestone (e.g. Physical Rally Date)"
                          value={cd.label}
                          onChange={(e) => {
                            const updated = [...customDates];
                            updated[idx] = { ...updated[idx], label: e.target.value };
                            setCustomDates(updated);
                          }}
                        />
                        <AdminInput
                          label=""
                          placeholder="Date (e.g. 01/05/2026 / TBA)"
                          value={cd.date}
                          onChange={(e) => {
                            const updated = [...customDates];
                            updated[idx] = { ...updated[idx], date: e.target.value };
                            setCustomDates(updated);
                          }}
                        />
                        <button
                          type="button"
                          onClick={() => setCustomDates(customDates.filter((_, i) => i !== idx))}
                          className="p-2 text-slate-400 hover:text-red-500 rounded"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                </AdminCard>

                <AdminCard
                  title="2. How to Apply & Process"
                  subtitle="Application mode, sequential steps, and instructions"
                >
                  <div className="space-y-4">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-semibold text-slate-600 mb-1">
                          Application Mode
                        </label>
                        <select
                          value={applicationMode}
                          onChange={(e) => setApplicationMode(e.target.value)}
                          className="w-full text-sm px-3 py-2 bg-white border border-slate-300 rounded-lg"
                        >
                          <option value="Online">Online Application Portal</option>
                          <option value="Offline / Postal">Offline / Postal Application</option>
                          <option value="Walk-in">Walk-in Registration</option>
                          <option value="Email">Email Submission</option>
                        </select>
                      </div>

                      <div className="flex items-center gap-2 pt-6">
                        <input
                          type="checkbox"
                          id="otr"
                          checked={oneTimeRegistration}
                          onChange={(e) => setOneTimeRegistration(e.target.checked)}
                          className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                        />
                        <label htmlFor="otr" className="text-xs font-semibold text-slate-700">
                          One-Time Registration (OTR) Required
                        </label>
                      </div>
                    </div>

                    {/* How to apply ordered steps */}
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <label className="text-xs font-bold text-slate-700">
                          Sequential Application Steps
                        </label>
                        <AdminButton
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => setHowToApplySteps([...howToApplySteps, ''])}
                        >
                          <Plus className="w-3.5 h-3.5 mr-1" /> Add Step
                        </AdminButton>
                      </div>
                      <div className="space-y-2">
                        {howToApplySteps.map((step, idx) => (
                          <div key={idx} className="flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-slate-100 text-slate-600 text-xs font-bold flex items-center justify-center shrink-0">
                              {idx + 1}
                            </span>
                            <input
                              type="text"
                              value={step}
                              placeholder={`Step ${idx + 1} instructions...`}
                              onChange={(e) => {
                                const updated = [...howToApplySteps];
                                updated[idx] = e.target.value;
                                setHowToApplySteps(updated);
                              }}
                              className="flex-1 text-xs px-3 py-2 bg-white border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#FF5A00]"
                            />
                            <button
                              type="button"
                              onClick={() =>
                                setHowToApplySteps(howToApplySteps.filter((_, i) => i !== idx))
                              }
                              className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </AdminCard>

                <AdminCard
                  title="3. Application Fees & Payment"
                  subtitle="Category-wise examination and processing fee breakdown"
                >
                  <div className="space-y-4">
                    <div className="space-y-2">
                      {applicationFees.map((fee, idx) => (
                        <div
                          key={fee.id || idx}
                          className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 items-end p-2.5 bg-slate-50 rounded-lg"
                        >
                          <AdminInput
                            label="Category"
                            placeholder="e.g. General / OBC / SC / ST"
                            value={fee.category}
                            onChange={(e) => {
                              const updated = [...applicationFees];
                              updated[idx] = { ...updated[idx], category: e.target.value };
                              setApplicationFees(updated);
                            }}
                          />
                          <AdminInput
                            label="Fee Amount"
                            placeholder="e.g. ₹100/- or Nil (Exempted)"
                            value={fee.fee}
                            onChange={(e) => {
                              const updated = [...applicationFees];
                              updated[idx] = { ...updated[idx], fee: e.target.value };
                              setApplicationFees(updated);
                            }}
                          />
                          <div className="flex items-center gap-1">
                            <div className="flex-1">
                              <AdminInput
                                label="Exemption Notes"
                                placeholder="e.g. Female candidates exempted"
                                value={fee.notes || ''}
                                onChange={(e) => {
                                  const updated = [...applicationFees];
                                  updated[idx] = { ...updated[idx], notes: e.target.value };
                                  setApplicationFees(updated);
                                }}
                              />
                            </div>
                            <button
                              type="button"
                              onClick={() =>
                                setApplicationFees(applicationFees.filter((_, i) => i !== idx))
                              }
                              className="p-2 text-slate-400 hover:text-red-500 rounded"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                    <AdminButton
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={() =>
                        setApplicationFees([
                          ...applicationFees,
                          { id: `fee-${Date.now()}`, category: 'UR / OBC / EWS', fee: '₹100/-' },
                        ])
                      }
                    >
                      <Plus className="w-3.5 h-3.5 mr-1" /> Add Fee Row
                    </AdminButton>
                  </div>
                </AdminCard>

                {/* Step navigation bottom bar */}
                <div className="flex justify-between pt-2">
                  <AdminButton
                    type="button"
                    variant="outline"
                    onClick={() => setCurrentStep('vacancy_eligibility')}
                  >
                    <ArrowLeft className="w-4 h-4 mr-1.5" /> Back: Vacancy & Eligibility
                  </AdminButton>
                  <AdminButton
                    type="button"
                    variant="primary"
                    onClick={() => setCurrentStep('exam_selection')}
                    className="bg-[#FF5A00] hover:bg-[#E04E00]"
                  >
                    Next: Exam & Selection <ArrowRight className="w-4 h-4 ml-1.5" />
                  </AdminButton>
                </div>
              </div>
            )}

            {/* =============================================================== */}
            {/* STEP 4: EXAM & SELECTION */}
            {/* =============================================================== */}
            {currentStep === 'exam_selection' && (
              <div className="space-y-6">
                {/* Smart Stage Activation Toggles */}
                <AdminCard
                  title="1. Selection Process Architecture"
                  subtitle="Activate the assessment stages applicable to this recruitment"
                >
                  <div className="grid grid-cols-2 sm:grid-cols-5 gap-3 p-3 bg-slate-50 rounded-xl border border-slate-200">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={hasExamination}
                        onChange={(e) => setHasExamination(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-700">Written / CBT</span>
                    </label>

                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={hasPhysicalTest}
                        onChange={(e) => setHasPhysicalTest(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-700">Physical (PET/PST)</span>
                    </label>

                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={hasTradeTest}
                        onChange={(e) => setHasTradeTest(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-700">Trade / Skill Test</span>
                    </label>

                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={hasInterview}
                        onChange={(e) => setHasInterview(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-700">Interview / Viva</span>
                    </label>

                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={hasMedicalExam}
                        onChange={(e) => setHasMedicalExam(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-700">Medical (DME/RME)</span>
                    </label>
                  </div>

                  {/* Sequential Selection Stages Repeater */}
                  <div className="mt-5 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-bold text-slate-700">
                        Sequential Selection Stages
                      </span>
                      <AdminButton
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() =>
                          setSelectionStages([
                            ...selectionStages,
                            {
                              id: `stg-${Date.now()}`,
                              stageNumber: selectionStages.length + 1,
                              name: '',
                              description: '',
                              mandatory: true,
                            },
                          ])
                        }
                      >
                        <Plus className="w-3.5 h-3.5 mr-1" /> Add Stage
                      </AdminButton>
                    </div>

                    {selectionStages.map((stage, idx) => (
                      <div
                        key={stage.id || idx}
                        className="flex items-center gap-2 p-2.5 bg-white border border-slate-200 rounded-lg shadow-xs"
                      >
                        <span className="w-6 h-6 rounded-full bg-slate-100 text-slate-700 font-bold text-xs flex items-center justify-center shrink-0">
                          {idx + 1}
                        </span>
                        <input
                          type="text"
                          placeholder="Stage Name (e.g. Physical Standard Test)"
                          value={stage.name}
                          onChange={(e) => {
                            const updated = [...selectionStages];
                            updated[idx] = { ...updated[idx], name: e.target.value };
                            setSelectionStages(updated);
                          }}
                          className="w-1/3 text-xs px-2.5 py-1.5 border border-slate-300 rounded"
                        />
                        <input
                          type="text"
                          placeholder="Stage description and qualifying standard..."
                          value={stage.description}
                          onChange={(e) => {
                            const updated = [...selectionStages];
                            updated[idx] = { ...updated[idx], description: e.target.value };
                            setSelectionStages(updated);
                          }}
                          className="flex-1 text-xs px-2.5 py-1.5 border border-slate-300 rounded"
                        />
                        <button
                          type="button"
                          onClick={() =>
                            setSelectionStages(selectionStages.filter((_, i) => i !== idx))
                          }
                          className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                </AdminCard>

                {/* Exam Details & Pattern (Conditional on hasExamination) */}
                {hasExamination && (
                  <AdminCard
                    title="2. Examination Details & Pattern"
                    subtitle="Mode, duration, marking scheme, and subject-wise question distribution"
                  >
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
                      <AdminInput
                        label="Exam Mode"
                        placeholder="e.g. Computer Based Test (CBT) / OMR"
                        value={examDetails.examMode || ''}
                        onChange={(e) =>
                          setExamDetails({ ...examDetails, examMode: e.target.value })
                        }
                      />
                      <AdminInput
                        label="Total Duration"
                        placeholder="e.g. 120 Minutes (2 Hours)"
                        value={examDetails.examDuration || ''}
                        onChange={(e) =>
                          setExamDetails({ ...examDetails, examDuration: e.target.value })
                        }
                      />
                      <AdminInput
                        label="Negative Marking"
                        placeholder="e.g. 0.25 marks per wrong answer"
                        value={examDetails.negativeMarking || ''}
                        onChange={(e) =>
                          setExamDetails({ ...examDetails, negativeMarking: e.target.value })
                        }
                      />
                    </div>

                    {/* Exam Pattern Table */}
                    <div className="space-y-3 pt-2 border-t border-slate-100">
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-bold text-slate-700">Exam Pattern Table</span>
                        <AdminButton
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() =>
                            setExamPatternItems([
                              ...examPatternItems,
                              {
                                id: `pat-${Date.now()}`,
                                paperName: 'Part-A',
                                subject: 'General Knowledge',
                                questions: 25,
                                marks: 25,
                                duration: '30 Mins',
                              },
                            ])
                          }
                        >
                          <Plus className="w-3.5 h-3.5 mr-1" /> Add Paper / Subject
                        </AdminButton>
                      </div>

                      {examPatternItems.map((pat, idx) => (
                        <div
                          key={pat.id || idx}
                          className="grid grid-cols-2 sm:grid-cols-5 gap-2 items-end p-2 bg-slate-50 rounded-lg text-xs"
                        >
                          <AdminInput
                            label="Paper / Section"
                            placeholder="Part-A"
                            value={pat.paperName}
                            onChange={(e) => {
                              const updated = [...examPatternItems];
                              updated[idx] = { ...updated[idx], paperName: e.target.value };
                              setExamPatternItems(updated);
                            }}
                          />
                          <AdminInput
                            label="Subject"
                            placeholder="General Awareness"
                            value={pat.subject}
                            onChange={(e) => {
                              const updated = [...examPatternItems];
                              updated[idx] = { ...updated[idx], subject: e.target.value };
                              setExamPatternItems(updated);
                            }}
                          />
                          <AdminInput
                            label="Questions"
                            placeholder="25"
                            value={String(pat.questions)}
                            onChange={(e) => {
                              const updated = [...examPatternItems];
                              updated[idx] = { ...updated[idx], questions: Number(e.target.value) || 0 };
                              setExamPatternItems(updated);
                            }}
                          />
                          <AdminInput
                            label="Marks"
                            placeholder="25"
                            value={String(pat.marks)}
                            onChange={(e) => {
                              const updated = [...examPatternItems];
                              updated[idx] = { ...updated[idx], marks: Number(e.target.value) || 0 };
                              setExamPatternItems(updated);
                            }}
                          />
                          <div className="flex items-center gap-1">
                            <div className="flex-1">
                              <AdminInput
                                label="Duration / Notes"
                                placeholder="Optional"
                                value={pat.duration || ''}
                                onChange={(e) => {
                                  const updated = [...examPatternItems];
                                  updated[idx] = { ...updated[idx], duration: e.target.value };
                                  setExamPatternItems(updated);
                                }}
                              />
                            </div>
                            <button
                              type="button"
                              onClick={() =>
                                setExamPatternItems(examPatternItems.filter((_, i) => i !== idx))
                              }
                              className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  </AdminCard>
                )}

                {/* Step navigation bottom bar */}
                <div className="flex justify-between pt-2">
                  <AdminButton
                    type="button"
                    variant="outline"
                    onClick={() => setCurrentStep('dates_application')}
                  >
                    <ArrowLeft className="w-4 h-4 mr-1.5" /> Back: Dates & Application
                  </AdminButton>
                  <AdminButton
                    type="button"
                    variant="primary"
                    onClick={() => setCurrentStep('content_links')}
                    className="bg-[#FF5A00] hover:bg-[#E04E00]"
                  >
                    Next: Content & Links <ArrowRight className="w-4 h-4 ml-1.5" />
                  </AdminButton>
                </div>
              </div>
            )}

            {/* =============================================================== */}
            {/* STEP 5: CONTENT & OFFICIAL LINKS */}
            {/* =============================================================== */}
            {currentStep === 'content_links' && (
              <div className="space-y-6">
                <AdminCard
                  title="1. Supplementary Overview & Instructions"
                  subtitle="Detailed instructions or additional guidelines. Structured dates, eligibility, and fees are automatically formatted and do not need repeating here."
                >
                  <textarea
                    rows={6}
                    placeholder="Enter supplementary recruitment notes, special terms, or general guidance..."
                    value={body}
                    onChange={(e) => setBody(e.target.value)}
                    className="w-full text-xs p-3 bg-white border border-slate-300 rounded-xl focus:ring-2 focus:ring-[#FF5A00]"
                  />
                </AdminCard>

                <AdminCard
                  title="2. Official Direct Links"
                  subtitle="Authoritative external portals. All links are strictly validated."
                >
                  <div className="space-y-4">
                    <AdminInput
                      label="Apply Online URL"
                      placeholder="https://..."
                      value={applyUrl}
                      onChange={(e) => setApplyUrl(e.target.value)}
                    />
                    <AdminInput
                      label="Official Notification PDF URL"
                      placeholder="https://..."
                      value={officialNotificationUrl}
                      onChange={(e) => setOfficialNotificationUrl(e.target.value)}
                    />
                    <AdminInput
                      label="Official Department Website URL"
                      placeholder="https://..."
                      value={officialWebsiteUrl}
                      onChange={(e) => setOfficialWebsiteUrl(e.target.value)}
                    />
                  </div>
                </AdminCard>

                <AdminCard
                  title="3. Source Verification & Editorial Notice"
                  subtitle="Authoritative source information ensuring candidate trust and transparency"
                >
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <AdminInput
                      label="Issuing Authority"
                      value={sourceVerification.sourceOrg || organization}
                      onChange={(e) =>
                        setSourceVerification({ ...sourceVerification, sourceOrg: e.target.value })
                      }
                    />
                    <AdminInput
                      label="Official Circular / Reference No"
                      value={sourceVerification.notificationNumber || notificationNumber}
                      onChange={(e) =>
                        setSourceVerification({
                          ...sourceVerification,
                          notificationNumber: e.target.value,
                        })
                      }
                    />
                  </div>

                  <div className="p-3 bg-amber-50 border border-amber-200 rounded-xl mt-4 flex items-start gap-2.5">
                    <Shield className="w-4 h-4 text-amber-600 mt-0.5 shrink-0" />
                    <p className="text-xs text-amber-800 leading-relaxed">
                      <strong>Editorial Notice:</strong> Notify Jobs is an independent exam & recruitment curator. All verified notices carry the label <em>"Reviewed by Notify Jobs"</em> with direct links to the official department source.
                    </p>
                  </div>
                </AdminCard>

                {/* Step navigation bottom bar */}
                <div className="flex justify-between pt-2">
                  <AdminButton
                    type="button"
                    variant="outline"
                    onClick={() => setCurrentStep('exam_selection')}
                  >
                    <ArrowLeft className="w-4 h-4 mr-1.5" /> Back: Exam & Selection
                  </AdminButton>
                  <AdminButton
                    type="button"
                    variant="primary"
                    onClick={() => setCurrentStep('publish_display')}
                    className="bg-[#FF5A00] hover:bg-[#E04E00]"
                  >
                    Next: Publish & App Display <ArrowRight className="w-4 h-4 ml-1.5" />
                  </AdminButton>
                </div>
              </div>
            )}

            {/* =============================================================== */}
            {/* STEP 6: PUBLISH & APP DISPLAY */}
            {/* =============================================================== */}
            {currentStep === 'publish_display' && (
              <div className="space-y-6">
                <AdminCard
                  title="1. Publication Lifecycle"
                  subtitle="Set current status and user-facing visibility"
                >
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                    {(['draft', 'scheduled', 'published', 'archived'] as ContentStatus[]).map(
                      (st) => (
                        <button
                          key={st}
                          type="button"
                          onClick={() => setStatus(st)}
                          className={`p-3 rounded-xl border text-center transition-all ${
                            status === st
                              ? 'bg-[#FFF0EB] border-[#FF5A00] text-[#FF5A00] font-bold shadow-xs'
                              : 'bg-white border-slate-200 text-slate-600 hover:border-slate-300'
                          }`}
                        >
                          <span className="capitalize text-xs">{st}</span>
                        </button>
                      )
                    )}
                  </div>
                </AdminCard>

                {/* Content Placement & Kill Switches */}
                <AdminCard
                  title="2. App Feeds & Placement Controls"
                  subtitle="Remote switches controlling where this content appears in the mobile app"
                >
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                    <label className="flex items-center gap-2 p-2.5 bg-slate-50 rounded-lg cursor-pointer">
                      <input
                        type="checkbox"
                        checked={showInUserApp}
                        onChange={(e) => setShowInUserApp(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-800">
                        Show in User App (Kill Switch)
                      </span>
                    </label>

                    <label className="flex items-center gap-2 p-2.5 bg-slate-50 rounded-lg cursor-pointer">
                      <input
                        type="checkbox"
                        checked={showOnHome}
                        onChange={(e) => setShowOnHome(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-800">Show on Home</span>
                    </label>

                    <label className="flex items-center gap-2 p-2.5 bg-slate-50 rounded-lg cursor-pointer">
                      <input
                        type="checkbox"
                        checked={featured}
                        onChange={(e) => setFeatured(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-800">Featured Highlight</span>
                    </label>

                    <label className="flex items-center gap-2 p-2.5 bg-slate-50 rounded-lg cursor-pointer">
                      <input
                        type="checkbox"
                        checked={urgent}
                        onChange={(e) => setUrgent(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-800">Urgent Alert Badge</span>
                    </label>

                    <label className="flex items-center gap-2 p-2.5 bg-slate-50 rounded-lg cursor-pointer">
                      <input
                        type="checkbox"
                        checked={showInLatestJobs}
                        onChange={(e) => setShowInLatestJobs(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-800">Latest Jobs Feed</span>
                    </label>

                    <label className="flex items-center gap-2 p-2.5 bg-slate-50 rounded-lg cursor-pointer">
                      <input
                        type="checkbox"
                        checked={showInSearch}
                        onChange={(e) => setShowInSearch(e.target.checked)}
                        className="w-4 h-4 text-[#FF5A00] rounded focus:ring-[#FF5A00]"
                      />
                      <span className="text-xs font-semibold text-slate-800">Searchable</span>
                    </label>
                  </div>
                </AdminCard>

                {/* DYNAMIC APP SECTION CONTROLS (Only populated modules) */}
                <AdminCard
                  title="3. Dynamic App Section Controls"
                  subtitle="Sections generated dynamically from data present in this entry. Empty sections are omitted."
                >
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2.5">
                    {populatedModules.hasDates && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Important Dates</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showImportantDates ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showImportantDates: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasPosts && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Post Vacancies</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showPosts ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showPosts: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasQualification && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Eligibility / Qualification</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showQualification ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showQualification: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasAgeLimit && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Age Limit & Relaxation</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showAgeLimit ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showAgeLimit: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasFees && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Application Fees</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showFees ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showFees: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasSalary && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Salary / Pay Level</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showSalary ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showSalary: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasPhysicalStandards && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Physical Standards (PST)</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showPhysicalStandards ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showPhysicalStandards: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasPETPST && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">PET Requirements</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showPETPST ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showPETPST: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasExam && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Exam Details & Pattern</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showExamPattern ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showExamPattern: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasSelection && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Selection Stages</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showSelectionProcess ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showSelectionProcess: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}

                    {populatedModules.hasLinks && (
                      <label className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
                        <span className="text-xs font-medium text-slate-700">Official Links</span>
                        <input
                          type="checkbox"
                          checked={appDisplayControls.showImportantLinks ?? true}
                          onChange={(e) =>
                            setAppDisplayControls({
                              ...appDisplayControls,
                              showImportantLinks: e.target.checked,
                            })
                          }
                          className="w-4 h-4 text-[#FF5A00] rounded"
                        />
                      </label>
                    )}
                  </div>
                </AdminCard>

                {/* Final Action Bar */}
                <div className="flex items-center justify-between p-4 bg-white border border-slate-200 rounded-2xl shadow-sm">
                  <AdminButton
                    type="button"
                    variant="outline"
                    onClick={() => setCurrentStep('content_links')}
                  >
                    <ArrowLeft className="w-4 h-4 mr-1.5" /> Back: Content & Links
                  </AdminButton>

                  <div className="flex items-center gap-3">
                    <AdminButton
                      type="button"
                      variant="secondary"
                      loading={isSaving}
                      onClick={() => handleSave('draft')}
                    >
                      <Save className="w-4 h-4 mr-1.5" /> Save Draft
                    </AdminButton>
                    <AdminButton
                      type="button"
                      variant="primary"
                      loading={isSaving}
                      onClick={() => handleSave('published')}
                      className="bg-[#FF5A00] hover:bg-[#E04E00]"
                    >
                      <Send className="w-4 h-4 mr-1.5" /> Publish to Live App
                    </AdminButton>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* 3. LIVE MOBILE PREVIEW MODAL */}
      {showPreviewModal && (
        <MobilePreviewModal
          isOpen={showPreviewModal}
          item={buildPayload() as ContentItem}
          onClose={() => setShowPreviewModal(false)}
        />
      )}
    </div>
  );
};
