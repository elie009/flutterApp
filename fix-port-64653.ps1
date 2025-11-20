# Comprehensive script to fix port 64653 issue
# This will either free the port OR switch to an available port

Write-Host "=== Port 64653 Fix Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if port 64653 is available
$port64653InUse = netstat -ano | findstr ":64653" | findstr "LISTENING"
$port64653Excluded = netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"

if ($port64653InUse -or $port64653Excluded) {
    Write-Host "Port 64653 is BLOCKED" -ForegroundColor Red
    Write-Host ""
    
    # Check if running as admin
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($isAdmin) {
        Write-Host "Running as Administrator - Attempting to free port 64653..." -ForegroundColor Yellow
        
        # Shut down WSL
        Write-Host "Shutting down WSL..." -ForegroundColor Cyan
        wsl --shutdown 2>$null
        
        # Try to remove exclusion
        Write-Host "Removing port from excluded range..." -ForegroundColor Cyan
        $result = netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Port 64653 should now be available!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Wait 5 seconds for changes to take effect..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
            
            # Verify
            $stillExcluded = netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
            if (-not $stillExcluded) {
                Write-Host "Port 64653 is now FREE!" -ForegroundColor Green
                $use64653 = $true
            } else {
                Write-Host "Port still excluded. May need restart." -ForegroundColor Yellow
                $use64653 = $false
            }
        } else {
            Write-Host "Failed to remove exclusion. Port may be in use by another service." -ForegroundColor Red
            $use64653 = $false
        }
    } else {
        Write-Host "NOT running as Administrator" -ForegroundColor Yellow
        Write-Host "Cannot free port 64653 without admin rights." -ForegroundColor Yellow
        $use64653 = $false
    }
} else {
    Write-Host "Port 64653 appears to be AVAILABLE!" -ForegroundColor Green
    $use64653 = $true
}

# If port 64653 is not available, find alternative
if (-not $use64653) {
    Write-Host ""
    Write-Host "Finding alternative port..." -ForegroundColor Cyan
    
    $alternativePorts = @(8080, 3000, 5000, 5173, 4200, 8081, 3001)
    $availablePort = $null
    
    foreach ($port in $alternativePorts) {
        $inUse = netstat -ano | findstr ":$port" | findstr "LISTENING"
        if (-not $inUse) {
            $availablePort = $port
            Write-Host "Found available port: $port" -ForegroundColor Green
            break
        }
    }
    
    if ($availablePort) {
        Write-Host ""
        Write-Host "SOLUTION: Use port $availablePort instead" -ForegroundColor Green
        Write-Host "Run: flutter run -d chrome --web-port=$availablePort" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Or update your scripts to use port $availablePort" -ForegroundColor Yellow
        
        # Ask if user wants to update scripts
        $update = Read-Host "Update scripts to use port $availablePort? (Y/N)"
        if ($update -eq "Y" -or $update -eq "y") {
            # Update run-web.ps1
            (Get-Content run-web.ps1) -replace "64653", $availablePort | Set-Content run-web.ps1
            # Update run-web.bat
            (Get-Content run-web.bat) -replace "64653", $availablePort | Set-Content run-web.bat
            # Update launch.json
            (Get-Content .vscode/launch.json) -replace "64653", $availablePort | Set-Content .vscode/launch.json
            Write-Host "Scripts updated to use port $availablePort" -ForegroundColor Green
        }
    } else {
        Write-Host "No common ports available. Flutter will auto-select a port." -ForegroundColor Yellow
        Write-Host "Run: flutter run -d chrome" -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "Port 64653 is ready to use!" -ForegroundColor Green
    Write-Host "Run: flutter run -d chrome --web-port=64653" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan




