import React, { useState } from 'react';
import {
  ArrowUp,
  ArrowDown,
  Eye,
  EyeOff,
  Save,
  Sliders,
  Check,
} from 'lucide-react';
import { HomepageSection, Category } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';
import { AdminBadge } from '../components/common/AdminBadge';

interface HomepageManagerPageProps {
  sections: HomepageSection[];
  categories: Category[];
  onSaveSections: (sections: HomepageSection[]) => Promise<void>;
}

export const HomepageManagerPage: React.FC<HomepageManagerPageProps> = ({
  sections: initialSections,
  categories,
  onSaveSections,
}) => {
  const [sections, setSections] = useState<HomepageSection[]>([...initialSections]);
  const [saving, setSaving] = useState(false);
  const [savedSuccess, setSavedSuccess] = useState(false);

  const handleMove = (index: number, direction: 'up' | 'down') => {
    const targetIndex = direction === 'up' ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= sections.length) return;

    const updated = [...sections];
    const temp = updated[index];
    updated[index] = updated[targetIndex];
    updated[targetIndex] = temp;

    // Update orders
    updated.forEach((s, idx) => {
      s.order = idx + 1;
    });

    setSections(updated);
  };

  const handleToggleEnable = (index: number) => {
    const updated = [...sections];
    updated[index].enabled = !updated[index].enabled;
    setSections(updated);
  };

  const handleUpdateField = (index: number, field: keyof HomepageSection, val: any) => {
    const updated = [...sections];
    (updated[index] as any)[field] = val;
    setSections(updated);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await onSaveSections(sections);
      setSavedSuccess(true);
      setTimeout(() => setSavedSuccess(false), 3000);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900">Homepage Layout Manager</h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Configure feed sections, ordering, display limits, and category filters for the mobile app
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          {savedSuccess && (
            <span className="text-xs text-emerald-600 font-semibold flex items-center gap-1">
              <Check className="w-3.5 h-3.5" /> Layout Saved
            </span>
          )}
          <AdminButton
            variant="primary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
            onClick={handleSave}
          >
            Save Layout Order
          </AdminButton>
        </div>
      </div>

      <div className="space-y-3">
        {sections.map((sec, idx) => (
          <AdminCard key={sec.id} noPadding className="transition-all hover:border-slate-300">
            <div className="p-4 sm:p-5 flex flex-col md:flex-row md:items-center justify-between gap-4">
              {/* Left Details */}
              <div className="flex items-start sm:items-center gap-3.5 min-w-0 flex-1">
                {/* Order Controls */}
                <div className="flex sm:flex-col items-center gap-1 flex-shrink-0">
                  <button
                    type="button"
                    disabled={idx === 0}
                    onClick={() => handleMove(idx, 'up')}
                    className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100 disabled:opacity-30 disabled:pointer-events-none"
                    title="Move section up"
                  >
                    <ArrowUp className="w-4 h-4" />
                  </button>
                  <span className="text-xs font-bold text-slate-500 w-4 text-center">
                    {idx + 1}
                  </span>
                  <button
                    type="button"
                    disabled={idx === sections.length - 1}
                    onClick={() => handleMove(idx, 'down')}
                    className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100 disabled:opacity-30 disabled:pointer-events-none"
                    title="Move section down"
                  >
                    <ArrowDown className="w-4 h-4" />
                  </button>
                </div>

                {/* Section Titles */}
                <div className="min-w-0 flex-1 space-y-2">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="text-xs font-mono font-bold text-slate-400 bg-slate-100 px-2 py-0.5 rounded">
                      {sec.key}
                    </span>
                    <AdminBadge variant={sec.enabled ? 'success' : 'slate'} size="sm">
                      {sec.enabled ? 'Visible' : 'Hidden'}
                    </AdminBadge>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                    <input
                      type="text"
                      value={sec.title}
                      onChange={(e) => handleUpdateField(idx, 'title', e.target.value)}
                      placeholder="Section Title"
                      className="text-sm font-bold text-slate-900 border border-slate-200 rounded-lg px-2.5 py-1 focus:border-[#159B76] focus:outline-none"
                    />
                    <input
                      type="text"
                      value={sec.subtitle || ''}
                      onChange={(e) => handleUpdateField(idx, 'subtitle', e.target.value)}
                      placeholder="Optional Subtitle"
                      className="text-xs text-slate-500 border border-slate-200 rounded-lg px-2.5 py-1 focus:border-[#159B76] focus:outline-none"
                    />
                  </div>
                </div>
              </div>

              {/* Right Configuration Controls */}
              <div className="flex items-center flex-wrap sm:flex-nowrap gap-3 pl-8 sm:pl-0 border-t sm:border-t-0 pt-2 sm:pt-0 border-slate-100">
                <div className="w-24">
                  <label className="block text-[10px] font-semibold text-slate-400 mb-0.5">
                    Item Limit
                  </label>
                  <input
                    type="number"
                    min={1}
                    max={20}
                    value={sec.limit}
                    onChange={(e) =>
                      handleUpdateField(idx, 'limit', parseInt(e.target.value) || 4)
                    }
                    className="w-full text-xs font-bold text-slate-800 border border-slate-200 rounded-lg px-2 py-1"
                  />
                </div>

                <div className="w-32">
                  <label className="block text-[10px] font-semibold text-slate-400 mb-0.5">
                    Sorting
                  </label>
                  <select
                    value={sec.sort}
                    onChange={(e) => handleUpdateField(idx, 'sort', e.target.value)}
                    className="w-full text-xs font-medium text-slate-800 border border-slate-200 rounded-lg px-2 py-1"
                  >
                    <option value="publishedAt_desc">Newest First</option>
                    <option value="views_desc">Most Viewed</option>
                    <option value="deadline_asc">Closing Soon</option>
                    <option value="order_asc">Default Order</option>
                  </select>
                </div>

                <button
                  type="button"
                  onClick={() => handleToggleEnable(idx)}
                  className={`p-2 rounded-xl transition-colors ${
                    sec.enabled
                      ? 'bg-emerald-50 text-[#159B76] hover:bg-emerald-100'
                      : 'bg-slate-100 text-slate-400 hover:bg-slate-200'
                  }`}
                  title={sec.enabled ? 'Disable section' : 'Enable section'}
                >
                  {sec.enabled ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                </button>
              </div>
            </div>
          </AdminCard>
        ))}
      </div>
    </div>
  );
};
