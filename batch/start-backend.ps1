Write-Host "Starting PMS Backend Server..." -ForegroundColor Green
Write-Host ""

# Get the directory where this script is located
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectPath = Split-Path -Parent $scriptPath

Set-Location $projectPath
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Installing dependencies..." -ForegroundColor Cyan
npm install

Write-Host ""
Write-Host "Starting backend server on http://localhost:3000" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

npm run dev
