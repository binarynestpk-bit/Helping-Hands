import { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { donationProofsAPI } from '@/services/api';
import {
  Search,
  Eye,
  CheckCircle,
  XCircle,
  HandCoins,
  Clock,
  DollarSign,
} from 'lucide-react';
import { formatDate, getStatusColor, formatCurrency } from '@/utils/helpers';
import { useToast } from '@/components/Toast';

const TYPE_LABEL: Record<string, string> = {
  education: 'Education',
  family: 'Family',
  general: 'General (Zakat/Sadaqah)',
};

export default function DonationProofs() {
  const { showToast } = useToast();
  const [proofs, setProofs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('pending');
  const [selected, setSelected] = useState<any>(null);
  const [showModal, setShowModal] = useState(false);
  const [editAmount, setEditAmount] = useState('');
  const [note, setNote] = useState('');
  const [working, setWorking] = useState(false);

  useEffect(() => {
    fetchProofs();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter]);

  const fetchProofs = async () => {
    try {
      setLoading(true);
      const res = await donationProofsAPI.getAll({
        status: statusFilter !== 'all' ? statusFilter : undefined,
      });
      setProofs(res.data.data || []);
    } catch (error) {
      console.error('Failed to fetch donation proofs:', error);
    } finally {
      setLoading(false);
    }
  };

  const causeTitle = (p: any) => {
    if (p.donation_type === 'general') return 'General donation';
    const r = p.request;
    if (!r) return `${TYPE_LABEL[p.donation_type] || p.donation_type} request`;
    if (p.donation_type === 'education') return r.student_name || r.institution_name || 'Education request';
    return r.deceased_name || r.martyr_name || r.family_head_name || r.family_name || 'Family request';
  };

  const causeTarget = (p: any) => {
    const r = p.request;
    if (!r) return null;
    if (p.donation_type === 'education' && r.fee_amount != null) return parseFloat(r.fee_amount);
    if (p.donation_type === 'family' && r.monthly_need != null) return parseFloat(r.monthly_need);
    return null;
  };

  const openModal = (p: any) => {
    setSelected(p);
    setEditAmount(p.amount != null ? String(parseFloat(p.amount)) : '');
    setNote('');
    setShowModal(true);
  };

  const handleApprove = async () => {
    if (!selected) return;
    const amt = parseFloat(editAmount);
    if (!amt || amt <= 0) {
      showToast('Enter a valid verified amount', 'error');
      return;
    }
    try {
      setWorking(true);
      await donationProofsAPI.approve(selected.id, { amount: amt, note: note || undefined });
      showToast('Donation approved and added to the cause', 'success');
      setShowModal(false);
      fetchProofs();
    } catch (error) {
      console.error('Failed to approve donation:', error);
      showToast('Failed to approve — please try again', 'error');
    } finally {
      setWorking(false);
    }
  };

  const handleReject = async () => {
    if (!selected) return;
    try {
      setWorking(true);
      await donationProofsAPI.reject(selected.id, note || undefined);
      showToast('Donation proof rejected', 'success');
      setShowModal(false);
      fetchProofs();
    } catch (error) {
      console.error('Failed to reject donation:', error);
      showToast('Failed to reject — please try again', 'error');
    } finally {
      setWorking(false);
    }
  };

  const filtered = proofs.filter(
    (p) =>
      (p.donor_name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (p.donor_email || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      causeTitle(p).toLowerCase().includes(searchTerm.toLowerCase())
  );

  const pendingCount = proofs.filter((p) => p.status === 'pending').length;
  const approvedCount = proofs.filter((p) => p.status === 'approved').length;
  const approvedAmount = proofs
    .filter((p) => p.status === 'approved')
    .reduce((sum, p) => sum + parseFloat(p.amount || 0), 0);

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-neutral-900">Donation Proofs</h1>
          <p className="text-neutral-600 mt-1">
            Review bank-transfer receipts and confirm donations. Approving adds the amount to the cause.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Pending Review</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">{pendingCount}</p>
              </div>
              <div className="p-3 bg-yellow-100 rounded-lg">
                <Clock className="w-6 h-6 text-yellow-600" />
              </div>
            </div>
          </div>
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Approved</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">{approvedCount}</p>
              </div>
              <div className="p-3 bg-green-100 rounded-lg">
                <CheckCircle className="w-6 h-6 text-green-600" />
              </div>
            </div>
          </div>
          <div className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-neutral-600">Approved Amount</p>
                <p className="text-2xl font-bold text-neutral-900 mt-1">{formatCurrency(approvedAmount)}</p>
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
                placeholder="Search by donor or cause..."
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
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
              <option value="all">All</option>
            </select>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-neutral-200">
              <thead>
                <tr className="bg-neutral-50">
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Donor</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Type</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Cause</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Amount</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-neutral-600 uppercase tracking-wider">Date</th>
                  <th className="px-6 py-3 text-right text-xs font-semibold text-neutral-600 uppercase tracking-wider">Actions</th>
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
                ) : filtered.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-6 py-12 text-center text-neutral-500">
                      No donation proofs found
                    </td>
                  </tr>
                ) : (
                  filtered.map((p) => (
                    <tr key={p.id} className="hover:bg-neutral-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-neutral-900">{p.donor_name || '—'}</div>
                        <div className="text-sm text-neutral-500">{p.donor_email || p.donor_mobile || ''}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="badge badge-info">{TYPE_LABEL[p.donation_type] || p.donation_type}</span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-neutral-900 max-w-xs truncate">{causeTitle(p)}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-neutral-900">
                        {formatCurrency(parseFloat(p.amount))}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`badge badge-${getStatusColor(p.status)}`}>{p.status}</span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">{formatDate(p.created_at)}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <button onClick={() => openModal(p)} className="text-primary-600 hover:text-primary-900 inline-flex items-center gap-1">
                          <Eye className="w-4 h-4" /> Review
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {showModal && selected && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen px-4">
            <div className="fixed inset-0 bg-neutral-900 bg-opacity-50" onClick={() => setShowModal(false)}></div>
            <div className="relative bg-white rounded-xl shadow-strong max-w-3xl w-full p-6 max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-neutral-900">Donation Proof</h3>
                <button onClick={() => setShowModal(false)} className="text-neutral-400 hover:text-neutral-600">
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Left: details */}
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Donor</label>
                    <p className="text-neutral-900 mt-1">{selected.donor_name || '—'}</p>
                    <p className="text-sm text-neutral-500">{selected.donor_email}</p>
                    <p className="text-sm text-neutral-500">{selected.donor_mobile}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Type</label>
                    <p className="mt-1"><span className="badge badge-info">{TYPE_LABEL[selected.donation_type] || selected.donation_type}</span></p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Cause</label>
                    <p className="text-neutral-900 mt-1">{causeTitle(selected)}</p>
                    {causeTarget(selected) != null && (
                      <p className="text-sm text-neutral-500">Target: {formatCurrency(causeTarget(selected)!)}</p>
                    )}
                  </div>
                  {selected.account_label && (
                    <div>
                      <label className="text-sm font-medium text-neutral-600">Paid to</label>
                      <p className="text-neutral-900 mt-1">{selected.account_label}</p>
                    </div>
                  )}
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Donor-reported amount</label>
                    <p className="text-neutral-900 mt-1 font-semibold text-lg">{formatCurrency(parseFloat(selected.amount))}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Submitted</label>
                    <p className="text-neutral-900 mt-1">{formatDate(selected.created_at)}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-neutral-600">Status</label>
                    <p className="mt-1"><span className={`badge badge-${getStatusColor(selected.status)}`}>{selected.status}</span></p>
                    {selected.admin_note && <p className="text-sm text-neutral-500 mt-1">Note: {selected.admin_note}</p>}
                  </div>
                </div>

                {/* Right: screenshot */}
                <div>
                  <label className="text-sm font-medium text-neutral-600">Transaction screenshot</label>
                  <div className="mt-2">
                    {selected.proof_url ? (
                      <a href={selected.proof_url} target="_blank" rel="noopener noreferrer">
                        <img
                          src={selected.proof_url}
                          alt="Transaction screenshot"
                          className="w-full max-h-[420px] object-contain rounded-lg border border-neutral-200 hover:opacity-90 transition-opacity bg-neutral-50"
                        />
                      </a>
                    ) : (
                      <p className="text-sm text-neutral-500">No screenshot provided.</p>
                    )}
                    <p className="text-xs text-neutral-400 mt-1">Tap the image to open full size.</p>
                  </div>
                </div>
              </div>

              {selected.status === 'pending' && (
                <div className="mt-6 pt-6 border-t border-neutral-200 space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="text-sm font-medium text-neutral-600">Verified amount (PKR)</label>
                      <input
                        type="number"
                        value={editAmount}
                        onChange={(e) => setEditAmount(e.target.value)}
                        className="input-field w-full mt-1"
                        placeholder="Amount to record"
                      />
                      <p className="text-xs text-neutral-400 mt-1">Adjust if the screenshot shows a different amount.</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-neutral-600">Note (optional)</label>
                      <input
                        type="text"
                        value={note}
                        onChange={(e) => setNote(e.target.value)}
                        className="input-field w-full mt-1"
                        placeholder="Reason / remark"
                      />
                    </div>
                  </div>
                  <div className="flex gap-3">
                    <button
                      onClick={handleApprove}
                      disabled={working}
                      className="flex-1 bg-green-600 text-white px-4 py-2.5 rounded-lg font-medium hover:bg-green-700 transition-colors disabled:opacity-60"
                    >
                      <CheckCircle className="w-4 h-4 inline mr-2" />
                      Approve &amp; Record
                    </button>
                    <button
                      onClick={handleReject}
                      disabled={working}
                      className="flex-1 bg-red-600 text-white px-4 py-2.5 rounded-lg font-medium hover:bg-red-700 transition-colors disabled:opacity-60"
                    >
                      <XCircle className="w-4 h-4 inline mr-2" />
                      Reject
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
}
