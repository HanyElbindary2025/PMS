@echo off
echo Restarting Flutter App with Cache Clear...
echo.

cd /d "%~dp0..\pms_app"

echo Clearing Flutter cache...
flutter clean

echo Getting Flutter dependencies...
flutter pub get

echo Starting Flutter app...
flutter run -d web-server --web-port 8080

pause
