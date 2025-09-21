@echo off
title PMS Database Studio
color 0B

echo.
echo ========================================
echo    Opening Prisma Database Studio
echo ========================================
echo.

echo Starting Prisma Studio...
start "Prisma Studio" cmd /k "cd /d %~dp0.. && npx prisma studio"

echo.
echo ✅ Prisma Studio is starting...
echo 🌐 Database Studio: http://localhost:5555
echo.
echo Press any key to exit...
pause >nul
