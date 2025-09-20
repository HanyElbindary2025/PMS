@echo off
title PMS System - Starting All Services
color 0A

echo.
echo ========================================
echo    PMS System - Starting All Services
echo ========================================
echo.

echo [1/4] Stopping any existing processes...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/4] Starting Backend Server...
start "PMS Backend" cmd /k "cd /d %~dp0.. && npm run dev"
echo    Backend starting on http://localhost:3000
timeout /t 5 /nobreak >nul

echo [3/4] Starting Flutter Frontend...
start "PMS Frontend" cmd /k "cd /d %~dp0..\pms_app && flutter run -d web-server --web-port 8080"
echo    Frontend starting on http://localhost:8080
timeout /t 10 /nobreak >nul

echo [4/4] Opening browser...
start http://localhost:8080

echo.
echo ========================================
echo    System Started Successfully!
echo ========================================
echo.
echo Backend:  http://localhost:3000
echo Frontend: http://localhost:8080
echo.
echo Test Accounts:
echo - admin@pms.com (Admin)
echo - developer@pms.com (Developer)
echo - qa@pms.com (QA Engineer)
echo.
echo Press any key to exit this window...
pause >nul
