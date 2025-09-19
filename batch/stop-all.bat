@echo off
echo Stopping all PMS processes...
echo.

echo Killing Node.js processes...
taskkill /f /im node.exe 2>nul
if %errorlevel% equ 0 (
    echo Backend server stopped.
) else (
    echo No Node.js processes found.
)

echo.
echo Killing Flutter processes...
taskkill /f /im flutter.exe 2>nul
if %errorlevel% equ 0 (
    echo Flutter app stopped.
) else (
    echo No Flutter processes found.
)

echo.
echo Killing Dart processes...
taskkill /f /im dart.exe 2>nul
if %errorlevel% equ 0 (
    echo Dart processes stopped.
) else (
    echo No Dart processes found.
)

echo.
echo All PMS processes have been stopped.
pause
