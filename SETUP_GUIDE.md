# Full Stack Setup Guide - MicroPatient

This guide will help you run the complete MicroPatient application with both backend services and frontend.

## Prerequisites

- Docker Desktop installed and running
- Node.js 18+ installed
- Maven 3.9+ (for local development, optional)

## Quick Start

### Option 1: Start Everything at Once

Run the startup script from the project root:

```cmd
start-full-stack.cmd
```

This will:
1. Start all backend services in Docker
2. Install frontend dependencies (if needed)
3. Start the Next.js frontend

### Option 2: Manual Start

#### Step 1: Start Backend Services

```cmd
cd java-spring-microservices
docker-compose up -d --build
```

Wait for services to be ready (about 15-30 seconds).

#### Step 2: Start Frontend

```cmd
cd ..\micropatient-frontend
npm install
npm run dev
```

## Service URLs

Once started, services will be available at:

- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:4004
- **Patient Service**: http://localhost:4000
- **Auth Service**: http://localhost:4005
- **Billing Service**: http://localhost:4001
- **Analytics Service**: http://localhost:4002

## Testing the Application

### 1. Access the Frontend

Open your browser and navigate to: **http://localhost:3000**

### 2. Login

Use the test credentials:
- **Email**: `testuser@test.com`
- **Password**: `password1234`

### 3. Test Patient Management

After logging in, you can:
- View all patients
- Create new patients
- Edit existing patients
- Delete patients
- Search patients

## API Gateway Routes

The frontend is configured to use the API Gateway (port 4004):

- **Auth**: `http://localhost:4004/auth/**` → Auth Service
- **Patients**: `http://localhost:4004/api/patients/**` → Patient Service (JWT protected)

## Troubleshooting

### Services Won't Start

```cmd
# Check if ports are available
netstat -ano | findstr :4000
netstat -ano | findstr :4004
netstat -ano | findstr :5432

# View service logs
cd java-spring-microservices
docker-compose logs -f [service-name]
```

### Frontend Can't Connect to Backend

1. Verify backend services are running:
   ```cmd
   docker-compose ps
   ```

2. Check API Gateway is accessible:
   ```cmd
   curl http://localhost:4004/auth/login
   ```

3. Verify CORS is configured (should be automatic)

### Database Connection Issues

```cmd
# Check database containers
docker-compose ps postgres-patient postgres-auth

# View database logs
docker-compose logs postgres-patient
```

### Reset Everything

```cmd
cd java-spring-microservices
docker-compose down -v
docker-compose up -d --build
```

## Service Dependencies

```
Frontend (Next.js)
    ↓
API Gateway (Port 4004)
    ├── Auth Service (Port 4005)
    │   └── PostgreSQL (Port 5433)
    └── Patient Service (Port 4000)
        ├── PostgreSQL (Port 5432)
        ├── Kafka (Port 9092)
        └── Billing Service (Port 4001, gRPC 9001)
            └── Analytics Service (Port 4002)
                └── Kafka Consumer
```

## Development

### Backend Development

```cmd
cd java-spring-microservices
# Build specific service
cd patient-service
mvn clean package

# Run locally (requires local DB/Kafka)
mvn spring-boot:run
```

### Frontend Development

```cmd
cd micropatient-frontend
npm run dev
```

The frontend will hot-reload on changes.

## Production Build

### Backend

```cmd
cd java-spring-microservices
docker-compose build
docker-compose up -d
```

### Frontend

```cmd
cd micropatient-frontend
npm run build
npm start
```

## Environment Variables

### Backend (Docker Compose)

All environment variables are configured in `docker-compose.yml`.

### Frontend

Create `.env.local` in `micropatient-frontend/`:

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:4004/api
NEXT_PUBLIC_AUTH_BASE_URL=http://localhost:4004/auth
```

## Monitoring

### View All Logs

```cmd
docker-compose logs -f
```

### View Specific Service

```cmd
docker-compose logs -f patient-service
docker-compose logs -f api-gateway
```

### Check Service Health

```cmd
# API Gateway
curl http://localhost:4004/actuator/health

# Patient Service
curl http://localhost:4000/actuator/health
```

## Next Steps

1. ✅ All services running
2. ✅ Frontend connected to API Gateway
3. ✅ Authentication working
4. ✅ Patient CRUD operations functional
5. ✅ Kafka event streaming active
6. ✅ gRPC communication between services

## Support

For issues or questions, check:
- Service logs: `docker-compose logs -f`
- Frontend console: Browser DevTools
- Network tab: Check API requests/responses

---

**Last Updated**: January 24, 2026
**Status**: ✅ Ready for Development and Testing
