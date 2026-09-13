# Deploying Notify Jobs Admin Web to Cloudflare Pages

The Notify Jobs Admin Web Portal is built as a single-page application (SPA) using React, Vite, and TypeScript. It is optimized to be deployed on **Cloudflare Pages**.

---

## 1. Cloudflare Pages Setup

1. Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. In the left navigation, select **Compute (Workers & Pages)** > **Pages**.
3. Click **Connect to Git** (e.g. GitHub or GitLab).
4. Authorize Cloudflare to access your `Notify-Jobs` repository.
5. Select the repository and click **Begin setup**.

---

## 2. Build Configuration Settings

Ensure the build settings match these exact parameters:

| Configuration Setting | Value |
|-----------------------|-------|
| **Project Name** | `notify-jobs-admin` (will produce `notify-jobs-admin.pages.dev`) |
| **Production Branch** | `main` (or `master`) |
| **Framework Preset** | `Vite` |
| **Root directory** | `Notify-Jobs/admin_web` *(or `admin_web` if repository root)* |
| **Build command** | `npm run build` |
| **Build output directory** | `dist` |

> [!WARNING]
> Do **NOT** deploy the admin web frontend using `npx wrangler deploy` from the root repository as if it were a Cloudflare Worker. Cloudflare Pages is the proper host for the static React SPA.

---

## 3. Environment Variables in Cloudflare Pages

Under **Settings > Environment variables**, configure the production Firebase client keys and Worker API endpoints:

```env
VITE_FIREBASE_API_KEY=AIzaSy...
VITE_FIREBASE_AUTH_DOMAIN=notify-jobs-app.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=notify-jobs-app
VITE_FIREBASE_STORAGE_BUCKET=notify-jobs-app.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=1234567890
VITE_FIREBASE_APP_ID=1:1234567890:web:abcdef123456

# Privileged FCM Worker endpoint (deployed in cloudflare_worker/)
VITE_FCM_WORKER_URL=https://notify-jobs-fcm-worker.workers.dev
```

---

## 4. Single-Page Application (SPA) Routing

To ensure direct page refreshes (e.g., navigating directly to `/dashboard`) work seamlessly without returning a 404 error from Cloudflare's edge, Cloudflare Pages automatically serves `index.html` for single-page applications built with Vite.

---

## 5. Verifying Local Production Builds

Before pushing to production, verify the production build locally:

```bash
cd Notify-Jobs/admin_web
npm install
npm run build
```

This must complete with zero errors and generate static assets in:
```
Notify-Jobs/admin_web/dist/
```
