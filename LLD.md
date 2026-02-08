# MicroPatient - Low-Level Design (LLD)

## 1. Service-Level Design

---

## 1.1 Auth Service

### Components

| Class | Purpose |
|-------|---------|
| `AuthServiceApplication` | Spring Boot entry point |
| `AuthController` | REST: `POST /login`, `GET /validate` |
| `AuthService` | Authenticate credentials, validate JWT |
| `UserService` | User lookup by email |
| `UserRepository` | JPA repository for `users` table |
| `User` | Entity: id, email, password, role |
| `JwtUtil` | Generate and validate JWT tokens |
| `SecurityConfig` | Security filter chain, `PasswordEncoder` bean |
| `DataSeeder` | CommandLineRunner: seed test user with BCrypt |

### Endpoints

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| POST | `/login` | No | `{ email, password }` | `{ token }` |
| GET | `/validate` | Bearer | - | 200 / 401 |

### Configuration

```
server.port=4005
jwt.secret=<Base64>
jwt.expiration=86400000
spring.datasource.* → postgres-auth:5432
```

### Database Schema

```sql
users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL
)
```

---

## 1.2 Patient Service

### Components

| Class | Purpose |
|-------|---------|
| `PatientServiceApplication` | Spring Boot entry point |
| `PatientController` | REST: CRUD on `/patients` |
| `PatientService` | Business logic, orchestrates DB, gRPC, Kafka |
| `PatientRepository` | JPA repository |
| `Patient` | Entity: id, name, email, address, dateOfBirth, registeredDate |
| `PatientMapper` | Entity ↔ DTO mapping |
| `BillingServiceGrpcClient` | gRPC client to Billing Service |
| `KafkaProducer` | Publish `PatientEvent` to Kafka |
| `GlobalExceptionHandler` | Handle `PatientNotFoundException`, `EmailAlreadyExistsException` |

### Endpoints

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| GET | `/patients` | Yes | - | `Patient[]` |
| GET | `/patients/{id}` | Yes | - | `Patient` |
| POST | `/patients` | Yes | `PatientRequestDTO` | `Patient` |
| PUT | `/patients/{id}` | Yes | `PatientRequestDTO` | `Patient` |
| DELETE | `/patients/{id}` | Yes | - | 204 |

### DTOs

**PatientRequestDTO (Create):**
```json
{
  "name": "string",
  "email": "string",
  "address": "string",
  "dateOfBirth": "YYYY-MM-DD",
  "registeredDate": "YYYY-MM-DD"
}
```

**PatientResponseDTO:**
```json
{
  "id": "uuid",
  "name": "string",
  "email": "string",
  "address": "string",
  "dateOfBirth": "YYYY-MM-DD",
  "registeredDate": "YYYY-MM-DD"
}
```

### Patient Create Flow (Internal)

```
1. Validate email uniqueness
2. Save Patient to PostgreSQL
3. Call BillingServiceGrpcClient.createBillingAccount(patientId, name, email)
4. Call KafkaProducer.sendEvent(patient)
5. Return PatientResponseDTO
```

### Configuration

```
server.port=4000
spring.datasource.* → postgres-patient:5432
billing.service.address=billing-service
billing.service.grpc.port=9001
spring.kafka.bootstrap-servers=kafka:9092
```

### Database Schema

```sql
patient (
  id UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  address VARCHAR(255) NOT NULL,
  date_of_birth DATE NOT NULL,
  registered_date DATE
)
```

---

## 1.3 Billing Service

### Components

| Class | Purpose |
|-------|---------|
| `BillingServiceApplication` | Spring Boot entry point |
| `BillingGrpcService` | gRPC server, extends `BillingServiceImplBase` |

### gRPC Definition (`billing_service.proto`)

```protobuf
service BillingService {
  rpc CreateBillingAccount (BillingRequest) returns (BillingResponse);
}

message BillingRequest {
  string patientId = 1;
  string name = 2;
  string email = 3;
}

message BillingResponse {
  string accountId = 1;
  string status = 2;
}
```

