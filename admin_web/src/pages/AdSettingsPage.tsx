import React, { useState } from 'react';
import { Save, Check, ShieldCheck, HelpCircle, ToggleLeft, ToggleRight } from 'lucide-react';
import { AppSettings, AdSlotItem, AdSlotsConfig } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';

interface AdSettingsPageProps {
  settings: AppSettings;
  onSaveSettings: (settings: Partial<AppSettings>) => Promise<void>;
}

const defaultAdSlots: AdSlotsConfig = {
  officialNotificationRewarded: {
    id: 'official_notification_rewarded',
    name: 'Official Notification PDF',
    format: 'rewarded',
    adUnitId: 'ca-app-pub-3940256099942544/5224354917',
    enabled: true,
    freeUserOnly: true,
  },
  downloadAdmitCardRewarded: {
    id: 'download_admit_card_rewarded',
    name: 'Download Admit Card',
    format: 'rewarded',
    adUnitId: '',
    enabled: false,
    freeUserOnly: true,
  },
  viewResultRewarded: {
    id: 'view_result_rewarded',
    name: 'View Result / Merit List',
    format: 'rewarded',
    adUnitId: '',
    enabled: false,
    freeUserOnly: true,
  },
  viewAnswerKeyRewarded: {
    id: 'view_answer_key_rewarded',
    name: 'View Answer Key & Objections',
    format: 'rewarded',
    adUnitId: '',
    enabled: false,
    freeUserOnly: true,
  },
  viewSyllabusRewarded: {
    id: 'view_syllabus_rewarded',
    name: 'View Official Syllabus PDF',
    format: 'rewarded',
    adUnitId: '',
    enabled: false,
    freeUserOnly: true,
  },
};

