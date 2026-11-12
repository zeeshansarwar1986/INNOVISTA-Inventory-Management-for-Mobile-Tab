# Licensing and code protection

## 1. How it works

```
Customer phone (Inventory app)          Owner phone (Key Generator)
  shows Device ID  ---- WhatsApp ---->   owner types the Device ID
                                         signs "INV1|DeviceID|expiry|name" with the PRIVATE key
  pastes the key   <---- WhatsApp ----   sends the activation key
  app checks the signature with the PUBLIC key built into the app
```

- **Device ID:** 16 characters (`XXXX-XXXX-XXXX-XXXX`) made from the Android ID (`@capacitor/device`) through SHA-256. The raw Android ID never leaves the phone. In a browser or PWA there is no hardware ID, so a random ID stored in the browser is used instead (it changes if the browser data is cleared).
- **Key:** `INV1-<payload>.<signature>`, ECDSA P-256 with SHA-256 (WebCrypto). The payload holds the Device ID, the expiry (`LIFETIME` or a date) and the customer name.
- **The app contains only the public key.** Nobody can make new keys from the app. The private key exists only on the owner phone, encrypted with the owner PIN (PBKDF2 250,000 rounds + AES-GCM).
- On every start, and when the app returns to the foreground, the stored key is checked again: signature, device, expiry, and a clock check (a clock set back by more than a day is refused).
- Tested here in a browser: wrong device, expired, tampered and garbage keys are refused; a correct key activates and stays active after restart.

## 2. Owner steps (once)

1. Build and install **INNOVISTA Key Generator** on the owner phone only (`keygen/build-keygen-apk.bat` or the GitHub workflow, artifact `innovista-keygen-apk`).
2. Open it, create a PIN (6+ characters). Keys are generated.
3. Settings > **Copy public key**. Save it as `public-key.json` in the project root (or as the GitHub secret `PUBLIC_KEY_JWK`). It must not contain a field named `d`.
4. Settings > **Download backup file** and keep it safe (cloud, second device). Without it, a lost phone means no new keys for apps already installed.
5. Build the Inventory APK (`build-apk.bat` or GitHub). The build writes `www/license-config.js` from the public key.

## 3. For every customer

1. Customer installs the APK and opens it: the first screen asks for activation and shows the Device ID with **Copy ID** and **WhatsApp** buttons.
2. Owner opens the Key Generator, types the Device ID, the customer name and the validity, taps **Generate key**, then **WhatsApp** (or Copy / Share).
3. Customer pastes the key and taps **Activate**. Admin panel > License shows the status.

The Key Generator keeps a history of issued keys (CSV export).

## 4. Important: keep the signing key fixed

On Android 8 and later the Android ID depends on the key that signs the APK. If the APK is signed with a different key (a new CI runner, a different PC), the Device ID of the same phone changes and old activation keys stop working.

- Build every version with the **same keystore**.
- GitHub: create the default debug keystore once, store it as the secret `DEBUG_KEYSTORE_BASE64`, and the workflow restores it before building:
  ```
  keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
  certutil -encode debug.keystore keystore.b64     (Windows)  /  base64 debug.keystore   (Linux, Mac)
  ```
- Windows local builds: always build on the same PC (`%USERPROFILE%\.android\debug.keystore`).
- For the Play Store use a proper release keystore and keep it forever.

## 5. Code protection that is in place

| Measure | Where |
|---|---|
| No secret in the app (public key only) | `license.js`, `license-config.js` |
| Signed keys bound to one device, with expiry | `license.js` |
| App password stored as a salted PBKDF2 hash, not as text | `www/index.html` |
| Admin panel asks for the password again | `openAdmin()` |
| Code obfuscation (string encoding, hex names) | `tools/protect.js`, runs in `npm run build` |
| Android backup off, debugging of the WebView off, no mixed content | `capacitor.config.json`, workflow and `.bat` scripts |
| Fail closed: if `license.js` is missing the app stays blank | boot code in `www/index.html` |

The obfuscation step needs `npm install` (javascript-obfuscator). It was **not run** in the environment that produced this package; the build step itself was tested without the obfuscator. After your first build test every screen of the APK.

## 6. Honest limits

A license check that runs inside the phone can never be 100% safe. A skilled person can unpack the APK, remove the check, or replace the public key with his own and sign his own keys. Obfuscation and signing make this much harder and stop normal users, sharing of keys between phones, and key guessing, but not a determined expert.

Also: a key cannot be taken back once issued (no online check), and expiry relies on the phone clock.

To get stronger protection later:
1. **Online activation server** (FastAPI): the phone sends the Device ID, the server returns a key, can refuse, revoke and log. Keys can then be short-lived and refreshed.
2. **Google Play Integrity API** to refuse modified or rooted installs (needs a server to verify).
3. Move the business data to the server so a cracked app has nothing to show.
4. Release signing, R8 minify and ProGuard for the Android part.

## 7. If something goes wrong

| Problem | Cause and fix |
|---|---|
| "This key was made for another device" | Device ID typed wrongly, or the APK was rebuilt with another signing key (section 4). Ask for the new Device ID and issue a new key. |
| "This key is not valid" | Key damaged when copied, or the app was built with another public key. |
| "Licensing is not configured" | `public-key.json` was missing at build time. |
| Owner phone lost | Install the Key Generator on a new phone, restore the backup file, enter the old PIN. |
| Forgot the PIN | Not recoverable. You must build a new Inventory app with a new public key and re-activate every customer. |
