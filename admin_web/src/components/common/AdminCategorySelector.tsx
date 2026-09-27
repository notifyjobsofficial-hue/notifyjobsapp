import React, { useState, useRef, useEffect, useMemo } from 'react';
import { Search, X, Check, Tag, ChevronDown } from 'lucide-react';
import { Category } from '../../types';

interface AdminCategorySelectorProps {
  categories: Category[];
  selectedCategoryIds: string[];
  onChange: (selectedIds: string[], selectedNames: string[]) => void;
  label?: string;
  placeholder?: string;
  error?: string;
}

export const AdminCategorySelector: React.FC<AdminCategorySelectorProps> = ({
  categories,
  selectedCategoryIds,
  onChange,
  label = 'Assigned Categories (Multi-Select Filter)',
  placeholder = 'Search & select categories (e.g. SSC, 10th Pass, Technical)...',
  error,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const containerRef = useRef<HTMLDivElement>(null);

  // Close dropdown on outside click
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Filter only active categories and match search query
  const filteredCategories = useMemo(() => {
    const q = searchQuery.toLowerCase().trim();
    return categories
      .filter((c) => c.isActive !== false)
      .filter((c) => {
        if (!q) return true;
        return (
          c.name.toLowerCase().includes(q) ||
          (c.shortName && c.shortName.toLowerCase().includes(q)) ||
          c.slug.toLowerCase().includes(q)
        );
      })
      .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
  }, [categories, searchQuery]);

  // Selected Category objects
  const selectedCategories = useMemo(() => {
    return selectedCategoryIds
      .map((id) => categories.find((c) => c.id === id || c.slug === id))
      .filter((c): c is Category => Boolean(c));
  }, [categories, selectedCategoryIds]);

  const handleToggleCategory = (cat: Category) => {
    const isSelected = selectedCategoryIds.includes(cat.id) || selectedCategoryIds.includes(cat.slug);
    let newIds: string[];
    if (isSelected) {
      newIds = selectedCategoryIds.filter((id) => id !== cat.id && id !== cat.slug);
    } else {
      newIds = [...selectedCategoryIds, cat.id];
    }

    const newNames = newIds
      .map((id) => {
        const found = categories.find((c) => c.id === id || c.slug === id);
        return found?.name || id;
      })
      .filter(Boolean);

    onChange(newIds, newNames);
  };

  const handleRemoveCategory = (catId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    const newIds = selectedCategoryIds.filter((id) => id !== catId);
    const newNames = newIds
      .map((id) => {
        const found = categories.find((c) => c.id === id || c.slug === id);
        return found?.name || id;
      })
      .filter(Boolean);

    onChange(newIds, newNames);
  };

  return (
    <div className="space-y-2" ref={containerRef}>
      {label && (
        <div className="flex items-center justify-between">
          <label className="block text-xs font-semibold text-slate-700">
            {label} <span className="text-rose-500 font-bold">*</span>
          </label>
          <span className="text-[11px] text-slate-400 font-medium">
            {selectedCategoryIds.length} selected
          </span>
        </div>
      )}

      {/* Selected Chips Display */}
      {selectedCategories.length > 0 && (
        <div className="flex flex-wrap gap-1.5 p-2 bg-slate-50 border border-slate-200/80 rounded-xl min-h-[40px] items-center">
          {selectedCategories.map((cat) => (
            <span
              key={cat.id}
              className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold bg-white border border-slate-200 text-slate-800 shadow-2xs group hover:border-slate-300 transition-colors"
            >
              <Tag className="w-3 h-3 text-[#159B76]" />
              <span>{cat.name}</span>
              <button
                type="button"
                onClick={(e) => handleRemoveCategory(cat.id, e)}
                className="w-4 h-4 rounded-full flex items-center justify-center text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition-colors"
                title={`Remove ${cat.name}`}
              >
                <X className="w-3 h-3" />
              </button>
            </span>
          ))}
        </div>
      )}

      {/* Search & Dropdown Trigger */}
      <div className="relative">
        <div
          onClick={() => setIsOpen(!isOpen)}
          className={`flex items-center justify-between w-full px-3 py-2 text-xs bg-white border rounded-xl cursor-pointer transition-all shadow-2xs ${
            isOpen
              ? 'border-[#159B76] ring-2 ring-[#159B76]/20'
              : error
              ? 'border-rose-300'
              : 'border-slate-200 hover:border-slate-300'
          }`}
        >
          <div className="flex items-center gap-2 text-slate-500 flex-1 truncate">
            <Search className="w-3.5 h-3.5 text-slate-400 shrink-0" />
            <span className="text-slate-400 truncate">
              {selectedCategoryIds.length === 0 ? placeholder : 'Click or type to add more categories...'}
            </span>
          </div>
          <ChevronDown
            className={`w-4 h-4 text-slate-400 shrink-0 transition-transform duration-200 ${
              isOpen ? 'rotate-180 text-[#159B76]' : ''
            }`}
          />
        </div>

        {/* Dropdown Menu */}
        {isOpen && (
          <div className="absolute z-50 left-0 right-0 mt-1.5 bg-white border border-slate-200 rounded-2xl shadow-xl overflow-hidden animate-in fade-in zoom-in-95 duration-100">
            {/* Search Input inside Dropdown */}
            <div className="p-2 border-b border-slate-100 bg-slate-50/70">
              <div className="relative">
                <Search className="w-3.5 h-3.5 text-slate-400 absolute left-2.5 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Filter categories..."
                  autoFocus
                  className="w-full pl-8 pr-7 py-1.5 text-xs bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#159B76] focus:border-[#159B76]"
                />
                {searchQuery && (
                  <button
                    type="button"
                    onClick={() => setSearchQuery('')}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                  >
                    <X className="w-3 h-3" />
                  </button>
                )}
              </div>
            </div>

            {/* Category Option List */}
            <div className="max-h-60 overflow-y-auto divide-y divide-slate-50 p-1">
              {filteredCategories.length === 0 ? (
                <div className="py-6 text-center text-xs text-slate-400">
                  No active categories matching "{searchQuery}"
                </div>
              ) : (
                filteredCategories.map((cat) => {
                  const isSelected =
                    selectedCategoryIds.includes(cat.id) || selectedCategoryIds.includes(cat.slug);
                  return (
                    <div
                      key={cat.id}
                      onClick={() => handleToggleCategory(cat)}
                      className={`flex items-center justify-between px-3 py-2 text-xs rounded-xl cursor-pointer transition-colors ${
                        isSelected
                          ? 'bg-emerald-50/70 text-[#159B76] font-semibold'
                          : 'text-slate-700 hover:bg-slate-50'
                      }`}
                    >
                      <div className="flex items-center gap-2.5 min-w-0">
                        <div
                          className={`w-4 h-4 rounded border flex items-center justify-center transition-colors ${
                            isSelected
                              ? 'bg-[#159B76] border-[#159B76] text-white'
                              : 'border-slate-300 bg-white'
                          }`}
                        >
                          {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                        </div>
                        <span className="truncate">{cat.name}</span>
                        {cat.shortName && cat.shortName !== cat.name && (
                          <span className="text-[10px] text-slate-400 font-normal">
                            ({cat.shortName})
                          </span>
                        )}
                      </div>
                      <span className="text-[10px] px-1.5 py-0.5 rounded bg-slate-100 text-slate-500 font-mono">
                        {cat.slug}
                      </span>
                    </div>
                  );
                })
              )}
            </div>

            {/* Footer with Select count and Done button */}
            <div className="p-2 border-t border-slate-100 bg-slate-50 flex items-center justify-between text-xs">
              <span className="text-slate-500 text-[11px]">
                {selectedCategoryIds.length} categories active
              </span>
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className="px-3 py-1 rounded-lg bg-[#159B76] text-white text-xs font-semibold hover:bg-[#117A5E] transition-colors"
              >
                Done
              </button>
            </div>
          </div>
        )}
      </div>

      {error && <p className="text-[11px] text-rose-500 font-medium">{error}</p>}
    </div>
  );
};
