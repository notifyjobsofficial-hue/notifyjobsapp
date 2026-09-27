# Notify Jobs — Version 1.1 Production Release Notes

**Release Date:** September 2026  
**Package Name:** `com.notifyjobs.app`  
**Version:** `1.1.0` (Version Code: `2`)  
**Target SDK:** Android 14 (API 34) | **Compile SDK:** API 36  

---

## Executive Summary

Notify Jobs **Version 1.1** is a complete stabilization, refinement, and monetization release of the official Notify Jobs Android App and Cloudflare-hosted Web Admin Portal.

This release integrates the approved **Notify Jobs Brand Identity**, implements a dynamic **Status & Normalization Engine**, establishes **Google Play In-App Billing** for lifetime ad-free Pro access, resolves all narrow-screen clipping and formatting bugs, and deepens admin CMS remote control.

---

## Key Refinements & Upgrades

### 1. Brand Asset Integration (Zero Generic Placeholders)
- **Approved NJ Monogram**: Replaced placeholder letters with the approved intertwining **N** & **J** monogram featuring the dynamic Navy (`#0B2C5F`), Emerald Green (`#159B76`), and Amber Orange (`#F59E0B`) palette.
- **Android Adaptive Icons**:
  - `mipmap-anydpi-v26/ic_launcher.xml` & `ic_launcher_round.xml`
  - High-precision vector foreground (`drawable/ic_launcher_foreground.xml`) and solid navy background (`drawable/ic_launcher_background.xml`).
- **Standard Density Mipmaps**: Native Skia-rasterized PNG assets generated across all density tiers (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`).
- **Android Monochrome Notification Icon**:
  - `drawable/ic_notification.xml` (Status-bar compliant white vector silhouette with `@color/notification_accent` tinting).
- **Native Launch Splash Screen**:
  - `drawable/launch_background.xml` & `drawable-v21/launch_background.xml` with centered brand monogram.
- **Admin Web & Favicons**:
  - Replaced text boxes with vector `<BrandLogo />` component on Admin Sidebar and Login Portal.
  - Crisp high-resolution SVG favicon on Cloudflare Pages.

### 2. Normalization & Dynamic Status Engine
- **Elimination of "Years Years" Bug**:
  - Added `NormalizationUtils.formatYears()` and `formatAgeRange()` to strip duplicate unit strings case-insensitively and format age brackets cleanly (e.g. `18 - 30 Years`, `Max 32 Years`).
- **Date Label Collision Prevention**:
  - Added `NormalizationUtils.formatImportantDateLabel()` and structured flex row columns in `JobDetailScreen`, preventing string collision like `Physical Endurance TestNovember 2026`.
- **Centralized Multi-Content StatusEngine**:
  - **Jobs**: Automatically computes `Open`, `Closing Soon` (<=3 days), `Closing Today`, and `Closed` based on real application deadlines.
  - **Admit Cards**: Computes `Available` and `Upcoming`.
  - **Results**: Computes `Declared` and `Upcoming`.
  - **Answer Keys**: Computes `Released`, `Objection Open`, and `Closed`.
  - **Syllabus**: Computes `Available` and `Updated`.

### 3. Google Play In-App Purchase Architecture
- **In-App Purchase Integration** (`in_app_purchase: ^3.2.0`):
  - **Notify Jobs Pro (Lifetime)**: Product ID `notify_jobs_pro_lifetime` (One-time purchase @ ₹159).
  - **Developer Support Tip Jar**: Tiered consumable products (`notify_jobs_support_29` through `499`).
  - **Purchase Restoration**: Dedicated `restorePurchases()` handler for seamless multi-device access.
- **Guaranteed Free Aspirant Access**:
  - **Apply Online** is 100% direct and never gated behind ads or paywalls.
- **Ad Suppression Engine**:
  - When `isProUser` is active, all interstitial, banner, and rewarded video ad requests are suppressed.
  - Official notification PDF downloads unlock immediately without waiting.

### 4. Admin Web Hierarchical Content Management
- **Structured Content Accordions**:
  - **Jobs**: All Jobs, Government Jobs, A&N Jobs, SSC, Railway, Banking, Police / Defence.
  - **Updates**: Admit Cards, Results, Answer Keys, Syllabus.
  - **Articles**: Guides and aspirant updates.
- **Content Creation Wizard**:
  - 7-Card visual creator for fast, structured data entry with Andaman Island and Government vs Private conditional logic.
- **Remote App Configuration**:
  - Dynamic toggles for Announcements, Live Updates, Closing Soon threshold, Popular jobs, and Social channels (`app_settings` collection).

### 5. Mobile UI & Responsive Fixes
- **Narrow-Screen Tab Clipping**:
  - Made `UpdatesScreen` tab bar scrollable with `TabAlignment.start`, ensuring zero text clipping on narrow 320px–360px screens.
- **Sticky Bottom Action Dock**:
  - Secured safe-area padding and theme-aware surface background in `JobDetailScreen`.
- **4-Tier ShareService**:
  - Priority fallbacks: Deep-link URL (`shareBaseUrl + slug`) -> Direct Apply Link -> Play Store Link -> Plain text.

---

## Verification & Test Results
- `flutter analyze`: **0 issues** found.
- `flutter test`: **22/22 unit & widget tests passing** (100% pass rate).
- `admin_web` build: `npm run build` exits with **code 0**.
- R8 / ProGuard optimization rules configured in `proguard-rules.pro`.
