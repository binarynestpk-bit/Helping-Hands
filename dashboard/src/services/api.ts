import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/api';

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
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token');
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
};

export const usersAPI = {
  getAll: (params?: any) => apiClient.get('/admin/users', { params }),
  getById: (id: string) => apiClient.get(`/admin/users/${id}`),
  approve: (id: string) => apiClient.put(`/admin/users/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/users/${id}/reject`, { reason }),
  suspend: (id: string, reason: string) =>
    apiClient.put(`/admin/users/${id}/suspend`, { reason }),
};

export const bloodRequestsAPI = {
  getAll: (params?: any) => apiClient.get('/admin/blood-requests', { params }),
  getById: (id: string) => apiClient.get(`/admin/blood-requests/${id}`),
  approve: (id: string) => apiClient.put(`/admin/blood-requests/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/blood-requests/${id}/reject`, { reason }),
};

export const educationRequestsAPI = {
  getAll: (params?: any) => apiClient.get('/admin/education-requests', { params }),
  getById: (id: string) => apiClient.get(`/admin/education-requests/${id}`),
  approve: (id: string) => apiClient.put(`/admin/education-requests/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/education-requests/${id}/reject`, { reason }),
};

export const familyRequestsAPI = {
  getAll: (params?: any) => apiClient.get('/admin/family-requests', { params }),
  getById: (id: string) => apiClient.get(`/admin/family-requests/${id}`),
  approve: (id: string) => apiClient.put(`/admin/family-requests/${id}/approve`),
  reject: (id: string, reason: string) =>
    apiClient.put(`/admin/family-requests/${id}/reject`, { reason }),
};

export const dashboardAPI = {
  getStats: () => apiClient.get('/admin/dashboard/stats'),
  getRecentActivity: () => apiClient.get('/admin/dashboard/activity'),
  getChartData: (period: string) =>
    apiClient.get('/admin/dashboard/charts', { params: { period } }),
};

export default apiClient;
