@echo off
echo ============================================
echo FREE PORT 64653 - MUST RUN AS ADMINISTRATOR
echo ============================================
echo.

REM Check for admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    echo.
    echo INSTRUCTIONS:
    echo 1. Right-click this file
    echo 2. Select "Run as administrator"
    echo 3. Click Yes when prompted
    echo.
    pause
    exit /b 1
)

echo [OK] Running as Administrator
echo.

echo [Step 1/3] Shutting down WSL...
wsl --shutdown
timeout /t 2 /nobreak >nul
echo [OK] WSL shut down
echo.

echo [Step 2/3] Removing port 64653 from Windows exclusion...
netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1
if %errorLevel% equ 0 (
    echo [OK] Port exclusion removed successfully!
) else (
    echo [WARNING] Command completed with errors
)
echo.

echo [Step 3/3] Verifying...
timeout /t 1 /nobreak >nul
netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653" >nul
if %errorLevel% equ 0 (
    echo [WARNING] Port still in excluded range
    echo [INFO] You may need to restart your computer
) else (
    echo [SUCCESS] Port 64653 is now FREE!
    echo.
    echo You can now run:
    echo   flutter run -d chrome --web-port=64653
)
echo.

echo Checking if port is in use...
netstat -ano | findstr ":64653" | findstr "LISTENING"
if %errorLevel% equ 0 (
    echo [INFO] Port is still being held by a process
    echo [INFO] May need to restart computer
) else (
    echo [OK] Port appears to be free
)
echo.

echo ============================================
echo Done! Try running Flutter now.
echo ============================================
pause



