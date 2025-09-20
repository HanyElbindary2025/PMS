@echo off
title PMS Database Management
color 0B

echo.
echo ========================================
echo    PMS Database Management
echo ========================================
echo.

echo [1/3] Checking database status...
if exist "prisma\dev.db" (
    echo    ✅ Database file exists
) else (
    echo    ⚠️  Database file not found, creating...
    npx prisma migrate dev --name init
)

echo.
echo [2/3] Opening Prisma Studio...
echo    Database will open in your browser at: http://localhost:5555
echo    Press Ctrl+C to stop the database viewer
echo.

start "PMS Database" cmd /k "npx prisma studio"

echo.
echo ========================================
echo    Database Management Started!
echo ========================================
echo.
echo Prisma Studio: http://localhost:5555
echo.
echo Available Commands:
echo - View/Edit data in browser
echo - Press Ctrl+C to stop
echo.
echo Press any key to exit this window...
pause >nul