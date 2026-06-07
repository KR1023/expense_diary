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

## 개발 진행 사항

작업 내역은 루트의 `progress.md`에 기록한다. Claude Code와 Codex가 공동으로 참조하는 파일이므로, 기능 추가·변경·수정 작업 완료 시 해당 내용을 `progress.md`에 업데이트한다.

## 프로젝트 정보

- **패키지:** `expense_diary` v2.5.1+19
- **플랫폼:** Android, iOS
- **주 언어:** 한국어(ko_KR), 영어(en_US) 폴백
- **테마:** Material 3, IBM Plex Sans KR, 밝기 자동 감지

## 아키텍처

**상태 관리**: BLoC/Riverpod/Provider를 사용하지 않음. 대부분의 상태는 SQLite(Drift)에 저장됨. UI는 `StreamBuilder`를 사용하여 `Stream<T>` 쿼리를 구독. `AppSettings`는 `ChangeNotifier`를 확장하며, UI에서는 `AnimatedBuilder`로 감싼 후 사용. GetIt은 서비스 로케이터로, 모든 싱글톤은 `main()`에서 `runApp()` 이전에 등록되고 `GetIt.I<T>()`로 접근.

**GetIt에 등록된 싱글톤:**
- `LocalDatabase` — Drift ORM
- `AuthRepository` — Firebase 이메일 + Google 로그인 (google_sign_in v7: `GoogleSignIn.instance.authenticate()`)
- `FirestoreTransactionRepository` — Firestore 클라우드 동기화
- `AppSettings` — 통화, 언어, 배경 테마(`backgroundIndex`) 설정(ChangeNotifier)
- `SubscriptionService` — RevenueCat 구독 상태 관리(ChangeNotifier)
- `SnapshotService` — 클라우드 백업/복원
- `ReportCsvService` / `ReportPdfService` — 내보내기 기능

**데이터베이스**: `lib/database/drift_database.dart`에서 스키마와 모든 쿼리 메서드 정의. `drift_database.g.dart`는 자동 생성되므로 수동 편집 금지. 스키마 버전: `3`.

테이블:
- `Expenses`: id, categoryId (nullable FK→Category), expenseName, expense (금액, int), expenseDate, expenseDetail (nullable), paymentMethodId (nullable FK→PaymentMethods), recurringExpenseId (nullable FK→RecurringExpenses), recurringOccurrenceDate (nullable)
- `Category`: id, categoryName (unique), usePresetAmount (bool), presetAmount (nullable int), autoFillExpenseName (bool)
- `PaymentMethods`: id, type (cash/card/bank/mobilePay/other), name, memo (nullable), sortOrder, isArchived, createdAt, updatedAt
- `RecurringExpenses`: id, name, amount, categoryId (nullable), paymentMethodId (nullable), detail (nullable), frequency (daily/weekly/monthly/yearly), interval, startDate, endDate (nullable), nextRunDate, isActive, createdAt, updatedAt

Drift 데이터베이스 클래스 또는 테이블 정의 수정 후 `build_runner`를 실행하여 `.g.dart` 재생성.

**계층 구조**:
- `lib/database/` — Drift ORM, 모든 DB 쿼리(watch/select/create/update/delete)
- `lib/model/` — 테이블 정의 및 DTO (예: 집계 쿼리용 `CategoryExpense`)
- `lib/screen/` — 전체 화면. `RootScreen`은 `IndexedStack`으로 하단 내비게이션 관리
- `lib/component/` — 재사용 가능한 위젯. 통계 뷰는 DB 스트림에 직접 `StreamBuilder` 사용
  - `lib/component/common/gradient_fab.dart` — 그라디언트 알약 스타일 FAB (`GradientFab`)
  - `lib/component/common/select_field.dart` — 드롭다운 셀렉트 필드 (`SelectField<T>`)
  - `lib/component/common/app_background.dart` — 앱 배경 위젯 (`AppBackground`)
