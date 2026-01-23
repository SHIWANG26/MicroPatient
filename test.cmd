@echo off
REM Test Auth
echo Testing Auth Service...
curl -X POST http://localhost:4005/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser\",\"password\":\"password123\",\"email\":\"test@example.com\"}"

echo.
echo Testing Patient Service...
curl -X GET http://localhost:4000/api/patients