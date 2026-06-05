# 개발 진행 사항

## 최근 작업 내역

---

### 1. 클라우드 백업 — Firebase Storage 전환 (`9a9e98a`)

**배경**
Firestore 문서 1MB 제한으로 인해 데이터가 늘어날수록 백업 실패 가능성이 있었음.

**변경 내용**
- 백업 페이로드(JSON)를 Firestore 문서 인라인 저장 → Firebase Storage(`users/{uid}/snapshots/{id}.json`)로 전환
- Firestore에는 메타데이터 + `payloadStoragePath` 필드만 저장
- 복원 시 `payloadStoragePath` 유무로 신/구 포맷 자동 구분 (하위 호환 유지)
- Firebase Storage 보안 규칙: 인증된 사용자가 자신의 경로만 읽기/쓰기 가능

**관련 파일**
- `lib/features/backup/data/firebase_snapshot_repository.dart`
- `lib/features/backup/domain/snapshot.dart`

---

### 2. RevenueCat 구독 재통합 (`6c6d7d8`)

**배경**
이전에 구독 서비스를 제거한 상태에서 재통합. Android 전용(iOS는 사업자 등록 후 추가 예정).

**플랜 구성**

| 플랜 | 기능 |
|---|---|
| Free (비구독) | 주 1회 백업, 일 1회 복원, 광고 표시 |
| Cloud 플랜 | 광고 제거, 무제한 백업/복원 |
| Report 플랜 | Cloud 플랜 포함 + 통계/CSV/PDF 내보내기 |

**변경 내용**
- `SubscriptionService`: RevenueCat SDK 초기화, 엔타이틀먼트 상태 관리 (`ChangeNotifier`)
- `RevenueCatConfig`: API 키 및 엔타이틀먼트 ID를 `--dart-define`으로 주입
- `PaywallScreen`: 플랜별 구독 화면
- `StatisticsTabScreen`: `report` 엔타이틀먼트 게이트 (잠금 아이콘)
- `BannerAdWidget`: 구독 시 광고 자동 숨김 (`AnimatedBuilder` 반응형)
- 무료 사용자 제한:
  - 백업: KST 주차 기준 주 1회 (`lastBackupWeekKey`)
  - 복원: KST 자정 기준 일 1회 (`lastRestoreDayKey`)
  - 설정 화면에 다음 가능 일시 표시

**Android Studio 실행 설정**
- `main.dart`: 프로덕션 키
- `main.dart (Force Entitled)`: UI 테스트용 (모든 기능 강제 활성화)

**관련 파일**
- `lib/const/revenuecat_config.dart`
- `lib/core/subscription/subscription_service.dart`
- `lib/screen/paywall_screen.dart`
- `lib/screen/subscription_screen.dart`
- `lib/screen/statistics_tab_screen.dart`
- `lib/screen/config_screen.dart`
- `lib/component/banner_ad_widget.dart`
- `.idea/runConfigurations/`

---

### 3. UX 개선 — 토스트 및 확인 팝업 (`75997d3`)

**변경 내용**
- 로그인 성공 시 토스트 표시 (모든 로그인 진입점 공통)
- 로그아웃 시 확인 팝업 (구독 기능 제한 안내 문구 포함)
- 구독 완료 시 토스트 표시
- 구독 버튼 탭 시 비로그인이면 로그인 화면 먼저 진입 (iOS 제외)

---

### 4. RevenueCat — Firebase UID 연동 (`5d60c46`)

**배경**
기존에는 RevenueCat이 기기별 익명 ID로 구독을 관리하여 기기 교체 시 구독 인식 불가.

**변경 내용**
- Firebase 로그인 시 `Purchases.logIn(uid)` → 구독이 Firebase 계정에 귀속
- Firebase 로그아웃 시 `Purchases.logOut()` → 익명 상태로 전환, 엔타이틀먼트 즉시 비활성화
- 앱 시작 시 이미 로그인된 상태면 즉시 UID 연동
- 익명 구독이 있는 경우 `logIn()` 호출 시 RevenueCat이 자동 병합

**동작 요약**

| 상황 | 결과 |
|---|---|
| 로그인 | 해당 계정의 구독 상태 즉시 적용 |
| 로그아웃 | 모든 구독 기능 차단 |
| 기기 교체 후 로그인 | 구독 자동 복원 |
| 여러 기기 동시 사용 | 동일 계정이면 모두 동일 구독 상태 |

**관련 파일**
- `lib/core/subscription/subscription_service.dart`
- `lib/main.dart`

---

### 5. iOS 구독 임시 처리 (`34ff237`)

**배경**
iOS는 사업자 등록 전으로 App Store 구독 불가. 구독 관련 기능 클릭 시 크래시 발생.