- `lib/auth/` — Firebase/Google 인증 (`AuthRepository`)
- `lib/core/time/` — KST 주차 키 헬퍼(백업 메타데이터용)
- `lib/core/recurring/` — 반복 지출 일정 계산(`RecurringSchedule`), 자동 생성 서비스(`RecurringExpenseService`)
- `lib/features/backup/` — 스냅샷 도메인 모델, 서비스, Firebase 저장소
  - `data/backup_metadata_keys.dart` — SharedPreferences/Firestore 백업 메타데이터 키 상수 (`BackupMetadataKeys`)
- `lib/features/report/` — CSV 및 PDF 내보내기 서비스
- `lib/service/` — `AppSettings`(통화, 언어, ChangeNotifier)
- `lib/const/` — 색상, 테마(`AppTheme`), 통화 유틸, Firebase 설정
- `lib/data/firestore/` — Firestore 트랜잭션 DTO 및 저장소
- `third_party/` — 로컬 `google_mobile_ads` 패키지

**내비게이션**: `RootScreen`이 `IndexedStack`으로 관리하는 6개 탭 (탭 전환 시 화면 재구성 없음):
1. 지출 (홈) — 선택 날짜 기반 지출 목록 (날짜 선택 버튼·오늘 버튼·좌우 스와이프로 날짜 이동), FAB heroTag: `home_fab`
2. 지출 내역 (캘린더) — 일별 합계를 포함한 달력 뷰
3. 분류 (카테고리) — 카테고리 CRUD
4. 고정 지출 (`RecurringExpenseScreen`) — 반복/고정 지출 목록·관리, FAB heroTag: `recurring_expense_fab`
5. 통계 (`StatisticsTabScreen`) — 통계/CSV/PDF 서브화면으로 이동하는 메뉴 화면 (`ReportStatisticsScreen`, `ReportCsvExportScreen`, `ReportPdfExportScreen` 진입점)
6. 설정 (설정) — 언어, 통화, 백업, 계정, 결제 수단 관리, 구독 플랜

IndexedStack 특성상 여러 탭이 동시에 마운트되므로 FAB가 있는 탭은 고유 `heroTag` 필수.

## 구독 시스템

RevenueCat(`purchases_flutter`)으로 Android 구독 관리. iOS는 사업자 등록 전으로 Free 플랜으로 동작하며 구독 버튼 탭 시 "준비 중" 안내 표시.

**플랜 구성:**
- `Free` — 주 1회 백업, 일 1회 복원, 광고 표시, 고정 지출 최대 10개, 결제 수단 최대 5개
- `Cloud` — 광고 제거, 무제한 백업/복원, 고정 지출·결제 수단 무제한 (`cloud` 엔타이틀먼트)
- `Report` — Cloud 포함 + 통계/CSV/PDF (`report` 엔타이틀먼트)

`isCloudEntitled`는 `_cloudEntitled || _reportEntitled`로 계산 — Report 플랜이 Cloud 기능 포함.
`isAdsRemoved = isCloudEntitled`.

**핵심 파일:**
- `lib/const/revenuecat_config.dart` — API 키·엔타이틀먼트 ID 상수 (`--dart-define` 주입)
- `lib/core/subscription/subscription_service.dart` — SDK 초기화, 엔타이틀먼트 상태(`ChangeNotifier`), Firebase UID 연동(`loginUser`/`logoutUser`)
- `lib/screen/paywall_screen.dart` — 구독 결제 화면 (iOS: "준비 중" 화면)
- `lib/screen/subscription_screen.dart` — 플랜 관리 화면 (현재 플랜, 업그레이드, 해지)

**Firebase UID 연동:** 로그인 시 `Purchases.logIn(uid)`, 로그아웃 시 `Purchases.logOut()` 호출로 구독이 Firebase 계정에 귀속됨. `main()`에서 `authStateChanges` 리스너로 자동 동기화.

**무료 사용자 제한:** `SharedPreferences`에 `lastBackupWeekKey`(YYYY-WW), `lastRestoreDayKey`(YYYY-MM-DD) 저장. 한도 초과 시 설정 화면에 다음 가능 일시 표시.

