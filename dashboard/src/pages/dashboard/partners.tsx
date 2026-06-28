import { useState, useEffect, useRef } from 'react';
import Layout from '@/components/Layout';
import { partnersAPI } from '@/services/api';
import {
  Plus,
  Pencil,
  Trash2,
  XCircle,
  Building2,
  Upload,
} from 'lucide-react';
import { useToast } from '@/components/Toast';
import ConfirmDialog from '@/components/ConfirmDialog';

const CATEGORIES = ['Hospital', 'Corporate', 'NGO', 'Bank', 'Educational', 'Media', 'Other'];

interface PartnerForm {
  name: string;
  category: string;
  description: string;
  website: string;
  email: string;
  phone: string;
  status: string;
}

const emptyForm: PartnerForm = {
  name: '',
  category: 'Hospital',
  description: '',
  website: '',
  email: '',
  phone: '',
  status: 'active',
};

export default function PartnersManagement() {
  const { showToast } = useToast();
  const [partners, setPartners] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState<PartnerForm>(emptyForm);
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [logoPreview, setLogoPreview] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [confirmId, setConfirmId] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    fetchPartners();
  }, []);

  const fetchPartners = async () => {
    try {
      setLoading(true);
      const response = await partnersAPI.getAll();
      setPartners(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch partners:', error);
    } finally {
      setLoading(false);
    }
  };

  const openAdd = () => {
    setEditingId(null);
    setForm(emptyForm);
    setLogoFile(null);
    setLogoPreview(null);
    setShowModal(true);
  };

  const openEdit = (partner: any) => {
    setEditingId(partner.id);
    setForm({
      name: partner.name || '',
      category: partner.category || 'Hospital',
      description: partner.description || '',
      website: partner.website || '',
      email: partner.email || '',
      phone: partner.phone || '',
      status: partner.status || 'active',
    });
    setLogoFile(null);
    setLogoPreview(partner.logo_url || null);
    setShowModal(true);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    setLogoFile(file);
    if (file) {
      setLogoPreview(URL.createObjectURL(file));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name.trim()) {
      showToast('Name is required', 'error');
      return;
    }
    try {
      setSubmitting(true);
      const formData = new FormData();
      (Object.keys(form) as (keyof PartnerForm)[]).forEach((key) => {
        const value = form[key];
        if (value !== '' && value !== null && value !== undefined) {
          formData.append(key, value);
        }
      });
      if (logoFile) {
        formData.append('logo', logoFile);
      }

      if (editingId) {
        await partnersAPI.update(editingId, formData);
        showToast('Partner updated', 'success');
      } else {
        await partnersAPI.create(formData);
        showToast('Partner added', 'success');
      }
      setShowModal(false);
      fetchPartners();
    } catch (error) {
      console.error('Failed to save partner:', error);
      showToast('Failed to save — please try again', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    setConfirmId(null);
    try {
      await partnersAPI.delete(id);
      showToast('Partner deleted', 'success');
      fetchPartners();
    } catch (error) {
      console.error('Failed to delete partner:', error);
      showToast('Failed to delete — please try again', 'error');
    }
  };

  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-neutral-900">Partners</h1>
            <p className="text-neutral-600 mt-1">Manage organizations partnering with Trusting Hand</p>
          </div>
          <button onClick={openAdd} className="btn-primary">
            <Plus className="w-4 h-4 mr-2" />
            Add Partner
          </button>
        </div>

        <div className="card p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Logo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Name
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Category
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Actions
                  </th>
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
                ) : partners.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-12 text-center text-neutral-500">
                      No partners yet. Click &apos;Add Partner&apos; to add one.
                    </td>
                  </tr>
                ) : (
                  partners.map((partner) => (
                    <tr key={partner.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        {partner.logo_url ? (
                          <img
                            src={partner.logo_url}
                            alt={partner.name}
                            className="h-10 w-10 rounded-lg object-cover border border-neutral-200"
                          />
                        ) : (
                          <div className="h-10 w-10 rounded-lg bg-neutral-100 flex items-center justify-center text-neutral-400">
                            <Building2 className="w-5 h-5" />
                          </div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-neutral-900">{partner.name}</div>
                        {partner.website && (
                          <div className="text-sm text-neutral-500">{partner.website}</div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-900">
                        {partner.category || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span
                          className={`badge ${
                            partner.status === 'active' ? 'badge-success' : 'badge-neutral'
                          }`}
                        >
                          {partner.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => openEdit(partner)}
                            className="text-primary-600 hover:text-primary-900"
                          >
                            <Pencil className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => setConfirmId(partner.id)}
                            className="text-red-600 hover:text-red-900"
                          >
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

      {showModal && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen px-4">
            <div
              className="fixed inset-0 bg-neutral-900 bg-opacity-50 transition-opacity"
              onClick={() => setShowModal(false)}
            ></div>
            <div className="relative bg-white rounded-xl shadow-strong max-w-2xl w-full p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-neutral-900">
                  {editingId ? 'Edit Partner' : 'Add Partner'}
                </h3>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-neutral-400 hover:text-neutral-600"
                >
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="text-sm font-medium text-neutral-600">
                      Name <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="text"
                      value={form.name}
                      onChange={(e) => setForm({ ...form, name: e.target.value })}
                      className="input-field w-full mt-1"
                      required
                    />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Category</label>
                    <select
                      value={form.category}
                      onChange={(e) => setForm({ ...form, category: e.target.value })}
                      className="input-field w-full mt-1"
                    >
                      {CATEGORIES.map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div>
                  <label className="text-sm font-medium text-neutral-600">Description</label>
                  <textarea
                    value={form.description}
                    onChange={(e) => setForm({ ...form, description: e.target.value })}
                    rows={3}
                    className="input-field w-full mt-1 resize-none"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Website</label>
                    <input
                      type="text"
                      value={form.website}
                      onChange={(e) => setForm({ ...form, website: e.target.value })}
                      className="input-field w-full mt-1"
                    />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Email</label>
                    <input
                      type="text"
                      value={form.email}
                      onChange={(e) => setForm({ ...form, email: e.target.value })}
                      className="input-field w-full mt-1"
                    />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Phone</label>
                    <input
                      type="text"
                      value={form.phone}
                      onChange={(e) => setForm({ ...form, phone: e.target.value })}
                      className="input-field w-full mt-1"
                    />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Status</label>
                    <select
                      value={form.status}
                      onChange={(e) => setForm({ ...form, status: e.target.value })}
                      className="input-field w-full mt-1"
                    >
                      <option value="active">Active</option>
                      <option value="inactive">Inactive</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="text-sm font-medium text-neutral-600">Logo</label>
                  <div className="flex items-center gap-4 mt-1">
                    {logoPreview ? (
                      <img
                        src={logoPreview}
                        alt="Logo preview"
                        className="h-16 w-16 rounded-lg object-cover border border-neutral-200"
                      />
                    ) : (
                      <div className="h-16 w-16 rounded-lg bg-neutral-100 flex items-center justify-center text-neutral-400">
                        <Building2 className="w-7 h-7" />
                      </div>
                    )}
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/*"
                      onChange={handleFileChange}
                      className="hidden"
                    />
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      className="btn-secondary"
                    >
                      <Upload className="w-4 h-4 mr-2" />
                      Choose Image
                    </button>
                  </div>
                </div>

                <div className="flex gap-3 pt-4 border-t border-neutral-200">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="flex-1 btn-secondary"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="flex-1 btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {submitting ? 'Saving...' : editingId ? 'Save Changes' : 'Add Partner'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!confirmId}
        mode="delete"
        title="Delete Partner"
        message="Are you sure you want to delete this partner? This action is permanent and cannot be undone."
        onCancel={() => setConfirmId(null)}
        onConfirm={() => confirmId && handleDelete(confirmId)}
      />
    </Layout>
  );
}
