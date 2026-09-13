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
            placeholder="support@notifyjobs.in"
          />
          <AdminInput
            label="Official Support Website"
            type="url"
            value={settings.supportWebsite || ''}
            onChange={(e) => handleUpdate('supportWebsite', e.target.value)}
            placeholder="https://notifyjobs.in"
          />
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
            placeholder="https://notifyjobs.in/privacy"
          />
          <AdminInput
            label="Terms of Service URL"
            value={settings.termsUrl || ''}
            onChange={(e) => handleUpdate('termsUrl', e.target.value)}
            placeholder="https://notifyjobs.in/terms"
          />
          <AdminInput
            label="Disclaimer URL"
            value={settings.disclaimerUrl || ''}
            onChange={(e) => handleUpdate('disclaimerUrl', e.target.value)}
            placeholder="https://notifyjobs.in/disclaimer"
          />
          <AdminInput
            label="Contact Us URL"
            value={settings.contactUrl || ''}
            onChange={(e) => handleUpdate('contactUrl', e.target.value)}
            placeholder="https://notifyjobs.in/contact"
          />
        </div>
      </AdminCard>
    </form>
  );
};
