# Notify Jobs - AdMob Rewarded Ads Architecture & Setup

This guide documents the Google AdMob integration for the **Notify Jobs** platform, outlining strict compliance rules, environment isolation, and production release procedures.

---

## 1. Product & Policy Rules

> [!IMPORTANT]
> **Ad Gating Policy Guarantee**:
> 1. **Apply Online** is always **DIRECT**. Never gate with ads.
> 2. **Official Website** is always **DIRECT**. Never gate with ads.
> 3. Normal browsing, reading eligibility, vacancies, salary, syllabus, and results are **100% free and un-gated**.
> 4. Rewarded ads are used **ONLY** when the user chooses to download/unlock the **Official Notification / PDF**.
> 5. When unlocked, the specific document remains unlocked locally for **30 minutes** (configurable via Admin Remote Settings).

---

## 2. Development vs Production Configuration

### Development Ad Unit ID (Hardcoded Safety Test ID)
During development and local testing, the app **strictly uses Google's official Android rewarded test unit**:

```
ca-app-pub-3940256099942544/5224354917
```

> [!CAUTION]
> Never click on production ads or repeatedly test production ad units on your own devices during development. Doing so risks immediate account suspension by Google AdMob for invalid traffic.

### Production Placeholders
The codebase contains dedicated placeholders in `Notify-Jobs/flutter_app/lib/core/config/admob_config.dart`:
- `ADMOB_APP_ID`: Your verified AdMob Application ID (e.g. `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`).
- `REWARDED_NOTIFICATION_AD_UNIT_ID`: Your verified production Rewarded Ad Unit ID.

---

## 3. Creating Production AdMob Units

When preparing for Google Play Store release:

1. Log in to [Google AdMob](https://admob.google.com/).
2. Navigate to **Apps > Add App**.
3. Select **Android** platform.
4. Select **Yes, the app is listed on a supported app store** (or *No* if first release).
5. Name the app: `Notify Jobs`.
6. Copy your **AdMob App ID** and place it in `Notify-Jobs/flutter_app/android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
   ```
7. Go to **Ad units > Add ad unit** and choose **Rewarded**.
8. Name the ad unit `Official Notification PDF Unlock`.
9. Set the reward item name to `Notification Unlock` and amount `1`.
10. Copy the generated Unit ID and paste it into `flutter_app/lib/core/config/admob_config.dart`.

---

## 4. Registering Test Devices

To safely view test ads on physical developer hardware without using test ad unit IDs:
1. Find your device's GAID (Google Advertising ID).
2. In AdMob Console, go to **Settings > Test devices > Add test device**.
3. Add your physical Android device.