**변경 내용**
- iOS에서 RevenueCat SDK 미초기화 유지 (크래시 방지)
- `isCloudEntitled` / `isReportEntitled`에서 `Platform.isIOS` 제거 → iOS도 Free 플랜으로 동작
- `PaywallScreen`: iOS에서 결제 UI 대신 "준비 중" 안내 화면 표시
- 구독 버튼 진입 시 iOS는 로그인 요구 없이 바로 "준비 중" 화면으로 이동

**iOS 현재 동작**

| 기능 | iOS |
|---|---|
| 광고 | 표시됨 (Free) |
| 백업/복원 | 주 1회 / 일 1회 제한 (Free) |
| 통계/리포트 | 잠금 아이콘 → 탭 시 "준비 중" |
| 구독하기 버튼 | "준비 중" 안내 |

**iOS App Store 연동 시 해야 할 작업** (`docs/revenue_cat/ios_setup.md` 참고)
1. 사업자 등록 완료
2. App Store Connect 구독 상품 등록
3. Shared Secret / API Key 발급
4. RevenueCat iOS 앱 추가 및 상품 연결
5. `SubscriptionService._configure()`의 iOS 예외 제거

---

### 6. 구독 SDK/결제 UX 정리 (`ce13bc9`)

**배경**
Android 실행 시 RevenueCat Test Store 응답의 `store: "test_store"`를 기존 SDK가 파싱하지 못해 `E/[Purchases] ... Store does not contain element with name 'test_store'` 오류가 반복됨.

**변경 내용**
- `purchases_flutter`를 `9.12.2`로 고정
- iOS는 계속 RevenueCat 초기화 제외 (`Platform.isIOS` early return)
- Android RevenueCat API 키가 비어 있으면 SDK 호출 없이 Free 상태로 동작
- `purchasePackage` deprecated API 대신 `Purchases.purchase(PurchaseParams.package(...))` 사용
- 결제 취소 시 RevenueCat/API 원문 대신 사용자 문구 표시
  - `결제가 취소되었습니다.`
  - `결제를 완료하지 못했습니다. 잠시 후 다시 시도해 주세요.`
  - `구매 복원에 실패했습니다. 잠시 후 다시 시도해 주세요.`
- 설정 > 구독 플랜 화면에서 iOS는 플랜/복원/업그레이드 대신 "준비 중" 안내만 표시

**관련 파일**
- `pubspec.yaml`
- `pubspec.lock`
- `ios/Podfile.lock`
- `lib/core/subscription/subscription_service.dart`
- `lib/screen/paywall_screen.dart`
- `lib/screen/subscription_screen.dart`
- `assets/locales/ko.json`
- `assets/locales/en.json`

---

### 7. AdMob 광고 단위 ID 플랫폼별 설정 (`76a791e`)

**배경**
Android 실기기에서 테스트 광고가 표시됨. 원인은 Android 배너 광고 단위 ID가 Google 공식 테스트 ID(`ca-app-pub-3940256099942544/6300978111`)로 하드코딩되어 있었기 때문.

**변경 내용**
- `AdMobConfig` 추가
- Android/iOS 배너 광고 단위 ID를 `--dart-define`으로 주입 가능하게 변경
- 환경변수를 지정하지 않으면 플랫폼별 기본 광고 단위 ID 사용

**현재 기본값**

| 플랫폼 | 기본 배너 광고 단위 ID |
|---|---|
| Android | `ca-app-pub-5444803558030319/2084179141` |
| iOS | `ca-app-pub-5444803558030319/5504549409` |

**빌드 인자**

```bash
--dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-5444803558030319/2084179141
--dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-5444803558030319/5504549409
```

**광고 제거 동작**
- `SubscriptionService.isAdsRemoved => isCloudEntitled`
- Cloud 플랜 또는 Report 플랜 entitlement가 active이면 `BannerAdWidget`이 광고를 렌더링하지 않음
- 사용자가 구독을 취소해도 결제 기간 만료일까지 RevenueCat entitlement가 active이면 광고 제거 유지
- 만료 후 entitlement가 inactive가 되면 Free 플랜으로 전환되고 광고 표시

**관련 파일**
- `lib/const/admob_config.dart`
- `lib/component/banner_ad_widget.dart`
- `docs/deployment/android.md`
- `docs/deployment/ios.md`

---

### 8. 결제 수단 + 고정 지출 + 6탭 네비게이션 (`725050b`)

**배경**
지출 입력에 결제 수단 선택 기능을 추가하고, 반복되는 고정 지출을 자동으로 실제 지출 내역에 반영하는 기능 구현. 탭 구조도 5개 → 6개로 확장.

