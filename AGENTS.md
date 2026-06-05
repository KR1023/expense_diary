# AGENTS.md

## Project Summary
- Flutter expense tracking app with Korean (primary) and English (secondary) locales.
- State is persisted in SQLite via Drift; UI reads data using `StreamBuilder` streams.
- Ads are integrated via a local `google_mobile_ads` package.
- Android subscriptions are active through RevenueCat; iOS subscription purchase UI is temporarily disabled and shows a "coming soon" state.
- The app now supports user-managed payment methods and recurring/fixed expenses.

## Tech Stack
- Flutter / Dart (`sdk: ^3.7.2`)
- Drift ORM + SQLite (`drift`, `drift_flutter`, `drift_dev`)
- Service locator: `get_it`
- Localization: `flutter_localizations`, `intl`
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- Subscriptions: RevenueCat via `purchases_flutter` (Android active, iOS temporarily disabled)
- Authentication: email/password, Google sign-in, and Sign in with Apple on iOS/macOS.

## Key Directories
- `lib/main.dart`: App bootstrap, localization, theme, and `GetIt` registration.
- `lib/database/`: Drift database (`drift_database.dart`) and generated code (`drift_database.g.dart`).
- `lib/model/`: Drift table definitions and DTOs.
- `lib/screen/`: App screens and navigation (`RootScreen` with bottom tabs).
- `lib/core/subscription/`: RevenueCat subscription state and entitlement helpers.
- `lib/core/recurring/`: Fixed expense schedule calculation and due-expense generation.
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
- Current local DB schema version: `3`.
- `Expense`: id, categoryId (nullable), paymentMethodId (nullable), recurringExpenseId (nullable), recurringOccurrenceDate (nullable), expenseName, expense (int), expenseDate, expenseDetail (nullable)
- `Category`: id, categoryName (unique), usePresetAmount, presetAmount (nullable), autoFillExpenseName
- `PaymentMethods`: id, type (`cash` / `card` / `bank` / `mobilePay` / `other`), name, memo (nullable), sortOrder, isArchived, createdAt, updatedAt
- `RecurringExpenses`: id, name, amount, categoryId (nullable), paymentMethodId (nullable), detail (nullable), frequency (`daily` / `weekly` / `monthly` / `yearly`), interval, startDate, endDate (nullable), nextRunDate, isActive, createdAt, updatedAt
- `PaymentMethodExpense`: DTO for payment-method monthly aggregation.
- Category presets are optional. When `usePresetAmount=true`, selecting the category in expense add/edit fills the amount from `presetAmount`. When `autoFillExpenseName=true`, selecting the category fills the expense name with the category name.
- Deleting a category unassigns related expenses by setting `Expense.categoryId` to null inside a transaction, then deletes the category. Expense rows are not deleted.
- Payment methods are archived with `isArchived=true` instead of hard-deleted to preserve historic expense references.
- Adding a payment method with the same active `type + name` is blocked. Adding the same `type + name` as an archived payment method prompts restore, reuses the original ID, and reconnects historic expenses/statistics.
- `PaymentMethodSelect` must tolerate archived selected values because historic expenses and fixed-expense rules can still reference archived payment methods. Include the archived selected value in the dropdown as a deleted/current value instead of assuming it exists in `watchPaymentMethods()`.
- Fixed expenses generate real `Expense` rows only when due (`nextRunDate <= today`), not for future dates in advance.
- Fixed expense generation is capped at 100 rows per run and checks `recurringExpenseId + recurringOccurrenceDate` to avoid duplicates.
- Date-based expense list/total queries must use half-open day ranges (`start <= expenseDate < nextDay`) instead of exact `DateTime` equality, because restored or migrated rows may contain non-midnight time components.

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
- Account-level manual entitlements are supported through Firestore `userEntitlements/{uid}`. Missing documents default to role `normal` with no manual entitlements.
- Manual entitlement fields: `role` (`normal`, `cloud`, `report`, `special`, `admin`), `manualCloud`, `manualReport`, `manualAdsRemoved`. The app also accepts alias booleans `cloud`, `report`, `adsRemoved`.
- Final entitlement checks combine RevenueCat and manual entitlements. `report`, `special`, and `admin` include Cloud access; `special` and `admin` unlock all paid features.
- Firestore rules allow users to read only their own `userEntitlements/{uid}` document and deny all client writes. Modify manual entitlements via Firebase Console/Admin SDK only.
- Plans:
  - Free: ads shown, backup limited to once per KST week, restore limited to once per KST day, active fixed expenses limited to 10, payment methods limited to 5.
  - Cloud: ads removed, unlimited backup/restore, unlimited fixed expenses, unlimited payment methods.
  - Report: includes Cloud and unlocks statistics/CSV/PDF export.
