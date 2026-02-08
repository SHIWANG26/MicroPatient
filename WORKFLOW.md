# MicroPatient - Complete Workflow

This document describes all workflows for the MicroPatient Patient Management System.

---

## 1. User Workflows

### 1.1 Authentication Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │     │  Frontend   │     │ API Gateway │     │ Auth Service│
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │                   │
       │ 1. Enter email &  │                   │                   │
       │    password      │                   │                   │
       │─────────────────>│                   │                   │
       │                   │ 2. POST /auth/login                 │
       │                   │    {email, password}                  │
       │                   │──────────────────>│                   │
       │                   │                   │ 3. Forward to    │
       │                   │                   │    Auth Service  │
       │                   │                   │──────────────────>│
       │                   │                   │                   │
       │                   │                   │ 4. Validate      │
       │                   │                   │    credentials   │
       │                   │                   │    (BCrypt)      │
       │                   │                   │                   │
       │                   │                   │ 5. Generate JWT   │
       │                   │                   │<──────────────────│
       │                   │ 6. { token }      │                   │
       │                   │<──────────────────│                   │
       │ 7. Store token    │                   │                   │
       │    in localStorage│                   │                   │
       │<─────────────────│                   │                   │
       │                   │                   │                   │
       │ 8. Redirect to    │                   │                   │
       │    /dashboard     │                   │                   │
       │<─────────────────│                   │                   │
```

**Steps:**
1. User lands on `/login` (or `/` redirects to login if unauthenticated)
2. User enters `testuser@test.com` / `password1234`
3. Frontend sends `POST /auth/login` via Next.js rewrites → Gateway → Auth Service
4. Auth Service validates credentials, generates JWT, returns `{ token }`
5. Frontend stores token in `localStorage` (keys: `jwt_token`, `user_email`)
6. User is redirected to `/dashboard`

### 1.2 Token Validation Workflow (Protected Routes)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │     │  Frontend   │     │ API Gateway │     │ Auth Service│
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │                   │
       │ 1. Navigate to    │                   │                   │
       │    /patients      │                   │                   │
       │─────────────────>│                   │                   │
       │                   │ 2. GET /api/patients                 │
       │                   │    Authorization: Bearer <token>      │
       │                   │──────────────────>│                   │
       │                   │                   │ 3. Extract token  │
       │                   │                   │    Validate via   │
       │                   │                   │    Auth /validate │
       │                   │                   │──────────────────>│
       │                   │                   │                   │
       │                   │                   │ 4. 200 OK        │
       │                   │                   │<──────────────────│
       │                   │                   │ 5. Forward to     │
       │                   │                   │    Patient Service │
       │                   │                   │──────────────────>│
       │                   │                   │                   │
       │                   │ 6. Patient list   │                   │
       │                   │<──────────────────│                   │
       │ 7. Render list    │                   │                   │
       │<─────────────────│                   │                   │
```

**Steps:**
1. User accesses protected route (e.g. `/patients`, `/dashboard`)
2. Frontend adds `Authorization: Bearer <token>` to all API requests
3. API Gateway applies `JwtValidation` filter, calls Auth Service `/validate`
4. If valid: request proceeds to downstream service
5. If invalid: 401 Unauthorized, frontend redirects to login

### 1.3 Patient CRUD Workflow

#### Create Patient

```
User → Frontend (/patients/new) → POST /api/patients → Gateway → Patient Service
                                                                      │
                                                                      ├─> Save to PostgreSQL
                                                                      ├─> gRPC → Billing Service (create account)
                                                                      └─> Kafka → Analytics Service (event)
```

**Steps:**
1. User clicks "New Patient", fills form (name, email, address, dateOfBirth, registeredDate)
2. Frontend validates (Zod), sends `POST /api/patients` with JWT
3. Patient Service: validates, saves to DB, calls Billing via gRPC, publishes Kafka event
4. Frontend receives created patient, redirects to list

#### List Patients

```
User → Frontend (/patients) → GET /api/patients → Gateway → Patient Service → PostgreSQL
```

#### Update Patient

```
User → Frontend (/patients/[id]/edit) → PUT /api/patients/{id} → Gateway → Patient Service → PostgreSQL
```

#### Delete Patient

```
User → Frontend (/patients) → DELETE /api/patients/{id} → Gateway → Patient Service → PostgreSQL
```

---

## 2. Event-Driven Workflows

### 2.1 Patient Created → Billing Account (gRPC)

