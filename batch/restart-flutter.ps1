Write-Host "Restarting Flutter App with Cache Clear..." -ForegroundColor Green
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectPath = Split-Path -Parent $scriptPath
$flutterPath = Join-Path $projectPath "pms_app"

Set-Location $flutterPath

Write-Host "Clearing Flutter cache..." -ForegroundColor Yellow
flutter clean

Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "Starting Flutter app..." -ForegroundColor Green
flutter run -d web-server --web-port 8080
