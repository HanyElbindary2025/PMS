Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Opening Prisma Studio" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting Prisma Studio..." -ForegroundColor Green
Write-Host "This will open in your browser at: http://localhost:5555" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop Prisma Studio" -ForegroundColor Red
Write-Host ""

npx prisma studio

Read-Host "Press Enter to continue"
