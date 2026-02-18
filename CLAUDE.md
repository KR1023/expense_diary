# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Dependencies
flutter pub get

# Code generation (required after modifying Drift schema in lib/database/ or lib/model/)
dart run build_runner build --delete-conflicting-outputs

# Run
flutter run

# Test
flutter test

# Analyze
flutter analyze

# Asset generation (run after changing icons/splash config in pubspec.yaml)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Architecture

**State management**: No BLoC/Riverpod/Provider. State lives entirely in SQLite (via Drift). UI subscribes to `Stream<T>` queries using `StreamBuilder`. GetIt is used as a service locator — `LocalDatabase` is registered as a singleton in `main.dart` and accessed via `GetIt.I<LocalDatabase>()` throughout.

**Database**: `lib/database/drift_database.dart` defines the schema and all query methods. `drift_database.g.dart` is generated — do not edit manually. Schema uses two tables:
- `Expense`: id, categoryId (nullable FK), expenseName, expense (amount as int), expenseDate, expenseDetail (nullable)
- `Category`: id, categoryName (unique)

After modifying the Drift database class or table definitions, run `build_runner` to regenerate `.g.dart`.

**Layer structure**:
- `lib/database/` — Drift ORM, all DB queries (watch/select/create/update/delete)
- `lib/model/` — Table definitions and DTOs (e.g., `CategoryExpense` for aggregated queries)
- `lib/screen/` — Full screens; `RootScreen` manages bottom navigation via `IndexedStack`
- `lib/component/` — Reusable widgets; statistical views use `StreamBuilder` directly against DB streams
- `third_party/` — Local `google_mobile_ads` package

**Navigation**: 4 tabs (지출/지출 내역/분류/설정) managed by `RootScreen` using `IndexedStack` (screens are not rebuilt on tab switch).

**Ads**: `BannerAdWidget` in `lib/component/banner_ad_widget.dart`. iOS uses a production AdUnit ID; Android currently uses a test ID. Handle ad lifecycle carefully — the widget manages load/dispose internally.

**Localization**: Korean (ko_KR) primary, English (en_US) secondary. Date formatting uses `intl` with Korean locale initialized in `main.dart` via `initializeDateFormatting`.
