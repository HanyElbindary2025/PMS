@echo off
title PMS System - Working Version
color 0A

echo.
echo ========================================
echo    PMS System - Working Version
echo ========================================
echo.

echo [1/3] Stopping all processes...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1
taskkill /f /im dart.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/3] Starting Backend...
start "PMS Backend" cmd /k "cd /d %~dp0.. && set DATABASE_URL=file:./prisma/dev.db && npm run dev"

echo [3/3] Starting Frontend...
start "PMS Frontend" cmd /k "cd /d %~dp0..\pms_app && flutter run -d web-server --web-port 8080"

echo.
echo ========================================
echo    System Started!
echo ========================================
echo.
echo ✅ Backend: http://localhost:3000
echo ✅ Frontend: http://localhost:8080
echo.
echo 👥 Test Accounts:
echo    admin@pms.com (Admin)
echo    developer@pms.com (Developer)
echo    qa@pms.com (QA Engineer)
echo.
echo 🎯 Open: http://localhost:8080
echo.
echo Press any key to exit...
pause >nul
