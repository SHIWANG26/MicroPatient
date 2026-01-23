@echo off
REM Microservices Testing Script
REM ========================================

echo.
echo ============================================
echo Testing Auth Service (Port 4005)
echo ============================================
echo.

REM Register a new user
echo [1] Registering new user...
REM Note: Register endpoint not shown in controller, so we'll test login with existing user
REM For now, we'll create a test directly via the database

echo.
echo [2] Testing Login endpoint...
curl -X POST http://localhost:4005/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"password\"}"

echo.
echo.

echo ============================================
echo Testing Patient Service (Port 4000)
echo ============================================
echo.

echo [1] Getting all patients...
curl -X GET http://localhost:4000/patients

echo.
echo.

echo ============================================
echo Testing via API Gateway (Port 4004)
echo ============================================
echo.

echo [1] Gateway - Get all patients...
curl -X GET http://localhost:4004/patients

echo.
echo.

echo ============================================
echo Testing Kafka (via Docker)
echo ============================================
echo.

echo [1] Checking Kafka topics...
docker exec java-spring-microservices-kafka-1 kafka-topics.sh --list --bootstrap-server localhost:9092

echo.
echo.

echo ============================================
echo Testing Databases
echo ============================================
echo.

echo [1] Patient Service DB - checking tables...
docker exec java-spring-microservices-patient-service-db-1 psql -U admin_user -d db -c "\dt"

echo.
echo [2] Auth Service DB - checking tables...
docker exec java-spring-microservices-auth-service-db-1 psql -U admin_user -d db -c "\dt"

echo.
echo ============================================
echo All tests completed!
echo ============================================
