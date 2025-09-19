@echo off
echo Starting PMS Application (Backend + Frontend)...
echo.

echo [1/3] Starting Backend Server...
start "PMS Backend" cmd /k "cd /d D:\projects\PMS && npm run dev"

echo [2/3] Waiting 3 seconds for backend to initialize...
timeout /t 3 /nobreak >nul

echo [3/3] Starting Frontend App...
start "PMS Frontend" cmd /k "cd /d D:\projects\PMS\pms_app && flutter run -d chrome --web-port 8080 --web-hostname localhost"

echo.
echo ✅ Both applications are starting!
echo 📱 Frontend: http://localhost:8080
echo 🔧 Backend: http://localhost:3000
echo.
echo Test Accounts:
echo - Requester: requester@test.com
echo - Admin: sys.agent@test.com
echo.
pause
