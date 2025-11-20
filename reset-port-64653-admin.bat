@echo off
REM Reset Port 64653 - Must run as Administrator
echo ========================================
echo Resetting Port 64653
echo ========================================
echo.

REM Check for admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo.
    echo Right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo [1/4] Shutting down WSL...
wsl --shutdown
timeout /t 2 /nobreak >nul

echo [2/4] Stopping WSL Service...
net stop WSLService >nul 2>&1
timeout /t 1 /nobreak >nul

echo [3/4] Removing port 64653 from excluded range...
netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1
if %errorLevel% equ 0 (
    echo    SUCCESS: Port exclusion removed
) else (
    echo    WARNING: Failed to remove exclusion
)

echo [4/4] Verifying...
timeout /t 2 /nobreak >nul
netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653" >nul
if %errorLevel% equ 0 (
    echo    WARNING: Port still in excluded range
    echo    You may need to restart your computer
) else (
    echo    SUCCESS: Port removed from excluded range
)

echo.
echo ========================================
echo Reset Complete
echo ========================================
echo.
echo Check port status:
netstat -ano | findstr ":64653"
echo.
echo If port is still blocked, restart your computer.
echo.
pause




