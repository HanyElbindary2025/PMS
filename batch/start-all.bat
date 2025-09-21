@echo off
title PMS System - Start All Services
color 0A

echo.
echo ========================================
echo    PMS System - Starting All Services
echo ========================================
echo.

echo [1/4] Stopping all existing processes...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1
taskkill /f /im dart.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/4] Setting up environment...
set DATABASE_URL=file:./prisma/dev.db
if not exist .env (
    echo DATABASE_URL="file:./prisma/dev.db" > .env
    echo PORT=3000 >> .env
    echo NODE_ENV=development >> .env
    echo    ✅ Created .env file
) else (
    echo    ✅ .env file already exists
)

echo [3/4] Starting Backend Server...
start "PMS Backend" cmd /k "cd /d %~dp0.. && set DATABASE_URL=file:./prisma/dev.db && npm run dev"

echo [4/4] Starting Flutter Frontend...
start "PMS Frontend" cmd /k "cd /d %~dp0..\pms_app && flutter run -d web-server --web-port 8080"

echo.
echo ========================================
echo    PMS System Started Successfully!
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
echo 🎯 Open your browser and go to: http://localhost:8080
echo.
echo Press any key to exit...
pause >nul