**DB 변경 (스키마 버전 1 → 2)**
- `PaymentMethods` 테이블 추가 (type, name, memo, sortOrder, isArchived, createdAt, updatedAt)
- `RecurringExpenses` 테이블 추가 (name, amount, frequency, interval, startDate, endDate, nextRunDate, isActive, ...)
- `Expenses` 테이블에 `paymentMethodId`, `recurringExpenseId`, `recurringOccurrenceDate` 컬럼 추가
- 기존 사용자 보호를 위한 마이그레이션 작성 (`addColumn` + `createTable`)

**결제 수단**
- 유형: cash / card / bank / mobilePay / other
- `isArchived` 방식으로 삭제 처리 (과거 지출 참조 보호)
- `ReorderableListView`로 드래그 순서 변경 지원
- 설정 화면 → 결제 수단 관리 진입
- 지출 추가/수정 화면에 `PaymentMethodSelect` 컴포넌트 추가
- `ExpenseCard`에 결제 수단 배지 표시

**고정 지출**
- `RecurringSchedule`: 주기별(daily/weekly/monthly/yearly) 다음 실행일 계산, 월말 처리(clamp to last day)
- `RecurringExpenseService`: nextRunDate <= today인 항목을 실제 Expense로 생성 (최대 100건, 중복 방지)
- 자동 생성 타이밍: 앱 시작, 고정 지출 탭 진입, 폼 저장 직후
- 반복 규칙 수정 → 앞으로 생성될 지출에만 반영 (이미 생성된 지출은 유지)
- 비활성화(isActive=false) 방식으로 삭제 처리

**탭 구조 변경**
`지출 / 지출 내역 / 분류 / 고정 지출 / 통계 / 설정` (5탭 → 6탭)
IndexedStack FAB hero 태그 충돌 방지를 위해 각 FAB에 고유 heroTag 지정

**백업/복원 확장**
- `SnapshotPayload`에 `paymentMethods`, `recurringExpenses` 포함
- 복원 시 FK 순서 준수 (expenses → recurringExpenses → category → paymentMethods 삭제 후 역순 삽입)
- 이전 백업 하위 호환: 키 없으면 빈 목록으로 처리
- Drift snake_case / camelCase 키 양쪽 처리

**관련 파일**
- `lib/model/payment_method.dart` (신규)
- `lib/model/recurring_expense.dart` (신규)
- `lib/model/expense.dart`
- `lib/database/drift_database.dart`
- `lib/core/recurring/recurring_schedule.dart` (신규)
- `lib/core/recurring/recurring_expense_service.dart` (신규)
- `lib/component/payment_method_select.dart` (신규)
- `lib/component/expense_card.dart`
- `lib/screen/payment_method_screen.dart` (신규)
- `lib/screen/recurring_expense_screen.dart` (신규)
- `lib/screen/recurring_expense_form_screen.dart` (신규)
- `lib/screen/add_screen.dart`, `detail_screen.dart`, `home_screen.dart`, `config_screen.dart`, `root_screen.dart`
- `lib/features/backup/domain/snapshot.dart`
- `lib/features/backup/data/snapshot_service.dart`

---

### 9. 고정 지출/결제 수단 버그 수정 및 UX 개선 (`d81c8e5`, `fae4cf3`, `a293451`, `127d69c`)

**버그 수정**
- 캘린더 지출 카드에 `paymentMethod` 미전달 수정 (`expense_by_date.dart`)
- 고정 지출 수정 폼에서 기존 분류/결제 수단이 표시되지 않던 문제 수정 (비동기 DB 조회 후 `setState`)
- `CategorySelect` / `PaymentMethodSelect`에 `didUpdateWidget` 추가 → 부모 `setState` 후 선택값 동기화

**UX 개선**
- 고정 지출 폼에서 분류/결제 수단 셀렉트 아이콘 제거 (`showIcon: false`)
- 지출 추가/수정 화면 분류/결제 수단 셀렉트 아이콘 제거
- 고정 지출 추가/수정/활성화/비활성화 시 토스트 안내
- 지출 수정 시 토스트 안내, 분류 추가/수정/삭제 시 토스트 안내
- 토스트 스타일 개선: `FToast` 커스텀 위젯 (어두운 반투명 배경, 아이콘, 라운드 코너, 그림자)
- 금액 입력란 3자리 구분자(,) 자동 삽입 (`ThousandsFormatter`)
- 고정 지출에서 자동 생성된 지출 카드에 반복 아이콘(↻) 표시

---

### 10. 플랜별 기능 한도 추가 (`d00e3ca`)

**변경 내용**
- Free 플랜: 활성 고정 지출 최대 10개, 결제 수단 최대 5개
- Cloud / Report 플랜: 둘 다 무제한
- 한도 초과 시 업그레이드 안내 다이얼로그 표시 → 구독 화면으로 이동
- 구독 화면 플랜 기능 목록에 새 항목 반영

