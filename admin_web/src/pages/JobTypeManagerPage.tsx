import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, ArrowUp, ArrowDown, Briefcase, Check, X, ShieldAlert } from 'lucide-react';
import { JobTypeItem } from '../types';
import { fetchJobTypes, saveJobType, deleteJobType, reorderJobTypes } from '../services/jobTypeService';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';
import { AdminModal } from '../components/common/AdminModal';
import { AdminBadge } from '../components/common/AdminBadge';

export const JobTypeManagerPage: React.FC = () => {
  const [jobTypes, setJobTypes] = useState<JobTypeItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [itemToDelete, setItemToDelete] = useState<JobTypeItem | null>(null);
  const [editingItem, setEditingItem] = useState<Partial<JobTypeItem> | null>(null);

  const [name, setName] = useState('');
  const [shortName, setShortName] = useState('');
  const [slug, setSlug] = useState('');
  const [description, setDescription] = useState('');
  const [colorToken, setColorToken] = useState('blue');
  const [order, setOrder] = useState<number>(1);
  const [isActive, setIsActive] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  const loadData = async () => {
    setLoading(true);
    try {
      const data = await fetchJobTypes();
      setJobTypes(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleOpenAdd = () => {
    setEditingItem(null);
    setName('');
    setShortName('');
    setSlug('');
    setDescription('');
    setColorToken('blue');
    setOrder(jobTypes.length + 1);
    setIsActive(true);
    setSaveError(null);
    setModalOpen(true);
  };

  const handleOpenEdit = (item: JobTypeItem) => {
    setEditingItem(item);
    setName(item.name);
    setShortName(item.shortName || item.name);
    setSlug(item.slug);
    setDescription(item.description || '');
    setColorToken(item.colorToken || 'blue');
    setOrder(item.order || 99);
    setIsActive(item.isActive !== false);
    setSaveError(null);
    setModalOpen(true);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setSaveError('Job type name is required.');
      return;
    }

    setSubmitting(true);
    setSaveError(null);

    const generatedSlug = slug.trim()
      ? slug.trim().toLowerCase().replace(/[^a-z0-9]+/g, '-')
      : name.trim().toLowerCase().replace(/[^a-z0-9]+/g, '-');

    const payload: Partial<JobTypeItem> = {
      id: editingItem?.id || generatedSlug,
      name: name.trim(),
      shortName: (shortName.trim() || name.trim()).slice(0, 24),
      slug: generatedSlug,
      description: description.trim(),
      colorToken,
      order,
      isActive,
    };

    try {
      await saveJobType(payload);
      setModalOpen(false);
      await loadData();
    } catch (err: any) {
      setSaveError(err.message || 'Failed to save job type.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleReorder = async (index: number, direction: 'up' | 'down') => {
    if (
      (direction === 'up' && index === 0) ||
      (direction === 'down' && index === jobTypes.length - 1)
    ) {
      return;
    }

    const targetIndex = direction === 'up' ? index - 1 : index + 1;
    const reordered = [...jobTypes];
    const [moved] = reordered.splice(index, 1);
    reordered.splice(targetIndex, 0, moved);

    setJobTypes(reordered);
    await reorderJobTypes(reordered);
  };

  const handleToggleActive = async (item: JobTypeItem) => {
    const updated = { ...item, isActive: !item.isActive };
    const newList = jobTypes.map((j) => (j.id === item.id ? updated : j));
    setJobTypes(newList);
    await saveJobType({ id: item.id, isActive: !item.isActive });
  };

  const confirmDelete = async () => {
    if (!itemToDelete) return;
    setSubmitting(true);
    try {
      await deleteJobType(itemToDelete.id);
      setDeleteModalOpen(false);
      setItemToDelete(null);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setSubmitting(false);
    }
  };

  const getColorClasses = (token: string) => {
    switch (token) {
      case 'emerald':
        return 'bg-emerald-50 text-emerald-700 border-emerald-200';
      case 'blue':
        return 'bg-blue-50 text-blue-700 border-blue-200';
      case 'amber':
        return 'bg-amber-50 text-amber-700 border-amber-200';
      case 'purple':
        return 'bg-purple-50 text-purple-700 border-purple-200';
      case 'cyan':
        return 'bg-cyan-50 text-cyan-700 border-cyan-200';
      case 'indigo':
        return 'bg-indigo-50 text-indigo-700 border-indigo-200';
      case 'orange':
        return 'bg-orange-50 text-orange-700 border-orange-200';
      case 'red':
        return 'bg-red-50 text-red-700 border-red-200';
      default:
        return 'bg-slate-50 text-slate-700 border-slate-200';
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Job & Employment Types</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage custom classifications (Government, Private, Contractual, Apprenticeship, etc.). Changes instantly reflect across user app cards & filters.
          </p>
        </div>
        <AdminButton variant="primary" onClick={handleOpenAdd}>
          <Plus className="w-4 h-4 mr-1.5" />
          Add Job Type
        </AdminButton>
      </div>

      <AdminCard className="overflow-hidden border border-slate-200 shadow-sm">
        {loading ? (
          <div className="p-8 text-center text-slate-500">Loading job types...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  <th className="py-3.5 px-4 w-16 text-center">Order</th>
                  <th className="py-3.5 px-4">Name & Description</th>
                  <th className="py-3.5 px-4">Short Name</th>
                  <th className="py-3.5 px-4">Slug</th>
                  <th className="py-3.5 px-4 text-center">Active</th>
                  <th className="py-3.5 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 text-sm">
                {jobTypes.map((item, index) => (
                  <tr key={item.id} className="hover:bg-slate-50/70 transition-colors">
                    <td className="py-3 px-4 text-center">
                      <div className="flex items-center justify-center space-x-1">
                        <span className="font-bold text-xs text-slate-400 w-5">{item.order}</span>
                        <div className="flex flex-col space-y-0.5">
                          <button
                            onClick={() => handleReorder(index, 'up')}
                            disabled={index === 0}
                            className={`p-0.5 rounded ${
                              index === 0
                                ? 'text-slate-200 cursor-not-allowed'
                                : 'text-slate-500 hover:text-emerald-600 hover:bg-slate-200'
                            }`}
                            title="Move Up"
                          >
                            <ArrowUp className="w-3.5 h-3.5" />
                          </button>
                          <button
                            onClick={() => handleReorder(index, 'down')}
                            disabled={index === jobTypes.length - 1}
                            className={`p-0.5 rounded ${
                              index === jobTypes.length - 1
                                ? 'text-slate-200 cursor-not-allowed'
                                : 'text-slate-500 hover:text-emerald-600 hover:bg-slate-200'
                            }`}
                            title="Move Down"
                          >
                            <ArrowDown className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <div>
                        <span className="font-semibold text-slate-900">{item.name}</span>
                        {item.description && (
                          <p className="text-xs text-slate-500 mt-0.5 line-clamp-1">
                            {item.description}
                          </p>
                        )}
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <span
                        className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold border ${getColorClasses(
                          item.colorToken || 'blue'
                        )}`}
                      >
                        {item.shortName || item.name}
                      </span>
                    </td>
                    <td className="py-3 px-4">
                      <code className="text-xs bg-slate-100 text-slate-700 px-1.5 py-0.5 rounded font-mono">
                        {item.slug}
                      </code>
                    </td>
                    <td className="py-3 px-4 text-center">
                      <button
                        onClick={() => handleToggleActive(item)}
                        className={`inline-flex items-center justify-center p-1 rounded-md transition-colors ${
                          item.isActive
                            ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200'
                            : 'bg-slate-100 text-slate-400 hover:bg-slate-200'
                        }`}
                        title={item.isActive ? 'Active (Click to deactivate)' : 'Inactive (Click to activate)'}
                      >
                        {item.isActive ? <Check className="w-4 h-4" /> : <X className="w-4 h-4" />}
                      </button>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <div className="flex items-center justify-end space-x-2">
                        <button
                          onClick={() => handleOpenEdit(item)}
                          className="p-1.5 text-slate-600 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                          title="Edit Job Type"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => {
                            setItemToDelete(item);
                            setDeleteModalOpen(true);
                          }}
                          className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                          title="Delete Job Type"
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
        )}
      </AdminCard>

      {/* Add / Edit Modal */}
      <AdminModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editingItem ? 'Edit Job Type' : 'Add New Job Type'}
      >
        <form onSubmit={handleSave} className="space-y-4">
          {saveError && (
            <div className="p-3 bg-red-50 border border-red-200 text-red-700 text-xs rounded-lg">
              {saveError}
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <AdminInput
              label="Full Name *"
              placeholder="e.g. Contractual Employment"
              value={name}
              onChange={(e) => {
                setName(e.target.value);
                if (!editingItem) {
                  setSlug(e.target.value.toLowerCase().replace(/[^a-z0-9]+/g, '-'));
                  setShortName(e.target.value.slice(0, 16));
                }
              }}
              required
            />

            <AdminInput
              label="Short Name (Card Chip) *"
              placeholder="e.g. Contractual"
              value={shortName}
              onChange={(e) => setShortName(e.target.value)}
              hint="Appears on mobile job card chip without truncating."
              required
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <AdminInput
              label="Slug Identifier *"
              placeholder="e.g. contractual"
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              hint="Unique identifier used in backend queries."
              required
            />

            <AdminSelect
              label="Visual Badge Color Token"
              value={colorToken}
              onChange={(e) => setColorToken(e.target.value)}
              options={[
                { value: 'emerald', label: 'Emerald (Govt standard)' },
                { value: 'blue', label: 'Blue (Corporate / Regular)' },
                { value: 'amber', label: 'Amber (Contractual / Urgent)' },
                { value: 'purple', label: 'Purple (Specialized / Temporary)' },
                { value: 'cyan', label: 'Cyan (Apprenticeship)' },
                { value: 'indigo', label: 'Indigo (Internship)' },
                { value: 'orange', label: 'Orange (Walk-in)' },
                { value: 'red', label: 'Red (High priority)' },
                { value: 'slate', label: 'Slate (Neutral)' },
              ]}
            />
          </div>

          <AdminInput
            label="Description"
            placeholder="e.g. Contractual recruitment with fixed tenure"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />

          <div className="grid grid-cols-2 gap-4 pt-2">
            <AdminInput
              type="number"
              label="Display Order"
              value={order.toString()}
              onChange={(e) => setOrder(parseInt(e.target.value) || 1)}
            />

            <div className="flex flex-col justify-center">
              <label className="text-xs font-semibold text-slate-600 mb-1.5">Status</label>
              <label className="flex items-center space-x-2 text-sm text-slate-700 cursor-pointer">
                <input
                  type="checkbox"
                  checked={isActive}
                  onChange={(e) => setIsActive(e.target.checked)}
                  className="rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 w-4 h-4"
                />
                <span className="font-medium">Active (Visible in App)</span>
              </label>
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-4 border-t border-slate-100">
            <AdminButton type="button" variant="outline" onClick={() => setModalOpen(false)}>
              Cancel
            </AdminButton>
            <AdminButton type="submit" variant="primary" loading={submitting}>
              {editingItem ? 'Update Job Type' : 'Save Job Type'}
            </AdminButton>
          </div>
        </form>
      </AdminModal>

      {/* Delete Confirmation Modal */}
      <AdminModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        title="Delete Job Type"
      >
        <div className="space-y-4">
          <div className="flex items-start space-x-3 p-3 bg-amber-50 border border-amber-200 rounded-lg text-amber-800 text-sm">
            <ShieldAlert className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
            <div>
              <p className="font-semibold">Confirm Deletion</p>
              <p className="mt-0.5 text-xs text-amber-700">
                Are you sure you want to delete &quot;{itemToDelete?.name}&quot;? Existing posts tagged with this job type will retain their string name, but it will no longer appear in the Admin selector.
              </p>
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-2">
            <AdminButton variant="outline" onClick={() => setDeleteModalOpen(false)}>
              Cancel
            </AdminButton>
            <AdminButton
              variant="primary"
              className="bg-red-600 hover:bg-red-700 text-white"
              onClick={confirmDelete}
              loading={submitting}
            >
              Delete Job Type
            </AdminButton>
          </div>
        </div>
      </AdminModal>
    </div>
  );
};
