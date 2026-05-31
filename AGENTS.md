# AGENTS.md

## Project Summary
- Flutter expense tracking app with Korean (primary) and English (secondary) locales.
- State is persisted in SQLite via Drift; UI reads data using `StreamBuilder` streams.
- Ads are integrated via a local `google_mobile_ads` package.

## Tech Stack
- Flutter / Dart (`sdk: ^3.7.2`)
- Drift ORM + SQLite (`drift`, `drift_flutter`, `drift_dev`)
- Service locator: `get_it`
- Localization: `flutter_localizations`, `intl`
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- Subscriptions: RevenueCat via `purchases_flutter` (Android active, iOS temporarily disabled)

## Key Directories
- `lib/main.dart`: App bootstrap, localization, theme, and `GetIt` registration.
- `lib/database/`: Drift database (`drift_database.dart`) and generated code (`drift_database.g.dart`).
- `lib/model/`: Drift table definitions and DTOs.
- `lib/screen/`: App screens and navigation (`RootScreen` with bottom tabs).
- `lib/core/subscription/`: RevenueCat subscription state and entitlement helpers.
- `lib/const/`: App constants including Firebase auth and RevenueCat dart-define config.
- `lib/features/backup/`: Snapshot backup/restore domain and Firebase Firestore/Storage repository.
- `lib/features/report/`: CSV/PDF report export services.
- `lib/component/`: Reusable widgets (e.g., ads, stats).
- `third_party/`: Local `google_mobile_ads` dependency.
- `asset/`: App images, splash, and icons.
- `docs/revenue_cat/`: RevenueCat console/code/Android/iOS setup notes.
- `docs/deployment/`: Android/iOS deployment commands and checklists.
- `docs/Structure/`: Local and cloud data storage structure notes.
- `progress.md`: Latest development handoff summary from Claude.

## Data Model (Drift)
- `Expense`: id, categoryId (nullable), expenseName, expense (int), expenseDate, expenseDetail (nullable)
- `Category`: id, categoryName (unique)

After changing table definitions or database logic, regenerate code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Common Commands
```bash
# Dependencies
flutter pub get

# Run
flutter run

# Tests
flutter test

# Lint
flutter analyze

# Codegen (Drift)
dart run build_runner build --delete-conflicting-outputs

# Assets (icons/splash)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## RevenueCat / Subscription Status
- RevenueCat is re-integrated for Android. iOS is currently disabled in `SubscriptionService._configure()` and behaves as Free until App Store subscription setup is ready.
- Firebase UID is linked to RevenueCat app user ID in `lib/main.dart` via `loginUser()` / `logoutUser()`.
- Plans:
  - Free: ads shown, backup limited to once per KST week, restore limited to once per KST day.
  - Cloud: ads removed, unlimited backup/restore.
  - Report: includes Cloud and unlocks statistics/CSV/PDF export.
- Runtime config is read from `--dart-define` in `lib/const/revenuecat_config.dart`:
  - `RC_ANDROID_PUBLIC_SDK_KEY`
  - `RC_IOS_PUBLIC_SDK_KEY`
  - `RC_TEST_STORE_KEY` (test store override)
  - `RC_FORCE_ENTITLED` (UI/dev testing only; never include in release)
  - `RC_ENTITLEMENT_CLOUD`, `RC_ENTITLEMENT_REPORT`
  - `RC_OFFERING_CLOUD`, `RC_OFFERING_REPORT`
- Default entitlement IDs are `cloud`, `report`.
- Default offering/package IDs are `cloud_monthly`, `report_monthly`.

Android release build example:
```bash
flutter build appbundle \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud_monthly \
  --dart-define=RC_OFFERING_REPORT=report_monthly
```

## Backup / Restore
- Snapshot payload JSON is stored in Firebase Storage at `users/{uid}/snapshots/{snapshotId}.json`.
- Firestore stores snapshot metadata plus `payloadStoragePath`; older inline-payload Firestore snapshots remain readable.
- Backup metadata is stored under `users/{uid}/meta/backupQuota`.
- Local backup/restore limit keys live in `lib/features/backup/data/backup_metadata_keys.dart`.
- Firestore rules are tracked in `firestore.rules`. If Storage rules are changed, make sure Firebase deployment config includes them before release.

## App Flow
- `RootScreen` manages 5 tabs (지출 / 지출 내역 / 분류 / 통계 / 설정) using `IndexedStack`.
- UI queries the DB directly with `StreamBuilder` for reactive updates.

## Generated Files
- `lib/database/drift_database.g.dart` is generated. Do not edit manually.
- Flutter plugin registrants such as `macos/Flutter/GeneratedPluginRegistrant.swift` are generated. Avoid manual edits unless generated output changed after `flutter pub get`.

## 커밋과 푸시
- "커밋/푸시" 를 입력하면 현재까지 진행한 사항을 커밋하고 푸시합니다.
- 기본 브랜치는 `main`입니다.
- 푸시는 `origin main`과 `github main` 양쪽에 수행합니다.
