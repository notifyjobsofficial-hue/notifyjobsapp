import React, { useState } from 'react';
import {
  Save,
  Check,
  Globe,
  Mail,
  Share2,
  ExternalLink,
  ShieldAlert,
} from 'lucide-react';
import { AppSettings } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';

interface SocialAndSupportPageProps {
  settings: AppSettings;
  onSaveSettings: (settings: Partial<AppSettings>) => Promise<void>;
}

export const SocialAndSupportPage: React.FC<SocialAndSupportPageProps> = ({
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

  const socialChannels = [
    {
      name: 'WhatsApp Channel',
      urlKey: 'whatsappUrl' as keyof AppSettings,
      enabledKey: 'whatsappEnabled' as keyof AppSettings,
      color: '#25D366',
      placeholder: 'https://whatsapp.com/channel/...',
    },
    {
      name: 'Telegram Channel',
      urlKey: 'telegramUrl' as keyof AppSettings,
      enabledKey: 'telegramEnabled' as keyof AppSettings,
      color: '#229ED9',
      placeholder: 'https://t.me/notifyjobs',
    },
    {
      name: 'YouTube Channel',
      urlKey: 'youtubeUrl' as keyof AppSettings,
      enabledKey: 'youtubeEnabled' as keyof AppSettings,
      color: '#FF0000',
      placeholder: 'https://youtube.com/@notifyjobs',
    },
    {
      name: 'Instagram Profile',
      urlKey: 'instagramUrl' as keyof AppSettings,
      enabledKey: 'instagramEnabled' as keyof AppSettings,
      color: '#E4405F',
      placeholder: 'https://instagram.com/notifyjobs',
    },
    {
      name: 'X (Twitter)',
      urlKey: 'xUrl' as keyof AppSettings,
      enabledKey: 'xEnabled' as keyof AppSettings,
      color: '#000000',
      placeholder: 'https://x.com/notifyjobs',
    },
    {
      name: 'Facebook Page',
      urlKey: 'facebookUrl' as keyof AppSettings,
      enabledKey: 'facebookEnabled' as keyof AppSettings,
      color: '#1877F2',
      placeholder: 'https://facebook.com/notifyjobs',
    },
  ];

  return (
    <form onSubmit={handleSave} className="space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900">
            Social Channels &amp; Support Links
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Modify community links, support emails, and legal pages in real-time without releasing an app update
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          {savedSuccess && (
            <span className="text-xs text-emerald-600 font-semibold flex items-center gap-1">
              <Check className="w-3.5 h-3.5" /> Updated Successfully
            </span>
          )}
          <AdminButton
            type="submit"
            variant="primary"
            size="sm"
            icon={<Save className="w-4 h-4" />}
            loading={saving}
          >
            Save Links
          </AdminButton>
        </div>
      </div>

      {/* Social Communities Grid */}
      <AdminCard
        title="Social Media & Communities"
        subtitle="Enable or disable platforms. Disabled channels are automatically hidden in the app."
      >
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {socialChannels.map((channel) => {
            const isEnabled = Boolean(settings[channel.enabledKey]);
            return (
              <div
                key={channel.name}
                className="p-4 rounded-2xl border border-slate-200 bg-slate-50/50 space-y-3"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2.5">
                    <span
                      className="w-3.5 h-3.5 rounded-full"
                      style={{ backgroundColor: channel.color }}
                    />
                    <span className="text-xs font-bold text-slate-900">
                      {channel.name}
                    </span>
                  </div>
                  <label className="flex items-center gap-2 cursor-pointer">
                    <span className="text-[11px] font-semibold text-slate-500">
                      {isEnabled ? 'Enabled' : 'Disabled'}
                    </span>
                    <input
                      type="checkbox"
                      checked={isEnabled}
                      onChange={(e) =>
                        handleUpdate(channel.enabledKey, e.target.checked)
                      }
                      className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
                    />
                  </label>
                </div>

                <AdminInput
                  value={(settings[channel.urlKey] as string) || ''}
                  onChange={(e) => handleUpdate(channel.urlKey, e.target.value)}
                  placeholder={channel.placeholder}
                  disabled={!isEnabled}
                />
              </div>
            );
          })}
        </div>
      </AdminCard>

      {/* Help & Support Settings */}
      <AdminCard
        title="Help & Contact Desk"
        subtitle="Aspirant support channels shown on the More -> Help & Support screen"
      >
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <AdminInput
            label="Support Email"
            type="email"
            value={settings.supportEmail || ''}
            onChange={(e) => handleUpdate('supportEmail', e.target.value)}
            placeholder="support@example.com"
          />
          <AdminInput
            label="Official Support Website"
            type="url"
            value={settings.supportWebsite || ''}
            onChange={(e) => handleUpdate('supportWebsite', e.target.value)}
            placeholder="https://example.com"
          />
        </div>
      </AdminCard>

      {/* Global Share & Web Portal Settings */}
      <AdminCard
        title="Global Share & Web Portal Settings"
        subtitle="Control where shared links point (Web Portal, Play Store, or Smart) and customize the default message"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <AdminInput
              label="Notify Jobs Official Website / Portal URL"
              type="url"
              value={settings.websiteUrl || settings.shareBaseUrl || ''}
              onChange={(e) => {
                handleUpdate('websiteUrl', e.target.value);
                handleUpdate('shareBaseUrl', e.target.value);
              }}
              placeholder="https://notifyjobs.in"
            />
            <AdminInput
              label="Google Play Store App URL"
              type="url"
              value={settings.playStoreUrl || ''}
              onChange={(e) => handleUpdate('playStoreUrl', e.target.value)}
              placeholder="https://play.google.com/store/apps/details?id=com.notifyjobs.app"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2 border-t border-slate-100">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Share Destination Mode
              </label>
              <select
                value={settings.shareTargetMode || 'SMART'}
                onChange={(e) =>
                  handleUpdate('shareTargetMode', e.target.value as any)
                }
                className="w-full px-3 py-2 text-xs border border-slate-200 rounded-xl bg-white text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
              >
                <option value="SMART">
                  SMART (Web Slug if available, else Play Store)
                </option>
                <option value="WEBSITE">
                  WEBSITE (Always link to Web Portal)
                </option>
                <option value="PLAY_STORE">
                  PLAY_STORE (Always link to Google Play Store)
                </option>
              </select>
              <p className="text-[11px] text-slate-500 mt-1">
                SMART generates web links using the slug (never raw IDs).
              </p>
            </div>

            <div className="flex items-center justify-between p-3.5 bg-slate-50 rounded-xl border border-slate-100 self-start">
              <div>
                <span className="text-xs font-bold text-slate-800 block">
                  Enable App-Wide Sharing
                </span>
                <span className="text-[11px] text-slate-500">
                  Show share buttons across job cards, details &amp; updates
                </span>
              </div>
              <input
                type="checkbox"
                checked={settings.shareEnabled !== false}
                onChange={(e) => handleUpdate('shareEnabled', e.target.checked)}
                className="w-4 h-4 rounded text-[#159B76] focus:ring-[#159B76]"
              />
            </div>
          </div>

          <div className="pt-2 border-t border-slate-100">
            <label className="block text-xs font-semibold text-slate-700 mb-1.5">
              Default Share Message Template
            </label>
            <textarea
              rows={4}
              value={
                settings.shareMessageTemplate ??
                '{title}\n\nOrganization: {organization}\nVacancies: {vacancies}\nLast Date: {lastDate}\n\nCheck official details & apply:\n{shareUrl}\n\nGet Notify Jobs for instant job alerts:\n{playStoreUrl}'
              }
              onChange={(e) =>
                handleUpdate('shareMessageTemplate', e.target.value)
              }
              placeholder="{title}\n\nOrganization: {organization}\nVacancies: {vacancies}\nLast Date: {lastDate}\n\nCheck official details & apply:\n{shareUrl}\n\nGet Notify Jobs for instant job alerts:\n{playStoreUrl}"
              className="w-full px-3 py-2 text-xs border border-slate-200 rounded-xl bg-white text-slate-800 font-mono focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
            />
            <p className="text-[11px] text-slate-500 mt-1">
              Available tags: <code className="text-emerald-700 bg-emerald-50 px-1 py-0.5 rounded">&#123;title&#125;</code>, <code className="text-emerald-700 bg-emerald-50 px-1 py-0.5 rounded">&#123;organization&#125;</code>, <code className="text-emerald-700 bg-emerald-50 px-1 py-0.5 rounded">&#123;vacancies&#125;</code>, <code className="text-emerald-700 bg-emerald-50 px-1 py-0.5 rounded">&#123;lastDate&#125;</code>, <code className="text-emerald-700 bg-emerald-50 px-1 py-0.5 rounded">&#123;shareUrl&#125;</code>, <code className="text-emerald-700 bg-emerald-50 px-1 py-0.5 rounded">&#123;playStoreUrl&#125;</code>
            </p>
          </div>
        </div>
      </AdminCard>

      {/* Legal & Policy Pages */}
      <AdminCard
        title="Legal & Compliance Links"
        subtitle="Required for Google Play Store compliance and transparent operation"
      >
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <AdminInput
            label="Privacy Policy URL"
            value={settings.privacyUrl || ''}
            onChange={(e) => handleUpdate('privacyUrl', e.target.value)}
            placeholder="https://example.com/privacy"
          />
          <AdminInput
            label="Terms of Service URL"
            value={settings.termsUrl || ''}
            onChange={(e) => handleUpdate('termsUrl', e.target.value)}
            placeholder="https://example.com/terms"
          />
          <AdminInput
            label="Disclaimer URL"
            value={settings.disclaimerUrl || ''}
            onChange={(e) => handleUpdate('disclaimerUrl', e.target.value)}
            placeholder="https://example.com/disclaimer"
          />
          <AdminInput
            label="Contact Us URL"
            value={settings.contactUrl || ''}
            onChange={(e) => handleUpdate('contactUrl', e.target.value)}
            placeholder="https://example.com/contact"
          />
        </div>
      </AdminCard>
    </form>
  );
};
