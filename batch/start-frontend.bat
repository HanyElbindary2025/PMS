@echo off
echo Starting PMS Flutter Frontend...
echo.
cd /d "%~dp0..\pms_app"
echo Current directory: %CD%
echo.
echo Getting Flutter dependencies...
call flutter pub get
echo.
echo Starting Flutter web app on http://localhost:8080
echo Press Ctrl+C to stop the app
echo.
call flutter run -d web-server --web-port 8080
pause
