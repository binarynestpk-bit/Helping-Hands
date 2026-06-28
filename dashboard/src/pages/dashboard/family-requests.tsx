import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { familyRequestsAPI } from '@/services/api';
import {
  Search,
  Download,
  Eye,
  CheckCircle,
  XCircle,
  Heart,
  Users,
  DollarSign,
  Calendar,
  MapPin,
  Phone,
  Trash2,
} from 'lucide-react';
import { formatDate, getStatusColor, formatCurrency } from '@/utils/helpers';
import { exportToCsv, csvDateStamp } from '@/utils/exportCsv';
import { useToast } from '@/components/Toast';
import ConfirmDialog from '@/components/ConfirmDialog';

export default function FamilyRequests() {
  const { showToast } = useToast();
  const [requests, setRequests] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedRequest, setSelectedRequest] = useState<any>(null);
  const [showModal, setShowModal] = useState(false);
  const [confirmState, setConfirmState] = useState<{ mode: 'approve' | 'reject' | 'delete'; id: string } | null>(null);

  useEffect(() => {
    fetchRequests();
  }, [statusFilter]);

  const fetchRequests = async () => {
    try {
      setLoading(true);
      const response = await familyRequestsAPI.getAll({
        status: statusFilter !== 'all' ? statusFilter : undefined,
      });
      setRequests(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch family requests:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (requestId: string) => {
    try {
      await familyRequestsAPI.approve(requestId);
      showToast('Request approved', 'success');
      fetchRequests();
    } catch (error) {
      console.error('Failed to approve request:', error);
      showToast('Failed to approve — please try again', 'error');
    }
  };

  const handleReject = async (requestId: string, reason: string) => {
    try {
      await familyRequestsAPI.reject(requestId, reason);
      showToast('Request rejected', 'success');
      fetchRequests();
    } catch (error) {
      console.error('Failed to reject request:', error);
      showToast('Failed to reject — please try again', 'error');
    }
  };

  const handleDelete = async (requestId: string) => {
    try {
      await familyRequestsAPI.delete(requestId);
      showToast('Record deleted', 'success');
      fetchRequests();
    } catch (error) {
      console.error('Failed to delete request:', error);
      showToast('Failed to delete — please try again', 'error');
    }
  };

  const handleConfirm = async (reason?: string) => {
    if (!confirmState) return;
    const { mode, id } = confirmState;
    setConfirmState(null);
    setShowModal(false);
    if (mode === 'approve') {
      await handleApprove(id);
    } else if (mode === 'delete') {
      await handleDelete(id);
    } else {
      await handleReject(id, reason || '');
    }
  };

  const filteredRequests = requests.filter((request) =>
    request.family_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    request.father_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    request.address?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleExport = () => {
    exportToCsv(`family-requests-${csvDateStamp()}.csv`, filteredRequests, [
      { key: 'family_name', label: 'Family Name' },
      { key: 'father_name', label: 'Father Name' },
      { key: 'address', label: 'Address' },
      { key: 'mobile_number', label: 'Mobile Number' },
      { key: 'children_count', label: 'Children Count' },
      { key: 'shahadat_date', label: 'Shahadat Date' },
      { key: 'monthly_need', label: 'Monthly Need' },
      { key: 'status', label: 'Status' },
    ]);
  };

  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-neutral-900">
              Martyrs' Family Support Requests
            </h1>
            <p className="text-neutral-600 mt-1">
              Manage and approve family support requests
            </p>
          </div>
          <button onClick={handleExport} className="btn-primary">
            <Download className="w-4 h-4 mr-2" />
            Export Data
          </button>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Total Requests</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">{requests.length}</p>
              </div>
              <div className="p-3 bg-yellow-100 rounded-lg">
                <Heart className="w-6 h-6 text-yellow-600" />
              </div>
            </div>
          </div>
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Pending</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">
                  {requests.filter((r) => r.status === 'pending').length}
                </p>
              </div>
              <div className="p-3 bg-orange-100 rounded-lg">
                <Users className="w-6 h-6 text-orange-600" />
              </div>
            </div>
          </div>
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Approved</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">
                  {requests.filter((r) => r.status === 'approved').length}
                </p>
              </div>
              <div className="p-3 bg-green-100 rounded-lg">
                <CheckCircle className="w-6 h-6 text-green-600" />
              </div>
            </div>
          </div>
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Families Supported</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">
                  {requests.filter((r) => r.status === 'fully_funded').length}
                </p>
              </div>
              <div className="p-3 bg-primary-100 rounded-lg">
                <Heart className="w-6 h-6 text-primary-600" fill="currentColor" />
              </div>
            </div>
          </div>
        </div>

        <div className="card p-6">
          <div className="flex flex-col sm:flex-row gap-4 mb-6">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-neutral-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Search by family name, father's name, or address..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input-field pl-10 w-full"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="input-field min-w-[150px]"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="partially_funded">Partially Funded</option>
              <option value="fully_funded">Fully Funded</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Family Details
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Contact
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Children
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Shahadat Date
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Monthly Need
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
                    <td colSpan={7} className="px-6 py-12 text-center">
                      <div className="flex justify-center">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"></div>
                      </div>
                    </td>
                  </tr>
                ) : filteredRequests.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-6 py-12 text-center text-neutral-500">
                      No family support requests found
                    </td>
                  </tr>
                ) : (
                  filteredRequests.map((request) => (
                    <tr key={request.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4">
                        <div>
                          <div className="text-sm font-medium text-neutral-900">
                            {request.family_name}
                          </div>
                          <div className="text-sm text-neutral-500">
                            Father: {request.father_name}
                          </div>
                          <div className="text-sm text-neutral-500 flex items-center mt-1">
                            <MapPin className="w-3 h-3 mr-1" />
                            {request.address.substring(0, 40)}...
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-neutral-900">
                          <Phone className="w-4 h-4 mr-1 text-neutral-400" />
                          {request.mobile_number}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        {request.marital_status ? (
                          <div className="text-sm">
                            <div className="font-medium text-neutral-900">
                              {request.children_count} children
                            </div>
                            <div className="text-neutral-500">
                              {request.boys_count} boys, {request.girls_count} girls
                            </div>
                          </div>
                        ) : (
                          <span className="text-sm text-neutral-500">N/A</span>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-900">
                        {formatDate(request.shahadat_date)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-neutral-900">
                        {formatCurrency(parseFloat(request.monthly_need))}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`badge badge-${getStatusColor(request.status)}`}>
                          {request.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => {
                              setSelectedRequest(request);
                              setShowModal(true);
                            }}
                            className="text-primary-600 hover:text-primary-900"
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                          {request.status === 'pending' && (
                            <>
                              <button
                                onClick={() => setConfirmState({ mode: 'approve', id: request.id })}
                                className="text-green-600 hover:text-green-900"
                              >
                                <CheckCircle className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => setConfirmState({ mode: 'reject', id: request.id })}
                                className="text-red-600 hover:text-red-900"
                              >
                                <XCircle className="w-4 h-4" />
                              </button>
                            </>
                          )}
                          <button
                            onClick={() => setConfirmState({ mode: 'delete', id: request.id })}
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

      {showModal && selectedRequest && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen px-4">
            <div
              className="fixed inset-0 bg-neutral-900 bg-opacity-50 transition-opacity"
              onClick={() => setShowModal(false)}
            ></div>
            <div className="relative bg-white rounded-xl shadow-strong max-w-4xl w-full p-6 max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-neutral-900">
                  Family Support Request Details
                </h3>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-neutral-400 hover:text-neutral-600"
                >
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <div className="grid grid-cols-2 gap-6">
                <div>
                  <label className="text-sm font-medium text-neutral-600">Family Name</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.family_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Father's Name</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.father_name}</p>
                </div>
                <div className="col-span-2">
                  <label className="text-sm font-medium text-neutral-600">Address</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.address}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Mobile Number</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.mobile_number}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Marital Status</label>
                  <p className="text-neutral-900 mt-1">
                    {selectedRequest.marital_status ? 'Married' : 'Unmarried'}
                  </p>
                </div>

                {selectedRequest.marital_status && (
                  <>
                    <div>
                      <label className="text-sm font-medium text-neutral-600">
                        Total Children
                      </label>
                      <p className="text-neutral-900 mt-1">{selectedRequest.children_count}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-neutral-600">Boys</label>
                      <p className="text-neutral-900 mt-1">{selectedRequest.boys_count}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-neutral-600">Girls</label>
                      <p className="text-neutral-900 mt-1">{selectedRequest.girls_count}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-neutral-600">
                        Children Ages
                      </label>
                      <p className="text-neutral-900 mt-1">{selectedRequest.children_ages}</p>
                    </div>
                  </>
                )}

                <div>
                  <label className="text-sm font-medium text-neutral-600">Shahadat Date</label>
                  <p className="text-neutral-900 mt-1">
                    {formatDate(selectedRequest.shahadat_date)}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Shahadat Place</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.shahadat_place}</p>
                </div>

                <div className="col-span-2">
                  <label className="text-sm font-medium text-neutral-600">
                    Shahadat Description
                  </label>
                  <p className="text-neutral-900 mt-1">
                    {selectedRequest.shahadat_description || 'N/A'}
                  </p>
                </div>

                <div>
                  <label className="text-sm font-medium text-neutral-600">Monthly Need</label>
                  <p className="text-neutral-900 mt-1 font-semibold text-lg">
                    {formatCurrency(parseFloat(selectedRequest.monthly_need))}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Status</label>
                  <p className="mt-1">
                    <span className={`badge badge-${getStatusColor(selectedRequest.status)}`}>
                      {selectedRequest.status}
                    </span>
                  </p>
                </div>

                {selectedRequest.video_link && (
                  <div className="col-span-2">
                    <label className="text-sm font-medium text-neutral-600">Video Link</label>
                    <a
                      href={selectedRequest.video_link}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary-600 hover:text-primary-700 text-sm mt-1 block"
                    >
                      {selectedRequest.video_link}
                    </a>
                  </div>
                )}

                <div>
                  <label className="text-sm font-medium text-neutral-600">Request Date</label>
                  <p className="text-neutral-900 mt-1">
                    {formatDate(selectedRequest.created_at)}
                  </p>
                </div>

                {selectedRequest.photo_attachment_url && (
                  <div className="col-span-2">
                    <label className="text-sm font-medium text-neutral-600">Documents</label>
                    <div className="flex flex-wrap gap-4 mt-2">
                      <div>
                        <p className="text-xs text-neutral-500 mb-1">Family Photo / Document</p>
                        <a
                          href={selectedRequest.photo_attachment_url}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <img
                            src={selectedRequest.photo_attachment_url}
                            alt="Family Photo / Document"
                            className="w-[120px] h-[120px] object-cover rounded-lg border border-neutral-200 hover:opacity-90 transition-opacity"
                          />
                        </a>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              <div className="flex gap-3 mt-6 pt-6 border-t border-neutral-200">
                {selectedRequest.status === 'pending' && (
                  <>
                    <button
                      onClick={() => setConfirmState({ mode: 'approve', id: selectedRequest.id })}
                      className="flex-1 bg-green-600 text-white px-4 py-2.5 rounded-lg font-medium hover:bg-green-700 transition-colors"
                    >
                      <CheckCircle className="w-4 h-4 inline mr-2" />
                      Approve Request
                    </button>
                    <button
                      onClick={() => setConfirmState({ mode: 'reject', id: selectedRequest.id })}
                      className="flex-1 btn-danger"
                    >
                      <XCircle className="w-4 h-4 inline mr-2" />
                      Reject Request
                    </button>
                  </>
                )}
                <button
                  onClick={() => setConfirmState({ mode: 'delete', id: selectedRequest.id })}
                  className="flex-1 inline-flex items-center justify-center bg-red-600 text-white px-4 py-2.5 rounded-lg font-medium hover:bg-red-700 transition-colors"
                >
                  <Trash2 className="w-4 h-4 mr-2" />
                  Delete
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!confirmState}
        mode={confirmState?.mode || 'approve'}
        onCancel={() => setConfirmState(null)}
        onConfirm={handleConfirm}
      />
    </Layout>
  );
}
