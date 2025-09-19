@echo off
echo Stopping all PMS processes...
echo.

echo Stopping Node.js processes (Backend)...
taskkill /f /im node.exe 2>nul
if %errorlevel% equ 0 (
    echo ✅ Backend stopped
) else (
    echo ℹ️  No backend processes found
)

echo.
echo Stopping Flutter processes...
taskkill /f /im flutter.exe 2>nul
taskkill /f /im dart.exe 2>nul
if %errorlevel% equ 0 (
    echo ✅ Frontend stopped
) else (
    echo ℹ️  No frontend processes found
)

echo.
echo Stopping Chrome instances (if running PMS)...
taskkill /f /im chrome.exe 2>nul
if %errorlevel% equ 0 (
    echo ✅ Chrome instances stopped
) else (
    echo ℹ️  No Chrome instances found
)

echo.
echo 🛑 All PMS processes stopped!
pause
