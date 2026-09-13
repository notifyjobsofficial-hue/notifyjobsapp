import React from 'react';
import { Menu, Search, ShieldCheck, Plus, Smartphone } from 'lucide-react';
import { isFirebaseConfigured } from '../../firebase/config';
import { AdminButton } from '../common/AdminButton';

interface AdminHeaderProps {
  onToggleSidebar: () => void;
  title: string;
  onAddNew?: () => void;
  onOpenMobilePreview?: () => void;
}

export const AdminHeader: React.FC<AdminHeaderProps> = ({
  onToggleSidebar,
  title,
  onAddNew,
  onOpenMobilePreview,
}) => {
  return (
    <header className="sticky top-0 z-30 h-16 bg-white/95 backdrop-blur border-b border-slate-200/80 px-4 sm:px-8 flex items-center justify-between gap-4">
      <div className="flex items-center gap-3">
        <button
          onClick={onToggleSidebar}
          className="p-2 -ml-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 lg:hidden"
        >
          <Menu className="w-5 h-5" />
        </button>
        <div>
          <h2 className="text-base sm:text-lg font-bold text-slate-900 tracking-tight">
            {title}
          </h2>
        </div>
      </div>

      <div className="flex items-center gap-2.5">
        {/* Firebase Environment Status */}
        <div
          className={`hidden md:inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold ${
            isFirebaseConfigured
              ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
              : 'bg-amber-50 text-amber-700 border border-amber-200'
          }`}
        >
          <ShieldCheck className="w-3.5 h-3.5" />
          <span>{isFirebaseConfigured ? 'Live Firebase' : 'Demo Memory Mode'}</span>
        </div>

        {onOpenMobilePreview && (
          <AdminButton
            variant="outline"
            size="sm"
            icon={<Smartphone className="w-3.5 h-3.5 text-slate-600" />}
            onClick={onOpenMobilePreview}
            className="hidden sm:inline-flex"
          >
            App Preview
          </AdminButton>
        )}

        {onAddNew && (
          <AdminButton
            variant="primary"
            size="sm"
            icon={<Plus className="w-3.5 h-3.5" />}
            onClick={onAddNew}
          >
            Add New
          </AdminButton>
        )}
      </div>
    </header>
  );
};
