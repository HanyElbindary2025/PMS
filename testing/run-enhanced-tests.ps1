Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Enhanced PMS Workflow Tester" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting enhanced workflow test with comprehensive logging..." -ForegroundColor Yellow
Write-Host ""

# Create logs and reports directories
if (!(Test-Path "logs")) { New-Item -ItemType Directory -Name "logs" }
if (!(Test-Path "reports")) { New-Item -ItemType Directory -Name "reports" }

Write-Host "[INFO] Running enhanced workflow tester..." -ForegroundColor Green
Write-Host "[INFO] Logs will be saved to: testing/logs/" -ForegroundColor Green
Write-Host "[INFO] Reports will be saved to: testing/reports/" -ForegroundColor Green
Write-Host ""

node enhanced-workflow-tester.js

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "    Enhanced Test completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Check the following for detailed results:" -ForegroundColor Yellow
Write-Host "- Logs: testing/logs/" -ForegroundColor White
Write-Host "- Reports: testing/reports/" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue"
