import {
  collection,
  doc,
  getDoc,
  getDocs,
  setDoc,
  query,
  orderBy,
} from 'firebase/firestore';
import { db, isFirebaseConfigured } from '../firebase/config';
import { AppSettings, HomepageSection } from '../types';

export const defaultAppSettings: AppSettings = {
  appTitle: 'Notify Jobs',
  tagline: 'Government Jobs. Results. Admit Cards. One App.',
  maintenanceMode: false,
  maintenanceMessage: 'We are upgrading our servers to serve you better. We will be back online shortly!',
  minimumAppVersion: '1.0.0',
  latestAppVersion: '1.0.0',
  forceUpdateUrl: 'https://play.google.com/store/apps/details?id=com.notifyjobs.app',

  supportEmail: 'support@notifyjobs.in',
  supportWebsite: 'https://notifyjobs.in',

  whatsappUrl: 'https://whatsapp.com/channel/0029VaNotifyJobs',
  whatsappEnabled: true,
  telegramUrl: 'https://t.me/notifyjobs',
  telegramEnabled: true,
  youtubeUrl: 'https://youtube.com/@notifyjobs',
  youtubeEnabled: true,
  facebookUrl: 'https://facebook.com/notifyjobs',
  facebookEnabled: false,
  instagramUrl: 'https://instagram.com/notifyjobs',
  instagramEnabled: true,
  xUrl: 'https://x.com/notifyjobs',
  xEnabled: true,

  privacyUrl: 'https://notifyjobs.in/privacy',
  termsUrl: 'https://notifyjobs.in/terms',
  disclaimerUrl: 'https://notifyjobs.in/disclaimer',
  contactUrl: 'https://notifyjobs.in/contact',

  rewardedAdsEnabled: true,
  rewardNotificationEnabled: true,
  rewardUnlockMinutes: 30,
  rewardPromptText: 'Watch a short ad to open the official notification.',
  rewardButtonText: 'Watch Ad',

  shareBaseUrl: 'https://notifyjobs.in/job',
  playStoreUrl: 'https://play.google.com/store/apps/details?id=com.notifyjobs.app',
  disclaimer:
    'Notify Jobs is an independent informational platform and is not affiliated with any government department. Users should verify recruitment information from the official source before applying.',
};

let memorySettings = { ...defaultAppSettings };

export async function fetchAppSettings(): Promise<AppSettings> {
  if (!isFirebaseConfigured) {
    return memorySettings;
  }

  try {
    const snap = await getDoc(doc(db, 'app_settings', 'main'));
    if (snap.exists()) {
      return { ...defaultAppSettings, ...snap.data() } as AppSettings;
    }
    return memorySettings;
  } catch (err) {
    console.error('Error reading app_settings:', err);
    return memorySettings;
  }
}

export async function saveAppSettings(settings: Partial<AppSettings>): Promise<void> {
  const merged = { ...memorySettings, ...settings };
  memorySettings = merged;

  if (!isFirebaseConfigured) return;

  try {
    await setDoc(doc(db, 'app_settings', 'main'), merged, { merge: true });
  } catch (err) {
    console.error('Error saving app_settings to Firestore:', err);
  }
}

let memorySections: HomepageSection[] = [
  { id: '1', key: 'latest_alerts', title: 'Latest Alerts', subtitle: 'Important updates & deadlines', contentType: 'government_job', enabled: true, order: 1, limit: 5, sort: 'publishedAt_desc' },
  { id: '2', key: 'quick_categories', title: 'Quick Categories', subtitle: 'Explore popular departments', enabled: true, order: 2, limit: 8, sort: 'order_asc' },
  { id: '3', key: 'popular_this_week', title: 'Popular This Week', subtitle: 'Most viewed opportunities', contentType: 'government_job', enabled: true, order: 3, limit: 5, sort: 'views_desc' },
  { id: '4', key: 'latest_jobs', title: 'Latest Government Jobs', subtitle: 'Newly published vacancies', contentType: 'government_job', categoryId: 'latest-jobs', enabled: true, order: 4, limit: 6, sort: 'publishedAt_desc' },
  { id: '5', key: 'andaman_jobs', title: 'Andaman & Nicobar Jobs', subtitle: 'Islands recruitments', contentType: 'government_job', categoryId: 'andaman-nicobar', enabled: true, order: 5, limit: 6, sort: 'publishedAt_desc' },
  { id: '6', key: 'ssc_jobs', title: 'SSC Jobs', subtitle: 'Staff Selection Commission', contentType: 'government_job', categoryId: 'ssc', enabled: true, order: 6, limit: 4, sort: 'publishedAt_desc' },
  { id: '7', key: 'railway_jobs', title: 'Railway Jobs', subtitle: 'RRB NTPC, Group D & ALP', contentType: 'government_job', categoryId: 'railway', enabled: true, order: 7, limit: 4, sort: 'publishedAt_desc' },
  { id: '8', key: 'banking_jobs', title: 'Banking Jobs', subtitle: 'IBPS, SBI, RBI & PSBs', contentType: 'government_job', categoryId: 'banking', enabled: true, order: 8, limit: 4, sort: 'publishedAt_desc' },
  { id: '9', key: 'police_defence', title: 'Police / Defence', subtitle: 'Armed forces & state police', contentType: 'government_job', categoryId: 'police-defence', enabled: true, order: 9, limit: 4, sort: 'publishedAt_desc' },
  { id: '10', key: 'results', title: 'Results', subtitle: 'Latest declared exam results', contentType: 'result', enabled: true, order: 10, limit: 4, sort: 'publishedAt_desc' },
  { id: '11', key: 'admit_cards', title: 'Admit Cards', subtitle: 'Call letters & exam city slips', contentType: 'admit_card', enabled: true, order: 11, limit: 4, sort: 'publishedAt_desc' },
  { id: '12', key: 'answer_keys', title: 'Answer Keys', subtitle: 'Official keys & objection portals', contentType: 'answer_key', enabled: true, order: 12, limit: 4, sort: 'publishedAt_desc' },
  { id: '13', key: 'syllabus', title: 'Syllabus', subtitle: 'Detailed pattern and marking schemes', contentType: 'syllabus', enabled: true, order: 13, limit: 4, sort: 'publishedAt_desc' },
  { id: '14', key: 'articles', title: 'Latest Articles', subtitle: 'Preparation tips and roadmaps', contentType: 'article', enabled: true, order: 14, limit: 4, sort: 'publishedAt_desc' },
];

export async function fetchHomepageSections(): Promise<HomepageSection[]> {
  if (!isFirebaseConfigured) {
    return memorySections.sort((a, b) => a.order - b.order);
  }

  try {
    const q = query(collection(db, 'homepage_sections'), orderBy('order', 'asc'));
    const snap = await getDocs(q);
    const list: HomepageSection[] = [];
    snap.forEach((d) => list.push({ id: d.id, ...d.data() } as HomepageSection));
    return list.length > 0 ? list : memorySections;
  } catch (err) {
    console.error('Error loading homepage sections:', err);
    return memorySections;
  }
}

export async function saveHomepageSections(sections: HomepageSection[]): Promise<void> {
  memorySections = sections;
  if (!isFirebaseConfigured) return;

  try {
    for (const sec of sections) {
      await setDoc(doc(db, 'homepage_sections', sec.id), sec, { merge: true });
    }
  } catch (err) {
    console.error('Error saving homepage sections to Firestore:', err);
  }
}
