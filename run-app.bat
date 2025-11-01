@echo off
echo ========================================
echo UtilityHub360 - Flutter App Launcher
echo ========================================
echo.

REM Check if emulator is running
echo Checking for Android devices...
flutter devices

echo.
echo ========================================
echo Instructions:
echo ========================================
echo.
echo Option 1: Launch Android Emulator
echo   Run: flutter emulators --launch android
echo   Wait for emulator to boot (may take 1-2 minutes)
echo   Then run: flutter run
echo.
echo Option 2: Use Physical Device
echo   1. Connect Android phone via USB
echo   2. Enable USB Debugging on phone
echo   3. Run: flutter run
echo.
echo Option 3: Run on Windows Desktop
echo   Run: flutter run -d windows
echo.
echo Option 4: Run on Web Browser
echo   Run: flutter run -d chrome
echo.
echo ========================================
echo.
pause

