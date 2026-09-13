import React from 'react';
import {
  LayoutDashboard,
  FileText,
  PlusCircle,
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
  Layers,
  Home,
  Bell,
  Share2,
  Tv,
  Settings,
  Users,
  Activity,
  LogOut,
  X,
} from 'lucide-react';

export type NavView =
  | 'dashboard'
  | 'content_all'
  | 'content_add'
  | 'content_govt'
  | 'content_private'
  | 'content_andaman'
  | 'content_ssc'
  | 'content_railway'
  | 'content_banking'
  | 'content_police'
  | 'content_admit_cards'
  | 'content_results'
  | 'content_answer_keys'
  | 'content_syllabus'
  | 'content_articles'
  | 'categories'
  | 'homepage'
  | 'notifications'
  | 'social_support'
  | 'ad_settings'
  | 'app_settings'
  | 'admin_users'
  | 'diagnostics';

interface AdminSidebarProps {
  currentView: NavView;
  onNavigate: (view: NavView) => void;
  isOpen: boolean;
  onClose: () => void;
  userEmail?: string;
  userRole?: 'super_admin' | 'editor';
  onLogout: () => void;
}

export const AdminSidebar: React.FC<AdminSidebarProps> = ({
  currentView,
  onNavigate,
  isOpen,
  onClose,
  userEmail = 'Admin',
  userRole = 'super_admin',
  onLogout,
}) => {
  const navSections = [
    {
      title: 'Overview',
      items: [
        { id: 'dashboard' as NavView, label: 'Dashboard', icon: <LayoutDashboard className="w-4 h-4" /> },
      ],
    },
    {
      title: 'Content Management',
      items: [
        { id: 'content_all' as NavView, label: 'All Content', icon: <FileText className="w-4 h-4" /> },
        { id: 'content_add' as NavView, label: 'Add New Job / Post', icon: <PlusCircle className="w-4 h-4 text-[#159B76]" /> },
        { id: 'content_govt' as NavView, label: 'Govt Jobs', icon: <Briefcase className="w-4 h-4" /> },
        { id: 'content_andaman' as NavView, label: 'A&N Jobs', icon: <MapPin className="w-4 h-4 text-[#0D9488]" /> },
        { id: 'content_ssc' as NavView, label: 'SSC', icon: <Landmark className="w-4 h-4" /> },
        { id: 'content_railway' as NavView, label: 'Railway', icon: <Train className="w-4 h-4" /> },
        { id: 'content_banking' as NavView, label: 'Banking', icon: <Landmark className="w-4 h-4" /> },
        { id: 'content_police' as NavView, label: 'Police / Defence', icon: <Shield className="w-4 h-4" /> },
        { id: 'content_admit_cards' as NavView, label: 'Admit Cards', icon: <FileCheck className="w-4 h-4" /> },
        { id: 'content_results' as NavView, label: 'Results', icon: <Award className="w-4 h-4" /> },
        { id: 'content_answer_keys' as NavView, label: 'Answer Keys', icon: <CheckSquare className="w-4 h-4" /> },
        { id: 'content_syllabus' as NavView, label: 'Syllabus', icon: <BookOpen className="w-4 h-4" /> },
        { id: 'content_articles' as NavView, label: 'Articles', icon: <Newspaper className="w-4 h-4" /> },
      ],
    },
    {
      title: 'Structure & Layout',
      items: [
        { id: 'categories' as NavView, label: 'Categories', icon: <Layers className="w-4 h-4" /> },
        { id: 'homepage' as NavView, label: 'Homepage Layout', icon: <Home className="w-4 h-4" /> },
      ],
    },
    {
      title: 'Engagement & Ads',
      items: [
        { id: 'notifications' as NavView, label: 'FCM Notifications', icon: <Bell className="w-4 h-4" /> },
        { id: 'social_support' as NavView, label: 'Social & Support', icon: <Share2 className="w-4 h-4" /> },
        { id: 'ad_settings' as NavView, label: 'AdMob Settings', icon: <Tv className="w-4 h-4" /> },
      ],
    },
    {
      title: 'System',
      items: [
        { id: 'app_settings' as NavView, label: 'App Settings', icon: <Settings className="w-4 h-4" /> },
        ...(userRole === 'super_admin'
          ? [{ id: 'admin_users' as NavView, label: 'Admin Users', icon: <Users className="w-4 h-4" /> }]
          : []),
        { id: 'diagnostics' as NavView, label: 'Diagnostics', icon: <Activity className="w-4 h-4" /> },
      ],
    },
  ];

  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div
          className="fixed inset-0 z-40 bg-slate-900/50 backdrop-blur-sm lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar Drawer */}
      <aside
        className={`fixed top-0 bottom-0 left-0 z-50 w-72 bg-white border-r border-slate-200 flex flex-col transition-transform duration-300 ease-in-out lg:translate-x-0 ${
          isOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {/* Brand Header */}
        <div className="h-16 px-6 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#159B76] flex items-center justify-center text-white font-bold shadow-md shadow-[#159B76]/20">
              NJ
            </div>
            <div>
              <h1 className="text-base font-bold text-slate-900 tracking-tight">
                Notify Jobs
              </h1>
              <span className="text-[10px] font-semibold text-[#159B76] tracking-wider uppercase">
                Admin Control
              </span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 lg:hidden"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Navigation List */}
        <div className="flex-1 overflow-y-auto px-4 py-4 space-y-6">
          {navSections.map((sec, idx) => (
            <div key={idx} className="space-y-1">
              <h2 className="px-3 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                {sec.title}
              </h2>
              <div className="space-y-0.5 mt-1">
                {sec.items.map((item) => {
                  const isActive = currentView === item.id;
                  return (
                    <button
                      key={item.id}
                      onClick={() => {
                        onNavigate(item.id);
                        onClose();
                      }}
                      className={`w-full flex items-center gap-3 px-3 py-2 rounded-xl text-xs font-medium transition-all duration-150 ${
                        isActive
                          ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                          : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                      }`}
                    >
                      <span className={isActive ? 'text-white' : 'text-slate-400'}>
                        {item.icon}
                      </span>
                      <span className="truncate">{item.label}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </div>

        {/* User Footer */}
        <div className="p-4 border-t border-slate-100 bg-slate-50/50">
          <div className="flex items-center justify-between mb-2">
            <div className="min-w-0 flex-1 mr-2">
              <p className="text-xs font-semibold text-slate-800 truncate">
                {userEmail}
              </p>
              <div className="flex items-center gap-1.5 mt-0.5">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                <span className="text-[10px] text-slate-500 capitalize">
                  {userRole === 'super_admin' ? 'Super Admin' : 'Editor'}
                </span>
              </div>
            </div>
            <button
              onClick={onLogout}
              className="p-2 rounded-xl text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"
              title="Logout"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </aside>
    </>
  );
};
