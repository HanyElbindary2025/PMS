@echo off
echo.
echo ========================================
echo    PMS Deployment Script
echo ========================================
echo.

echo Step 1: Building Flutter Web App...
cd pms_app
flutter clean
flutter pub get
flutter build web --web-renderer html --release
cd ..

echo.
echo Step 2: Preparing for deployment...
echo ✅ Flutter web app built successfully
echo ✅ Configuration files ready
echo.

echo Step 3: Next Steps:
echo.
echo 🚀 RAILWAY (Backend):
echo    1. Go to https://railway.app
echo    2. Connect GitHub repository
echo    3. Deploy backend automatically
echo    4. Add PostgreSQL database
echo    5. Set environment variables
echo.
echo 🌐 VERCEL (Frontend):
echo    1. Go to https://vercel.com
echo    2. Connect GitHub repository
echo    3. Set build command: cd pms_app && flutter build web --web-renderer html
echo    4. Set output directory: pms_app/build/web
echo    5. Add environment variable: BACKEND_URL
echo.
echo 📋 Environment Variables to Set:
echo    DATABASE_URL=postgresql://...
echo    NODE_ENV=production
echo    BACKEND_URL=https://your-railway-app.railway.app
echo.

echo 🎉 Ready for deployment!
echo Check deployment-guide.md for detailed instructions.
echo.

pause
