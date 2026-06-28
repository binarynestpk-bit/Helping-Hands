import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { educationRequestsAPI } from '@/services/api';
import {
  Search,
  Download,
  Eye,
  CheckCircle,
  XCircle,
  GraduationCap,
  FileText,
  DollarSign,
  Trash2,
} from 'lucide-react';
import { formatDate, getStatusColor, formatCurrency } from '@/utils/helpers';
import { exportToCsv, csvDateStamp } from '@/utils/exportCsv';
import { useToast } from '@/components/Toast';
import ConfirmDialog from '@/components/ConfirmDialog';

export default function EducationRequests() {
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
      const response = await educationRequestsAPI.getAll({
        status: statusFilter !== 'all' ? statusFilter : undefined,
      });
      setRequests(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch education requests:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (requestId: string) => {
    try {
      await educationRequestsAPI.approve(requestId);
      showToast('Request approved', 'success');
      fetchRequests();
    } catch (error) {
      console.error('Failed to approve request:', error);
      showToast('Failed to approve — please try again', 'error');
    }
  };

  const handleReject = async (requestId: string, reason: string) => {
    try {
      await educationRequestsAPI.reject(requestId, reason);
      showToast('Request rejected', 'success');
      fetchRequests();
    } catch (error) {
      console.error('Failed to reject request:', error);
      showToast('Failed to reject — please try again', 'error');
    }
  };

  const handleDelete = async (requestId: string) => {
    try {
      await educationRequestsAPI.delete(requestId);
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
    request.student_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    request.institution_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    request.degree?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleExport = () => {
    exportToCsv(`education-requests-${csvDateStamp()}.csv`, filteredRequests, [
      { key: 'student_name', label: 'Student Name' },
      { key: 'father_name', label: 'Father Name' },
      { key: 'institution_name', label: 'Institution Name' },
      { key: 'degree', label: 'Degree' },
      { key: 'cgpa_result', label: 'CGPA/Result' },
      { key: 'fee_amount', label: 'Fee Amount' },
      { key: 'mobile_number', label: 'Mobile Number' },
      { key: 'status', label: 'Status' },
      { key: 'required_date', label: 'Required Date' },
    ]);
  };

  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-neutral-900">Education Support Requests</h1>
            <p className="text-neutral-600 mt-1">Manage and approve education funding requests</p>
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
              <div className="p-3 bg-green-100 rounded-lg">
                <GraduationCap className="w-6 h-6 text-green-600" />
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
              <div className="p-3 bg-yellow-100 rounded-lg">
                <FileText className="w-6 h-6 text-yellow-600" />
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
              <div className="p-3 bg-blue-100 rounded-lg">
                <CheckCircle className="w-6 h-6 text-blue-600" />
              </div>
            </div>
          </div>
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Total Amount</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">
                  {formatCurrency(
                    requests.reduce((sum, r) => sum + parseFloat(r.fee_amount || 0), 0)
                  )}
                </p>
              </div>
              <div className="p-3 bg-primary-100 rounded-lg">
                <DollarSign className="w-6 h-6 text-primary-600" />
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
                placeholder="Search by student name, institution, or degree..."
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
              <option value="funded">Funded</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Student
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Institution
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Degree
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    CGPA
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Fee Amount
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
                ) : filteredRequests.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="px-6 py-12 text-center text-neutral-500">
                      No education requests found
                    </td>
                  </tr>
                ) : (
                  filteredRequests.map((request) => (
                    <tr key={request.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <div className="text-sm font-medium text-neutral-900">
                            {request.student_name}
                          </div>
                          <div className="text-sm text-neutral-500">
                            Father: {request.father_name}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-neutral-900 max-w-xs truncate">
                          {request.institution_name}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-neutral-900 max-w-xs truncate">
                          {request.degree}
                        </div>
                        <div className="text-sm text-neutral-500">{request.semester_year}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="badge badge-info">{request.cgpa_result}</span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-neutral-900">
                        {formatCurrency(parseFloat(request.fee_amount))}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`badge badge-${getStatusColor(request.status)}`}>
                          {request.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                        {formatDate(request.required_date)}
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
                  Education Support Request Details
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
                  <label className="text-sm font-medium text-neutral-600">Student Name</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.student_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Father's Name</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.father_name}</p>
                </div>
                <div className="col-span-2">
                  <label className="text-sm font-medium text-neutral-600">Institution Name</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.institution_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Degree</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.degree}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Semester/Year</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.semester_year}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">CGPA/Result</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.cgpa_result}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Mobile Number</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.mobile_number}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Fee Amount</label>
                  <p className="text-neutral-900 mt-1 font-semibold text-lg">
                    {formatCurrency(parseFloat(selectedRequest.fee_amount))}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Required Date</label>
                  <p className="text-neutral-900 mt-1">
                    {formatDate(selectedRequest.required_date)}
                  </p>
                </div>
                <div className="col-span-2">
                  <label className="text-sm font-medium text-neutral-600">Reason for Support</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.reason}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Status</label>
                  <p className="mt-1">
                    <span className={`badge badge-${getStatusColor(selectedRequest.status)}`}>
                      {selectedRequest.status}
                    </span>
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Request Date</label>
                  <p className="text-neutral-900 mt-1">
                    {formatDate(selectedRequest.created_at)}
                  </p>
                </div>

                {(selectedRequest.result_attachment_url || selectedRequest.fee_challan_url) && (
                  <div className="col-span-2">
                    <label className="text-sm font-medium text-neutral-600">Documents</label>
                    <div className="flex flex-wrap gap-4 mt-2">
                      {selectedRequest.result_attachment_url && (
                        <div>
                          <p className="text-xs text-neutral-500 mb-1">Result / Marksheet</p>
                          <a
                            href={selectedRequest.result_attachment_url}
                            target="_blank"
                            rel="noopener noreferrer"
                          >
                            <img
                              src={selectedRequest.result_attachment_url}
                              alt="Result / Marksheet"
                              className="w-[120px] h-[120px] object-cover rounded-lg border border-neutral-200 hover:opacity-90 transition-opacity"
                            />
                          </a>
                        </div>
                      )}
                      {selectedRequest.fee_challan_url && (
                        <div>
                          <p className="text-xs text-neutral-500 mb-1">Fee Challan</p>
                          <a
                            href={selectedRequest.fee_challan_url}
                            target="_blank"
                            rel="noopener noreferrer"
                          >
                            <img
                              src={selectedRequest.fee_challan_url}
                              alt="Fee Challan"
                              className="w-[120px] h-[120px] object-cover rounded-lg border border-neutral-200 hover:opacity-90 transition-opacity"
                            />
                          </a>
                        </div>
                      )}
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
