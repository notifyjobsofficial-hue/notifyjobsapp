# Notify Jobs - Firebase Configuration & Security Guide

This document outlines the authoritative instructions to link the **Notify Jobs** Flutter Android application, Admin Web portal, and Cloudflare Worker to Firebase in production.

---

## 1. Create Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `Notify Jobs` (e.g. `notify-jobs-prod`).
3. Enable or disable Google Analytics according to your preference (recommended: **Enabled** for aspirant engagement tracking).
4. Click **Create Project**.

---

## 2. Register Android Application

1. In the Project Overview page, click the **Android** icon to add an Android app.
2. Enter the **Android package name** exactly as defined in the native app:
   ```
   com.notifyjobs.app
   ```
3. Set the App nickname to `Notify Jobs Android`.
4. Enter your Debug/Release SHA-1 fingerprint (required for SafetyNet/App Check and push notification integrity).
5. Click **Register App**.
6. Download `google-services.json` and place it in:
   ```
   Notify-Jobs/flutter_app/android/app/google-services.json
   ```
   *(Note: This file is ignored in public git by `.gitignore` to prevent leaking private project metadata).*

---

## 3. FlutterFire CLI Integration

From your terminal, ensure Flutter and Dart are available in your PATH, then activate and run FlutterFire CLI:

```bash
# 1. Login to Firebase CLI
firebase login

# 2. Activate flutterfire_cli globally
dart pub global activate flutterfire_cli

# 3. Configure Flutter app
cd Notify-Jobs/flutter_app
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This will automatically configure Android and generate:
```
Notify-Jobs/flutter_app/lib/firebase_options.dart
```

---

## 4. Enable Firebase Authentication

1. In the Firebase Console sidebar, navigate to **Build > Authentication**.
2. Click **Get Started**.
3. Under the **Sign-in method** tab, click **Email/Password**.
4. Enable the **Email/Password** toggle (keep *Email link (passwordless sign-in)* disabled).
5. Click **Save**.

> [!IMPORTANT]
> Mobile end-users require **NO LOGIN, NO OTP, and NO REGISTRATION**.
> Firebase Authentication is used exclusively for administrators accessing the Admin Web Application.

---

## 5. Enable Cloud Firestore

1. In the Firebase Console sidebar, navigate to **Build > Firestore Database**.
2. Click **Create Database**.
3. Choose your database location (recommended for India-based government job seekers: `asia-south1` Mumbai).
4. Choose **Start in production mode** (our security rules will be deployed in the next step).
5. Click **Enable**.

---

## 6. Deploy Security Rules and Composite Indexes

Deploy the pre-configured rules and composite indexes directly using the Firebase CLI from the `Notify-Jobs/` directory:

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy composite indexes
firebase deploy --only firestore:indexes
```

### Security Rules Highlights:
- **Public Users**: Can **read only published content** (`resource.data.isPublished == true`), active categories, and public app settings. All write operations (`create`, `update`, `delete`) are **strictly blocked**.
- **Admin Users**: Can write only if their authenticated UID exists in `/admins/{uid}` with `active == true`.
- **Role Isolation**: Only `super_admin` can manage `/admins` records and critical system settings; `editor` can manage content, categories, and homepage layouts.

---

## 7. Creating the First Super Admin Account

To avoid weak hardcoded passwords in source repositories, follow this secure bootstrap procedure:

1. In the Firebase Console, go to **Authentication > Users** and click **Add user**.
2. Enter your primary administrator email (e.g., `admin@notifyjobs.in`) and a strong, unique password. Click **Add user**.
3. Copy the generated **User UID** (e.g. `4k9J2mP...`).
4. In **Firestore Database**, create a document in the `admins` collection with that exact UID:
   - **Collection ID**: `admins`
   - **Document ID**: `[PASTE_USER_UID]`
   - **Fields**:
     ```json
     {
       "uid": "[PASTE_USER_UID]",
       "email": "admin@notifyjobs.in",
       "displayName": "Super Administrator",
       "role": "super_admin",
       "active": true,
       "createdAt": "2026-09-12T00:00:00.000Z"
     }
     ```
5. You can now log in to the Admin Web Portal with these credentials.

---

## 8. Exporting Google Service Account for FCM Worker

To allow the Cloudflare Worker to send push notifications via FCM v1:
1. In Firebase Console, go to **Project Settings > Service accounts**.
2. Select **Firebase Admin SDK** and click **Generate new private key**.
3. Download the JSON file.
4. Set it as a Cloudflare Worker secret (see `docs/FCM_WORKER.md`).
5. **Never** commit this JSON file to version control.
