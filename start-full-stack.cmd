@echo off
echo ========================================
echo Starting Full Stack Application
echo ========================================
echo.

cd /d "%~dp0"

echo [1/2] Starting Backend Services...
cd java-spring-microservices
echo Building and starting Docker containers...
docker-compose up -d --build
echo Waiting for services to initialize...
timeout /t 20 /nobreak >nul
echo.
echo Service Status:
docker-compose ps
cd ..

echo.
echo [2/2] Starting Frontend...
cd micropatient-frontend

if not exist node_modules (
    echo Installing dependencies...
    call npm install
)

echo.
echo ========================================
echo Starting Next.js development server...
echo ========================================
echo Frontend will be available at: http://localhost:3000
echo Backend API Gateway: http://localhost:4004
echo.
echo Test Credentials:
echo   Email: testuser@test.com
echo   Password: password1234
echo.
start cmd /k "npm run dev"

echo.
echo ========================================
echo Full Stack Started!
echo ========================================
echo.
echo Services:
echo   Frontend:        http://localhost:3000
echo   API Gateway:     http://localhost:4004
echo   Patient Service: http://localhost:4000
echo   Auth Service:    http://localhost:4005
echo.
echo View logs: cd java-spring-microservices ^&^& docker-compose logs -f
echo Stop services: cd java-spring-microservices ^&^& docker-compose down
echo.
pause
