# Current State Audit (T0-1)

기준일: 2026-02-23  
대상 프로젝트: `expense_diary` (Flutter)

이 문서는 이후 티켓에서 수정 지점을 빠르게 특정하기 위한 "현재 구조/연동 상태" 기준 문서입니다.

## 1) `lib/` 구조 요약 + 레이어 분류

### 폴더 트리 (요약)

```text
lib/
  main.dart
  firebase_options.dart
  auth/
    auth_repository.dart
  data/
    firestore/
      firestore_transaction_repository.dart
      transaction_dto.dart
  database/
    drift_database.dart
    drift_database.g.dart (generated)
  model/
    expense.dart
    category.dart
    category_expense.dart
  screen/
    root_screen.dart
    home_screen.dart
    calendar_screen.dart
    category_screen.dart
    config_screen.dart
    add_screen.dart
    detail_screen.dart
    login_screen.dart
    signup_screen.dart
    cloud_transaction_screen.dart
  component/
    banner_ad_widget.dart
    expense_card.dart
    expense_by_*.dart
    category_select.dart
    calendar/expense_calendar.dart
    common/*
  service/
    app_settings.dart
  const/
    app_theme.dart
    app_colors.dart
    currency_utils.dart
    firebase_auth_config.dart
```

### 레이어 분류 (실제 코드 기준)

- `presentation/ui`: `lib/screen/*`, `lib/component/*`
- `data/local (SQLite/Drift)`: `lib/database/*`, `lib/model/*`
- `data/remote (Firebase Firestore)`: `lib/data/firestore/*`
- `auth (Firebase Auth + Google Sign-In)`: `lib/auth/auth_repository.dart`
- `app bootstrap / DI`: `lib/main.dart` (`GetIt` 등록)
- `app config / constants`: `lib/const/*`, `lib/service/app_settings.dart`, `lib/firebase_options.dart`

### 아키텍처 특징 (중요)

- 로컬 DB는 `Repository` 레이어 없이 UI가 `GetIt.I<LocalDatabase>()`로 직접 접근합니다.
- 상태관리 프레임워크(Provider/BLoC/Riverpod) 대신 `GetIt + StreamBuilder + StatefulWidget` 중심입니다.
- Firebase 쪽은 `AuthRepository`, `FirestoreTransactionRepository`로 일부 repository abstraction이 존재합니다.

## 2) Firebase 초기화 위치

### 초기화 호출 여부

- `Firebase.initializeApp()` 호출 있음
  - 위치: `lib/main.dart:20`
  - 옵션: `DefaultFirebaseOptions.currentPlatform` (`lib/firebase_options.dart`)

### 관련 부트스트랩

- `MobileAds.instance.initialize()` 호출 있음: `lib/main.dart:24`
- DI 등록 (`GetIt`)
  - `LocalDatabase`: `lib/main.dart:36`
  - `AuthRepository`: `lib/main.dart:40`
  - `FirestoreTransactionRepository`: `lib/main.dart:41`

## 3) Firebase Auth 구현 위치 / 플로우

### 핵심 구현 파일

- 인증 저장소: `lib/auth/auth_repository.dart` (`AuthRepository`)
- 로그인 UI: `lib/screen/login_screen.dart` (`LoginScreen`)
- 회원가입 UI: `lib/screen/signup_screen.dart` (`SignupScreen`)
- 인증 상태 소비/진입점: `lib/screen/config_screen.dart` (`ConfigScreen`)
- Google Sign-In 설정값: `lib/const/firebase_auth_config.dart` (`FirebaseAuthConfig.googleServerClientId`)

### Email/Password 로그인/회원가입

- 회원가입: `AuthRepository.signUp(...)`
  - 구현: `lib/auth/auth_repository.dart:23`
  - 호출 UI: `lib/screen/signup_screen.dart:45`
- 로그인: `AuthRepository.signIn(...)`
  - 구현: `lib/auth/auth_repository.dart:30`
  - 호출 UI: `lib/screen/login_screen.dart:179`

### Google 로그인

- 구현 메서드: `AuthRepository.signInWithGoogle()` (`lib/auth/auth_repository.dart:44`)
- 동작:
  - `GoogleSignIn.instance.initialize(...)`
  - `GoogleSignIn.instance.authenticate()`
  - `GoogleAuthProvider.credential(idToken: ...)`
  - `FirebaseAuth.signInWithCredential(...)`
- 호출 UI: `lib/screen/login_screen.dart:204`
- 취소 처리:
  - `AuthCancelledException` (`lib/auth/auth_repository.dart:4`)
  - `LoginScreen`에서 취소 시 에러 UI 미표시

