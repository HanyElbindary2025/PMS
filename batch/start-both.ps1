Write-Host "Starting PMS Backend and Frontend..." -ForegroundColor Green
Write-Host ""

# Get the directory where this script is located
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectPath = Split-Path -Parent $scriptPath

Set-Location $projectPath
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Backend Server..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Start backend in new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath'; npm install; npm run dev" -WindowStyle Normal

Write-Host "Waiting 5 seconds for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Frontend App..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$flutterPath = Join-Path $projectPath "pms_app"

# Start frontend in new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$flutterPath'; flutter pub get; flutter run -d web-server --web-port 8080" -WindowStyle Normal

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Both servers are starting..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Backend: http://localhost:3000" -ForegroundColor Yellow
Write-Host "Frontend: http://localhost:8080" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to close this window..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
