# Microservices Testing Guide

All services are running on their respective ports. Use the correct endpoints below.

## **1. Auth Service (Port 4005)**

### **Login**
```cmd
curl -X POST http://localhost:4005/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"testuser@test.com\",\"password\":\"password1234\"}"
```

**Fields:**
- `email` (required, valid email format)
- `password` (required, min 8 characters)

**Response:** JWT token in format `{"token":"eyJhbGc..."}`

---

### **Validate Token**
```cmd
curl -X GET http://localhost:4005/validate ^
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>"
```

---

## **2. Patient Service (Port 4000)**

### **Create Patient**
```cmd
curl -X POST http://localhost:4000/patients ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"address\":\"123 Main St\",\"dateOfBirth\":\"1990-01-15\",\"registeredDate\":\"2026-01-23\"}"
```

**Required Fields:**
- `name` (string, max 100 chars)
- `email` (valid email)
- `address` (string)
- `dateOfBirth` (date format YYYY-MM-DD)
- `registeredDate` (date format YYYY-MM-DD)

---

### **Get All Patients**
```cmd
curl -X GET http://localhost:4000/patients
```

**Response:** Array of patient objects
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "address": "123 Main St",
    "dateOfBirth": "1990-01-15",
    "registeredDate": "2026-01-23"
  }
]
```

---

### **Get Patient by ID**
```cmd
curl -X GET http://localhost:4000/patients/550e8400-e29b-41d4-a716-446655440000
```

---

### **Update Patient**
```cmd
curl -X PUT http://localhost:4000/patients/550e8400-e29b-41d4-a716-446655440000 ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Jane Doe\",\"email\":\"jane@example.com\",\"address\":\"456 Oak St\",\"dateOfBirth\":\"1990-01-15\"}"
```

---

### **Delete Patient**
```cmd
curl -X DELETE http://localhost:4000/patients/550e8400-e29b-41d4-a716-446655440000
```

---

## **3. API Gateway (Port 4004)**

Gateway forwards requests to services. Use same endpoints:

```cmd
curl -X GET http://localhost:4004/patients
curl -X POST http://localhost:4004/patients ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Jane Smith\",\"email\":\"jane@example.com\",\"address\":\"789 Pine St\",\"dateOfBirth\":\"1995-05-20\",\"registeredDate\":\"2026-01-23\"}"
```

---

## **4. Kafka Broker (Port 9092/9094)**

### **List Topics**
```cmd
docker exec java-spring-microservices-kafka-1 kafka-topics.sh --list --bootstrap-server localhost:9092
```

### **Monitor Patient Events**
```cmd
docker exec java-spring-microservices-kafka-1 kafka-console-consumer.sh ^
  --bootstrap-server localhost:9092 ^
  --topic patient-events ^
  --from-beginning
```

---

## **5. Databases**

### **Patient Service DB (Port 5432)**
```cmd
docker exec java-spring-microservices-patient-service-db-1 psql -U admin_user -d db -c "SELECT * FROM patient;"
```

### **Auth Service DB (Port 5433)**
```cmd
docker exec java-spring-microservices-auth-service-db-1 psql -U admin_user -d db -c "SELECT * FROM users;"
```

---

## **6. View Service Logs**

```cmd
REM Auth Service
docker-compose logs -f auth-service

REM Patient Service
docker-compose logs -f patient-service

REM Billing Service
docker-compose logs -f billing-service

REM Kafka
docker-compose logs -f kafka
```

Press `Ctrl+C` to stop.

---

## **Service Endpoints Summary**

| Service | Base URL | Endpoints |
|---------|----------|-----------|
| **Auth** | http://localhost:4005 | `/login`, `/validate` |
| **Patient** | http://localhost:4000 | `/patients` (GET/POST/PUT/DELETE) |
| **Billing** | http://localhost:4001 | gRPC server on 9001 |
| **Gateway** | http://localhost:4004 | Routes to all services |

---

## **Test Data**

**Existing Auth User:**
- Email: `testuser@test.com`
- Password: `password1234`

**Note:** Auth endpoint may require Spring Security configuration. Check logs if login fails.

---

## **Troubleshooting**

1. **404 errors:** Check endpoint paths (no `/api` prefix needed)
2. **Connection refused:** Verify `docker-compose ps` shows services as `Up`
3. **Validation errors:** Check required fields in request body
4. **Auth failures:** Check logs with `docker logs <container_id>`

---
