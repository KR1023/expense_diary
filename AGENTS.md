# AGENTS.md

## 프로젝트 요약
- 한국어를 기본, 영어를 보조 로케일로 사용하는 Flutter 지출 관리 앱입니다.
- 상태는 Drift 기반 SQLite에 저장하며, UI는 주로 `StreamBuilder` 스트림으로 데이터를 구독합니다.
- 광고는 `third_party/` 아래의 로컬 `google_mobile_ads` 패키지를 통해 연동합니다.
- RevenueCat 구독은 Android에서 활성화되어 있고, iOS 구독 구매 UI는 임시 비활성화 상태이며 “준비 중”으로 표시합니다.
- 사용자가 직접 관리하는 결제 수단과 고정 지출 기능을 지원합니다.

## 기술 스택
- Flutter / Dart (`sdk: ^3.7.2`)
- Drift ORM + SQLite (`drift`, `drift_flutter`, `drift_dev`)
- 서비스 로케이터: `get_it`
- 다국어: `flutter_localizations`, `intl`, `easy_localization`
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- 구독: RevenueCat `purchases_flutter` 사용. Android 활성, iOS 임시 비활성.
- 인증: 이메일/비밀번호, Google 로그인, iOS/macOS의 Sign in with Apple.

## 주요 디렉터리
- `lib/main.dart`: 앱 부트스트랩, 다국어, 테마, `GetIt` 등록.
- `lib/database/`: Drift DB (`drift_database.dart`)와 생성 코드 (`drift_database.g.dart`).
- `lib/model/`: Drift 테이블 정의와 DTO.
- `lib/screen/`: 앱 화면과 `RootScreen` 하단 탭 내비게이션.
- `lib/core/subscription/`: RevenueCat 구독 상태와 권한 헬퍼.
- `lib/core/recurring/`: 고정 지출 스케줄 계산과 due 지출 생성.
- `lib/const/`: Firebase Auth, RevenueCat dart-define 등 앱 상수.
- `lib/features/backup/`: 스냅샷 백업/복원 도메인과 Firebase Firestore/Storage 저장소.
- `lib/features/report/`: CSV/PDF 리포트 내보내기 서비스.
- `lib/component/`: 광고, 통계, 셀렉트 등 재사용 위젯.
- `third_party/`: 로컬 `google_mobile_ads` 의존성.
- `asset/`: 앱 이미지, 스플래시, 아이콘.
- `docs/revenue_cat/`: RevenueCat 콘솔/코드/Android/iOS 설정 문서.
- `docs/subscription/`: 구독 정책, 플랜 구성, RevenueCat/스토어 운영 전환 문서.
- `docs/deployment/`: Android/iOS 배포 명령과 체크리스트.
- `docs/Structure/`: 로컬/클라우드 데이터 저장 구조 문서.
- `progress.md`: 작업 진행 요약. 사용자가 명시적으로 요청할 때만 업데이트합니다.

## 작업 규칙
- `AGENTS.md`는 한글로 작성하고 유지합니다.
- `progress.md`는 사용자가 “progress.md 업데이트”를 명시적으로 요청할 때만 수정합니다.
- 사용자가 요청하지 않은 문서 업데이트는 `AGENTS.md`처럼 현재 작업 규칙 유지에 필요한 경우로 제한합니다.

