@echo off
title PMS Database Reset
color 0C

echo.
echo ========================================
echo    PMS Database Reset
echo ========================================
echo.

echo ⚠️  WARNING: This will delete all data!
echo.
set /p confirm="Are you sure you want to reset the database? (y/N): "

if /i "%confirm%"=="y" (
    echo.
    echo [1/3] Stopping all services...
    taskkill /f /im node.exe >nul 2>&1
    
    echo [2/3] Resetting database...
    if exist "prisma\dev.db" del "prisma\dev.db"
    if exist "prisma\migrations" rmdir /s /q "prisma\migrations"
    
    echo [3/3] Creating fresh database...
    npx prisma migrate dev --name init
    npx prisma db seed
    
    echo.
    echo ✅ Database reset complete!
    echo    Fresh database created with sample data
) else (
    echo.
    echo ❌ Database reset cancelled
)

echo.
echo Press any key to exit...
pause >nul
