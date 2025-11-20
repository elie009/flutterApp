# Fix: "Access forbidden by its access permissions" Error

## The Problem
Port 64653 is blocked by Windows. You're getting:
```
SocketException: An attempt was made to access a socket in a way forbidden by its access permissions
```

## The Solution (2 Steps)

### Step 1: Open PowerShell as Administrator

**Method 1:**
1. Press `Windows Key`
2. Type "PowerShell"
3. Right-click "Windows PowerShell"
4. Click "Run as administrator"

**Method 2:**
1. Press `Windows + X`
2. Select "Windows PowerShell (Admin)" or "Terminal (Admin)"

### Step 2: Run These Commands

Copy and paste these commands one by one:

```powershell
# Navigate to your project
cd D:\PROJECT\REPOSITORY\WEBMVC\FEUtilityHub360\flutterApp

# Shut down WSL
wsl --shutdown

# Remove port from excluded range
netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1

# Verify it worked (should return nothing)
netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
```

### Step 3: Test

After running the commands, try:
```powershell
flutter run -d chrome --web-port=64653
```

## If It Still Doesn't Work

**Restart your computer** - Windows sometimes needs a restart for port exclusions to clear.

## Quick Alternative

If you need to run the app NOW while fixing the port:

```powershell
flutter run -d chrome --web-port=8080
```

This will work immediately without admin rights.



