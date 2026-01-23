# Quick Start Guide - MicroPatient Full Stack

## 🚀 Start Everything

### One Command Start

From the project root directory:

```cmd
start-full-stack.cmd
```

This will:
1. ✅ Start all backend microservices in Docker
2. ✅ Install frontend dependencies (if needed)
3. ✅ Start the Next.js frontend

### Manual Start

**Backend:**
```cmd
cd java-spring-microservices
docker-compose up -d --build
```

**Frontend:**
```cmd
cd ..\micropatient-frontend
npm install
npm run dev
```

## 🌐 Access the Application

- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:4004

## 🔐 Login Credentials

- **Email**: `testuser@test.com`
- **Password**: `password1234`

## ✅ What's Configured

1. **Backend Services** (Docker Compose):
   - ✅ API Gateway (Port 4004) - Routes all requests
   - ✅ Patient Service (Port 4000) - Patient CRUD operations
   - ✅ Auth Service (Port 4005) - Authentication
   - ✅ Billing Service (Port 4001) - Billing operations
   - ✅ Analytics Service (Port 4002) - Event processing
   - ✅ PostgreSQL Databases (Ports 5432, 5433)
   - ✅ Kafka (Port 9092) - Message broker

2. **Frontend**:
   - ✅ Configured to use API Gateway (port 4004)
   - ✅ JWT token authentication
   - ✅ Patient management UI
   - ✅ CORS enabled

3. **API Gateway**:
   - ✅ CORS configured for frontend
   - ✅ Routes `/auth/**` → Auth Service
   - ✅ Routes `/api/patients/**` → Patient Service (JWT protected)

## 🧪 Test the Application

1. Open http://localhost:3000
2. Login with test credentials
3. Create, view, edit, and delete patients
4. All requests go through API Gateway

## 📊 Check Service Status

```cmd
cd java-spring-microservices
docker-compose ps
```

## 📝 View Logs

```cmd
cd java-spring-microservices
docker-compose logs -f [service-name]
```

## 🛑 Stop Services

```cmd
cd java-spring-microservices
docker-compose down
```

## 🔄 Restart Services

```cmd
cd java-spring-microservices
docker-compose restart
```

---

**Ready to use!** 🎉