### 현재 유저 상태 노출 방식

- 방식: `FirebaseAuth.authStateChanges()` 기반 `Stream<User?>`
- 노출 지점: `AuthRepository.authStateChanges` getter (`lib/auth/auth_repository.dart:19`)
- 소비 방식: `ConfigScreen`의 `StreamBuilder<User?>`
  - 로그인/로그아웃 타일: `lib/screen/config_screen.dart:229`
  - Cloud Transaction 진입 타일 활성/비활성: `lib/screen/config_screen.dart:272`

## 4) Firebase DB 테스트 로직 (Firestore) 확인

### 사용 여부 (Firestore / RTDB / Storage)

- Firestore 사용: `cloud_firestore` 패키지 + 구현 코드 존재
  - `pubspec.yaml:56`
  - `lib/data/firestore/firestore_transaction_repository.dart`
- Realtime Database 사용 흔적 없음 (`firebase_database` 패키지/코드 없음)
- Firebase Storage 사용 흔적 없음 (`firebase_storage` 패키지/코드 없음)

### 테스트/검증용 UI 로직 위치

- 화면: `lib/screen/cloud_transaction_screen.dart` (`CloudTransactionScreen`)
- 진입 조건:
  - `ConfigScreen`에서 로그인 사용자만 버튼 활성화
  - 진입 호출: `lib/screen/config_screen.dart:299`

### Firestore 컬렉션/문서 경로

- 저장소: `FirestoreTransactionRepository` (`lib/data/firestore/firestore_transaction_repository.dart:6`)
- 경로 구성:
  - `users/{uid}/transactions/{txId}`
  - 코드 위치: `lib/data/firestore/firestore_transaction_repository.dart:28-30`

### CRUD 구현 상태 (코드 기준)

- Create/Update: `createOrUpdate(TransactionDto)` (`lib/data/firestore/firestore_transaction_repository.dart:32`)
- Delete: `delete(String txId)` (`lib/data/firestore/firestore_transaction_repository.dart:63`)
- Read (1회 조회): `listByMonth(String yyyyMM)` (`lib/data/firestore/firestore_transaction_repository.dart:67`)
- Read (실시간 스트림): `watchByMonth(String yyyyMM)` (`lib/data/firestore/firestore_transaction_repository.dart:78`)
- UI 실시간 렌더링:
  - `StreamBuilder<List<TransactionDto>>` + `_repo.watchByMonth(_yyyyMM)`
  - `lib/screen/cloud_transaction_screen.dart:327-328`

### 테스트 문서/관련 문서

- Firebase 설정 문서: `docs/FIREBASE_SETUP.md`
- Firebase 트러블슈팅 문서: `docs/FIREBASE_TROUBLESHOOTING.md`
- Firestore rules 관련 경로 가이드(`/users/{uid}/...`) 언급 있음:
  - `docs/FIREBASE_SETUP.md:186`
  - `docs/FIREBASE_TROUBLESHOOTING.md:170`

### 실제 동작 여부 (이번 감사 범위)

- 코드상 CRUD 구현 및 UI 테스트 화면은 존재합니다.
- 이번 작업에서는 앱 실행/실기기 인증/Firestore write-read 런타임 검증은 수행하지 않았습니다.
- 따라서 상태 표기는 `구현 존재 (런타임 미검증)`입니다.

## 5) SQLite 로컬 DB 사용 방식 확인

### 사용 패키지

- `drift`, `drift_flutter`, `drift_dev` 사용
  - `pubspec.yaml:42-43`
  - `pubspec.yaml:73`
- `sqflite`, `floor` 사용 없음

### 핵심 구현 구조

- DB 클래스: `LocalDatabase` (`lib/database/drift_database.dart:14`)
- Drift 선언: `@DriftDatabase(tables: [Expenses, Category])` (`lib/database/drift_database.dart:13`)
- Generated 파일: `lib/database/drift_database.g.dart` (수정 금지)
- DB 파일 위치:
  - 앱 문서 디렉터리의 `db.sqlite`
  - `_openConnection()` 구현: `lib/database/drift_database.dart` 하단

### Entity / DAO / Repository 구성 추정

- Entity(Table 정의)
  - `Expenses` 테이블: `lib/model/expense.dart:4`
  - `Category` 테이블: `lib/model/category.dart:3`
- DTO/ViewModel 성격 모델
  - `CategoryExpense`: `lib/model/category_expense.dart:1`
- DAO/Query 메서드
  - `LocalDatabase` 내부에 직접 구현 (`watchExpense`, `createExpense`, `watchCategory` 등)