**계정별 수동 권한 (Firestore `userEntitlements/{uid}`):** RevenueCat 구독 외에 Firebase 관리자 콘솔에서 계정별로 수동으로 유료 기능을 부여할 수 있음. 최종 권한은 RevenueCat 엔타이틀먼트 OR Firestore 수동 권한으로 합산. 클라이언트 write는 Firestore Rules로 전면 차단, read만 본인 문서 허용. 로그아웃 시 수동 권한 초기화.
- 지원 필드: `role`(normal/cloud/report/special/admin), `manualCloud`, `manualReport`, `manualAdsRemoved`
- `report`/`special`/`admin` role은 Cloud 포함, `special`/`admin`은 전체 유료 기능 허용
- 핵심 파일: `lib/core/subscription/subscription_service.dart`, `firestore.rules`, `docs/auth/account_entitlements.md`

**Android Studio 실행 설정** (`.idea/runConfigurations/`):
- `main.dart` — 프로덕션 키
- `main.dart (Force Entitled)` — `RC_FORCE_ENTITLED=true`, UI 테스트용

**iOS App Store 연동 시 할 작업:** `docs/revenue_cat/ios_setup.md` 참고.

**플랜 한도 초과 처리:** 한도 초과 시 업그레이드 안내 다이얼로그 → `SubscriptionScreen`으로 이동. 고정 지출 폼(`recurring_expense_form_screen.dart`)·결제 수단 폼(`payment_method_screen.dart`)에서 각각 처리.

## 광고

`lib/component/banner_ad_widget.dart`의 `BannerAdWidget`에서 직접 배너를 로드. iOS는 프로덕션 AdUnit ID, Android는 현재 테스트 ID 사용. 광고 생명 주기를 신중하게 처리. 위젯이 내부적으로 로드/해제를 관리.

`BannerAdWidget`은 `AnimatedBuilder`로 `SubscriptionService`를 감시하여 `isAdsRemoved`(= `isCloudEntitled`) 가 true이면 `SizedBox.shrink()` 반환 — Cloud/Report 구독자에게는 광고가 표시되지 않음.

배너 광고 표시 위치: 홈 화면 상단, 카테고리 화면 하단, 설정 화면 하단, 통계 탭 화면 하단(`StatisticsTabScreen`).

## 다국어 지원

- **엔진:** `easy_localization`으로 `assets/locales/`의 JSON 로케일 파일 사용
- **파일:** `ko.json`(기본), `en.json`(폴백)
- **범위:** 대부분의 화면이 완전히 현지화됨. 다음은 여전히 한국어 문자열이 하드코딩되어 있음 (다국어 후보):
  - `lib/screen/report_csv_export_screen.dart`
  - `lib/screen/report_pdf_export_screen.dart`
  - `lib/screen/snapshot_restore_screen.dart`

## 클라우드 백업

스냅샷 기반: `SnapshotService`가 모든 Drift 데이터 + SharedPreferences를 읽고, 정규 JSON(SplayTreeMap을 통한 키 정렬)으로 직렬화한 후, SHA-256 해시를 생성.

**저장 구조 (Firebase Storage 전환 후):**
- 페이로드(JSON): Firebase Storage `users/{uid}/snapshots/{snapshotId}.json`
- 메타데이터: Firestore `users/{uid}/snapshots/{snapshotId}` + `payloadStoragePath` 필드
- 복원 시 `payloadStoragePath` 유무로 신/구 포맷 자동 구분 (하위 호환 유지)
- 사용자별 최신 5개 스냅샷만 보관 — 새 백업 후 초과분은 오래된 것부터 Firestore 메타데이터 + Storage 페이로드 함께 삭제
- 백업 시 스냅샷 이름 입력 가능 (미입력 시 `yyyy.MM.dd HH:mm` 자동 이름)
- 복원 화면에서 선택 삭제·전체 삭제 지원

**백업 페이로드 포함 테이블:** `expenses`, `category`, `paymentMethods`, `recurringExpenses` + SharedPreferences 설정. 빈 목록(`paymentMethods`, `recurringExpenses`)은 `toJson()`에서 생략 — 기존 백업과 해시 호환성 유지.

**복원 순서 (FK 제약):** expenses → recurringExpenses → category → paymentMethods 삭제 후 역순 삽입. Drift 직렬화의 DateTime은 unix timestamp(int, ms)이므로 `_parseDateTime`에서 int 처리 필수.