**플랜 기능 목록 (현재)**

| 플랜 | 기능 |
|---|---|
| Free | 주 1회 백업, 일 1회 복원, 고정 지출 최대 10개, 결제 수단 최대 5개 |
| Cloud | 광고 제거, 무제한 백업/복원, 고정 지출 무제한, 결제 수단 무제한 |
| Report | Cloud 전체 + 통계/CSV/PDF |

---

### 11. 클라우드 복원 버그 3종 수정 (`2035344`)

**배경**
Android에서 백업 후 iOS에서 복원 시 지출 금액은 표시되나 항목이 보이지 않는 문제, 무결성 검증 실패 오류, `Cannot modify an unmodifiable list` 크래시 발생.

**버그 1: 날짜 복원 오류**
- 원인: Drift 기본 직렬화는 DateTime을 unix timestamp(int, ms)로 저장하는데 `_parseDateTime`이 int를 처리하지 못해 모든 날짜가 `DateTime.now()`로 덮어써짐
- 증상: `selectDayExpense`(범위 쿼리)에는 잡혀 합계는 표시되나 `watchExpense`(정확 일치)에는 안 잡혀 목록이 비어 보임
- 수정: `_parseDateTime` / `_parseDateTimeNullable`에 `int`/`double` → `DateTime.fromMillisecondsSinceEpoch()` 처리 추가

**버그 2: 해시 불일치 (무결성 검증 실패)**
- 원인: `SnapshotPayload.toJson()`에 `paymentMethods: []`, `recurringExpenses: []` 추가 후 해시 계산 결과가 기존 백업과 달라짐
- 수정: 빈 목록은 `toJson()`에서 생략 → 기존 백업과 해시 호환성 유지

**버그 3: 불변 리스트 `.sort()` 크래시**
- 원인: `_listOfMaps`가 키 없을 때 `const []`(불변 리스트)를 반환, 복원 코드의 `.sort()` 호출 시 `Cannot modify an unmodifiable list` 예외
- 수정: `const []` → `[]` (가변 빈 목록)

**관련 파일**
- `lib/features/backup/domain/snapshot.dart`
- `lib/features/backup/data/snapshot_service.dart`
- `lib/screen/snapshot_restore_screen.dart` (에러 메시지 개선)

---

### 12. 지출 통계 화면 개선 (`074c08b`)

**변경 내용**
- "Report 통계" → "지출 통계"로 이름 변경 (메뉴 + 화면 제목)
- 월별 요약 카드 항목 추가:
  - 총 지출 + 지출 건수 (나란히)
  - 일 평균 지출 (월 합계 ÷ 해당 월 일수)
  - 전월 대비 (증감 금액·%, 빨강/초록 색상)
  - 최대 지출일 (해당 월 하루 최대 지출일·금액)
- 결제 수단별 지출 카드 추가: 막대 비율 + 금액 + % 표시, 탭 시 상세 드로어
- 결제 수단 상세 드로어: 카드 스타일 항목 (분류 칩 + 날짜 아이콘 + 금액)
- `DraggableScrollableSheet` 기반 바텀 시트
- 스트림 구독 방식으로 상태 관리 (중첩 `StreamBuilder` 회피)

**신규 DB 쿼리**
- `countMonthExpenses(DateTime)` — 월별 지출 건수
- `watchMonthlyPaymentMethodExpense(DateTime)` — 결제 수단별 월간 집계
- `watchMonthExpensesByPaymentMethod(DateTime, int?)` — 특정 결제 수단의 지출 목록

**신규 모델**
- `lib/model/payment_method_expense.dart` — `PaymentMethodExpense(name, total, paymentMethodId)`

---

### 13. 고정 지출 삭제 기능 추가 (`7e1967e`)

**변경 내용**
- `deleteRecurringExpense(int id)` DB 메서드 추가 (완전 삭제)
- 고정 지출 목록 화면: 각 카드에 🗑️ 삭제 버튼 추가
- 고정 지출 수정 화면: 수정 모드일 때 저장 버튼 왼쪽에 삭제 버튼 표시 (추가 모드에서는 미표시)
- 삭제 시 확인 다이얼로그(빨간 버튼) → 완료 토스트
- 삭제 후 해당 규칙의 자동 생성 중단, 이미 생성된 지출 내역은 유지
- 버전 2.2.1+13으로 업데이트

**관련 파일**
- `lib/database/drift_database.dart`
- `lib/screen/recurring_expense_screen.dart`
- `lib/screen/recurring_expense_form_screen.dart`

---

### 14. iOS 심사 대응 — Apple 로그인 및 계정 삭제 플로우 추가