## 데이터 모델 (Drift)
- 현재 로컬 DB 스키마 버전: `3`.
- `Expense`: id, categoryId(nullable), paymentMethodId(nullable), recurringExpenseId(nullable), recurringOccurrenceDate(nullable), expenseName, expense(int), expenseDate, expenseDetail(nullable).
- `Category`: id, categoryName(unique), usePresetAmount, presetAmount(nullable), autoFillExpenseName.
- `PaymentMethods`: id, type(`cash` / `card` / `bank` / `mobilePay` / `other`), name, memo(nullable), sortOrder, isArchived, createdAt, updatedAt.
- `RecurringExpenses`: id, name, amount, categoryId(nullable), paymentMethodId(nullable), detail(nullable), frequency(`daily` / `weekly` / `monthly` / `yearly`), interval, startDate, endDate(nullable), nextRunDate, isActive, createdAt, updatedAt.
- `PaymentMethodExpense`: 결제 수단별 월 집계 DTO.
- 분류 기본값은 선택 사항입니다. `usePresetAmount=true`이면 지출 추가/수정에서 해당 분류 선택 시 `presetAmount`가 금액에 자동 입력됩니다. `autoFillExpenseName=true`이면 지출명이 분류명으로 자동 입력됩니다.
- 분류 삭제 시 관련 지출은 transaction 안에서 `Expense.categoryId`를 `null`로 바꾼 뒤 분류를 삭제합니다. 지출 row는 삭제하지 않습니다.
- 결제 수단은 실제 삭제하지 않고 `isArchived=true`로 보관하여 과거 지출 참조를 유지합니다.
- 활성 결제 수단 중 같은 `type + name` 추가/수정은 차단합니다. 같은 `type + name`의 보관된 결제 수단을 다시 추가하면 복원 확인 후 원래 ID를 재사용해 과거 지출/통계와 다시 연결합니다.
- `PaymentMethodSelect`는 보관된 결제 수단이 선택값으로 들어오는 상황을 허용해야 합니다. 과거 지출이나 고정 지출 규칙이 보관된 결제 수단을 계속 참조할 수 있으므로, `watchPaymentMethods()` 결과에 없더라도 현재 선택값을 삭제된 항목으로 표시합니다.
- 고정 지출은 실행일이 도래했을 때만 실제 `Expense` row를 생성합니다. 미래 데이터를 미리 대량 생성하지 않습니다.
- 고정 지출 생성은 실행당 최대 100건이며, `recurringExpenseId + recurringOccurrenceDate` 조합으로 중복 생성을 방지합니다.
- 날짜 기반 지출 목록/합계 쿼리는 정확한 `DateTime` equality를 사용하지 말고 half-open range를 사용합니다. 복원/마이그레이션 데이터에는 자정이 아닌 시간값이 포함될 수 있습니다.
- 일자 기준 쿼리는 `start <= expenseDate < nextDay`, 월 기준 쿼리는 `monthStart <= expenseDate < nextMonthStart`, 주차 기준 쿼리는 `weekStart <= expenseDate < dayAfterWeekEnd`를 사용합니다.
- `isBetweenValues(start, end)`는 end 값을 포함할 수 있어 월/일 경계 데이터가 중복 집계될 수 있으므로 날짜 합계 쿼리에는 사용하지 않습니다.
- 달력 일자별 합계는 월 범위 지출을 조회한 뒤 `DateTime(year, month, day)` key로 누적 합산합니다. 같은 날짜에 시간이 다른 지출이 여러 건 있어도 덮어쓰지 말고 누적해야 합니다.

