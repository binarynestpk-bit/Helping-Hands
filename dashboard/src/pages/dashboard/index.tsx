import { useEffect, useState } from 'react';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import { dashboardAPI } from '@/services/api';
import {
  Users,
  Droplet,
  GraduationCap,
  Heart,
  TrendingUp,
  Clock,
  CheckCircle,
  AlertCircle,
} from 'lucide-react';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
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

const COLORS = ['#2A9D8F', '#E01219', '#FFC107', '#3B82F6'];

export default function Dashboard() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const response = await dashboardAPI.getStats();
      setStats(response.data.data);
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const monthlyData = [
    { month: 'Jan', blood: 45, education: 32, family: 28 },
    { month: 'Feb', blood: 52, education: 38, family: 31 },
    { month: 'Mar', blood: 48, education: 45, family: 35 },
    { month: 'Apr', blood: 61, education: 52, family: 42 },
    { month: 'May', blood: 55, education: 48, family: 38 },
    { month: 'Jun', blood: 67, education: 55, family: 45 },
  ];

  const statusData = [
    { name: 'Approved', value: 324 },
    { name: 'Pending', value: 89 },
    { name: 'Fulfilled', value: 256 },
    { name: 'Rejected', value: 42 },
  ];

  const recentActivity = [
    {
      id: 1,
      type: 'user',
      action: 'New user registration',
      user: 'Ahmad Khan',
      time: '5 minutes ago',
    },
    {
      id: 2,
      type: 'blood',
      action: 'Blood request approved',
      user: 'Sara Ahmed',
      time: '12 minutes ago',
    },
    {
      id: 3,
      type: 'education',
      action: 'Education request funded',
      user: 'Ali Raza',
      time: '1 hour ago',
    },
    {
      id: 4,
      type: 'family',
      action: 'Family support approved',
      user: 'Fatima Shah',
      time: '2 hours ago',
    },
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

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          <StatCard
            title="Total Users"
            value="1,247"
            change="+12% from last month"
            changeType="increase"
            icon={Users}
            iconBgColor="bg-blue-100"
            iconColor="text-blue-600"
          />
          <StatCard
            title="Blood Requests"
            value="89"
            change="23 pending approval"
            changeType="neutral"
            icon={Droplet}
            iconBgColor="bg-red-100"
            iconColor="text-red-600"
          />
          <StatCard
            title="Education Support"
            value="156"
            change="+8% from last month"
            changeType="increase"
            icon={GraduationCap}
            iconBgColor="bg-green-100"
            iconColor="text-green-600"
          />
          <StatCard
            title="Family Support"
            value="73"
            change="15 active cases"
            changeType="neutral"
            icon={Heart}
            iconBgColor="bg-yellow-100"
            iconColor="text-yellow-600"
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
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-semibold text-neutral-900">Recent Activity</h2>
              <button className="text-sm font-medium text-primary-500 hover:text-primary-600">
                View all
              </button>
            </div>
            <div className="space-y-4">
              {recentActivity.map((activity) => (
                <div
                  key={activity.id}
                  className="flex items-start gap-4 p-4 bg-neutral-50 rounded-lg hover:bg-neutral-100 transition-colors"
                >
                  <div className="flex-shrink-0">
                    {activity.type === 'user' && (
                      <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                        <Users className="w-5 h-5 text-blue-600" />
                      </div>
                    )}
                    {activity.type === 'blood' && (
                      <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center">
                        <Droplet className="w-5 h-5 text-red-600" />
                      </div>
                    )}
                    {activity.type === 'education' && (
                      <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center">
                        <GraduationCap className="w-5 h-5 text-green-600" />
                      </div>
                    )}
                    {activity.type === 'family' && (
                      <div className="w-10 h-10 rounded-full bg-yellow-100 flex items-center justify-center">
                        <Heart className="w-5 h-5 text-yellow-600" />
                      </div>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-neutral-900">{activity.action}</p>
                    <p className="text-sm text-neutral-600">{activity.user}</p>
                  </div>
                  <div className="flex-shrink-0">
                    <p className="text-xs text-neutral-500">{activity.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="card p-6">
            <h2 className="text-lg font-semibold text-neutral-900 mb-6">Quick Actions</h2>
            <div className="space-y-3">
              <button className="w-full btn-primary justify-center">
                <CheckCircle className="w-5 h-5 mr-2" />
                Approve Pending
              </button>
              <button className="w-full btn-secondary justify-center">
                <Clock className="w-5 h-5 mr-2" />
                Review Requests
              </button>
              <button className="w-full btn-secondary justify-center">
                <AlertCircle className="w-5 h-5 mr-2" />
                Urgent Cases
              </button>
            </div>

            <div className="mt-8 pt-6 border-t border-neutral-200">
              <h3 className="text-sm font-semibold text-neutral-900 mb-4">Pending Approvals</h3>
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-neutral-600">New Users</span>
                  <span className="badge badge-warning">23</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-neutral-600">Blood Requests</span>
                  <span className="badge badge-danger">12</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-neutral-600">Education</span>
                  <span className="badge badge-info">8</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-neutral-600">Family Support</span>
                  <span className="badge badge-warning">5</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
