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
      // Local preview / initial demo login
      setTimeout(() => {
        setLoading(false);
        if (email && password) {
          onLoginSuccess({
            email,
            role: email.includes('editor') ? 'editor' : 'super_admin',
            uid: 'demo-admin-uid-1',
          });
        } else {
          setError('Please enter both email and password.');
        }
      }, 600);
      return;
    }

    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Verify active admin record in Firestore admins/{uid}
      const adminDocSnap = await getDoc(doc(db, 'admins', user.uid));
      if (!adminDocSnap.exists()) {
        setError('Access denied. No admin account registered for this email.');
        setLoading(false);
        return;
      }

      const adminData = adminDocSnap.data();
      if (adminData.active !== true) {
        setError('Your admin account has been deactivated. Please contact the administrator.');
        setLoading(false);
        return;
      }

      onLoginSuccess({
        email: user.email || email,
        role: adminData.role || 'editor',
        uid: user.uid,
      });
    } catch (err: any) {
      console.error('Login error:', err);
      setError(
        err.code === 'auth/invalid-credential' || err.code === 'auth/wrong-password'
          ? 'Invalid email or password.'
          : err.message || 'Login failed. Please check credentials.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handleQuickDemo = (role: 'super_admin' | 'editor') => {
    onLoginSuccess({
      email: role === 'super_admin' ? 'admin@notifyjobs.in' : 'editor@notifyjobs.in',
      role,
      uid: role === 'super_admin' ? 'demo-super-admin' : 'demo-editor',
    });
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
              placeholder="admin@notifyjobs.in"
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

          {/* Quick Demo Access (Active if Firebase keys not configured or for quick testing) */}
          <div className="mt-6 pt-6 border-t border-slate-100">
            <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider text-center mb-3">
              One-Click Instant Access
            </p>
            <div className="grid grid-cols-2 gap-2">
              <AdminButton
                type="button"
                variant="outline"
                size="sm"
                onClick={() => handleQuickDemo('super_admin')}
              >
                Super Admin
              </AdminButton>
              <AdminButton
                type="button"
                variant="outline"
                size="sm"
                onClick={() => handleQuickDemo('editor')}
              >
                Editor
              </AdminButton>
            </div>
            <p className="text-[11px] text-center text-slate-400 mt-3">
              Production credentials authenticate against Firebase Auth &amp; Firestore{' '}
              <code className="bg-slate-100 px-1 py-0.5 rounded text-[10px]">admins/{'{uid}'}</code>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