테이블 정의나 DB 로직 변경 후에는 생성 코드를 갱신합니다.
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 자주 쓰는 명령
```bash
# 의존성 설치
flutter pub get

# 실행
flutter run

# 테스트
flutter test

# 정적 분석
flutter analyze

# Drift 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 아이콘/스플래시 생성
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## RevenueCat / 구독 상태
- RevenueCat은 Android에 재통합되어 있습니다. iOS는 `SubscriptionService._configure()`에서 현재 비활성화되어 있으며, App Store 구독 설정이 준비될 때까지 Free처럼 동작합니다.
- Firebase UID는 `lib/main.dart`에서 `loginUser()` / `logoutUser()`를 통해 RevenueCat app user ID와 연결합니다.
- Firestore `userEntitlements/{uid}` 문서로 계정별 수동 권한을 지원합니다. 문서가 없으면 role은 `normal`, 수동 권한은 없음으로 처리합니다.
- 수동 권한 필드: `role`(`normal`, `cloud`, `report`, `special`, `admin`), `manualCloud`, `manualReport`, `manualAdsRemoved`. 호환 alias boolean으로 `cloud`, `report`, `adsRemoved`도 허용합니다.
- 최종 권한은 RevenueCat 권한과 수동 권한을 OR로 합산합니다. `report`, `special`, `admin` role은 Cloud 권한을 포함하며, `special`, `admin`은 전체 유료 기능을 해제합니다.
- Firestore Rules는 사용자가 본인의 `userEntitlements/{uid}` 문서만 읽을 수 있게 하고, 클라이언트 write는 전부 차단합니다. 수동 권한 변경은 Firebase Console 또는 Admin SDK로만 수행합니다.
- 현재 코드 기준 플랜:
  - Free: 광고 표시, 백업 KST 기준 주 1회, 복원 KST 기준 일 1회, 활성 고정 지출 10개 제한, 결제 수단 5개 제한.
  - Cloud: 광고 제거, 백업/복원 무제한, 고정 지출 무제한, 결제 수단 무제한.
  - Report: Cloud 포함, 통계/CSV/PDF 내보내기 해제.
- 구독 정책 변경 검토 기준은 `docs/subscription/free_report_subscription_policy.md`에 정리되어 있습니다. 방향은 리포트/통계/CSV/PDF를 무료화하고, 구독은 광고 제거와 클라우드 백업/복원 무제한 및 결제 수단/고정 지출 제한 해제로 단순화하는 것입니다.
- 리포트 무료화 구현 시 `StatisticsTabScreen`의 Report 권한 게이트와 CSV/PDF 내보내기 제한 문구를 제거합니다. 단, 기존 Report 구독자 보호를 위해 `report` entitlement/product/package는 RevenueCat과 코드에서 즉시 삭제하지 않고 호환용으로 유지할 수 있습니다.
- 리포트 무료화 이후에도 기존 Report 권한은 Cloud 혜택(광고 제거, 백업/복원 무제한, 결제 수단/고정 지출 제한 해제)을 포함하도록 유지하는 것이 안전합니다.
- RevenueCat/Play Console 전환 시 신규 판매는 `cloud_monthly` 중심으로 유지하고, `report_monthly`는 Offering 노출과 신규 판매를 중단합니다. 기존 구독자가 있을 수 있으므로 product/entitlement 즉시 삭제는 피합니다.
- iOS 구독을 다시 도입할 경우 Report 상품은 새로 만들지 않고 Cloud 상품만 구성하는 방향이 권장됩니다.
- iOS 구독/페이월 화면은 현재 “준비 중”을 표시합니다. App Store 구독 설정이 완료되기 전까지 iOS 구매 플로우를 활성화하지 않습니다.
- 사용자가 구매를 취소한 경우 정상 취소 흐름으로 처리하고 RevenueCat/API 원문 오류를 사용자에게 노출하지 않습니다.
- 런타임 설정은 `lib/const/revenuecat_config.dart`에서 `--dart-define`으로 읽습니다.
  - `RC_ANDROID_PUBLIC_SDK_KEY`
  - `RC_IOS_PUBLIC_SDK_KEY`
  - `RC_TEST_STORE_KEY` (test store override)
  - `RC_FORCE_ENTITLED` (UI/dev 테스트용. release에 포함 금지)
  - `RC_ENTITLEMENT_CLOUD`, `RC_ENTITLEMENT_REPORT`
  - `RC_OFFERING_CLOUD`, `RC_OFFERING_REPORT`
- 기본 entitlement ID는 `cloud`, `report`입니다.
- 기본 offering/package ID는 `cloud_monthly`, `report_monthly`입니다.

Android release build 예시:
```bash
flutter build appbundle \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud_monthly \
  --dart-define=RC_OFFERING_REPORT=report_monthly
