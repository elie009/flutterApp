# How to Run UtilityHub360 App on Windows 11

## ✅ Your Setup is Complete!

Android SDK and Emulator are already installed at:
- **Android SDK**: `C:\Users\Elie\AppData\Local\Android\Sdk`
- **Android Emulator**: Available ✓

## 🚀 Quick Start

### Option 1: Launch Emulator and Run (Recommended)

1. **Start Android Emulator:**
   ```bash
   flutter emulators --launch android
   ```
   Or use the emulator ID if available:
   ```bash
   flutter emulators --launch <emulator-id>
   ```

2. **Wait for emulator to fully boot** (may take 1-2 minutes)

3. **Check connected devices:**
   ```bash
   flutter devices
   ```
   You should see your emulator listed.

4. **Run the app:**
   ```bash
   flutter run
   ```

### Option 2: Use Physical Android Device

1. **Enable Developer Options:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times

2. **Enable USB Debugging:**
   - Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect device via USB**

4. **Run:**
   ```bash
   flutter devices  # Verify device is connected
   flutter run
   ```

### Option 3: Run on Web (Limited Features)

```bash
flutter run -d chrome
```

**Note:** Web version has limitations and may not support all native features.

## 📝 Current Status

- ✅ Flutter installed and configured
- ✅ Android SDK found at: `C:\Users\Elie\AppData\Local\Android\Sdk`
- ✅ Android Emulator available
- ✅ Dependencies installed (`flutter pub get` completed)

## 🔧 Troubleshooting

### If emulator doesn't start:

1. **Create a new emulator:**
   ```bash
   flutter emulators --create
   ```

2. **List all emulators:**
   ```bash
   flutter emulators
   ```

3. **Launch specific emulator:**
   ```bash
   flutter emulators --launch <emulator-name>
   ```

### If "No devices found":

1. **Check if emulator is running:**
   - Look for the emulator window on your screen
   - Wait for it to fully boot (home screen appears)

2. **Verify ADB connection:**
   ```bash
   flutter doctor
   ```

3. **Restart ADB:**
   ```bash
   adb kill-server
   adb start-server
   flutter devices
   ```

### Accept Android Licenses (if needed):

```bash
flutter doctor --android-licenses
```
(When prompted, type `y` and press Enter for each license)

## 🎯 Next Steps

1. **Update API Base URL** (Important!)
   - Open `lib/config/app_config.dart`
   - Update `baseUrl` to your backend API URL:
   ```dart
   static const String baseUrl = 'https://api.utilityhub360.com/api';
   ```

2. **Launch emulator:**
   ```bash
   flutter emulators --launch android
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **During development:**
   - Press `r` for hot reload
   - Press `R` for hot restart
   - Press `q` to quit

## 📱 Features Available

Once running, you'll have access to:
- Login/Register screens
- Dashboard with financial overview
- Transactions management
- Bills & Utilities
- Loan Management
- Income Sources
- Bank Accounts
- Notifications
- Settings & Profile

Enjoy building with UtilityHub360! 🚀

