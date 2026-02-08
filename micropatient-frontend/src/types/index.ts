export interface Patient {
  id: string;
  name: string;
  email: string;
  address: string;
  dateOfBirth: string;
  registeredDate?: string;
}

export interface CreatePatientDTO {
  name: string;
  email: string;
  address: string;
  dateOfBirth: string;
  registeredDate: string;
}

export interface UpdatePatientDTO {
  name: string;
  email: string;
  address: string;
  dateOfBirth: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  token: string;
}