# Check if Flutter is installed and properly configured
Write-Host "`n🔍 Checking Flutter Installation..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if Flutter is in PATH
Write-Host "Checking if Flutter is in PATH..." -ForegroundColor Yellow
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutterPath) {
    Write-Host "✅ Flutter found at: $($flutterPath.Source)" -ForegroundColor Green
    
    Write-Host "`nFlutter Version:" -ForegroundColor Yellow
    flutter --version
    
    Write-Host "`nFlutter Doctor Status:" -ForegroundColor Yellow
    flutter doctor
    
    Write-Host "`n✅ Flutter is installed and ready to use!" -ForegroundColor Green
    Write-Host "`nYou can now run the app with:" -ForegroundColor Cyan
    Write-Host "  flutter pub get" -ForegroundColor White
    Write-Host "  flutter run`n" -ForegroundColor White
    
} else {
    Write-Host "❌ Flutter is NOT installed or not in PATH" -ForegroundColor Red
    Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Read INSTALL-FLUTTER.md for installation instructions" -ForegroundColor White
    Write-Host "2. Download Flutter from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "3. Add Flutter to your system PATH" -ForegroundColor White
    Write-Host "4. Restart your terminal and run this script again`n" -ForegroundColor White
    
    Write-Host "Current PATH entries:" -ForegroundColor Cyan
    $env:PATH -split ';' | Where-Object { $_ -match 'flutter' } | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
    
    if (-not ($env:PATH -match 'flutter')) {
        Write-Host "  (no Flutter paths found in PATH)" -ForegroundColor Gray
    }
}

Write-Host "`n========================================`n" -ForegroundColor Cyan


