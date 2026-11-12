@echo off
REM Builds the INNOVISTA Inventory debug APK on Windows.
REM Needs: Node.js 18+, JDK 17, Android Studio (Android SDK). First put the PUBLIC key from the Key Generator into public-key.json
cd /d "%~dp0"
call npm install || goto :err
call node tools\set-public-key.js || goto :err
if not exist android call npx cap add android || goto :err
powershell -Command "(Get-Content android\app\src\main\AndroidManifest.xml) -replace 'android:allowBackup=\"true\"','android:allowBackup=\"false\"' | Set-Content android\app\src\main\AndroidManifest.xml"
call npm run android:sync || goto :err
cd android
call gradlew.bat assembleDebug || goto :err
cd ..
echo DONE. APK: android\app\build\outputs\apk\debug\app-debug.apk
echo Always build on the same PC (same debug keystore) so Device IDs stay the same. See docs\LICENSING.md
pause
exit /b 0
:err
echo Build failed. Read the message above and see README.md.
pause
exit /b 1
