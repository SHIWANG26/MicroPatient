# Patient Management Microservices System

A comprehensive Java Spring Boot microservices application for managing patient data, authentication, billing, and analytics with event-driven architecture.

## 📋 Project Overview

This is a distributed microservices system built with Spring Boot that demonstrates enterprise-grade patterns including:
- **Microservices Architecture** - Independent, scalable services
- **API Gateway** - Unified entry point for all services
- **Event-Driven Architecture** - Kafka for asynchronous communication
- **gRPC Communication** - High-performance service-to-service communication
- **Database Per Service** - PostgreSQL instances for each service
- **Docker Containerization** - Complete containerized deployment

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────┐
│              Client Applications                    │
└─────────────────────┬───────────────────────────────┘
                      │ HTTP/REST
                      ▼
        ┌─────────────────────────────┐
        │    API GATEWAY (4004)       │
        │  - Route Management         │
        │  - JWT Validation           │
        │  - Load Balancing           │
        └─────────────────────────────┘
                  │      │      │
        ┌─────────┴──┐ ┌──┴────┐ ┌────┴──────┐
        ▼            ▼ ▼       ▼ ▼           ▼
    ┌────────┐  ┌────────┐ ┌────────┐ ┌──────────┐
    │  AUTH  │  │PATIENT │ │BILLING │ │ANALYTICS │
    │SERVICE │  │SERVICE │ │SERVICE │ │ SERVICE  │
    │(4005)  │  │ (4000) │ │(4001)  │ │(Kafka)   │
    └────────┘  └────────┘ └────────┘ └──────────┘
        │            │          │
    ┌───┴───┐    ┌───┴──┐   ┌──┴────┐
    │Auth DB│    │Patient│  │Billing│
    │(5433) │    │ DB    │  │ gRPC  │
    └───────┘    │(5432) │  │(9001) │
                 └───────┘  └───────┘

         ┌────────────────────────┐
         │   KAFKA (9092)         │
         │  - Message Broker      │
         │  - Event Processing    │
         │  - Analytics Topic     │
         └────────────────────────┘
```

## 🚀 Services

### 1. **Patient Service** (Port 4000)
Manages patient records and information.
- **REST API** for CRUD operations
- **PostgreSQL** database for persistence
- **Kafka Producer** for patient events

**Key Endpoints:**
- `POST /patients` - Create patient
- `GET /patients` - Get all patients
- `GET /patients/{id}` - Get patient by ID
- `PUT /patients/{id}` - Update patient
- `DELETE /patients/{id}` - Delete patient

### 2. **Auth Service** (Port 4005)
Handles authentication and authorization.
- **JWT Token** generation and validation
- **User credentials** management
- **PostgreSQL** for user data storage

**Key Endpoints:**
- `POST /login` - User login
- `GET /validate` - Validate JWT token
- `POST /register` - User registration

### 3. **Billing Service** (Port 4001 REST / 9001 gRPC)
Manages billing accounts and transactions.
- **REST API** for HTTP requests
- **gRPC Server** for high-performance communication
- **Protocol Buffers** for data serialization

**Key Endpoints:**
- `POST /billing-accounts` - Create billing account
- `GET /billing-accounts` - Get all accounts
- `POST /transactions` - Create transaction

### 4. **Analytics Service**
Consumes events from Kafka for real-time analytics.
- **Kafka Consumer** for patient events
- **Event Processing** and analytics
- **No persistent data store** (event-driven)

### 5. **API Gateway** (Port 4004)
Central entry point for all client requests.
- **Request Routing** to appropriate services
- **JWT Token Validation** (if required)
- **Load Balancing** capabilities
- **CORS** configuration for frontend

## 🗄️ Databases

### PostgreSQL (Patient Service DB)
- **Port:** 5432
- **Database:** `db`
- **User:** `admin_user`
- **Password:** `password`

### PostgreSQL (Auth Service DB)
- **Port:** 5433
- **Database:** `db`
- **User:** `admin_user`
- **Password:** `password`

## 📦 Technologies Used

- **Java 21** - Programming language
- **Spring Boot 3.x** - Framework
- **Spring Cloud** - Microservices patterns
- **Spring Data JPA** - ORM
- **PostgreSQL** - Database
- **Apache Kafka** - Message broker
- **gRPC** - Service-to-service communication
- **Protocol Buffers** - Data serialization
- **Maven** - Build tool
- **Docker** - Containerization
- **Docker Compose** - Orchestration

## 🏃 Getting Started

### Prerequisites
- Java 21 or higher
- Maven 3.9+
- Docker & Docker Compose
- Git

### Quick Start with Docker

```bash
# Navigate to project directory
cd java-spring-microservices

# Build all services
docker-compose build

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f
```

### Verify Services

```bash
# Check if all services are running
docker-compose ps

# Test Patient Service
curl http://localhost:4000/patients

# Test Auth Service
curl http://localhost:4005/login

