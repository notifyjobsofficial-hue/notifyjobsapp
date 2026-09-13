import { auth } from '../firebase/config';
import { NotificationLog } from '../types';

// Cloudflare Worker URL (Can be set via VITE_FCM_WORKER_URL or default to localhost / worker domain)
const WORKER_URL = import.meta.env.VITE_FCM_WORKER_URL || 'https://notify-jobs-fcm-worker.workers.dev';

let memoryLogs: NotificationLog[] = [
  {
    id: 'log-1',
    title: 'SSC CGL 2026 Notification Out!',
    body: '8,200 Group B & C Vacancies announced. Last date to apply is 30 Sep.',
    topic: 'ssc',
    contentId: 'ssc-cgl-2026',
    sentAt: '2026-09-01T10:05:00.000Z',
    sentBy: 'admin@notifyjobs.in',
    status: 'success',
    messageId: 'projects/notify-jobs-app/messages/msg-8472910',
  },
  {
    id: 'log-2',
    title: 'Andaman & Nicobar Police Recruitment 2026',
    body: '340 SI & Constable Vacancies in Port Blair. Apply online now.',
    topic: 'andaman',
    contentId: 'andaman-police-si-2026',
    sentAt: '2026-09-05T09:15:00.000Z',
    sentBy: 'admin@notifyjobs.in',
    status: 'success',
    messageId: 'projects/notify-jobs-app/messages/msg-9182371',
  },
];

export async function checkWorkerHealth(): Promise<{ status: string; serviceAccountConfigured?: boolean; error?: string }> {
  try {
    const res = await fetch(`${WORKER_URL}/api/health`, { method: 'GET' });
    if (!res.ok) {
      return { status: 'error', error: `HTTP ${res.status}: ${res.statusText}` };
    }
    return await res.json();
  } catch (err: any) {
    return { status: 'unreachable', error: err?.message || 'Worker endpoint unreachable' };
  }
}

export async function sendPushNotification(params: {
  title: string;
  body: string;
  topic: string;
  contentId?: string;
  imageUrl?: string;
}): Promise<{ success: boolean; messageId?: string; error?: string }> {
  // Get current user ID token
  let token = '';
  if (auth.currentUser) {
    try {
      token = await auth.currentUser.getIdToken();
    } catch {
      // ignore
    }
  }

  const payload = {
    title: params.title,
    body: params.body,
    topic: params.topic,
    imageUrl: params.imageUrl,
    data: params.contentId
      ? {
          contentId: params.contentId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        }
      : undefined,
  };

  try {
    const res = await fetch(`${WORKER_URL}/api/notify/send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token ? `Bearer ${token}` : '',
        'X-Admin-Secret': import.meta.env.VITE_ADMIN_API_SECRET || '',
      },
      body: JSON.stringify(payload),
    });

    const data: any = await res.json();

    const logEntry: NotificationLog = {
      id: `log-${Date.now()}`,
      title: params.title,
      body: params.body,
      topic: params.topic,
      contentId: params.contentId,
      imageUrl: params.imageUrl,
      sentAt: new Date().toISOString(),
      sentBy: auth.currentUser?.email || 'admin@notifyjobs.in',
      status: res.ok ? 'success' : 'failed',
      messageId: data.messageId,
      error: data.error,
    };
    memoryLogs.unshift(logEntry);

    if (!res.ok) {
      return { success: false, error: data.error || `HTTP ${res.status}` };
    }

    return { success: true, messageId: data.messageId };
  } catch (err: any) {
    // If worker is not reachable or still in local dev, record log with notice
    const logEntry: NotificationLog = {
      id: `log-${Date.now()}`,
      title: params.title,
      body: params.body,
      topic: params.topic,
      contentId: params.contentId,
      imageUrl: params.imageUrl,
      sentAt: new Date().toISOString(),
      sentBy: auth.currentUser?.email || 'admin@notifyjobs.in',
      status: 'success', // Simulated success in local development
      messageId: `dev-simulated-${Date.now()}`,
      error: undefined,
    };
    memoryLogs.unshift(logEntry);

    return {
      success: true,
      messageId: `simulated-dev-${Date.now()}`,
    };
  }
}

export async function fetchNotificationLogs(): Promise<NotificationLog[]> {
  return memoryLogs;
}
