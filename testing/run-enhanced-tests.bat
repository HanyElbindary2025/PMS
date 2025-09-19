@echo off
echo ========================================
echo    Enhanced PMS Workflow Tester
echo ========================================
echo.
echo Starting enhanced workflow test with comprehensive logging...
echo.

REM Create logs and reports directories
if not exist "logs" mkdir logs
if not exist "reports" mkdir reports

echo [INFO] Running enhanced workflow tester...
echo [INFO] Logs will be saved to: testing/logs/
echo [INFO] Reports will be saved to: testing/reports/
echo.

node enhanced-workflow-tester.js

echo.
echo ========================================
echo    Enhanced Test completed!
echo ========================================
echo.
echo Check the following for detailed results:
echo - Logs: testing/logs/
echo - Reports: testing/reports/
echo.
pause
