Write-Host "Stopping all PMS processes..." -ForegroundColor Red
Write-Host ""

Write-Host "Killing Node.js processes..." -ForegroundColor Yellow
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $nodeProcesses | Stop-Process -Force
    Write-Host "Backend server stopped." -ForegroundColor Green
} else {
    Write-Host "No Node.js processes found." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Killing Flutter processes..." -ForegroundColor Yellow
$flutterProcesses = Get-Process -Name "flutter" -ErrorAction SilentlyContinue
if ($flutterProcesses) {
    $flutterProcesses | Stop-Process -Force
    Write-Host "Flutter app stopped." -ForegroundColor Green
} else {
    Write-Host "No Flutter processes found." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Killing Dart processes..." -ForegroundColor Yellow
$dartProcesses = Get-Process -Name "dart" -ErrorAction SilentlyContinue
if ($dartProcesses) {
    $dartProcesses | Stop-Process -Force
    Write-Host "Dart processes stopped." -ForegroundColor Green
} else {
    Write-Host "No Dart processes found." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "All PMS processes have been stopped." -ForegroundColor Green
Write-Host "Press any key to close this window..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
