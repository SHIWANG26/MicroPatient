'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authAPI } from '@/lib/api';
import type { LoginCredentials, RegisterCredentials } from '@/types';

interface AuthContextType {
  isAuthenticated: boolean;
  user: { email: string } | null;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (credentials: RegisterCredentials) => Promise<void>;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState<{ email: string } | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('jwt_token');
    const email = localStorage.getItem('user_email');
    
    if (token && email) {
      authAPI.validateToken(token).then((valid) => {
        if (valid) {
          setIsAuthenticated(true);
          setUser({ email });
        } else {
          localStorage.removeItem('jwt_token');
          localStorage.removeItem('user_email');
        }
        setLoading(false);
      });
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (credentials: LoginCredentials) => {
    const response = await authAPI.login(credentials);
    localStorage.setItem('jwt_token', response.token);
    localStorage.setItem('user_email', credentials.email);
    setIsAuthenticated(true);
    setUser({ email: credentials.email });
  };

  const register = async (credentials: RegisterCredentials) => {
    const response = await authAPI.register(credentials);
    localStorage.setItem('jwt_token', response.token);
    localStorage.setItem('user_email', credentials.email);
    setIsAuthenticated(true);
    setUser({ email: credentials.email });
  };

  const logout = () => {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('user_email');
    setIsAuthenticated(false);
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, user, login, register, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}