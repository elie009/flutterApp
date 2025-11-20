# Reset Port 64653 - Complete Instructions

## What I've Done

✅ Shut down WSL
✅ Stopped WSL Service

## What You Need to Do (Requires Admin)

To completely free port 64653, you need to run PowerShell **as Administrator**:

### Step 1: Open PowerShell as Administrator

1. Press `Windows Key + X`
2. Select "Windows PowerShell (Admin)" or "Terminal (Admin)"
3. Navigate to your project:
   ```powershell
   cd D:\PROJECT\REPOSITORY\WEBMVC\FEUtilityHub360\flutterApp
   ```

### Step 2: Run the Reset Script

```powershell
.\reset-port-64653.ps1
```

### OR Run These Commands Manually:

```powershell
# 1. Shut down WSL (already done, but run again to be sure)
wsl --shutdown

# 2. Stop WSL Service
Stop-Service -Name "WSLService" -Force

# 3. Remove port from excluded range
netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1

# 4. Verify it's removed
netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
# (Should return nothing if successful)

# 5. Check if port is free
netstat -ano | findstr :64653
# (Should return nothing if free)
```

### Step 3: Test the Port

After removing the exclusion, try:
```powershell
flutter run -d chrome --web-port=64653
```

## If Port Still Blocked After Reset

If the port is still blocked after running the commands:

1. **Restart your computer** (most reliable solution)
   - Windows sometimes needs a restart for port exclusions to clear

2. **Or disable WSL completely** (if you don't need it):
   ```powershell
   # Run as Administrator
   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   # Restart required
   ```

## Current Status

- ✅ WSL: Shut down
- ✅ WSL Service: Stopped  
- ⚠️ Port Exclusion: Needs admin to remove
- ⚠️ System Process: May need restart to release

## Quick Test

After running as admin, test if port is free:
```powershell
Test-NetConnection -ComputerName localhost -Port 64653 -InformationLevel Quiet
# Should return False if port is free
```




