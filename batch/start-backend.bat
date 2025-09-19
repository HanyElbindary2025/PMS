@echo off
echo Starting PMS Backend Server...
echo.
cd /d "%~dp0.."
echo Current directory: %CD%
echo.
echo Installing dependencies...
call npm install
echo.
echo Starting backend server on http://localhost:3000
echo Press Ctrl+C to stop the server
echo.
call npm run dev
pause
