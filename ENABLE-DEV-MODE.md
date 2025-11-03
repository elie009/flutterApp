# 🔧 Enable Developer Mode on Windows

## Problem
```
Error: Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

Flutter needs **symlink support** to build apps with plugins on Windows. Developer Mode enables this.

## ✅ Solution: Enable Developer Mode

I've opened the Windows Settings for you. Here's what to do:

### Step-by-Step Instructions

1. **In the Windows Settings window** (now open):
   - You should see "Developer Mode" section
   - Toggle the **"Developer Mode"** switch to **ON** (blue)

2. **If you get a warning dialog:**
   - Click **"Yes"** to confirm

3. **Wait for installation:**
   - Windows will download and install some features
   - This takes 1-2 minutes

4. **When done:**
   - The switch will show as ON (blue)
   - You can close the Settings window

## 🔄 After Enabling Developer Mode

**Try running your app again:**

### In Android Studio:
- Click the **▶️ Run** button again

### OR from Terminal:
```bash
flutter run -d windows
```

## ✅ Success!

Once Developer Mode is enabled, you should see:
- Flutter building your app
- No more symlink errors
- App launching on Windows desktop

## 🎯 What if Developer Mode is Already Enabled?

If the toggle is already ON and you still get the error:

1. **Restart your computer** (sometimes needed)
2. **Check if you're running as Administrator:**
   - Right-click Command Prompt/PowerShell
   - Select "Run as administrator"
   - Navigate to project and run again

## 📱 Alternative: Run on Android Emulator Instead

If you don't want to enable Developer Mode, you can run on Android emulator:

```bash
# List available devices
flutter devices

# Launch emulator
flutter emulators --launch <emulator-name>

# Run app on emulator
flutter run
```

The emulator doesn't require Developer Mode!

## 🔍 Verify Developer Mode is Enabled

You can check if Developer Mode is enabled by running:

```powershell
Get-AppxPackage -Name Microsoft.WindowsSubsystemLinux -ErrorAction SilentlyContinue
```

If it returns a result, Developer Mode is likely enabled.

---

**Once Developer Mode is enabled, try running your app again!** 🚀


