import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth, onAuthStateChanged, User } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

// Client-side Firebase configuration for Notify Jobs (same project as Flutter app: notify-jobs-753b8)
export const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || '',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || 'notify-jobs-753b8.firebaseapp.com',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || 'notify-jobs-753b8',
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || 'notify-jobs-753b8.firebasestorage.app',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '885309400735',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || '',
};

export const isFirebaseConfigured = Boolean(
  import.meta.env.VITE_FIREBASE_API_KEY &&
  import.meta.env.VITE_FIREBASE_API_KEY !== 'PLACEHOLDER_API_KEY' &&
  import.meta.env.VITE_FIREBASE_API_KEY.length > 5
);

// Initialize Firebase App safely for both build-time and runtime
const app = !getApps().length
  ? initializeApp({
      ...firebaseConfig,
      apiKey: firebaseConfig.apiKey || 'dummy-api-key-for-build',
      appId: firebaseConfig.appId || '1:885309400735:web:dummy',
    })
  : getApp();

export const auth = getAuth(app);
export const db = getFirestore(app);

export { onAuthStateChanged };
export type { User };