**배경**
App Store Review에서 다음 항목으로 리젝됨.
- Guideline 4.8: Google 로그인 등 서드파티 로그인 사용 시 동등한 `Sign in with Apple` 제공 필요
- Guideline 5.1.1(v): 계정 생성/로그인을 제공하는 앱은 앱 내 계정 삭제 기능 제공 필요

**변경 내용**
- iOS/macOS 로그인 화면에 `Apple로 로그인` 버튼 추가
- Firebase Auth `AppleAuthProvider` 기반 native Apple 로그인 사용
- Android/Web에는 Apple 로그인 버튼 미노출 (현재 iOS 심사 대응 범위)
- iOS `Runner.entitlements` 추가 및 Xcode project에 `Sign in with Apple` entitlement 연결
- 설정 화면 로그인 계정 카드 하단에 `계정 삭제` 메뉴 추가
- 계정 삭제 전 삭제 대상 안내를 먼저 표시하고, 사용자가 수락하면 최종 확인 후 삭제 진행
- 삭제 대상 안내:
  - 클라우드 계정
  - 클라우드 백업 데이터
  - 클라우드 거래 데이터
  - 백업 메타데이터
  - 로컬 SQLite 지출 데이터는 삭제되지 않음
- 실제 삭제 처리:
  - Firebase Authentication 현재 사용자 삭제
  - Firestore `users/{uid}/snapshots`, `users/{uid}/transactions`, `users/{uid}/meta`, `users/{uid}` 삭제
  - Firebase Storage `users/{uid}/snapshots/*` 삭제
- 최근 로그인 요구(`requires-recent-login`) 발생 시 다시 로그인 후 삭제하도록 사용자 문구 표시
- 계정 삭제 버튼 문구에서 `Firebase 계정` 대신 `클라우드 계정` 표현 사용

**외부 콘솔 설정 상태**
- Apple Developer App ID(`com.ysh.expenseDiary`)에 `Sign in with Apple` capability 활성화
- Xcode `Runner > Signing & Capabilities`에 `Sign in with Apple` 표시 확인
- Firebase Console Authentication Apple provider 활성화 확인

**심사 대응 시 남은 작업**
- App Review 요구사항에 맞춰 실제 기기에서 화면 녹화 완료:
  `앱 실행 → 설정 → 로그인/회원가입 → Apple로 로그인 → 설정 복귀 → 계정 삭제 → 삭제 안내 수락 → 최종 확인 → 삭제 완료`
- App Store Connect `App Review Information > Notes`에 녹화 파일 또는 링크 첨부
  - 권장 Notes 문구:
    `We added Sign in with Apple as an equivalent login option on iOS. Account deletion is available in Settings tab -> Account section -> Delete Account. The attached screen recording was captured on a physical device and demonstrates signing in with Apple, reviewing the data deletion notice, and completing the account deletion flow.`

**검증**
- `flutter analyze lib/auth/auth_repository.dart lib/screen/login_screen.dart lib/screen/config_screen.dart` 통과
- `flutter analyze lib/screen/config_screen.dart` 통과
- `plutil -lint ios/Runner/Runner.entitlements ios/Runner/Info.plist` 통과
- `assets/locales/ko.json`, `assets/locales/en.json` JSON 유효성 확인
- 실제 iOS 기기(`00008130-000170510EE3803A`, iOS 26.5)에서 release 모드 실행 및 Apple 로그인/계정 삭제 녹화 완료
- iOS 26.5 + Flutter 3.7.2 조합에서는 debug JIT 실행 크래시가 발생하므로 실기기 테스트/녹화는 `--release` 또는 `--profile` 사용 필요

**관련 파일**
- `lib/auth/auth_repository.dart`
- `lib/screen/login_screen.dart`
- `lib/screen/config_screen.dart`
- `ios/Runner/Runner.entitlements`
- `ios/Runner.xcodeproj/project.pbxproj`
- `assets/locales/ko.json`
- `assets/locales/en.json`

---

### 15. 분류 기본값 옵션 추가

**변경 내용**
- 분류 테이블에 선택형 기본값 컬럼 추가 (스키마 버전 3)
  - `usePresetAmount`
  - `presetAmount`
  - `autoFillExpenseName`
- 분류 추가/수정 다이얼로그에 체크박스 옵션 추가
  - 금액 설정: 체크 시 자동 입력할 금액 필수 입력
  - 자동 이름 채우기: 체크 시 지출명에 분류명 자동 입력
- 분류 목록에서 설정된 옵션을 칩 형태로 표시
- 지출 추가/수정 화면에서 분류 선택 시 옵션에 따라 지출명/금액 자동 입력
- `LabelField`에 외부 `TextEditingController` 지원 추가
- 백업/복원 시 새 분류 필드 포함 및 이전 백업 하위 호환 유지

