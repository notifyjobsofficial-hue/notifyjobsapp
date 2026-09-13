import React, { useState, useEffect } from 'react';
import { NavView } from './components/layout/AdminSidebar';
import { AdminLayout } from './components/layout/AdminLayout';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { ContentListPage } from './pages/ContentListPage';
import { ContentEditorPage } from './pages/ContentEditorPage';
import { CategoryManagerPage } from './pages/CategoryManagerPage';
import { HomepageManagerPage } from './pages/HomepageManagerPage';
import { NotificationManagerPage } from './pages/NotificationManagerPage';
import { SocialAndSupportPage } from './pages/SocialAndSupportPage';
import { AdSettingsPage } from './pages/AdSettingsPage';
import { AppSettingsPage } from './pages/AppSettingsPage';
import { AdminUsersPage } from './pages/AdminUsersPage';
import { DiagnosticsPage } from './pages/DiagnosticsPage';
import { MobilePreviewModal } from './components/preview/MobilePreviewModal';
import { AdminToast, ToastMessage } from './components/common/AdminToast';
import {
  ContentItem,
  Category,
  HomepageSection,
  AppSettings,
  NotificationLog,
  ContentType,
} from './types';
import {
  fetchContentList,
  saveContent,
  archiveContent,
  deleteContentPermanently,
  toggleContentPublish,
  isCategoryMatch,
} from './services/contentService';
import {
  fetchCategories,
  saveCategory,
  deleteCategory,
} from './services/categoryService';
import {
  fetchAppSettings,
  saveAppSettings,
  fetchHomepageSections,
  saveHomepageSections,
  defaultAppSettings,
} from './services/settingsService';
import {
  fetchNotificationLogs,
  sendPushNotification,
} from './services/workerService';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db, onAuthStateChanged } from './firebase/config';