### Configuration

```
server.port=4001
grpc.server.port=9001
```

---

## 1.4 Analytics Service

### Components

| Class | Purpose |
|-------|---------|
| `AnalyticsServiceApplication` | Spring Boot entry point |
| `KafkaConsumer` | `@KafkaListener` on topic `patient`, groupId `analytics-service` |

### Kafka Event (patient_event.proto)

```protobuf
message PatientEvent {
  string patientId = 1;
  string name = 2;
  string email = 3;
  string event_type = 4;
}
```

### Configuration

```
spring.kafka.bootstrap-servers=kafka:9092
```

---

## 1.5 API Gateway

### Components

| Class | Purpose |
|-------|---------|
| `ApiGatewayApplication` | Spring Boot entry point |
| `JwtValidationGatewayFilterFactory` | Custom filter: validate JWT via Auth Service `/validate` |
| `JwtValidationExceptionHandler` | Handle validation errors |

### Routes (application.yml)

| Route ID | Path | Destination | Filters |
|----------|------|-------------|---------|
| auth-service-route | `/auth/**` | auth-service:4005 | StripPrefix=1 |
| patient-service-route | `/api/patients/**` | patient-service:4000 | StripPrefix=1, JwtValidation |
| api-docs-patient-route | `/api-docs/patients` | patient-service:4000 | RewritePath |
| api-docs-auth-route | `/api-docs/auth` | auth-service:4005 | RewritePath |

### JWT Validation Filter Logic

```
1. Extract Authorization header
2. If null or not "Bearer <token>" → 401
3. Call auth-service:4005/validate with header
4. On success → chain.filter(exchange)
5. On error → 401
```

### CORS

```
allowedOrigins: localhost:3000, localhost:3001
allowedMethods: GET, POST, PUT, DELETE, OPTIONS
allowedHeaders: *
allowCredentials: true
```

---

## 2. Frontend Design

### 2.1 App Structure

```
src/
├── app/
│   ├── layout.tsx          # Root layout, AuthProvider
│   ├── page.tsx            # "/" - redirect to dashboard or login
│   ├── login/page.tsx      # "/login" - login form
│   ├── dashboard/page.tsx   # "/dashboard" - after login
│   └── patients/
│       ├── page.tsx        # "/patients" - list
│       ├── new/page.tsx    # "/patients/new" - create form
│       └── [id]/edit/page.tsx  # "/patients/:id/edit" - edit form
├── contexts/
│   └── AuthContext.tsx     # Auth state, login, logout
├── lib/
│   └── api.ts              # authAPI, patientAPI (axios)
└── types/
    └── index.ts            # Patient, CreatePatientDTO, etc.
```

### 2.2 AuthContext

| State | Type | Purpose |
|-------|------|---------|
| isAuthenticated | boolean | User logged in |
| user | { email } \| null | Current user |
| loading | boolean | Initial token validation |
| login(credentials) | async | Call authAPI.login, store token |
| logout() | void | Clear localStorage, set state |

### 2.3 API Client (api.ts)

| Module | Methods |
|--------|---------|
| authAPI | `login(credentials)`, `validateToken(token)` |
| patientAPI | `getAll()`, `getById(id)`, `create(patient)`, `update(id, patient)`, `delete(id)` |

**Axios interceptor:** Adds `Authorization: Bearer <token>` from localStorage to all requests.

### 2.4 Next.js Rewrites (next.config.ts)

```javascript
rewrites: [
  { source: '/api/:path*', destination: 'http://localhost:4004/api/:path*' },
  { source: '/auth/:path*', destination: 'http://localhost:4004/auth/:path*' }
]
```

---

## 3. Data Models

### 3.1 Patient (Backend)

