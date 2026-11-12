param (
    [string]$ProjectDir = "c:\Users\hp\Downloads\app innovista\Innovista Ap",
    [string]$OutputDir = "c:\Users\hp\Downloads\app innovista\Innovista Ap\apk-output"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Building INNOVISTA Inventory Android APK ===" -ForegroundColor Cyan

$JAVA_HOME = "C:\Users\hp\jdk-21\jdk-21.0.12.1+1"
$JAVAC = "$JAVA_HOME\bin\javac.exe"
$JAR = "$JAVA_HOME\bin\jar.exe"

$ANDROID_SDK = "C:\Users\hp\AppData\Local\Android\Sdk"
$BUILD_TOOLS = "$ANDROID_SDK\build-tools\36.0.0"
$AAPT2 = "$BUILD_TOOLS\aapt2.exe"
$D8 = "$BUILD_TOOLS\d8.bat"
$ZIPALIGN = "$BUILD_TOOLS\zipalign.exe"
$APKSIGNER = "$BUILD_TOOLS\apksigner.bat"
$ANDROID_JAR = "$ANDROID_SDK\platforms\android-36\android.jar"
$KEYSTORE = "C:\Users\hp\Downloads\ytfb\debug.keystore"

$BuildDir = "$ProjectDir\android-build"

Write-Host "1. Cleaning and preparing build folders..." -ForegroundColor Yellow
if (Test-Path $BuildDir) { Remove-Item -Path $BuildDir -Recurse -Force }
New-Item -ItemType Directory -Path "$BuildDir\res\values" -Force | Out-Null
New-Item -ItemType Directory -Path "$BuildDir\res\mipmap-xxxhdpi" -Force | Out-Null
New-Item -ItemType Directory -Path "$BuildDir\assets\www\icons" -Force | Out-Null
New-Item -ItemType Directory -Path "$BuildDir\gen" -Force | Out-Null
New-Item -ItemType Directory -Path "$BuildDir\classes" -Force | Out-Null
New-Item -ItemType Directory -Path "$BuildDir\dex" -Force | Out-Null
New-Item -ItemType Directory -Path "$BuildDir\src\com\innovista\inventory" -Force | Out-Null
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

# Copy assets
Write-Host "2. Copying web application to assets..." -ForegroundColor Yellow
Copy-Item -Path "$ProjectDir\www\*" -Destination "$BuildDir\assets\www" -Recurse -Force

# Copy icons
if (Test-Path "$ProjectDir\www\icons\icon-192.png") {
    Copy-Item -Path "$ProjectDir\www\icons\icon-192.png" -Destination "$BuildDir\res\mipmap-xxxhdpi\ic_launcher.png" -Force
    Copy-Item -Path "$ProjectDir\www\icons\icon-192.png" -Destination "$BuildDir\res\mipmap-xxxhdpi\ic_launcher_round.png" -Force
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Create res/values/strings.xml
$stringsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">INNOVISTA Inventory</string>
</resources>
"@
[System.IO.File]::WriteAllText("$BuildDir\res\values\strings.xml", $stringsXml, $utf8NoBom)

# Create AndroidManifest.xml
$manifestXml = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.innovista.inventory"
    android:versionCode="1"
    android:versionName="1.0.0">

    <uses-sdk android:minSdkVersion="24" android:targetSdkVersion="34" />

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.DeviceDefault.NoActionBar"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|smallestScreenSize|screenLayout|uiMode"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
"@
[System.IO.File]::WriteAllText("$BuildDir\AndroidManifest.xml", $manifestXml, $utf8NoBom)

# Create MainActivity.java without BOM
$mainActivityCode = @"
package com.innovista.inventory;

import android.app.Activity;
import android.os.Bundle;
import android.os.Build;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.webkit.JavascriptInterface;
import android.view.Window;
import android.view.WindowManager;
import android.graphics.Color;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;

public class MainActivity extends Activity {
    private WebView webView;

    public class Bridge {
        @JavascriptInterface
        public String getAndroidId() {
            try {
                return Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
            } catch (Exception e) {
                return "";
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.parseColor("#e8502e"));
        }

        webView = new WebView(this);
        setContentView(webView);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setAllowFileAccessFromFileURLs(true);
        settings.setAllowUniversalAccessFromFileURLs(true);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(true);
        settings.setSupportZoom(false);

        webView.addJavascriptInterface(new Bridge(), "AndroidBridge");

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith("tel:") || url.startsWith("mailto:") || url.startsWith("https://wa.me/") || url.startsWith("whatsapp:")) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                        startActivity(intent);
                        return true;
                    } catch (Exception e) {
                        return false;
                    }
                }
                return false;
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                String js = "if (!window.Capacitor) { " +
                            "  window.Capacitor = { " +
                            "    isNativePlatform: function() { return true; }, " +
                            "    Plugins: { " +
                            "      Device: { " +
                            "        getId: async function() { " +
                            "          var aid = (window.AndroidBridge && window.AndroidBridge.getAndroidId) ? window.AndroidBridge.getAndroidId() : ''; " +
                            "          return { identifier: aid }; " +
                            "        } " +
                            "      } " +
                            "    } " +
                            "  }; " +
                            "}";
                view.evaluateJavascript(js, null);
            }
        });

        webView.setWebChromeClient(new WebChromeClient());
        webView.loadUrl("file:///android_asset/www/index.html");
    }

    @Override
    public void onBackPressed() {
        if (webView != null && webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
"@
[System.IO.File]::WriteAllText("$BuildDir\src\com\innovista\inventory\MainActivity.java", $mainActivityCode, $utf8NoBom)

Write-Host "3. Compiling Android resources with AAPT2..." -ForegroundColor Yellow
& $AAPT2 compile --dir "$BuildDir\res" -o "$BuildDir\compiled_res.zip"

Write-Host "4. Linking resources with AAPT2..." -ForegroundColor Yellow
& $AAPT2 link -I $ANDROID_JAR --manifest "$BuildDir\AndroidManifest.xml" -o "$BuildDir\base.apk" "$BuildDir\compiled_res.zip" --java "$BuildDir\gen"

Write-Host "5. Compiling Java source files..." -ForegroundColor Yellow
$javaFiles = @("$BuildDir\src\com\innovista\inventory\MainActivity.java", "$BuildDir\gen\com\innovista\inventory\R.java")
& $JAVAC -encoding UTF-8 -cp "$ANDROID_JAR;$BuildDir\gen" -d "$BuildDir\classes" $javaFiles
if ($LASTEXITCODE -ne 0) { throw "Java compilation failed with exit code $LASTEXITCODE" }

Write-Host "6. Translating bytecode to Dalvik Executable (DEX) with D8..." -ForegroundColor Yellow
$classFiles = (Get-ChildItem -Path "$BuildDir\classes" -Recurse -Filter "*.class").FullName
& $D8 --lib $ANDROID_JAR --output "$BuildDir\dex" $classFiles
if ($LASTEXITCODE -ne 0) { throw "D8 DEX compilation failed with exit code $LASTEXITCODE" }

Write-Host "7. Adding assets and classes.dex into APK with forward slashes..." -ForegroundColor Yellow
Push-Location "$BuildDir"
& $JAR -uf "$BuildDir\base.apk" assets/
Pop-Location
Push-Location "$BuildDir\dex"
& $JAR -uf "$BuildDir\base.apk" classes.dex
Pop-Location

Write-Host "8. Aligning APK with zipalign..." -ForegroundColor Yellow
$FinalApk = "$OutputDir\Innovista-Inventory-v1.0.apk"
if (Test-Path $FinalApk) { Remove-Item $FinalApk -Force }
& $ZIPALIGN -f -p 4 "$BuildDir\base.apk" $FinalApk
if ($LASTEXITCODE -ne 0) { throw "Zipalign failed with exit code $LASTEXITCODE" }

Write-Host "9. Signing APK with apksigner..." -ForegroundColor Yellow
& $APKSIGNER sign --ks $KEYSTORE --ks-pass pass:android --key-pass pass:android --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true $FinalApk
if ($LASTEXITCODE -ne 0) { throw "APK signing failed with exit code $LASTEXITCODE" }

Write-Host "10. Verifying APK signature..." -ForegroundColor Yellow
& $APKSIGNER verify -v $FinalApk

Write-Host "`nSUCCESS! APK generated successfully at:" -ForegroundColor Green
Write-Host $FinalApk -ForegroundColor Cyan
