# Microservices Backend - Complete API Specification for React Frontend

## **Project Overview**

This is a **Patient Management Microservices System** with the following core functionalities:
- Patient registration and management
- Authentication and authorization
- Billing and transaction tracking
- Event streaming for analytics
- API Gateway for unified access

---

## **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────┐
│                     REACT FRONTEND                              │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────┐
        │    API GATEWAY (Port 4004)      │
        │  - Routes requests to services  │
        │  - JWT Token Validation         │
        └─────────────────────────────────┘
                  │            │
        ┌─────────┴────┐   ┌───┴──────────┐
        ▼              ▼   ▼              ▼
    ┌────────┐   ┌──────────┐   ┌──────────────┐
    │  AUTH  │   │ PATIENT  │   │   BILLING    │
    │SERVICE │   │ SERVICE  │   │   SERVICE    │
    │(4005)  │   │  (4000)  │   │   (4001)     │
    └────────┘   └──────────┘   └──────────────┘
        │            │               │
    ┌───┴───┐    ┌───┴───┐      ┌───┴────┐
    │ Auth  │    │Patient│      │Billing │
    │ DB    │    │  DB   │      │Service │
    │(5433) │    │(5432) │      │(gRPC)  │
    └───────┘    └───────┘      └────────┘
        
    ┌──────────────────────────┐
    │  KAFKA BROKER (9092)     │
    │  - patient-events topic  │
    │  - Consumed by Analytics │
    └──────────────────────────┘
```

---

## **1. PATIENT SERVICE (Port: 4000)**

### **1.1 Base URL**
```
Direct: http://localhost:4000
Via Gateway: http://localhost:4004/api
```

### **1.2 Data Model - Patient**

```json
{
  "id": "uuid-string",
  "name": "string (max 100 chars, required)",
  "email": "string (valid email, required, unique)",
  "address": "string (required)",
  "dateOfBirth": "YYYY-MM-DD (required)",
  "registeredDate": "YYYY-MM-DD (optional, auto-set on creation)"
}
```

### **1.3 Endpoints**

#### **A. Get All Patients**
```
GET /patients
```

**Request:**
```bash
curl -X GET http://localhost:4000/patients
```

**Response:** `200 OK`
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "address": "123 Main Street",
    "dateOfBirth": "1990-01-15",
    "registeredDate": "2026-01-22"
  },
  {
    "id": "650e8400-e29b-41d4-a716-446655440001",
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "address": "456 Oak Avenue",
    "dateOfBirth": "1985-06-10",
    "registeredDate": "2026-01-22"
  }
]
```

**Error Responses:**
- `500 Internal Server Error` - Database error

---

#### **B. Get Patient by ID**
```
GET /patients/{patientId}
```

**Request:**
```bash
curl -X GET http://localhost:4000/patients/550e8400-e29b-41d4-a716-446655440000
```

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "John Doe",
  "email": "john@example.com",
  "address": "123 Main Street",
  "dateOfBirth": "1990-01-15",
  "registeredDate": "2026-01-22"
}
```

**Error Responses:**
- `404 Not Found` - Patient does not exist

---

#### **C. Create New Patient**
```
POST /patients
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "address": "789 Pine Road",
  "dateOfBirth": "1992-03-20",
  "registeredDate": "2026-01-23"
}
```

**Request:**
```bash
curl -X POST http://localhost:4000/patients \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com",
    "address": "789 Pine Road",
    "dateOfBirth": "1992-03-20",
    "registeredDate": "2026-01-23"
  }'
```

**Response:** `200 OK`
```json
{
  "id": "750e8400-e29b-41d4-a716-446655440002",
  "name": "Jane Smith",
  "email": "jane@example.com",
  "address": "789 Pine Road",
  "dateOfBirth": "1992-03-20"
}
```

**Validation Errors:** `400 Bad Request`
```json
{
  "name": "Name is required",
  "email": "Email is required",
  "address": "Address is required",
  "dateOfBirth": "Date of birth is required",
  "registeredDate": "Registered date is required"
}
```

**Duplicate Email Error:** `409 Conflict`
```json
{
  "error": "Email already exists"
}
```

---

#### **D. Update Patient**
```
PUT /patients/{patientId}
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Jane Doe",
  "email": "jane.doe@example.com",
  "address": "999 Elm Street",
  "dateOfBirth": "1992-03-20"
}
```

**Request:**
```bash
curl -X PUT http://localhost:4000/patients/750e8400-e29b-41d4-a716-446655440002 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "address": "999 Elm Street",
    "dateOfBirth": "1992-03-20"
  }'
