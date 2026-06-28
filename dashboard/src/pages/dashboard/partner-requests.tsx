import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { partnerApplicationsAPI } from '@/services/api';
import { Inbox, Trash2, Clock, X } from 'lucide-react';
import { useToast } from '@/components/Toast';
import ConfirmDialog from '@/components/ConfirmDialog';
import { formatDate, truncateText } from '@/utils/helpers';

const STATUSES = ['pending', 'contacted', 'closed'];

const statusBadge = (status: string) => {
  switch (status) {
    case 'pending':
      return 'badge-warning';
    case 'contacted':
      return 'badge-info';
    default:
      return 'badge-neutral';
  }
};

export default function PartnerRequests() {
  const { showToast } = useToast();
  const [applications, setApplications] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [confirmId, setConfirmId] = useState<string | null>(null);
  const [detail, setDetail] = useState<any | null>(null);

  useEffect(() => {
    fetchApplications();
  }, []);

  const fetchApplications = async () => {
    try {
      setLoading(true);
      const response = await partnerApplicationsAPI.getAll();
      setApplications(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch partner applications:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (id: string, status: string) => {
    try {
      await partnerApplicationsAPI.updateStatus(id, status);
      showToast('Status updated', 'success');
      fetchApplications();
    } catch (error) {
      console.error('Failed to update status:', error);
      showToast('Failed to update status — please try again', 'error');
    }
  };

  const handleDelete = async (id: string) => {
    setConfirmId(null);
    try {
      await partnerApplicationsAPI.delete(id);
      showToast('Request deleted', 'success');
      fetchApplications();
    } catch (error) {
      console.error('Failed to delete partner application:', error);
      showToast('Failed to delete — please try again', 'error');
    }
  };

  const total = applications.length;
  const pendingCount = applications.filter((a) => a.status === 'pending').length;

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-neutral-900">Partner Requests</h1>
          <p className="text-neutral-600 mt-1">
            Organizations who applied to partner with us via the app
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-md">
          <div className="card p-5 flex items-center gap-4">
            <div className="p-3 rounded-xl bg-primary-50 text-primary-600">
              <Inbox className="w-6 h-6" />
            </div>
            <div>
              <p className="text-sm text-neutral-500">Total</p>
              <p className="text-2xl font-bold text-neutral-900">{total}</p>
            </div>
          </div>
          <div className="card p-5 flex items-center gap-4">
            <div className="p-3 rounded-xl bg-yellow-50 text-yellow-600">
              <Clock className="w-6 h-6" />
            </div>
            <div>
              <p className="text-sm text-neutral-500">Pending</p>
              <p className="text-2xl font-bold text-neutral-900">{pendingCount}</p>
            </div>
          </div>
        </div>

        <div className="card p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Organization
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Contact
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Email
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Phone
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Message
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Date
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-neutral-200">
                {loading ? (
                  <tr>
                    <td colSpan={8} className="px-6 py-12 text-center">
                      <div className="flex justify-center">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"></div>
                      </div>
                    </td>
                  </tr>
                ) : applications.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="px-6 py-12 text-center text-neutral-500">
                      No partner requests yet.
                    </td>
                  </tr>
                ) : (
                  applications.map((app) => (
                    <tr key={app.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-neutral-900">
                        {app.organization_name}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-900">
                        {app.contact_person || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                        {app.email || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                        {app.phone || 'N/A'}
                      </td>
                      <td className="px-6 py-4 text-sm text-neutral-600 max-w-xs">
                        {app.message ? (
                          <button
                            onClick={() => setDetail(app)}
                            title={app.message}
                            className="text-left hover:text-primary-600 transition-colors"
                          >
                            {truncateText(app.message, 60)}
                          </button>
                        ) : (
                          <span className="text-neutral-400">—</span>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={statusBadge(app.status)}>{app.status}</span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                        {app.created_at ? formatDate(app.created_at) : 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end gap-3">
                          <select
                            value={app.status}
                            onChange={(e) => handleStatusChange(app.id, e.target.value)}
                            className="input-field text-sm py-1.5"
                          >
                            {STATUSES.map((s) => (
                              <option key={s} value={s}>
                                {s.charAt(0).toUpperCase() + s.slice(1)}
                              </option>
                            ))}
                          </select>
                          <button
                            onClick={() => setConfirmId(app.id)}
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

      {detail && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen px-4">
            <div
              className="fixed inset-0 bg-neutral-900 bg-opacity-50 transition-opacity"
              onClick={() => setDetail(null)}
            ></div>
            <div className="relative bg-white rounded-xl shadow-strong max-w-lg w-full p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-bold text-neutral-900">
                  {detail.organization_name}
                </h3>
                <button
                  onClick={() => setDetail(null)}
                  className="text-neutral-400 hover:text-neutral-600"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
              <div className="space-y-3 text-sm">
                <div>
                  <span className="font-medium text-neutral-600">Contact: </span>
                  <span className="text-neutral-900">{detail.contact_person || 'N/A'}</span>
                </div>
                <div>
                  <span className="font-medium text-neutral-600">Email: </span>
                  <span className="text-neutral-900">{detail.email || 'N/A'}</span>
                </div>
                <div>
                  <span className="font-medium text-neutral-600">Phone: </span>
                  <span className="text-neutral-900">{detail.phone || 'N/A'}</span>
                </div>
                <div>
                  <p className="font-medium text-neutral-600 mb-1">Message</p>
                  <p className="text-neutral-900 whitespace-pre-wrap">
                    {detail.message || 'No message provided.'}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!confirmId}
        mode="delete"
        title="Delete Partner Request"
        message="Are you sure you want to delete this partner request? This action is permanent and cannot be undone."
        onCancel={() => setConfirmId(null)}
        onConfirm={() => confirmId && handleDelete(confirmId)}
      />
    </Layout>
  );
}
