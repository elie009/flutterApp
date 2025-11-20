# Comprehensive reset script to free port 64653
# This will attempt all methods to free the port

Write-Host "=== Resetting Port 64653 ===" -ForegroundColor Cyan
Write-Host ""

# Check admin status
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Administrator!" -ForegroundColor Red
    Write-Host "Some operations require admin rights." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please run PowerShell as Administrator and run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Right-click PowerShell -> Run as Administrator" -ForegroundColor Cyan
    exit 1
}

Write-Host "Running as Administrator - Proceeding with reset..." -ForegroundColor Green
Write-Host ""

# Step 1: Shut down WSL
Write-Host "[1/5] Shutting down WSL..." -ForegroundColor Cyan
wsl --shutdown
Start-Sleep -Seconds 2
Write-Host "   ✓ WSL shut down" -ForegroundColor Green

# Step 2: Stop WSL service
Write-Host "[2/5] Stopping WSL Service..." -ForegroundColor Cyan
Stop-Service -Name "WSLService" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Write-Host "   ✓ WSL Service stopped" -ForegroundColor Green

# Step 3: Check for Hyper-V NAT
Write-Host "[3/5] Checking Hyper-V NAT..." -ForegroundColor Cyan
$natMappings = Get-NetNatStaticMapping -ErrorAction SilentlyContinue | Where-Object {$_.ExternalPort -eq 64653 -or $_.InternalPort -eq 64653}
if ($natMappings) {
    Write-Host "   ⚠ Found Hyper-V NAT mappings on port 64653" -ForegroundColor Yellow
    Write-Host "   Removing NAT mappings..." -ForegroundColor Yellow
    $natMappings | Remove-NetNatStaticMapping -ErrorAction SilentlyContinue
    Write-Host "   ✓ NAT mappings removed" -ForegroundColor Green
} else {
    Write-Host "   ✓ No Hyper-V NAT mappings found" -ForegroundColor Green
}

# Step 4: Remove port from excluded range
Write-Host "[4/5] Removing port 64653 from excluded range..." -ForegroundColor Cyan
$result = netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Port exclusion removed successfully" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Failed to remove exclusion: $result" -ForegroundColor Yellow
    Write-Host "   This may require a system restart" -ForegroundColor Yellow
}

# Step 5: Verify
Write-Host "[5/5] Verifying port status..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

$stillExcluded = netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
$stillInUse = netstat -ano | findstr ":64653" | findstr "LISTENING"

if ($stillExcluded) {
    Write-Host "   ⚠ Port still in excluded range" -ForegroundColor Yellow
    Write-Host "   May need to restart Windows for changes to take effect" -ForegroundColor Yellow
} else {
    Write-Host "   ✓ Port removed from excluded range" -ForegroundColor Green
}

if ($stillInUse) {
    $pid = ($stillInUse -split '\s+')[-1]
    Write-Host "   ⚠ Port still in use by PID: $pid" -ForegroundColor Yellow
    
    if ($pid -eq "4") {
        Write-Host "   System process still holding port - may need restart" -ForegroundColor Yellow
    } else {
        Write-Host "   Attempting to close connection..." -ForegroundColor Yellow
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
} else {
    Write-Host "   ✓ Port appears to be free" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Reset Complete ===" -ForegroundColor Cyan
Write-Host ""

# Final check
Write-Host "Final Status:" -ForegroundColor Cyan
$finalExcluded = netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
$finalInUse = netstat -ano | findstr ":64653" | findstr "LISTENING"

if ($finalExcluded -or $finalInUse) {
    Write-Host "❌ Port 64653 is still blocked" -ForegroundColor Red
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Restart your computer (recommended)" -ForegroundColor White
    Write-Host "2. Or try disabling WSL completely:" -ForegroundColor White
    Write-Host "   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux" -ForegroundColor Gray
} else {
    Write-Host "Port 64653 should now be available!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Try running:" -ForegroundColor Cyan
    Write-Host "flutter run -d chrome --web-port=64653" -ForegroundColor Gray
}

