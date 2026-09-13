import React, { useState } from 'react';
import { AdminSidebar, NavView } from './AdminSidebar';
import { AdminHeader } from './AdminHeader';

interface AdminLayoutProps {
  currentView: NavView;
  onNavigate: (view: NavView) => void;
  title: string;
  userEmail?: string;
  userRole?: 'super_admin' | 'editor';
  onLogout: () => void;
  onAddNew?: () => void;
  onOpenMobilePreview?: () => void;
  counts?: Record<string, number>;
  children: React.ReactNode;
}

export const AdminLayout: React.FC<AdminLayoutProps> = ({
  currentView,
  onNavigate,
  title,
  userEmail,
  userRole,
  onLogout,
  onAddNew,
  onOpenMobilePreview,
  counts,
  children,
}) => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex">
      {/* Sidebar Navigation */}
      <AdminSidebar
        currentView={currentView}
        onNavigate={onNavigate}
        isOpen={isSidebarOpen}
        onClose={() => setIsSidebarOpen(false)}
        userEmail={userEmail}
        userRole={userRole}
        onLogout={onLogout}
        counts={counts}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 lg:pl-72">
        <AdminHeader
          title={title}
          onToggleSidebar={() => setIsSidebarOpen(true)}
          onAddNew={onAddNew}
          onOpenMobilePreview={onOpenMobilePreview}
        />
        <main className="flex-1 p-4 sm:p-8 max-w-7xl w-full mx-auto animate-fadeIn">
          {children}
        </main>
      </div>
    </div>
  );
};
