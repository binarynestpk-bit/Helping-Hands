import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { donationAccountsAPI } from '@/services/api';
import { Plus, Pencil, Trash2, XCircle, Landmark } from 'lucide-react';
import { useToast } from '@/components/Toast';
import ConfirmDialog from '@/components/ConfirmDialog';

const TYPES = [
  { value: 'bank', label: 'Bank account' },
  { value: 'paypal', label: 'PayPal' },
  { value: 'jazzcash', label: 'JazzCash' },
  { value: 'easypaisa', label: 'Easypaisa' },
  { value: 'other', label: 'Other' },
];

const emptyForm = {
  type: 'bank',
  label: '',
  account_title: '',
  account_number: '',
  iban: '',
  bank_name: '',
  currency: 'PKR',
  instructions: '',
  is_active: true,
  sort_order: 0,
};

export default function DonationAccounts() {
  const { showToast } = useToast();
  const [accounts, setAccounts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState<any>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  useEffect(() => {
    fetchAccounts();
  }, []);

  const fetchAccounts = async () => {
    try {
      setLoading(true);
      const res = await donationAccountsAPI.getAll();
      setAccounts(res.data.data || []);
    } catch (error) {
      console.error('Failed to fetch accounts:', error);
    } finally {
      setLoading(false);
    }
  };

  const openAdd = () => {
    setForm(emptyForm);
    setEditingId(null);
    setShowForm(true);
  };

  const openEdit = (a: any) => {
    setForm({
      type: a.type || 'bank',
      label: a.label || '',
      account_title: a.account_title || '',
      account_number: a.account_number || '',
      iban: a.iban || '',
      bank_name: a.bank_name || '',
      currency: a.currency || '',
      instructions: a.instructions || '',
      is_active: a.is_active !== false,
      sort_order: a.sort_order || 0,
    });
    setEditingId(a.id);
    setShowForm(true);
  };

  const set = (k: string, v: any) => setForm((f: any) => ({ ...f, [k]: v }));

  const handleSave = async () => {
    if (!form.label.trim()) {
      showToast('Label is required', 'error');
      return;
    }
    try {
      setSaving(true);
      if (editingId) {
        await donationAccountsAPI.update(editingId, form);
        showToast('Account updated', 'success');
      } else {
        await donationAccountsAPI.create(form);
        showToast('Account added', 'success');
      }
      setShowForm(false);
      fetchAccounts();
    } catch (error) {
      console.error('Failed to save account:', error);
      showToast('Failed to save — please try again', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteId) return;
    const id = deleteId;
    setDeleteId(null);
    try {
      await donationAccountsAPI.delete(id);
      showToast('Account deleted', 'success');
      fetchAccounts();
    } catch (error) {
      console.error('Failed to delete account:', error);
      showToast('Failed to delete — please try again', 'error');
    }
  };

  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-neutral-900">Donation Accounts</h1>
            <p className="text-neutral-600 mt-1">
              Bank, PayPal and wallet accounts shown to donors in the app. Changes appear instantly — no app update needed.
            </p>
          </div>
          <button onClick={openAdd} className="btn-primary">
            <Plus className="w-4 h-4 mr-2" />
            Add Account
          </button>
        </div>

        <div className="card p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Label</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Type</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Account</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Active</th>
                  <th className="px-6 py-3 text-right text-xs font-semibold text-neutral-600 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-neutral-200">
                {loading ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-12 text-center">
                      <div className="flex justify-center">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"></div>
                      </div>
                    </td>
                  </tr>
                ) : accounts.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-12 text-center text-neutral-500">
                      No accounts yet. Add one so donors can send money.
                    </td>
                  </tr>
                ) : (
                  accounts.map((a) => (
                    <tr key={a.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          <Landmark className="w-4 h-4 text-primary-500" />
                          <span className="text-sm font-medium text-neutral-900">{a.label}</span>
                        </div>
                        {a.bank_name && <div className="text-sm text-neutral-500 ml-6">{a.bank_name}</div>}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="badge badge-info capitalize">{a.type}</span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-neutral-900">{a.account_number || '—'}</div>
                        {a.iban && <div className="text-xs text-neutral-500">{a.iban}</div>}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`badge badge-${a.is_active !== false ? 'success' : 'neutral'}`}>
                          {a.is_active !== false ? 'Active' : 'Hidden'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end gap-3">
                          <button onClick={() => openEdit(a)} className="text-primary-600 hover:text-primary-900">
                            <Pencil className="w-4 h-4" />
                          </button>
                          <button onClick={() => setDeleteId(a.id)} className="text-red-600 hover:text-red-900">
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {showForm && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen px-4">
            <div className="fixed inset-0 bg-neutral-900 bg-opacity-50" onClick={() => setShowForm(false)}></div>
            <div className="relative bg-white rounded-xl shadow-strong max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-neutral-900">{editingId ? 'Edit Account' : 'Add Account'}</h3>
                <button onClick={() => setShowForm(false)} className="text-neutral-400 hover:text-neutral-600">
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-neutral-600">Type</label>
                  <select value={form.type} onChange={(e) => set('type', e.target.value)} className="input-field w-full mt-1">
                    {TYPES.map((t) => (
                      <option key={t.value} value={t.value}>{t.label}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Label *</label>
                  <input value={form.label} onChange={(e) => set('label', e.target.value)} className="input-field w-full mt-1" placeholder="e.g. Meezan Bank (Local)" />
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Account Title</label>
                  <input value={form.account_title} onChange={(e) => set('account_title', e.target.value)} className="input-field w-full mt-1" placeholder="Account holder name" />
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Account Number / Email</label>
                  <input value={form.account_number} onChange={(e) => set('account_number', e.target.value)} className="input-field w-full mt-1" placeholder="Account no. / PayPal email / wallet no." />
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">IBAN</label>
                  <input value={form.iban} onChange={(e) => set('iban', e.target.value)} className="input-field w-full mt-1" placeholder="PK.." />
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Bank Name</label>
                  <input value={form.bank_name} onChange={(e) => set('bank_name', e.target.value)} className="input-field w-full mt-1" />
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Currency</label>
                  <input value={form.currency} onChange={(e) => set('currency', e.target.value)} className="input-field w-full mt-1" placeholder="PKR / USD" />
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Sort Order</label>
                  <input type="number" value={form.sort_order} onChange={(e) => set('sort_order', parseInt(e.target.value) || 0)} className="input-field w-full mt-1" />
                </div>
                <div className="md:col-span-2">
                  <label className="text-sm font-medium text-neutral-600">Instructions (optional)</label>
                  <input value={form.instructions} onChange={(e) => set('instructions', e.target.value)} className="input-field w-full mt-1" placeholder="e.g. Use your name as reference" />
                </div>
                <div className="md:col-span-2">
                  <label className="inline-flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" checked={form.is_active} onChange={(e) => set('is_active', e.target.checked)} className="w-4 h-4" />
                    <span className="text-sm text-neutral-700">Active (visible to donors)</span>
                  </label>
                </div>
              </div>

              <div className="flex gap-3 mt-6 pt-6 border-t border-neutral-200">
                <button onClick={handleSave} disabled={saving} className="flex-1 btn-primary justify-center disabled:opacity-60">
                  {saving ? 'Saving...' : editingId ? 'Update Account' : 'Add Account'}
                </button>
                <button onClick={() => setShowForm(false)} className="flex-1 inline-flex items-center justify-center bg-neutral-200 text-neutral-800 px-4 py-2.5 rounded-lg font-medium hover:bg-neutral-300 transition-colors">
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteId}
        mode="delete"
        onCancel={() => setDeleteId(null)}
        onConfirm={handleDelete}
      />
    </Layout>
  );
}
