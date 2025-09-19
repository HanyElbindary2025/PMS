Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    PMS Workflow Tester Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting comprehensive workflow test..." -ForegroundColor Yellow
Write-Host ""

node test-simplified-workflow.js

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "    Test completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Read-Host "Press Enter to continue"
