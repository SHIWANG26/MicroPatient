# MicroPatient - High-Level Design (HLD)

## 1. System Overview

**MicroPatient** is a Patient Management System built as a microservices architecture. It provides patient registration, authentication, billing integration, and event-driven analytics through a modern web frontend.

---

## 2. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │              Next.js Frontend (React) - Port 3000                            │ │
│  │  • Login, Dashboard, Patient CRUD • JWT in localStorage • Axios API client  │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         │ HTTP (rewrites /api, /auth → Gateway)
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              GATEWAY LAYER                                       │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │              API Gateway (Spring Cloud Gateway) - Port 4004                 │ │
│  │  • Route /auth/* → Auth Service  • Route /api/patients/* → Patient Service  │ │
│  │  • JWT validation filter  • CORS  • Strip path prefix                        │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                    │                                    │
        ┌───────────┘                                    └───────────┐
        ▼                                                              ▼
┌───────────────────────┐                              ┌───────────────────────┐
│ AUTH SERVICE (4005)    │                              │ PATIENT SERVICE (4000) │
│ • Login, Validate JWT │                              │ • Patient CRUD        │
│ • BCrypt, JWT tokens  │                              │ • PostgreSQL          │
│ • PostgreSQL (5433)   │                              │ • gRPC → Billing      │
└───────────────────────┘                              │ • Kafka Producer      │
                                                        └───────────┬───────────┘
                                                                    │
                    ┌───────────────────────────────┬───────────────┘
                    │                               │
                    ▼                               ▼
        ┌───────────────────────┐      ┌───────────────────────┐
        │ BILLING SERVICE       │      │ KAFKA (9092)          │
        │ • gRPC server (9001)  │      │ • Topic: patient      │
        │ • Create billing acct │      └───────────┬───────────┘
        └───────────────────────┘                  │
                                                    ▼
                                        ┌───────────────────────┐
                                        │ ANALYTICS SERVICE     │
                                        │ • Kafka consumer      │
                                        │ • Patient events      │
                                        └───────────────────────┘
```

---

## 3. Component Responsibilities

| Component | Responsibility | Key Tech |
|-----------|-----------------|----------|
| **Frontend** | UI, auth state, patient CRUD forms, API calls | Next.js 16, React 19, Tailwind, Axios |
| **API Gateway** | Single entry point, routing, JWT validation, CORS | Spring Cloud Gateway |
| **Auth Service** | User authentication, JWT generation/validation | Spring Boot, Spring Security, BCrypt |
| **Patient Service** | Patient CRUD, business logic, orchestration | Spring Boot, Spring Data JPA |
| **Billing Service** | Billing accounts (gRPC), triggered on patient create | Spring Boot, gRPC |
| **Analytics Service** | Consume patient events, analytics processing | Spring Boot, Kafka Consumer |
| **Kafka** | Event streaming between Patient and Analytics | Apache Kafka |
| **PostgreSQL** | Persistence for Auth and Patient data | PostgreSQL 16 |

---

## 4. Communication Patterns

| From | To | Pattern | Protocol |
|------|-----|---------|----------|
| Frontend | API Gateway | Synchronous | HTTP/REST |
| API Gateway | Auth Service | Synchronous | HTTP/REST |
| API Gateway | Patient Service | Synchronous | HTTP/REST |
| Patient Service | Billing Service | Synchronous | gRPC |
| Patient Service | Kafka | Asynchronous | Kafka Producer |
| Kafka | Analytics Service | Asynchronous | Kafka Consumer |
| API Gateway | Auth Service (validate) | Synchronous | HTTP (WebClient) |

---

## 5. Data Flow (High-Level)

### 5.1 Authentication

```
User → Frontend → Gateway → Auth → DB (validate) → JWT → User
```

### 5.2 Patient Create (Full Flow)

```
User → Frontend → Gateway → Patient Service
                             ├─> PostgreSQL (save patient)
                             ├─> Billing Service (gRPC: create billing account)
                             └─> Kafka (publish PatientEvent)
                                    └─> Analytics Service (consume, log)
```

### 5.3 Patient Read/Update/Delete

```
User → Frontend → Gateway → Patient Service → PostgreSQL
```

---

## 6. Security Model

| Aspect | Implementation |
|--------|----------------|
| **Authentication** | Email/password → Auth Service → JWT |
| **Password Storage** | BCrypt hash in PostgreSQL |
| **Token** | JWT (HS512), stored in frontend localStorage |
| **Protected Routes** | API Gateway validates JWT via Auth Service /validate |
| **CORS** | Gateway allows `http://localhost:3000`, `http://localhost:3001` |

---

## 7. Scalability Considerations

| Component | Scaling Strategy |
|-----------|------------------|
| Frontend | Static build, CDN, multiple instances |
| API Gateway | Horizontal scaling, stateless |
| Auth Service | Stateless, scale horizontally |
| Patient Service | Stateless, scale horizontally, DB connection pooling |
| Billing Service | Stateless, scale horizontally |
| Analytics Service | Kafka consumer groups, scale by partition |
| Kafka | Add brokers, partition topics |
| PostgreSQL | Read replicas, connection pooling |

---

## 8. Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Docker Compose Stack                        │
├─────────────────────────────────────────────────────────────────┤
│  postgres-patient │ postgres-auth │ kafka                        │
│  auth-service     │ billing-service │ analytics-service           │
│  patient-service  │ api-gateway                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ (Frontend runs separately: npm run dev)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Next.js Dev Server (localhost:3000)                             │
│  Rewrites: /api/*, /auth/* → localhost:4004                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 9. Technology Stack Summary

| Layer | Technologies |
|-------|--------------|
| **Frontend** | Next.js 16, React 19, TypeScript, Tailwind CSS, Axios, React Hook Form, Zod |
| **Backend** | Spring Boot 3.4, Spring Cloud Gateway, Spring Data JPA, Spring Security |
| **Database** | PostgreSQL 16 |
| **Messaging** | Apache Kafka |
| **RPC** | gRPC, Protocol Buffers |
| **Auth** | JWT, BCrypt |
| **Container** | Docker, Docker Compose |

---

## 10. Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| API Gateway | Single entry point, centralize auth, CORS, routing |
| JWT validation at Gateway | Avoid duplicating validation in each service |
| gRPC for Billing | Efficient internal service-to-service communication |
| Kafka for Analytics | Decouple analytics from patient operations, async processing |
| Separate DBs for Auth and Patient | Bounded contexts, independent scaling |
| Next.js rewrites | Proxy API calls to avoid CORS, same-origin from frontend |
