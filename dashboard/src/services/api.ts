import axios from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://helpinghand-backend.vercel.app/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    // 401 = no/expired session, 403 = invalid token (e.g. stale token from an
    // older backend). Both mean the session is bad — force a fresh login instead
    // of silently showing empty data.
    const status = error.response?.status;
    if ((status === 401 || status === 403) && !error.config?.url?.includes('/login')) {
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_role');
      localStorage.removeItem('admin_user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: (credentials: { email: string; password: string }) =>
    apiClient.post('/admin/login', credentials),
  logout: () => apiClient.post('/admin/logout'),
  getProfile: () => apiClient.get('/admin/profile'),
  updateProfile: (data: any) => apiClient.put('/admin/profile', data),
  changePassword: (data: any) => apiClient.put('/admin/change-password', data),
};

export const notificationsAPI = {
  getAll: () => apiClient.get('/admin/notifications'),
};

export const usersAPI = {
  getAll: (params?: any) => apiClient.get('/admin/users', { params }),
  getById: (id: string) => apiClient.get(`/admin/users/${id}`),
  approve: (id: string) => apiClient.put(`/admin/users/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/users/${id}/reject`, { reason }),
  suspend: (id: string, reason: string) =>
    apiClient.put(`/admin/users/${id}/suspend`, { reason }),
  delete: (id: string) => apiClient.delete(`/admin/users/${id}`),
};

export const bloodRequestsAPI = {
  getAll: (params?: any) => apiClient.get('/admin/blood-requests', { params }),
  getById: (id: string) => apiClient.get(`/admin/blood-requests/${id}`),
  approve: (id: string) => apiClient.put(`/admin/blood-requests/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/blood-requests/${id}/reject`, { reason }),
  delete: (id: string) => apiClient.delete(`/admin/blood-requests/${id}`),
};

export const educationRequestsAPI = {
  getAll: (params?: any) => apiClient.get('/admin/education-requests', { params }),
  getById: (id: string) => apiClient.get(`/admin/education-requests/${id}`),
  approve: (id: string) => apiClient.put(`/admin/education-requests/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/education-requests/${id}/reject`, { reason }),
  delete: (id: string) => apiClient.delete(`/admin/education-requests/${id}`),
};

export const familyRequestsAPI = {
  getAll: (params?: any) => apiClient.get('/admin/family-requests', { params }),
  getById: (id: string) => apiClient.get(`/admin/family-requests/${id}`),
  approve: (id: string) => apiClient.put(`/admin/family-requests/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/family-requests/${id}/reject`, { reason }),
  delete: (id: string) => apiClient.delete(`/admin/family-requests/${id}`),
};

export const partnersAPI = {
  getAll: () => apiClient.get('/admin/partners'),
  create: (formData: FormData) => apiClient.post('/admin/partners', formData),
  update: (id: string, formData: FormData) => apiClient.put(`/admin/partners/${id}`, formData),
  delete: (id: string) => apiClient.delete(`/admin/partners/${id}`),
};

export const partnerApplicationsAPI = {
  getAll: () => apiClient.get('/admin/partner-applications'),
  updateStatus: (id: string, status: string) =>
    apiClient.put(`/admin/partner-applications/${id}/status`, { status }),
  delete: (id: string) => apiClient.delete(`/admin/partner-applications/${id}`),
};

export const deletionRequestsAPI = {
  getAll: () => apiClient.get('/admin/deletion-requests'),
  complete: (id: string) => apiClient.put(`/admin/deletion-requests/${id}/complete`),
  delete: (id: string) => apiClient.delete(`/admin/deletion-requests/${id}`),
};

export const donationProofsAPI = {
  getAll: (params?: any) => apiClient.get('/admin/donation-proofs', { params }),
  approve: (id: string, data?: { amount?: number | string; note?: string }) =>
    apiClient.post(`/admin/donation-proofs/${id}/approve`, data || {}),
  reject: (id: string, note?: string) =>
    apiClient.post(`/admin/donation-proofs/${id}/reject`, { note }),
};

export const donationAccountsAPI = {
  getAll: () => apiClient.get('/admin/donation-accounts'),
  create: (data: any) => apiClient.post('/admin/donation-accounts', data),
  update: (id: string, data: any) => apiClient.put(`/admin/donation-accounts/${id}`, data),
  delete: (id: string) => apiClient.delete(`/admin/donation-accounts/${id}`),
};

export const dashboardAPI = {
  getStats: () => apiClient.get('/admin/dashboard/stats'),
  getRecentActivity: () => apiClient.get('/admin/dashboard/activity'),
  getChartData: (period: string) =>
    apiClient.get('/admin/dashboard/charts', { params: { period } }),
};

export default apiClient;
