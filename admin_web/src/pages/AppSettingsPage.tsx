import React, { useState } from 'react';
import {
  Save,
  Check,
  Wrench,
  AlertCircle,
  Layout,
  Sliders,
  Share2,
  ShieldAlert,
  Bell,
  Sparkles,
  HelpCircle,
  Tv,
  Megaphone,
  Flame,
  Clock,
  Layers,
  FileCheck
} from 'lucide-react';
import { AppSettings } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';

interface AppSettingsPageProps {
  settings: AppSettings;
  onSaveSettings: (settings: Partial<AppSettings>) => Promise<void>;
}

type TabType = 'home' | 'general' | 'features' | 'social' | 'ads' | 'legal';

const ToggleSwitch: React.FC<{
  checked: boolean;
  onChange: (checked: boolean) => void;
  label: string;
  description?: string;
  badge?: string;
}> = ({ checked, onChange, label, description, badge }) => (
  <div className="flex items-center justify-between p-3.5 bg-slate-50 border border-slate-200/80 rounded-xl hover:bg-slate-100/60 transition-colors">
    <div className="pr-4">
      <div className="flex items-center gap-2">
        <span className="text-sm font-semibold text-slate-900">{label}</span>
        {badge && (
          <span className="text-[10px] uppercase tracking-wider font-bold px-1.5 py-0.5 rounded bg-emerald-100 text-emerald-800">
            {badge}
          </span>
        )}
      </div>
      {description && <div className="text-xs text-slate-500 mt-0.5">{description}</div>}
    </div>
    <button
      type="button"
      onClick={() => onChange(!checked)}
      className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
        checked ? 'bg-[#159B76]' : 'bg-slate-300'
      }`}
    >
      <span
        className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
          checked ? 'translate-x-5' : 'translate-x-0'
        }`}
      />
    </button>
  </div>
);

