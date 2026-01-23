@echo off
echo ========================================
echo Starting Microservices with Docker Compose
echo ========================================
echo.

cd /d "%~dp0"

echo Building and starting all services...
docker-compose up -d --build

echo.
echo Waiting for services to be ready...
timeout /t 15 /nobreak >nul

echo.
echo ========================================
echo Service Status:
echo ========================================
docker-compose ps

echo.
echo ========================================
echo Service URLs:
echo ========================================
echo API Gateway:     http://localhost:4004
echo Patient Service: http://localhost:4000
echo Auth Service:    http://localhost:4005
echo Billing Service: http://localhost:4001
echo Analytics:       http://localhost:4002
echo.
echo ========================================
echo View logs with: docker-compose logs -f
echo Stop services with: docker-compose down
echo ========================================
pause