```

**Response:** `200 OK`
```json
{
  "id": "750e8400-e29b-41d4-a716-446655440002",
  "name": "Jane Doe",
  "email": "jane.doe@example.com",
  "address": "999 Elm Street",
  "dateOfBirth": "1992-03-20"
}
```

**Error Responses:**
- `404 Not Found` - Patient does not exist
- `400 Bad Request` - Validation failed
- `409 Conflict` - Email already exists

---

#### **E. Delete Patient**
```
DELETE /patients/{patientId}
```

**Request:**
```bash
curl -X DELETE http://localhost:4000/patients/750e8400-e29b-41d4-a716-446655440002
```

**Response:** `204 No Content` (empty body)

**Error Responses:**
- `404 Not Found` - Patient does not exist

---

## **2. AUTH SERVICE (Port: 4005)**

### **2.1 Base URL**
```
Direct: http://localhost:4005
Via Gateway: http://localhost:4004/auth
```

### **2.2 Data Model - User**

```json
{
  "id": "uuid-string",
  "email": "string (valid email, unique, required)",
  "password": "string (hashed in DB, min 8 chars)",
  "role": "ADMIN | USER"
}
```

### **2.3 Endpoints**

#### **A. User Login**
```
POST /login
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "testuser@test.com",
  "password": "password1234"
}
```

**Request:**
```bash
curl -X POST http://localhost:4005/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@test.com",
    "password": "password1234"
  }'
```

**Success Response:** `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMjNlNDU2Ny1lODliLTEyZDMtYTQ1Ni00MjY2MTQxNzQwMDYiLCJpYXQiOjE2NzcxNTI3NzAsImV4cCI6MTY3NzIzOTE3MH0...."
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid email or password

**Validation Errors:** `400 Bad Request`
```json
{
  "email": "Email is required",
  "password": "Password is required"
}
```

---

#### **B. Validate Token**
```
GET /validate
Authorization: Bearer <JWT_TOKEN>
```

**Request:**
```bash
curl -X GET http://localhost:4005/validate \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Success Response:** `200 OK` (no body)

**Error Responses:**
- `401 Unauthorized` - Invalid or expired token
- `401 Unauthorized` - Missing Authorization header

---

### **2.4 Test Credentials**

```
Email: testuser@test.com
Password: password1234
```

---

## **3. BILLING SERVICE (Port: 4001 REST, 9001 gRPC)**

### **3.1 Overview**
- Communicates with Patient Service via **gRPC** (port 9001)
- Provides REST API on port 4001
- Processes billing and transactions
- Consumes Kafka events from patient service

### **3.2 Business Logic**
- When a patient is created → Automatic billing account created
- When a patient is updated → Billing account updated
- When a patient is deleted → Billing account deactivated

---

## **4. ANALYTICS SERVICE**

### **4.1 Overview**
- Consumes events from Kafka topic: `patient-events`
- Tracks patient creation, update, deletion events
- No direct REST API (internal service)
- Triggered by Patient Service events

### **4.2 Event Flow**
```
Patient Created/Updated/Deleted
         ↓
    Publish to Kafka (patient-events topic)
         ↓
    Analytics Service Consumes
         ↓
    Logs/Stores Analytics Data
