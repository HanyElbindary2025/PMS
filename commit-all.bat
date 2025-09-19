@echo off
echo Starting Professional PMS Auto Commit...
echo.

:: Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell not available, using basic batch version...
    call auto-commit.bat
    goto :end
)

:: Run PowerShell version
powershell -ExecutionPolicy Bypass -File "auto-commit.ps1"

:end
echo.
echo Auto commit completed!
pause
