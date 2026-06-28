import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { authAPI } from '@/services/api';
import { useToast } from '@/components/Toast';
import { User, Lock, Save } from 'lucide-react';

export default function Profile() {
  const { showToast } = useToast();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [changingPassword, setChangingPassword] = useState(false);

  const [profile, setProfile] = useState<any>({
    full_name: '',
    email: '',
    phone: '',
    city: '',
    father_name: '',
    current_address: '',
    role: '',
  });

  const [passwords, setPasswords] = useState({
    current_password: '',
    new_password: '',
    confirm_password: '',
  });

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      setLoading(true);
      const response = await authAPI.getProfile();
      setProfile(response.data.data || {});
    } catch (error) {
      console.error('Failed to load profile:', error);
      showToast('Failed to load profile', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleSaveProfile = async () => {
    try {
      setSaving(true);
      await authAPI.updateProfile({
        full_name: profile.full_name,
        phone: profile.phone,
        city: profile.city,
        father_name: profile.father_name,
        current_address: profile.current_address,
      });
      showToast('Profile updated successfully', 'success');
    } catch (error) {
      console.error('Failed to update profile:', error);
      showToast('Failed to update profile — please try again', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async () => {
    if (passwords.new_password !== passwords.confirm_password) {
      showToast('New password and confirmation do not match', 'error');
      return;
    }
    if (passwords.new_password.length < 6) {
      showToast('New password must be at least 6 characters', 'error');
      return;
    }
    try {
      setChangingPassword(true);
      await authAPI.changePassword({
        current_password: passwords.current_password,
        new_password: passwords.new_password,
      });
      showToast('Password changed successfully', 'success');
      setPasswords({ current_password: '', new_password: '', confirm_password: '' });
    } catch (error) {
      console.error('Failed to change password:', error);
      showToast('Failed to change password — please try again', 'error');
    } finally {
      setChangingPassword(false);
    }
  };

  return (
    <Layout>
      <div className="space-y-6 max-w-3xl">
        <div>
          <h1 className="text-2xl font-bold text-neutral-900">Profile &amp; Settings</h1>
          <p className="text-neutral-600 mt-1">Manage your account details and password</p>
        </div>

        {loading ? (
          <div className="card p-12 flex justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"></div>
          </div>
        ) : (
          <>
            {/* Profile Details */}
            <div className="card p-6">
              <div className="flex items-center gap-2 mb-6">
                <User className="w-5 h-5 text-primary-600" />
                <h2 className="text-lg font-bold text-neutral-900">Profile Details</h2>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Full Name</label>
                  <input
                    type="text"
                    value={profile.full_name || ''}
                    onChange={(e) => setProfile({ ...profile, full_name: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Father's Name</label>
                  <input
                    type="text"
                    value={profile.father_name || ''}
                    onChange={(e) => setProfile({ ...profile, father_name: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Phone</label>
                  <input
                    type="text"
                    value={profile.phone || ''}
                    onChange={(e) => setProfile({ ...profile, phone: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">City</label>
                  <input
                    type="text"
                    value={profile.city || ''}
                    onChange={(e) => setProfile({ ...profile, city: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
                <div className="sm:col-span-2">
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Current Address</label>
                  <input
                    type="text"
                    value={profile.current_address || ''}
                    onChange={(e) => setProfile({ ...profile, current_address: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Email</label>
                  <input
                    type="email"
                    value={profile.email || ''}
                    readOnly
                    className="input-field w-full bg-neutral-100 cursor-not-allowed text-neutral-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Role</label>
                  <input
                    type="text"
                    value={profile.role || ''}
                    readOnly
                    className="input-field w-full bg-neutral-100 cursor-not-allowed text-neutral-500"
                  />
                </div>
              </div>

              <div className="mt-6 pt-6 border-t border-neutral-200">
                <button
                  onClick={handleSaveProfile}
                  disabled={saving}
                  className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Save className="w-4 h-4 mr-2" />
                  {saving ? 'Saving...' : 'Save Changes'}
                </button>
              </div>
            </div>

            {/* Change Password */}
            <div className="card p-6">
              <div className="flex items-center gap-2 mb-6">
                <Lock className="w-5 h-5 text-primary-600" />
                <h2 className="text-lg font-bold text-neutral-900">Change Password</h2>
              </div>

              <div className="grid grid-cols-1 gap-4">
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Current Password</label>
                  <input
                    type="password"
                    value={passwords.current_password}
                    onChange={(e) => setPasswords({ ...passwords, current_password: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">New Password</label>
                  <input
                    type="password"
                    value={passwords.new_password}
                    onChange={(e) => setPasswords({ ...passwords, new_password: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-neutral-700 mb-1">Confirm New Password</label>
                  <input
                    type="password"
                    value={passwords.confirm_password}
                    onChange={(e) => setPasswords({ ...passwords, confirm_password: e.target.value })}
                    className="input-field w-full"
                  />
                </div>
              </div>

              <div className="mt-6 pt-6 border-t border-neutral-200">
                <button
                  onClick={handleChangePassword}
                  disabled={changingPassword}
                  className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Lock className="w-4 h-4 mr-2" />
                  {changingPassword ? 'Updating...' : 'Update Password'}
                </button>
              </div>
            </div>
          </>
        )}
      </div>
    </Layout>
  );
}
