Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    PMS Local Testing Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Starting Backend Server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "npm run dev" -WindowStyle Normal

Write-Host ""
Write-Host "Step 2: Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Step 3: Starting Flutter Frontend..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd pms_app; flutter run -d web-server --web-port 8080" -WindowStyle Normal

Write-Host ""
Write-Host "Step 4: Opening browser..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Start-Process "http://localhost:8080"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    System is starting up..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend: http://localhost:3000" -ForegroundColor White
Write-Host "Frontend: http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "Test Accounts:" -ForegroundColor Yellow
Write-Host "- admin@pms.com (Admin)" -ForegroundColor White
Write-Host "- developer@pms.com (Developer)" -ForegroundColor White
Write-Host "- qa@pms.com (QA Engineer)" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Green
Read-Host
