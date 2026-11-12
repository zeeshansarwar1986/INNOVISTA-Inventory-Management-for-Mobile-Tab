@echo off
REM ========================================================
REM INNOVISTA Inventory - Direct APK Builder (No Node/Capacitor needed)
REM Uses installed Android SDK 36, JDK 21, and Android tools
REM ========================================================
cd /d "%~dp0"
echo Building APK...
powershell -ExecutionPolicy Bypass -File "%~dp0tools\build-native-apk.ps1"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo --------------------------------------------------------
    echo APK successfully created at:
    echo apk-output\Innovista-Inventory-v1.0.apk
    echo --------------------------------------------------------
) else (
    echo.
    echo Build encountered an error.
)
pause

