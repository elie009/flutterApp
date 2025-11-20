# 🚀 FREE PORT 64653 - Quick Instructions

## ⚡ FASTEST WAY (2 clicks):

1. **Right-click** the file: `FREE-64653-NOW.bat`
2. Click **"Run as administrator"**
3. Click **Yes** when Windows asks for permission
4. Wait for it to complete
5. Run: `flutter run -d chrome --web-port=64653`

---

## 📝 Manual Method (if batch file doesn't work):

1. **Open PowerShell as Administrator:**
   - Press `Windows + X`
   - Click "Windows PowerShell (Admin)" or "Terminal (Admin)"

2. **Run these commands:**
   ```powershell
   wsl --shutdown
   netsh int ipv4 delete excludedportrange protocol=tcp startport=64653 numberofports=1
   ```

3. **Verify it worked:**
   ```powershell
   netsh int ipv4 show excludedportrange protocol=tcp | findstr "64653"
   ```
   (Should return nothing if successful)

4. **Run Flutter:**
   ```powershell
   cd D:\PROJECT\REPOSITORY\WEBMVC\FEUtilityHub360\flutterApp
   flutter run -d chrome --web-port=64653
   ```

---

## ⚠️ If Port Still Blocked After Running:

**Restart your computer** - Windows sometimes needs a restart for port exclusions to clear.

---

## ✅ After Port is Free:

Your Flutter app will run on `http://localhost:64653`



