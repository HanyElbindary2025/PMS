@echo off
echo Starting PMS Flutter Frontend...
cd /d "D:\projects\PMS\pms_app"
echo Frontend starting on http://localhost:8080
flutter run -d chrome --web-port 8080 --web-hostname localhost
pause
