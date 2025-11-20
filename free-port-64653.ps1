# Script to free port 64653 from Windows excluded port range
# NOTE: This requires Administrator privileges

Write-Host "Port 64653 is in Windows excluded port range" -ForegroundColor Yellow
Write-Host "This means Windows has reserved it and it cannot be used by applications." -ForegroundColor Yellow
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To free port 64653, you need to:" -ForegroundColor Cyan
    Write-Host "1. Run PowerShell as Administrator" -ForegroundColor White
    Write-Host "2. Check what's reserving it:" -ForegroundColor White
    Write-Host "   netsh int ipv4 show excludedportrange protocol=tcp" -ForegroundColor Gray
    Write-Host "3. Identify the service (often Hyper-V, WSL, or Docker)" -ForegroundColor White
    Write-Host "4. Disable that service or reconfigure it" -ForegroundColor White
    Write-Host ""
    Write-Host "RECOMMENDED: Use a different port instead (already configured: 8080)" -ForegroundColor Green
    Write-Host "   flutter run -d chrome --web-port=8080" -ForegroundColor Gray
    exit 1
}

Write-Host "Checking excluded port ranges..." -ForegroundColor Cyan
$excluded = netsh int ipv4 show excludedportrange protocol=tcp

if ($excluded -match "64653") {
    Write-Host "Port 64653 is excluded. Checking what service might be using it..." -ForegroundColor Yellow
    
    # Common services that reserve ports
    Write-Host "`nCommon services that reserve ports:" -ForegroundColor Cyan
    Write-Host "- Hyper-V" -ForegroundColor White
    Write-Host "- Windows Subsystem for Linux (WSL)" -ForegroundColor White
    Write-Host "- Docker Desktop" -ForegroundColor White
    Write-Host "- Windows NAT" -ForegroundColor White
    
    Write-Host "`nTo identify the service:" -ForegroundColor Cyan
    Write-Host "1. Check Hyper-V: Get-NetNatStaticMapping" -ForegroundColor Gray
    Write-Host "2. Check WSL: wsl --list --verbose" -ForegroundColor Gray
    Write-Host "3. Check Docker: docker ps" -ForegroundColor Gray
    
    Write-Host "`nNOTE: Removing port from excluded range may break services using it!" -ForegroundColor Red
    Write-Host "RECOMMENDED: Use port 8080 instead (already configured)" -ForegroundColor Green
} else {
    Write-Host "Port 64653 is not in excluded range. Checking active connections..." -ForegroundColor Cyan
    netstat -ano | findstr :64653
}