```

## 백업 / 복원
- 스냅샷 payload JSON은 Firebase Storage의 `users/{uid}/snapshots/{snapshotId}.json`에 저장합니다.
- Firestore에는 스냅샷 메타데이터와 `payloadStoragePath`를 저장합니다. 예전 inline-payload Firestore 스냅샷도 계속 읽을 수 있어야 합니다.
- 스냅샷 메타데이터에는 사용자 표시용 `name`이 포함됩니다. 백업 시 이름을 입력받고, 비워두면 로컬 `yyyy.MM.dd HH:mm` 타임스탬프 이름을 기본값으로 사용합니다.
- 스냅샷 이름 입력 다이얼로그의 `TextEditingController`는 다이얼로그 내부 `State`가 소유합니다. `showDialog` 반환 직후 즉시 dispose하면 닫힘 애니메이션 중 필드가 렌더링될 수 있어 오류가 납니다.
- 사용자별 스냅샷은 최대 5개 유지합니다. 새 백업 업로드 후 최신 5개를 초과하는 오래된 스냅샷은 Firestore와 Storage에서 모두 삭제합니다.
- 스냅샷 복원 화면은 최신 5개만 표시하고 선택 삭제와 전체 삭제를 지원합니다.
- 스냅샷 payload에는 지출, 분류, 결제 수단, 고정 지출이 포함됩니다.
- 복원 순서는 FK 안전성을 지켜야 합니다. 현재는 dependent row를 먼저 지우고 parent row를 먼저 다시 삽입한 뒤 dependent row를 삽입합니다.
- 스냅샷 파싱은 Drift snake_case와 앱 camelCase key를 모두 처리합니다.
- 결제 수단/고정 지출 key가 없는 legacy 스냅샷은 빈 리스트로 처리하여 복원 가능해야 합니다.
- 백업 메타데이터는 `users/{uid}/meta/backupQuota`에 저장합니다.
- 로컬 백업/복원 제한 key는 `lib/features/backup/data/backup_metadata_keys.dart`에 있습니다.
- Firestore Rules는 `firestore.rules`에서 관리합니다. Storage Rules를 변경하면 release 전에 Firebase 배포 설정에 포함되어 있는지 확인합니다.

## 인증 / 계정 삭제
- 로그인 옵션:
  - 이메일/비밀번호는 모든 플랫폼에서 사용 가능합니다.
  - Google 로그인은 로그인 화면에서 사용 가능합니다.
  - Sign in with Apple은 iOS/macOS에서만 표시하며 Firebase Auth `AppleAuthProvider`를 사용합니다.
- iOS App Store Guideline 4.8 대응을 위해 iOS에서 Google 로그인을 제공하는 곳에는 Sign in with Apple도 함께 표시해야 합니다.
- iOS Sign in with Apple 요구사항:
  - Apple Developer App ID `com.ysh.expenseDiary`에 Sign in with Apple capability 활성화.
  - `ios/Runner/Runner.entitlements`에 `com.apple.developer.applesignin` 포함.
  - Xcode `Runner > Signing & Capabilities`에 Sign in with Apple 표시.
  - Firebase Authentication Apple provider 활성화.
- 계정 삭제는 로그인한 사용자에게 설정 화면에서 제공됩니다.
- 삭제 플로우는 데이터 삭제 안내를 먼저 표시하고, 최종 확인을 한 번 더 받습니다.
- 계정 삭제는 클라우드 계정 데이터만 제거합니다.
  - Firebase Authentication 현재 사용자.
  - Firestore `users/{uid}/snapshots`, `users/{uid}/transactions`, `users/{uid}/meta`, `users/{uid}`.
  - Firebase Storage `users/{uid}/snapshots/*`.
- 로컬 SQLite 지출 데이터는 계정 삭제 시 의도적으로 삭제하지 않습니다. 로컬 데이터 초기화는 설정의 “모든 데이터 초기화”를 사용합니다.
- Firebase가 `requires-recent-login`을 던지면 다시 로그인 후 삭제를 재시도하도록 안내합니다.

## AdMob / 광고
- 광고는 `third_party/` 아래의 로컬 `google_mobile_ads` 패키지를 사용합니다.
- 광고 단위 ID는 `lib/const/admob_config.dart`에서 설정합니다.
- 기본값:
  - Android banner: `ca-app-pub-5444803558030319/2084179141`
  - iOS banner: `ca-app-pub-5444803558030319/5504549409`
- `--dart-define=ADMOB_ANDROID_BANNER_ID=...`, `--dart-define=ADMOB_IOS_BANNER_ID=...`로 override할 수 있습니다.
- `BannerAdWidget`은 `SubscriptionService.isAdsRemoved`가 true이면 광고를 숨깁니다. Cloud와 Report 권한은 광고를 제거합니다.

## 고정 지출 / 결제 수단
- 결제 수단은 설정 > 결제 수단 관리에서 관리합니다.
- 지출 추가/수정 화면에는 `PaymentMethodSelect`가 포함되고, 지출 카드에는 결제 수단 배지가 표시됩니다.
- 지출 추가/수정의 분류/결제 수단 셀렉트는 즉시 추가 액션을 지원합니다. 결제 수단 즉시 추가도 Cloud/Report 권한이 없으면 Free 플랜의 5개 제한을 동일하게 적용해야 합니다.
- 고정 지출은 `고정 지출` 탭에서 관리합니다.
- `RecurringExpenseService.generateDueExpenses()`는 앱 시작, 고정 지출 탭 진입, 고정 지출 폼 저장 후 실행됩니다.
- `RecurringSchedule`은 daily/weekly/monthly/yearly 반복과 월말 보정을 처리합니다. 유효하지 않은 월말 날짜는 해당 월의 마지막 유효일로 clamp합니다.
- 고정 지출 규칙 삭제는 현재 rule을 hard-delete합니다. 이미 생성된 지출 row는 유지됩니다.

## 앱 흐름
- `RootScreen`은 `IndexedStack`으로 6개 탭을 관리합니다: 지출 / 지출 내역 / 분류 / 고정 지출 / 통계 / 설정.
- FAB가 있는 각 탭은 `IndexedStack` hero 충돌을 피하기 위해 고유 `heroTag`를 사용해야 합니다.
- UI는 DB를 직접 `StreamBuilder`로 구독하여 반응형으로 갱신합니다.
- 지출 홈 탭은 날짜 선택이 가능합니다. 헤더의 달력 버튼은 `showDatePicker`를 열고, 오늘 버튼은 현재 로컬 날짜로 이동합니다. 좌우 스와이프는 하루 단위로 날짜를 이동하며 slide/fade 애니메이션을 사용합니다.
- 홈 선택 날짜가 오늘이면 “오늘 지출/오늘 합계”를 사용하고, 오늘이 아니면 `{yyyy.MM.dd} 지출/{yyyy.MM.dd} 합계`를 사용합니다.
- 홈 탭에서 `AddScreen`을 열 때 현재 선택 날짜를 기본 지출 날짜로 전달합니다.
- 지출 내역 탭은 달력 높이를 우선합니다. 달력 아래에는 월 합계/일자 합계를 합친 compact 카드가 있고, 일자 영역은 상세 드로어를 엽니다. 그 아래에 주차별/분류별 월간 요약 탭 카드가 있습니다. 분류별 합계는 Top-N이나 순위형 통계가 아니라 단순 리스트로 표시합니다.
- 지출 내역 달력의 일자 하단에는 해당 일자의 합계 금액을 compact 형식으로 표시합니다. 지출 금액이 있는 날짜와 없는 날짜의 날짜 숫자 기준선은 같아야 합니다.
- 월간 요약 탭은 `PageView` 기반으로 유지합니다. 탭 클릭 시 `animateToPage`, 좌우 스와이프 시 `onPageChanged`로 세그먼트 선택 상태를 동기화합니다.
- 월간 요약 카드 내부에는 별도 리스트 스크롤을 만들지 않습니다. 주차별/분류별 항목 수만큼 카드 높이가 늘어나도록 유지합니다.
- 월/일 합계 카드의 금액은 숫자와 통화 단위를 분리 렌더링해 단위 간격을 확보합니다. 라벨은 보조 정보이므로 금액보다 작고 가볍게 표시합니다.
- 통계 화면 이름은 `지출 통계`이며 월 요약, 일평균, 전월 비교, 최대 지출일, 분류별 breakdown, 결제 수단별 breakdown/detail sheet를 포함합니다.

## 생성 파일
- `lib/database/drift_database.g.dart`는 생성 파일입니다. 직접 수정하지 않습니다.
- `macos/Flutter/GeneratedPluginRegistrant.swift` 같은 Flutter plugin registrant도 생성 파일입니다. `flutter pub get` 이후 생성 결과가 바뀐 경우가 아니면 직접 수정하지 않습니다.

## 커밋과 푸시
- 사용자가 “커밋/푸시”를 입력하면 현재까지 진행한 사항을 커밋하고 푸시합니다.
- 기본 브랜치는 `main`입니다.
- 푸시는 `origin main`과 `github main` 양쪽에 수행합니다.
