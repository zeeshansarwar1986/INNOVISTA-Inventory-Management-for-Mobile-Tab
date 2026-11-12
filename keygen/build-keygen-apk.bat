@echo off
REM Builds the INNOVISTA Key Generator debug APK (install it only on the owner phone).
cd /d "%~dp0"
call npm install || goto :err
if not exist android call npx cap add android || goto :err
powershell -Command "(Get-Content android\app\src\main\AndroidManifest.xml) -replace 'android:allowBackup=\"true\"','android:allowBackup=\"false\"' | Set-Content android\app\src\main\AndroidManifest.xml"
call npm run android:sync || goto :err
cd android
call gradlew.bat assembleDebug || goto :err
echo DONE. APK: keygen\android\app\build\outputs\apk\debug\app-debug.apk
pause
exit /b 0
:err
echo Build failed.
pause
exit /b 1
