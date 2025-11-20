# How to Free Port 64653

Port 64653 is currently reserved by Windows in the excluded port range. To use it for Flutter, you need to remove it from the exclusion list.

## Quick Fix (Requires Admin)

1. **Open PowerShell as Administrator:**
   - Right-click on PowerShell
   - Select "Run as Administrator"

2. **Shut down WSL (if running):**
   ```powershell
   wsl --shutdown
   ```

3. **Remove port from excluded range:**
   ```powershell
   netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1
   ```

4. **Verify it's removed:**
   ```powershell
   netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
   ```
   (Should return nothing if successful)

5. **Run your Flutter app:**
   ```powershell
   flutter run -d chrome --web-port=64653
   ```

## Alternative: Use the Script

Run the provided script as Administrator:
```powershell
.\remove-port-exclusion-64653.ps1
```

## If It Still Doesn't Work

If the port is still reserved after removing the exclusion:

1. **Restart your computer** (sometimes required for changes to take effect)

2. **Check for other services:**
   - Hyper-V: `Get-NetNatStaticMapping`
   - Docker: Check if Docker Desktop is running
   - Other virtualization software

3. **Temporarily disable WSL:**
   ```powershell
   # As Administrator
   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   # Restart required
   ```

## Current Status

- ✅ Scripts updated to use port 64653
- ⚠️ Port needs to be freed from Windows exclusion (requires admin)
- ✅ WSL has been shut down (helps but may not be enough)




