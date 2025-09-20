@echo off
echo.
echo ========================================
echo    PMS Local Testing Script
echo ========================================
echo.

echo Step 1: Starting Backend Server...
start "Backend Server" cmd /k "npm run dev"

echo.
echo Step 2: Waiting for backend to start...
timeout /t 5 /nobreak > nul

echo.
echo Step 3: Starting Flutter Frontend...
start "Flutter Frontend" cmd /k "cd pms_app && flutter run -d web-server --web-port 8080"

echo.
echo Step 4: Opening browser...
timeout /t 10 /nobreak > nul
start http://localhost:8080

echo.
echo ========================================
echo    System is starting up...
echo ========================================
echo.
echo Backend: http://localhost:3000
echo Frontend: http://localhost:8080
echo.
echo Test Accounts:
echo - admin@pms.com (Admin)
echo - developer@pms.com (Developer)
echo - qa@pms.com (QA Engineer)
echo.
echo Press any key to exit...
pause > nul
