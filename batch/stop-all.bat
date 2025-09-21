@echo off
title PMS System - Stop All Services
color 0C

echo.
echo ========================================
echo    PMS System - Stopping All Services
echo ========================================
echo.

echo Stopping all processes...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1
taskkill /f /im dart.exe >nul 2>&1

echo.
echo ✅ All services stopped successfully!
echo.
echo Press any key to exit...
pause >nul