**검증**
- `dart run build_runner build --delete-conflicting-outputs`로 Drift generated code 갱신
- 수정 범위 analyzer 통과:
  `flutter analyze lib/model/category.dart lib/database/drift_database.dart lib/component/category_select.dart lib/component/label_field.dart lib/screen/category_screen.dart lib/screen/add_screen.dart lib/screen/detail_screen.dart lib/features/backup/data/snapshot_service.dart`
- 전체 `flutter analyze`는 기존 `third_party/google_mobile_ads/test`의 mockito 의존성/생성 mock 오류로 실패함. 이번 수정 범위에서는 오류 없음.

**관련 파일**
- `lib/model/category.dart`
- `lib/database/drift_database.dart`
- `lib/database/drift_database.g.dart`
- `lib/screen/category_screen.dart`
- `lib/screen/add_screen.dart`
- `lib/screen/detail_screen.dart`
- `lib/component/category_select.dart`
- `lib/component/label_field.dart`
- `lib/features/backup/data/snapshot_service.dart`
- `assets/locales/ko.json`
- `assets/locales/en.json`

---

### 16. 스냅샷 목록/삭제/보관 정책 개선

**변경 내용**
- 스냅샷은 사용자별 최신 5개까지만 보관하도록 변경
- 새 백업 업로드 후 스냅샷이 5개를 초과하면 가장 오래된 스냅샷부터 삭제
- 스냅샷 삭제 시 Firestore metadata와 Firebase Storage payload를 함께 삭제
- 스냅샷 복원 화면에서 표시 목록을 최대 5개로 제한
- 스냅샷 복원 화면에 선택 삭제와 전체 삭제 기능 추가
- 백업 시 스냅샷 이름을 입력할 수 있도록 변경
- 스냅샷 이름을 입력하지 않으면 로컬 날짜/시간(`yyyy.MM.dd HH:mm`)으로 기본 이름 저장
- 스냅샷 이름 입력 다이얼로그의 `TextEditingController` 생명주기를 별도 StatefulWidget 내부로 이동해 닫힘 애니메이션 중 dispose된 controller를 참조하던 오류 수정
- 스냅샷 카드 UI 개선
  - 사용자에게 필요한 스냅샷 이름, 백업 시간, 앱 버전, 크기, 스냅샷 ID만 표시
  - 내부용 schema/hash 정보는 화면에서 제거

**검증**
- 수정 범위 analyzer 통과:
  `flutter analyze lib/features/backup/data/firebase_snapshot_repository.dart lib/features/backup/data/snapshot_service.dart lib/screen/snapshot_restore_screen.dart`
- 스냅샷 이름 변경 범위 analyzer 통과:
  `flutter analyze lib/features/backup/domain/snapshot.dart lib/features/backup/data/snapshot_service.dart lib/features/backup/data/firebase_snapshot_repository.dart lib/screen/config_screen.dart lib/screen/snapshot_restore_screen.dart test/features/backup/domain/snapshot_test.dart`
- `flutter test test/features/backup/domain/snapshot_test.dart` 통과
- `flutter analyze lib/screen/config_screen.dart` 통과
- Firestore 규칙은 `users/{uid}/...`에 본인 `read, write` 허용 상태라 Firestore 스냅샷 삭제 가능
- Storage rules 파일은 repo에 추적되어 있지 않음. 실제 Storage payload 삭제 권한은 Firebase Console Storage Rules 확인 필요

**관련 파일**
- `lib/features/backup/domain/snapshot.dart`
- `lib/features/backup/data/firebase_snapshot_repository.dart`
- `lib/features/backup/data/snapshot_service.dart`
- `lib/screen/config_screen.dart`
- `lib/screen/snapshot_restore_screen.dart`
- `test/features/backup/domain/snapshot_test.dart`
- `AGENTS.md`

---

### 17. 지출 탭 날짜 선택 및 슬라이드 전환

**변경 내용**
- 지출 탭을 선택 날짜 기반 화면으로 변경
- 상단 제목/날짜 행 우측에 날짜 선택 버튼과 오늘 버튼 추가
- 날짜 선택 버튼 클릭 시 `showDatePicker`로 날짜 선택 가능
- 오늘 버튼 클릭 시 현재 로컬 날짜로 복귀
- 선택 날짜가 오늘이면 기존처럼 `오늘 지출`, `오늘 합계` 표시
- 선택 날짜가 오늘이 아니면 `{yyyy.MM.dd} 지출`, `{yyyy.MM.dd} 합계` 표시
- 좌우 스와이프 시 선택 날짜를 하루씩 이동
- 날짜 변경 시 제목, 날짜, 합계 카드, 지출 목록이 슬라이드/페이드 애니메이션으로 전환
- 상단 날짜 액션 버튼을 pill 스타일로 개선
  - 달력 버튼은 primary 강조
  - 오늘 버튼은 보조 스타일이며 오늘 날짜에서는 비활성 표시
