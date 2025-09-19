@echo off
echo Starting PMS Backend and Frontend...
echo.
cd /d "%~dp0.."
echo Current directory: %CD%
echo.

echo ========================================
echo Starting Backend Server...
echo ========================================
start "PMS Backend" cmd /k "npm install && npm run dev"

echo Waiting 5 seconds for backend to start...
timeout /t 5 /nobreak > nul

echo ========================================
echo Starting Frontend App...
echo ========================================
cd pms_app
start "PMS Frontend" cmd /k "flutter pub get && flutter run -d web-server --web-port 8080"

echo.
echo ========================================
echo Both servers are starting...
echo ========================================
echo Backend: http://localhost:3000
echo Frontend: http://localhost:8080
echo.
echo Press any key to close this window...
pause > nul
