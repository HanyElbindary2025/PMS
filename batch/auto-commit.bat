@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    Professional PMS - Auto Commit
echo ========================================
echo.

:: Check if git is available
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH
    pause
    exit /b 1
)

:: Check if we're in a git repository
git status >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Not in a git repository
    pause
    exit /b 1
)

echo [1/6] Checking git status...
git status --porcelain > temp_status.txt
set /a total_files=0
for /f %%i in (temp_status.txt) do set /a total_files+=1

if %total_files%==0 (
    echo No changes to commit.
    del temp_status.txt
    pause
    exit /b 0
)

echo Found %total_files% files with changes
echo.

:: Get commit message from user or use default
set /p commit_msg="Enter commit message (or press Enter for auto-generated): "
if "%commit_msg%"=="" (
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
    for /f "tokens=1-2 delims=: " %%a in ('time /t') do set mytime=%%a:%%b
    set commit_msg=Auto commit - %mydate% %mytime%
)

echo.
echo [2/6] Adding all files to staging area...
git add -A
if %errorlevel% neq 0 (
    echo ERROR: Failed to add files to staging area
    del temp_status.txt
    pause
    exit /b 1
)
echo ✓ Files added to staging area

echo.
echo [3/6] Checking staged files...
git diff --cached --name-only > temp_staged.txt
set /a staged_files=0
for /f %%i in (temp_staged.txt) do set /a staged_files+=1
echo ✓ %staged_files% files staged for commit

echo.
echo [4/6] Creating commit...
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create commit
    del temp_status.txt
    del temp_staged.txt
    pause
    exit /b 1
)
echo ✓ Commit created successfully

echo.
echo [5/6] Getting commit information...
for /f "tokens=*" %%i in ('git log -1 --format=%%H') do set commit_hash=%%i
for /f "tokens=*" %%i in ('git log -1 --format=%%s') do set commit_subject=%%i
for /f "tokens=*" %%i in ('git log -1 --format=%%ci') do set commit_date=%%i

echo ✓ Commit Hash: %commit_hash:~0,8%...
echo ✓ Commit Message: %commit_subject%
echo ✓ Commit Date: %commit_date%

echo.
echo [6/6] Finalizing...
echo ✓ All changes committed successfully!

echo.
echo ========================================
echo           COMMIT SUMMARY
echo ========================================
echo Files Changed: %total_files%
echo Files Staged: %staged_files%
echo Commit Hash: %commit_hash:~0,8%...
echo Commit Message: %commit_subject%
echo ========================================

:: Clean up temporary files
del temp_status.txt 2>nul
del temp_staged.txt 2>nul

echo.
echo Press any key to continue...
pause >nul
