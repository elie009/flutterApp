# Port Troubleshooting Guide

## Common Issue: Port 64653 Blocked

If you encounter errors like:
```
SocketException: An attempt was made to access a socket in a way forbidden by its access permissions
```

This means the port is blocked by Windows.

## Quick Solutions

### Option 1: Use a Different Port (Recommended - No Admin Required)
```powershell
flutter run -d chrome --web-port=8080
```

### Option 2: Let Flutter Auto-Select
```powershell
flutter run -d chrome
```

### Option 3: Free Port 64653 (Requires Admin)

1. **Open PowerShell as Administrator**
   - Press `Windows + X` → Select "Windows PowerShell (Admin)" or "Terminal (Admin)"

2. **Run these commands:**
   ```powershell
   # Shut down WSL
   wsl --shutdown
   
   # Remove port from excluded range
   netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1
   
   # Verify it worked (should return nothing)
   netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
   ```

3. **Test:**
   ```powershell
   flutter run -d chrome --web-port=64653
   ```

## Why Ports Get Blocked

Windows reserves certain ports for:
- Hyper-V (Virtualization)
- WSL (Windows Subsystem for Linux)
- Docker Desktop
- Windows NAT services

These are system-level reservations that require admin rights to modify.

## If Port Still Blocked

1. **Restart your computer** - Windows sometimes needs a restart for port exclusions to clear
2. **Check if port is in use:**
   ```powershell
   netstat -ano | findstr :64653
   ```
3. **Test port availability:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 64653 -InformationLevel Quiet
   # Should return False if port is free
   ```

## Available Scripts

- `reset-port-64653.ps1` - Reset port exclusion (requires admin)
- `free-port-64653.ps1` - Alternative port freeing script (requires admin)

**Note:** All port modification scripts require administrator privileges.

