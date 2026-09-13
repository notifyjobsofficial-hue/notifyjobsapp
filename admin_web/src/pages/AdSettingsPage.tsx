import React, { useState } from 'react';
import { Save, Check, Tv, AlertTriangle, ShieldCheck, Lock } from 'lucide-react';
import { AppSettings } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';

interface AdSettingsPageProps {
  settings: AppSettings;
  onSaveSettings: (settings: Partial<AppSettings>) => Promise<void>;
}

export const AdSettingsPage: React.FC<AdSettingsPageProps> = ({
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
          <h2 className="text-xl font-bold text-slate-900">
            AdMob &amp; Rewarded Ad Controls
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Configure rewarded ad gating, unlock caching, and safe development test unit separation
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          {savedSuccess && (
            <span className="text-xs text-emerald-600 font-semibold flex items-center gap-1">
              <Check className="w-3.5 h-3.5" /> Ad Settings Saved
            </span>
          )}
          <AdminButton
            type="submit"
            variant="primary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
          >
            Save Ad Settings
          </AdminButton>
        </div>
      </div>

      {/* Critical Rule Notice */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-950 text-xs flex items-start gap-3">
        <ShieldCheck className="w-5 h-5 text-[#159B76] flex-shrink-0 mt-0.5" />
        <div className="space-y-1">
          <p className="font-bold text-sm">Policy &amp; Architecture Guarantee:</p>
          <p className="text-slate-600 leading-relaxed">
            Rewarded ads are used <strong>exclusively</strong> to unlock the <strong>Official Notification / PDF</strong>.
            Browsing job details, reading eligibility, <strong>Apply Online</strong>, and <strong>Official Website</strong> links are always direct, un-gated, and 100% free.
          </p>
        </div>
      </div>

      {/* Master Toggles */}
      <AdminCard
        title="Master Rewarded Ad Switches"
        subtitle="Remotely enable or disable rewarded ad gating without publishing an app update"
      >
        <div className="space-y-4">
          <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
            <input
              type="checkbox"
              checked={settings.rewardedAdsEnabled}
              onChange={(e) => handleUpdate('rewardedAdsEnabled', e.target.checked)}
              className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
            />
            <div>
              <span className="text-sm font-bold text-slate-900 block">
                Enable Rewarded Ads (Master Switch)
              </span>
              <span className="text-xs text-slate-500 block mt-0.5">
                When turned OFF, all official notifications open immediately with zero ads.
              </span>
            </div>
          </label>

          <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
            <input
              type="checkbox"
              checked={settings.rewardNotificationEnabled}
              onChange={(e) =>
                handleUpdate('rewardNotificationEnabled', e.target.checked)
              }
              className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
            />
            <div>
              <span className="text-sm font-bold text-slate-900 block">
                Gate Official Notification / PDF Downloads
              </span>
              <span className="text-xs text-slate-500 block mt-0.5">
                Shows the confirmation bottom sheet asking users to watch a short ad before opening the document.
              </span>
            </div>
          </label>
        </div>
      </AdminCard>

      {/* Unlock Duration & Copy */}
      <AdminCard
        title="Reward Prompt &amp; Unlock Caching"
        subtitle="Customize the message displayed on the confirmation sheet and the local unlock duration"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <AdminInput
              label="Local Unlock Duration (Minutes)"
              type="number"
              min={5}
              max={1440}
              value={settings.rewardUnlockMinutes || 30}
              onChange={(e) =>
                handleUpdate('rewardUnlockMinutes', parseInt(e.target.value) || 30)
              }
              hint="During this period, the user can re-open the same document without watching another ad"
            />

            <AdminInput
              label="Reward Button Text"
              value={settings.rewardButtonText || 'Watch Ad'}
              onChange={(e) => handleUpdate('rewardButtonText', e.target.value)}
              placeholder="Watch Ad"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1.5">
              Reward Prompt Message
            </label>
            <textarea
              rows={2}
              value={settings.rewardPromptText || ''}
              onChange={(e) => handleUpdate('rewardPromptText', e.target.value)}
              placeholder="Watch a short ad to open the official notification."
              className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
            />
          </div>
        </div>
      </AdminCard>

      {/* Environment Separation Reference */}
      <AdminCard
        title="AdMob Ad Unit ID Configuration"
        subtitle="Safe separation between development test units and production release IDs"
      >
        <div className="space-y-4">
          <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-700">
                Official Google Android Rewarded Test Unit (Development)
              </span>
              <span className="text-[10px] font-bold bg-emerald-100 text-emerald-800 px-2 py-0.5 rounded-full">
                Active in Dev
              </span>
            </div>
            <code className="block p-2 rounded-lg bg-slate-900 text-emerald-400 font-mono text-xs">
              ca-app-pub-3940256099942544/5224354917
            </code>
            <p className="text-[11px] text-slate-500">
              This official Google test ad ID is hard-isolated in development so you never accidentally generate invalid clicks.
            </p>
          </div>

          <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
            <span className="text-xs font-bold text-slate-700 block">
              Production Rewarded Ad Unit ID (Supplied Before Play Store Release)
            </span>
            <code className="block p-2 rounded-lg bg-slate-200 text-slate-800 font-mono text-xs">
              REWARDED_NOTIFICATION_AD_UNIT_ID (Placeholder in flutter_app/lib/core/config/admob_config.dart)
            </code>
            <p className="text-[11px] text-slate-500">
              When ready for production release, replace the placeholder with your verified AdMob unit ID.
            </p>
          </div>
        </div>
      </AdminCard>
    </form>
  );
};
