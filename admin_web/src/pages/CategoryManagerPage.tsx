import React, { useState } from 'react';
import { Plus, Edit2, Trash2, Layers, Check, ArrowUp, ArrowDown } from 'lucide-react';
import { Category } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';
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
  const [editingCategory, setEditingCategory] = useState<Partial<Category> | null>(null);
  const [name, setName] = useState('');
  const [slug, setSlug] = useState('');
  const [icon, setIcon] = useState('Briefcase');
  const [color, setColor] = useState('#159B76');
  const [isActive, setIsActive] = useState(true);
  const [loading, setLoading] = useState(false);

  const handleOpenAdd = () => {
    setEditingCategory(null);
    setName('');
    setSlug('');
    setIcon('Briefcase');
    setColor('#159B76');
    setIsActive(true);
    setModalOpen(true);
  };

  const handleOpenEdit = (cat: Category) => {
    setEditingCategory(cat);
    setName(cat.name);
    setSlug(cat.slug);
    setIcon(cat.icon);
    setColor(cat.color);
    setIsActive(cat.isActive);
    setModalOpen(true);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await onSaveCategory({
        ...(editingCategory || {}),
        name,
        slug: slug || name.toLowerCase().replace(/[^a-z0-9]/g, '-'),
        icon,
        color,
        isActive,
      });
      setModalOpen(false);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900">Categories Manager</h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Organize government job departments, exams, and quick navigation filters
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
        <div className="divide-y divide-slate-100">
          {categories.map((cat, idx) => (
            <div
              key={cat.id}
              className="p-4 sm:px-6 flex items-center justify-between gap-4 hover:bg-slate-50/70 transition-colors"
            >
              <div className="flex items-center gap-3 min-w-0">
                <div
                  className="w-10 h-10 rounded-2xl flex items-center justify-center text-white font-bold text-sm shadow-sm"
                  style={{ backgroundColor: cat.color }}
                >
                  {cat.name.charAt(0)}
                </div>
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <h4 className="text-sm font-bold text-slate-900 truncate">
                      {cat.name}
                    </h4>
                    <AdminBadge
                      variant={cat.isActive ? 'success' : 'slate'}
                      size="sm"
                    >
                      {cat.isActive ? 'Active' : 'Hidden'}
                    </AdminBadge>
                  </div>
                  <p className="text-xs text-slate-400 mt-0.5 font-mono">
                    slug: {cat.slug} • icon: {cat.icon}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <button
                  onClick={() => handleOpenEdit(cat)}
                  className="p-2 rounded-xl text-slate-500 hover:text-[#159B76] hover:bg-slate-100 transition-colors"
                  title="Edit Category"
                >
                  <Edit2 className="w-4 h-4" />
                </button>
                <button
                  onClick={() => onDeleteCategory(cat.id)}
                  className="p-2 rounded-xl text-red-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                  title="Delete Category"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </AdminCard>

      {/* Category Editor Modal */}
      <AdminModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editingCategory ? 'Edit Category' : 'Add New Category'}
      >
        <form onSubmit={handleSave} className="space-y-4">
          <AdminInput
            label="Category Name"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g. Andaman & Nicobar Jobs"
          />

          <AdminInput
            label="URL Slug"
            value={slug}
            onChange={(e) => setSlug(e.target.value)}
            placeholder="e.g. andaman-nicobar"
          />

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

          <label className="flex items-center gap-2.5 pt-2 cursor-pointer">
            <input
              type="checkbox"
              checked={isActive}
              onChange={(e) => setIsActive(e.target.checked)}
              className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
            />
            <span className="text-xs font-semibold text-slate-800">
              Show in App (Active)
            </span>
          </label>

          <div className="pt-4 flex items-center justify-end gap-2.5">
            <AdminButton
              type="button"
              variant="outline"
              onClick={() => setModalOpen(false)}
            >
              Cancel
            </AdminButton>
            <AdminButton type="submit" variant="primary" loading={loading}>
              Save Category
            </AdminButton>
          </div>
        </form>
      </AdminModal>
    </div>
  );
};
