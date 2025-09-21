@echo off
title PMS System - Quick Stop
color 0C

echo.
echo ========================================
echo    PMS System - Quick Stop
echo ========================================
echo.

echo Stopping PMS System...
call batch\stop-all.bat

echo.
echo System stopped!
echo.
pause
