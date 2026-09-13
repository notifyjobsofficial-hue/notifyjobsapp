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
  Link,
  HelpCircle,
  BookOpen,
  Globe,
  Bell,
  Check,
  ChevronDown,
  ChevronUp,
} from 'lucide-react';
import {
  ContentItem,
  ContentType,
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
  const [title, setTitle] = useState(initialItem?.title || '');
  const [slug, setSlug] = useState(initialItem?.slug || '');
  const [excerpt, setExcerpt] = useState(initialItem?.excerpt || '');
  const [body, setBody] = useState(initialItem?.body || '');
  const [featuredImageUrl, setFeaturedImageUrl] = useState(initialItem?.featuredImageUrl || '');

  // Job specifics
  const [organization, setOrganization] = useState(initialItem?.organization || '');
  const [department, setDepartment] = useState(initialItem?.department || '');
  const [jobRole, setJobRole] = useState(initialItem?.jobRole || '');
  const [vacancies, setVacancies] = useState(initialItem?.vacancies || '');
  const [qualification, setQualification] = useState(initialItem?.qualification || '');
  const [salary, setSalary] = useState(initialItem?.salary || '');
  const [location, setLocation] = useState(initialItem?.location || 'All India');
  const [jobType, setJobType] = useState(initialItem?.jobType || 'Regular Govt');

  const [applicationStartDate, setApplicationStartDate] = useState(
    initialItem?.applicationStartDate || ''
  );
  const [applicationLastDate, setApplicationLastDate] = useState(
    initialItem?.applicationLastDate || ''
  );
  const [statusOverride, setStatusOverride] = useState<StatusOverride>(
    initialItem?.statusOverride || 'auto'
  );

  const [officialWebsiteUrl, setOfficialWebsiteUrl] = useState(
    initialItem?.officialWebsiteUrl || ''
  );
  const [officialNotificationUrl, setOfficialNotificationUrl] = useState(
    initialItem?.officialNotificationUrl || ''
  );
  const [applyUrl, setApplyUrl] = useState(initialItem?.applyUrl || '');

  // Structured arrays
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

  // Validation Warnings
  const warnings: string[] = [];
  if (!title) warnings.push('Title is missing.');
  if (contentType !== 'article') {
    if (!organization) warnings.push('Organization is missing.');
    if (!sourceUrl && !officialWebsiteUrl) warnings.push('Official source / website URL is missing.');
    if (contentType === 'government_job' && !applicationLastDate) {
      warnings.push('Application deadline is missing.');
    }
    if (contentType === 'government_job' && !applyUrl) {
      warnings.push('Apply Online URL is missing.');
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
    return {
      ...(initialItem || {}),
      contentType,
      title,
      slug: slug || `job-${Date.now()}`,
      excerpt,
      body,
      featuredImageUrl,
      organization,
      department,
      jobRole,
      vacancies,
      qualification,
      salary,
      location,
      jobType,
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
      sourceUrl: sourceUrl || officialWebsiteUrl,
      lastVerifiedAt,
      status: overrideStatus || status,
      isPublished: (overrideStatus || status) === 'published',
      categoryIds: selectedCategoryIds,
      tags: selectedCategoryIds,
      seoTitle: seoTitle || title,
      seoDescription: seoDescription || excerpt,
    };
  };

  const handleSaveDraft = async () => {
    setSaving(true);
    try {
      await onSave(constructPayload('draft'), false, 'all_updates');
    } finally {
      setSaving(false);
    }
  };

  const handleConfirmPublish = async () => {
    setSaving(true);
    try {
      await onSave(constructPayload('published'), sendPush, pushTopic);
      setPublishModalOpen(false);
    } finally {
      setSaving(false);
    }
  };

  const isArticle = contentType === 'article';

  return (
    <div className="space-y-6 pb-24">
      {/* Top Header & Sticky Action Bar */}
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
            Preview
          </AdminButton>
          <AdminButton
            type="button"
            variant="secondary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
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
            <span>Missing Information Warnings (Can still save draft)</span>
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
        subtitle="Primary identification, title, and excerpt"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <AdminSelect
              label="Content Type"
              value={contentType}
              onChange={(e) => setContentType(e.target.value as ContentType)}
              options={[
                { value: 'government_job', label: 'Government Job' },
                { value: 'private_job', label: 'Private Job' },
                { value: 'admit_card', label: 'Admit Card' },
                { value: 'result', label: 'Result' },
                { value: 'answer_key', label: 'Answer Key' },
                { value: 'syllabus', label: 'Syllabus' },
                { value: 'article', label: 'Article / Guide' },
              ]}
            />
            <AdminInput
              label="URL Slug (Auto-generated)"
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              placeholder="ssc-cgl-2026-notification"
            />
          </div>

          <AdminInput
            label="Title"
            required
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g. SSC CGL 2026 Notification - 8,200 Group B & C Vacancies"
          />

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1.5">
              Short Summary / Excerpt
            </label>
            <textarea
              rows={2}
              value={excerpt}
              onChange={(e) => setExcerpt(e.target.value)}
              placeholder="Brief 1-2 sentence description shown in lists and meta description..."
              className="w-full text-sm rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
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

      {/* NON-ARTICLE SECTIONS (JOB / ADMIT CARD / RESULT SPECIFICATIONS) */}
      {!isArticle && (
        <>
          {/* SECTION 2: Highlights */}
          <AdminCard
            title="2. Recruitment Highlights"
            subtitle="Core specifications shown prominently in app overview tiles"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
              <AdminInput
                label="Organization / Board Name"
                required
                value={organization}
                onChange={(e) => setOrganization(e.target.value)}
                placeholder="e.g. Staff Selection Commission"
              />
              <AdminInput
                label="Department (Optional)"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                placeholder="e.g. Ministry of Home Affairs"
              />
              <AdminInput
                label="Job Role / Post"
                value={jobRole}
                onChange={(e) => setJobRole(e.target.value)}
                placeholder="e.g. Inspector, Assistant Section Officer"
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
                placeholder="e.g. Graduate in any stream"
              />
              <AdminInput
                label="Salary / Pay Scale"
                value={salary}
                onChange={(e) => setSalary(e.target.value)}
                placeholder="e.g. ₹35,400 - ₹1,12,400 (Level 7)"
              />
              <AdminInput
                label="Job Location"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g. All India / Port Blair"
              />
              <AdminInput
                label="Job Type"
                value={jobType}
                onChange={(e) => setJobType(e.target.value)}
                placeholder="e.g. Regular Govt / Contractual"
              />
              <AdminSelect
                label="Status Override (Automatic or Force)"
                value={statusOverride}
                onChange={(e) => setStatusOverride(e.target.value as StatusOverride)}
                options={[
                  { value: 'auto', label: 'Auto (Calculated from Last Date)' },
                  { value: 'open', label: 'Force Open' },
                  { value: 'closing_soon', label: 'Force Closing Soon' },
                  { value: 'closing_today', label: 'Force Closing Today' },
                  { value: 'closed', label: 'Force Closed' },
                ]}
              />
            </div>
          </AdminCard>

          {/* SECTION 3: Important Dates */}
          <AdminCard
            title="3. Important Dates"
            subtitle="Application dates and exam schedules"
          >
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pb-4 border-b border-slate-100">
                <AdminInput
                  label="Application Start Date"
                  type="date"
                  value={applicationStartDate}
                  onChange={(e) => setApplicationStartDate(e.target.value)}
                />
                <AdminInput
                  label="Application Last Date (Used for Auto-Status)"
                  type="date"
                  value={applicationLastDate}
                  onChange={(e) => setApplicationLastDate(e.target.value)}
                />
              </div>

              <AdminRepeater
                title="Custom Event Dates"
                description="List specific milestones: Admit Card Release, Exam Date, Answer Key, Result"
                items={importantDates}
                onAdd={() =>
                  setImportantDates([
                    ...importantDates,
                    { id: String(Date.now()), label: 'New Milestone', date: '' },
                  ])
                }
                onRemove={(idx) =>
                  setImportantDates(importantDates.filter((_, i) => i !== idx))
                }
                renderItem={(item, idx) => (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <AdminInput
                      label="Event Label"
                      value={item.label}
                      onChange={(e) => {
                        const copy = [...importantDates];
                        copy[idx].label = e.target.value;
                        setImportantDates(copy);
                      }}
                      placeholder="e.g. Tier 1 Exam Date"
                    />
                    <AdminInput
                      label="Date / Status"
                      value={item.date}
                      onChange={(e) => {
                        const copy = [...importantDates];
                        copy[idx].date = e.target.value;
                        setImportantDates(copy);
                      }}
                      placeholder="e.g. 25 Nov 2026 or To be announced"
                    />
                  </div>
                )}
              />
            </div>
          </AdminCard>

          {/* SECTION 4: Vacancy Breakdown */}
          <AdminCard
            title="4. Vacancy Breakdown"
            subtitle="Detailed distribution by post name and category"
          >
            <AdminRepeater
              title="Post-wise Vacancies"
              items={vacanciesBreakdown}
              onAdd={() =>
                setVacanciesBreakdown([
                  ...vacanciesBreakdown,
                  {
                    id: String(Date.now()),
                    postName: '',
                    category: 'UR/OBC/SC/ST',
                    count: '',
                    payLevel: '',
                  },
                ])
              }
              onRemove={(idx) =>
                setVacanciesBreakdown(vacanciesBreakdown.filter((_, i) => i !== idx))
              }
              renderItem={(item, idx) => (
                <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
                  <AdminInput
                    label="Post Name"
                    value={item.postName}
                    onChange={(e) => {
                      const copy = [...vacanciesBreakdown];
                      copy[idx].postName = e.target.value;
                      setVacanciesBreakdown(copy);
                    }}
                    placeholder="Assistant Section Officer"
                  />
                  <AdminInput
                    label="Category / Reservation"
                    value={item.category}
                    onChange={(e) => {
                      const copy = [...vacanciesBreakdown];
                      copy[idx].category = e.target.value;
                      setVacanciesBreakdown(copy);
                    }}
                    placeholder="All Categories / UR"
                  />
                  <AdminInput
                    label="Count"
                    value={String(item.count)}
                    onChange={(e) => {
                      const copy = [...vacanciesBreakdown];
                      copy[idx].count = e.target.value;
                      setVacanciesBreakdown(copy);
                    }}
                    placeholder="1,850"
                  />
                  <AdminInput
                    label="Pay Level"
                    value={item.payLevel || ''}
                    onChange={(e) => {
                      const copy = [...vacanciesBreakdown];
                      copy[idx].payLevel = e.target.value;
                      setVacanciesBreakdown(copy);
                    }}
                    placeholder="Level 7"
                  />
                </div>
              )}
            />
          </AdminCard>

          {/* SECTION 5: Age Limits & Application Fees */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Age Limits */}
            <AdminCard
              title="5. Age Limits & Relaxation"
              subtitle="Category-wise age cutoffs and relaxations"
            >
              <AdminRepeater
                title="Age Rules"
                items={ageLimits}
                onAdd={() =>
                  setAgeLimits([
                    ...ageLimits,
                    { id: String(Date.now()), category: '', relaxationYears: '', maxAge: '' },
                  ])
                }
                onRemove={(idx) => setAgeLimits(ageLimits.filter((_, i) => i !== idx))}
                renderItem={(item, idx) => (
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                    <AdminInput
                      label="Category"
                      value={item.category}
                      onChange={(e) => {
                        const copy = [...ageLimits];
                        copy[idx].category = e.target.value;
                        setAgeLimits(copy);
                      }}
                      placeholder="OBC (NCL)"
                    />
                    <AdminInput
                      label="Max Age"
                      value={item.maxAge || ''}
                      onChange={(e) => {
                        const copy = [...ageLimits];
                        copy[idx].maxAge = e.target.value;
                        setAgeLimits(copy);
                      }}
                      placeholder="33 Years"
                    />
                    <AdminInput
                      label="Relaxation"
                      value={item.relaxationYears}
                      onChange={(e) => {
                        const copy = [...ageLimits];
                        copy[idx].relaxationYears = e.target.value;
                        setAgeLimits(copy);
                      }}
                      placeholder="3 Years"
                    />
                  </div>
                )}
              />
            </AdminCard>

            {/* Application Fees */}
            <AdminCard
              title="6. Application Fees"
              subtitle="Category fees and payment options"
            >
              <AdminRepeater
                title="Fee Structure"
                items={applicationFees}
                onAdd={() =>
                  setApplicationFees([
                    ...applicationFees,
                    { id: String(Date.now()), category: '', fee: '', paymentMode: 'Online' },
                  ])
                }
                onRemove={(idx) =>
                  setApplicationFees(applicationFees.filter((_, i) => i !== idx))
                }
                renderItem={(item, idx) => (
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                    <AdminInput
                      label="Category"
                      value={item.category}
                      onChange={(e) => {
                        const copy = [...applicationFees];
                        copy[idx].category = e.target.value;
                        setApplicationFees(copy);
                      }}
                      placeholder="General / OBC (Male)"
                    />
                    <AdminInput
                      label="Fee Amount"
                      value={item.fee}
                      onChange={(e) => {
                        const copy = [...applicationFees];
                        copy[idx].fee = e.target.value;
                        setApplicationFees(copy);
                      }}
                      placeholder="₹100"
                    />
                    <AdminInput
                      label="Mode"
                      value={item.paymentMode || ''}
                      onChange={(e) => {
                        const copy = [...applicationFees];
                        copy[idx].paymentMode = e.target.value;
                        setApplicationFees(copy);
                      }}
                      placeholder="Online (UPI/Netbanking)"
                    />
                  </div>
                )}
              />
            </AdminCard>
          </div>

          {/* SECTION 7: Selection Process & Exam Pattern */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <AdminCard
              title="7. Selection Process"
              subtitle="Recruitment stages: CBT, Skill Test, DV, Medical"
            >
              <AdminRepeater
                title="Stages"
                items={selectionProcess}
                onAdd={() =>
                  setSelectionProcess([
                    ...selectionProcess,
                    {
                      id: String(Date.now()),
                      stageNumber: selectionProcess.length + 1,
                      name: '',
                      description: '',
                    },
                  ])
                }
                onRemove={(idx) =>
                  setSelectionProcess(selectionProcess.filter((_, i) => i !== idx))
                }
                renderItem={(item, idx) => (
                  <div className="space-y-2">
                    <AdminInput
                      label={`Stage ${idx + 1} Name`}
                      value={item.name}
                      onChange={(e) => {
                        const copy = [...selectionProcess];
                        copy[idx].name = e.target.value;
                        setSelectionProcess(copy);
                      }}
                      placeholder="e.g. Tier 1 Computer Based Exam"
                    />
                    <AdminInput
                      label="Description"
                      value={item.description}
                      onChange={(e) => {
                        const copy = [...selectionProcess];
                        copy[idx].description = e.target.value;
                        setSelectionProcess(copy);
                      }}
                      placeholder="Brief details about negative marking, syllabus scope..."
                    />
                  </div>
                )}
              />
            </AdminCard>

            <AdminCard
              title="8. Exam Pattern"
              subtitle="Subject-wise questions and mark breakdown"
            >
              <AdminRepeater
                title="Exam Pattern Rows"
                items={examPattern}
                onAdd={() =>
                  setExamPattern([
                    ...examPattern,
                    { id: String(Date.now()), subject: '', questions: '', marks: '', duration: '' },
                  ])
                }
                onRemove={(idx) => setExamPattern(examPattern.filter((_, i) => i !== idx))}
                renderItem={(item, idx) => (
                  <div className="grid grid-cols-1 sm:grid-cols-4 gap-2">
                    <AdminInput
                      label="Subject"
                      value={item.subject}
                      onChange={(e) => {
                        const copy = [...examPattern];
                        copy[idx].subject = e.target.value;
                        setExamPattern(copy);
                      }}
                      placeholder="Reasoning"
                    />
                    <AdminInput
                      label="Questions"
                      value={String(item.questions)}
                      onChange={(e) => {
                        const copy = [...examPattern];
                        copy[idx].questions = e.target.value;
                        setExamPattern(copy);
                      }}
                      placeholder="25"
                    />
                    <AdminInput
                      label="Marks"
                      value={String(item.marks)}
                      onChange={(e) => {
                        const copy = [...examPattern];
                        copy[idx].marks = e.target.value;
                        setExamPattern(copy);
                      }}
                      placeholder="50"
                    />
                    <AdminInput
                      label="Duration"
                      value={item.duration || ''}
                      onChange={(e) => {
                        const copy = [...examPattern];
                        copy[idx].duration = e.target.value;
                        setExamPattern(copy);
                      }}
                      placeholder="60m Total"
                    />
                  </div>
                )}
              />
            </AdminCard>
          </div>

          {/* SECTION 9: Important Links (Crucial Specification: Apply Online is direct, Official Notification is Rewarded) */}
          <AdminCard
            title="9. Important Links"
            subtitle="Apply Online &amp; Official Website are DIRECT. Official Notification is gated by Rewarded Ad."
          >
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pb-4 border-b border-slate-100">
                <AdminInput
                  label="Apply Online URL (Direct Link)"
                  value={applyUrl}
                  onChange={(e) => setApplyUrl(e.target.value)}
                  placeholder="https://..."
                />
                <AdminInput
                  label="Official Notification PDF URL (Rewarded Ad Gated)"
                  value={officialNotificationUrl}
                  onChange={(e) => setOfficialNotificationUrl(e.target.value)}
                  placeholder="https://.../notification.pdf"
                />
                <AdminInput
                  label="Official Website URL (Direct Link)"
                  value={officialWebsiteUrl}
                  onChange={(e) => setOfficialWebsiteUrl(e.target.value)}
                  placeholder="https://..."
                />
              </div>

              <AdminRepeater
                title="Additional Custom Links"
                items={importantLinks}
                onAdd={() =>
                  setImportantLinks([
                    ...importantLinks,
                    { id: String(Date.now()), title: 'Custom Link', url: '', type: 'custom' },
                  ])
                }
                onRemove={(idx) =>
                  setImportantLinks(importantLinks.filter((_, i) => i !== idx))
                }
                renderItem={(item, idx) => (
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <AdminInput
                      label="Link Title"
                      value={item.title}
                      onChange={(e) => {
                        const copy = [...importantLinks];
                        copy[idx].title = e.target.value;
                        setImportantLinks(copy);
                      }}
                      placeholder="e.g. Download Syllabus PDF"
                    />
                    <AdminInput
                      label="URL"
                      value={item.url}
                      onChange={(e) => {
                        const copy = [...importantLinks];
                        copy[idx].url = e.target.value;
                        setImportantLinks(copy);
                      }}
                      placeholder="https://..."
                    />
                    <AdminSelect
                      label="Link Type"
                      value={item.type}
                      onChange={(e) => {
                        const copy = [...importantLinks];
                        copy[idx].type = e.target.value as any;
                        setImportantLinks(copy);
                      }}
                      options={[
                        { value: 'apply_online', label: 'Apply Online (Direct)' },
                        { value: 'official_notification', label: 'Official Notification (Rewarded Ad)' },
                        { value: 'official_website', label: 'Official Website (Direct)' },
                        { value: 'download_pdf', label: 'Download PDF (Rewarded Ad)' },
                        { value: 'result', label: 'Result Link (Direct)' },
                        { value: 'admit_card', label: 'Admit Card Link (Direct)' },
                        { value: 'custom', label: 'Custom Direct Link' },
                      ]}
                    />
                  </div>
                )}
              />
            </div>
          </AdminCard>

          {/* SECTION 10: FAQs */}
          <AdminCard
            title="10. Frequently Asked Questions (FAQs)"
            subtitle="Common aspirant questions and clear answers"
          >
            <AdminRepeater
              title="FAQ Items"
              items={faqs}
              onAdd={() =>
                setFaqs([
                  ...faqs,
                  { id: String(Date.now()), question: '', answer: '' },
                ])
              }
              onRemove={(idx) => setFaqs(faqs.filter((_, i) => i !== idx))}
              renderItem={(item, idx) => (
                <div className="space-y-2">
                  <AdminInput
                    label="Question"
                    value={item.question}
                    onChange={(e) => {
                      const copy = [...faqs];
                      copy[idx].question = e.target.value;
                      setFaqs(copy);
                    }}
                    placeholder="What is the age limit for this recruitment?"
                  />
                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Answer
                    </label>
                    <textarea
                      rows={2}
                      value={item.answer}
                      onChange={(e) => {
                        const copy = [...faqs];
                        copy[idx].answer = e.target.value;
                        setFaqs(copy);
                      }}
                      placeholder="Provide a clear, accurate explanation..."
                      className="w-full text-xs rounded-xl border border-slate-200 p-2.5 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                    />
                  </div>
                </div>
              )}
            />
          </AdminCard>
        </>
      )}

      {/* SECTION 11: Detailed Body (For all content types) */}
      <AdminCard
        title="11. Detailed Body & Instructions"
        subtitle="Full markdown text shown in the article / job detail view"
      >
        <div>
          <textarea
            rows={8}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder="Write comprehensive notification details, eligibility breakdown, how to apply steps, exam preparation tips using Markdown..."
            className="w-full font-mono text-xs rounded-2xl border border-slate-200 p-4 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76] leading-relaxed"
          />
          <p className="text-[11px] text-slate-400 mt-1.5">
            Supports Markdown formatting: <code>## Headings</code>, <code>**bold**</code>, <code>- bullet points</code>.
          </p>
        </div>
      </AdminCard>

      {/* SECTION 12: Trust, Categories & Publishing */}
      <AdminCard
        title="12. Trust Source, Categories &amp; Publishing"
        subtitle="Verification credits, taxonomy mapping, and search tags"
      >
        <div className="space-y-6">
          {/* Categories Selector */}
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-2">
              Assigned Categories (Select all that apply)
            </label>
            <div className="flex flex-wrap gap-2">
              {categories.map((cat) => {
                const isSelected = selectedCategoryIds.includes(cat.id);
                return (
                  <button
                    key={cat.id}
                    type="button"
                    onClick={() => handleCategoryToggle(cat.id)}
                    className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-all ${
                      isSelected
                        ? 'bg-[#159B76] text-white border-[#159B76] shadow-sm'
                        : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
                    }`}
                  >
                    {isSelected && <Check className="w-3 h-3 inline mr-1" />}
                    {cat.name}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Source Verification Fields (Specification 107) */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-4 border-t border-slate-100">
            <AdminInput
              label="Source Organization"
              value={sourceOrg}
              onChange={(e) => setSourceOrg(e.target.value)}
              placeholder="e.g. Official SSC Portal"
            />
            <AdminInput
              label="Source Verification URL"
              value={sourceUrl}
              onChange={(e) => setSourceUrl(e.target.value)}
              placeholder="https://ssc.gov.in"
            />
            <AdminInput
              label="Last Verified Date"
              value={lastVerifiedAt}
              onChange={(e) => setLastVerifiedAt(e.target.value)}
              placeholder="12 Sep 2026"
            />
          </div>

          {/* Status & SEO */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-4 border-t border-slate-100">
            <AdminSelect
              label="Publishing Status"
              value={status}
              onChange={(e) => setStatus(e.target.value as ContentStatus)}
              options={[
                { value: 'published', label: 'Published (Visible to all app users)' },
                { value: 'draft', label: 'Draft (Visible only in admin)' },
                { value: 'archived', label: 'Archived' },
              ]}
            />
            <AdminInput
              label="SEO Title"
              value={seoTitle}
              onChange={(e) => setSeoTitle(e.target.value)}
              placeholder="Leave blank to use main title"
            />
          </div>
        </div>
      </AdminCard>

      {/* Sticky Bottom Action Bar */}
      <div className="fixed bottom-0 left-0 right-0 z-40 bg-white/95 backdrop-blur border-t border-slate-200 py-3 px-4 sm:px-8 flex items-center justify-between shadow-lg lg:pl-80">
        <div className="text-xs text-slate-500 font-medium truncate hidden sm:block">
          {isEditing ? `Editing: ${title || 'Untitled'}` : 'New Content Draft'}
        </div>
        <div className="flex items-center gap-2.5 w-full sm:w-auto justify-end">
          <AdminButton
            type="button"
            variant="outline"
            size="sm"
            onClick={() => setPreviewOpen(true)}
          >
            Mobile Preview
          </AdminButton>
          <AdminButton
            type="button"
            variant="secondary"
            size="sm"
            loading={saving}
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
            onClick={() => setPublishModalOpen(true)}
          >
            {isEditing ? 'Update & Save' : 'Publish to App'}
          </AdminButton>
        </div>
      </div>

      {/* Mobile Preview Modal */}
      <MobilePreviewModal
        isOpen={previewOpen}
        onClose={() => setPreviewOpen(false)}
        item={constructPayload()}
      />

      {/* Publish & Send Push Notification Modal */}
      <AdminModal
        isOpen={publishModalOpen}
        onClose={() => setPublishModalOpen(false)}
        title="Confirm Publishing"
        subtitle="Make this notification live for all Notify Jobs app users"
      >
        <div className="space-y-4">
          <p className="text-xs text-slate-600 leading-relaxed">
            You are about to publish <strong>{title || 'this content'}</strong>. It will immediately appear on the home feed, search results, and category listings in the Flutter app.
          </p>

          {/* Send Push Notification Option (Specification 153) */}
          <div className="p-4 rounded-2xl bg-emerald-50/60 border border-emerald-200 space-y-3">
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
                  Dispatches an instant alert via Cloudflare Worker FCM
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