- iOS subscription/paywall screens currently show "준비 중"; do not enable iOS purchase flow until App Store subscription setup is ready.
- User-cancelled purchases are treated as a normal cancellation path and should not expose raw RevenueCat/API errors.
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
- Snapshot metadata includes a user-facing `name`. Backup prompts for a name; an empty input defaults to a local `yyyy.MM.dd HH:mm` timestamp name.
- Snapshot name input dialog owns its `TextEditingController` inside the dialog `State`; do not dispose it immediately after `showDialog` returns because the closing animation may still render the field.
- Each user keeps at most 5 snapshots. After a new backup is uploaded, older snapshots beyond the newest 5 are deleted from both Firestore and Storage.
- Snapshot restore screen displays only the newest 5 snapshots and supports selected deletion plus delete-all.
- Snapshot payload includes expenses, categories, payment methods, and recurring expenses.
- Restore order must preserve FK safety. Current restore clears dependent rows first and reinserts parent rows before dependent rows.
- Snapshot parsing handles both Drift snake_case and app camelCase keys.
- Legacy snapshots without payment/recurring keys must remain restorable by treating missing lists as empty.
- Backup metadata is stored under `users/{uid}/meta/backupQuota`.
- Local backup/restore limit keys live in `lib/features/backup/data/backup_metadata_keys.dart`.
- Firestore rules are tracked in `firestore.rules`. If Storage rules are changed, make sure Firebase deployment config includes them before release.

## Authentication / Account Deletion
- Login options:
  - Email/password is available on all platforms.
  - Google sign-in is available from the login screen.
  - Sign in with Apple is shown only on iOS/macOS and uses Firebase Auth `AppleAuthProvider`.
- iOS App Store Guideline 4.8 compliance depends on keeping Sign in with Apple visible wherever Google sign-in is available on iOS.
- iOS Sign in with Apple requires:
  - Apple Developer App ID `com.ysh.expenseDiary` has the Sign in with Apple capability enabled.
  - `ios/Runner/Runner.entitlements` includes `com.apple.developer.applesignin`.
  - Xcode `Runner > Signing & Capabilities` shows Sign in with Apple.
  - Firebase Authentication Apple provider is enabled.
- Account deletion is exposed in Settings when a user is signed in.
- Deletion flow first shows a data deletion notice, then a final confirmation.
- Account deletion removes cloud account data only:
  - Firebase Authentication current user.
  - Firestore `users/{uid}/snapshots`, `users/{uid}/transactions`, `users/{uid}/meta`, and `users/{uid}`.
  - Firebase Storage `users/{uid}/snapshots/*`.
- Local SQLite expense data is intentionally not deleted by account deletion. Use Settings → 모든 데이터 초기화 for local data reset.
- Firebase may throw `requires-recent-login`; in that case the app asks the user to sign in again before retrying deletion.

## AdMob / Ads
- Ads use the local `google_mobile_ads` package under `third_party/`.
- Ad unit IDs are configured in `lib/const/admob_config.dart`.
- Defaults:
  - Android banner: `ca-app-pub-5444803558030319/2084179141`
  - iOS banner: `ca-app-pub-5444803558030319/5504549409`
- Override with `--dart-define=ADMOB_ANDROID_BANNER_ID=...` and `--dart-define=ADMOB_IOS_BANNER_ID=...`.
- `BannerAdWidget` hides ads when `SubscriptionService.isAdsRemoved` is true; Cloud and Report entitlements remove ads.

## Fixed Expenses / Payment Methods
- Payment methods are managed from Settings → 결제 수단 관리.
- Expense add/edit screens include `PaymentMethodSelect`; expense cards show payment-method badges.
- Expense add/edit category and payment-method selectors support quick-add actions. Payment-method quick-add must enforce the same Free-plan limit of 5 methods unless Cloud/Report entitlement is active.
- Fixed expenses are managed in the `고정 지출` tab.
- `RecurringExpenseService.generateDueExpenses()` runs on app start, fixed-expense tab entry, and after fixed-expense form save.
- `RecurringSchedule` handles daily/weekly/monthly/yearly recurrence and clamps invalid month-end dates to the last valid day.
- Deleting a fixed expense rule currently hard-deletes the rule; already generated expense rows remain.

## App Flow
- `RootScreen` manages 6 tabs (지출 / 지출 내역 / 분류 / 고정 지출 / 통계 / 설정) using `IndexedStack`.
- Each tab with a FAB must use a unique `heroTag` to avoid `IndexedStack` hero collisions.
- UI queries the DB directly with `StreamBuilder` for reactive updates.
- The expense home tab is date-selectable. Header calendar opens `showDatePicker`, Today jumps to the current local date, and horizontal swipes move one day at a time with slide/fade animation.
- When the selected home date is today, labels use "오늘 지출/오늘 합계"; otherwise they use `{yyyy.MM.dd} 지출/{yyyy.MM.dd} 합계`.
- Opening `AddScreen` from the home tab passes the currently selected date as the default expense date.
- Statistics screen is named `지출 통계` and includes monthly summary, day average, previous-month comparison, max spending day, category breakdown, and payment-method breakdown/detail sheet.

## Generated Files
- `lib/database/drift_database.g.dart` is generated. Do not edit manually.
- Flutter plugin registrants such as `macos/Flutter/GeneratedPluginRegistrant.swift` are generated. Avoid manual edits unless generated output changed after `flutter pub get`.

## 커밋과 푸시
- "커밋/푸시" 를 입력하면 현재까지 진행한 사항을 커밋하고 푸시합니다.
- 기본 브랜치는 `main`입니다.
- 푸시는 `origin main`과 `github main` 양쪽에 수행합니다.
