'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authAPI } from '@/lib/api';
import type { LoginCredentials } from '@/types';

interface AuthContextType {
  isAuthenticated: boolean;
  user: { email: string } | null;
  login: (credentials: LoginCredentials) => Promise<void>;
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
    // Backend returns only a token; keep the email from the login form for UI display.
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
    <AuthContext.Provider value={{ isAuthenticated, user, login, logout, loading }}>
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