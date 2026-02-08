import axios from 'axios';
import type { Patient, CreatePatientDTO, UpdatePatientDTO, LoginCredentials, RegisterCredentials, AuthResponse } from '@/types';

// Prefer gateway URLs so CORS and JWT validation happen in one place.
// If no env vars are set, we use relative paths and let Next.js rewrites proxy to the gateway.
const API_GATEWAY = process.env.NEXT_PUBLIC_API_GATEWAY_URL ?? '';
const AUTH_BASE = process.env.NEXT_PUBLIC_AUTH_SERVICE_URL ?? API_GATEWAY;

// Create axios instance
const apiClient = axios.create({
  baseURL: API_GATEWAY,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
apiClient.interceptors.request.use((config) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('jwt_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }
  return config;
});

// Auth API
export const authAPI = {
  login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const response = await axios.post(`${AUTH_BASE}/auth/login`, credentials);
    return response.data;
  },

  register: async (credentials: RegisterCredentials): Promise<AuthResponse> => {
    const response = await axios.post(`${AUTH_BASE}/auth/register`, credentials);
    return response.data;
  },
  
  validateToken: async (token: string): Promise<boolean> => {
    try {
      await axios.get(`${AUTH_BASE}/auth/validate`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      return true;
    } catch {
      return false;
    }
  },

  forgotPassword: async (email: string, newPassword: string): Promise<void> => {
    await axios.post(`${AUTH_BASE}/auth/forgot-password`, { email, newPassword });
  },

  changePassword: async (currentPassword: string, newPassword: string): Promise<void> => {
    await apiClient.post('/auth/change-password', { currentPassword, newPassword });
  }
};

// Patient API
export const patientAPI = {
  getAll: async (): Promise<Patient[]> => {
    const response = await apiClient.get('/api/patients');
    return response.data;
  },

  getById: async (id: string): Promise<Patient> => {
    const response = await apiClient.get(`/api/patients/${id}`);
    return response.data;
  },

  create: async (patient: CreatePatientDTO): Promise<Patient> => {
    const response = await apiClient.post('/api/patients', patient);
    return response.data;
  },

  update: async (id: string, patient: UpdatePatientDTO): Promise<Patient> => {
    const response = await apiClient.put(`/api/patients/${id}`, patient);
    return response.data;
  },

  delete: async (id: string): Promise<void> => {
    await apiClient.delete(`/api/patients/${id}`);
  }
};