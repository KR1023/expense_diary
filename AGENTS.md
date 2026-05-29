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

## Key Directories
- `lib/main.dart`: App bootstrap, localization, theme, and `GetIt` registration.
- `lib/database/`: Drift database (`drift_database.dart`) and generated code (`drift_database.g.dart`).
- `lib/model/`: Drift table definitions and DTOs.
- `lib/screen/`: App screens and navigation (`RootScreen` with bottom tabs).
- `lib/component/`: Reusable widgets (e.g., ads, stats).
- `third_party/`: Local `google_mobile_ads` dependency.
- `asset/`: App images, splash, and icons.
- `docs/`: Setup/troubleshooting notes.

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

## Subscription Removal Status
- RevenueCat, StoreKit test configuration, Paywall, plan gating, and `purchases_flutter` have been removed from active code.
- Backup and report/export features are now available without subscription checks.
- Ads remain enabled through the local `google_mobile_ads` package; they are no longer hidden based on plan state.
- App Store Connect / Play Console subscription products should be deactivated or removed from store listings outside this repository.

## App Flow
- `RootScreen` manages 4 tabs (지출 / 지출 내역 / 분류 / 설정) using `IndexedStack`.
- UI queries the DB directly with `StreamBuilder` for reactive updates.

## Generated Files
- `lib/database/drift_database.g.dart` is generated. Do not edit manually.

## 커밋과 푸시
- "커밋/푸시" 를 입력하면 현재까지 진행한 사항을 커밋하고 푸시합니다.
- remote는 origin의 main입니다.
