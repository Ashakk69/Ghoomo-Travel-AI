# APK Build and Installation Script
# This script builds the Flutter app as a release APK and installs it on a connected device

Write-Host "=== Travel Planner APK Build & Install ===" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "X Error: Not in a Flutter project directory" -ForegroundColor Red
    Write-Host "Please run this script from the travel_planner directory" -ForegroundColor Yellow
    exit 1
}

# Step 1: Clean previous builds
Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Cyan
flutter clean
Write-Host "Clean complete" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "Step 2: Getting dependencies..." -ForegroundColor Cyan
flutter pub get
Write-Host "Dependencies updated" -ForegroundColor Green
Write-Host ""

# Step 3: Build APK
Write-Host "Step 3: Building release APK..." -ForegroundColor Cyan
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "APK built successfully!" -ForegroundColor Green
    Write-Host ""
    
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    $fullApkPath = Join-Path (Get-Location) $apkPath
    
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "APK Location: $fullApkPath" -ForegroundColor White
        Write-Host "APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor White
        Write-Host ""
        
        # Step 4: Check for connected devices
        Write-Host "Step 4: Checking for connected devices..." -ForegroundColor Cyan
        $devices = adb devices
        
        if ($devices -match "device$") {
            Write-Host "Device connected!" -ForegroundColor Green
            Write-Host ""
            
            # Ask user if they want to install
            $install = Read-Host "Install APK on connected device? (Y/n)"
            
            if (($install -eq "") -or ($install -eq "Y") -or ($install -eq "y")) {
                Write-Host ""
                Write-Host "Installing APK..." -ForegroundColor Cyan
                flutter install
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host ""
                    Write-Host "=== Installation Complete! ===" -ForegroundColor Green
                    Write-Host "The Travel Planner app is now installed on your device." -ForegroundColor White
                }
                else {
                    Write-Host "Installation failed" -ForegroundColor Red
                }
            }
        }
        else {
            Write-Host "No device connected via USB" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "To install on your phone:" -ForegroundColor Cyan
            Write-Host "1. Enable USB Debugging on your phone" -ForegroundColor White
            Write-Host "2. Connect your phone via USB" -ForegroundColor White
            Write-Host "3. Run this script again" -ForegroundColor White
            Write-Host ""
            Write-Host "OR manually transfer the APK:" -ForegroundColor Cyan
            Write-Host "Copy this file to your phone: $fullApkPath" -ForegroundColor White
        }
    }
}
else {
    Write-Host "APK build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check the error messages above and ensure:" -ForegroundColor Yellow
    Write-Host "1. Android SDK is properly installed" -ForegroundColor White
    Write-Host "2. ANDROID_HOME environment variable is set" -ForegroundColor White
    Write-Host "3. Android licenses are accepted (run: flutter doctor --android-licenses)" -ForegroundColor White
}

Write-Host ""