```java
@Entity
@Table(name = "patient")
class Patient {
  UUID id;
  String name;       // max 100
  String email;      // unique
  String address;
  LocalDate dateOfBirth;
  LocalDate registeredDate;
}
```

### 3.2 User (Backend)

```java
@Entity
@Table(name = "users")
class User {
  UUID id;
  String email;      // unique
  String password;   // BCrypt
  String role;       // ADMIN, USER
}
```

### 3.3 Frontend Types

```typescript
interface Patient {
  id: string;
  name: string;
  email: string;
  address: string;
  dateOfBirth: string;
  registeredDate?: string;
}

interface CreatePatientDTO {
  name: string;
  email: string;
  address: string;
  dateOfBirth: string;
  registeredDate: string;
}

interface AuthResponse {
  token: string;
}
```

---

## 4. Exception Handling

### 4.1 Patient Service

| Exception | HTTP Status | Handler |
|-----------|-------------|---------|
| PatientNotFoundException | 404 | GlobalExceptionHandler |
| EmailAlreadyExistsException | 409 | GlobalExceptionHandler |
| MethodArgumentNotValidException | 400 | GlobalExceptionHandler |

### 4.2 API Gateway

| Scenario | Response |
|----------|----------|
| Missing/invalid JWT | 401 |
| Auth /validate fails | 401 |

---

## 5. Configuration Reference

### 5.1 Environment Variables (Docker Compose)

| Service | Variable | Value |
|---------|----------|-------|
| auth-service | SPRING_DATASOURCE_URL | jdbc:postgresql://postgres-auth:5432/db |
| patient-service | SPRING_DATASOURCE_URL | jdbc:postgresql://postgres-patient:5432/db |
| patient-service | BILLING_SERVICE_ADDRESS | billing-service |
| patient-service | BILLING_SERVICE_GRPC_PORT | 9001 |
| patient-service | SPRING_KAFKA_BOOTSTRAP_SERVERS | kafka:9092 |
| analytics-service | SPRING_KAFKA_BOOTSTRAP_SERVERS | kafka:9092 |
| api-gateway | AUTH_SERVICE_URL | http://auth-service:4005 |

### 5.2 Port Mapping

| Container | Host Port | Container Port |
|-----------|-----------|----------------|
| postgres-patient | 5432 | 5432 |
| postgres-auth | 5433 | 5432 |
| kafka | 9092 | 9092 |
| auth-service | 4005 | 4005 |
| patient-service | 4000 | 4000 |
| billing-service | 4001, 9001 | 4001, 9001 |
| analytics-service | 4002 | 4002 |
| api-gateway | 4004 | 4004 |

---

## 6. Sequence Diagrams (Key Flows)

### 6.1 Login

```
User -> Frontend: Submit credentials
Frontend -> Gateway: POST /auth/login
Gateway -> Auth: POST /login (StripPrefix)
Auth -> DB: findByEmail
Auth -> Auth: BCrypt.matches, JwtUtil.generate
Auth -> Gateway: { token }
Gateway -> Frontend: { token }
Frontend -> Frontend: localStorage.setItem('jwt_token', token)
Frontend -> User: Redirect /dashboard
```

### 6.2 Create Patient

```
User -> Frontend: Submit patient form
Frontend -> Gateway: POST /api/patients + Authorization
Gateway -> Auth: GET /validate
Auth -> Gateway: 200 OK
Gateway -> Patient: POST /patients
Patient -> DB: save
Patient -> Billing: gRPC CreateBillingAccount
Patient -> Kafka: send PatientEvent
Patient -> Gateway: PatientResponseDTO
Gateway -> Frontend: PatientResponseDTO
Frontend -> User: Redirect /patients
```

---

## 7. Kafka Topic Details

| Topic | Producer | Consumer | Payload |
|-------|----------|---------|---------|
| patient | Patient Service | Analytics Service | PatientEvent (protobuf) |

**Note:** Actual topic name in code is `patient` (KafkaProducer sends to `"patient"`).
