import React, { useState, useEffect } from 'react';
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
  ChevronDown,
  ChevronRight,
} from 'lucide-react';

export type NavView =
  | 'dashboard'
  | 'content_all'
  | 'content_add'
  // Jobs
  | 'jobs_all'
  | 'jobs_govt'
  | 'jobs_andaman'
  | 'jobs_ssc'
  | 'jobs_railway'
  | 'jobs_banking'
  | 'jobs_police'
  // Updates
  | 'updates_admit_cards'
  | 'updates_results'
  | 'updates_answer_keys'
  | 'updates_syllabus'
  // Articles
  | 'articles_all'
  // Settings & Management
  | 'categories'
  | 'homepage'
  | 'notifications'
  | 'social_support'
  | 'ad_settings'
  | 'app_settings'
  | 'admin_users'
  | 'diagnostics'
  // Legacy aliases for backward compatibility
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
  | 'content_articles';

interface AdminSidebarProps {
  currentView: NavView;
  onNavigate: (view: NavView) => void;
  isOpen: boolean;
  onClose: () => void;
  userEmail?: string;
  userRole?: 'super_admin' | 'editor';
  onLogout: () => void;
  counts?: Record<string, number>;
}

export const AdminSidebar: React.FC<AdminSidebarProps> = ({
  currentView,
  onNavigate,
  isOpen,
  onClose,
  userEmail = 'Admin',
  userRole = 'super_admin',
  onLogout,
  counts = {},
}) => {
  // Normalize legacy aliases
  const normalizedView = ((): NavView => {
    switch (currentView) {
      case 'content_govt':
        return 'jobs_govt';
      case 'content_andaman':
        return 'jobs_andaman';
      case 'content_ssc':
        return 'jobs_ssc';
      case 'content_railway':
        return 'jobs_railway';
      case 'content_banking':
        return 'jobs_banking';
      case 'content_police':
        return 'jobs_police';
      case 'content_admit_cards':
        return 'updates_admit_cards';
      case 'content_results':
        return 'updates_results';
      case 'content_answer_keys':
        return 'updates_answer_keys';
      case 'content_syllabus':
        return 'updates_syllabus';
      case 'content_articles':
        return 'articles_all';
      default:
        return currentView;
    }
  })();

  const isJobView = [
    'jobs_all',
    'jobs_govt',
    'jobs_andaman',
    'jobs_ssc',
    'jobs_railway',
    'jobs_banking',
    'jobs_police',
    'content_govt',
    'content_andaman',
    'content_ssc',
    'content_railway',
    'content_banking',
    'content_police',
  ].includes(currentView);

  const isUpdateView = [
    'updates_admit_cards',
    'updates_results',
    'updates_answer_keys',
    'updates_syllabus',
    'content_admit_cards',
    'content_results',
    'content_answer_keys',
    'content_syllabus',
  ].includes(currentView);

  const [jobsExpanded, setJobsExpanded] = useState(true);
  const [updatesExpanded, setUpdatesExpanded] = useState(true);

  // Automatically expand groups if an inner child route becomes active
  useEffect(() => {
    if (isJobView) setJobsExpanded(true);
    if (isUpdateView) setUpdatesExpanded(true);
  }, [currentView, isJobView, isUpdateView]);

  const jobsSubItems: { id: NavView; label: string; icon: React.ReactNode; countKey?: string }[] = [
    { id: 'jobs_all', label: 'All Jobs', icon: <Briefcase className="w-3.5 h-3.5" />, countKey: 'jobs_all' },
    { id: 'jobs_govt', label: 'Government Jobs', icon: <Landmark className="w-3.5 h-3.5" />, countKey: 'jobs_govt' },
    { id: 'jobs_andaman', label: 'A&N Jobs', icon: <MapPin className="w-3.5 h-3.5 text-[#0D9488]" />, countKey: 'jobs_andaman' },
    { id: 'jobs_ssc', label: 'SSC', icon: <Landmark className="w-3.5 h-3.5" />, countKey: 'jobs_ssc' },
    { id: 'jobs_railway', label: 'Railway', icon: <Train className="w-3.5 h-3.5" />, countKey: 'jobs_railway' },
    { id: 'jobs_banking', label: 'Banking', icon: <Landmark className="w-3.5 h-3.5" />, countKey: 'jobs_banking' },
    { id: 'jobs_police', label: 'Police / Defence', icon: <Shield className="w-3.5 h-3.5" />, countKey: 'jobs_police' },
  ];

  const updatesSubItems: { id: NavView; label: string; icon: React.ReactNode; countKey?: string }[] = [
    { id: 'updates_admit_cards', label: 'Admit Cards', icon: <FileCheck className="w-3.5 h-3.5" />, countKey: 'updates_admit_cards' },
    { id: 'updates_results', label: 'Results', icon: <Award className="w-3.5 h-3.5" />, countKey: 'updates_results' },
    { id: 'updates_answer_keys', label: 'Answer Keys', icon: <CheckSquare className="w-3.5 h-3.5" />, countKey: 'updates_answer_keys' },
    { id: 'updates_syllabus', label: 'Syllabus', icon: <BookOpen className="w-3.5 h-3.5" />, countKey: 'updates_syllabus' },
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
          <div className="flex items-center gap-3 cursor-pointer" onClick={() => onNavigate('dashboard')}>
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
        <div className="flex-1 overflow-y-auto px-3.5 py-4 space-y-6">
          {/* Overview */}
          <div className="space-y-1">
            <h2 className="px-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
              Overview
            </h2>
            <button
              onClick={() => {
                onNavigate('dashboard');
                onClose();
              }}
              className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'dashboard'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <div className="flex items-center gap-2.5">
                <LayoutDashboard className={`w-4 h-4 ${currentView === 'dashboard' ? 'text-white' : 'text-slate-400'}`} />
                <span>Dashboard</span>
              </div>
            </button>
          </div>

          {/* CONTENT MANAGEMENT */}
          <div className="space-y-1">
            <h2 className="px-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
              Content Management
            </h2>

            {/* All Content */}
            <button
              onClick={() => {
                onNavigate('content_all');
                onClose();
              }}
              className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'content_all'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <div className="flex items-center gap-2.5">
                <FileText className={`w-4 h-4 ${currentView === 'content_all' ? 'text-white' : 'text-slate-400'}`} />
                <span>All Content</span>
              </div>
              {counts.all !== undefined && counts.all > 0 && (
                <span
                  className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${
                    currentView === 'content_all' ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-600'
                  }`}
                >
                  {counts.all}
                </span>
              )}
            </button>

            {/* Add New */}
            <button
              onClick={() => {
                onNavigate('content_add');
                onClose();
              }}
              className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'content_add'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-emerald-700 bg-emerald-50/70 hover:bg-emerald-100/70 font-semibold'
              }`}
            >
              <div className="flex items-center gap-2.5">
                <PlusCircle className={`w-4 h-4 ${currentView === 'content_add' ? 'text-white' : 'text-[#159B76]'}`} />
                <span>Add New</span>
              </div>
              <span className={`text-[10px] px-1.5 py-0.5 rounded font-bold uppercase tracking-wider ${
                currentView === 'content_add' ? 'bg-white/20 text-white' : 'bg-white text-[#159B76] border border-emerald-200'
              }`}>
                Create
              </span>
            </button>

            {/* Jobs (Expandable) */}
            <div className="pt-1">
              <button
                onClick={() => setJobsExpanded((prev) => !prev)}
                className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold transition-all ${
                  isJobView
                    ? 'text-slate-900 bg-slate-100/80'
                    : 'text-slate-700 hover:bg-slate-50'
                }`}
              >
                <div className="flex items-center gap-2.5">
                  <Briefcase className="w-4 h-4 text-[#159B76]" />
                  <span>Jobs</span>
                </div>
                <div className="flex items-center gap-1.5">
                  {counts.jobs_all !== undefined && counts.jobs_all > 0 && (
                    <span className="text-[10px] px-1.5 py-0.2 rounded-full font-bold bg-slate-200/60 text-slate-700">
                      {counts.jobs_all}
                    </span>
                  )}
                  {jobsExpanded ? (
                    <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
                  ) : (
                    <ChevronRight className="w-3.5 h-3.5 text-slate-400" />
                  )}
                </div>
              </button>

              {jobsExpanded && (
                <div className="mt-1 ml-3 pl-3 border-l-2 border-slate-100 space-y-0.5">
                  {jobsSubItems.map((sub) => {
                    const isActive = normalizedView === sub.id;
                    const count = sub.countKey ? counts[sub.countKey] : undefined;
                    return (
                      <button
                        key={sub.id}
                        onClick={() => {
                          onNavigate(sub.id);
                          onClose();
                        }}
                        className={`w-full flex items-center justify-between px-2.5 py-1.5 rounded-lg text-xs font-medium transition-all ${
                          isActive
                            ? 'bg-[#159B76] text-white font-semibold shadow-sm'
                            : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                        }`}
                      >
                        <div className="flex items-center gap-2 truncate">
                          <span className={isActive ? 'text-white' : 'text-slate-400'}>{sub.icon}</span>
                          <span className="truncate">{sub.label}</span>
                        </div>
                        {count !== undefined && count > 0 && (
                          <span
                            className={`text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                              isActive ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-500'
                            }`}
                          >
                            {count}
                          </span>
                        )}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Updates (Expandable) */}
            <div className="pt-1">
              <button
                onClick={() => setUpdatesExpanded((prev) => !prev)}
                className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold transition-all ${
                  isUpdateView
                    ? 'text-slate-900 bg-slate-100/80'
                    : 'text-slate-700 hover:bg-slate-50'
                }`}
              >
                <div className="flex items-center gap-2.5">
                  <FileCheck className="w-4 h-4 text-amber-500" />
                  <span>Updates</span>
                </div>
                <div className="flex items-center gap-1.5">
                  {counts.updates_all !== undefined && counts.updates_all > 0 && (
                    <span className="text-[10px] px-1.5 py-0.2 rounded-full font-bold bg-slate-200/60 text-slate-700">
                      {counts.updates_all}
                    </span>
                  )}
                  {updatesExpanded ? (
                    <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
                  ) : (
                    <ChevronRight className="w-3.5 h-3.5 text-slate-400" />
                  )}
                </div>
              </button>

              {updatesExpanded && (
                <div className="mt-1 ml-3 pl-3 border-l-2 border-slate-100 space-y-0.5">
                  {updatesSubItems.map((sub) => {
                    const isActive = normalizedView === sub.id;
                    const count = sub.countKey ? counts[sub.countKey] : undefined;
                    return (
                      <button
                        key={sub.id}
                        onClick={() => {
                          onNavigate(sub.id);
                          onClose();
                        }}
                        className={`w-full flex items-center justify-between px-2.5 py-1.5 rounded-lg text-xs font-medium transition-all ${
                          isActive
                            ? 'bg-[#159B76] text-white font-semibold shadow-sm'
                            : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                        }`}
                      >
                        <div className="flex items-center gap-2 truncate">
                          <span className={isActive ? 'text-white' : 'text-slate-400'}>{sub.icon}</span>
                          <span className="truncate">{sub.label}</span>
                        </div>
                        {count !== undefined && count > 0 && (
                          <span
                            className={`text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                              isActive ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-500'
                            }`}
                          >
                            {count}
                          </span>
                        )}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Articles */}
            <button
              onClick={() => {
                onNavigate('articles_all');
                onClose();
              }}
              className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                normalizedView === 'articles_all'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <div className="flex items-center gap-2.5">
                <Newspaper className={`w-4 h-4 ${normalizedView === 'articles_all' ? 'text-white' : 'text-slate-400'}`} />
                <span>All Articles</span>
              </div>
              {counts.articles_all !== undefined && counts.articles_all > 0 && (
                <span
                  className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${
                    normalizedView === 'articles_all' ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-600'
                  }`}
                >
                  {counts.articles_all}
                </span>
              )}
            </button>
          </div>

          {/* Structure & Layout */}
          <div className="space-y-1">
            <h2 className="px-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
              Structure &amp; Layout
            </h2>
            <button
              onClick={() => {
                onNavigate('categories');
                onClose();
              }}
              className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'categories'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <Layers className={`w-4 h-4 ${currentView === 'categories' ? 'text-white' : 'text-slate-400'}`} />
              <span>Categories</span>
            </button>

            <button
              onClick={() => {
                onNavigate('homepage');
                onClose();
              }}
              className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'homepage'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <Home className={`w-4 h-4 ${currentView === 'homepage' ? 'text-white' : 'text-slate-400'}`} />
              <span>Homepage Layout</span>
            </button>
          </div>

          {/* Engagement & Ads */}
          <div className="space-y-1">
            <h2 className="px-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
              Engagement &amp; Ads
            </h2>
            <button
              onClick={() => {
                onNavigate('notifications');
                onClose();
              }}
              className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'notifications'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <Bell className={`w-4 h-4 ${currentView === 'notifications' ? 'text-white' : 'text-slate-400'}`} />
              <span>Push Notification Hub</span>
            </button>

            <button
              onClick={() => {
                onNavigate('social_support');
                onClose();
              }}
              className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'social_support'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <Share2 className={`w-4 h-4 ${currentView === 'social_support' ? 'text-white' : 'text-slate-400'}`} />
              <span>Social &amp; Support</span>
            </button>

            <button
              onClick={() => {
                onNavigate('ad_settings');
                onClose();
              }}
              className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'ad_settings'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <Tv className={`w-4 h-4 ${currentView === 'ad_settings' ? 'text-white' : 'text-slate-400'}`} />
              <span>AdMob &amp; Rewards</span>
            </button>
          </div>

          {/* System */}
          <div className="space-y-1">
            <h2 className="px-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
              System
            </h2>
            <button
              onClick={() => {
                onNavigate('app_settings');
                onClose();
              }}
              className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'app_settings'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <Settings className={`w-4 h-4 ${currentView === 'app_settings' ? 'text-white' : 'text-slate-400'}`} />
              <span>App Settings</span>
            </button>

            {userRole === 'super_admin' && (
              <button
                onClick={() => {
                  onNavigate('admin_users');
                  onClose();
                }}
                className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                  currentView === 'admin_users'
                    ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                    : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                }`}
              >
                <Users className={`w-4 h-4 ${currentView === 'admin_users' ? 'text-white' : 'text-slate-400'}`} />
                <span>Admin Team &amp; Roles</span>
              </button>
            )}

            <button
              onClick={() => {
                onNavigate('diagnostics');
                onClose();
              }}
              className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                currentView === 'diagnostics'
                  ? 'bg-[#159B76] text-white font-semibold shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <Activity className={`w-4 h-4 ${currentView === 'diagnostics' ? 'text-white' : 'text-slate-400'}`} />
              <span>Diagnostics</span>
            </button>
          </div>
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
                <span className="text-[10px] text-slate-500 capitalize font-medium">
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

