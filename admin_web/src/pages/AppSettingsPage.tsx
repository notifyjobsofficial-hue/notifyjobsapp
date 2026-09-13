import React, { useState } from 'react';
import { Save, Check, Wrench, RefreshCw, AlertTriangle, Share2 } from 'lucide-react';
import { AppSettings } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';

interface AppSettingsPageProps {
  settings: AppSettings;
  onSaveSettings: (settings: Partial<AppSettings>) => Promise<void>;
}

export const AppSettingsPage: React.FC<AppSettingsPageProps> = ({
  settings: initialSettings,
  onSaveSettings,
}) => {
  const [settings, setSettings] = useState<AppSettings>({ ...initialSettings });
  const [saving, setSaving] = useState(false);
  const [savedSuccess, setSavedSuccess] = useState(false);

  const handleUpdate = (field: keyof AppSettings, value: any) => {
    setSettings((prev) => ({ ...prev, [field]: value }));
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await onSaveSettings(settings);
      setSavedSuccess(true);
      setTimeout(() => setSavedSuccess(false), 3000);
    } finally {
      setSaving(false);
    }
  };

  return (
    <form onSubmit={handleSave} className="space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900">App Remote Settings</h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Manage branding text, maintenance mode, force version gates, and official disclaimers
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          {savedSuccess && (
            <span className="text-xs text-emerald-600 font-semibold flex items-center gap-1">
              <Check className="w-3.5 h-3.5" /> Settings Saved
            </span>
          )}
          <AdminButton
            type="submit"
            variant="primary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
          >
            Save Settings
          </AdminButton>
        </div>
      </div>

      {/* Brand & Tagline */}
      <AdminCard
        title="Branding & Tagline"
        subtitle="Configurable supporting text shown across the mobile app"
      >
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <AdminInput
            label="App Title"
            value={settings.appTitle || 'Notify Jobs'}
            onChange={(e) => handleUpdate('appTitle', e.target.value)}
          />
          <AdminInput
            label="Tagline Concept"
            value={settings.tagline || ''}
            onChange={(e) => handleUpdate('tagline', e.target.value)}
            placeholder="Government Jobs. Results. Admit Cards. One App."
            hint="Admins can change this without releasing a new APK"
          />
        </div>
      </AdminCard>

      {/* Maintenance Mode (Specification 143) */}
      <AdminCard
        title="Remote Maintenance Barrier"
        subtitle="Instantly locks the mobile app with a friendly maintenance screen during server migrations"
      >
        <div className="space-y-4">
          <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
            <input
              type="checkbox"
              checked={settings.maintenanceMode}
              onChange={(e) => handleUpdate('maintenanceMode', e.target.checked)}
              className="w-5 h-5 rounded text-amber-600 focus:ring-amber-600 mt-0.5"
            />
            <div>
              <span className="text-sm font-bold text-slate-900 block flex items-center gap-2">
                <Wrench className="w-4 h-4 text-amber-600" />
                Activate Maintenance Mode
              </span>
              <span className="text-xs text-slate-500 block mt-0.5">
                When enabled, the Flutter app displays a full-screen maintenance message and disables requests.
              </span>
            </div>
          </label>

          {settings.maintenanceMode && (
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Custom Maintenance Notice Message
              </label>
              <textarea
                rows={2}
                value={settings.maintenanceMessage}
                onChange={(e) => handleUpdate('maintenanceMessage', e.target.value)}
                placeholder="We are upgrading our servers to serve you better. We will be back online shortly!"
                className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
              />
            </div>
          )}
        </div>
      </AdminCard>

      {/* Version Control (Specification 144) */}
      <AdminCard
        title="Remote Version Control &amp; Play Store Gates"
        subtitle="Enforce mandatory minimum versions or display update suggestions"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <AdminInput
              label="Minimum Required App Version"
              value={settings.minimumAppVersion}
              onChange={(e) => handleUpdate('minimumAppVersion', e.target.value)}
              placeholder="1.0.0"
              hint="Users running an older version will see a blocking update screen"
            />
            <AdminInput
              label="Latest Available App Version"
              value={settings.latestAppVersion}
              onChange={(e) => handleUpdate('latestAppVersion', e.target.value)}
              placeholder="1.0.1"
              hint="Shows an optional non-blocking update banner"
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

      {/* Share Base URL & Official Disclaimer (Specification 31 & 108) */}
      <AdminCard
        title="Share URLs &amp; Independent Disclaimer"
        subtitle="Ensure public links never point to old/sold domains, and maintain strict legal compliance"
      >
        <div className="space-y-4">
          <AdminInput
            label="Public Share URL Base"
            value={settings.shareBaseUrl}
            onChange={(e) => handleUpdate('shareBaseUrl', e.target.value)}
            placeholder="https://notifyjobs.in/job"
            hint="Used when users share jobs on WhatsApp, Telegram, or Copy Link"
          />

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1.5">
              Official Disclaimer Text (Specification 108)
            </label>
            <textarea
              rows={3}
              value={settings.disclaimer}
              onChange={(e) => handleUpdate('disclaimer', e.target.value)}
              className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
            />
            <p className="text-[11px] text-slate-400 mt-1">
              Displayed prominently on every job detail screen and the More tab.
            </p>
          </div>
        </div>
      </AdminCard>
    </form>
  );
};