export const AdSettingsPage: React.FC<AdSettingsPageProps> = ({
  settings: initialSettings,
  onSaveSettings,
}) => {
  const [settings, setSettings] = useState<AppSettings>({
    ...initialSettings,
    adSlots: initialSettings.adSlots || defaultAdSlots,
  });
  const [saving, setSaving] = useState(false);
  const [savedSuccess, setSavedSuccess] = useState(false);

  const adSlots = settings.adSlots || defaultAdSlots;

  const handleUpdate = (field: keyof AppSettings, value: any) => {
    setSettings((prev) => ({ ...prev, [field]: value }));
  };

  const handleSlotUpdate = (slotKey: keyof AdSlotsConfig, field: keyof AdSlotItem, value: any) => {
    setSettings((prev) => {
      const currentSlots = prev.adSlots || defaultAdSlots;
      const currentSlot = currentSlots[slotKey] || defaultAdSlots[slotKey];
      return {
        ...prev,
        adSlots: {
          ...currentSlots,
          [slotKey]: {
            ...currentSlot,
            [field]: value,
          },
        },
      };
    });
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

  const slotEntries: Array<{ key: keyof AdSlotsConfig; slot: AdSlotItem }> = [
    {
      key: 'officialNotificationRewarded',
      slot: adSlots.officialNotificationRewarded || defaultAdSlots.officialNotificationRewarded,
    },
    {
      key: 'downloadAdmitCardRewarded',
      slot: adSlots.downloadAdmitCardRewarded || defaultAdSlots.downloadAdmitCardRewarded!,
    },
    {
      key: 'viewResultRewarded',
      slot: adSlots.viewResultRewarded || defaultAdSlots.viewResultRewarded!,
    },
    {
      key: 'viewAnswerKeyRewarded',
      slot: adSlots.viewAnswerKeyRewarded || defaultAdSlots.viewAnswerKeyRewarded!,
    },
    {
      key: 'viewSyllabusRewarded',
      slot: adSlots.viewSyllabusRewarded || defaultAdSlots.viewSyllabusRewarded!,
    },
  ];

  return (
    <form onSubmit={handleSave} className="space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900">
            Monetization &amp; Ad Management
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Manage supported predefined Rewarded Ad slots, AdMob Unit IDs, and free-user gating
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          {savedSuccess && (
            <span className="text-xs text-emerald-600 font-semibold flex items-center gap-1">
              <Check className="w-3.5 h-3.5" /> Placements Saved
            </span>
          )}
          <AdminButton
            type="submit"
            variant="primary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
          >
            Save Ad Placements
          </AdminButton>
        </div>
      </div>

      {/* Critical Policy Guarantees */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-950 text-xs flex items-start gap-3">
        <ShieldCheck className="w-5 h-5 text-[#159B76] flex-shrink-0 mt-0.5" />
        <div className="space-y-1">
          <p className="font-bold text-sm">Monetization Safety Rules:</p>
          <ul className="list-disc list-inside text-slate-600 space-y-0.5">
            <li><strong>Apply Online</strong> is 100% direct and NEVER gated behind ads.</li>
            <li><strong>Ad-Free Support</strong> contributors bypass all ads automatically.</li>
            <li><strong>Rewarded Ads only</strong>: No annoying banners, interstitials, or app-open popups.</li>
            <li>Only predefined safe slots are supported to prevent broken app layouts.</li>
          </ul>
        </div>
      </div>

      {/* Predefined Ad Slots Management Table */}
      <AdminCard
        title="Predefined Rewarded Ad Slots"
        subtitle="Paste your verified AdMob Rewarded Ad Unit ID for each slot. Enable or disable anytime without rebuilding the app."
      >
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider">
                <th className="py-3 px-3">Placement Slot</th>
                <th className="py-3 px-3">Format</th>
                <th className="py-3 px-3">AdMob Rewarded Ad Unit ID</th>
                <th className="py-3 px-3 text-center">Audience</th>
                <th className="py-3 px-3 text-center">Slot Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 text-sm">
              {slotEntries.map(({ key, slot }) => (
                <tr key={key} className="hover:bg-slate-50/70 transition-colors">
                  <td className="py-3.5 px-3">
                    <span className="font-semibold text-slate-900 block">{slot.name}</span>
                    <span className="text-[11px] text-slate-400 font-mono">{slot.id}</span>
                  </td>
                  <td className="py-3.5 px-3">
                    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200">
                      Rewarded
                    </span>
                  </td>
                  <td className="py-3.5 px-3 min-w-[280px]">
                    <input
                      type="text"
                      placeholder="e.g. ca-app-pub-2250115842376248/4291317920"
                      value={slot.adUnitId || ''}
                      onChange={(e) => handleSlotUpdate(key, 'adUnitId', e.target.value)}
                      className="w-full text-xs font-mono px-3 py-2 rounded-lg border border-slate-200 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                    />
                  </td>
                  <td className="py-3.5 px-3 text-center">
                    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-emerald-50 text-emerald-800 border border-emerald-200">
                      Free Users Only
                    </span>
                  </td>
                  <td className="py-3.5 px-3 text-center">
                    <button
                      type="button"
                      onClick={() => handleSlotUpdate(key, 'enabled', !slot.enabled)}
                      className={`p-1 rounded-lg transition-colors ${
                        slot.enabled
                          ? 'text-emerald-600 bg-emerald-50 hover:bg-emerald-100'
                          : 'text-slate-400 bg-slate-100 hover:bg-slate-200'
                      }`}
                      title={slot.enabled ? 'Click to disable' : 'Click to enable'}
                    >
                      {slot.enabled ? (
                        <ToggleRight className="w-6 h-6" />
                      ) : (
                        <ToggleLeft className="w-6 h-6" />
                      )}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </AdminCard>

      {/* Global Ad Controls & Environment (Part 13) */}
      <AdminCard
        title="Global AdMob &amp; Cooldown Controls"
        subtitle="Manage master switches, test mode, AdMob units, and cooldown bypass"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
              <input
                type="checkbox"
                checked={settings.adsEnabled ?? true}
                onChange={(e) => handleUpdate('adsEnabled', e.target.checked)}
                className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
              />
              <div>
                <span className="text-sm font-bold text-slate-900 block">
                  Enable All Ads (Master Switch)
                </span>
                <span className="text-xs text-slate-500 block mt-0.5">
                  When toggled OFF, all ads are completely disabled across the entire app.
                </span>
              </div>
            </label>

            <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
              <input
                type="checkbox"
                checked={settings.rewardedAdsEnabled}
                onChange={(e) => handleUpdate('rewardedAdsEnabled', e.target.checked)}
                className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
              />
              <div>
                <span className="text-sm font-bold text-slate-900 block">
                  Enable Rewarded Ads
                </span>
                <span className="text-xs text-slate-500 block mt-0.5">
                  Master switch for all rewarded ad sheets and prompts.
                </span>
              </div>
            </label>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-amber-200 bg-amber-50/40 cursor-pointer">
              <input
                type="checkbox"
                checked={settings.testMode ?? false}
                onChange={(e) => handleUpdate('testMode', e.target.checked)}
                className="w-5 h-5 rounded text-amber-600 focus:ring-amber-500 mt-0.5"
              />
              <div>
                <span className="text-sm font-bold text-slate-900 block">
                  AdMob Test Mode
                </span>
                <span className="text-xs text-slate-500 block mt-0.5">
                  Forces Google sample test ad units to prevent production account policy strikes during QA.
                </span>
              </div>
            </label>

            <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
              <input
                type="checkbox"
                checked={settings.allowSkipRewarded ?? true}
                onChange={(e) => handleUpdate('allowSkipRewarded', e.target.checked)}
                className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
              />
              <div>
                <span className="text-sm font-bold text-slate-900 block">
                  Allow Continue Without Ad
                </span>
                <span className="text-xs text-slate-500 block mt-0.5">
                  Guarantees applicants can bypass ads for essential government recruitment links.
                </span>
              </div>
            </label>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
            <AdminInput
              label="Android Rewarded Ad Unit ID"
              value={settings.rewardedAdUnitAndroid || ''}
              onChange={(e) => handleUpdate('rewardedAdUnitAndroid', e.target.value)}
              placeholder="ca-app-pub-3940256099942544/5224354917"
              hint="Production AdMob unit ID. If blank or in test mode, Google test ID is used automatically."
            />

            <AdminInput
              label="Rewarded Cooldown Period (Minutes)"
              type="number"
              min={1}
              max={120}
              value={settings.rewardedCooldownMinutes ?? 10}
              onChange={(e) =>
                handleUpdate('rewardedCooldownMinutes', parseInt(e.target.value) || 10)
              }
              hint="After watching an ad, user will not be prompted again for this many minutes (Default: 10 mins)."
            />
          </div>
        </div>
      </AdminCard>

      {/* Per-Action Rewarded Prompts (Part 9 & 13) */}
      <AdminCard
        title="Per-Action Rewarded Prompt Configuration"
        subtitle="Individually control which official source actions trigger the optional rewarded sheet"
      >
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
            <input
              type="checkbox"
              checked={settings.supportRewardedEnabled ?? true}
              onChange={(e) => handleUpdate('supportRewardedEnabled', e.target.checked)}
              className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
            />
            <div>
              <span className="text-sm font-bold text-slate-900 block">
                Support Us Screen Ad
              </span>
              <span className="text-xs text-slate-500 block mt-0.5">
                Allows users to watch a short sponsored ad to support Notify Jobs from More screen.
              </span>
            </div>
          </label>

          <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
            <input
              type="checkbox"
              checked={settings.applyRewardedEnabled ?? true}
              onChange={(e) => handleUpdate('applyRewardedEnabled', e.target.checked)}
              className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
            />
            <div>
              <span className="text-sm font-bold text-slate-900 block">
                Apply Online Prompt
              </span>
              <span className="text-xs text-slate-500 block mt-0.5">
                Displays the optional &quot;Continue to Official Source&quot; sheet when tapping Apply.
              </span>
            </div>
          </label>

          <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
            <input
              type="checkbox"
              checked={settings.notificationDownloadRewardedEnabled ?? true}
              onChange={(e) => handleUpdate('notificationDownloadRewardedEnabled', e.target.checked)}
              className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
            />
            <div>
              <span className="text-sm font-bold text-slate-900 block">
                Official PDF Download Prompt
              </span>
              <span className="text-xs text-slate-500 block mt-0.5">
                Displays the optional prompt when downloading official notification PDFs.
              </span>
            </div>
          </label>

          <label className="flex items-start gap-3.5 p-4 rounded-2xl border border-slate-200 bg-slate-50/50 cursor-pointer">
            <input
              type="checkbox"
              checked={settings.officialWebsiteRewardedEnabled ?? true}
              onChange={(e) => handleUpdate('officialWebsiteRewardedEnabled', e.target.checked)}
              className="w-5 h-5 rounded text-[#159B76] focus:ring-[#159B76] mt-0.5"
            />
            <div>
              <span className="text-sm font-bold text-slate-900 block">
                Official Website Visit Prompt
              </span>
              <span className="text-xs text-slate-500 block mt-0.5">
                Displays the optional prompt when opening official board websites.
              </span>
            </div>
          </label>
        </div>
      </AdminCard>
    </form>
  );
};

