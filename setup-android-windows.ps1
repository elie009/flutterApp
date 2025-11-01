# Android Setup Script for Windows 11 (Without Android Studio)
# This script helps set up Android SDK command line tools

Write-Host "Android Setup for Flutter on Windows 11" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

# Check if Android SDK is installed
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    Write-Host "ANDROID_HOME not set. Checking common locations..." -ForegroundColor Yellow
    
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:USERPROFILE\AppData\Local\Android\Sdk",
        "C:\Android\Sdk",
        "C:\Program Files (x86)\Android\android-sdk"
    )
    
    foreach ($path in $possiblePaths) {
        $adbPath = Join-Path $path "platform-tools\adb.exe"
        if (Test-Path $adbPath) {
            $androidHome = $path
            Write-Host "Found Android SDK at: $androidHome" -ForegroundColor Green
            break
        }
    }
}

if ($androidHome) {
    $adbPath = Join-Path $androidHome "platform-tools\adb.exe"
    if (Test-Path $adbPath) {
        Write-Host "Android SDK found at: $androidHome" -ForegroundColor Green
        
        # Check for emulator
        $emulatorPath = Join-Path $androidHome "emulator\emulator.exe"
        if (Test-Path $emulatorPath) {
            Write-Host "Android Emulator found" -ForegroundColor Green
            
            Write-Host ""
            Write-Host "Available Android Virtual Devices:" -ForegroundColor Cyan
            & $emulatorPath -list-avds
            
            Write-Host ""
            Write-Host "To start an emulator, use:" -ForegroundColor Yellow
            Write-Host "  flutter emulators" -ForegroundColor White
            Write-Host "  flutter emulators --launch <emulator-id>" -ForegroundColor White
        } else {
            Write-Host "Android Emulator not found" -ForegroundColor Red
            Write-Host "You need to install the Android Emulator package." -ForegroundColor Yellow
        }
        
        # Check for sdkmanager
        $sdkmanagerPath1 = Join-Path $androidHome "cmdline-tools\latest\bin\sdkmanager.bat"
        $sdkmanagerPath2 = Join-Path $androidHome "tools\bin\sdkmanager.bat"
        
        $sdkmanager = $null
        if (Test-Path $sdkmanagerPath1) {
            $sdkmanager = $sdkmanagerPath1
        } elseif (Test-Path $sdkmanagerPath2) {
            $sdkmanager = $sdkmanagerPath2
        }
        
        if ($sdkmanager) {
            Write-Host "SDK Manager found" -ForegroundColor Green
            Write-Host ""
            Write-Host "To install required packages, run:" -ForegroundColor Yellow
            Write-Host "  $sdkmanager platform-tools platforms;android-34 build-tools;34.0.0 emulator system-images;android-34;google_apis;x86_64" -ForegroundColor White
        }
    }
} else {
    Write-Host "Android SDK not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "You have two options:" -ForegroundColor Yellow
    Write-Host "1. Install Android Studio (but you don't need to use it)" -ForegroundColor White
    Write-Host "   Download from: https://developer.android.com/studio" -ForegroundColor White
    Write-Host "2. Install Android SDK Command Line Tools only" -ForegroundColor White
    Write-Host "   Download from: https://developer.android.com/studio#command-tools" -ForegroundColor White
    Write-Host "   Extract to: C:\Android\Sdk" -ForegroundColor White
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Alternative: Use a Physical Android Device" -ForegroundColor Cyan
Write-Host "1. Enable Developer Options on your phone" -ForegroundColor White
Write-Host "2. Enable USB Debugging" -ForegroundColor White
Write-Host "3. Connect via USB" -ForegroundColor White
Write-Host "4. Run: flutter devices" -ForegroundColor White
Write-Host "5. Run: flutter run" -ForegroundColor White
