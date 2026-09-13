import { collection, doc, getDocs, setDoc, query, orderBy, limit } from 'firebase/firestore';
import { auth, db } from '../firebase/config';
import { NotificationLog } from '../types';

// Cloudflare Worker URL (Can be set via VITE_FCM_WORKER_URL or default to localhost / worker domain)
const WORKER_URL = import.meta.env.VITE_FCM_WORKER_URL || 'https://notify-jobs-fcm-worker.workers.dev';

let memoryLogs: NotificationLog[] = [];

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

  const currentEmail = auth.currentUser?.email || 'Admin';

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
      sentBy: currentEmail,
      status: res.ok ? 'success' : 'failed',
      messageId: data.messageId,
      error: data.error,
    };

    try {
      await setDoc(doc(db, 'notification_logs', logEntry.id), logEntry);
    } catch (e) {
      console.warn('Could not save notification log to Firestore:', e);
    }

    memoryLogs.unshift(logEntry);

    if (!res.ok) {
      return { success: false, error: data.error || `HTTP ${res.status}` };
    }

    return { success: true, messageId: data.messageId };
  } catch (err: any) {
    const logEntry: NotificationLog = {
      id: `log-${Date.now()}`,
      title: params.title,
      body: params.body,
      topic: params.topic,
      contentId: params.contentId,
      imageUrl: params.imageUrl,
      sentAt: new Date().toISOString(),
      sentBy: currentEmail,
      status: 'failed',
      error: err?.message || 'Worker unreachable',
    };

    try {
      await setDoc(doc(db, 'notification_logs', logEntry.id), logEntry);
    } catch (_) {}

    memoryLogs.unshift(logEntry);

    return {
      success: false,
      error: err?.message || 'Notification service temporarily unreachable',
    };
  }
}

export async function fetchNotificationLogs(): Promise<NotificationLog[]> {
  try {
    const q = query(collection(db, 'notification_logs'), orderBy('sentAt', 'desc'), limit(50));
    const snap = await getDocs(q);
    const logs: NotificationLog[] = [];
    snap.forEach((d) => logs.push({ id: d.id, ...d.data() } as NotificationLog));
    memoryLogs = logs;
    return logs;
  } catch (err) {
    console.error('Error loading notification logs from Firestore:', err);
    return memoryLogs;
  }
}