백업 메타데이터 키(`lastBackupAt`, `lastBackupWeekKey`, `lastRestoreDayKey`)는 `BackupMetadataKeys` 상수 클래스(`lib/features/backup/data/backup_metadata_keys.dart`)로 중앙 관리.

`ConfigScreen`은 인증 상태 변경 시(`authStateChanges`) 클라우드 백업 메타데이터를 자동으로 다시 로드.

`cloud_transaction_screen.dart`는 코드베이스에 존재하지만 UI에서 더 이상 접근 불가능 (커밋 `f00d536`에서 진입점 제거).

## 결제 수단

`lib/screen/payment_method_screen.dart`에서 관리. 설정 탭 → 결제 수단 관리 진입.

- 유형: cash / card / bank / mobilePay / other
- 삭제는 `isArchived = true` 처리 (과거 지출 참조 보호)
- `ReorderableListView`로 드래그 순서 변경 → `reorderPaymentMethods()` 호출
- `PaymentMethodSelect` 컴포넌트(`lib/component/payment_method_select.dart`)로 지출 추가/수정 폼에서 선택
- `ExpenseCard`에 결제 수단 배지 표시 (muted 스타일)
- Free 플랜 최대 5개 제한 (archived 제외 카운트)
- **중복 방지:** 같은 유형+이름의 활성 결제 수단이 있으면 신규 추가·수정 차단
- **복원 정책:** 같은 유형+이름의 삭제된 결제 수단이 있으면 복원 여부 확인 후 기존 ID 재사용 (과거 지출이 다시 동일 수단으로 연결됨)
- **삭제된 수단 표시:** `PaymentMethodSelect`에서 archived 선택값은 `{이름} (삭제됨)`으로 표시 — assertion 방지
- 지출 추가/수정 폼의 셀렉트에서 즉시 추가 버튼으로 바로 결제 수단 생성 가능 (Free 플랜 한도 동일 적용)

## 분류

`lib/screen/category_screen.dart`에서 관리. 분류 탭 직접 진입.

- 분류 추가/수정은 다이얼로그 방식
- **기본값 옵션 (스키마 v3):** 분류에 선택형 기본값 설정 가능
  - `usePresetAmount` + `presetAmount`: 체크 시 지출 추가/수정 폼에서 분류 선택 시 금액 자동 입력
  - `autoFillExpenseName`: 체크 시 지출명에 분류명 자동 입력
  - 설정된 옵션은 분류 목록에 칩 형태로 표시
- **삭제 정책:** 관련 지출이 있는 분류도 삭제 가능. 삭제 시 관련 지출의 `categoryId`를 `null`(미분류)로 변경 후 삭제 (transaction 처리). 관련 지출 수 확인 다이얼로그 선표시.
- 지출 추가/수정 폼의 셀렉트에서 즉시 추가 버튼으로 바로 분류 생성 가능

## 고정 지출

`lib/screen/recurring_expense_screen.dart` + `recurring_expense_form_screen.dart`.

- `RecurringSchedule`(`lib/core/recurring/recurring_schedule.dart`): 주기별 다음 실행일 계산, 월말 clamp 처리
- `RecurringExpenseService.generateDueExpenses()`: nextRunDate <= today인 항목을 실제 Expense로 생성 (최대 100건, 중복 방지)
- 자동 생성 타이밍: 앱 시작(`main.dart`), 고정 지출 탭 진입, 폼 저장 직후
- 삭제는 `isActive = false` 처리, 이미 생성된 Expense는 유지
- 반복 규칙 수정 → 앞으로 생성될 지출에만 반영
- 자동 생성된 지출은 `recurringExpenseId != null`이며 ExpenseCard에 ↻ 아이콘 표시
- Free 플랜 활성 항목 최대 10개 제한

## 보고서/내보내기

`ReportCsvService`와 `ReportPdfService`는 `lib/features/report/`에 위치. 내보내기 화면은 `share_plus`를 사용하여 네이티브 공유 시트 실행.

## 지출 내역 (캘린더)

`lib/screen/calendar_screen.dart`. 달력 + 월간 요약 화면.

