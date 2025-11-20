# Quick fix script - MUST RUN AS ADMINISTRATOR
# Right-click PowerShell -> Run as Administrator, then run this script

Write-Host "=== Fixing Port 64653 ===" -ForegroundColor Cyan
Write-Host ""

# Check if admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell -> Run as Administrator" -ForegroundColor Yellow
    Write-Host "Then run this script again" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Step 1: Shutting down WSL..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 2

Write-Host "Step 2: Removing port 64653 from excluded range..." -ForegroundColor Yellow
$result = netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS!" -ForegroundColor Green
} else {
    Write-Host "Error: $result" -ForegroundColor Red
}

Write-Host ""
Write-Host "Step 3: Verifying..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
$check = netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"

if ($check) {
    Write-Host "WARNING: Port still excluded. May need restart." -ForegroundColor Yellow
} else {
    Write-Host "SUCCESS: Port 64653 is now free!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run:" -ForegroundColor Cyan
    Write-Host "flutter run -d chrome --web-port=64653" -ForegroundColor Gray
}

Write-Host ""
pause



