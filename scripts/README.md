# Notify Jobs Administrative Scripts

This directory contains administrative tools for provisioning and bootstrapping the Notify Jobs platform.

## 1. First Super-Admin Bootstrap (`bootstrap-super-admin.mjs`)

This script provisions the initial super-admin account in Cloud Firestore (`/admins/{uid}`) and sets custom admin claims in Firebase Authentication using the Firebase Admin SDK.

### Prerequisites

1. Ensure the super-admin user exists in Firebase Authentication:
   - Go to [Firebase Console](https://console.firebase.google.com/) -> Select `notify-jobs-753b8`.
   - In left menu: **Build** -> **Authentication** -> **Users** tab.
   - If `laurelsformahesh@gmail.com` is not already listed, click **Add user**, enter `laurelsformahesh@gmail.com` and a secure password, and click **Add user**.

2. Download your Firebase Service Account Private Key:
   - Go to [Firebase Console](https://console.firebase.google.com/) -> Select `notify-jobs-753b8`.
   - Click the gear icon (**Project Settings**) -> Select the **Service accounts** tab.
   - Click **Generate new private key**, then confirm **Generate key**.
   - A `.json` file will download to your computer.
   - Rename this file to `serviceAccountKey.json`.
   - Move or copy `serviceAccountKey.json` into this `scripts/` folder (or the root of `Notify-Jobs`).
   - *(Note: `serviceAccountKey.json` is protected by `.gitignore` and will never be committed to Git).*

### Running the Script

Open a terminal in the `scripts` directory:

```powershell
cd scripts
npm install
npm run bootstrap
```

To bootstrap a different email address if needed:

```powershell
node bootstrap-super-admin.mjs your-email@example.com
```

### What This Script Does

1. Verifies the service account belongs to `notify-jobs-753b8`.
2. Queries Firebase Authentication for `laurelsformahesh@gmail.com` and retrieves their unique Firebase Auth UID.
3. Idempotently creates or updates `/admins/{uid}` in Cloud Firestore with:
   ```json
   {
     "uid": "<Auth UID>",
     "email": "laurelsformahesh@gmail.com",
     "displayName": "Super Admin",
     "role": "super_admin",
     "active": true,
     "createdAt": "<Timestamp>",
     "updatedAt": "<Timestamp>"
   }
   ```
4. Assigns Firebase Auth custom claims `{ admin: true, super_admin: true, role: 'super_admin' }`.
5. Reads back the record to confirm the write succeeded.

### Verification

Once the script completes with `🎉 SUCCESS: Super Admin Provisioned Successfully!`, open:
👉 **https://notifyjobsapp.pages.dev**

Sign in with `laurelsformahesh@gmail.com` and your password. You will be directed straight to the Notify Jobs Admin Dashboard.
