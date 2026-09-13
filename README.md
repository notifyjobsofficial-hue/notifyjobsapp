# NOTIFY JOBS PLATFORM

> **Government Jobs. Results. Admit Cards. One App.**

A complete, standalone, production-oriented digital platform for Indian government job aspirants, comprising:
1. **Native Flutter Android Application** (`flutter_app/`)
2. **Admin Web Dashboard** (`admin_web/`) (React, Vite, TypeScript, Tailwind CSS)
3. **Firebase Cloud Backend** (`firebase/`) (Auth, Firestore Rules, Composite Indexes)
4. **Cloudflare Worker** (`cloudflare_worker/`) (Privileged FCM Dispatcher)
5. **Operational Documentation** (`docs/`)

---

## Architecture Overview

```
                 FIREBASE CLOUD
        ┌──────────────────────────────┐
        │ • Firebase Authentication    │
        │ • Cloud Firestore Database   │
        │ • Firebase Cloud Messaging   │
        │ • Firebase Analytics         │
        │ • Firebase Crashlytics       │
        └───────────────┬──────────────┘
                        │
         ┌──────────────┴──────────────┐
         │                             │
         ▼                             ▼
  Flutter Android App            Admin Web App
  (com.notifyjobs.app)       (Cloudflare Pages)
                                       │
                                       ▼
                              Cloudflare Worker
                             (Privileged FCM API)
```

---

## Directory Structure

```
Notify-Jobs/
│
├── flutter_app/         # Native Flutter Android App (Material 3 + Riverpod)
│   ├── lib/
│   │   ├── core/        # Theme, constants, widgets, services, config
│   │   ├── features/    # Home, Jobs, Updates, Saved, More, Details
│   │   └── main.dart
│   └── android/         # Native Android project (signing, manifest, Gradle)
│
├── admin_web/           # Admin Portal (React + Vite + TypeScript)
│   ├── src/
│   │   ├── components/  # Layout, common UI, repeaters, mobile preview
│   │   ├── pages/       # Dashboard, Content CRUD, Categories, Notifications
│   │   └── services/    # Firestore & Worker client services
│   └── dist/            # Production bundle for Cloudflare Pages
│
├── firebase/            # Firebase Backend Assets
│   ├── firestore.rules  # Role-based & public read-only security rules
│   ├── firestore.indexes.json # Composite indexes for high-speed queries
│   └── seed_data.json   # Initial categories, sections & app settings
│
├── cloudflare_worker/   # Cloudflare Worker for Privileged Operations
│   ├── src/index.ts     # RS256 OAuth2 token exchange & FCM v1 dispatch
│   └── wrangler.toml
│
├── docs/                # Comprehensive Operations & Release Guides
│   ├── FIREBASE_SETUP.md
│   ├── CLOUDFLARE_PAGES.md
│   ├── FCM_WORKER.md
│   ├── ADMOB_SETUP.md
│   └── PLAY_STORE_RELEASE.md
│
└── README.md
```

---

## Key Product Rules & Principles

1. **Zero WordPress Dependency**: Built as a 100% clean standalone Flutter + React architecture.
2. **No User Login in Mobile App**: Aspirants can browse, search, filter, and save jobs locally without registration, login, or OTP.
3. **Direct External Links**: **Apply Online** and **Official Website** links open directly with zero ads.
4. **Rewarded Ad Gating**: AdMob rewarded ads are used exclusively to unlock the **Official Notification / PDF**, caching the unlock locally for 30 minutes.
5. **Development AdMob Safety**: Development builds strictly use Google's official test ad unit `ca-app-pub-3940256099942544/5224354917`.
6. **Zero Secrets in Clients**: Privileged Google service account credentials reside exclusively in Cloudflare Worker environment secrets.
7. **Maths Yoddha Quality Benchmark**: Clean rounded cards, soft mint/emerald accents (`#159B76`), 16px mobile gutters, responsive layouts tested across 320px–430px.

---

## Quick Start Commands

### 1. Admin Web Application
```bash
cd Notify-Jobs/admin_web
npm install
npm run dev     # Development server on http://localhost:3000
npm run build   # Production bundle in admin_web/dist/
```

### 2. Flutter Android Application
```bash
cd Notify-Jobs/flutter_app
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

### 3. Cloudflare Worker
```bash
cd Notify-Jobs/cloudflare_worker
npm install
npm run dev     # Local test on http://127.0.0.1:8787
npm run deploy  # Deploy to Cloudflare edge
```
