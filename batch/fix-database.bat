@echo off
title PMS Database Fix
color 0A

echo.
echo ========================================
echo    PMS Database Fix
echo ========================================
echo.

echo [1/4] Stopping all services...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1

echo [2/4] Setting environment variable...
set DATABASE_URL=file:./prisma/dev.db

echo [3/4] Pushing database schema...
npx prisma db push

echo [4/4] Seeding database with initial data...
npx prisma db seed

echo.
echo ========================================
echo    Database Fixed Successfully!
echo ========================================
echo.
echo ✅ Database schema updated
echo ✅ Database seeded with test data
echo ✅ Environment variable set
echo.
echo You can now run:
echo - batch\start-all.bat (to start the system)
echo - batch\open-database.bat (to view data)
echo.
echo Press any key to exit...
pause >nul
