import React, { useState } from 'react';
import { Users, Plus, ShieldCheck, UserX, Check, AlertCircle } from 'lucide-react';
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
  const [users, setUsers] = useState<AdminUser[]>([
    {
      uid: 'admin-1',
      email: 'admin@notifyjobs.in',
      displayName: 'Lead Architect',
      role: 'super_admin',
      active: true,
      createdAt: '2026-09-01T00:00:00.000Z',
      lastLoginAt: '2026-09-12T18:30:00.000Z',
    },
    {
      uid: 'editor-1',
      email: 'editor@notifyjobs.in',
      displayName: 'Content Editor',
      role: 'editor',
      active: true,
      createdAt: '2026-09-05T00:00:00.000Z',
      lastLoginAt: '2026-09-11T14:10:00.000Z',
    },
  ]);

  const [modalOpen, setModalOpen] = useState(false);
  const [email, setEmail] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [role, setRole] = useState<'super_admin' | 'editor'>('editor');

  const handleToggleActive = (uid: string) => {
    setUsers((prev) =>
      prev.map((u) => (u.uid === uid ? { ...u, active: !u.active } : u))
    );
  };

  const handleAddUser = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;

    const newUser: AdminUser = {
      uid: `admin-${Date.now()}`,
      email,
      displayName: displayName || email.split('@')[0],
      role,
      active: true,
      createdAt: new Date().toISOString(),
    };

    setUsers((prev) => [...prev, newUser]);
    setEmail('');
    setDisplayName('');
    setRole('editor');
    setModalOpen(false);
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
        <div className="divide-y divide-slate-100">
          {users.map((user) => (
            <div
              key={user.uid}
              className="p-4 sm:px-6 flex items-center justify-between gap-4 hover:bg-slate-50/70"
            >
              <div className="flex items-center gap-3 min-w-0">
                <div className="w-10 h-10 rounded-2xl bg-slate-900 text-white font-bold flex items-center justify-center text-xs">
                  {user.displayName.charAt(0)}
                </div>
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-bold text-slate-900 truncate">
                      {user.displayName}
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
            placeholder="editor@notifyjobs.in"
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
