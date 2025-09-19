Write-Host "Starting PMS Flutter Frontend..." -ForegroundColor Green
Write-Host ""

# Get the directory where this script is located
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectPath = Split-Path -Parent $scriptPath
$flutterPath = Join-Path $projectPath "pms_app"

Set-Location $flutterPath
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Getting Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "Starting Flutter web app on http://localhost:8080" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the app" -ForegroundColor Yellow
Write-Host ""

flutter run -d web-server --web-port 8080
