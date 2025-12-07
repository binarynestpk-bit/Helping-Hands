import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { bloodRequestsAPI } from '@/services/api';
import {
  Search,
  Filter,
  Download,
  Eye,
  CheckCircle,
  XCircle,
  MapPin,
  Phone,
  Calendar,
  Droplet,
  AlertCircle,
} from 'lucide-react';
import { formatDate, getStatusColor, formatDateTime } from '@/utils/helpers';

export default function BloodRequests() {
  const [requests, setRequests] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [urgencyFilter, setUrgencyFilter] = useState('all');
  const [bloodGroupFilter, setBloodGroupFilter] = useState('all');
  const [selectedRequest, setSelectedRequest] = useState<any>(null);
  const [showModal, setShowModal] = useState(false);

  useEffect(() => {
    fetchRequests();
  }, [statusFilter]);

  const fetchRequests = async () => {
    try {
      setLoading(true);
      const response = await bloodRequestsAPI.getAll({
        status: statusFilter !== 'all' ? statusFilter : undefined,
      });
      setRequests(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch blood requests:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (requestId: string) => {
    try {
      await bloodRequestsAPI.approve(requestId);
      fetchRequests();
    } catch (error) {
      console.error('Failed to approve request:', error);
    }
  };

  const handleReject = async (requestId: string) => {
    const reason = prompt('Enter rejection reason:');
    if (reason) {
      try {
        await bloodRequestsAPI.reject(requestId, reason);
        fetchRequests();
      } catch (error) {
        console.error('Failed to reject request:', error);
      }
    }
  };

  const filteredRequests = requests.filter((request) => {
    const matchesSearch =
      request.patient_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      request.hospital_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      request.location?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesUrgency = urgencyFilter === 'all' || request.urgency_level === urgencyFilter;
    const matchesBloodGroup = bloodGroupFilter === 'all' || request.blood_group === bloodGroupFilter;

    return matchesSearch && matchesUrgency && matchesBloodGroup;
  });

  const getUrgencyColor = (urgency: string) => {
    const colors: Record<string, string> = {
      Urgent: 'badge-danger',
      Normal: 'badge-warning',
      Low: 'badge-neutral',
    };
    return colors[urgency] || 'badge-neutral';
  };

  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-neutral-900">Blood Donation Requests</h1>
            <p className="text-neutral-600 mt-1">
              Manage and approve blood donation requests
            </p>
          </div>
          <button className="btn-primary">
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
              <div className="p-3 bg-blue-100 rounded-lg">
                <Droplet className="w-6 h-6 text-blue-600" />
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
                <AlertCircle className="w-6 h-6 text-yellow-600" />
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
                <p className="text-sm text-neutral-600">Urgent Cases</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">
                  {requests.filter((r) => r.urgency_level === 'Urgent').length}
                </p>
              </div>
              <div className="p-3 bg-red-100 rounded-lg">
                <AlertCircle className="w-6 h-6 text-red-600" />
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
                placeholder="Search by patient, hospital, or location..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input-field pl-10 w-full"
              />
            </div>
            <div className="flex gap-3">
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="input-field min-w-[130px]"
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="approved">Approved</option>
                <option value="fulfilled">Fulfilled</option>
                <option value="cancelled">Cancelled</option>
              </select>
              <select
                value={urgencyFilter}
                onChange={(e) => setUrgencyFilter(e.target.value)}
                className="input-field min-w-[130px]"
              >
                <option value="all">All Urgency</option>
                <option value="Urgent">Urgent</option>
                <option value="Normal">Normal</option>
                <option value="Low">Low</option>
              </select>
              <select
                value={bloodGroupFilter}
                onChange={(e) => setBloodGroupFilter(e.target.value)}
                className="input-field min-w-[100px]"
              >
                <option value="all">All Groups</option>
                <option value="A+">A+</option>
                <option value="A-">A-</option>
                <option value="B+">B+</option>
                <option value="B-">B-</option>
                <option value="AB+">AB+</option>
                <option value="AB-">AB-</option>
                <option value="O+">O+</option>
                <option value="O-">O-</option>
              </select>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Patient
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Blood Group
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Hospital
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Urgency
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Units Needed
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
                      No blood requests found
                    </td>
                  </tr>
                ) : (
                  filteredRequests.map((request) => (
                    <tr key={request.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <div className="text-sm font-medium text-neutral-900">
                            {request.patient_name}
                          </div>
                          <div className="text-sm text-neutral-500">{request.mobile_number}</div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800">
                          <Droplet className="w-3 h-3 mr-1" />
                          {request.blood_group}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-neutral-900">{request.hospital_name}</div>
                        <div className="text-sm text-neutral-500 flex items-center mt-1">
                          <MapPin className="w-3 h-3 mr-1" />
                          {request.location}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`badge ${getUrgencyColor(request.urgency_level)}`}>
                          {request.urgency_level}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-900">
                        {request.blood_units} units
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
                                onClick={() => handleApprove(request.id)}
                                className="text-green-600 hover:text-green-900"
                              >
                                <CheckCircle className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => handleReject(request.id)}
                                className="text-red-600 hover:text-red-900"
                              >
                                <XCircle className="w-4 h-4" />
                              </button>
                            </>
                          )}
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
            <div className="relative bg-white rounded-xl shadow-strong max-w-3xl w-full p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-neutral-900">Blood Request Details</h3>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-neutral-400 hover:text-neutral-600"
                >
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <div className="grid grid-cols-2 gap-6">
                <div>
                  <label className="text-sm font-medium text-neutral-600">Patient Name</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.patient_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Blood Group</label>
                  <p className="mt-1">
                    <span className="badge bg-red-100 text-red-800">
                      {selectedRequest.blood_group}
                    </span>
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Mobile Number</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.mobile_number}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Case Type</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.case_type}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Hospital Name</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.hospital_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Location</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.location}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Blood Units Needed</label>
                  <p className="text-neutral-900 mt-1">{selectedRequest.blood_units} units</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Required Date</label>
                  <p className="text-neutral-900 mt-1">{formatDate(selectedRequest.required_date)}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Urgency Level</label>
                  <p className="mt-1">
                    <span className={`badge ${getUrgencyColor(selectedRequest.urgency_level)}`}>
                      {selectedRequest.urgency_level}
                    </span>
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
                {selectedRequest.additional_details && (
                  <div className="col-span-2">
                    <label className="text-sm font-medium text-neutral-600">Additional Details</label>
                    <p className="text-neutral-900 mt-1">{selectedRequest.additional_details}</p>
                  </div>
                )}
              </div>

              {selectedRequest.status === 'pending' && (
                <div className="flex gap-3 mt-6 pt-6 border-t border-neutral-200">
                  <button
                    onClick={() => {
                      handleApprove(selectedRequest.id);
                      setShowModal(false);
                    }}
                    className="flex-1 bg-green-600 text-white px-4 py-2.5 rounded-lg font-medium hover:bg-green-700 transition-colors"
                  >
                    <CheckCircle className="w-4 h-4 inline mr-2" />
                    Approve Request
                  </button>
                  <button
                    onClick={() => {
                      handleReject(selectedRequest.id);
                      setShowModal(false);
                    }}
                    className="flex-1 btn-danger"
                  >
                    <XCircle className="w-4 h-4 inline mr-2" />
                    Reject Request
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
}
