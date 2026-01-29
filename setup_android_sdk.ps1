# Android SDK Setup Script
# This script configures the ANDROID_HOME environment variable and updates PATH
# Run this AFTER installing Android Studio

Write-Host "=== Android SDK Environment Setup ===" -ForegroundColor Cyan
Write-Host ""

# Common Android SDK locations
$possibleSdkPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:ProgramFiles\Android\Android Studio\sdk",
    "${env:ProgramFiles(x86)}\Android\Android Studio\sdk"
)

# Find Android SDK
$androidSdkPath = $null
foreach ($path in $possibleSdkPaths) {
    if (Test-Path $path) {
        $androidSdkPath = $path
        Write-Host "✓ Found Android SDK at: $androidSdkPath" -ForegroundColor Green
        break
    }
}

if (-not $androidSdkPath) {
    Write-Host "✗ Android SDK not found at common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure Android Studio is installed first." -ForegroundColor Yellow
    Write-Host "Download from: https://developer.android.com/studio" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If Android SDK is installed in a custom location, please enter the path:" -ForegroundColor Yellow
    $customPath = Read-Host "Android SDK Path (or press Enter to exit)"
    
    if ($customPath -and (Test-Path $customPath)) {
        $androidSdkPath = $customPath
    } else {
        Write-Host "Exiting setup." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Setting up environment variables..." -ForegroundColor Cyan

# Set ANDROID_HOME user environment variable
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSdkPath, [System.EnvironmentVariableTarget]::User)
Write-Host "✓ Set ANDROID_HOME = $androidSdkPath" -ForegroundColor Green

# Get current user PATH
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

# Add platform-tools and tools to PATH if not already present
$pathsToAdd = @(
    "$androidSdkPath\platform-tools",
    "$androidSdkPath\tools",
    "$androidSdkPath\cmdline-tools\latest\bin"
)

$pathUpdated = $false
foreach ($pathToAdd in $pathsToAdd) {
    if ($currentPath -notlike "*$pathToAdd*") {
        $currentPath = "$currentPath;$pathToAdd"
        $pathUpdated = $true
        Write-Host "✓ Added to PATH: $pathToAdd" -ForegroundColor Green
    } else {
        Write-Host "- Already in PATH: $pathToAdd" -ForegroundColor Gray
    }
}

if ($pathUpdated) {
    [System.Environment]::SetEnvironmentVariable("Path", $currentPath, [System.EnvironmentVariableTarget]::User)
    Write-Host "✓ PATH updated successfully" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Please restart PowerShell for changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Close and reopen PowerShell" -ForegroundColor White
Write-Host "2. Run: flutter doctor --android-licenses" -ForegroundColor White
Write-Host "3. Run: flutter doctor" -ForegroundColor White
Write-Host "4. Run: flutter build apk --release" -ForegroundColor White
Write-Host ""
