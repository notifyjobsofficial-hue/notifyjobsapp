import React, { useState } from 'react';
import { Plus, Edit2, Trash2, ArrowUp, ArrowDown, ShieldAlert, Check, X } from 'lucide-react';
import { Category } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';
import { AdminModal } from '../components/common/AdminModal';
import { AdminBadge } from '../components/common/AdminBadge';

interface CategoryManagerPageProps {
  categories: Category[];
  onSaveCategory: (category: Partial<Category>) => Promise<void>;
  onDeleteCategory: (id: string) => Promise<void>;
}

export const CategoryManagerPage: React.FC<CategoryManagerPageProps> = ({
  categories,
  onSaveCategory,
  onDeleteCategory,
}) => {
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [categoryToDelete, setCategoryToDelete] = useState<Category | null>(null);
  const [editingCategory, setEditingCategory] = useState<Partial<Category> | null>(null);
  
  const [name, setName] = useState('');
  const [shortName, setShortName] = useState('');
  const [slug, setSlug] = useState('');
  const [icon, setIcon] = useState('Briefcase');
  const [color, setColor] = useState('#159B76');
  const [contentScope, setContentScope] = useState<'job' | 'update' | 'article' | 'all'>('job');
  const [order, setOrder] = useState<number>(1);
  const [isActive, setIsActive] = useState(true);
  const [showOnHome, setShowOnHome] = useState(true);
  const [showInUserApp, setShowInUserApp] = useState(true);
  const [showInQuickCategories, setShowInQuickCategories] = useState(true);
  const [showInJobsFilters, setShowInJobsFilters] = useState(true);
  const [showInUpdates, setShowInUpdates] = useState(true);
  const [showInSearch, setShowInSearch] = useState(true);
  const [showInAdminSidebar, setShowInAdminSidebar] = useState(true);
  const [destination, setDestination] = useState('');
  const [loading, setLoading] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  const handleOpenAdd = () => {
    setEditingCategory(null);
    setName('');
    setShortName('');
    setSlug('');
    setIcon('Briefcase');
    setColor('#159B76');
    setContentScope('job');
    setOrder(categories.length + 1);
    setIsActive(true);
    setShowOnHome(true);
    setShowInUserApp(true);
    setShowInQuickCategories(true);
    setShowInJobsFilters(true);
    setShowInUpdates(true);
    setShowInSearch(true);
    setShowInAdminSidebar(true);
    setDestination('');
    setModalOpen(true);
  };

  const handleOpenEdit = (cat: Category) => {
    setEditingCategory(cat);
    setName(cat.name);
    setShortName(cat.shortName || cat.name);
    setSlug(cat.slug);
    setIcon(cat.icon);
    setColor(cat.color);
    setContentScope(cat.contentScope || 'job');
    setOrder(cat.order || 99);
    setIsActive(cat.isActive !== false);
    setShowOnHome(cat.showOnHome !== false);
    setShowInUserApp(cat.showInUserApp !== false);
    setShowInQuickCategories(cat.showInQuickCategories !== false);
    setShowInJobsFilters(cat.showInJobsFilters !== false);
    setShowInUpdates(cat.showInUpdates !== false);
    setShowInSearch(cat.showInSearch !== false);
    setShowInAdminSidebar(cat.showInAdminSidebar !== false);
    setDestination(cat.destination || '');
    setModalOpen(true);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setSaveError(null);
    try {
      await onSaveCategory({
        ...(editingCategory || {}),
        name: name.trim(),
        shortName: shortName.trim() || name.trim(),
        slug: slug.trim() || name.toLowerCase().replace(/[^a-z0-9]/g, '-'),
        icon: icon.trim(),
        color,
        contentScope,
        order: Number(order) || 99,
        isActive,
        showOnHome,
        showInUserApp,
        showInQuickCategories,
        showInJobsFilters,
        showInUpdates,
        showInSearch,
        showInAdminSidebar,
        destination: destination.trim() || undefined,
      });
      setModalOpen(false);
    } catch (err) {
      setSaveError(String(err) || 'Failed to save category. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleQuickToggleActive = async (cat: Category) => {
    await onSaveCategory({
      ...cat,
      isActive: !cat.isActive,
    });
  };

  const handleQuickToggleHome = async (cat: Category) => {
    await onSaveCategory({
      ...cat,
      showOnHome: cat.showOnHome === false ? true : false,
    });
  };

  const handleMoveOrder = async (cat: Category, direction: 'up' | 'down') => {
    const sorted = [...categories].sort((a, b) => (a.order || 99) - (b.order || 99));
    const currentIndex = sorted.findIndex((c) => c.id === cat.id);
    if (currentIndex === -1) return;

    const targetIndex = direction === 'up' ? currentIndex - 1 : currentIndex + 1;
    if (targetIndex < 0 || targetIndex >= sorted.length) return;

    const targetCat = sorted[targetIndex];
    const currentOrder = cat.order || (currentIndex + 1);
    const targetOrder = targetCat.order || (targetIndex + 1);

    // Swap orders
    await onSaveCategory({ ...cat, order: targetOrder });
    await onSaveCategory({ ...targetCat, order: currentOrder });
  };

  const handleConfirmDelete = async () => {
    if (!categoryToDelete) return;
    setLoading(true);
    try {
      await onDeleteCategory(categoryToDelete.id);
      setDeleteModalOpen(false);
      setCategoryToDelete(null);
    } finally {
      setLoading(false);
    }
  };

  const sortedCategories = [...categories].sort((a, b) => (a.order || 99) - (b.order || 99));

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900">Categories Manager</h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Manage navigation chips, scopes, short names, and home screen quick grid display
          </p>
        </div>
        <AdminButton
          variant="primary"
          size="sm"
          icon={<Plus className="w-4 h-4" />}
          onClick={handleOpenAdd}
        >
          Add Category
        </AdminButton>
      </div>

      <AdminCard noPadding>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-700">
            <thead className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-bold text-slate-500 uppercase tracking-wider">
              <tr>
                <th className="py-3.5 px-4">Order</th>
                <th className="py-3.5 px-4">Name</th>
                <th className="py-3.5 px-4">Short Name</th>
                <th className="py-3.5 px-4">Scope</th>
                <th className="py-3.5 px-4">Destination</th>
                <th className="py-3.5 px-4 text-center">Active</th>
                <th className="py-3.5 px-4 text-center">Home Grid</th>
                <th className="py-3.5 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {sortedCategories.map((cat, idx) => (
                <tr
                  key={cat.id}
                  className="hover:bg-slate-50/70 transition-colors group"
                >
                  {/* Order & Reorder arrows */}
                  <td className="py-3 px-4 whitespace-nowrap">
                    <div className="flex items-center gap-1.5">
                      <span className="font-bold text-slate-800 text-xs w-5 text-center">
                        {cat.order ?? idx + 1}
                      </span>
                      <div className="flex flex-col">
                        <button
                          type="button"
                          disabled={idx === 0}
                          onClick={() => handleMoveOrder(cat, 'up')}
                          className="p-0.5 text-slate-400 hover:text-slate-700 disabled:opacity-20 transition-colors"
                          title="Move Up"
                        >
                          <ArrowUp className="w-3 h-3" />
                        </button>
                        <button
                          type="button"
                          disabled={idx === sortedCategories.length - 1}
                          onClick={() => handleMoveOrder(cat, 'down')}
                          className="p-0.5 text-slate-400 hover:text-slate-700 disabled:opacity-20 transition-colors"
                          title="Move Down"
                        >
                          <ArrowDown className="w-3 h-3" />
                        </button>
                      </div>
                    </div>
                  </td>

                  {/* Name & Icon */}
                  <td className="py-3 px-4">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-8 h-8 rounded-xl flex items-center justify-center text-white font-bold text-xs shadow-sm flex-shrink-0"
                        style={{ backgroundColor: cat.color || '#159B76' }}
                      >
                        {cat.name.charAt(0)}
                      </div>
                      <div className="min-w-0">
                        <p className="font-bold text-slate-900 truncate">{cat.name}</p>
                        <p className="text-[10px] text-slate-400 font-mono truncate">
                          {cat.slug} • {cat.icon}
                        </p>
                      </div>
                    </div>
                  </td>

                  {/* Short Name */}
                  <td className="py-3 px-4 whitespace-nowrap font-medium text-slate-800">
                    <span className="bg-slate-100 px-2 py-0.5 rounded text-[11px] font-semibold text-slate-700">
                      {cat.shortName || cat.name}
                    </span>
                  </td>

                  {/* Scope */}
                  <td className="py-3 px-4 whitespace-nowrap">
                    <AdminBadge
                      variant={
                        cat.contentScope === 'update'
                          ? 'warning'
                          : cat.contentScope === 'article'
                          ? 'slate'
                          : 'primary'
                      }
                      size="sm"
                    >
                      {cat.contentScope ? cat.contentScope.toUpperCase() : 'JOB'}
                    </AdminBadge>
                  </td>

                  {/* Destination */}
                  <td className="py-3 px-4 whitespace-nowrap text-slate-500 font-mono text-[11px]">
                    {cat.destination || '—'}
                  </td>

                  {/* Active Toggle */}
                  <td className="py-3 px-4 whitespace-nowrap text-center">
                    <button
                      type="button"
                      onClick={() => handleQuickToggleActive(cat)}
                      className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold transition-all ${
                        cat.isActive !== false
                          ? 'bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100'
                          : 'bg-slate-100 text-slate-400 border border-slate-200 hover:bg-slate-200'
                      }`}
                    >
                      {cat.isActive !== false ? (
                        <>
                          <Check className="w-3 h-3 text-emerald-600" /> Active
                        </>
                      ) : (
                        <>
                          <X className="w-3 h-3 text-slate-400" /> Off
                        </>
                      )}
                    </button>
                  </td>

                  {/* Show on Home Toggle */}
                  <td className="py-3 px-4 whitespace-nowrap text-center">
                    <button
                      type="button"
                      onClick={() => handleQuickToggleHome(cat)}
                      className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold transition-all ${
                        cat.showOnHome !== false
                          ? 'bg-indigo-50 text-indigo-700 border border-indigo-200 hover:bg-indigo-100'
                          : 'bg-slate-100 text-slate-400 border border-slate-200 hover:bg-slate-200'
                      }`}
                    >
                      {cat.showOnHome !== false ? 'Shown' : 'Hidden'}
                    </button>
                  </td>

                  {/* Actions */}
                  <td className="py-3 px-4 whitespace-nowrap text-right">
                    <div className="flex items-center justify-end gap-1.5">
                      <button
                        type="button"
                        onClick={() => handleOpenEdit(cat)}
                        className="p-1.5 rounded-lg text-slate-500 hover:text-[#159B76] hover:bg-emerald-50 transition-colors"
                        title="Edit Category"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setCategoryToDelete(cat);
                          setDeleteModalOpen(true);
                        }}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                        title="Delete Category"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </AdminCard>

      {/* Category Editor Modal */}
      <AdminModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editingCategory ? 'Edit Category' : 'Add New Category'}
      >
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <AdminInput
              label="Category Name (Full)"
              required
              value={name}
              onChange={(e) => {
                setName(e.target.value);
                if (!shortName) setShortName(e.target.value.slice(0, 15));
              }}
              placeholder="e.g. Andaman & Nicobar Jobs"
            />

            <AdminInput
              label="Short Name (App Chips & Cards)"
              required
              value={shortName}
              onChange={(e) => setShortName(e.target.value)}
              placeholder="e.g. A&N Jobs"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <AdminInput
              label="URL Slug"
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              placeholder="e.g. andaman-nicobar"
            />
            <AdminSelect
              label="Content Scope"
              value={contentScope}
              onChange={(e) =>
                setContentScope(e.target.value as 'job' | 'update' | 'article' | 'all')
              }
              options={[
                { value: 'job', label: 'Jobs Section' },
                { value: 'update', label: 'Updates Section' },
                { value: 'article', label: 'Articles' },
                { value: 'all', label: 'All Content' },
              ]}
            />
            <AdminInput
              label="Sort Order"
              type="number"
              value={order}
              onChange={(e) => setOrder(parseInt(e.target.value, 10) || 1)}
              placeholder="1, 2, 3..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <AdminInput
              label="Icon Name"
              value={icon}
              onChange={(e) => setIcon(e.target.value)}
              placeholder="e.g. MapPin, Train, Shield"
            />
            <AdminInput
              label="Accent Color (Hex)"
              type="color"
              value={color}
              onChange={(e) => setColor(e.target.value)}
            />
          </div>

          <AdminInput
            label="Custom Destination Route (Optional)"
            value={destination}
            onChange={(e) => setDestination(e.target.value)}
            placeholder="e.g. /jobs?category=andaman-nicobar or /updates?tab=results"
          />

          <div className="space-y-2.5 pt-2 border-t border-slate-100">
            <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
              Visibility & App Placement Controls
            </div>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={isActive}
                onChange={(e) => setIsActive(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Is Active (Enabled in System)
              </span>
            </label>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={showInUserApp}
                onChange={(e) => setShowInUserApp(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Show in User App (Master Visibility Switch)
              </span>
            </label>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={showOnHome}
                onChange={(e) => setShowOnHome(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Show on Home Screen
              </span>
            </label>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={showInQuickCategories}
                onChange={(e) => setShowInQuickCategories(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Show in Home Quick Categories Chips/Grid
              </span>
            </label>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={showInJobsFilters}
                onChange={(e) => setShowInJobsFilters(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Show in Jobs Filter Bar
              </span>
            </label>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={showInUpdates}
                onChange={(e) => setShowInUpdates(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Show in Updates Tabs / Screen
              </span>
            </label>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={showInSearch}
                onChange={(e) => setShowInSearch(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Show in Search Screen Category Filter Pills
              </span>
            </label>

            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={showInAdminSidebar}
                onChange={(e) => setShowInAdminSidebar(e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
              <span className="text-xs font-semibold text-slate-800">
                Show in Admin Sidebar
              </span>
            </label>
          </div>

          <div className="pt-4 flex flex-col gap-2.5">
            {saveError && (
              <p className="text-xs text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2">
                ❌ {saveError}
              </p>
            )}
            <div className="flex items-center justify-end gap-2.5">
              <AdminButton
                type="button"
                variant="outline"
                onClick={() => {
                  setModalOpen(false);
                  setSaveError(null);
                }}
              >
                Cancel
              </AdminButton>
              <AdminButton type="submit" variant="primary" loading={loading}>
                Save Category
              </AdminButton>
            </div>
          </div>
        </form>
      </AdminModal>

      {/* Safe Delete Confirmation Modal */}
      <AdminModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        title="Delete Category?"
      >
        <div className="space-y-4">
          <div className="flex items-start gap-3 p-3.5 bg-amber-50 border border-amber-200 rounded-xl text-amber-900 text-xs">
            <ShieldAlert className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
            <div className="space-y-1">
              <p className="font-bold">Caution: Posts may be linked to this category</p>
              <p className="text-amber-800 leading-relaxed">
                Deleting <strong className="text-slate-900">{categoryToDelete?.name}</strong> will remove it from mobile category filters and the home screen grid. Existing posts under this category will retain their category ID but won't have this filter pill.
              </p>
            </div>
          </div>

          <p className="text-xs text-slate-600">
            Are you sure you want to permanently delete this category?
          </p>

          <div className="pt-2 flex items-center justify-end gap-2.5">
            <AdminButton
              type="button"
              variant="outline"
              onClick={() => setDeleteModalOpen(false)}
            >
              Cancel
            </AdminButton>
            <AdminButton
              type="button"
              variant="danger"
              loading={loading}
              onClick={handleConfirmDelete}
            >
              Confirm Delete
            </AdminButton>
          </div>
        </div>
      </AdminModal>
    </div>
  );
};