export const AppSettingsPage: React.FC<AppSettingsPageProps> = ({
  settings: initialSettings,
  onSaveSettings,
}) => {
  const [settings, setSettings] = useState<AppSettings>({ ...initialSettings });
  const [activeTab, setActiveTab] = useState<TabType>('home');
  const [saving, setSaving] = useState(false);
  const [savedSuccess, setSavedSuccess] = useState(false);
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  const handleUpdate = (field: keyof AppSettings, value: any) => {
    setSettings((prev) => ({ ...prev, [field]: value }));
    setHasUnsavedChanges(true);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await onSaveSettings(settings);
      setSavedSuccess(true);
      setHasUnsavedChanges(false);
      setTimeout(() => setSavedSuccess(false), 3000);
    } catch (err) {
      console.error('Failed to save settings:', err);
      alert('Failed to save settings to Firestore. Please verify your connection.');
    } finally {
      setSaving(false);
    }
  };

  const tabs: { id: TabType; label: string; icon: React.ReactNode }[] = [
    { id: 'home', label: 'Home Screen', icon: <Layout className="w-4 h-4" /> },
    { id: 'general', label: 'General & Versions', icon: <Sliders className="w-4 h-4" /> },
    { id: 'features', label: 'Feature Flags', icon: <Sparkles className="w-4 h-4" /> },
    { id: 'social', label: 'Social & Support', icon: <Share2 className="w-4 h-4" /> },
    { id: 'ads', label: 'Monetization & Ads', icon: <Tv className="w-4 h-4" /> },
    { id: 'legal', label: 'Legal & Disclaimers', icon: <ShieldAlert className="w-4 h-4" /> },
  ];

  return (
    <form onSubmit={handleSave} className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
        <div>
          <div className="flex items-center gap-3">
            <h2 className="text-xl font-bold text-slate-900 tracking-tight">App Remote Configuration</h2>
            {hasUnsavedChanges ? (
              <span className="px-2.5 py-0.5 text-xs font-semibold bg-amber-100 text-amber-800 rounded-full flex items-center gap-1">
                <AlertCircle className="w-3 h-3" /> Unsaved changes
              </span>
            ) : (
              <span className="px-2.5 py-0.5 text-xs font-semibold bg-slate-100 text-slate-600 rounded-full">
                In sync with Firestore
              </span>
            )}
          </div>
          <p className="text-xs text-slate-500 mt-1">
            Live admin control layer: dynamically configure home modules, announcement banners, and feature visibility
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          {savedSuccess && (
            <span className="text-xs text-emerald-600 font-semibold flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 rounded-xl border border-emerald-200">
              <Check className="w-4 h-4" /> Settings Saved Successfully
            </span>
          )}
          <AdminButton
            type="submit"
            variant="primary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
          >
            Save All Settings
          </AdminButton>
        </div>
      </div>

      {/* Tabs Navigation */}
      <div className="flex items-center gap-1.5 overflow-x-auto pb-1 border-b border-slate-200/80">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            type="button"
            onClick={() => setActiveTab(tab.id)}
            className={`flex items-center gap-2 px-4 py-2.5 text-xs font-bold rounded-xl whitespace-nowrap transition-all ${
              activeTab === tab.id
                ? 'bg-[#159B76] text-white shadow-sm'
                : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100/80'
            }`}
          >
            {tab.icon}
            <span>{tab.label}</span>
          </button>
        ))}
      </div>

      {/* Tab 1: Home Screen Modules */}
      {activeTab === 'home' && (
        <div className="space-y-6">
          {/* Announcement Banner */}
          <AdminCard
            title="Announcement Banner Module"
            subtitle="Display a prominent, scheduled alert ribbon at the top of the mobile home screen"
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.announcementEnabled}
                onChange={(checked) => handleUpdate('announcementEnabled', checked)}
                label="Show Announcement Banner"
                description="When active, renders directly under the search bar. Outside scheduled dates, it stays hidden."
                badge={settings.announcementEnabled ? 'Active' : 'Disabled'}
              />

              {settings.announcementEnabled && (
                <div className="p-4 bg-slate-50 border border-slate-200/70 rounded-xl space-y-4 animate-in fade-in duration-200">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                        Banner Type / Urgency
                      </label>
                      <select
                        value={settings.announcementType || 'New'}
                        onChange={(e) => handleUpdate('announcementType', e.target.value)}
                        className="w-full text-xs rounded-xl border border-slate-200 p-2.5 text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                      >
                        <option value="New">New (Green Badge)</option>
                        <option value="Important">Important (Blue Badge)</option>
                        <option value="Urgent">Urgent (Rose Badge)</option>
                        <option value="General">General (Slate Badge)</option>
                      </select>
                    </div>

                    <AdminInput
                      label="Display Priority (1 = Highest)"
                      type="number"
                      value={settings.announcementPriority || 1}
                      onChange={(e) => handleUpdate('announcementPriority', parseInt(e.target.value) || 1)}
                    />
                  </div>

                  <AdminInput
                    label="Banner Message Text"
                    value={settings.announcementText}
                    onChange={(e) => handleUpdate('announcementText', e.target.value)}
                    placeholder="e.g. UPSC CSE 2026 Prelims Notification is out now!"
                    hint="Keep message concise to avoid truncation on small mobile screens"
                  />

                  <AdminInput
                    label="Destination URL (Optional - If empty, banner is non-clickable)"
                    value={settings.announcementUrl}
                    onChange={(e) => handleUpdate('announcementUrl', e.target.value)}
                    placeholder="https://example.com/announcement"
                  />

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                        Schedule Start (Optional)
                      </label>
                      <input
                        type="datetime-local"
                        value={settings.announcementStartAt ? settings.announcementStartAt.slice(0, 16) : ''}
                        onChange={(e) => handleUpdate('announcementStartAt', e.target.value ? new Date(e.target.value).toISOString() : '')}
                        className="w-full text-xs rounded-xl border border-slate-200 p-2.5 text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                        Schedule Expiry (Optional)
                      </label>
                      <input
                        type="datetime-local"
                        value={settings.announcementEndAt ? settings.announcementEndAt.slice(0, 16) : ''}
                        onChange={(e) => handleUpdate('announcementEndAt', e.target.value ? new Date(e.target.value).toISOString() : '')}
                        className="w-full text-xs rounded-xl border border-slate-200 p-2.5 text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                      />
                    </div>
                  </div>
                </div>
              )}
            </div>
          </AdminCard>

          {/* Live Updates */}
          <AdminCard
            title="Live Updates Section"
            subtitle="Displays quick ticker items marked 'Show in Live Updates' from published content"
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.liveUpdatesEnabled}
                onChange={(checked) => handleUpdate('liveUpdatesEnabled', checked)}
                label="Show Live Updates Carousel"
                description="Pulls real published vacancies marked for live stream. Never invents fake updates."
              />

              {settings.liveUpdatesEnabled && (
                <div className="p-4 bg-slate-50 border border-slate-200/70 rounded-xl space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <AdminInput
                      label="Section Title"
                      value={settings.liveUpdatesTitle || 'Live Updates'}
                      onChange={(e) => handleUpdate('liveUpdatesTitle', e.target.value)}
                    />
                    <AdminInput
                      label="Maximum Items to Display"
                      type="number"
                      value={settings.liveUpdatesMaxItems || 5}
                      onChange={(e) => handleUpdate('liveUpdatesMaxItems', parseInt(e.target.value) || 5)}
                    />
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 items-center">
                    <ToggleSwitch
                      checked={settings.liveUpdatesAutoSlideEnabled}
                      onChange={(checked) => handleUpdate('liveUpdatesAutoSlideEnabled', checked)}
                      label="Auto-Slide Carousel"
                      description="Automatically rotate slides on the mobile screen"
                    />
                    <AdminInput
                      label="Auto-Slide Interval (Seconds)"
                      type="number"
                      value={settings.liveUpdatesAutoSlideSeconds || 4}
                      onChange={(e) => handleUpdate('liveUpdatesAutoSlideSeconds', parseInt(e.target.value) || 4)}
                    />
                  </div>
                </div>
              )}
            </div>
          </AdminCard>

          {/* Closing Soon */}
          <AdminCard
            title="Closing Soon Section"
            subtitle="Automatically calculated from official application deadlines"
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.closingSoonEnabled}
                onChange={(checked) => handleUpdate('closingSoonEnabled', checked)}
                label="Show Closing Soon Section"
                description="Dynamic calculation: queries jobs closing within the threshold. Empty state renders if no jobs close soon."
              />

              {settings.closingSoonEnabled && (
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 p-4 bg-slate-50 border border-slate-200/70 rounded-xl">
                  <AdminInput
                    label="Section Title"
                    value={settings.closingSoonTitle || 'Closing Soon'}
                    onChange={(e) => handleUpdate('closingSoonTitle', e.target.value)}
                  />
                  <AdminInput
                    label="Days Threshold (e.g. 7)"
                    type="number"
                    value={settings.closingSoonDaysThreshold || 7}
                    onChange={(e) => handleUpdate('closingSoonDaysThreshold', parseInt(e.target.value) || 7)}
                    hint="Shows vacancies with deadlines within this many days"
                  />
                  <AdminInput
                    label="Max Items to Display"
                    type="number"
                    value={settings.closingSoonMaxItems || 5}
                    onChange={(e) => handleUpdate('closingSoonMaxItems', parseInt(e.target.value) || 5)}
                  />
                </div>
              )}
            </div>
          </AdminCard>

          {/* Popular This Week */}
          <AdminCard
            title="Popular This Week Section"
            subtitle="Ranks real vacancies based on aspirant view counts. Safe deterministic fallback if no views exist."
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.popularEnabled}
                onChange={(checked) => handleUpdate('popularEnabled', checked)}
                label="Show Popular This Week"
                description="Based strictly on real Firestore view counts. Zero fake stats."
              />

              {settings.popularEnabled && (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-4 bg-slate-50 border border-slate-200/70 rounded-xl">
                  <AdminInput
                    label="Section Title"
                    value={settings.popularTitle || 'Popular This Week'}
                    onChange={(e) => handleUpdate('popularTitle', e.target.value)}
                  />
                  <AdminInput
                    label="Max Items to Display"
                    type="number"
                    value={settings.popularMaxItems || 5}
                    onChange={(e) => handleUpdate('popularMaxItems', parseInt(e.target.value) || 5)}
                  />
                </div>
              )}
            </div>
          </AdminCard>

          {/* Latest Jobs */}
          <AdminCard
            title="Latest Jobs Section"
            subtitle="Displays published opportunities ordered by publication date"
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.latestJobsEnabled}
                onChange={(checked) => handleUpdate('latestJobsEnabled', checked)}
                label="Show Latest Jobs Section"
                description="Queries published government, private, and Andaman vacancies."
              />

              {settings.latestJobsEnabled && (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-4 bg-slate-50 border border-slate-200/70 rounded-xl">
                  <AdminInput
                    label="Section Title"
                    value={settings.latestJobsTitle || 'Latest Jobs'}
                    onChange={(e) => handleUpdate('latestJobsTitle', e.target.value)}
                  />
                  <AdminInput
                    label="Max Items to Display"
                    type="number"
                    value={settings.latestJobsMaxItems || 6}
                    onChange={(e) => handleUpdate('latestJobsMaxItems', parseInt(e.target.value) || 6)}
                  />
                </div>
              )}
            </div>
          </AdminCard>

          {/* Quick Categories */}
          <AdminCard
            title="Quick Categories Section"
            subtitle="Grid of recruitment departments (Govt Jobs, SSC, Railway, A&N Jobs, Admit Cards, etc.)"
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.quickCategoriesEnabled}
                onChange={(checked) => handleUpdate('quickCategoriesEnabled', checked)}
                label="Show Quick Categories Grid"
                description="When enabled, renders 2-column shortcut tiles on the Home screen."
              />

              {settings.quickCategoriesEnabled && (
                <div className="p-4 bg-slate-50 border border-slate-200/70 rounded-xl">
                  <AdminInput
                    label="Section Title"
                    value={settings.quickCategoriesTitle || 'Quick Categories'}
                    onChange={(e) => handleUpdate('quickCategoriesTitle', e.target.value)}
                  />
                </div>
              )}
            </div>
          </AdminCard>
        </div>
      )}

      {/* Tab 2: General & Versions */}
      {activeTab === 'general' && (
        <div className="space-y-6">
          <AdminCard
            title="Branding & Tagline"
            subtitle="Configurable branding strings displayed in the app header and drawer"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="App Title"
                value={settings.appTitle || 'Notify Jobs'}
                onChange={(e) => handleUpdate('appTitle', e.target.value)}
              />
              <AdminInput
                label="App Tagline"
                value={settings.tagline || ''}
                onChange={(e) => handleUpdate('tagline', e.target.value)}
                placeholder="Government Jobs. Results. Admit Cards. One App."
              />
            </div>
          </AdminCard>

          <AdminCard
            title="Remote Maintenance Barrier"
            subtitle="Lock the mobile app with a friendly maintenance screen during server migrations or maintenance"
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.maintenanceMode}
                onChange={(checked) => handleUpdate('maintenanceMode', checked)}
                label="Activate Maintenance Mode"
                description="When active, end users see a full-screen maintenance message and cannot make requests."
              />

              {settings.maintenanceMode && (
                <div className="p-4 bg-amber-50 border border-amber-200 rounded-xl space-y-2">
                  <label className="block text-xs font-semibold text-amber-900">
                    Custom Maintenance Message
                  </label>
                  <textarea
                    rows={2}
                    value={settings.maintenanceMessage}
                    onChange={(e) => handleUpdate('maintenanceMessage', e.target.value)}
                    placeholder="We are upgrading our servers to serve you better. We will be back online shortly!"
                    className="w-full text-xs rounded-xl border border-amber-300 p-3 text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-amber-500/20"
                  />
                </div>
              )}
            </div>
          </AdminCard>

          <AdminCard
            title="Remote Version Control & Play Store Gate"
            subtitle="Enforce minimum required app versions and offer update notices"
          >
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <AdminInput
                  label="Minimum Required App Version"
                  value={settings.minimumAppVersion}
                  onChange={(e) => handleUpdate('minimumAppVersion', e.target.value)}
                  placeholder="1.0.0"
                  hint="Users on older versions will see a blocking update prompt"
                />
                <AdminInput
                  label="Latest Available App Version"
                  value={settings.latestAppVersion}
                  onChange={(e) => handleUpdate('latestAppVersion', e.target.value)}
                  placeholder="1.0.1"
                  hint="Shows a non-blocking update banner if user is on older version"
                />
              </div>
              <AdminInput
                label="Google Play Store URL"
                value={settings.playStoreUrl}
                onChange={(e) => handleUpdate('playStoreUrl', e.target.value)}
                placeholder="https://play.google.com/store/apps/details?id=com.notifyjobs.app"
              />
            </div>
          </AdminCard>
        </div>
      )}

      {/* Tab 3: Feature Flags */}
      {activeTab === 'features' && (
        <div className="space-y-6">
          <AdminCard
            title="Feature Flags & Module Visibility"
            subtitle="Turn on or off optional modules cleanly. Disabled modules disappear with zero empty gaps."
          >
            <div className="space-y-3">
              <ToggleSwitch
                checked={settings.supportPageEnabled}
                onChange={(checked) => handleUpdate('supportPageEnabled', checked)}
                label="Help & Support Desk"
                description="Show Support Desk in the More screen and footer links"
              />
              <ToggleSwitch
                checked={settings.notificationPreferencesEnabled}
                onChange={(checked) => handleUpdate('notificationPreferencesEnabled', checked)}
                label="Notification Preferences Screen"
                description="Allow aspirants to customize job alert category subscriptions"
              />
              <ToggleSwitch
                checked={settings.socialSectionEnabled}
                onChange={(checked) => handleUpdate('socialSectionEnabled', checked)}
                label="Social Community Channels"
                description="Display WhatsApp, Telegram, YouTube community shortcuts in More tab"
              />
              <ToggleSwitch
                checked={settings.proPageEnabled}
                onChange={(checked) => handleUpdate('proPageEnabled', checked)}
                label="Notify Jobs Pro Gate"
                description="Enable Pro premium membership features and screen"
              />
            </div>
          </AdminCard>
        </div>
      )}

      {/* Tab 4: Social & Support */}
      {activeTab === 'social' && (
        <div className="space-y-6">
          <AdminCard
            title="Help Desk Contacts"
            subtitle="Direct contact details presented on the More -> Help & Support screen"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <AdminInput
                label="Support Email Address"
                type="email"
                value={settings.supportEmail}
                onChange={(e) => handleUpdate('supportEmail', e.target.value)}
                placeholder="support@example.com"
              />
              <AdminInput
                label="Support Website Portal"
                type="url"
                value={settings.supportWebsite}
                onChange={(e) => handleUpdate('supportWebsite', e.target.value)}
                placeholder="https://example.com/help"
              />
            </div>
          </AdminCard>

          <AdminCard
            title="Community Channels"
            subtitle="Official social groups where aspirants receive real-time vacancy alerts"
          >
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-3 bg-slate-50 rounded-xl border border-slate-200/70">
                <AdminInput
                  label="WhatsApp Channel URL"
                  value={settings.whatsappUrl}
                  onChange={(e) => handleUpdate('whatsappUrl', e.target.value)}
                  placeholder="https://whatsapp.com/channel/..."
                />
                <div className="flex items-center pt-5">
                  <ToggleSwitch
                    checked={settings.whatsappEnabled}
                    onChange={(checked) => handleUpdate('whatsappEnabled', checked)}
                    label="Enable WhatsApp"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-3 bg-slate-50 rounded-xl border border-slate-200/70">
                <AdminInput
                  label="Telegram Group URL"
                  value={settings.telegramUrl}
                  onChange={(e) => handleUpdate('telegramUrl', e.target.value)}
                  placeholder="https://t.me/..."
                />
                <div className="flex items-center pt-5">
                  <ToggleSwitch
                    checked={settings.telegramEnabled}
                    onChange={(checked) => handleUpdate('telegramEnabled', checked)}
                    label="Enable Telegram"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-3 bg-slate-50 rounded-xl border border-slate-200/70">
                <AdminInput
                  label="YouTube Channel URL"
                  value={settings.youtubeUrl}
                  onChange={(e) => handleUpdate('youtubeUrl', e.target.value)}
                  placeholder="https://youtube.com/@..."
                />
                <div className="flex items-center pt-5">
                  <ToggleSwitch
                    checked={settings.youtubeEnabled}
                    onChange={(checked) => handleUpdate('youtubeEnabled', checked)}
                    label="Enable YouTube"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-3 bg-slate-50 rounded-xl border border-slate-200/70">
                <AdminInput
                  label="Instagram URL"
                  value={settings.instagramUrl}
                  onChange={(e) => handleUpdate('instagramUrl', e.target.value)}
                  placeholder="https://instagram.com/..."
                />
                <div className="flex items-center pt-5">
                  <ToggleSwitch
                    checked={settings.instagramEnabled}
                    onChange={(checked) => handleUpdate('instagramEnabled', checked)}
                    label="Enable Instagram"
                  />
                </div>
              </div>
            </div>
          </AdminCard>
        </div>
      )}

      {/* Tab 5: Monetization & Ads */}
      {activeTab === 'ads' && (
        <div className="space-y-6">
          <AdminCard
            title="Rewarded Video PDF Gates"
            subtitle="Control whether users watch a short rewarded ad to unlock official recruitment notifications"
          >
            <div className="space-y-4">
              <ToggleSwitch
                checked={settings.rewardedAdsEnabled}
                onChange={(checked) => handleUpdate('rewardedAdsEnabled', checked)}
                label="Enable Rewarded Ads Mechanism"
                description="Monetization feature supporting free ongoing operation"
              />

              <ToggleSwitch
                checked={settings.rewardNotificationEnabled}
                onChange={(checked) => handleUpdate('rewardNotificationEnabled', checked)}
                label="Require Ad to Unlock Official Notification PDF"
                description="When active, tapping 'Download Official PDF' opens the rewarded prompt"
              />

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 p-4 bg-slate-50 border border-slate-200/70 rounded-xl">
                <AdminInput
                  label="Unlock Duration (Minutes)"
                  type="number"
                  value={settings.rewardUnlockMinutes || 30}
                  onChange={(e) => handleUpdate('rewardUnlockMinutes', parseInt(e.target.value) || 30)}
                  hint="Once unlocked, PDF stays unlocked for this long"
                />
                <AdminInput
                  label="Prompt Modal Text"
                  value={settings.rewardPromptText}
                  onChange={(e) => handleUpdate('rewardPromptText', e.target.value)}
                  placeholder="Watch a short ad to open official notification"
                />
                <AdminInput
                  label="Action Button Label"
                  value={settings.rewardButtonText}
                  onChange={(e) => handleUpdate('rewardButtonText', e.target.value)}
                  placeholder="Watch Ad to Unlock"
                />
              </div>
            </div>
          </AdminCard>
        </div>
      )}

      {/* Tab 6: Legal & Compliance */}
      {activeTab === 'legal' && (
        <div className="space-y-6">
          <AdminCard
            title="Public Share Base URL & Legal Disclaimers"
            subtitle="Crucial for Google Play compliance and clear independent operation"
          >
            <div className="space-y-4">
              <AdminInput
                label="Public Share URL Base"
                value={settings.shareBaseUrl}
                onChange={(e) => handleUpdate('shareBaseUrl', e.target.value)}
                placeholder="https://example.com/job"
                hint="Appended with job slug when aspirants share posts on WhatsApp or Telegram"
              />

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <AdminInput
                  label="Privacy Policy URL"
                  type="url"
                  value={settings.privacyUrl}
                  onChange={(e) => handleUpdate('privacyUrl', e.target.value)}
                  placeholder="https://example.com/privacy"
                />
                <AdminInput
                  label="Terms of Service URL"
                  type="url"
                  value={settings.termsUrl}
                  onChange={(e) => handleUpdate('termsUrl', e.target.value)}
                  placeholder="https://example.com/terms"
                />
                <AdminInput
                  label="Disclaimer URL"
                  type="url"
                  value={settings.disclaimerUrl}
                  onChange={(e) => handleUpdate('disclaimerUrl', e.target.value)}
                  placeholder="https://example.com/disclaimer"
                />
                <AdminInput
                  label="Contact Page URL"
                  type="url"
                  value={settings.contactUrl}
                  onChange={(e) => handleUpdate('contactUrl', e.target.value)}
                  placeholder="https://example.com/contact"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  Official Non-Affiliation Disclaimer
                </label>
                <textarea
                  rows={3}
                  value={settings.disclaimer}
                  onChange={(e) => handleUpdate('disclaimer', e.target.value)}
                  className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                />
                <p className="text-[11px] text-slate-400 mt-1">
                  Displayed on the Job Detail screen and More tab to ensure legal clarity.
                </p>
              </div>
            </div>
          </AdminCard>
        </div>
      )}
    </form>
  );
};
