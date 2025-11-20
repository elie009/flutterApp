# Remove port 64653 from Windows excluded port range
# This requires Administrator privileges

Write-Host "Attempting to remove port 64653 from Windows excluded port range..." -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To run this script:" -ForegroundColor Yellow
    Write-Host "1. Right-click PowerShell" -ForegroundColor White
    Write-Host "2. Select 'Run as Administrator'" -ForegroundColor White
    Write-Host "3. Navigate to this directory" -ForegroundColor White
    Write-Host "4. Run: .\remove-port-exclusion-64653.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternatively, you can manually run:" -ForegroundColor Cyan
    Write-Host "netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1" -ForegroundColor Gray
    exit 1
}

Write-Host "Checking current excluded port ranges..." -ForegroundColor Cyan
$excluded = netsh int ipv4 show excludedportrange protocol=tcp
Write-Host $excluded

Write-Host "`nAttempting to remove port 64653 from excluded range..." -ForegroundColor Yellow

# Try to remove the exclusion
$result = netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Port 64653 has been removed from excluded range!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Verifying..." -ForegroundColor Cyan
    $verify = netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
    if ($verify) {
        Write-Host "WARNING: Port still appears in excluded range. May need to restart Windows or the service using it." -ForegroundColor Yellow
    } else {
        Write-Host "Confirmed: Port 64653 is now available!" -ForegroundColor Green
    }
} else {
    Write-Host "ERROR: Failed to remove port exclusion." -ForegroundColor Red
    Write-Host $result
    Write-Host ""
    Write-Host "The port may be actively used by:" -ForegroundColor Yellow
    Write-Host "- WSL (Windows Subsystem for Linux)" -ForegroundColor White
    Write-Host "- Hyper-V" -ForegroundColor White
    Write-Host "- Docker Desktop" -ForegroundColor White
    Write-Host ""
    Write-Host "You may need to:" -ForegroundColor Cyan
    Write-Host "1. Stop WSL: wsl --shutdown" -ForegroundColor Gray
    Write-Host "2. Stop Hyper-V services" -ForegroundColor Gray
    Write-Host "3. Then try removing the exclusion again" -ForegroundColor Gray
}

Write-Host ""
Write-Host "After removing the exclusion, you can use:" -ForegroundColor Cyan
Write-Host "flutter run -d chrome --web-port=64653" -ForegroundColor Gray




