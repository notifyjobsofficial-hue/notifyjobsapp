import React, { useState, useMemo, useEffect } from 'react';
import {
  Search,
  Filter,
  Plus,
  Edit2,
  Archive,
  Trash2,
  Smartphone,
  Copy,
  CheckCircle,
  XCircle,
  Clock,
  Calendar,
  Layers,
  ArrowUpDown,
  ChevronRight,
  AlertCircle,
  CheckCircle2,
  FileText,
  Briefcase,
  MapPin,
  Landmark,
  Train,
  Shield,
  FileCheck,
  Award,
  CheckSquare,
  BookOpen,
  Newspaper,
  RotateCcw,
} from 'lucide-react';
import { ContentItem, ContentType, ContentStatus, Category, StatusOverride } from '../types';
import { AdminButton } from '../components/common/AdminButton';
import { AdminBadge } from '../components/common/AdminBadge';
import { AdminConfirmDialog } from '../components/common/AdminConfirmDialog';
import { calculateJobStatus, isCategoryMatch } from '../services/contentService';

export type PublishStateFilter = 'all' | 'published' | 'draft' | 'scheduled' | 'archived';

interface ContentListPageProps {
  items: ContentItem[];
  categories?: Category[];
  currentTypeFilter?: ContentType | 'all' | 'jobs';
  currentCategoryFilter?: string | 'all';
  pageTitle?: string;
  pageSubtitle?: string;
  breadcrumbs?: string[];
  onEditItem: (item: ContentItem) => void;
  onAddNew: (presetType?: ContentType) => void;
  onPreviewItem: (item: ContentItem) => void;
  onDuplicateItem?: (item: ContentItem) => void;
  onTogglePublish?: (id: string, isPublished: boolean) => void;
  onArchiveItem: (id: string) => void;
  onDeleteItem: (id: string) => void;
}