- 지출 탭에서 지출 추가 화면을 열 때 현재 선택 날짜를 기본 지출 날짜로 전달

**검증**
- `flutter analyze lib/screen/home_screen.dart lib/screen/add_screen.dart` 통과
- `flutter analyze lib/screen/home_screen.dart` 통과
- `assets/locales/ko.json`, `assets/locales/en.json` JSON 유효성 확인
- `git diff --check` 통과

**관련 파일**
- `lib/screen/home_screen.dart`
- `lib/screen/add_screen.dart`
- `assets/locales/ko.json`
- `assets/locales/en.json`
- `AGENTS.md`

---

### 18. 계정별 수동 권한 시스템 추가

**변경 내용**
- Firestore `userEntitlements/{uid}` 문서를 통해 계정별 수동 권한을 부여할 수 있도록 변경
- 권한 문서가 없으면 기본 role은 `normal`로 처리
- 지원 필드
  - `role`: `normal`, `cloud`, `report`, `special`, `admin`
  - `manualCloud`
  - `manualReport`
  - `manualAdsRemoved`
  - 호환 alias: `cloud`, `report`, `adsRemoved`
- 최종 권한은 RevenueCat 구독 권한과 Firestore 수동 권한을 OR로 합산
- `report`, `special`, `admin` role은 Cloud 권한 포함
- `special`, `admin` role은 Report 포함 전체 유료 기능 사용 가능
- iOS는 RevenueCat 구독 UI가 비활성화되어 있어도 Firebase 수동 권한으로 유료 기능 사용 가능
- 로그아웃 시 수동 권한은 `normal`/false로 초기화
- Firestore Rules에 `userEntitlements/{uid}` read-only 규칙 추가
  - 본인 문서 read 허용
  - 클라이언트 write 전체 차단
- `userEntitlements/{uid}` 규칙을 Firebase 프로젝트 `expense-diary-4892a`에 배포 완료
- Firestore Rules 의미와 CLI/Console 수동 적용 방법을 문서화

**운영 예시**
```text
userEntitlements/{uid}
  role: "normal"
  manualCloud: true
  manualReport: false
  manualAdsRemoved: true
```

**검증**
- `flutter analyze lib/core/subscription/subscription_service.dart lib/main.dart` 통과
- `git diff --check` 통과
- `./scripts/firebase_deploy_firestore_rules.sh expense-diary-4892a` 배포 완료

**관련 파일**
- `lib/core/subscription/subscription_service.dart`
- `firestore.rules`
- `docs/auth/account_entitlements.md`
- `docs/auth/firestore_entitlement_rules.md`
- `AGENTS.md`

---

### 19. 지출 추가/수정 셀렉트 즉시 추가

**변경 내용**
- 지출 추가/수정 화면의 분류 셀렉트에 즉시 추가 버튼 추가
- 분류 즉시 추가 시 분류명, 기본 금액 설정, 자동 이름 채우기 옵션 입력 가능
- 새로 생성한 분류는 즉시 선택 상태로 반영
- 지출 추가/수정 화면의 결제 수단 셀렉트에 즉시 추가 버튼 추가
- 결제 수단 즉시 추가 시 유형, 이름, 메모 입력 가능
- 새로 생성한 결제 수단은 즉시 선택 상태로 반영
- 결제 수단 즉시 추가에서도 기존 무료 플랜 한도 5개를 동일하게 확인
- Cloud/Report 권한이 있으면 결제 수단 개수 제한 없이 즉시 추가 가능

**검증**
- `flutter analyze lib/component/category_select.dart lib/component/payment_method_select.dart lib/screen/add_screen.dart lib/screen/detail_screen.dart` 통과
- `assets/locales/ko.json`, `assets/locales/en.json` JSON 유효성 확인
- `git diff --check` 통과

**관련 파일**
- `lib/component/category_select.dart`
- `lib/component/payment_method_select.dart`
- `assets/locales/ko.json`
- `assets/locales/en.json`
- `AGENTS.md`

---

### 20. 분류 삭제 시 관련 지출 미분류 처리

**변경 내용**
- 관련 지출이 있는 분류도 삭제할 수 있도록 변경
- 삭제 전 관련 지출 개수를 안내하고, 삭제 시 해당 지출들이 `미분류`로 변경된다는 확인 다이얼로그 표시
- 확인 시 transaction 안에서 관련 지출의 `categoryId`를 `null`로 변경한 뒤 분류 삭제
- 지출 데이터는 삭제하지 않음
- 관련 지출이 없는 분류는 일반 삭제 확인 후 삭제

