@echo off
echo Setting up PMS Project...
echo.
cd /d "%~dp0.."
echo Current directory: %CD%
echo.

echo ========================================
echo Installing Backend Dependencies...
echo ========================================
call npm install

echo.
echo ========================================
echo Setting up Database...
echo ========================================
call npx prisma generate
call npx prisma migrate dev --name init

echo.
echo ========================================
echo Installing Frontend Dependencies...
echo ========================================
cd pms_app
call flutter pub get
cd ..

echo.
echo ========================================
echo Project Setup Complete!
echo ========================================
echo.
echo To start the application:
echo 1. Run start-both.bat to start both servers
echo 2. Or run start-backend.bat and start-frontend.bat separately
echo.
echo Access points:
echo - Backend API: http://localhost:3000
echo - Frontend App: http://localhost:8080
echo - Database Studio: http://localhost:5555
echo.
pause
