@echo off
title PMS System Test
color 0B

echo.
echo ========================================
echo    PMS System Test
echo ========================================
echo.

echo Testing Backend...
curl -s http://localhost:3000/health >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Backend is running on http://localhost:3000
) else (
    echo ❌ Backend is not running
)

echo.
echo Testing Frontend...
curl -s http://localhost:8080 >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Frontend is running on http://localhost:8080
) else (
    echo ❌ Frontend is not running
)

echo.
echo Testing Database Studio...
curl -s http://localhost:5555 >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Database Studio is running on http://localhost:5555
) else (
    echo ❌ Database Studio is not running
)

echo.
echo ========================================
echo    Test Complete!
echo ========================================
echo.
echo If all are ✅, your system is ready!
echo.
echo Press any key to exit...
pause >nul
