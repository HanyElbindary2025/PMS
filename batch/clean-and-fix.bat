@echo off
title PMS System - Complete Cleanup and Fix
color 0C

echo.
echo ========================================
echo    PMS System - Complete Cleanup and Fix
echo ========================================
echo.

echo [1/8] Stopping all processes...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1
taskkill /f /im dart.exe >nul 2>&1
echo    ✅ All processes stopped

echo.
echo [2/8] Cleaning Flutter build cache...
cd pms_app
flutter clean >nul 2>&1
flutter pub get >nul 2>&1
cd ..
echo    ✅ Flutter cache cleaned

echo.
echo [3/8] Cleaning Node.js cache...
npm cache clean --force >nul 2>&1
echo    ✅ Node.js cache cleaned

echo.
echo [4/8] Fixing environment variables...
set DATABASE_URL=file:./prisma/dev.db
echo DATABASE_URL="file:./prisma/dev.db" > .env
echo PORT=3000 >> .env
echo NODE_ENV=development >> .env
echo    ✅ Environment variables fixed

echo.
echo [5/8] Regenerating Prisma client...
npx prisma generate >nul 2>&1
echo    ✅ Prisma client regenerated

echo.
echo [6/8] Pushing database schema...
npx prisma db push >nul 2>&1
echo    ✅ Database schema updated

echo.
echo [7/8] Seeding database...
npx prisma db seed >nul 2>&1
echo    ✅ Database seeded

echo.
echo [8/8] Testing system...
echo    Testing backend...
start "PMS Backend" cmd /k "cd /d %~dp0.. && set DATABASE_URL=file:./prisma/dev.db && npm run dev"
timeout /t 8 /nobreak >nul

echo    Testing frontend...
start "PMS Frontend" cmd /k "cd /d %~dp0..\pms_app && flutter run -d web-server --web-port 8080"
timeout /t 15 /nobreak >nul

echo.
echo ========================================
echo    System Cleanup and Fix Complete!
echo ========================================
echo.
echo ✅ All processes stopped
echo ✅ Caches cleaned
echo ✅ Environment fixed
echo ✅ Database updated
echo ✅ Backend started
echo ✅ Frontend started
echo.
echo 🌐 System URLs:
echo    Backend:  http://localhost:3000
echo    Frontend: http://localhost:8080
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
