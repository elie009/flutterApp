# 🚀 Quick Start Guide - Run UtilityHub360 App

## ✅ Setup Complete!

Your environment is ready:
- ✅ Flutter installed
- ✅ Android SDK found: `C:\Users\Elie\AppData\Local\Android\Sdk`
- ✅ Android Emulator available
- ✅ All dependencies installed

## 🎯 Choose Your Method:

### Method 1: Android Emulator (Recommended for Mobile Testing)

```bash
# Step 1: Launch emulator (this will open the emulator window)
flutter emulators --launch android

# Step 2: Wait 1-2 minutes for emulator to fully boot
# (You'll see the Android home screen)

# Step 3: Check devices (should show your emulator)
flutter devices

# Step 4: Run the app
flutter run
```

### Method 2: Physical Android Device (Easiest)

1. **Enable Developer Options:**
   - Settings → About Phone → Tap "Build Number" 7 times

2. **Enable USB Debugging:**
   - Settings → Developer Options → Turn on "USB Debugging"

3. **Connect phone via USB cable**

4. **Run:**
   ```bash
   flutter devices  # Verify your phone appears
   flutter run       # Launch app on phone
   ```

### Method 3: Windows Desktop (Quick Test)

```bash
flutter run -d windows
```

### Method 4: Web Browser (UI Testing)

```bash
flutter run -d chrome
```
⚠️ Note: Some native features won't work on web.

## ⚙️ Important: Update API URL First!

Before running, update the API base URL:

1. Open: `lib/config/app_config.dart`
2. Find the line:
   ```dart
   static const String baseUrl = 'https://api.utilityhub360.com/api';
   ```
3. Change to your actual backend URL

## 🔥 Development Tips

Once the app is running:

- **`r`** - Hot reload (fast refresh)
- **`R`** - Hot restart (full restart)
- **`q`** - Quit the app
- **`h`** - Show help

## 🐛 Troubleshooting

### Emulator not starting?
```bash
# List available emulators
flutter emulators

# Create new emulator if needed
flutter emulators --create
```

### No devices found?
```bash
# Restart ADB
adb kill-server
adb start-server

# Check again
flutter devices
```

### Need to accept licenses?
```bash
flutter doctor --android-licenses
# Type 'y' and press Enter for each license
```

## 📱 What You'll See

After running, you should see:
- Login screen (first time)
- Dashboard after login
- Bottom navigation with 4 tabs:
  - 🏠 Dashboard
  - 💰 Transactions
  - 📄 Bills
  - ➕ More (Settings, Loans, etc.)

## 🎉 You're All Set!

The app is ready to run. Choose your preferred method above and start developing!

---

**Quick Command Reference:**
```bash
flutter emulators              # List emulators
flutter emulators --launch     # Launch emulator
flutter devices                # List devices
flutter run                    # Run app
flutter run -d <device-id>     # Run on specific device
```

