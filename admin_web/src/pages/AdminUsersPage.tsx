import React, { useState, useEffect } from 'react';
import { Users, Plus, ShieldCheck, UserX, Check, AlertCircle } from 'lucide-react';
import { collection, doc, getDocs, setDoc, updateDoc } from 'firebase/firestore';
import { db } from '../firebase/config';
import { AdminUser } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminButton } from '../components/common/AdminButton';
import { AdminBadge } from '../components/common/AdminBadge';
import { AdminModal } from '../components/common/AdminModal';
import { AdminInput } from '../components/common/AdminInput';
import { AdminSelect } from '../components/common/AdminSelect';

interface AdminUsersPageProps {
  currentUserRole?: 'super_admin' | 'editor';
}

export const AdminUsersPage: React.FC<AdminUsersPageProps> = ({ currentUserRole }) => {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);

  const [modalOpen, setModalOpen] = useState(false);
  const [email, setEmail] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [role, setRole] = useState<'super_admin' | 'editor'>('editor');

  const loadAdminUsers = async () => {
    setLoading(true);
    try {
      const snap = await getDocs(collection(db, 'admins'));
      const list: AdminUser[] = [];
      snap.forEach((d) => {
        list.push({ uid: d.id, ...d.data() } as AdminUser);
      });
      setUsers(list);
    } catch (err) {
      console.error('Error loading admin users from Firestore:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAdminUsers();
  }, []);

  const handleToggleActive = async (uid: string) => {
    const user = users.find((u) => u.uid === uid);
    if (!user) return;
    const newActive = !user.active;

    try {
      await updateDoc(doc(db, 'admins', uid), { active: newActive });
      setUsers((prev) =>
        prev.map((u) => (u.uid === uid ? { ...u, active: newActive } : u))
      );
    } catch (err) {
      console.error('Failed to update admin status:', err);
    }
  };

  const handleAddUser = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;

    const targetUid = `admin-${Date.now()}`;
    const newUser: AdminUser = {
      uid: targetUid,
      email,
      displayName: displayName || email.split('@')[0],
      role,
      active: true,
      createdAt: new Date().toISOString(),
    };

    try {
      await setDoc(doc(db, 'admins', targetUid), newUser, { merge: true });
      setUsers((prev) => [...prev, newUser]);
      setEmail('');
      setDisplayName('');
      setRole('editor');
      setModalOpen(false);
    } catch (err) {
      console.error('Failed to add admin user to Firestore:', err);
    }
  };

  if (currentUserRole !== 'super_admin') {
    return (
      <div className="p-12 text-center bg-white rounded-3xl border border-slate-200">
        <AlertCircle className="w-8 h-8 text-amber-500 mx-auto mb-2" />
        <h3 className="text-base font-bold text-slate-800">Access Restricted</h3>
        <p className="text-xs text-slate-500 mt-1">
          Only Super Administrators can view and manage admin team privileges.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900">Admin Team &amp; Roles</h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Manage authenticated editors and super admin security privileges
          </p>
        </div>
        <AdminButton
          variant="primary"
          size="sm"
          icon={<Plus className="w-4 h-4" />}
          onClick={() => setModalOpen(true)}
        >
          Add Admin User
        </AdminButton>
      </div>

      <AdminCard noPadding>
        {users.length === 0 ? (
          <div className="p-8 text-center text-xs text-slate-400">
            {loading
              ? 'Loading administrators...'
              : 'No team members added yet. Authenticated administrators in the Firestore admins collection will appear here.'}
          </div>
        ) : (
          <div className="divide-y divide-slate-100">
            {users.map((user) => (
              <div
                key={user.uid}
                className="p-4 sm:px-6 flex items-center justify-between gap-4 hover:bg-slate-50/70"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 rounded-2xl bg-slate-900 text-white font-bold flex items-center justify-center text-xs">
                    {(user.displayName || user.email || 'A').charAt(0).toUpperCase()}
                  </div>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-bold text-slate-900 truncate">
                        {user.displayName || user.email}
                      </p>
                      <AdminBadge
                        variant={user.role === 'super_admin' ? 'primary' : 'info'}
                        size="sm"
                      >
                        {user.role === 'super_admin' ? 'Super Admin' : 'Editor'}
                      </AdminBadge>
                      <AdminBadge
                        variant={user.active ? 'success' : 'danger'}
                        size="sm"
                      >
                        {user.active ? 'Active' : 'Deactivated'}
                      </AdminBadge>
                    </div>
                    <p className="text-xs text-slate-400 mt-0.5">{user.email}</p>
                  </div>
                </div>

                <AdminButton
                  variant={user.active ? 'outline' : 'success'}
                  size="sm"
                  onClick={() => handleToggleActive(user.uid)}
                >
                  {user.active ? 'Deactivate' : 'Reactivate'}
                </AdminButton>
              </div>
            ))}
          </div>
        )}
      </AdminCard>

      <AdminModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title="Add Admin Team Member"
        subtitle="Invite an administrator or content editor"
      >
        <form onSubmit={handleAddUser} className="space-y-4">
          <AdminInput
            label="Email Address"
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="editor@example.com"
          />
          <AdminInput
            label="Display Name"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            placeholder="Editor Name"
          />
          <AdminSelect
            label="Role & Permissions"
            value={role}
            onChange={(e) => setRole(e.target.value as any)}
            options={[
              { value: 'editor', label: 'Editor (Content & Categories)' },
              { value: 'super_admin', label: 'Super Admin (Full System Access)' },
            ]}
          />
          <div className="pt-4 flex justify-end gap-2.5">
            <AdminButton
              type="button"
              variant="outline"
              onClick={() => setModalOpen(false)}
            >
              Cancel
            </AdminButton>
            <AdminButton type="submit" variant="primary">
              Create Admin
            </AdminButton>
          </div>
        </form>
      </AdminModal>
    </div>
  );
};
