import React, { useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db, isFirebaseConfigured } from '../firebase/config';
import { AdminInput } from '../components/common/AdminInput';
import { AdminButton } from '../components/common/AdminButton';
import { ShieldCheck, Lock, Mail, AlertCircle } from 'lucide-react';

interface LoginPageProps {
  onLoginSuccess: (user: { email: string; role: 'super_admin' | 'editor'; uid: string }) => void;
}

export const LoginPage: React.FC<LoginPageProps> = ({ onLoginSuccess }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    if (!isFirebaseConfigured) {
      setError(
        'Firebase configuration is required. Please enter your Firebase environment variables in Cloudflare Pages.'
      );
      setLoading(false);
      return;
    }

    try {
      const userCredential = await signInWithEmailAndPassword(auth, email.trim(), password);
      const user = userCredential.user;

      // Verify active admin record in Firestore admins/{uid}
      const adminDocRef = doc(db, 'admins', user.uid);
      const adminDocSnap = await getDoc(adminDocRef);

      if (adminDocSnap.exists()) {
        const adminData = adminDocSnap.data();
        if (adminData?.active !== true) {
          await auth.signOut();
          setError('Your administrator account has been deactivated. Please contact the project owner.');
          setLoading(false);
          return;
        }

        onLoginSuccess({
          email: user.email || email.trim(),
          role: adminData.role || 'super_admin',
          uid: user.uid,
        });
      } else {
        // Authenticated in Firebase Auth, but not provisioned in /admins/{uid}
        await auth.signOut();
        setError(
          'Your account is authenticated, but is not authorized as an administrator for Notify Jobs. If you are setting up the project, please run the super-admin bootstrap script.'
        );
        setLoading(false);
        return;
      }
    } catch (err: any) {
      console.error('Login error:', err);
      const code = err?.code || '';

      if (
        code === 'auth/invalid-credential' ||
        code === 'auth/wrong-password' ||
        code === 'auth/user-not-found' ||
        code === 'auth/invalid-email'
      ) {
        setError('Invalid email or password. Please check your credentials and try again.');
      } else if (code === 'auth/user-disabled') {
        setError('This account has been disabled. Please contact the administrator.');
      } else if (code === 'auth/too-many-requests') {
        setError('Too many unsuccessful login attempts. Please wait a few moments and try again.');
      } else if (code === 'auth/network-request-failed') {
        setError('Network connection error. Please check your internet connection and try again.');
      } else if (code === 'permission-denied' || String(err?.message || '').toLowerCase().includes('permission')) {
        setError('Access denied: This account lacks administrator authorization in Firestore.');
      } else {
        setError('Login failed. Please check your credentials or contact the administrator.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="flex justify-center">
          <div className="w-14 h-14 rounded-2xl bg-[#159B76] flex items-center justify-center text-white text-xl font-extrabold shadow-lg shadow-[#159B76]/30">
            NJ
          </div>
        </div>
        <h2 className="mt-4 text-center text-2xl font-extrabold text-slate-900 tracking-tight">
          Notify Jobs Admin Portal
        </h2>
        <p className="mt-1.5 text-center text-xs text-slate-500">
          Sign in to manage government jobs, admit cards, results, and push alerts.
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-6 shadow-xl shadow-slate-200/50 rounded-3xl border border-slate-200/80 sm:px-10">
          <form className="space-y-4" onSubmit={handleLogin}>
            {error && (
              <div className="p-3.5 rounded-xl bg-red-50 border border-red-200 text-red-700 text-xs flex items-start gap-2.5">
                <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5 text-red-500" />
                <span>{error}</span>
              </div>
            )}

            <AdminInput
              label="Admin Email"
              type="email"
              required
              placeholder="admin@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              icon={<Mail className="w-4 h-4" />}
            />

            <AdminInput
              label="Password"
              type="password"
              required
              placeholder="••••••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              icon={<Lock className="w-4 h-4" />}
            />

            <div className="pt-2">
              <AdminButton
                type="submit"
                variant="primary"
                size="lg"
                className="w-full"
                loading={loading}
              >
                Sign In to Dashboard
              </AdminButton>
            </div>
          </form>

          <div className="mt-6 pt-6 border-t border-slate-100 flex items-center justify-center gap-1.5 text-slate-400 text-xs">
            <ShieldCheck className="w-4 h-4 text-[#159B76]" />
            <span>Protected with Firebase Authentication &amp; Firestore Security Rules</span>
          </div>
        </div>
      </div>
    </div>
  );
};
