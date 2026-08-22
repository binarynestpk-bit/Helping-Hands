import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { deletionRequestsAPI } from '@/services/api';
import { UserX, Trash2, Clock, CheckCircle, AlertTriangle } from 'lucide-react';
import { useToast } from '@/components/Toast';
import ConfirmDialog from '@/components/ConfirmDialog';
import { formatDate, truncateText } from '@/utils/helpers';

const statusBadge = (status: string) => {
  switch (status) {
    case 'completed':
      return 'badge-success';
    case 'pending':
      return 'badge-warning';
    default:
      return 'badge-neutral';
  }
};

export default function DeletionRequests() {
  const { showToast } = useToast();
  const [requests, setRequests] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [confirmId, setConfirmId] = useState<string | null>(null);

  useEffect(() => {
    fetchRequests();
  }, []);

  const fetchRequests = async () => {
    try {
      setLoading(true);
      const response = await deletionRequestsAPI.getAll();
      setRequests(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch deletion requests:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleComplete = async (id: string) => {
    try {
      await deletionRequestsAPI.complete(id);
      showToast('Request marked as done', 'success');
      fetchRequests();
    } catch (error) {
      console.error('Failed to mark request as done:', error);
      showToast('Failed to update — please try again', 'error');
    }
  };

  const handleDelete = async (id: string) => {
    setConfirmId(null);
    try {
      await deletionRequestsAPI.delete(id);
      showToast('Request deleted', 'success');
      fetchRequests();
    } catch (error) {
      console.error('Failed to delete deletion request:', error);
      showToast('Failed to delete — please try again', 'error');
    }
  };

  const total = requests.length;
  const pendingCount = requests.filter((r) => r.status === 'pending').length;

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-neutral-900">Account Deletion Requests</h1>
          <p className="text-neutral-600 mt-1">
            Users who requested deletion of their account and data (via the web form).
          </p>
        </div>

        <div className="card p-4 flex items-start gap-3 bg-yellow-50 border border-yellow-200">
          <AlertTriangle className="w-5 h-5 flex-shrink-0 text-yellow-600 mt-0.5" />
          <p className="text-sm text-yellow-800">
            After receiving a request, delete the matching user from User Management, then
            mark the request as done here.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-md">
          <div className="card p-5 flex items-center gap-4">
            <div className="p-3 rounded-xl bg-primary-50 text-primary-600">
              <UserX className="w-6 h-6" />
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
                    Email
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Phone
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Reason
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
                    <td colSpan={6} className="px-6 py-12 text-center">
                      <div className="flex justify-center">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"></div>
                      </div>
                    </td>
                  </tr>
                ) : requests.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-12 text-center text-neutral-500">
                      No deletion requests.
                    </td>
                  </tr>
                ) : (
                  requests.map((req) => (
                    <tr key={req.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-neutral-900">
                        {req.email || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                        {req.phone || 'N/A'}
                      </td>
                      <td className="px-6 py-4 text-sm text-neutral-600 max-w-xs">
                        {req.reason ? (
                          <span title={req.reason}>{truncateText(req.reason, 60)}</span>
                        ) : (
                          <span className="text-neutral-400">—</span>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={statusBadge(req.status)}>{req.status}</span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                        {req.created_at ? formatDate(req.created_at) : 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end gap-3">
                          {req.status === 'pending' && (
                            <button
                              onClick={() => handleComplete(req.id)}
                              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium text-white bg-green-600 hover:bg-green-700 transition-colors"
                            >
                              <CheckCircle className="w-4 h-4" />
                              Mark done
                            </button>
                          )}
                          <button
                            onClick={() => setConfirmId(req.id)}
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

      <ConfirmDialog
        open={!!confirmId}
        mode="delete"
        title="Delete Deletion Request"
        message="Are you sure you want to delete this deletion request record? This action is permanent and cannot be undone."
        onCancel={() => setConfirmId(null)}
        onConfirm={() => confirmId && handleDelete(confirmId)}
      />
    </Layout>
  );
}