export const ContentListPage: React.FC<ContentListPageProps> = ({
  items,
  categories = [],
  currentTypeFilter = 'all',
  currentCategoryFilter = 'all',
  pageTitle,
  pageSubtitle,
  breadcrumbs = ['Content Management', 'All Content'],
  onEditItem,
  onAddNew,
  onPreviewItem,
  onDuplicateItem,
  onTogglePublish,
  onArchiveItem,
  onDeleteItem,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState<ContentType | 'all' | 'jobs'>(currentTypeFilter);
  const [categoryFilter, setCategoryFilter] = useState<string | 'all'>(currentCategoryFilter);
  const [publishStateTab, setPublishStateTab] = useState<PublishStateFilter>('all');
  const [publicStatusFilter, setPublicStatusFilter] = useState<string>('all');
  const [sortBy, setSortBy] = useState<'updated_desc' | 'published_desc' | 'deadline_asc' | 'views_desc' | 'title_asc'>('updated_desc');

  const [itemToDelete, setItemToDelete] = useState<ContentItem | null>(null);
  const [deleting, setDeleting] = useState(false);

  // Synchronize internal state when navigation props change
  useEffect(() => {
    setTypeFilter(currentTypeFilter);
  }, [currentTypeFilter]);

  useEffect(() => {
    setCategoryFilter(currentCategoryFilter);
  }, [currentCategoryFilter]);

  // Map category ID to Category Name
  const categoryMap = useMemo(() => {
    const map = new Map<string, string>();
    categories.forEach((c) => map.set(c.id, c.name));
    return map;
  }, [categories]);

  // Content type matching helper
  const matchesContentType = (itemType: ContentType, filter: ContentType | 'all' | 'jobs') => {
    if (filter === 'all') return true;
    if (filter === 'jobs') {
      return itemType === 'government_job' || itemType === 'andaman_job' || itemType === 'private_job';
    }
    return itemType === filter;
  };

  // Compute publish state counts across currently scoped type and category
  const tabCounts = useMemo(() => {
    const base = items.filter((item) => {
      if (!matchesContentType(item.contentType, typeFilter)) return false;
      if (categoryFilter !== 'all' && !isCategoryMatch(item, categoryFilter)) return false;
      return true;
    });

    return {
      all: base.length,
      published: base.filter((i) => i.status === 'published').length,
      draft: base.filter((i) => i.status === 'draft').length,
      scheduled: 0, // Reserved for scheduled posts
      archived: base.filter((i) => i.status === 'archived').length,
    };
  }, [items, typeFilter, categoryFilter]);

  // Main Filtered & Sorted items list
  const filteredItems = useMemo(() => {
    return items
      .filter((item) => {
        // 1. Content Type Filter
        if (!matchesContentType(item.contentType, typeFilter)) return false;

        // 2. Category Filter
        if (categoryFilter !== 'all' && !isCategoryMatch(item, categoryFilter)) {
          return false;
        }

        // 3. Publish State Tab
        if (publishStateTab !== 'all') {
          if (publishStateTab === 'scheduled') return false; // currently none
          if (item.status !== publishStateTab) return false;
        }

        // 4. Public Status Filter (Open, Closing Soon, Closed, Declared, Available, Released)
        if (publicStatusFilter !== 'all') {
          if (item.contentType === 'government_job' || item.contentType === 'andaman_job') {
            const calculated = calculateJobStatus(item.applicationLastDate, item.statusOverride);
            if (calculated.status !== publicStatusFilter) return false;
          }
        }

        // 5. Search Term Filter
        if (searchTerm.trim()) {
          const q = searchTerm.toLowerCase().trim();
          const matches =
            item.title.toLowerCase().includes(q) ||
            item.organization.toLowerCase().includes(q) ||
            item.jobRole.toLowerCase().includes(q) ||
            (item.location && item.location.toLowerCase().includes(q)) ||
            (item.searchKeywords && item.searchKeywords.some((k) => k.toLowerCase().includes(q)));
          if (!matches) return false;
        }

        return true;
      })
      .sort((a, b) => {
        switch (sortBy) {
          case 'published_desc':
            return (b.publishedAt || b.createdAt || '').localeCompare(a.publishedAt || a.createdAt || '');
          case 'deadline_asc':
            return (a.applicationLastDate || '9999').localeCompare(b.applicationLastDate || '9999');
          case 'views_desc':
            return (b.views || 0) - (a.views || 0);
          case 'title_asc':
            return a.title.localeCompare(b.title);
          case 'updated_desc':
          default:
            return (b.updatedAt || b.createdAt || '').localeCompare(a.updatedAt || a.createdAt || '');
        }
      });
  }, [items, typeFilter, categoryFilter, publishStateTab, publicStatusFilter, searchTerm, sortBy]);

  // Formatted display title
  const displayTitle = useMemo(() => {
    if (pageTitle) return pageTitle;
    if (categoryFilter !== 'all') {
      const catName = categoryMap.get(categoryFilter) || categoryFilter.toUpperCase();
      return `${catName} Jobs`;
    }
    if (typeFilter !== 'all') {
      switch (typeFilter) {
        case 'government_job':
          return 'Government Jobs';
        case 'andaman_job':
          return 'Andaman & Nicobar Jobs';
        case 'admit_card':
          return 'Admit Cards & Hall Tickets';
        case 'result':
          return 'Exam Results';
        case 'answer_key':
          return 'Answer Keys';
        case 'syllabus':
          return 'Exam Syllabus';
        case 'article':
          return 'Editorial Articles';
        default:
          return 'All Content';
      }
    }
    return 'All Content';
  }, [pageTitle, categoryFilter, typeFilter, categoryMap]);

  // Formatted count subtitle
  const displayCountSubtitle = useMemo(() => {
    if (pageSubtitle) return pageSubtitle;
    const count = filteredItems.length;
    const tabLabel = publishStateTab === 'all' ? '' : `${publishStateTab.toUpperCase()} `;
    return `Showing ${count} ${tabLabel}${displayTitle.toLowerCase()}`;
  }, [pageSubtitle, filteredItems.length, publishStateTab, displayTitle]);

  // Helper for Public Status Badge
  const renderPublicStatusBadge = (item: ContentItem) => {
    if (item.contentType === 'government_job' || item.contentType === 'andaman_job') {
      const statusInfo = calculateJobStatus(item.applicationLastDate, item.statusOverride);
      return (
        <span
          className="text-[10px] font-bold px-2 py-0.5 rounded-full inline-flex items-center gap-1 border"
          style={{
            color: statusInfo.color,
            backgroundColor: `${statusInfo.color}10`,
            borderColor: `${statusInfo.color}30`,
          }}
        >
          <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: statusInfo.color }} />
          {statusInfo.label}
        </span>
      );
    }
    if (item.contentType === 'result') {
      return (
        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-orange-50 text-orange-700 border border-orange-200">
          Declared
        </span>
      );
    }
    if (item.contentType === 'admit_card') {
      return (
        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-purple-50 text-purple-700 border border-purple-200">
          Available
        </span>
      );
    }
    if (item.contentType === 'answer_key') {
      return (
        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-sky-50 text-sky-700 border border-sky-200">
          Released
        </span>
      );
    }
    if (item.contentType === 'syllabus') {
      return (
        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-teal-50 text-teal-700 border border-teal-200">
          Syllabus Live
        </span>
      );
    }
    return <span className="text-xs text-slate-400">—</span>;
  };

  // Helper for Content Type Badge
  const renderContentTypeBadge = (item: ContentItem) => {
    if (item.contentType === 'andaman_job') {
      return (
        <span
          className={`text-[11px] font-bold px-2.5 py-0.5 rounded-full inline-flex items-center gap-1 ${
            item.jobType === 'private'
              ? 'bg-indigo-50 text-indigo-700 border border-indigo-200'
              : 'bg-emerald-50 text-[#159B76] border border-emerald-200'
          }`}
        >
          <MapPin className="w-3 h-3" />
          {item.jobType === 'private' ? 'A&N • PRIVATE' : 'A&N • GOVT'}
        </span>
      );
    }
    if (item.contentType === 'government_job') {
      return (
        <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-emerald-50 text-[#159B76] border border-emerald-100 inline-flex items-center gap-1">
          <Landmark className="w-3 h-3" />
          Govt Job
        </span>
      );
    }
    if (item.contentType === 'admit_card') {
      return (
        <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-purple-50 text-purple-700 border border-purple-100 inline-flex items-center gap-1">
          <FileCheck className="w-3 h-3" />
          Admit Card
        </span>
      );
    }
    if (item.contentType === 'result') {
      return (
        <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-orange-50 text-orange-700 border border-orange-100 inline-flex items-center gap-1">
          <Award className="w-3 h-3" />
          Result
        </span>
      );
    }
    if (item.contentType === 'answer_key') {
      return (
        <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-sky-50 text-sky-700 border border-sky-100 inline-flex items-center gap-1">
          <CheckSquare className="w-3 h-3" />
          Answer Key
        </span>
      );
    }
    if (item.contentType === 'syllabus') {
      return (
        <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-teal-50 text-teal-700 border border-teal-100 inline-flex items-center gap-1">
          <BookOpen className="w-3 h-3" />
          Syllabus
        </span>
      );
    }
    if (item.contentType === 'article') {
      return (
        <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-slate-100 text-slate-700 border border-slate-200 inline-flex items-center gap-1">
          <Newspaper className="w-3 h-3" />
          Article
        </span>
      );
    }
    return (
      <AdminBadge variant="slate" size="sm">
        {item.contentType.replace('_', ' ')}
      </AdminBadge>
    );
  };

  return (
    <div className="space-y-6">
      {/* Breadcrumbs & Header Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          {/* Subtle Breadcrumbs */}
          <nav className="flex items-center gap-1.5 text-xs text-slate-400 font-medium mb-1">
            {breadcrumbs.map((crumb, idx) => (
              <React.Fragment key={idx}>
                {idx > 0 && <ChevronRight className="w-3 h-3 text-slate-300" />}
                <span className={idx === breadcrumbs.length - 1 ? 'text-slate-700 font-semibold' : 'hover:text-slate-600'}>
                  {crumb}
                </span>
              </React.Fragment>
            ))}
          </nav>
          <div className="flex items-center gap-3">
            <h1 className="text-xl sm:text-2xl font-extrabold text-slate-900 tracking-tight">
              {displayTitle}
            </h1>
            <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-[#159B76]/10 text-[#159B76] border border-[#159B76]/20">
              {filteredItems.length} items
            </span>
          </div>
          <p className="text-xs text-slate-500 mt-1 font-medium">{displayCountSubtitle}</p>
        </div>

        <AdminButton
          variant="primary"
          size="md"
          icon={<Plus className="w-4 h-4" />}
          onClick={() => onAddNew(typeFilter !== 'all' && typeFilter !== 'jobs' ? (typeFilter as ContentType) : undefined)}
        >
          Add New
        </AdminButton>
      </div>

      {/* Publish State Tabs (All, Published, Draft, Scheduled, Archived) */}
      <div className="flex items-center gap-1 border-b border-slate-200/80 overflow-x-auto pb-px">
        {[
          { id: 'all' as PublishStateFilter, label: 'All', count: tabCounts.all },
          { id: 'published' as PublishStateFilter, label: 'Published', count: tabCounts.published },
          { id: 'draft' as PublishStateFilter, label: 'Drafts', count: tabCounts.draft },
          { id: 'archived' as PublishStateFilter, label: 'Archived', count: tabCounts.archived },
        ].map((tab) => {
          const isActive = publishStateTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setPublishStateTab(tab.id)}
              className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold border-b-2 transition-all whitespace-nowrap ${
                isActive
                  ? 'border-[#159B76] text-[#159B76] font-bold bg-emerald-50/40 rounded-t-lg'
                  : 'border-transparent text-slate-500 hover:text-slate-800 hover:border-slate-300'
              }`}
            >
              <span>{tab.label}</span>
              <span
                className={`text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                  isActive ? 'bg-[#159B76] text-white' : 'bg-slate-100 text-slate-600'
                }`}
              >
                {tab.count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Top Filter & Search Bar */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3.5">
        {/* Search Input */}
        <div className="relative flex-1">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by title, organization, role, location..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-8 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76] text-slate-800 placeholder:text-slate-400"
          />
          {searchTerm && (
            <button
              onClick={() => setSearchTerm('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs"
            >
              ×
            </button>
          )}
        </div>

        {/* Filter Controls Row */}
        <div className="flex items-center flex-wrap gap-2.5">
          {/* Content Type Filter */}
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value as any)}
            className="px-3 py-2 text-xs font-semibold bg-white border border-slate-200 rounded-xl text-slate-700 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
          >
            <option value="all">All Content Types</option>
            <option value="jobs">All Jobs (Govt &amp; A&amp;N)</option>
            <option value="government_job">Government Jobs</option>
            <option value="andaman_job">Andaman &amp; Nicobar Jobs</option>
            <option value="admit_card">Admit Cards</option>
            <option value="result">Exam Results</option>
            <option value="answer_key">Answer Keys</option>
            <option value="syllabus">Syllabus</option>
            <option value="article">Articles</option>
          </select>

          {/* Category Filter */}
          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value as any)}
            className="px-3 py-2 text-xs font-semibold bg-white border border-slate-200 rounded-xl text-slate-700 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
          >
            <option value="all">All Categories</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>

          {/* Public Status Filter */}
          <select
            value={publicStatusFilter}
            onChange={(e) => setPublicStatusFilter(e.target.value)}
            className="px-3 py-2 text-xs font-semibold bg-white border border-slate-200 rounded-xl text-slate-700 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
          >
            <option value="all">All Public Statuses</option>
            <option value="open">Open</option>
            <option value="closing_soon">Closing Soon</option>
            <option value="closing_today">Closing Today</option>
            <option value="closed">Closed</option>
          </select>

          {/* Sort Dropdown */}
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as any)}
            className="px-3 py-2 text-xs font-semibold bg-white border border-slate-200 rounded-xl text-slate-700 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
          >
            <option value="updated_desc">Recently Updated</option>
            <option value="published_desc">Published (Newest)</option>
            <option value="deadline_asc">Deadline (Earliest)</option>
            <option value="views_desc">Most Viewed</option>
            <option value="title_asc">Title (A-Z)</option>
          </select>

          {/* Reset Filters button */}
          {(searchTerm || typeFilter !== currentTypeFilter || categoryFilter !== currentCategoryFilter || publishStateTab !== 'all' || publicStatusFilter !== 'all') && (
            <button
              onClick={() => {
                setSearchTerm('');
                setTypeFilter(currentTypeFilter);
                setCategoryFilter(currentCategoryFilter);
                setPublishStateTab('all');
                setPublicStatusFilter('all');
              }}
              className="p-2 text-xs text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-xl transition-colors"
              title="Reset all filters"
            >
              <RotateCcw className="w-3.5 h-3.5" />
            </button>
          )}
        </div>
      </div>

      {/* Desktop CMS Table View */}
      <div className="hidden md:block bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50/85 border-b border-slate-200 text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                <th className="py-3.5 px-5 min-w-[280px]">Title &amp; Details</th>
                <th className="py-3.5 px-3 whitespace-nowrap">Type</th>
                <th className="py-3.5 px-3 whitespace-nowrap">Category</th>
                <th className="py-3.5 px-3 whitespace-nowrap">Public Status</th>
                <th className="py-3.5 px-3 whitespace-nowrap">Publish State</th>
                <th className="py-3.5 px-3 whitespace-nowrap">Deadline / Date</th>
                <th className="py-3.5 px-3 whitespace-nowrap">Updated</th>
                <th className="py-3.5 px-3 text-right whitespace-nowrap">Views</th>
                <th className="py-3.5 px-5 text-right whitespace-nowrap">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-sm">
              {filteredItems.length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-16 text-center">
                    <div className="max-w-sm mx-auto flex flex-col items-center gap-2.5">
                      <div className="w-12 h-12 rounded-2xl bg-slate-100 flex items-center justify-center text-slate-400">
                        <FileText className="w-6 h-6" />
                      </div>
                      <h3 className="text-sm font-bold text-slate-800">
                        No {displayTitle} Found
                      </h3>
                      <p className="text-xs text-slate-400 text-center">
                        {searchTerm
                          ? `No items match "${searchTerm}". Try adjusting your keywords or clearing filters.`
                          : `There are currently no items matching the selected filters.`}
                      </p>
                      <div className="pt-2">
                        <AdminButton
                          variant="primary"
                          size="sm"
                          icon={<Plus className="w-3.5 h-3.5" />}
                          onClick={() => onAddNew(typeFilter !== 'all' && typeFilter !== 'jobs' ? (typeFilter as ContentType) : undefined)}
                        >
                          Add New {displayTitle.replace('All ', '')}
                        </AdminButton>
                      </div>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredItems.map((item) => {
                  const firstCatId = item.categoryIds?.[0];
                  const catName = firstCatId ? categoryMap.get(firstCatId) : null;

                  return (
                    <tr
                      key={item.id}
                      className="hover:bg-slate-50/80 transition-colors group"
                    >
                      {/* Title & Organization */}
                      <td className="py-3.5 px-5">
                        <p
                          className="font-bold text-slate-900 leading-snug hover:text-[#159B76] cursor-pointer line-clamp-2"
                          onClick={() => onEditItem(item)}
                        >
                          {item.title}
                        </p>
                        <div className="flex items-center gap-2 mt-1 text-xs text-slate-500 font-medium truncate">
                          <span>{item.organization || 'Notify Jobs'}</span>
                          {item.jobRole && (
                            <>
                              <span className="text-slate-300">•</span>
                              <span className="text-slate-600">{item.jobRole}</span>
                            </>
                          )}
                          {item.vacancies && (
                            <>
                              <span className="text-slate-300">•</span>
                              <span className="font-semibold text-slate-700">{item.vacancies} Posts</span>
                            </>
                          )}
                        </div>
                      </td>

                      {/* Content Type */}
                      <td className="py-3.5 px-3 whitespace-nowrap">
                        {renderContentTypeBadge(item)}
                      </td>

                      {/* Category */}
                      <td className="py-3.5 px-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                        {catName ? (
                          <span className="px-2 py-0.5 rounded bg-slate-100 text-slate-700 font-semibold text-[11px]">
                            {catName}
                          </span>
                        ) : (
                          <span className="text-slate-300">—</span>
                        )}
                      </td>

                      {/* Public Status */}
                      <td className="py-3.5 px-3 whitespace-nowrap">
                        {renderPublicStatusBadge(item)}
                      </td>

                      {/* Publish State */}
                      <td className="py-3.5 px-3 whitespace-nowrap">
                        {item.status === 'published' ? (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
                            <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                            Published
                          </span>
                        ) : item.status === 'draft' ? (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold px-2 py-0.5 rounded-full bg-amber-50 text-amber-700 border border-amber-200">
                            <Clock className="w-3 h-3 text-amber-600" />
                            Draft
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 border border-slate-200">
                            <Archive className="w-3 h-3 text-slate-500" />
                            Archived
                          </span>
                        )}
                      </td>

                      {/* Deadline / Exam Date */}
                      <td className="py-3.5 px-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                        {item.applicationLastDate ? (
                          <span className="inline-flex items-center gap-1">
                            <Calendar className="w-3 h-3 text-slate-400" />
                            {item.applicationLastDate}
                          </span>
                        ) : (
                          <span className="text-slate-300">—</span>
                        )}
                      </td>

                      {/* Updated Date */}
                      <td className="py-3.5 px-3 whitespace-nowrap text-xs text-slate-400">
                        {item.updatedAt ? new Date(item.updatedAt).toLocaleDateString() : '—'}
                      </td>

                      {/* Views */}
                      <td className="py-3.5 px-3 text-right whitespace-nowrap text-xs font-semibold text-slate-600">
                        {(item.views || 0).toLocaleString()}
                      </td>

                      {/* Actions */}
                      <td className="py-3.5 px-5 text-right whitespace-nowrap">
                        <div className="flex items-center justify-end gap-1 opacity-90 group-hover:opacity-100">
                          {/* Edit */}
                          <button
                            onClick={() => onEditItem(item)}
                            className="p-1.5 rounded-lg text-[#159B76] hover:text-[#117A5E] hover:bg-emerald-50 transition-colors"
                            title="Edit Content"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>

                          {/* Mobile Preview */}
                          <button
                            onClick={() => onPreviewItem(item)}
                            className="p-1.5 rounded-lg text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors"
                            title="Mobile Preview"
                          >
                            <Smartphone className="w-4 h-4" />
                          </button>

                          {/* Duplicate */}
                          {onDuplicateItem && (
                            <button
                              onClick={() => onDuplicateItem(item)}
                              className="p-1.5 rounded-lg text-indigo-500 hover:text-indigo-700 hover:bg-indigo-50 transition-colors"
                              title="Duplicate as Draft"
                            >
                              <Copy className="w-4 h-4" />
                            </button>
                          )}

                          {/* Quick Publish/Unpublish Toggle */}
                          {onTogglePublish && (
                            <button
                              onClick={() => onTogglePublish(item.id, item.status !== 'published')}
                              className={`p-1.5 rounded-lg transition-colors ${
                                item.status === 'published'
                                  ? 'text-amber-500 hover:text-amber-700 hover:bg-amber-50'
                                  : 'text-emerald-600 hover:text-emerald-800 hover:bg-emerald-50'
                              }`}
                              title={item.status === 'published' ? 'Unpublish to Draft' : 'Publish Live'}
                            >
                              {item.status === 'published' ? (
                                <XCircle className="w-4 h-4" />
                              ) : (
                                <CheckCircle className="w-4 h-4" />
                              )}
                            </button>
                          )}

                          {/* Archive */}
                          <button
                            onClick={() => onArchiveItem(item.id)}
                            className="p-1.5 rounded-lg text-slate-400 hover:text-amber-700 hover:bg-amber-50 transition-colors"
                            title="Archive Content"
                          >
                            <Archive className="w-4 h-4" />
                          </button>

                          {/* Delete */}
                          <button
                            onClick={() => setItemToDelete(item)}
                            className="p-1.5 rounded-lg text-red-400 hover:text-red-700 hover:bg-red-50 transition-colors"
                            title="Delete Permanently"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Mobile Card Layout (Screens < 768px) */}
      <div className="block md:hidden space-y-3">
        {filteredItems.length === 0 ? (
          <div className="bg-white rounded-2xl p-8 text-center text-slate-400 text-xs border border-slate-200">
            No {displayTitle} items found matching your filters.
          </div>
        ) : (
          filteredItems.map((item) => (
            <div
              key={item.id}
              className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm space-y-3"
            >
              <div className="flex items-center justify-between gap-2">
                {renderContentTypeBadge(item)}
                <div className="flex items-center gap-1.5">
                  {renderPublicStatusBadge(item)}
                  <span
                    className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                      item.status === 'published'
                        ? 'bg-emerald-50 text-emerald-700'
                        : 'bg-amber-50 text-amber-700'
                    }`}
                  >
                    {item.status}
                  </span>
                </div>
              </div>

              <div>
                <h4
                  onClick={() => onEditItem(item)}
                  className="text-sm font-bold text-slate-900 leading-snug cursor-pointer hover:text-[#159B76]"
                >
                  {item.title}
                </h4>
                <p className="text-xs text-slate-500 mt-1 font-medium">
                  {item.organization}
                </p>
              </div>

              <div className="grid grid-cols-2 gap-2 text-xs py-2 border-y border-slate-100">
                <div>
                  <span className="text-slate-400 block text-[10px]">Vacancies</span>
                  <span className="font-semibold text-slate-800">
                    {item.vacancies || '—'}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">Last Date</span>
                  <span className="font-semibold text-slate-800">
                    {item.applicationLastDate || '—'}
                  </span>
                </div>
              </div>

              <div className="flex items-center justify-between pt-1">
                <span className="text-xs text-slate-400 font-medium">
                  {(item.views || 0).toLocaleString()} views
                </span>
                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => onPreviewItem(item)}
                    className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100"
                    title="Mobile Preview"
                  >
                    <Smartphone className="w-4 h-4" />
                  </button>
                  {onDuplicateItem && (
                    <button
                      onClick={() => onDuplicateItem(item)}
                      className="p-1.5 rounded-lg text-indigo-500 hover:bg-indigo-50"
                      title="Duplicate"
                    >
                      <Copy className="w-4 h-4" />
                    </button>
                  )}
                  <AdminButton
                    size="sm"
                    variant="outline"
                    onClick={() => onEditItem(item)}
                  >
                    Edit
                  </AdminButton>
                  <button
                    onClick={() => setItemToDelete(item)}
                    className="p-1.5 rounded-lg text-red-500 hover:bg-red-50"
                    title="Delete"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Delete Confirmation Dialog */}
      <AdminConfirmDialog
        isOpen={Boolean(itemToDelete)}
        title="Delete Content Item"
        message={`Are you sure you want to permanently delete "${itemToDelete?.title || 'this item'}"? This action cannot be undone.`}
        confirmLabel="Delete Permanently"
        cancelLabel="Cancel"
        variant="danger"
        loading={deleting}
        onCancel={() => setItemToDelete(null)}
        onConfirm={async () => {
          if (!itemToDelete) return;
          setDeleting(true);
          try {
            await onDeleteItem(itemToDelete.id);
            setItemToDelete(null);
          } finally {
            setDeleting(false);
          }
        }}
      />
    </div>
  );
};

