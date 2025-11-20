# Check if a port is in use and show what's using it
param(
    [int]$Port = 8080
)

Write-Host "Checking port $Port..." -ForegroundColor Cyan
$connections = netstat -ano | findstr ":$Port"

if ($connections) {
    Write-Host "`nPort $Port is in use:" -ForegroundColor Yellow
    Write-Host $connections
    
    # Extract PIDs
    $pids = $connections | ForEach-Object {
        if ($_ -match '\s+(\d+)$') {
            $matches[1]
        }
    } | Sort-Object -Unique
    
    Write-Host "`nProcess IDs using this port:" -ForegroundColor Yellow
    foreach ($pid in $pids) {
        try {
            $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "  PID $pid : $($process.ProcessName) - $($process.Path)" -ForegroundColor Red
            } else {
                Write-Host "  PID $pid : (Process not found or system process)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  PID $pid : (Cannot access)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "Port $Port is available!" -ForegroundColor Green
}

Write-Host "`nTo free up a port, you can:" -ForegroundColor Cyan
Write-Host "1. Close the application using it" -ForegroundColor White
Write-Host "2. Kill the process: Stop-Process -Id <PID> -Force" -ForegroundColor White
Write-Host "3. Use a different port: flutter run -d chrome --web-port=<PORT>" -ForegroundColor White




