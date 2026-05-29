# CLAUDE.md

이 파일은 이 저장소에서 Claude Code(claude.ai/code)로 작업할 때 필요한 가이드를 제공합니다.

## 명령어

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (lib/database/ 또는 lib/model/의 Drift 스키마 수정 후 필수)
dart run build_runner build --delete-conflicting-outputs

# 실행
flutter run

# 테스트
flutter test

# 분석
flutter analyze

# 에셋 생성 (pubspec.yaml의 아이콘/스플래시 설정 변경 후 실행)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## 프로젝트 정보

- **패키지:** `expense_diary` v2.1.2+9
- **플랫폼:** Android, iOS
- **주 언어:** 한국어(ko_KR), 영어(en_US) 폴백
- **테마:** Material 3, IBM Plex Sans KR, 밝기 자동 감지

## 아키텍처

**상태 관리**: BLoC/Riverpod/Provider를 사용하지 않음. 대부분의 상태는 SQLite(Drift)에 저장됨. UI는 `StreamBuilder`를 사용하여 `Stream<T>` 쿼리를 구독. `AppSettings`는 `ChangeNotifier`를 확장하며, UI에서는 `AnimatedBuilder`로 감싼 후 사용. GetIt은 서비스 로케이터로, 모든 싱글톤은 `main()`에서 `runApp()` 이전에 등록되고 `GetIt.I<T>()`로 접근.

**GetIt에 등록된 싱글톤:**
- `LocalDatabase` — Drift ORM
- `AuthRepository` — Firebase 이메일 + Google 로그인 (google_sign_in v7: `GoogleSignIn.instance.authenticate()`)
- `FirestoreTransactionRepository` — Firestore 클라우드 동기화
- `AppSettings` — 통화, 언어 설정(ChangeNotifier)
- `SnapshotService` — 클라우드 백업/복원
- `ReportCsvService` / `ReportPdfService` — 내보내기 기능

**데이터베이스**: `lib/database/drift_database.dart`에서 스키마와 모든 쿼리 메서드 정의. `drift_database.g.dart`는 자동 생성되므로 수동 편집 금지. 스키마 버전: `1` (아직 마이그레이션 미구현).

테이블:
- `Expenses`: id, categoryId (nullable FK→Category), expenseName, expense (금액, int), expenseDate, expenseDetail (nullable)
- `Category`: id, categoryName (unique)

Drift 데이터베이스 클래스 또는 테이블 정의 수정 후 `build_runner`를 실행하여 `.g.dart` 재생성.

**계층 구조**:
- `lib/database/` — Drift ORM, 모든 DB 쿼리(watch/select/create/update/delete)
- `lib/model/` — 테이블 정의 및 DTO (예: 집계 쿼리용 `CategoryExpense`)
- `lib/screen/` — 전체 화면. `RootScreen`은 `IndexedStack`으로 하단 내비게이션 관리
- `lib/component/` — 재사용 가능한 위젯. 통계 뷰는 DB 스트림에 직접 `StreamBuilder` 사용
- `lib/auth/` — Firebase/Google 인증 (`AuthRepository`)
- `lib/core/time/` — KST 주차 키 헬퍼(백업 메타데이터용)
- `lib/features/backup/` — 스냅샷 도메인 모델, 서비스, Firebase 저장소
  - `data/backup_metadata_keys.dart` — SharedPreferences/Firestore 백업 메타데이터 키 상수 (`BackupMetadataKeys`)
- `lib/features/report/` — CSV 및 PDF 내보내기 서비스
- `lib/service/` — `AppSettings`(통화, 언어, ChangeNotifier)
- `lib/const/` — 색상, 테마(`AppTheme`), 통화 유틸, Firebase 설정
- `lib/data/firestore/` — Firestore 트랜잭션 DTO 및 저장소
- `third_party/` — 로컬 `google_mobile_ads` 패키지

**내비게이션**: `RootScreen`이 `IndexedStack`으로 관리하는 5개 탭 (탭 전환 시 화면 재구성 없음):
1. 지출 (홈) — 오늘의 지출 목록
2. 지출 내역 (캘린더) — 일별 합계를 포함한 달력 뷰
3. 분류 (카테고리) — 카테고리 CRUD
4. 통계 (`StatisticsTabScreen`) — 통계/CSV/PDF 서브화면으로 이동하는 메뉴 화면 (`ReportStatisticsScreen`, `ReportCsvExportScreen`, `ReportPdfExportScreen` 진입점)
5. 설정 (설정) — 언어, 통화, 백업, 계정

## 구독 시스템 제거 상태

RevenueCat, Paywall, StoreKit 로컬 구성, 요금제 제한, `purchases_flutter` 의존성은 활성 코드에서 제거됨. `lib/core/subscription/`, `lib/screen/paywall_screen.dart`, `test/core/subscription/` 등 관련 파일 전체 삭제. 백업/복원 및 통계/CSV/PDF 기능은 구독 확인 없이 사용할 수 있음.

## 광고

`lib/component/banner_ad_widget.dart`의 `BannerAdWidget`에서 직접 배너를 로드. iOS는 프로덕션 AdUnit ID, Android는 현재 테스트 ID 사용. 광고 생명 주기를 신중하게 처리. 위젯이 내부적으로 로드/해제를 관리.

배너 광고 표시 위치: 홈 화면 상단, 카테고리 화면 하단, 설정 화면 하단, 통계 탭 화면 하단(`StatisticsTabScreen`).

## 다국어 지원

- **엔진:** `easy_localization`으로 `assets/locales/`의 JSON 로케일 파일 사용
- **파일:** `ko.json`(기본), `en.json`(폴백)
- **범위:** 대부분의 화면이 완전히 현지화됨. 다음은 여전히 한국어 문자열이 하드코딩되어 있음 (다국어 후보):
  - `lib/screen/report_csv_export_screen.dart`
  - `lib/screen/report_pdf_export_screen.dart`
  - `lib/screen/snapshot_restore_screen.dart`

## 클라우드 백업

스냅샷 기반: `SnapshotService`가 모든 Drift 데이터 + SharedPreferences를 읽고, 정규 JSON(SplayTreeMap을 통한 키 정렬)으로 직렬화한 후, SHA-256 해시를 생성하고 Firestore에 업로드. 복원은 로컬 데이터를 Drift 트랜잭션으로 초기화한 후 재삽입.

백업 메타데이터 키(`lastBackupAt`, `lastBackupWeekKey`)는 `BackupMetadataKeys` 상수 클래스(`lib/features/backup/data/backup_metadata_keys.dart`)로 중앙 관리. SharedPreferences 저장 키와 Firestore 필드명이 분리되어 있음.

`ConfigScreen`은 인증 상태 변경 시(`authStateChanges`) 클라우드 백업 메타데이터를 자동으로 다시 로드.

`cloud_transaction_screen.dart`는 코드베이스에 존재하지만 UI에서 더 이상 접근 불가능 (커밋 `f00d536`에서 진입점 제거).

## 보고서/내보내기

`ReportCsvService`와 `ReportPdfService`는 `lib/features/report/`에 위치. 내보내기 화면은 `share_plus`를 사용하여 네이티브 공유 시트 실행.

## 주요 규칙

- 모든 화면은 `GetIt.I<T>()`를 통해 직접 서비스 접근 (위젯에 생성자 주입 없음)
- `AppBackground` 위젯이 그래디언트 배경 제공. 모든 탭 화면은 `Scaffold(backgroundColor: Colors.transparent)` + `AppBackground` 사용
- 날짜 형식은 `intl` 사용, `main.dart`에서 `initializeDateFormatting`으로 한국어 로케일 초기화
