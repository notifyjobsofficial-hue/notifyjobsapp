import React, { useState, useEffect } from 'react';
import {
  Save,
  Send,
  Eye,
  ArrowLeft,
  AlertTriangle,
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
  MessageSquare
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
} from '../types';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';
import { AdminButton } from '../components/common/AdminButton';
import { AdminCard } from '../components/common/AdminCard';
import { AdminRepeater } from '../components/common/AdminRepeater';
import { MobilePreviewModal } from '../components/preview/MobilePreviewModal';
import { AdminModal } from '../components/common/AdminModal';

interface ContentEditorPageProps {
  initialItem?: ContentItem | null;
  categories: Category[];
  userEmail: string;
  onSave: (item: Partial<ContentItem>, sendPush: boolean, pushTopic: string) => Promise<void>;
  onCancel: () => void;
}

export const ContentEditorPage: React.FC<ContentEditorPageProps> = ({
  initialItem,
  categories,
  userEmail,
  onSave,
  onCancel,
}) => {
  const isEditing = Boolean(initialItem?.id);

  // Form State
  const [contentType, setContentType] = useState<ContentType>(
    initialItem?.contentType || 'government_job'
  );
  const [jobType, setJobType] = useState<JobType>(
    (initialItem?.jobType as JobType) || (contentType === 'private_job' ? 'private' : 'government')
  );
  const [showInLiveUpdates, setShowInLiveUpdates] = useState(
    initialItem?.showInLiveUpdates || false
  );

  const [title, setTitle] = useState(initialItem?.title || '');
  const [slug, setSlug] = useState(initialItem?.slug || '');
  const [excerpt, setExcerpt] = useState(initialItem?.excerpt || '');
  const [body, setBody] = useState(initialItem?.body || '');
  const [featuredImageUrl, setFeaturedImageUrl] = useState(initialItem?.featuredImageUrl || '');

  // Government / General Job specifics
  const [organization, setOrganization] = useState(initialItem?.organization || '');
  const [department, setDepartment] = useState(initialItem?.department || '');
  const [jobRole, setJobRole] = useState(initialItem?.jobRole || '');
  const [vacancies, setVacancies] = useState(initialItem?.vacancies || '');
  const [qualification, setQualification] = useState(initialItem?.qualification || '');
  const [salary, setSalary] = useState(initialItem?.salary || '');
  const [location, setLocation] = useState(initialItem?.location || 'All India');

  // Private / Andaman specifics
  const [companyName, setCompanyName] = useState(initialItem?.companyName || '');
  const [island, setIsland] = useState(initialItem?.island || 'South Andaman (Port Blair)');
  const [salaryRange, setSalaryRange] = useState(initialItem?.salaryRange || '');
  const [experience, setExperience] = useState(initialItem?.experience || '');
  const [skillsText, setSkillsText] = useState(initialItem?.skills?.join(', ') || '');
  const [employmentType, setEmploymentType] = useState(initialItem?.employmentType || 'Full Time');
  const [workingHours, setWorkingHours] = useState(initialItem?.workingHours || '9:00 AM - 5:30 PM');
  const [applicationMethod, setApplicationMethod] = useState(initialItem?.applicationMethod || 'Online / WhatsApp');
  const [contactEmail, setContactEmail] = useState(initialItem?.contactEmail || '');
  const [contactPhone, setContactPhone] = useState(initialItem?.contactPhone || '');
  const [whatsappApplyUrl, setWhatsappApplyUrl] = useState(initialItem?.whatsappApplyUrl || '');
  const [jobDescription, setJobDescription] = useState(initialItem?.jobDescription || '');
  const [requirements, setRequirements] = useState(initialItem?.requirements || '');

  // Dates & Status
  const [applicationStartDate, setApplicationStartDate] = useState(
    initialItem?.applicationStartDate || ''
  );
  const [applicationLastDate, setApplicationLastDate] = useState(
    initialItem?.applicationLastDate || ''
  );
  const [statusOverride, setStatusOverride] = useState<StatusOverride>(
    initialItem?.statusOverride || 'auto'
  );

  // Official links
  const [officialWebsiteUrl, setOfficialWebsiteUrl] = useState(
    initialItem?.officialWebsiteUrl || ''
  );
  const [officialNotificationUrl, setOfficialNotificationUrl] = useState(
    initialItem?.officialNotificationUrl || ''
  );
  const [applyUrl, setApplyUrl] = useState(initialItem?.applyUrl || '');

  // Structured arrays (for Govt jobs & general exams)
  const [importantDates, setImportantDates] = useState<ImportantDateItem[]>(
    initialItem?.importantDates || [
      { id: '1', label: 'Application Start', date: '' },
      { id: '2', label: 'Last Date to Apply', date: '' },
      { id: '3', label: 'Exam Date', date: 'To be announced', isTentative: true },
    ]
  );
  const [vacanciesBreakdown, setVacanciesBreakdown] = useState<VacancyItem[]>(
    initialItem?.vacanciesBreakdown || []
  );
  const [ageLimits, setAgeLimits] = useState<AgeLimitItem[]>(
    initialItem?.ageLimits || []
  );
  const [applicationFees, setApplicationFees] = useState<ApplicationFeeItem[]>(
    initialItem?.applicationFees || []
  );
  const [selectionProcess, setSelectionProcess] = useState<SelectionStepItem[]>(
    initialItem?.selectionProcess || []
  );
  const [examPattern, setExamPattern] = useState<ExamPatternItem[]>(
    initialItem?.examPattern || []
  );
  const [importantLinks, setImportantLinks] = useState<ImportantLinkItem[]>(
    initialItem?.importantLinks || [
      { id: '1', title: 'Apply Online', url: '', type: 'apply_online' },
      { id: '2', title: 'Official Notification PDF', url: '', type: 'official_notification' },
      { id: '3', title: 'Official Website', url: '', type: 'official_website' },
    ]
  );
  const [faqs, setFaqs] = useState<FAQItem[]>(initialItem?.faqs || []);

  // Trust & SEO
  const [sourceOrg, setSourceOrg] = useState(initialItem?.sourceOrg || '');
  const [sourceUrl, setSourceUrl] = useState(initialItem?.sourceUrl || '');
  const [lastVerifiedAt, setLastVerifiedAt] = useState(
    initialItem?.lastVerifiedAt ||
      new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
  );
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<string[]>(
    initialItem?.categoryIds || ['latest-jobs']
  );
  const [status, setStatus] = useState<ContentStatus>(initialItem?.status || 'published');
  const [seoTitle, setSeoTitle] = useState(initialItem?.seoTitle || '');
  const [seoDescription, setSeoDescription] = useState(initialItem?.seoDescription || '');

  // UI States
  const [collapsedSections, setCollapsedSections] = useState<Record<string, boolean>>({});
  const [previewOpen, setPreviewOpen] = useState(false);
  const [publishModalOpen, setPublishModalOpen] = useState(false);
  const [sendPush, setSendPush] = useState(false);
  const [pushTopic, setPushTopic] = useState('all_updates');
  const [saving, setSaving] = useState(false);

  // Auto slug generation from title
  useEffect(() => {
    if (!isEditing && title && !slug) {
      setSlug(
        title
          .toLowerCase()
          .replace(/[^a-z0-9\s-]/g, '')
          .replace(/\s+/g, '-')
          .slice(0, 80)
      );
    }
  }, [title, isEditing, slug]);

  const toggleSection = (sectionId: string) => {
    setCollapsedSections((prev) => ({
      ...prev,
      [sectionId]: !prev[sectionId],
    }));
  };

  // Is this private or government?
  const isPrivate = contentType === 'private_job' || (contentType === 'andaman_job' && jobType === 'private');
  const isGovt = contentType === 'government_job' || (contentType === 'andaman_job' && jobType === 'government');
  const isArticle = contentType === 'article';
  const isExamUpdate = contentType === 'admit_card' || contentType === 'result' || contentType === 'answer_key' || contentType === 'syllabus';

  // Validation Warnings
  const warnings: string[] = [];
  if (!title) warnings.push('Title is missing.');
  if (!isArticle) {
    if (isPrivate) {
      if (!companyName && !organization) warnings.push('Company / Employer name is missing.');
      if (!contactEmail && !contactPhone && !whatsappApplyUrl && !applyUrl) {
        warnings.push('At least one contact or apply method (Email, Phone, WhatsApp, or Link) is required.');
      }
    } else {
      if (!organization) warnings.push('Organization / Board name is missing.');
      if (!sourceUrl && !officialWebsiteUrl) warnings.push('Official source or website URL is missing.');
      if (!applicationLastDate && isGovt) warnings.push('Application deadline is missing.');
    }
  }

  const handleCategoryToggle = (catId: string) => {
    if (selectedCategoryIds.includes(catId)) {
      setSelectedCategoryIds(selectedCategoryIds.filter((id) => id !== catId));
    } else {
      setSelectedCategoryIds([...selectedCategoryIds, catId]);
    }
  };

  const constructPayload = (overrideStatus?: ContentStatus): Partial<ContentItem> => {
    const skillsArray = skillsText
      .split(',')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    return {
      ...(initialItem || {}),
      contentType,
      jobType,
      showInLiveUpdates,
      title,
      slug: slug || `job-${Date.now()}`,
      excerpt,
      body: body || (isPrivate ? jobDescription : ''),
      featuredImageUrl,
      organization: isPrivate ? (companyName || organization) : organization,
      department: isGovt ? department : '',
      jobRole,
      vacancies,
      qualification,
      salary: isPrivate ? (salaryRange || salary) : salary,
      location: isPrivate ? `${island}, ${location}` : location,

      // Private specifics
      companyName,
      island,
      salaryRange,
      experience,
      skills: skillsArray,
      employmentType,
      workingHours,
      applicationMethod,
      contactEmail,
      contactPhone,
      whatsappApplyUrl,
      jobDescription,
      requirements,

      applicationStartDate,
      applicationLastDate,
      statusOverride,
      officialWebsiteUrl,
      officialNotificationUrl,
      applyUrl,
      importantDates,
      vacanciesBreakdown,
      ageLimits,
      applicationFees,
      selectionProcess,
      examPattern,
      importantLinks,
      faqs,
      sourceOrg: sourceOrg || organization,
      sourceUrl,
      lastVerifiedAt,
      status: overrideStatus || status,
      isPublished: (overrideStatus || status) === 'published',
      publishedAt: initialItem?.publishedAt || new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      updatedBy: userEmail,
      views: initialItem?.views || 0,
      categoryIds: selectedCategoryIds,
      tags: [
        contentType,
        jobType,
        ...(contentType === 'andaman_job' ? ['andaman', island.toLowerCase().split(' ')[0]] : []),
        ...selectedCategoryIds,
      ],
      searchKeywords: [
        title.toLowerCase(),
        organization.toLowerCase(),
        (companyName || '').toLowerCase(),
        jobRole.toLowerCase(),
        location.toLowerCase(),
      ],
      seoTitle: seoTitle || title,
      seoDescription: seoDescription || excerpt,
    };
  };

  const handleSaveDraft = async () => {
    if (saving) return;
    setSaving(true);
    try {
      await onSave(constructPayload('draft'), false, '');
    } finally {
      setSaving(false);
    }
  };

  const handleConfirmPublish = async () => {
    if (saving) return;
    setSaving(true);
    try {
      await onSave(constructPayload('published'), sendPush, pushTopic);
      setPublishModalOpen(false);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6 pb-24">
      {/* Top Header & Action Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-200">
        <div className="flex items-center gap-3">
          <button
            onClick={onCancel}
            className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h2 className="text-xl font-bold text-slate-900">
              {isEditing ? 'Edit Post' : 'Create New Post'}
            </h2>
            <p className="text-xs text-slate-500">
              {isArticle ? 'Publish an editorial article or roadmap' : 'Enter recruitment specifications and official source details'}
            </p>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-2.5">
          <AdminButton
            type="button"
            variant="outline"
            size="sm"
            icon={<Eye className="w-4 h-4 text-slate-600" />}
            onClick={() => setPreviewOpen(true)}
          >
            Live Preview
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
            {isEditing ? 'Update Post' : 'Publish'}
          </AdminButton>
        </div>
      </div>

      {/* Validation Warnings Alert Banner */}
      {warnings.length > 0 && (
        <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 text-amber-900 text-xs">
          <div className="flex items-center gap-2 font-bold mb-1">
            <AlertTriangle className="w-4 h-4 text-amber-600" />
            <span>Missing Information Warnings (You can still save a draft)</span>
          </div>
          <ul className="list-disc list-inside space-y-0.5 text-amber-800">
            {warnings.map((w, idx) => (
              <li key={idx}>{w}</li>
            ))}
          </ul>
        </div>
      )}

      {/* SECTION 1: Content Type & Basic Info */}
      <AdminCard
        title="1. Basic Information"
        subtitle="Primary identification, title, content type, and live updates"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <AdminSelect
              label="Content Type"
              value={contentType}
              onChange={(e) => {
                const val = e.target.value as ContentType;
                setContentType(val);
                if (val === 'andaman_job') {
                  if (!selectedCategoryIds.includes('andaman-nicobar')) {
                    setSelectedCategoryIds([...selectedCategoryIds, 'andaman-nicobar']);
                  }
                }
              }}
              options={[
                { value: 'government_job', label: 'Government Job (All India / State)' },
                { value: 'andaman_job', label: 'Andaman & Nicobar Job' },
                { value: 'private_job', label: 'Private Sector Job' },
                { value: 'admit_card', label: 'Admit Card / Hall Ticket' },
                { value: 'result', label: 'Exam Result / Merit List' },
                { value: 'answer_key', label: 'Answer Key & Objections' },
                { value: 'syllabus', label: 'Syllabus & Exam Pattern' },
                { value: 'article', label: 'Article / Guide' },
              ]}
            />
            <AdminInput
              label="URL Slug (Auto-generated)"
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              placeholder="e.g. andaman-police-constable-2026"
            />
          </div>

          {/* Special Andaman Job Type Selector */}
          {contentType === 'andaman_job' && (
            <div className="p-4 rounded-xl bg-emerald-50/80 border border-emerald-200">
              <label className="block text-xs font-bold text-emerald-950 mb-1">
                Andaman Job Type (Required) *
              </label>
              <p className="text-[11px] text-emerald-800 mb-3">
                Specify whether this opportunity is in an A&N Government Department or Private Island Enterprise. Form fields adapt dynamically.
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <label className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all ${
                  jobType === 'government'
                    ? 'bg-white border-emerald-600 shadow-sm'
                    : 'bg-emerald-100/40 border-emerald-200'
                }`}>
                  <input
                    type="radio"
                    name="anJobType"
                    value="government"
                    checked={jobType === 'government'}
                    onChange={() => setJobType('government')}
                    className="w-4 h-4 text-emerald-600 focus:ring-emerald-500"
                  />
                  <div>
                    <span className="text-xs font-bold text-slate-900 block">A&N Government Vacancy</span>
                    <span className="text-[10px] text-slate-500 block">UT Administration, Police, DHS, APWD, Education</span>
                  </div>
                </label>

                <label className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all ${
                  jobType === 'private'
                    ? 'bg-white border-indigo-600 shadow-sm'
                    : 'bg-emerald-100/40 border-emerald-200'
                }`}>
                  <input
                    type="radio"
                    name="anJobType"
                    value="private"
                    checked={jobType === 'private'}
                    onChange={() => setJobType('private')}
                    className="w-4 h-4 text-indigo-600 focus:ring-indigo-500"
                  />
                  <div>
                    <span className="text-xs font-bold text-slate-900 block">A&N Private Job</span>
                    <span className="text-[10px] text-slate-500 block">Resorts, Shipping, IT, Tour Operators, Retail</span>
                  </div>
                </label>
              </div>
            </div>
          )}

          <AdminInput
            label="Title"
            required
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder={
              isPrivate
                ? "e.g. Front Office Executive - Havelock Island Resort (5 Vacancies)"
                : "e.g. SSC CGL 2026 Notification - 8,200 Group B & C Vacancies"
            }
          />

          {/* Show in Live Updates Toggle */}
          <div className="flex items-center justify-between p-3.5 rounded-xl bg-slate-50 border border-slate-200">
            <div>
              <span className="text-xs font-bold text-slate-900 block flex items-center gap-1.5">
                <Bell className="w-3.5 h-3.5 text-[#159B76]" /> Show in Live Updates Feed
              </span>
              <span className="text-[11px] text-slate-500">
                When enabled, this vacancy is featured in the animated ticker on the mobile Home screen.
              </span>
            </div>
            <button
              type="button"
              onClick={() => setShowInLiveUpdates(!showInLiveUpdates)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ${
                showInLiveUpdates ? 'bg-[#159B76]' : 'bg-slate-300'
              }`}
            >
              <span
                className={`inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ${
                  showInLiveUpdates ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1.5">
              Short Summary / Excerpt
            </label>
            <textarea
              rows={2}
              value={excerpt}
              onChange={(e) => setExcerpt(e.target.value)}
              placeholder="Brief 1-2 sentence description shown on cards and in search results..."
              className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
            />
          </div>

          <AdminInput
            label="Featured Image URL (Optional HTTPS link)"
            value={featuredImageUrl}
            onChange={(e) => setFeaturedImageUrl(e.target.value)}
            placeholder="https://images.unsplash.com/... or CDN URL"
          />
        </div>
      </AdminCard>

      {/* SECTION 2: CONDITIONAL SPECIFICATIONS */}
      {/* 2A: PRIVATE EMPLOYMENT SPECIFICATIONS */}
      {isPrivate && !isArticle && (
        <AdminCard
          title="2. Private Employment Specifications"
          subtitle="Fields tailored for private enterprises, island businesses, and direct employer contact"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
              <AdminInput
                label="Company / Employer Name"
                required
                value={companyName}
                onChange={(e) => {
                  setCompanyName(e.target.value);
                  setOrganization(e.target.value);
                }}
                placeholder="e.g. Symphony Palms Beach Resort"
              />

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  Island / Region
                </label>
                <select
                  value={island}
                  onChange={(e) => setIsland(e.target.value)}
                  className="w-full text-xs rounded-xl border border-slate-200 p-2.5 text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                >
                  <option value="South Andaman (Port Blair)">South Andaman (Port Blair)</option>
                  <option value="Swaraj Dweep (Havelock)">Swaraj Dweep (Havelock)</option>
                  <option value="Shaheed Dweep (Neil)">Shaheed Dweep (Neil)</option>
                  <option value="North & Middle Andaman (Mayabunder / Diglipur)">North & Middle Andaman (Mayabunder / Diglipur)</option>
                  <option value="Baratang / Rangat">Baratang / Rangat</option>
                  <option value="Nicobar (Car Nicobar / Campbell Bay)">Nicobar (Car Nicobar / Campbell Bay)</option>
                  <option value="Mainland / Other">Mainland / Other</option>
                </select>
              </div>

              <AdminInput
                label="Exact Work Location"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g. Govind Nagar Beach, Havelock"
              />

              <AdminInput
                label="Job Role / Designation"
                required
                value={jobRole}
                onChange={(e) => setJobRole(e.target.value)}
                placeholder="e.g. Front Office Manager, Chef, Accounts Assistant"
              />

              <AdminInput
                label="Number of Vacancies"
                value={vacancies}
                onChange={(e) => setVacancies(e.target.value)}
                placeholder="e.g. 3 or Multiple"
              />

              <AdminInput
                label="Salary / Compensation"
                value={salaryRange}
                onChange={(e) => {
                  setSalaryRange(e.target.value);
                  setSalary(e.target.value);
                }}
                placeholder="e.g. ₹20,000 - ₹30,000 / month + Food & Stay"
              />

              <AdminInput
                label="Experience Required"
                value={experience}
                onChange={(e) => setExperience(e.target.value)}
                placeholder="e.g. 1-2 Years (Freshers can also apply)"
              />

              <AdminInput
                label="Minimum Qualification"
                value={qualification}
                onChange={(e) => setQualification(e.target.value)}
                placeholder="e.g. 12th Pass / Graduate in Hotel Management"
              />

              <AdminInput
                label="Key Skills (Comma-separated)"
                value={skillsText}
                onChange={(e) => setSkillsText(e.target.value)}
                placeholder="e.g. English Fluency, MS Excel, Driving"
              />

              <AdminInput
                label="Employment Type"
                value={employmentType}
                onChange={(e) => setEmploymentType(e.target.value)}
                placeholder="e.g. Full Time / Season Contract"
              />

              <AdminInput
                label="Working Hours / Shifts"
                value={workingHours}
                onChange={(e) => setWorkingHours(e.target.value)}
                placeholder="e.g. 9:00 AM - 6:00 PM (Rotational)"
              />

              <AdminInput
                label="Application Deadline"
                type="date"
                value={applicationLastDate}
                onChange={(e) => setApplicationLastDate(e.target.value)}
              />
            </div>

            {/* Direct Contact & Application Channels */}
            <div className="p-4 bg-indigo-50/50 border border-indigo-200 rounded-xl space-y-4">
              <h4 className="text-xs font-bold text-indigo-950 flex items-center gap-1.5">
                <Phone className="w-3.5 h-3.5 text-indigo-600" /> Direct Applicant Channels (Shown to Aspirants)
              </h4>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <AdminInput
                  label="Contact Phone / Mobile"
                  value={contactPhone}
                  onChange={(e) => setContactPhone(e.target.value)}
                  placeholder="e.g. +91 94342 XXXXX"
                />
                <AdminInput
                  label="Contact Email"
                  type="email"
                  value={contactEmail}
                  onChange={(e) => setContactEmail(e.target.value)}
                  placeholder="e.g. hr@hotelresort.com"
                />
                <AdminInput
                  label="WhatsApp Apply URL or Number"
                  value={whatsappApplyUrl}
                  onChange={(e) => setWhatsappApplyUrl(e.target.value)}
                  placeholder="https://wa.me/91XXXXXXXXXX"
                />
              </div>
              <AdminInput
                label="Direct Apply / Company Career Link (Optional)"
                value={applyUrl}
                onChange={(e) => setApplyUrl(e.target.value)}
                placeholder="https://company.com/apply"
              />
            </div>

            {/* Job Requirements & Detailed Description */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Job Responsibilities & Description
              </label>
              <textarea
                rows={4}
                value={jobDescription}
                onChange={(e) => setJobDescription(e.target.value)}
                placeholder="Describe day-to-day duties, work environment, and benefits (e.g. Accommodation, PF, Food provided)..."
                className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Key Requirements & Documents to Bring
              </label>
              <textarea
                rows={3}
                value={requirements}
                onChange={(e) => setRequirements(e.target.value)}
                placeholder="e.g. Island Resident Certificate, Updated Resume, Aadhar Card, Experience Certificates..."
                className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
              />
            </div>
          </div>
        </AdminCard>
      )}

      {/* 2B: GOVERNMENT RECRUITMENT SPECIFICATIONS */}
      {isGovt && !isArticle && (
        <>
          <AdminCard
            title="2. Government Recruitment Highlights"
            subtitle="Core specifications shown prominently in overview cards and metadata chips"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
              <AdminInput
                label="Organization / Board Name"
                required
                value={organization}
                onChange={(e) => setOrganization(e.target.value)}
                placeholder="e.g. Staff Selection Commission / A&N Police"
              />
              <AdminInput
                label="Department (Optional)"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                placeholder="e.g. Dept of Personnel & Training"
              />
              <AdminInput
                label="Job Role / Post Name"
                value={jobRole}
                onChange={(e) => setJobRole(e.target.value)}
                placeholder="e.g. Police Constable / Inspector"
              />
              <AdminInput
                label="Total Vacancies"
                value={vacancies}
                onChange={(e) => setVacancies(e.target.value)}
                placeholder="e.g. 8,200"
              />
              <AdminInput
                label="Minimum Qualification"
                value={qualification}
                onChange={(e) => setQualification(e.target.value)}
                placeholder="e.g. 12th Pass / Graduate in any stream"
              />
              <AdminInput
                label="Salary / Pay Level Scale"
                value={salary}
                onChange={(e) => setSalary(e.target.value)}
                placeholder="e.g. ₹21,700 - ₹69,100 (Pay Level 3)"
              />
              <AdminInput
                label="Job Location"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g. All India / Port Blair"
              />
              <AdminInput
                label="Cadre / Service Category"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                placeholder="e.g. Regular Central Govt / UT Cadre"
              />
              <AdminSelect
                label="Status Override (Automatic or Force)"
                value={statusOverride}
                onChange={(e) => setStatusOverride(e.target.value as StatusOverride)}
                options={[
                  { value: 'auto', label: 'Auto (Calculated from deadline)' },
                  { value: 'open', label: 'Force Open' },
                  { value: 'closing_soon', label: 'Force Closing Soon' },
                  { value: 'closed', label: 'Force Closed' },
                ]}
              />
            </div>
          </AdminCard>

          {/* SECTION 3: Official Links & Dates */}
          <AdminCard
            title="3. Official Government Portal & Dates"
            subtitle="Application window and direct official links"
          >
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <AdminInput
                  label="Application Start Date"
                  type="date"
                  value={applicationStartDate}
                  onChange={(e) => setApplicationStartDate(e.target.value)}
                />
                <AdminInput
                  label="Last Date to Apply"
                  type="date"
                  value={applicationLastDate}
                  onChange={(e) => setApplicationLastDate(e.target.value)}
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <AdminInput
                  label="Official Apply Online URL"
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
                  label="Official Department Website"
                  value={officialWebsiteUrl}
                  onChange={(e) => setOfficialWebsiteUrl(e.target.value)}
                  placeholder="https://..."
                />
              </div>
            </div>
          </AdminCard>

          {/* SECTION 4: Structured Government Data Tables */}
          <AdminCard
            title="4. Government Exam & Vacancy Breakdown"
            subtitle="Structured sub-tables parsed cleanly on mobile with zero text collision"
          >
            <div className="space-y-6">
              {/* Important Dates Repeater */}
              <div>
                <AdminRepeater
                  title="Important Schedule Milestones"
                  description="List milestones such as Written Exam Date, Admit Card Release, etc."
                  items={importantDates}
                  onAdd={() =>
                    setImportantDates((prev) => [
                      ...prev,
                      { id: Date.now().toString(), label: '', date: '' },
                    ])
                  }
                  onRemove={(idx) =>
                    setImportantDates((prev) => prev.filter((_, i) => i !== idx))
                  }
                  renderItem={(item, idx) => (
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <AdminInput
                        label="Milestone Label"
                        value={item.label}
                        onChange={(e) => {
                          const copy = [...importantDates];
                          copy[idx] = { ...copy[idx], label: e.target.value };
                          setImportantDates(copy);
                        }}
                        placeholder="e.g. Written Exam Date, Admit Card Release"
                      />
                      <AdminInput
                        label="Date String"
                        value={item.date}
                        onChange={(e) => {
                          const copy = [...importantDates];
                          copy[idx] = { ...copy[idx], date: e.target.value };
                          setImportantDates(copy);
                        }}
                        placeholder="e.g. 15 Nov 2026 or Dec 2026"
                      />
                    </div>
                  )}
                />
              </div>

              {/* Vacancy Breakdown */}
              <div className="pt-4 border-t border-slate-100">
                <AdminRepeater
                  title="Vacancy Breakdown by Category"
                  items={vacanciesBreakdown}
                  onAdd={() =>
                    setVacanciesBreakdown((prev) => [
                      ...prev,
                      { id: Date.now().toString(), postName: '', category: '', count: '' },
                    ])
                  }
                  onRemove={(idx) =>
                    setVacanciesBreakdown((prev) => prev.filter((_, i) => i !== idx))
                  }
                  renderItem={(item, idx) => (
                    <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
                      <div className="sm:col-span-2">
                        <AdminInput
                          label="Post Name"
                          value={item.postName}
                          onChange={(e) => {
                            const copy = [...vacanciesBreakdown];
                            copy[idx] = { ...copy[idx], postName: e.target.value };
                            setVacanciesBreakdown(copy);
                          }}
                          placeholder="e.g. Assistant Section Officer"
                        />
                      </div>
                      <AdminInput
                        label="Category"
                        value={item.category}
                        onChange={(e) => {
                          const copy = [...vacanciesBreakdown];
                          copy[idx] = { ...copy[idx], category: e.target.value };
                          setVacanciesBreakdown(copy);
                        }}
                        placeholder="UR / OBC / SC / ST / EWS"
                      />
                      <AdminInput
                        label="Count"
                        value={String(item.count)}
                        onChange={(e) => {
                          const copy = [...vacanciesBreakdown];
                          copy[idx] = { ...copy[idx], count: e.target.value };
                          setVacanciesBreakdown(copy);
                        }}
                        placeholder="150"
                      />
                    </div>
                  )}
                />
              </div>

              {/* Age Limits */}
              <div className="pt-4 border-t border-slate-100">
                <AdminRepeater
                  title="Age Limits & Relaxations"
                  items={ageLimits}
                  onAdd={() =>
                    setAgeLimits((prev) => [
                      ...prev,
                      { id: Date.now().toString(), category: '', relaxationYears: '' },
                    ])
                  }
                  onRemove={(idx) =>
                    setAgeLimits((prev) => prev.filter((_, i) => i !== idx))
                  }
                  renderItem={(item, idx) => (
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                      <AdminInput
                        label="Candidate Category"
                        value={item.category}
                        onChange={(e) => {
                          const copy = [...ageLimits];
                          copy[idx] = { ...copy[idx], category: e.target.value };
                          setAgeLimits(copy);
                        }}
                        placeholder="e.g. OBC (Non-Creamy)"
                      />
                      <AdminInput
                        label="Relaxation Years"
                        value={item.relaxationYears}
                        onChange={(e) => {
                          const copy = [...ageLimits];
                          copy[idx] = { ...copy[idx], relaxationYears: e.target.value };
                          setAgeLimits(copy);
                        }}
                        placeholder="3 Years"
                      />
                      <AdminInput
                        label="Max Age Cutoff"
                        value={item.maxAge || ''}
                        onChange={(e) => {
                          const copy = [...ageLimits];
                          copy[idx] = { ...copy[idx], maxAge: e.target.value };
                          setAgeLimits(copy);
                        }}
                        placeholder="33 Years"
                      />
                    </div>
                  )}
                />
              </div>
            </div>
          </AdminCard>
        </>
      )}

      {/* SECTION 3: Content Body (Markdown) */}
      <AdminCard
        title="3. Detailed Notification Overview & Notes"
        subtitle="Full editorial write-up formatted in standard Markdown"
      >
        <div className="space-y-2">
          <textarea
            rows={8}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder="Write a clear breakdown of the notification, eligibility details, and application procedure..."
            className="w-full text-xs font-mono rounded-xl border border-slate-200 p-4 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 leading-relaxed"
          />
        </div>
      </AdminCard>

      {/* SECTION 4: Categories & Trust Verification */}
      <AdminCard
        title="4. Categories & Source Verification"
        subtitle="Ensure authentic information with verifiable official links"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-2">
              Assigned Categories (Filters on Mobile App)
            </label>
            <div className="flex flex-wrap gap-2">
              {categories.map((cat) => {
                const isSelected = selectedCategoryIds.includes(cat.slug);
                return (
                  <button
                    key={cat.id}
                    type="button"
                    onClick={() => handleCategoryToggle(cat.slug)}
                    className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-all ${
                      isSelected
                        ? 'bg-[#159B76] text-white border-[#159B76] shadow-sm'
                        : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
                    }`}
                  >
                    {cat.name}
                  </button>
                );
              })}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2 border-t border-slate-100">
            <AdminInput
              label="Verified Source / Department Name"
              value={sourceOrg}
              onChange={(e) => setSourceOrg(e.target.value)}
              placeholder="e.g. Staff Selection Commission (Official)"
            />
            <AdminInput
              label="Source Gazette / Circular URL"
              value={sourceUrl}
              onChange={(e) => setSourceUrl(e.target.value)}
              placeholder="https://.../circular-2026.pdf"
            />
          </div>
        </div>
      </AdminCard>

      {/* Live Mobile Preview Modal */}
      {previewOpen && (
        <MobilePreviewModal
          isOpen={previewOpen}
          onClose={() => setPreviewOpen(false)}
          item={constructPayload('published') as ContentItem}
        />
      )}

      {/* Publish & Notification Confirmation Modal */}
      <AdminModal
        isOpen={publishModalOpen}
        onClose={() => setPublishModalOpen(false)}
        title="Confirm Publication"
      >
        <div className="space-y-4">
          <p className="text-xs text-slate-600 leading-relaxed">
            You are about to publish <strong>{title || 'Untitled Notice'}</strong> directly to the live mobile app.
          </p>

          <div className="p-4 rounded-xl bg-emerald-50/60 border border-emerald-200 space-y-3">
            <label className="flex items-start gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={sendPush}
                onChange={(e) => setSendPush(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
              />
              <div>
                <span className="text-xs font-bold text-slate-900 block">
                  Send Push Notification to Subscribers
                </span>
                <span className="text-[11px] text-slate-500 block">
                  Dispatches an instant alert to subscribed aspirants
                </span>
              </div>
            </label>

            {sendPush && (
              <div className="pt-2 border-t border-emerald-200/60">
                <AdminSelect
                  label="Target Push Topic"
                  value={pushTopic}
                  onChange={(e) => setPushTopic(e.target.value)}
                  options={[
                    { value: 'all_updates', label: 'All Updates (Broad Audience)' },
                    { value: 'jobs', label: 'All Jobs' },
                    { value: 'andaman', label: 'Andaman & Nicobar Jobs' },
                    { value: 'ssc', label: 'SSC Aspirants' },
                    { value: 'railway', label: 'Railway Aspirants' },
                    { value: 'banking', label: 'Banking Aspirants' },
                    { value: 'police', label: 'Police & Defence' },
                    { value: 'results', label: 'Results Alert' },
                    { value: 'admit_cards', label: 'Admit Cards Alert' },
                  ]}
                />
              </div>
            )}
          </div>

          <div className="pt-3 flex items-center justify-end gap-3">
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
              disabled={saving}
              onClick={handleConfirmPublish}
            >
              Confirm &amp; Publish
            </AdminButton>
          </div>
        </div>
      </AdminModal>
    </div>
  );
};
