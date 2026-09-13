# Notify Jobs - Google Play Store Release & Signing Guide

This guide covers building production-ready Android App Bundles (AAB), keystore generation, release signing, Google Play App Signing, and Data Safety declarations.

---

## 1. Package Name & Versioning

- **Application Package ID**: `com.notifyjobs.app`
  > [!IMPORTANT]
  > Once uploaded to Google Play, the package name is permanently tied to the application and cannot be changed.
- **Initial Version**: `1.0.0+1`
  - Version Name: `1.0.0` (User facing)
  - Version Code: `1` (Internal integer; increment by 1 for every Play Console upload).

---

## 2. Generating Release Keystore

Generate your dedicated upload keystore on your development workstation:

```bash
keytool -genkey -v -keystore notifyjobs-upload-key.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias notifyjobs-upload
```

Keep this keystore safe and back it up in multiple secure offline locations.

---

## 3. Configuring Release Signing

Create a `key.properties` file in `Notify-Jobs/flutter_app/android/key.properties` using the provided example (`key.properties.example`):

```properties
storePassword=YOUR_SECURE_KEYSTORE_PASSWORD
keyPassword=YOUR_SECURE_KEY_PASSWORD
keyAlias=notifyjobs-upload
storeFile=C:/path/to/notifyjobs-upload-key.jks
```

> [!CAUTION]
> `key.properties` and `*.jks` are strictly excluded in `.gitignore`. Never commit signing credentials to source control.

---

## 4. Google Play App Signing

We use **Google Play App Signing**:
- The **Upload Key** signs the AAB before uploading to Google Play.
- Google Play verifies the upload key, strips it, and re-signs the final delivered APKs with the master **App Signing Key** managed securely in Google Cloud Key Management Service.

---

## 5. Building the Production Android App Bundle (AAB)

Run the release build command from `Notify-Jobs/flutter_app/`:

```bash
cd Notify-Jobs/flutter_app
flutter build appbundle --release
```

The generated bundle will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 6. Play Console Data Safety Declarations

Notify Jobs is designed with privacy at its core:
- **No User Account Requirement**: No email, name, phone number, or OTP collected from mobile users.
- **Data Collected for Functionality**:
  - **Firebase Analytics**: Approximate location (country/city level), app interactions (job saves, shares, search terms) for performance optimization.
  - **Firebase Crashlytics**: Crash logs and diagnostics.
  - **Firebase Cloud Messaging**: Device FCM registration token for sending targeted recruitment alerts.
  - **Google AdMob**: Device identifiers / advertising IDs for rewarded ad delivery.
- **Data Encryption**: All network traffic uses HTTPS (TLS 1.3/1.2).
- **Data Deletion**: Users can clear local saved jobs and search history at any time from device settings or the app More tab.

---

## 7. Track Release Flow

1. **Internal Testing**: Upload `app-release.aab` to verify installation on physical test devices (e.g. Samsung Galaxy A34, Pixel).
2. **Closed Testing**: Share with initial beta testers to verify push notifications and rewarded ad unlocks.
3. **Production Release**: Submit for review and publish to Google Play Store.
