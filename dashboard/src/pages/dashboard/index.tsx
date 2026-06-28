import { useEffect, useState } from 'react';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import { dashboardAPI } from '@/services/api';
import { formatCurrency } from '@/utils/helpers';
import {
  Users,
  Droplet,
  GraduationCap,
  Heart,
  Wallet,
  Clock,
  CheckCircle,
  AlertCircle,
} from 'lucide-react';
import {
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';

const COLORS = ['#2A9D8F', '#FFC107', '#3B82F6', '#E01219'];

const EMPTY_STATS = {
  cards: {
    users: { total: 0, pending: 0 },
    blood: { total: 0, pending: 0 },
    education: { total: 0, pending: 0 },
    family: { total: 0, pending: 0 },
  },
  funds: { total_raised: 0, donations_count: 0 },
  statusDistribution: { approved: 0, pending: 0, fulfilled: 0 },
  pendingApprovals: { users: 0, blood: 0, education: 0, family: 0 },
  monthly: [] as any[],
};

export default function Dashboard() {
  const [stats, setStats] = useState<any>(EMPTY_STATS);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const response = await dashboardAPI.getStats();
      setStats(response.data.data || EMPTY_STATS);
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
      setStats(EMPTY_STATS);
    } finally {
      setLoading(false);
    }
  };

  const cards = stats?.cards || EMPTY_STATS.cards;
  const funds = stats?.funds || EMPTY_STATS.funds;
  const statusDistribution = stats?.statusDistribution || EMPTY_STATS.statusDistribution;
  const pendingApprovals = stats?.pendingApprovals || EMPTY_STATS.pendingApprovals;
  const monthlyData = stats?.monthly || EMPTY_STATS.monthly;

  const statusData = [
    { name: 'Approved', value: statusDistribution.approved || 0 },
    { name: 'Pending', value: statusDistribution.pending || 0 },
    { name: 'Fulfilled', value: statusDistribution.fulfilled || 0 },
  ];

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-96">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500"></div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-neutral-900">Dashboard Overview</h1>
          <p className="text-neutral-600 mt-1">Welcome back! Here's what's happening today.</p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5">
          <StatCard
            title="Total Users"
            value={cards.users.total.toLocaleString()}
            change={`${cards.users.pending} pending approval`}
            changeType="neutral"
            icon={Users}
            iconBgColor="bg-blue-100"
            iconColor="text-blue-600"
          />
          <StatCard
            title="Blood Requests"
            value={cards.blood.total.toLocaleString()}
            change={`${cards.blood.pending} pending`}
            changeType="neutral"
            icon={Droplet}
            iconBgColor="bg-red-100"
            iconColor="text-red-600"
          />
          <StatCard
            title="Education Support"
            value={cards.education.total.toLocaleString()}
            change={`${cards.education.pending} pending`}
            changeType="neutral"
            icon={GraduationCap}
            iconBgColor="bg-green-100"
            iconColor="text-green-600"
          />
          <StatCard
            title="Family Support"
            value={cards.family.total.toLocaleString()}
            change={`${cards.family.pending} pending`}
            changeType="neutral"
            icon={Heart}
            iconBgColor="bg-yellow-100"
            iconColor="text-yellow-600"
          />
          <StatCard
            title="Funds Raised"
            value={formatCurrency(funds.total_raised || 0)}
            change={`${funds.donations_count || 0} donations`}
            changeType="increase"
            icon={Wallet}
            iconBgColor="bg-primary-100"
            iconColor="text-primary-600"
          />
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <div className="card p-6">
            <h2 className="text-lg font-semibold text-neutral-900 mb-4">
              Monthly Requests Trend
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={monthlyData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e5e5" />
                <XAxis dataKey="month" stroke="#737373" />
                <YAxis stroke="#737373" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#fff',
                    border: '1px solid #e5e5e5',
                    borderRadius: '8px',
                  }}
                />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="blood"
                  stroke="#E01219"
                  strokeWidth={2}
                  name="Blood Donations"
                />
                <Line
                  type="monotone"
                  dataKey="education"
                  stroke="#2A9D8F"
                  strokeWidth={2}
                  name="Education"
                />
                <Line
                  type="monotone"
                  dataKey="family"
                  stroke="#FFC107"
                  strokeWidth={2}
                  name="Family Support"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="card p-6">
            <h2 className="text-lg font-semibold text-neutral-900 mb-4">
              Request Status Distribution
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={statusData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {statusData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 card p-6">
            <h2 className="text-lg font-semibold text-neutral-900 mb-6">Quick Actions</h2>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <button className="btn-primary justify-center">
                <CheckCircle className="w-5 h-5 mr-2" />
                Approve Pending
              </button>
              <button className="btn-secondary justify-center">
                <Clock className="w-5 h-5 mr-2" />
                Review Requests
              </button>
              <button className="btn-secondary justify-center">
                <AlertCircle className="w-5 h-5 mr-2" />
                Urgent Cases
              </button>
            </div>
          </div>

          <div className="card p-6">
            <h3 className="text-sm font-semibold text-neutral-900 mb-4">Pending Approvals</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm text-neutral-600">New Users</span>
                <span className="badge badge-warning">{pendingApprovals.users || 0}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-neutral-600">Blood Requests</span>
                <span className="badge badge-danger">{pendingApprovals.blood || 0}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-neutral-600">Education</span>
                <span className="badge badge-info">{pendingApprovals.education || 0}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-neutral-600">Family Support</span>
                <span className="badge badge-warning">{pendingApprovals.family || 0}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
