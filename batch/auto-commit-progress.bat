@echo off
setlocal enabledelayedexpansion

:: Set colors
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                Professional PMS - Auto Commit                ║
echo ║                    with Progress Bar                         ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

:: Function to show progress bar
:showProgress
set /a progress=%1
set /a total=%2
set /a percentage=(%progress%*100)/%total%
set /a filled=(%percentage%*50)/100
set /a empty=50-%filled%

set "bar="
for /l %%i in (1,1,%filled%) do set "bar=!bar!█"
for /l %%i in (1,1,%empty%) do set "bar=!bar!░"

echo [%progress%/%total%] %bar% %percentage%%%
goto :eof

:: Check if git is available
echo [1/7] Checking Git installation...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Git is not installed or not in PATH
    pause
    exit /b 1
)
call :showProgress 1 7
echo ✓ Git is available

:: Check if we're in a git repository
echo [2/7] Checking Git repository...
git status >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Not in a git repository
    pause
    exit /b 1
)
call :showProgress 2 7
echo ✓ Git repository found

:: Count changed files
echo [3/7] Analyzing changes...
git status --porcelain > temp_status.txt
set /a total_files=0
for /f %%i in (temp_status.txt) do set /a total_files+=1

if %total_files%==0 (
    echo.
    echo ℹ️  No changes to commit.
    del temp_status.txt
    pause
    exit /b 0
)
call :showProgress 3 7
echo ✓ Found %total_files% files with changes

:: Get commit message
echo [4/7] Getting commit message...
set /p commit_msg="Enter commit message (or press Enter for auto-generated): "
if "%commit_msg%"=="" (
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
    for /f "tokens=1-2 delims=: " %%a in ('time /t') do set mytime=%%a:%%b
    set commit_msg=Auto commit - %mydate% %mytime%
)
call :showProgress 4 7
echo ✓ Commit message: %commit_msg%

:: Add files to staging
echo [5/7] Staging files...
git add -A
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to add files to staging area
    del temp_status.txt
    pause
    exit /b 1
)
call :showProgress 5 7
echo ✓ Files staged successfully

:: Create commit
echo [6/7] Creating commit...
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to create commit
    del temp_status.txt
    pause
    exit /b 1
)
call :showProgress 6 7
echo ✓ Commit created successfully

:: Get commit details
echo [7/7] Finalizing...
for /f "tokens=*" %%i in ('git log -1 --format=%%H') do set commit_hash=%%i
for /f "tokens=*" %%i in ('git log -1 --format=%%s') do set commit_subject=%%i
for /f "tokens=*" %%i in ('git log -1 --format=%%ci') do set commit_date=%%i
call :showProgress 7 7
echo ✓ Process completed

:: Clean up
del temp_status.txt 2>nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    COMMIT SUMMARY                            ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║ Files Changed: %total_files%                                        ║
echo ║ Commit Hash: %commit_hash:~0,12%...                           ║
echo ║ Commit Message: %commit_subject%                              ║
echo ║ Commit Date: %commit_date%                                    ║
echo ╚══════════════════════════════════════════════════════════════╝

echo.
echo 🎉 All changes committed successfully!
echo.
echo Press any key to continue...
pause >nul