```

---

## **5. API GATEWAY (Port: 4004)**

### **5.1 Purpose**
- Single entry point for all microservices
- JWT token validation
- Request routing
- Load balancing

### **5.2 Gateway Routes**

| Path | Destination | Auth Required |
|------|-------------|---|
| `/auth/**` | Auth Service (4005) | No |
| `/api/patients/**` | Patient Service (4000) | Yes (JWT) |
| `/api-docs/patients` | Patient Service Docs | No |
| `/api-docs/auth` | Auth Service Docs | No |

### **5.3 Usage Example**

**Get patients through gateway:**
```bash
curl -X GET http://localhost:4004/api/patients \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>"
```

---

## **6. AUTHENTICATION & AUTHORIZATION**

### **6.1 JWT Token Structure**

```json
{
  "sub": "user-id",
  "iat": 1677152770,
  "exp": 1677239170
}
```

### **6.2 Token Usage**

All authenticated requests require:
```
Authorization: Bearer <JWT_TOKEN>
```

### **6.3 Authentication Flow**

```
1. User enters email & password in React form
   ↓
2. POST /login with credentials
   ↓
3. Receive JWT token in response
   ↓
4. Store token in localStorage/sessionStorage
   ↓
5. Include token in Authorization header for all requests
   ↓
6. Gateway validates token
   ↓
7. Request reaches service if valid
   ↓
8. On token expiry, user logs out
```

---

## **7. DATA RELATIONSHIPS**

```
User (Auth Service)
  ├── Can create/read patients
  └── Can update/delete own patients

Patient (Patient Service)
  ├── Has unique email
  ├── Connected to Billing Account (via gRPC)
  ├── Publishes events to Kafka
  └── Events consumed by Analytics Service
```

---

## **8. COMPLETE API REFERENCE TABLE**

| Service | Method | Endpoint | Auth | Purpose |
|---------|--------|----------|------|---------|
| Patient | GET | /patients | No | List all patients |
| Patient | GET | /patients/{id} | No | Get patient details |
| Patient | POST | /patients | No | Create patient |
| Patient | PUT | /patients/{id} | No | Update patient |
| Patient | DELETE | /patients/{id} | No | Delete patient |
| Auth | POST | /login | No | User login |
| Auth | GET | /validate | Yes | Validate JWT token |
| Gateway | GET | /api/patients | Yes | List patients (via gateway) |
| Gateway | POST | /api/patients | Yes | Create patient (via gateway) |
| Gateway | PUT | /api/patients/{id} | Yes | Update patient (via gateway) |
| Gateway | DELETE | /api/patients/{id} | Yes | Delete patient (via gateway) |

---

## **9. ERROR HANDLING**

### **Common HTTP Status Codes**

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | OK | Successful GET, POST, PUT |
| 201 | Created | Resource created |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation error |
| 401 | Unauthorized | Invalid token or credentials |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate email |
| 500 | Server Error | Internal error |

### **Example Error Response**

```json
{
  "timestamp": "2026-01-22T18:50:50.454+00:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Name is required",
  "path": "/patients"
}
```

---

## **10. FRONTEND REQUIREMENTS**

### **10.1 Pages Needed**

1. **Login Page**
   - Email input field
   - Password input field
   - Login button
   - Display error messages
   - Store JWT token on success

2. **Patient List Page**
   - Display all patients in table/cards
   - Show: ID, Name, Email, Address, DOB, Registered Date
   - Search/filter functionality
   - Action buttons: View, Edit, Delete

3. **Patient Details Page**
   - Show all patient information
   - Edit button
   - Delete button
   - Back button

4. **Create Patient Form**
   - Input fields: Name, Email, Address, DOB, Registered Date
   - Validation messages
   - Submit button
   - Cancel button

5. **Edit Patient Form**
   - Pre-populate form with current data
   - Update button
   - Cancel button

### **10.2 Features to Implement**

1. **Authentication**
   - Login with email/password
   - JWT token storage
   - Token validation
   - Logout functionality

2. **Patient Management**
   - CRUD operations
   - Form validation
   - Error handling
   - Success notifications

3. **UI Components**
   - Navigation bar (with logout)
   - Forms with validation
   - Tables/Cards for patient list
   - Modal dialogs for confirmations
   - Loading spinners
   - Toast notifications

4. **State Management**
   - Authentication state
   - Patient list state
   - Current patient state
   - Loading states
   - Error states

---

## **11. DATABASE SCHEMAS**

### **Patient Table**
```sql
CREATE TABLE patient (
  id UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  address VARCHAR(255) NOT NULL,
  date_of_birth DATE NOT NULL,
  registered_date DATE
);
```

### **Users Table (Auth Service)**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL
);
```

---

## **12. EXAMPLE REACT FLOW**

```javascript
// 1. User logs in
const handleLogin = async (email, password) => {
  const response = await fetch('http://localhost:4005/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  const { token } = await response.json();
  localStorage.setItem('jwtToken', token);
  navigate('/patients');
};

// 2. Get all patients
const fetchPatients = async () => {
  const token = localStorage.getItem('jwtToken');
  const response = await fetch('http://localhost:4000/patients', {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  const patients = await response.json();
  setPatients(patients);
};

// 3. Create patient
const handleCreatePatient = async (formData) => {
  const response = await fetch('http://localhost:4000/patients', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData)
  });
  const newPatient = await response.json();
  setPatients([...patients, newPatient]);
};

// 4. Update patient
const handleUpdatePatient = async (id, formData) => {
  const response = await fetch(`http://localhost:4000/patients/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData)
  });
  const updated = await response.json();
  setPatients(patients.map(p => p.id === id ? updated : p));
};

// 5. Delete patient
const handleDeletePatient = async (id) => {
  await fetch(`http://localhost:4000/patients/${id}`, {
    method: 'DELETE'
  });
  setPatients(patients.filter(p => p.id !== id));
};
```

---

## **SUMMARY FOR AI FRONTEND REQUEST**

Use this prompt with an AI to generate your React frontend:

> "I have a microservices backend with the following APIs:
> 
> 1. **Patient Service** (Port 4000): CRUD operations on patients with fields (id, name, email, address, dateOfBirth, registeredDate)
> 2. **Auth Service** (Port 4005): Login endpoint that returns JWT token
> 3. **API Gateway** (Port 4004): Routes requests to services with JWT validation
> 
> Create a React application with:
> - Login page (email, password, JWT token storage)
> - Patient list page (table with all patients, search, filter)
> - Create patient form (with validation)
> - Edit patient form
> - Delete patient with confirmation
> - Navigation with logout
> - Error handling and loading states
> - Use React Router for navigation
> - Use Context API or Redux for state management
> 
> API endpoints:
> - POST /login (returns token)
> - GET /patients (list all)
> - POST /patients (create)
> - PUT /patients/{id} (update)
> - DELETE /patients/{id} (delete)
> 
> All requests except login require JWT token in Authorization header."

---