- Repository 레이어
  - 로컬 DB 기준 별도 `Repository` 없음 (UI가 `LocalDatabase` 직접 호출)

### 테이블 구조 요약 (코드 기준)

#### `Expenses` (`lib/model/expense.dart`)

- `id` (PK, autoIncrement)
- `categoryId` (nullable, FK -> `Category.id`)
- `expenseName` (text)
- `expense` (int)
- `expenseDate` (DateTime)
- `expenseDetail` (nullable text)

#### `Category` (`lib/model/category.dart`)

- `id` (PK, autoIncrement)
- `categoryName` (text)
- unique key: `categoryName` (`uniqueKeys`)

### 주요 쿼리/동작 메서드 (LocalDatabase)

- 일자별 지출 목록 스트림: `watchExpense(...)` (`lib/database/drift_database.dart:18`)
- 일자/월/주 합계 스트림:
  - `selectDayExpense(...)` (`lib/database/drift_database.dart:32`)
  - `selectMonthExpense(...)` (`lib/database/drift_database.dart:48`)
  - `selectWeekExpense(...)` (`lib/database/drift_database.dart:84`)
- 월간 일별 합계 맵 스트림: `watchDailyExpenseTotals(...)` (`lib/database/drift_database.dart:60`)
- 월간 카테고리별 합계 스트림: `watchMonthlyCategoryExpense(...)` (`lib/database/drift_database.dart:94`)
- 지출 CRUD:
  - `createExpense(...)` (`lib/database/drift_database.dart:118`)
  - `updateExpense(...)` (`lib/database/drift_database.dart:121`)
  - `removeExpense(...)` (`lib/database/drift_database.dart:132`)
- 카테고리 CRUD/검증:
  - `addCategory(...)` (`lib/database/drift_database.dart:136`)
  - `watchCategory(...)` (`lib/database/drift_database.dart:139`)
  - `updateCategory(...)` (`lib/database/drift_database.dart:148`)
  - `deleteCategory(...)` (`lib/database/drift_database.dart:152`)
  - `countExpensesByCategory(...)` (`lib/database/drift_database.dart:155`)
- 전체 초기화(트랜잭션): `deleteAllData()` (`lib/database/drift_database.dart:166`)

### UI의 로컬 DB 사용 방식 (예시)

- `HomeScreen`에서 `StreamBuilder`로 직접 구독
  - `selectDayExpense(...)`, `watchExpense(...)`
  - 파일: `lib/screen/home_screen.dart`
- `CategoryScreen`에서 `watchCategory(...)` 직접 구독
  - 파일: `lib/screen/category_screen.dart`
- `ConfigScreen`에서 `deleteAllData()` 호출(초기화)
  - 파일: `lib/screen/config_screen.dart`

## 6) 광고 구현 여부 확인

### SDK/패키지

- AdMob (`google_mobile_ads`) 사용
  - `pubspec.yaml:52-53` (로컬 패키지 경로 `third_party/google_mobile_ads`)
- SDK 초기화
  - `MobileAds.instance.initialize()` in `lib/main.dart:24`

### 광고 위젯 구현

- 광고 위젯: `lib/component/banner_ad_widget.dart` (`BannerAdWidget`)
- 내부 구현:
  - `BannerAd` 생성/로드: `lib/component/banner_ad_widget.dart:30`
  - `AdWidget(ad: banner)` 렌더링: `lib/component/banner_ad_widget.dart:66`

### 광고 표시 위치 (현재 확인됨)

- 홈 화면 상단: `lib/screen/home_screen.dart:29`
- 카테고리 화면 하단: `lib/screen/category_screen.dart:127`
- 설정 화면 하단: `lib/screen/config_screen.dart:312`

### 광고 로드/표시 구조 평가

- 현재 구조는 각 화면이 `BannerAdWidget()`를 직접 배치하는 방식입니다.
- 구독 기반 광고 숨김 레이어는 제거되었습니다.
- 전역 광고 on/off가 필요하면 `BannerAdWidget` 자체에서 조건부 렌더링을 추가하는 방식이 가장 단순합니다.

## 7) 후속 티켓을 위한 구조적 메모

- 로컬 DB 접근이 UI에 직접 퍼져 있으므로, 데이터 정책이 늘어나면 `Repository` 또는 `UseCase` 계층 도입 검토 가치가 큽니다.
- Firestore는 현재 `users/{uid}/transactions` 및 백업 스냅샷 경로를 사용합니다. 결제/구독 메타데이터 경로는 사용하지 않습니다.