**검증**
- `flutter analyze lib/database/drift_database.dart lib/screen/category_screen.dart` 통과
- `assets/locales/ko.json`, `assets/locales/en.json` JSON 유효성 확인

**관련 파일**
- `lib/database/drift_database.dart`
- `lib/screen/category_screen.dart`
- `assets/locales/ko.json`
- `assets/locales/en.json`
- `AGENTS.md`

---

### 21. 결제 수단 중복/복원 정책 개선

**변경 내용**
- 결제 수단 삭제는 기존처럼 `isArchived=true`로 보관
- 같은 유형과 이름의 활성 결제 수단이 이미 있으면 신규 추가 차단
- 결제 수단 수정 시에도 다른 활성 결제 수단과 같은 유형/이름으로 저장하는 것을 차단
- 같은 유형과 이름의 삭제된 결제 수단이 있으면 복원 여부 확인 다이얼로그 표시
- 복원 시 새 결제 수단 ID를 만들지 않고 기존 ID를 재사용
- 복원된 결제 수단은 현재 목록 마지막 순서로 다시 표시
- 복원 시 입력한 메모로 갱신하고 `isArchived=false`로 변경
- 과거 지출 내역은 기존 결제 수단 ID를 유지하므로 다시 같은 결제 수단으로 연결됨
- 결제 수단별 통계도 과거/현재 지출이 같은 결제 수단으로 합산됨
- 설정의 결제 수단 관리 화면과 지출 추가/수정 화면의 즉시 추가 다이얼로그에 동일하게 적용
- 무료 플랜의 활성 결제 수단 5개 제한은 유지
- 삭제된 결제 수단을 참조하는 과거 지출/고정지출을 열 때 드롭다운 assertion이 발생하지 않도록 `PaymentMethodSelect`가 archived selected value를 현재 선택 항목으로 표시
- 삭제된 결제 수단은 셀렉트 박스에서 `{이름} (삭제됨)`으로 표시

**검증**
- `flutter analyze lib/database/drift_database.dart lib/screen/payment_method_screen.dart lib/component/payment_method_select.dart` 통과
- `assets/locales/ko.json`, `assets/locales/en.json` JSON 유효성 확인
- `git diff --check` 통과

**관련 파일**
- `lib/database/drift_database.dart`
- `lib/screen/payment_method_screen.dart`
- `lib/component/payment_method_select.dart`
- `assets/locales/ko.json`
- `assets/locales/en.json`
- `AGENTS.md`

---

### 22. 지출 탭 날짜별 목록/합계 불일치 수정

**문제**
- 지출 탭에서 특정 날짜의 목록은 3건만 보이는데 합계가 더 크게 표시되는 문제가 발생
- 원인은 목록 조회가 `expenseDate == selectedDate` 정확 일치 조건을 사용하고, 합계 조회는 하루 범위 조건을 사용했기 때문
- 복원/마이그레이션/기타 경로로 저장된 지출 날짜에 00:00:00이 아닌 시간값이 포함되면 목록에서는 누락되고 합계에는 포함될 수 있었음

**변경 내용**
- `watchExpense(selectedDate)`를 정확 일치 조회에서 날짜 범위 조회로 변경
- 일별 목록과 일별 합계가 모두 `start <= expenseDate < nextDay` 기준을 사용하도록 정렬
- 자정 경계값이 다음 날짜에 중복 포함되지 않도록 `isBetweenValues` 대신 half-open range 사용
- 지출 목록 정렬 기준을 `expenseDate ASC`, `id ASC`로 명시

**검증**
- `flutter analyze lib/database/drift_database.dart lib/screen/home_screen.dart lib/component/expense_by_date.dart` 통과
- `git diff --check` 통과

**관련 파일**
- `lib/database/drift_database.dart`
- `AGENTS.md`

---

## 문서

| 파일 | 내용 |
|---|---|
| `docs/revenue_cat/console_setup.md` | RevenueCat 콘솔 초기 설정 |
| `docs/revenue_cat/code_integration.md` | RevenueCat 코드 통합 및 무료 제한 로직 |
| `docs/revenue_cat/android_setup.md` | Android Play Store 연동 상세 |
| `docs/revenue_cat/ios_setup.md` | iOS App Store 연동 절차 (사업자 등록 후 진행) |
| `docs/deployment/android.md` | Android 배포 절차 및 빌드 명령어 |
| `docs/deployment/ios.md` | iOS 배포 절차 및 트러블슈팅 |
| `docs/Structure/local_data_storage.md` | 로컬 데이터 저장 구조 |
| `docs/Structure/cloud_storage.md` | 클라우드 저장 구조 (Firestore + Storage) |
