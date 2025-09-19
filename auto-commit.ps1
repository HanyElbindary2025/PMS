# Professional PMS - Auto Commit with Progress Bar
# PowerShell version with enhanced progress visualization

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                Professional PMS - Auto Commit                ║" -ForegroundColor Cyan
Write-Host "║              PowerShell Version with Progress                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Function to show progress bar
function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Processing"
    )
    
    $percent = [math]::Round(($Current / $Total) * 100, 1)
    $filled = [math]::Round(($percent / 100) * 50)
    $empty = 50 - $filled
    
    $bar = "█" * $filled + "░" * $empty
    Write-Host "[$Current/$Total] $bar $percent%" -ForegroundColor Green
}

# Check if git is available
Write-Host "[1/7] Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Git not found"
    }
    Show-Progress 1 7
    Write-Host "✓ Git is available: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if we're in a git repository
Write-Host "[2/7] Checking Git repository..." -ForegroundColor Yellow
try {
    git status 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Not a git repository"
    }
    Show-Progress 2 7
    Write-Host "✓ Git repository found" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Not in a git repository" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Count changed files
Write-Host "[3/7] Analyzing changes..." -ForegroundColor Yellow
$changedFiles = git status --porcelain
$totalFiles = ($changedFiles | Measure-Object).Count

if ($totalFiles -eq 0) {
    Write-Host ""
    Write-Host "ℹ️  No changes to commit." -ForegroundColor Blue
    Read-Host "Press Enter to exit"
    exit 0
}

Show-Progress 3 7
Write-Host "✓ Found $totalFiles files with changes" -ForegroundColor Green

# Get commit message
Write-Host "[4/7] Getting commit message..." -ForegroundColor Yellow
$commitMsg = Read-Host "Enter commit message (or press Enter for auto-generated)"
if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $commitMsg = "Auto commit - $timestamp"
}
Show-Progress 4 7
Write-Host "✓ Commit message: $commitMsg" -ForegroundColor Green

# Add files to staging
Write-Host "[5/7] Staging files..." -ForegroundColor Yellow
try {
    git add -A 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage files"
    }
    Show-Progress 5 7
    Write-Host "✓ Files staged successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Failed to add files to staging area" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Create commit
Write-Host "[6/7] Creating commit..." -ForegroundColor Yellow
try {
    git commit -m $commitMsg 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create commit"
    }
    Show-Progress 6 7
    Write-Host "✓ Commit created successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Failed to create commit" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Get commit details
Write-Host "[7/7] Finalizing..." -ForegroundColor Yellow
$commitHash = git log -1 --format="%H" 2>$null
$commitSubject = git log -1 --format="%s" 2>$null
$commitDate = git log -1 --format="%ci" 2>$null
Show-Progress 7 7
Write-Host "✓ Process completed" -ForegroundColor Green

# Display summary
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    COMMIT SUMMARY                            ║" -ForegroundColor Cyan
Write-Host "╠══════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║ Files Changed: $totalFiles" -ForegroundColor White
Write-Host "║ Commit Hash: $($commitHash.Substring(0,12))..." -ForegroundColor White
Write-Host "║ Commit Message: $commitSubject" -ForegroundColor White
Write-Host "║ Commit Date: $commitDate" -ForegroundColor White
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎉 All changes committed successfully!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to continue"
