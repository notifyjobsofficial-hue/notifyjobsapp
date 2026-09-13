import React, { useState, useMemo } from 'react';
import {
  Search,
  Filter,
  Plus,
  Eye,
  Edit2,
  Archive,
  Trash2,
  Smartphone,
  CheckCircle2,
  AlertTriangle,
  Clock,
} from 'lucide-react';
import { ContentItem, ContentType, ContentStatus } from '../types';
import { AdminButton } from '../components/common/AdminButton';
import { AdminBadge } from '../components/common/AdminBadge';
import { calculateJobStatus } from '../services/contentService';

interface ContentListPageProps {
  items: ContentItem[];
  currentTypeFilter?: ContentType | 'all';
  onEditItem: (item: ContentItem) => void;
  onAddNew: () => void;
  onPreviewItem: (item: ContentItem) => void;
  onArchiveItem: (id: string) => void;
  onDeleteItem: (id: string) => void;
}

export const ContentListPage: React.FC<ContentListPageProps> = ({
  items,
  currentTypeFilter = 'all',
  onEditItem,
  onAddNew,
  onPreviewItem,
  onArchiveItem,
  onDeleteItem,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState<ContentType | 'all'>(currentTypeFilter);
  const [statusFilter, setStatusFilter] = useState<ContentStatus | 'all'>('all');

  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      if (typeFilter !== 'all' && item.contentType !== typeFilter) return false;
      if (statusFilter !== 'all' && item.status !== statusFilter) return false;
      if (searchTerm) {
        const q = searchTerm.toLowerCase();
        const matches =
          item.title.toLowerCase().includes(q) ||
          item.organization.toLowerCase().includes(q) ||
          item.jobRole.toLowerCase().includes(q) ||
          (item.location && item.location.toLowerCase().includes(q));
        if (!matches) return false;
      }
      return true;
    });
  }, [items, typeFilter, statusFilter, searchTerm]);

  return (
    <div className="space-y-6">
      {/* Top Filter & Search Bar */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm flex flex-col md:flex-row items-stretch md:items-center justify-between gap-4">
        {/* Search Input */}
        <div className="relative flex-1">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by title, department, role, location..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76] text-slate-800 placeholder:text-slate-400"
          />
        </div>

        {/* Filters */}
        <div className="flex items-center flex-wrap gap-2.5">
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value as any)}
            className="px-3 py-2 text-xs font-semibold bg-white border border-slate-200 rounded-xl text-slate-700 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
          >
            <option value="all">All Content Types</option>
            <option value="government_job">Government Jobs</option>
            <option value="private_job">Private Jobs</option>
            <option value="admit_card">Admit Cards</option>
            <option value="result">Results</option>
            <option value="answer_key">Answer Keys</option>
            <option value="syllabus">Syllabus</option>
            <option value="article">Articles</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as any)}
            className="px-3 py-2 text-xs font-semibold bg-white border border-slate-200 rounded-xl text-slate-700 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
          >
            <option value="all">All Statuses</option>
            <option value="published">Published</option>
            <option value="draft">Drafts</option>
            <option value="archived">Archived</option>
          </select>

          <AdminButton
            variant="primary"
            size="sm"
            icon={<Plus className="w-3.5 h-3.5" />}
            onClick={onAddNew}
          >
            Add New
          </AdminButton>
        </div>
      </div>

      {/* Results Counter */}
      <div className="flex items-center justify-between text-xs text-slate-500 px-1">
        <span>
          Showing <strong>{filteredItems.length}</strong> items
        </span>
      </div>

      {/* Responsive Content Display: Wide Table on Desktop, Cards on Mobile */}
      {/* Desktop Table View */}
      <div className="hidden md:block bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50/75 border-b border-slate-200 text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                <th className="py-3.5 px-6 min-w-[320px] w-2/5">Title &amp; Organization</th>
                <th className="py-3.5 px-4 whitespace-nowrap">Type</th>
                <th className="py-3.5 px-4 whitespace-nowrap">Role</th>
                <th className="py-3.5 px-4 whitespace-nowrap">Vacancies</th>
                <th className="py-3.5 px-4 whitespace-nowrap">Last Date</th>
                <th className="py-3.5 px-4 whitespace-nowrap">Status</th>
                <th className="py-3.5 px-4 text-right whitespace-nowrap">Views</th>
                <th className="py-3.5 px-6 text-right whitespace-nowrap">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-sm">
              {filteredItems.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400 text-xs">
                    No items found matching your filters.
                  </td>
                </tr>
              ) : (
                filteredItems.map((item) => {
                  const statusInfo = calculateJobStatus(
                    item.applicationLastDate,
                    item.statusOverride
                  );
                  return (
                    <tr
                      key={item.id}
                      className="hover:bg-slate-50/70 transition-colors group"
                    >
                      {/* Title & Organization (Largest Column, No Wrapping Word by Word) */}
                      <td className="py-4 px-6">
                        <p className="font-semibold text-slate-900 leading-snug hover:text-[#159B76] cursor-pointer line-clamp-2"
                           onClick={() => onEditItem(item)}>
                          {item.title}
                        </p>
                        <p className="text-xs text-slate-500 mt-1 font-medium truncate">
                          {item.organization}
                        </p>
                      </td>

                      {/* Content Type */}
                      <td className="py-4 px-4 whitespace-nowrap">
                        <AdminBadge variant="slate" size="sm">
                          {item.contentType.replace('_', ' ')}
                        </AdminBadge>
                      </td>

                      {/* Role */}
                      <td className="py-4 px-4 whitespace-nowrap text-xs text-slate-700 font-medium">
                        {item.jobRole || '—'}
                      </td>

                      {/* Vacancies */}
                      <td className="py-4 px-4 whitespace-nowrap text-xs font-bold text-slate-800">
                        {item.vacancies || '—'}
                      </td>

                      {/* Last Date */}
                      <td className="py-4 px-4 whitespace-nowrap text-xs text-slate-600">
                        {item.applicationLastDate || '—'}
                      </td>

                      {/* Status */}
                      <td className="py-4 px-4 whitespace-nowrap">
                        <div className="flex flex-col gap-1 items-start">
                          <AdminBadge
                            variant={
                              item.status === 'published'
                                ? 'success'
                                : item.status === 'draft'
                                ? 'warning'
                                : 'slate'
                            }
                            size="sm"
                          >
                            {item.status}
                          </AdminBadge>
                          {item.contentType === 'government_job' && (
                            <span
                              className="text-[10px] font-bold px-1.5 py-0.5 rounded"
                              style={{
                                color: statusInfo.color,
                                backgroundColor: `${statusInfo.color}15`,
                              }}
                            >
                              {statusInfo.label}
                            </span>
                          )}
                        </div>
                      </td>

                      {/* Views */}
                      <td className="py-4 px-4 text-right whitespace-nowrap text-xs font-medium text-slate-500">
                        {item.views.toLocaleString()}
                      </td>

                      {/* Actions */}
                      <td className="py-4 px-6 text-right whitespace-nowrap">
                        <div className="flex items-center justify-end gap-1.5 opacity-90 group-hover:opacity-100">
                          <button
                            onClick={() => onPreviewItem(item)}
                            className="p-1.5 rounded-lg text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors"
                            title="Mobile Preview"
                          >
                            <Smartphone className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => onEditItem(item)}
                            className="p-1.5 rounded-lg text-[#159B76] hover:text-[#117A5E] hover:bg-emerald-50 transition-colors"
                            title="Edit"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => onArchiveItem(item.id)}
                            className="p-1.5 rounded-lg text-amber-600 hover:text-amber-800 hover:bg-amber-50 transition-colors"
                            title="Archive"
                          >
                            <Archive className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => onDeleteItem(item.id)}
                            className="p-1.5 rounded-lg text-red-500 hover:text-red-700 hover:bg-red-50 transition-colors"
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

      {/* Mobile Cards View (Screen < 768px) */}
      <div className="block md:hidden space-y-3">
        {filteredItems.length === 0 ? (
          <div className="bg-white rounded-2xl p-8 text-center text-slate-400 text-xs border border-slate-200">
            No items found matching your filters.
          </div>
        ) : (
          filteredItems.map((item) => {
            const statusInfo = calculateJobStatus(
              item.applicationLastDate,
              item.statusOverride
            );
            return (
              <div
                key={item.id}
                className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm space-y-3"
              >
                <div className="flex items-center justify-between gap-2">
                  <AdminBadge variant="slate" size="sm">
                    {item.contentType.replace('_', ' ')}
                  </AdminBadge>
                  <div className="flex items-center gap-1.5">
                    <AdminBadge
                      variant={item.status === 'published' ? 'success' : 'warning'}
                      size="sm"
                    >
                      {item.status}
                    </AdminBadge>
                    {item.contentType === 'government_job' && (
                      <span
                        className="text-[10px] font-bold px-2 py-0.5 rounded-full"
                        style={{
                          color: statusInfo.color,
                          backgroundColor: `${statusInfo.color}15`,
                        }}
                      >
                        {statusInfo.label}
                      </span>
                    )}
                  </div>
                </div>

                <div>
                  <h4
                    onClick={() => onEditItem(item)}
                    className="text-sm font-bold text-slate-900 leading-snug cursor-pointer"
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
                      {item.vacancies || 'N/A'}
                    </span>
                  </div>
                  <div>
                    <span className="text-slate-400 block text-[10px]">Last Date</span>
                    <span className="font-semibold text-slate-800">
                      {item.applicationLastDate || 'N/A'}
                    </span>
                  </div>
                </div>

                <div className="flex items-center justify-between pt-1">
                  <span className="text-xs text-slate-400 font-medium">
                    {item.views.toLocaleString()} views
                  </span>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => onPreviewItem(item)}
                      className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100"
                    >
                      <Smartphone className="w-4 h-4" />
                    </button>
                    <AdminButton
                      size="sm"
                      variant="outline"
                      onClick={() => onEditItem(item)}
                    >
                      Edit
                    </AdminButton>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
