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

  // Titles mapping
  const viewTitles: Record<NavView, string> = {
    dashboard: 'Dashboard Overview',
    content_all: 'All Content & Jobs',
    content_add: 'Create New Content',
    content_govt: 'Government Jobs',
    content_private: 'Private Jobs',
    content_andaman: 'Andaman & Nicobar Jobs',
    content_ssc: 'SSC Jobs & Notifications',
    content_railway: 'Railway Recruitment',
    content_banking: 'Banking Recruitments',
    content_police: 'Police & Defence Jobs',
    content_admit_cards: 'Admit Cards & Hall Tickets',
    content_results: 'Exam Results & Merit Lists',
    content_answer_keys: 'Answer Keys & Objections',
    content_syllabus: 'Syllabus & Exam Pattern',
    content_articles: 'Editorial Articles & Guides',
    categories: 'Category Management',
    homepage: 'Homepage Layout Manager',
    notifications: 'Push Notification Hub',
    social_support: 'Social Channels & Support',
    ad_settings: 'AdMob & Reward Controls',
    app_settings: 'Remote App Settings',
    admin_users: 'Admin Team & Roles',
    diagnostics: 'Diagnostics & Connectivity',
  };

  // Content type filter helper
  const getContentTypeForView = (view: NavView): ContentType | 'all' => {
    switch (view) {
      case 'content_govt':
      case 'content_andaman':
      case 'content_ssc':
      case 'content_railway':
      case 'content_banking':
      case 'content_police':
        return 'government_job';
      case 'content_private':
        return 'private_job';
      case 'content_admit_cards':
        return 'admit_card';
      case 'content_results':
        return 'result';
      case 'content_answer_keys':
        return 'answer_key';
      case 'content_syllabus':
        return 'syllabus';
      case 'content_articles':
        return 'article';
      default:
        return 'all';
    }
  };

  const renderCurrentView = () => {
    if (currentView === 'content_add' || editingItem !== null) {
      return (
        <ContentEditorPage
          initialItem={editingItem}
          categories={categories}
          userEmail={currentUser.email}
          onSave={handleSaveContent}
          onCancel={() => {
            setEditingItem(null);
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

      default:
        // Content list views (all, govt, andaman, ssc, results, etc.)
        return (
          <ContentListPage
            items={contentList}
            currentTypeFilter={getContentTypeForView(currentView)}
            onAddNew={() => {
              setEditingItem(null);
              setCurrentView('content_add');
            }}
            onEditItem={(item) => setEditingItem(item)}
            onPreviewItem={(item) => setPreviewItem(item)}
            onArchiveItem={handleArchiveContent}
            onDeleteItem={handleDeleteContent}
          />
        );
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
      onLogout={() => {
        auth.signOut().catch(() => {});
        setCurrentUser(null);
      }}
      onAddNew={() => {
        setEditingItem(null);
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
