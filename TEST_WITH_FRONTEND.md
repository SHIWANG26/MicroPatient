# Test Backend Using Frontend

Use this guide to test your MicroPatient backend through the Next.js frontend.

---

## Quick Start (3 steps)

### Step 1: Start the backend

```powershell
cd "C:\Users\shiwa\OneDrive\Desktop\web dev\java course\MicroPatient\java-spring-microservices"
docker-compose up -d --build
```

Wait ~20–30 seconds for all services to start (PostgreSQL, Kafka, Auth, Patient, Billing, Analytics, API Gateway).

### Step 2: Start the frontend

```powershell
cd "C:\Users\shiwa\OneDrive\Desktop\web dev\java course\MicroPatient\micropatient-frontend"
npm install   # if you haven't already
npm run dev
```

### Step 3: Open and test

1. Open **http://localhost:3000** in your browser.
2. Log in with:
   - **Email:** `testuser@test.com`
   - **Password:** `password1234`
3. After login you should be redirected to the dashboard.
4. From the dashboard:
   - Go to **Patients** to list, add, edit, and delete patients.
   - Test creating a new patient.
   - Test editing and deleting patients.

---

## Alternative: One-command startup

From the project root:

```powershell
.\start-full-stack.cmd
```

This starts the backend and then the frontend in a new window.

---

## How it works

```
Browser (localhost:3000)
    ↓
Next.js rewrites /api/* and /auth/* to API Gateway (localhost:4004)
    ↓
API Gateway routes:
  - /auth/login, /auth/validate → Auth Service (:4005)
  - /api/patients/* → Patient Service (:4000)
```

- Login calls the Auth Service and returns a JWT.
- The frontend stores the JWT and sends it as `Authorization: Bearer <token>` on all patient requests.
- The API Gateway validates the JWT before forwarding to the Patient Service.

---

## Checklist: What to test

| Test | Steps | Expected |
|------|-------|----------|
| Login | Use test credentials | Redirect to dashboard |
| List patients | Open Patients page | List of patients (or empty) |
| Create patient | Click "New Patient", fill form | New patient appears in list |
| Edit patient | Click edit on a patient | Form pre-filled, save updates |
| Delete patient | Click delete on a patient | Patient removed from list |
| Logout | Logout from dashboard | Redirect to login |

---

## Troubleshooting

### Backend not responding

- Ensure Docker is running: `docker ps`
- Check logs: `docker-compose -f java-spring-microservices/docker-compose.yml logs -f`
- Ensure databases are up: `docker-compose ps` and wait for healthy status

### Login fails

- Confirm backend is up: `curl http://localhost:4004/auth/login -X POST -H "Content-Type: application/json" -d "{\"email\":\"testuser@test.com\",\"password\":\"password1234\"}"`
- You should get a JSON response with a `token` field.

### CORS errors

- The API Gateway is configured for `http://localhost:3000`. If using another port, update `java-spring-microservices/api-gateway/src/main/resources/application.yml`.

### Patient list empty / 401

- Log in again; the JWT may have expired.
- Clear `localStorage` and log in again.

---

## Manual API tests (optional)

You can also test the backend directly:

```powershell
# Login (get token)
$body = @{ email = 'testuser@test.com'; password = 'password1234' } | ConvertTo-Json
$response = Invoke-RestMethod -Uri 'http://localhost:4004/auth/login' -Method POST -Body $body -ContentType 'application/json'
$token = $response.token

# List patients
$headers = @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri 'http://localhost:4004/api/patients' -Headers $headers
```
