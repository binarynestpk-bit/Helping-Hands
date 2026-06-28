import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { usersAPI } from '@/services/api';
import {
  Search,
  Filter,
  Download,
  Eye,
  CheckCircle,
  XCircle,
  Ban,
  MoreVertical,
  ChevronLeft,
  ChevronRight,
  Trash2,
} from 'lucide-react';
import { formatDate, getStatusColor } from '@/utils/helpers';
import { exportToCsv, csvDateStamp } from '@/utils/exportCsv';
import { useToast } from '@/components/Toast';
import ConfirmDialog from '@/components/ConfirmDialog';

export default function UsersManagement() {
  const { showToast } = useToast();
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedUser, setSelectedUser] = useState<any>(null);
  const [showModal, setShowModal] = useState(false);
  const [confirmState, setConfirmState] = useState<{ mode: 'approve' | 'reject' | 'delete'; id: string } | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    fetchUsers();
  }, [statusFilter]);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await usersAPI.getAll({ status: statusFilter !== 'all' ? statusFilter : undefined });
      setUsers(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch users:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (userId: string) => {
    try {
      await usersAPI.approve(userId);
      showToast('User approved', 'success');
      fetchUsers();
    } catch (error) {
      console.error('Failed to approve user:', error);
      showToast('Failed to approve — please try again', 'error');
    }
  };

  const handleReject = async (userId: string, reason: string) => {
    try {
      await usersAPI.reject(userId, reason);
      showToast('User rejected', 'success');
      fetchUsers();
    } catch (error) {
      console.error('Failed to reject user:', error);
      showToast('Failed to reject — please try again', 'error');
    }
  };

  const handleDelete = async (userId: string) => {
    try {
      await usersAPI.delete(userId);
      showToast('Record deleted', 'success');
      fetchUsers();
    } catch (error) {
      console.error('Failed to delete user:', error);
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

  const filteredUsers = users.filter((user) =>
    user.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.phone?.includes(searchTerm)
  );

  const handleExport = () => {
    exportToCsv(`users-${csvDateStamp()}.csv`, filteredUsers, [
      { key: 'full_name', label: 'Full Name' },
      { key: 'email', label: 'Email' },
      { key: 'phone', label: 'Phone' },
      { key: 'city', label: 'City' },
      { key: 'blood_group', label: 'Blood Group' },
      { key: 'status', label: 'Status' },
      { key: 'created_at', label: 'Created At' },
    ]);
  };

  const paginatedUsers = filteredUsers.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);

  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-neutral-900">User Management</h1>
            <p className="text-neutral-600 mt-1">Manage and approve user registrations</p>
          </div>
          <button onClick={handleExport} className="btn-primary">
            <Download className="w-4 h-4 mr-2" />
            Export Data
          </button>
        </div>

        <div className="card p-6">
          <div className="flex flex-col sm:flex-row gap-4 mb-6">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-neutral-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Search users by name, email, or phone..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input-field pl-10 w-full"
              />
            </div>
            <div className="flex gap-3">
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="input-field min-w-[150px]"
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="approved">Approved</option>
                <option value="rejected">Rejected</option>
                <option value="suspended">Suspended</option>
              </select>
              <button className="btn-secondary">
                <Filter className="w-4 h-4" />
              </button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    User
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Contact
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Location
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Blood Group
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">
                    Registered
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
                ) : paginatedUsers.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-6 py-12 text-center text-neutral-500">
                      No users found
                    </td>
                  </tr>
                ) : (
                  paginatedUsers.map((user) => (
                    <tr key={user.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="flex-shrink-0 h-10 w-10">
                            <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center text-primary-600 font-semibold">
                              {user.full_name?.charAt(0).toUpperCase()}
                            </div>
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-neutral-900">
                              {user.full_name}
                            </div>
                            <div className="text-sm text-neutral-500">ID: {user.id.slice(0, 8)}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-neutral-900">{user.email || 'N/A'}</div>
                        <div className="text-sm text-neutral-500">{user.phone || 'N/A'}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-900">
                        {user.city || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="badge badge-info">{user.blood_group || 'N/A'}</span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`badge badge-${getStatusColor(user.status)}`}>
                          {user.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                        {formatDate(user.created_at)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => {
                              setSelectedUser(user);
                              setShowModal(true);
                            }}
                            className="text-primary-600 hover:text-primary-900"
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                          {user.status === 'pending' && (
                            <>
                              <button
                                onClick={() => setConfirmState({ mode: 'approve', id: user.id })}
                                className="text-green-600 hover:text-green-900"
                              >
                                <CheckCircle className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => setConfirmState({ mode: 'reject', id: user.id })}
                                className="text-red-600 hover:text-red-900"
                              >
                                <XCircle className="w-4 h-4" />
                              </button>
                            </>
                          )}
                          <button
                            onClick={() => setConfirmState({ mode: 'delete', id: user.id })}
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

          {totalPages > 1 && (
            <div className="flex items-center justify-between mt-6 pt-6 border-t border-neutral-200">
              <div className="text-sm text-neutral-600">
                Showing {(currentPage - 1) * itemsPerPage + 1} to{' '}
                {Math.min(currentPage * itemsPerPage, filteredUsers.length)} of {filteredUsers.length} users
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                  className="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
                {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                  <button
                    key={page}
                    onClick={() => setCurrentPage(page)}
                    className={`px-3 py-2 rounded-lg font-medium transition-all ${
                      currentPage === page
                        ? 'bg-primary-500 text-white'
                        : 'bg-white text-neutral-700 hover:bg-neutral-50 border border-neutral-200'
                    }`}
                  >
                    {page}
                  </button>
                ))}
                <button
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                  className="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {showModal && selectedUser && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen px-4">
            <div
              className="fixed inset-0 bg-neutral-900 bg-opacity-50 transition-opacity"
              onClick={() => setShowModal(false)}
            ></div>
            <div className="relative bg-white rounded-xl shadow-strong max-w-3xl w-full p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-neutral-900">User Details</h3>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-neutral-400 hover:text-neutral-600"
                >
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <div className="grid grid-cols-2 gap-6">
                <div>
                  <label className="text-sm font-medium text-neutral-600">Full Name</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.full_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Father's Name</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.father_name || 'N/A'}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Email</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.email || 'N/A'}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Phone</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.phone || 'N/A'}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">CNIC</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.cnic || 'N/A'}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Blood Group</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.blood_group || 'N/A'}</p>
                </div>
                <div className="col-span-2">
                  <label className="text-sm font-medium text-neutral-600">Current Address</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.current_address || 'N/A'}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">City</label>
                  <p className="text-neutral-900 mt-1">{selectedUser.city || 'N/A'}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-neutral-600">Status</label>
                  <p className="mt-1">
                    <span className={`badge badge-${getStatusColor(selectedUser.status)}`}>
                      {selectedUser.status}
                    </span>
                  </p>
                </div>

                {(selectedUser.profile_image_url ||
                  selectedUser.cnic_front_image_url ||
                  selectedUser.cnic_back_image_url) && (
                  <div className="col-span-2">
                    <label className="text-sm font-medium text-neutral-600">Documents</label>
                    <div className="flex flex-wrap gap-4 mt-2">
                      {selectedUser.profile_image_url && (
                        <div>
                          <p className="text-xs text-neutral-500 mb-1">Profile Photo</p>
                          <a
                            href={selectedUser.profile_image_url}
                            target="_blank"
                            rel="noopener noreferrer"
                          >
                            <img
                              src={selectedUser.profile_image_url}
                              alt="Profile Photo"
                              className="w-[120px] h-[120px] object-cover rounded-lg border border-neutral-200 hover:opacity-90 transition-opacity"
                            />
                          </a>
                        </div>
                      )}
                      {selectedUser.cnic_front_image_url && (
                        <div>
                          <p className="text-xs text-neutral-500 mb-1">CNIC Front</p>
                          <a
                            href={selectedUser.cnic_front_image_url}
                            target="_blank"
                            rel="noopener noreferrer"
                          >
                            <img
                              src={selectedUser.cnic_front_image_url}
                              alt="CNIC Front"
                              className="w-[120px] h-[120px] object-cover rounded-lg border border-neutral-200 hover:opacity-90 transition-opacity"
                            />
                          </a>
                        </div>
                      )}
                      {selectedUser.cnic_back_image_url && (
                        <div>
                          <p className="text-xs text-neutral-500 mb-1">CNIC Back</p>
                          <a
                            href={selectedUser.cnic_back_image_url}
                            target="_blank"
                            rel="noopener noreferrer"
                          >
                            <img
                              src={selectedUser.cnic_back_image_url}
                              alt="CNIC Back"
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
                {selectedUser.status === 'pending' && (
                  <>
                    <button
                      onClick={() => setConfirmState({ mode: 'approve', id: selectedUser.id })}
                      className="flex-1 bg-green-600 text-white px-4 py-2.5 rounded-lg font-medium hover:bg-green-700 transition-colors"
                    >
                      <CheckCircle className="w-4 h-4 inline mr-2" />
                      Approve User
                    </button>
                    <button
                      onClick={() => setConfirmState({ mode: 'reject', id: selectedUser.id })}
                      className="flex-1 btn-danger"
                    >
                      <XCircle className="w-4 h-4 inline mr-2" />
                      Reject User
                    </button>
                  </>
                )}
                <button
                  onClick={() => setConfirmState({ mode: 'delete', id: selectedUser.id })}
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
        title={
          confirmState?.mode === 'delete'
            ? 'Delete User'
            : confirmState?.mode === 'reject'
            ? 'Reject User'
            : 'Approve User'
        }
        message={
          confirmState?.mode === 'delete'
            ? 'Are you sure you want to delete this user? This action is permanent and cannot be undone.'
            : confirmState?.mode === 'reject'
            ? 'Are you sure you want to reject this user? Please provide a reason below.'
            : 'Are you sure you want to approve this user? This will grant them access to the platform.'
        }
        onCancel={() => setConfirmState(null)}
        onConfirm={handleConfirm}
      />
    </Layout>
  );
}
