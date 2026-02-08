@echo off
echo ========================================
echo  MicroPatient - Full Stack Startup
echo ========================================
echo.

cd /d "%~dp0"

echo [1/2] Starting backend services (Docker)...
cd java-spring-microservices
docker-compose up -d --build
if errorlevel 1 (
    echo ERROR: Failed to start backend. Is Docker running?
    pause
    exit /b 1
)

echo.
echo Waiting for backend services to be ready...
timeout /t 20 /nobreak >nul

echo.
echo [2/2] Starting frontend (Next.js)...
cd ..\micropatient-frontend
start "MicroPatient Frontend" cmd /k "npm run dev"

echo.
echo ========================================
echo  Ready! Open http://localhost:3000
echo ========================================
echo.
echo Test credentials:
echo   Email:    testuser@test.com
echo   Password: password1234
echo.
echo Backend services:
echo   API Gateway:  http://localhost:4004
echo   Auth:         http://localhost:4005
echo   Patient:      http://localhost:4000
echo.
pause
