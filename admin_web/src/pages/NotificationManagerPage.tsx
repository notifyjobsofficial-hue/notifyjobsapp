import React, { useState } from 'react';
import {
  Bell,
  Send,
  Eye,
  CheckCircle2,
  Clock,
  Smartphone,
  AlertCircle,
  ExternalLink,
} from 'lucide-react';
import { ContentItem, NotificationLog } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';
import { AdminBadge } from '../components/common/AdminBadge';
import { sendPushNotification } from '../services/workerService';

interface NotificationManagerPageProps {
  items: ContentItem[];
  logs: NotificationLog[];
  onRefreshLogs: () => void;
}

export const NotificationManagerPage: React.FC<NotificationManagerPageProps> = ({
  items,
  logs,
  onRefreshLogs,
}) => {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [topic, setTopic] = useState('all_updates');
  const [selectedContentId, setSelectedContentId] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const [resultMessage, setResultMessage] = useState<{
    type: 'success' | 'error';
    text: string;
  } | null>(null);

  const publishedJobs = items.filter((i) => i.isPublished);

  const handleSelectContent = (contentId: string) => {
    setSelectedContentId(contentId);
    if (!contentId) return;

    const item = items.find((i) => i.id === contentId);
    if (item) {
      setTitle(item.title);
      setBody(
        item.excerpt ||
          `${item.organization}: ${item.vacancies ? `${item.vacancies} vacancies.` : ''} Last date: ${item.applicationLastDate || 'Check details'}`
      );
    }
  };

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !body) return;

    setLoading(true);
    setResultMessage(null);

    try {
      const res = await sendPushNotification({
        title,
        body,
        topic,
        contentId: selectedContentId || undefined,
        imageUrl: imageUrl || undefined,
      });

      if (res.success) {
        setResultMessage({
          type: 'success',
          text: `Notification successfully dispatched! Message ID: ${res.messageId}`,
        });
        setTitle('');
        setBody('');
        setSelectedContentId('');
        setImageUrl('');
        onRefreshLogs();
      } else {
        setResultMessage({
          type: 'error',
          text: `Failed to dispatch notification: ${res.error}`,
        });
      }
    } catch (err: any) {
      setResultMessage({
        type: 'error',
        text: err?.message || 'Error communicating with Cloudflare Worker',
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-xl font-bold text-slate-900">Push Notifications Hub</h2>
        <p className="text-xs text-slate-500 mt-0.5">
          Dispatch instant breaking alerts to Android app subscribers via Cloudflare Worker FCM
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Left 7 Columns: Compose Form */}
        <div className="lg:col-span-7 space-y-6">
          <AdminCard
            title="Compose New Notification"
            subtitle="Alerts are sent to opted-in subscribers of the selected topic"
          >
            <form onSubmit={handleSend} className="space-y-4">
              {resultMessage && (
                <div
                  className={`p-3.5 rounded-xl border text-xs flex items-start gap-2.5 ${
                    resultMessage.type === 'success'
                      ? 'bg-emerald-50 border-emerald-200 text-emerald-800'
                      : 'bg-red-50 border-red-200 text-red-800'
                  }`}
                >
                  {resultMessage.type === 'success' ? (
                    <CheckCircle2 className="w-4 h-4 text-emerald-600 flex-shrink-0 mt-0.5" />
                  ) : (
                    <AlertCircle className="w-4 h-4 text-red-600 flex-shrink-0 mt-0.5" />
                  )}
                  <span>{resultMessage.text}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  Link with Published Job / Result (Optional Deep Link)
                </label>
                <select
                  value={selectedContentId}
                  onChange={(e) => handleSelectContent(e.target.value)}
                  className="w-full text-xs rounded-xl border border-slate-200 p-2.5 bg-white text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                >
                  <option value="">-- Manual Notification (No Direct Link) --</option>
                  {publishedJobs.map((item) => (
                    <option key={item.id} value={item.id}>
                      [{item.contentType}] {item.title}
                    </option>
                  ))}
                </select>
                <p className="text-[11px] text-slate-400 mt-1">
                  When tapped, the app automatically navigates straight to this item
                </p>
              </div>

              <AdminSelect
                label="Target Subscriber Topic"
                value={topic}
                onChange={(e) => setTopic(e.target.value)}
                options={[
                  { value: 'all_updates', label: 'all_updates (Entire App Audience)' },
                  { value: 'jobs', label: 'jobs (All Government Job Seekers)' },
                  { value: 'andaman', label: 'andaman (Andaman & Nicobar Islands)' },
                  { value: 'ssc', label: 'ssc (Staff Selection Commission)' },
                  { value: 'railway', label: 'railway (RRB Aspirants)' },
                  { value: 'banking', label: 'banking (IBPS, SBI & PSBs)' },
                  { value: 'police', label: 'police (Police & Defence)' },
                  { value: 'results', label: 'results (Results & Merit Lists)' },
                  { value: 'admit_cards', label: 'admit_cards (Admit Cards / Call Letters)' },
                  { value: 'answer_keys', label: 'answer_keys (Answer Keys)' },
                ]}
              />

              <AdminInput
                label="Notification Title"
                required
                maxLength={60}
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. SSC CGL 2026 Notification Out!"
              />

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  Message Body
                </label>
                <textarea
                  rows={3}
                  required
                  maxLength={160}
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  placeholder="e.g. 8,200 Group B & C Vacancies announced. Last date to apply is 30 Sep. Tap to view eligibility."
                  className="w-full text-xs rounded-xl border border-slate-200 p-3 text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#159B76]/20"
                />
                <span className="text-[10px] text-slate-400 block text-right">
                  {body.length}/160 chars
                </span>
              </div>

              <AdminInput
                label="Image URL (Optional Banner HTTPS link)"
                value={imageUrl}
                onChange={(e) => setImageUrl(e.target.value)}
                placeholder="https://..."
              />

              <div className="pt-2 flex items-center justify-end">
                <AdminButton
                  type="submit"
                  variant="primary"
                  size="md"
                  loading={loading}
                  icon={<Send className="w-4 h-4" />}
                >
                  Send Push Notification
                </AdminButton>
              </div>
            </form>
          </AdminCard>
        </div>

        {/* Right 5 Columns: Android Push Preview & History */}
        <div className="lg:col-span-5 space-y-6">
          <AdminCard
            title="Android Lockscreen Preview"
            subtitle="Realistic notification banner simulation"
          >
            <div className="bg-slate-900 rounded-3xl p-5 shadow-inner text-white space-y-4">
              <div className="flex items-center justify-between text-[11px] text-slate-400 px-1">
                <span>Notify Jobs • Just now</span>
                <Bell className="w-3.5 h-3.5 text-[#159B76]" />
              </div>

              {/* Notification Banner */}
              <div className="bg-slate-800/90 rounded-2xl p-4 border border-slate-700/80 shadow-lg space-y-2">
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-xl bg-[#159B76] flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                    NJ
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="text-xs font-bold text-white leading-snug">
                      {title || 'Notification Headline'}
                    </p>
                    <p className="text-[11px] text-slate-300 mt-1 leading-relaxed line-clamp-3">
                      {body || 'The alert description will be displayed here for user preview.'}
                    </p>
                  </div>
                </div>

                {imageUrl && (
                  <div className="mt-2 rounded-xl overflow-hidden max-h-32 bg-slate-900">
                    <img
                      src={imageUrl}
                      alt="Banner"
                      className="w-full h-full object-cover"
                      onError={(e) => (e.currentTarget.style.display = 'none')}
                    />
                  </div>
                )}
              </div>
            </div>
          </AdminCard>

          {/* Delivery History */}
          <AdminCard
            title="Delivery History"
            subtitle="Previous broadcasts dispatched via Worker"
            noPadding
          >
            <div className="divide-y divide-slate-100 max-h-80 overflow-y-auto">
              {logs.length === 0 ? (
                <div className="p-6 text-center text-xs text-slate-400">
                  No notifications recorded yet.
                </div>
              ) : (
                logs.map((log) => (
                  <div key={log.id} className="p-4 space-y-1 hover:bg-slate-50/60">
                    <div className="flex items-center justify-between gap-2">
                      <p className="text-xs font-bold text-slate-900 truncate">
                        {log.title}
                      </p>
                      <AdminBadge variant={log.status === 'success' ? 'success' : 'danger'} size="sm">
                        {log.status}
                      </AdminBadge>
                    </div>
                    <p className="text-xs text-slate-600 line-clamp-1">{log.body}</p>
                    <div className="flex items-center justify-between pt-1 text-[10px] text-slate-400">
                      <span>Topic: {log.topic}</span>
                      <span>{new Date(log.sentAt).toLocaleDateString()}</span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </AdminCard>
        </div>
      </div>
    </div>
  );
};