- 달력 일자 하단에 일별 합계 금액 표시
- 달력 아래 월 합계/선택 일자 합계 통합 카드
- 월간 요약 카드: 주차별 합계·분류별 합계를 `PageView` 탭으로 분리 (클릭·스와이프 동기화)
- 월 합계, 분류별 합계, 결제 수단별 합계는 `start <= expenseDate < nextMonthStart` 기준으로 통일
- 달력 일자별 합계는 월 범위 지출을 Dart에서 `yyyy-MM-dd` 기준으로 누적 합산

## 지출 통계

`lib/screen/report_statistics_screen.dart`. `report` 엔타이틀먼트 게이트.

스트림 구독 방식으로 상태 관리 (`_subscribe()` / `_cancelAll()`). 월 변경 시 전체 재구독.

**표시 항목:**
- 월별 요약 카드: 총 지출, 건수, 일 평균, 전월 대비(빨강/초록), 최대 지출일
- 분류별 Top 5: 막대차트 + 목록
- 결제 수단별 지출: 막대 비율 + % — 탭 시 `DraggableScrollableSheet`로 상세 목록 표시

**관련 DB 쿼리:**
- `countMonthExpenses(DateTime)` — 월별 건수
- `watchMonthlyPaymentMethodExpense(DateTime)` — 결제 수단별 집계
- `watchMonthExpensesByPaymentMethod(DateTime, int?)` — 특정 수단의 지출 목록

## 배경 테마 시스템

`AppSettings.backgroundIndex`(0~8)로 배경 테마를 관리. 0은 그라디언트, 1~8은 단색.

**`AppColors` 테마 헬퍼 — 배경 인덱스에 반응하는 색상:**
- `AppColors.accentColorForBackground(bgIndex, context)` — 테마별 대표 accent 색
- `AppColors.heroGradientForBackground(bgIndex, context)` — 히어로 카드·FAB·다이얼로그 헤더용 그라디언트
- `AppColors.cardColorOf(bgIndex, context)` — 카드/다이얼로그/바텀 시트 배경색
- `AppColors.outlineColorOf(bgIndex, context)` — 테마별 테두리색

**테마 반응형 위젯 패턴:**
```dart
AnimatedBuilder(
  animation: GetIt.I<AppSettings>(),
  builder: (context, _) {
    final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
    final accentColor = AppColors.accentColorForBackground(bgIndex, context);
    final gradient = AppColors.heroGradientForBackground(bgIndex, context);
    final cardColor = AppColors.cardColorOf(bgIndex, context);
    final outlineColor = AppColors.outlineColorOf(bgIndex, context);
    // ...
  },
)
```

**테마 반응형 다이얼로그 패턴** (분류·결제 수단 다이얼로그 참고):
```dart
Dialog(
  backgroundColor: cardColor,
  clipBehavior: Clip.antiAlias,
  child: Column(children: [
    Container(decoration: BoxDecoration(gradient: gradient), child: /* 헤더 */),
    /* 본문 */,
    /* 버튼: FilledButton.styleFrom(backgroundColor: accentColor) */,
  ]),
)
```

**테마 반응형 바텀 시트 패턴** (`showModalBottomSheet(backgroundColor: Colors.transparent)` + 내부 `Container(color: cardColor)`).

## 주요 규칙

- 모든 화면은 `GetIt.I<T>()`를 통해 직접 서비스 접근 (위젯에 생성자 주입 없음)
- `AppBackground` 위젯이 배경 제공 (`backgroundIndex`에 따라 그라디언트 또는 단색). 모든 탭 화면은 `Scaffold(backgroundColor: Colors.transparent)` + `AppBackground` 사용
- `AppBackground`는 `Theme` 오버라이드로 `colorScheme.surface`, `colorScheme.outline`, `cardTheme`, `inputDecorationTheme`을 배경 테마에 맞게 자동 교체 → `Card`, `TextField`, `DropdownButtonFormField` 등 surface 기반 위젯이 자동 반응
- 배경 테마에 반응해야 하는 색상(버튼·아이콘·헤더 등)은 반드시 `AppColors` 테마 헬퍼를 `AnimatedBuilder(GetIt.I<AppSettings>())` 안에서 사용
- 날짜 형식은 `intl` 사용, `main.dart`에서 `initializeDateFormatting`으로 한국어 로케일 초기화
