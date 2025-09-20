@echo off
title PMS System - Stopping All Services
color 0C

echo.
echo ========================================
echo    PMS System - Stopping All Services
echo ========================================
echo.

echo Stopping Backend Server...
taskkill /f /im node.exe >nul 2>&1
if %errorlevel% == 0 (
    echo    Backend stopped successfully
) else (
    echo    No backend process found
)

echo.
echo Stopping Flutter Frontend...
taskkill /f /im flutter.exe >nul 2>&1
if %errorlevel% == 0 (
    echo    Frontend stopped successfully
) else (
    echo    No frontend process found
)

echo.
echo ========================================
echo    All Services Stopped!
echo ========================================
echo.
echo Press any key to exit...
pause >nul