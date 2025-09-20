@echo off
title PMS Database Status
color 0A

echo.
echo ========================================
echo    PMS Database Status Check
echo ========================================
echo.

echo [1/4] Checking environment...
if exist ".env" (
    echo    ✅ Environment file exists
) else (
    echo    ❌ Environment file missing
    echo    Creating .env file...
    echo DATABASE_URL="file:./prisma/dev.db" > .env
    echo PORT=3000 >> .env
    echo NODE_ENV=development >> .env
    echo    ✅ Environment file created
)

echo.
echo [2/4] Checking database file...
if exist "prisma\dev.db" (
    echo    ✅ Database file exists
    for %%A in ("prisma\dev.db") do echo    Size: %%~zA bytes
) else (
    echo    ❌ Database file missing
    echo    Run 'reset-database.bat' to create it
)

echo.
echo [3/4] Checking Prisma client...
npx prisma generate >nul 2>&1
if %errorlevel% == 0 (
    echo    ✅ Prisma client is up to date
) else (
    echo    ❌ Prisma client needs regeneration
    echo    Regenerating...
    npx prisma generate
    echo    ✅ Prisma client regenerated
)

echo.
echo [4/4] Testing database connection...
node -e "const { PrismaClient } = require('@prisma/client'); const prisma = new PrismaClient(); prisma.\$connect().then(() => { console.log('✅ Database connection successful'); prisma.\$disconnect(); }).catch(err => { console.log('❌ Database connection failed:', err.message); process.exit(1); });" 2>nul
if %errorlevel% == 0 (
    echo    ✅ Database connection successful
) else (
    echo    ❌ Database connection failed
    echo    Run 'reset-database.bat' to fix
)

echo.
echo ========================================
echo    Database Status Complete!
echo ========================================
echo.
echo Available Commands:
echo - open-database.bat    : Open Prisma Studio
echo - reset-database.bat   : Reset database
echo - start-all.bat        : Start full system
echo.
echo Press any key to exit...
pause >nul