```
┌────────────────┐                    ┌────────────────┐
│ Patient Service│                    │ Billing Service│
└───────┬────────┘                    └───────┬────────┘
        │                                    │
        │ 1. Patient saved to DB             │
        │                                    │
        │ 2. gRPC CreateBillingAccount       │
        │    (patientId, name, email)        │
        │───────────────────────────────────>│
        │                                    │
        │ 3. BillingResponse                │
        │    (accountId, status)             │
        │<───────────────────────────────────│
        │                                    │
```

### 2.2 Patient Created → Analytics (Kafka)

```
┌────────────────┐     ┌────────┐     ┌────────────────┐
│ Patient Service│     │ Kafka   │     │ Analytics Svc  │
└───────┬────────┘     └───┬────┘     └───────┬────────┘
        │                  │                  │
        │ 1. Publish       │                  │
        │    PatientEvent  │                  │
        │    to "patient"  │                  │
        │    topic         │                  │
        │─────────────────>│                  │
        │                  │ 2. Consume       │
        │                  │    (groupId:     │
        │                  │    analytics-svc)│
        │                  │─────────────────>│
        │                  │                  │
        │                  │ 3. Log/process    │
        │                  │    event         │
        │                  │                  │
```

---

## 3. Development Workflows

### 3.1 Local Development Startup

```
1. Start Infrastructure
   └─> docker-compose up -d (PostgreSQL, Kafka, services)

2. Start Backend (if not using Docker)
   └─> Optional: run each service from IDE (auth, patient, billing, analytics, gateway)

3. Start Frontend
   └─> cd micropatient-frontend && npm run dev

4. Access
   └─> http://localhost:3000
   └─> Login: testuser@test.com / password1234
```

### 3.2 Full Stack Startup (Docker)

```
.\start-full-stack.cmd
   │
   ├─> docker-compose up -d --build (java-spring-microservices)
   │      ├─> postgres-patient, postgres-auth
   │      ├─> kafka
   │      ├─> auth-service, billing-service, analytics-service
   │      ├─> patient-service
   │      └─> api-gateway
   │
   └─> npm run dev (micropatient-frontend)
          └─> Next.js on http://localhost:3000
```

### 3.3 Request Flow (Next.js Rewrites)

```
Browser request: GET http://localhost:3000/api/patients
   │
   └─> Next.js rewrites to: http://localhost:4004/api/patients
          │
          └─> API Gateway receives, validates JWT, forwards to Patient Service
```

### 3.4 Build & Deploy Workflow

```
1. Backend
   └─> cd java-spring-microservices
   └─> docker-compose build
   └─> docker-compose up -d

2. Frontend
   └─> cd micropatient-frontend
   └─> npm run build
   └─> npm start (or deploy to Vercel/Netlify)
```

---

## 4. Data Flow Summary

| Flow | Trigger | Path | Outcome |
|------|---------|------|---------|
| Login | User submits credentials | Frontend → Gateway → Auth | JWT token issued |
| Token validation | Any protected API call | Gateway → Auth /validate | Request allowed or 401 |
| List patients | User visits /patients | Frontend → Gateway → Patient → DB | Patient list |
| Create patient | User submits form | Frontend → Gateway → Patient → DB + gRPC + Kafka | Patient created, billing account, event logged |
| Update patient | User saves edit form | Frontend → Gateway → Patient → DB | Patient updated |
| Delete patient | User confirms delete | Frontend → Gateway → Patient → DB | Patient removed |

---

## 5. Error Handling Workflows

| Scenario | Handling |
|----------|----------|
| Invalid login | 401 → Frontend shows error message |
| Expired/missing JWT | 401 → Gateway returns 401, frontend redirects to login |
| Patient not found | 404 → GlobalExceptionHandler returns error JSON |
| Duplicate email | 409 → Frontend shows "Email already exists" |
| Validation errors | 400 → Frontend shows field-level errors (Zod + backend) |
| Network error | Frontend catches, shows generic error |

---

## 6. Port Reference

| Component | Port | Protocol |
|-----------|------|----------|
| Frontend | 3000 | HTTP |
| API Gateway | 4004 | HTTP |
| Patient Service | 4000 | HTTP |
| Auth Service | 4005 | HTTP |
| Billing Service | 4001, 9001 | HTTP, gRPC |
| Analytics Service | 4002 | HTTP |
| Kafka | 9092 | TCP |
| PostgreSQL (Patient) | 5432 | TCP |
| PostgreSQL (Auth) | 5433 | TCP |
