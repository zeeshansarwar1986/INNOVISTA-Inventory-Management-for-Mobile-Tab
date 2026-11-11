@echo off
REM INNOVISTA: build a debug APK on Windows.
REM Needs: Node.js 18+, JDK 17, Android Studio (Android SDK). Set ANDROID_HOME if gradle cannot find the SDK.
cd /d "%~dp0"
call npm install || goto :err
if not exist android call npx cap add android || goto :err
call npm run android:sync || goto :err
cd android
call gradlew.bat assembleDebug || goto :err
cd ..
echo.
echo DONE. APK: android\app\build\outputs\apk\debug\app-debug.apk
pause
exit /b 0
:err
echo Build failed. Read the message above and see README.md, section Android APK.
pause
exit /b 1
