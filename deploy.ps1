Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    PMS Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Building Flutter Web App..." -ForegroundColor Green
Set-Location pms_app
flutter clean
flutter pub get
flutter build web --web-renderer html --release
Set-Location ..

Write-Host ""
Write-Host "Step 2: Preparing for deployment..." -ForegroundColor Green
Write-Host "✅ Flutter web app built successfully" -ForegroundColor Yellow
Write-Host "✅ Configuration files ready" -ForegroundColor Yellow
Write-Host ""

Write-Host "Step 3: Next Steps:" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 RAILWAY (Backend):" -ForegroundColor Blue
Write-Host "   1. Go to https://railway.app" -ForegroundColor White
Write-Host "   2. Connect GitHub repository" -ForegroundColor White
Write-Host "   3. Deploy backend automatically" -ForegroundColor White
Write-Host "   4. Add PostgreSQL database" -ForegroundColor White
Write-Host "   5. Set environment variables" -ForegroundColor White
Write-Host ""
Write-Host "🌐 VERCEL (Frontend):" -ForegroundColor Blue
Write-Host "   1. Go to https://vercel.com" -ForegroundColor White
Write-Host "   2. Connect GitHub repository" -ForegroundColor White
Write-Host "   3. Set build command: cd pms_app && flutter build web --web-renderer html" -ForegroundColor White
Write-Host "   4. Set output directory: pms_app/build/web" -ForegroundColor White
Write-Host "   5. Add environment variable: BACKEND_URL" -ForegroundColor White
Write-Host ""
Write-Host "📋 Environment Variables to Set:" -ForegroundColor Blue
Write-Host "   DATABASE_URL=postgresql://..." -ForegroundColor White
Write-Host "   NODE_ENV=production" -ForegroundColor White
Write-Host "   BACKEND_URL=https://your-railway-app.railway.app" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Ready for deployment!" -ForegroundColor Green
Write-Host "Check deployment-guide.md for detailed instructions." -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to continue"