# Test API Gateway
curl http://localhost:4004/patients
```

## 📝 Project Structure

```
java-spring-microservices/
├── api-gateway/              # API Gateway service
│   ├── src/main/java/       # Gateway code
│   ├── pom.xml              # Maven configuration
│   └── Dockerfile           # Container configuration
├── patient-service/          # Patient management service
│   ├── src/main/java/       # Service code
│   ├── src/test/            # Unit tests
│   ├── pom.xml              # Maven configuration
│   └── Dockerfile           # Container configuration
├── auth-service/             # Authentication service
│   ├── src/main/java/       # Service code
│   ├── pom.xml              # Maven configuration
│   └── Dockerfile           # Container configuration
├── billing-service/          # Billing service
│   ├── src/main/java/       # Service code
│   ├── src/main/proto/      # Protocol buffer definitions
│   ├── pom.xml              # Maven configuration
│   └── Dockerfile           # Container configuration
├── analytics-service/        # Analytics service
│   ├── src/main/java/       # Service code
│   ├── src/main/proto/      # gRPC definitions
│   ├── pom.xml              # Maven configuration
│   └── Dockerfile           # Container configuration
├── infrastructure/           # Infrastructure setup
│   ├── pom.xml              # Shared dependencies
│   └── localstack-deploy.sh # AWS LocalStack deployment
├── integration-tests/        # Integration tests
│   ├── src/test/            # Test code
│   └── pom.xml              # Test configuration
├── api-requests/             # HTTP request examples
│   ├── auth-service/        # Auth service requests
│   ├── patient-service/     # Patient service requests
│   └── grpc-requests/       # gRPC requests
├── docker-compose.yml        # Container orchestration
└── README.md                 # Original README
```

## 🔌 API Gateway Routes

The API Gateway routes requests to appropriate services:

| Path | Service | Port |
|------|---------|------|
| `/patients/**` | Patient Service | 4000 |
| `/auth/**` | Auth Service | 4005 |
| `/billing/**` | Billing Service | 4001 |

## 🧪 Testing

### Run All Tests
```bash
# Using script
./run_tests.cmd

# Using Maven
mvn clean test
```

### Test Services
```bash
# Run service-specific tests
./test_services.cmd
```

### API Testing
HTTP request examples are available in the `api-requests/` directory.

## 📊 Monitoring and Logs

### View Service Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f patient-service

# Last 100 lines
docker-compose logs --tail=100 patient-service
```

### Health Checks
Each service provides health endpoints:
- `GET /actuator/health` - Service health status

## 🔐 Security

### JWT Token Authentication
- Auth Service generates JWT tokens
- API Gateway validates tokens
- Protected endpoints require valid tokens

### Environment Configuration
- `.env` files for sensitive data (not committed)
- Docker secrets for production
- Spring profiles for environment-specific configs

## 🚦 Service Dependencies

```
Patient Service
├── PostgreSQL (5432)
└── Kafka (9092)

Auth Service
├── PostgreSQL (5433)

Billing Service
├── gRPC Protocol Buffers
└── Analytics Service (gRPC)

Analytics Service
├── Kafka Consumer (9092)

API Gateway
├── Patient Service
├── Auth Service
├── Billing Service
```

## 📈 Deployment

### Production Deployment
1. Build JAR files: `mvn clean package`
2. Create Docker images: `docker build -t service:latest .`
3. Push to registry: `docker push registry/service:tag`
4. Deploy using Kubernetes or Docker Swarm

### Local Development
```bash
# Run with Docker Compose
docker-compose up -d

# Run individual service
cd patient-service
mvn spring-boot:run
```

## 🤝 Contributing

1. Create a feature branch
2. Make changes to services
3. Run tests: `mvn test`
4. Commit with clear messages
5. Push and create pull request

## 📚 Documentation

- [API Specification](../BACKEND_API_SPECIFICATION.md) - Detailed API documentation
- [Testing Guide](../TESTING_GUIDE.md) - Testing procedures
- [Project Summary](../PROJECT_SUMMARY.md) - Project status and endpoints

## 🐛 Troubleshooting

### Services won't start
```bash
# Check ports are available
netstat -ano | findstr :4000
netstat -ano | findstr :5432

# Clear Docker volumes
docker-compose down -v
docker-compose up
```

### Database connection errors
```bash
# Verify database containers
docker-compose ps

# Check database logs
docker-compose logs postgres-patient
docker-compose logs postgres-auth
```

### Port conflicts
Change ports in `docker-compose.yml` and update service configurations.

## 📄 License

Copyright © 2025 Code Jackal | Original Course Material by Chris Blakely

## 🔗 Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Documentation](https://docs.docker.com/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [gRPC Java Guide](https://grpc.io/docs/languages/java/)

## 💬 Support

For questions and discussions:
- Discord Community: https://discord.gg/nCrDnfCE
- Create GitHub issues for bugs
- Email: support@codeJackal.com

---

**Last Updated:** January 24, 2026
**Status:** ✅ All Services Running
