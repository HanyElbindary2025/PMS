@echo off
title PMS System - Testing
color 0B

echo.
echo ========================================
echo    PMS System - Testing
echo ========================================
echo.

echo Testing Backend Connection...
cd /d %~dp0..
node quick-test.js

echo.
echo ========================================
echo    Test Complete!
echo ========================================
echo.
echo If you see "Backend is running" above,
echo then the system is working correctly.
echo.
echo Open your browser and go to:
echo http://localhost:8080
echo.
echo Press any key to exit...
pause >nul
