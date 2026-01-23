@echo off
REM Complete Microservices Testing Script
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo    MICROSERVICES TEST SUITE
echo ============================================================
echo.

REM Test 1: Patient Service - Create
echo [TEST 1] Creating patients...
echo.
curl -X POST http://localhost:4000/patients ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Alice Johnson\",\"email\":\"alice@example.com\",\"address\":\"100 Maple Dr\",\"dateOfBirth\":\"1985-06-10\",\"registeredDate\":\"2026-01-23\"}"

echo.
echo.

REM Test 2: Patient Service - Get All
echo [TEST 2] Retrieving all patients...
echo.
curl -X GET http://localhost:4000/patients

echo.
echo.

REM Test 3: Test Gateway
echo [TEST 3] Testing API Gateway routing (same request through gateway)...
echo.
curl -X GET http://localhost:4004/patients

echo.
echo.

REM Test 4: Database Verification
echo [TEST 4] Checking Patient Service Database...
echo.
docker exec java-spring-microservices-patient-service-db-1 psql -U admin_user -d db -c "SELECT id, name, email FROM patient LIMIT 5;"

echo.
echo.

REM Test 5: Kafka Topics
echo [TEST 5] Kafka Topics...
echo.
docker exec java-spring-microservices-kafka-1 kafka-topics.sh --list --bootstrap-server localhost:9092

echo.
echo.

REM Test 6: Health Check
echo [TEST 6] Service Health Checks...
echo.
echo Patient Service Status:
docker ps --filter "name=patient-service" --format "table {{.Names}}\t{{.Status}}"

echo.
echo Auth Service Status:
docker ps --filter "name=auth-service" --format "table {{.Names}}\t{{.Status}}"

echo.
echo Billing Service Status:
docker ps --filter "name=billing-service" --format "table {{.Names}}\t{{.Status}}"

echo.
echo.
echo ============================================================
echo    ALL TESTS COMPLETED!
echo ============================================================
echo.
