# API Test Script for MicroPatient
$baseUrl = "http://localhost:4004"

Write-Host "`n=== 1. LOGIN (Auth) ===" -ForegroundColor Cyan
try {
    $loginBody = '{"email":"testuser@test.com","password":"password1234"}'
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "SUCCESS - Token received" -ForegroundColor Green
} catch {
    Write-Host "Trying password123..." -ForegroundColor Yellow
    $loginBody = '{"email":"testuser@test.com","password":"password123"}'
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "SUCCESS - Token received" -ForegroundColor Green
}

if (-not $token) {
    Write-Host "FAILED - No token. Cannot continue." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== 2. VALIDATE TOKEN ===" -ForegroundColor Cyan
try {
    $headers = @{ Authorization = "Bearer $token" }
    Invoke-RestMethod -Uri "$baseUrl/auth/validate" -Method GET -Headers $headers | Out-Null
    Write-Host "SUCCESS - Token is valid" -ForegroundColor Green
} catch {
    Write-Host "FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== 3. GET ALL PATIENTS ===" -ForegroundColor Cyan
try {
    $headers = @{ Authorization = "Bearer $token" }
    $patients = Invoke-RestMethod -Uri "$baseUrl/api/patients" -Method GET -Headers $headers
    Write-Host "SUCCESS - Found $($patients.Count) patients" -ForegroundColor Green
    $patients | ConvertTo-Json -Depth 2 | Write-Host
} catch {
    Write-Host "FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== 4. CREATE PATIENT ===" -ForegroundColor Cyan
try {
    $headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
    $newPatient = @{
        name = "API Test Patient"
        email = "apitest_$(Get-Random)@example.com"
        address = "123 Test Street"
        dateOfBirth = "1990-05-15"
        registeredDate = "2025-02-07"
    } | ConvertTo-Json
    $created = Invoke-RestMethod -Uri "$baseUrl/api/patients" -Method POST -Headers $headers -Body $newPatient
    Write-Host "SUCCESS - Created patient: $($created.name) (ID: $($created.id))" -ForegroundColor Green
} catch {
    Write-Host "FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== All API tests completed ===" -ForegroundColor Cyan
