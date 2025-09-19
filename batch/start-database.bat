@echo off
echo Starting Prisma Studio...
echo.
cd /d "%~dp0.."
echo Current directory: %CD%
echo.
echo Starting Prisma Studio on http://localhost:5555
echo Press Ctrl+C to stop Prisma Studio
echo.
call npx prisma studio --port 5555
pause
