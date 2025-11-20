# Why Port 64653 Cannot Be Used

## The Problem

Port 64653 is in **Windows' Excluded Port Range**. This means:

1. **Windows has reserved it** - The operating system has explicitly marked this port as "off-limits" for regular applications
2. **System Process owns it** - PID 4 (Windows System process) is listening on it
3. **It's an "Administered Port Exclusion"** - This is a system-level reservation, not just a port in use

## Why Windows Does This

Windows reserves ports for:
- **Hyper-V** (Virtualization)
- **WSL** (Windows Subsystem for Linux) 
- **Docker Desktop**
- **Windows NAT** services
- Other system-level networking services

These services need guaranteed ports that won't conflict with user applications.

## The Technical Details

When you try to bind to port 64653, Windows returns:
```
SocketException: Failed to create server socket 
(OS Error: An attempt was made to access a socket in a way forbidden by its access permissions, errno = 10013)
```

Error code **10013** = `WSAEACCES` = "Permission denied" - Windows is **refusing** to let your app use this port.

## Solutions

### Option 1: Remove the Exclusion (Requires Admin)

1. **Run PowerShell as Administrator**
2. **Shut down WSL:**
   ```powershell
   wsl --shutdown
   ```
3. **Remove the exclusion:**
   ```powershell
   netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1
   ```
4. **Verify:**
   ```powershell
   netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
   ```
   (Should return nothing if successful)

**⚠️ Warning:** This may break WSL or other services that need this port.

### Option 2: Use a Different Port (Recommended)

Use port **8080** (or any other available port):
```powershell
flutter run -d chrome --web-port=8080
```

### Option 3: Let Flutter Auto-Select

Don't specify a port - Flutter will find an available one:
```powershell
flutter run -d chrome
```

## Why We Can't Just "Kill" It

- **PID 4 is the System process** - You cannot kill it (it IS Windows)
- **It's a reservation, not just usage** - Even if nothing is actively using it, Windows won't let you bind to it
- **It requires admin rights** - Only an administrator can modify Windows port exclusions

## Current Status

✅ **Port 8080 is AVAILABLE** - You can use this immediately
❌ **Port 64653 is BLOCKED** - Requires admin intervention to free