export function App() {
  // Authentication State (Enforced via Firebase Auth; null by default)
  const [currentUser, setCurrentUser] = useState<{
    email: string;
    role: 'super_admin' | 'editor';
    uid: string;
  } | null>(null);
  const [authLoading, setAuthLoading] = useState(true);

  const [currentView, setCurrentView] = useState<NavView>('dashboard');
  const [editingItem, setEditingItem] = useState<ContentItem | null>(null);
  const [presetType, setPresetType] = useState<ContentType | undefined>(undefined);

  // App Data
  const [contentList, setContentList] = useState<ContentItem[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [homepageSections, setHomepageSections] = useState<HomepageSection[]>([]);
  const [appSettings, setAppSettings] = useState<AppSettings>(defaultAppSettings);
  const [logs, setLogs] = useState<NotificationLog[]>([]);
  const [loadingData, setLoadingData] = useState(true);

  // Preview & Toasts
  const [previewItem, setPreviewItem] = useState<ContentItem | null>(null);
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const addToast = (type: 'success' | 'error' | 'info', title: string, message?: string) => {
    setToasts((prev) => [
      ...prev,
      { id: `toast-${Date.now()}-${Math.random()}`, type, title, message },
    ]);
  };

  const removeToast = (id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  // Load Initial Data from Firestore (Only executed after admin role is verified)
  const loadAllData = async () => {
    setLoadingData(true);
    try {
      const [cList, cats, sections, settings, nLogs] = await Promise.all([
        fetchContentList({}),
        fetchCategories(),
        fetchHomepageSections(),
        fetchAppSettings(),
        fetchNotificationLogs(),
      ]);
      setContentList(cList);
      setCategories(cats);
      setHomepageSections(sections);
      setAppSettings(settings);
      setLogs(nLogs);
    } catch (err) {
      console.error('Error loading data from Firestore:', err);
      addToast('error', 'Failed to load data from Firestore');
    } finally {
      setLoadingData(false);
    }
  };

  // Listen to Firebase Auth state
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const adminDocRef = doc(db, 'admins', user.uid);
          const adminDoc = await getDoc(adminDocRef);

          if (adminDoc.exists() && adminDoc.data()?.active === true) {
            const data = adminDoc.data();
            setCurrentUser({
              email: user.email || data.email || '',
              role: (data.role as 'super_admin' | 'editor') || 'super_admin',
              uid: user.uid,
            });
            await loadAllData();
          } else {
            console.warn('User authenticated in Firebase Auth but not registered/active in /admins:', user.email);
            await auth.signOut();
            setCurrentUser(null);
          }
        } catch (e) {
          console.error('Error verifying admin auth state:', e);
          await auth.signOut();
          setCurrentUser(null);
        }
      } else {
        setCurrentUser(null);
      }
      setAuthLoading(false);
    });

    return () => unsubscribe();
  }, []);

  // Handlers
  const handleSaveContent = async (
    item: Partial<ContentItem>,
    sendPush: boolean,
    pushTopic: string
  ) => {
    try {
      const id = await saveContent(item, currentUser?.email || 'Admin');
      addToast('success', 'Content Saved Successfully', `Document ID: ${id}`);

      // Dispatch push if requested (Specification 153)
      if (sendPush && item.title) {
        await sendPushNotification({
          title: item.title,
          body: item.excerpt || `${item.organization}: Tap to view details`,
          topic: pushTopic,
          contentId: id,
        });
        addToast('success', 'Push Notification Dispatched', `Broadcasted to topic: ${pushTopic}`);
      }

      // Refresh list and return to content list
      const updated = await fetchContentList({});
      setContentList(updated);
      setEditingItem(null);
      setCurrentView('content_all');
    } catch (err: any) {
      addToast('error', 'Failed to save content', err?.message);
    }
  };

  const handleDuplicateContent = (item: ContentItem) => {
    const cloned: ContentItem = {
      ...item,
      id: '',
      title: `${item.title} (Copy)`,
      slug: `${item.slug || 'copy'}-${Date.now().toString().slice(-4)}`,
      status: 'draft',
      isPublished: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    setEditingItem(cloned);
    setPresetType(item.contentType);
    setCurrentView('content_add');
    addToast('info', 'Cloned into Draft', 'Make any changes and click Save to create.');
  };

  const handleTogglePublish = async (id: string, isPublished: boolean) => {
    try {
      await toggleContentPublish(id, isPublished);
      addToast('success', isPublished ? 'Content Published Live' : 'Content Moved to Drafts');
      const updated = await fetchContentList({});
      setContentList(updated);
    } catch (err: any) {
      addToast('error', 'Failed to update publish state', err?.message);
    }
  };

  const handleArchiveContent = async (id: string) => {
    await archiveContent(id);
    addToast('info', 'Content Moved to Archive');
    const updated = await fetchContentList({});
    setContentList(updated);
  };

  const handleDeleteContent = async (id: string) => {
    if (window.confirm('Are you sure you want to permanently delete this document?')) {
      await deleteContentPermanently(id);
      addToast('success', 'Document permanently deleted');
      const updated = await fetchContentList({});
      setContentList(updated);
    }
  };

  const handleSaveCategory = async (cat: Partial<Category>) => {
    await saveCategory(cat);
    addToast('success', 'Category updated');
    const updated = await fetchCategories();
    setCategories(updated);
  };

  const handleDeleteCategory = async (id: string) => {
    if (window.confirm('Delete category?')) {
      await deleteCategory(id);
      addToast('info', 'Category removed');
      const updated = await fetchCategories();
      setCategories(updated);
    }
  };

  const handleSaveHomepageSections = async (sections: HomepageSection[]) => {
    await saveHomepageSections(sections);
    setHomepageSections(sections);
    addToast('success', 'Homepage layout configuration saved');
  };

  const handleSaveSettings = async (newSettings: Partial<AppSettings>) => {
    await saveAppSettings(newSettings);
    setAppSettings((prev) => ({ ...prev, ...newSettings }));
    addToast('success', 'App settings updated in real-time');
  };

  // Titles mapping
  const viewTitles: Record<NavView, string> = {
    dashboard: 'Dashboard Overview',
    content_all: 'All Content',
    content_add: 'Create New Content',
    jobs_all: 'All Jobs',
    jobs_govt: 'Government Jobs',
    jobs_andaman: 'Andaman & Nicobar Jobs',
    jobs_ssc: 'SSC Jobs & Notifications',
    jobs_railway: 'Railway Recruitment',
    jobs_banking: 'Banking Recruitments',
    jobs_police: 'Police & Defence Jobs',
    updates_admit_cards: 'Admit Cards & Hall Tickets',
    updates_results: 'Exam Results & Merit Lists',
    updates_answer_keys: 'Answer Keys & Objections',
    updates_syllabus: 'Syllabus & Exam Pattern',
    articles_all: 'Editorial Articles & Guides',
    // Legacy aliases
    content_govt: 'Government Jobs',
    content_private: 'Private Jobs',
    content_andaman: 'Andaman & Nicobar Jobs',
    content_ssc: 'SSC Jobs',
    content_railway: 'Railway Jobs',
    content_banking: 'Banking Jobs',
    content_police: 'Police & Defence Jobs',
    content_admit_cards: 'Admit Cards',
    content_results: 'Results',
    content_answer_keys: 'Answer Keys',
    content_syllabus: 'Syllabus',
    content_articles: 'Articles',
    // Admin features
    categories: 'Category Management',
    homepage: 'Homepage Layout Manager',
    notifications: 'Push Notification Hub',
    social_support: 'Social Channels & Support',
    ad_settings: 'AdMob & Reward Controls',
    app_settings: 'Remote App Settings',
    admin_users: 'Admin Team & Roles',
    diagnostics: 'Diagnostics & Connectivity',
  };

  // Synchronize hash with currentView for bookmarking and browser navigation
  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.replace('#', '') as NavView;
      if (hash && viewTitles[hash]) {
        setCurrentView(hash);
      }
    };

    const initialHash = window.location.hash.replace('#', '') as NavView;
    if (initialHash && viewTitles[initialHash]) {
      setCurrentView(initialHash);
    }

    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  useEffect(() => {
    if (window.location.hash.replace('#', '') !== currentView) {
      window.location.hash = currentView;
    }
  }, [currentView]);

  // Compute real-time sidebar count badges matching CMS list filters
  const sidebarCounts = React.useMemo(() => {
    return {
      all: contentList.length,
      jobs_all: contentList.filter(
        (i) => i.contentType === 'government_job' || i.contentType === 'andaman_job' || i.contentType === 'private_job'
      ).length,
      jobs_govt: contentList.filter((i) => i.contentType === 'government_job').length,
      jobs_andaman: contentList.filter((i) => i.contentType === 'andaman_job').length,
      jobs_ssc: contentList.filter(
        (i) => (i.contentType === 'government_job' || i.contentType === 'andaman_job') && isCategoryMatch(i, 'ssc')
      ).length,
      jobs_railway: contentList.filter(
        (i) => (i.contentType === 'government_job' || i.contentType === 'andaman_job') && isCategoryMatch(i, 'railway')
      ).length,
      jobs_banking: contentList.filter(
        (i) => (i.contentType === 'government_job' || i.contentType === 'andaman_job') && isCategoryMatch(i, 'banking')
      ).length,
      jobs_police: contentList.filter(
        (i) => (i.contentType === 'government_job' || i.contentType === 'andaman_job') && isCategoryMatch(i, 'police-defence')
      ).length,
      updates_all: contentList.filter((i) =>
        ['admit_card', 'result', 'answer_key', 'syllabus'].includes(i.contentType)
      ).length,
      updates_admit_cards: contentList.filter((i) => i.contentType === 'admit_card').length,
      updates_results: contentList.filter((i) => i.contentType === 'result').length,
      updates_answer_keys: contentList.filter((i) => i.contentType === 'answer_key').length,
      updates_syllabus: contentList.filter((i) => i.contentType === 'syllabus').length,
      articles_all: contentList.filter((i) => i.contentType === 'article').length,
    };
  }, [contentList]);

  if (authLoading) {
    return (
      <div className="min-h-screen bg-slate-900 flex items-center justify-center">
        <div className="flex flex-col items-center gap-4 text-white">
          <div className="w-10 h-10 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-sm font-medium text-slate-400">Verifying Admin Session...</p>
        </div>
      </div>
    );
  }

  // If user is not logged in
  if (!currentUser) {
    return (
      <LoginPage
        onLoginSuccess={(user) => {
          setCurrentUser(user);
          addToast('success', 'Signed In', `Welcome back, ${user.email}`);
        }}
      />
    );
  }

  const renderCurrentView = () => {
    if (currentView === 'content_add' || editingItem !== null) {
      return (
        <ContentEditorPage
          initialItem={editingItem}
          categories={categories}
          presetType={presetType}
          userEmail={currentUser.email}
          onSave={handleSaveContent}
          onCancel={() => {
            setEditingItem(null);
            setPresetType(undefined);
            setCurrentView('content_all');
          }}
        />
      );
    }

    switch (currentView) {
      case 'dashboard':
        return (
          <DashboardPage
            items={contentList}
            logs={logs}
            onNavigate={(v) => setCurrentView(v)}
            onEditItem={(item) => setEditingItem(item)}
          />
        );

      case 'categories':
        return (
          <CategoryManagerPage
            categories={categories}
            onSaveCategory={handleSaveCategory}
            onDeleteCategory={handleDeleteCategory}
          />
        );

      case 'homepage':
        return (
          <HomepageManagerPage
            sections={homepageSections}
            categories={categories}
            onSaveSections={handleSaveHomepageSections}
          />
        );

      case 'notifications':
        return (
          <NotificationManagerPage
            items={contentList}
            logs={logs}
            onRefreshLogs={async () => {
              const updated = await fetchNotificationLogs();
              setLogs(updated);
            }}
          />
        );

      case 'social_support':
        return (
          <SocialAndSupportPage
            settings={appSettings}
            onSaveSettings={handleSaveSettings}
          />
        );

      case 'ad_settings':
        return (
          <AdSettingsPage
            settings={appSettings}
            onSaveSettings={handleSaveSettings}
          />
        );

      case 'app_settings':
        return (
          <AppSettingsPage
            settings={appSettings}
            onSaveSettings={handleSaveSettings}
          />
        );

      case 'admin_users':
        return <AdminUsersPage currentUserRole={currentUser.role} />;

      case 'diagnostics':
        return <DiagnosticsPage />;

      default: {
        // Precise configurations for all content views
        const contentConfigs: Record<
          string,
          {
            type: ContentType | 'all' | 'jobs';
            category: string | 'all';
            title: string;
            breadcrumbs: string[];
            defaultPreset?: ContentType;
          }
        > = {
          content_all: {
            type: 'all',
            category: 'all',
            title: 'All Content',
            breadcrumbs: ['Content Management', 'All Content'],
          },
          jobs_all: {
            type: 'jobs',
            category: 'all',
            title: 'All Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'All Jobs'],
            defaultPreset: 'government_job',
          },
          jobs_govt: {
            type: 'government_job',
            category: 'all',
            title: 'Government Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'Government Jobs'],
            defaultPreset: 'government_job',
          },
          content_govt: {
            type: 'government_job',
            category: 'all',
            title: 'Government Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'Government Jobs'],
            defaultPreset: 'government_job',
          },
          jobs_andaman: {
            type: 'andaman_job',
            category: 'all',
            title: 'Andaman & Nicobar Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'A&N Jobs'],
            defaultPreset: 'andaman_job',
          },
          content_andaman: {
            type: 'andaman_job',
            category: 'all',
            title: 'Andaman & Nicobar Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'A&N Jobs'],
            defaultPreset: 'andaman_job',
          },
          jobs_ssc: {
            type: 'government_job',
            category: 'ssc',
            title: 'SSC Recruitment',
            breadcrumbs: ['Content Management', 'Jobs', 'SSC'],
            defaultPreset: 'government_job',
          },
          content_ssc: {
            type: 'government_job',
            category: 'ssc',
            title: 'SSC Recruitment',
            breadcrumbs: ['Content Management', 'Jobs', 'SSC'],
            defaultPreset: 'government_job',
          },
          jobs_railway: {
            type: 'government_job',
            category: 'railway',
            title: 'Railway Recruitment',
            breadcrumbs: ['Content Management', 'Jobs', 'Railway'],
            defaultPreset: 'government_job',
          },
          content_railway: {
            type: 'government_job',
            category: 'railway',
            title: 'Railway Recruitment',
            breadcrumbs: ['Content Management', 'Jobs', 'Railway'],
            defaultPreset: 'government_job',
          },
          jobs_banking: {
            type: 'government_job',
            category: 'banking',
            title: 'Banking Recruitments',
            breadcrumbs: ['Content Management', 'Jobs', 'Banking'],
            defaultPreset: 'government_job',
          },
          content_banking: {
            type: 'government_job',
            category: 'banking',
            title: 'Banking Recruitments',
            breadcrumbs: ['Content Management', 'Jobs', 'Banking'],
            defaultPreset: 'government_job',
          },
          jobs_police: {
            type: 'government_job',
            category: 'police-defence',
            title: 'Police & Defence Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'Police & Defence'],
            defaultPreset: 'government_job',
          },
          content_police: {
            type: 'government_job',
            category: 'police-defence',
            title: 'Police & Defence Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'Police & Defence'],
            defaultPreset: 'government_job',
          },
          updates_admit_cards: {
            type: 'admit_card',
            category: 'all',
            title: 'Admit Cards & Hall Tickets',
            breadcrumbs: ['Content Management', 'Updates', 'Admit Cards'],
            defaultPreset: 'admit_card',
          },
          content_admit_cards: {
            type: 'admit_card',
            category: 'all',
            title: 'Admit Cards & Hall Tickets',
            breadcrumbs: ['Content Management', 'Updates', 'Admit Cards'],
            defaultPreset: 'admit_card',
          },
          updates_results: {
            type: 'result',
            category: 'all',
            title: 'Exam Results & Merit Lists',
            breadcrumbs: ['Content Management', 'Updates', 'Results'],
            defaultPreset: 'result',
          },
          content_results: {
            type: 'result',
            category: 'all',
            title: 'Exam Results & Merit Lists',
            breadcrumbs: ['Content Management', 'Updates', 'Results'],
            defaultPreset: 'result',
          },
          updates_answer_keys: {
            type: 'answer_key',
            category: 'all',
            title: 'Answer Keys & Objections',
            breadcrumbs: ['Content Management', 'Updates', 'Answer Keys'],
            defaultPreset: 'answer_key',
          },
          content_answer_keys: {
            type: 'answer_key',
            category: 'all',
            title: 'Answer Keys & Objections',
            breadcrumbs: ['Content Management', 'Updates', 'Answer Keys'],
            defaultPreset: 'answer_key',
          },
          updates_syllabus: {
            type: 'syllabus',
            category: 'all',
            title: 'Syllabus & Exam Pattern',
            breadcrumbs: ['Content Management', 'Updates', 'Syllabus'],
            defaultPreset: 'syllabus',
          },
          content_syllabus: {
            type: 'syllabus',
            category: 'all',
            title: 'Syllabus & Exam Pattern',
            breadcrumbs: ['Content Management', 'Updates', 'Syllabus'],
            defaultPreset: 'syllabus',
          },
          articles_all: {
            type: 'article',
            category: 'all',
            title: 'Editorial Articles & Guides',
            breadcrumbs: ['Content Management', 'Articles'],
            defaultPreset: 'article',
          },
          content_articles: {
            type: 'article',
            category: 'all',
            title: 'Editorial Articles & Guides',
            breadcrumbs: ['Content Management', 'Articles'],
            defaultPreset: 'article',
          },
          content_private: {
            type: 'private_job',
            category: 'all',
            title: 'Private Jobs',
            breadcrumbs: ['Content Management', 'Jobs', 'Private Jobs'],
          },
        };

        const config = contentConfigs[currentView] || contentConfigs.content_all;

        return (
          <ContentListPage
            items={contentList}
            categories={categories}
            currentTypeFilter={config.type}
            currentCategoryFilter={config.category}
            pageTitle={config.title}
            breadcrumbs={config.breadcrumbs}
            onAddNew={(type) => {
              setEditingItem(null);
              setPresetType(type || config.defaultPreset);
              setCurrentView('content_add');
            }}
            onEditItem={(item) => setEditingItem(item)}
            onDuplicateItem={handleDuplicateContent}
            onPreviewItem={(item) => setPreviewItem(item)}
            onTogglePublish={handleTogglePublish}
            onArchiveItem={handleArchiveContent}
            onDeleteItem={handleDeleteContent}
          />
        );
      }
    }
  };

  return (
    <AdminLayout
      currentView={currentView}
      onNavigate={(v) => {
        setEditingItem(null);
        setCurrentView(v);
      }}
      title={viewTitles[currentView] || 'Notify Jobs Admin'}
      userEmail={currentUser.email}
      userRole={currentUser.role}
      counts={sidebarCounts}
      onLogout={() => {
        auth.signOut().catch(() => {});
        setCurrentUser(null);
      }}
      onAddNew={() => {
        setEditingItem(null);
        setPresetType(undefined);
        setCurrentView('content_add');
      }}
      onOpenMobilePreview={() => {
        if (contentList.length > 0) setPreviewItem(contentList[0]);
      }}
    >
      {renderCurrentView()}

      {/* Global Mobile Preview Modal */}
      {previewItem && (
        <MobilePreviewModal
          isOpen={Boolean(previewItem)}
          onClose={() => setPreviewItem(null)}
          item={previewItem}
        />
      )}

      {/* Global Toast System */}
      <AdminToast toasts={toasts} onDismiss={removeToast} />
    </AdminLayout>
  );
}
