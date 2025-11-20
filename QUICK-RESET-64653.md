# Quick Reset Port 64653

## ✅ What's Already Done

- WSL has been shut down
- WSL Service has been stopped

## 🔧 What You Need to Do

**Run PowerShell or Command Prompt as Administrator** and execute:

### Option 1: Use the Batch File (Easiest)

1. **Right-click** `reset-port-64653-admin.bat`
2. Select **"Run as administrator"**
3. Follow the prompts

### Option 2: Run Commands Manually

1. **Open PowerShell as Administrator:**
   - Press `Windows + X`
   - Select "Windows PowerShell (Admin)"

2. **Navigate to project:**
   ```powershell
   cd D:\PROJECT\REPOSITORY\WEBMVC\FEUtilityHub360\flutterApp
   ```

3. **Run this command:**
   ```powershell
   netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1
   ```

4. **Verify:**
   ```powershell
   netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
   ```
   (Should return nothing if successful)

5. **Test:**
   ```powershell
   flutter run -d chrome --web-port=64653
   ```

## ⚠️ If Port Still Blocked

If after running as admin the port is still blocked:

1. **Restart your computer** (most reliable)
2. Or check if other services are using it

## 📝 Current Status

- ✅ WSL: Shut down
- ✅ WSL Service: Stopped
- ⚠️ Port Exclusion: **Needs admin to remove** ← You are here
- ⚠️ System Process: May need restart




