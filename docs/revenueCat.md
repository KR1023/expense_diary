# RevenueCat 설정 및 Flutter 연동 가이드 (ExpenseDiary)

이 문서는 현재 프로젝트(`expense_diary`) 기준으로 RevenueCat 구독 연동을 설정하는 방법을 정리한 운영 문서입니다.

대상 범위:
- RevenueCat 대시보드 설정 방법 (Entitlements / Products / Offerings / 앱 연결)
- Flutter 앱 연동 방법 (SDK, API 키, 어느 파일에서 읽는지)
- Google Play Console / Apple App Store Connect에서 필요한 설정
- 테스트/검증/운영 시 추가로 해야 할 것

관련 문서:
- `docs/how_to_test.md` (구독 테스트 절차)
- `docs/play_store_seller.md` (Play 판매자 프로필 / Base plan / 실제 Play 테스트 준비)

## 1. 현재 프로젝트의 RevenueCat 연동 구조 (코드 기준)

이 프로젝트는 RevenueCat을 다음 구조로 사용합니다.

- SDK 연동 패키지: `purchases_flutter`
- Paywall UI: RevenueCat 기본 UI 미사용, 프로젝트 커스텀 Paywall 사용 (`lib/screen/paywall_screen.dart`)
- 구독 상태 전역 관리: `SubscriptionService` (`lib/core/subscription/subscription_service.dart`)
- Firebase Auth 로그인/로그아웃과 RevenueCat 사용자 동기화:
  - `lib/auth/auth_repository.dart`
- 앱 시작 시 초기화/등록:
  - `lib/main.dart`

### 플랜 매핑 규칙 (중요)

`SubscriptionService`에서 RevenueCat Entitlement 활성 상태를 `PlanType`으로 매핑합니다.

- `report` entitlement 활성 -> `PlanType.report`
- 아니고 `cloud` entitlement 활성 -> `PlanType.cloud`
- 둘 다 아니면 -> `PlanType.free`

즉, RevenueCat 대시보드의 Entitlement ID 이름이 코드와 맞아야 합니다.

권장/기본값:
- `cloud`
- `report`

## 2. RevenueCat 대시보드 설정 방법

## 2-0. Store 선택 기준 (Test Store vs 실제 스토어)

결론:
- 초기 개발/연동 확인 단계에서는 `Test Store`를 먼저 선택해도 됩니다.
- 실제 결제/복원 검증 및 출시 준비 단계에서는 반드시 `Google Play` / `Apple App Store`를 연결해야 합니다.

`Test Store`를 먼저 써도 되는 경우:
- RevenueCat SDK 연결 확인
- Entitlement / Offering / Product 구조 검증
- 커스텀 Paywall UI 표시 확인
- 구매/복원 버튼 코드 흐름 확인
- `SubscriptionService`의 entitlement -> plan 매핑 확인

`Test Store`만으로는 부족한 경우:
- 실제 Play 결제 테스트
- 실제 App Store Sandbox 결제 테스트
- 스토어 영수증/갱신/취소 반영 검증
- 출시 전 최종 QA

권장 순서:
1. `Test Store`로 구조/연동/Paywall 확인
2. `Apps & providers`에서 Android/iOS 앱 추가
3. Play Console / App Store Connect 상품 생성 및 연결
4. 플랫폼별 Public SDK key로 재검증
5. 실제 스토어 테스트 계정으로 구매/복원 검증

## 2-1. 꼭 맞춰야 하는 이름 (이 프로젝트 기준)

프로젝트 코드 기본값은 아래 이름을 기대합니다.

- Entitlement IDs
  - `cloud`
  - `report`
- Offering IDs
  - `cloud`
  - `report`

다른 이름을 써도 되지만, 그 경우 앱 실행 시 `--dart-define`로 별도 지정해야 합니다.

## 2-2. Product catalog에서 설정할 것

RevenueCat 최신 UI에서는 `Entitlements`, `Products`, `Offerings`가 좌측 사이드바가 아니라 `Product catalog` 내부 탭에 있습니다.

경로:
- `Product catalog` -> `Entitlements`
- `Product catalog` -> `Products`
- `Product catalog` -> `Offerings`

참고:
- `Overview` 화면의 온보딩 카드(`Integrate the SDK`, `Create your first paywall`)를 먼저 완료하지 않아도 됩니다.
- 현재 프로젝트는 RevenueCat Paywall Builder가 아니라 커스텀 Paywall(`lib/screen/paywall_screen.dart`)을 사용합니다.

## 2-3. Entitlements 생성

`Product catalog > Entitlements` 에서 아래 2개를 생성합니다.

- `cloud`
- `report`

주의:
- `cloud, report`처럼 한 개 entitlement 이름으로 만들면 안 됩니다.
- 반드시 `cloud`, `report` 두 개를 각각 따로 생성해야 합니다.

## 2-4. Products(구독 상품) 생성

`Product catalog > Products` 에서 구독 상품을 생성합니다.

최소 구성(권장):
- `cloud_monthly` (Auto-renewing subscription / Monthly)
- `report_monthly` (Auto-renewing subscription / Monthly)

예시 입력값:
- Identifier: `cloud_monthly`
- Customer-facing name: `Cloud`
- Product type: `Auto-renewing subscription`
- Duration: `Monthly`

그리고 동일 방식으로:
- Identifier: `report_monthly`
- Customer-facing name: `Report`

선택 확장(후속):
- `cloud_yearly`
- `report_yearly`

초기 구현/검증 단계는 월간 상품 2개만으로도 충분합니다.

중요:
- `Identifier`는 나중에 Play Console / App Store Connect의 상품 ID와 동일해야 합니다.
- 이미 스토어에서 만든 상품이 있다면 그 ID를 그대로 사용하세요.

### 2-4-1. RevenueCat `Play Store > New Product` 화면 입력 방법 (현재 UI 기준)

RevenueCat UI에서 `ExpenseDiary (Play Store) > + New`를 눌렀을 때 보이는 입력 필드는,
Google Play Console에 이미 만들어 둔 `구독 상품 ID(Subscription ID)`와 `Base plan ID`를 그대로 넣는 구조입니다.

가장 쉬운 방법(권장):
- 가능하면 `Import Products`를 먼저 사용하세요.
- RevenueCat가 Play Console 상품/베이스플랜을 자동으로 가져오므로 수동 입력 실수를 줄일 수 있습니다.

수동 입력 시 필드 의미:
- `Display name`
  - RevenueCat 대시보드에서 보이는 관리용 이름입니다.
  - 예시: `cloud_monthly`, `report_monthly` 또는 `Cloud Monthly`, `Report Monthly`
- `Product type`
  - 구독이면 `Subscription` 선택
- `Subscription`
  - **Google Play Console의 구독 상품 ID(Subscription ID)와 정확히 동일**해야 합니다.
  - 예시: `cloud_monthly` / `report_monthly`
  - 주의: `Cloud` 같은 표시용 이름이 아니라 **ID 값**을 넣어야 합니다.
- `Base plan ID`
  - **Google Play Console의 Base plan ID와 정확히 동일**해야 합니다.
  - 예시: `monthly`, `p1m` (프로젝트에서 실제로 만든 값 사용)
  - 비어 있다면 Play Console에서 해당 구독의 Base plan을 먼저 만들어야 합니다.
- `Backwards compatible`
  - 일반적으로 기본값(체크 유지)로 시작해도 됩니다.
  - 특수한 마이그레이션 정책이 없다면 기본 설정으로 두고 테스트 후 조정합니다.
- `RevenueCat product identifier`
  - 자동 생성값을 보통 그대로 사용하면 됩니다. (관리용)

예시 (Cloud 월간):
- `Display name`: `cloud_monthly`
- `Product type`: `Subscription`
- `Subscription`: `cloud_monthly`
- `Base plan ID`: `monthly` (또는 Play Console에서 만든 실제 값)

예시 (Report 월간):
- `Display name`: `report_monthly`
- `Product type`: `Subscription`
- `Subscription`: `report_monthly`
- `Base plan ID`: `monthly` (또는 Play Console에서 만든 실제 값)

중요:
- RevenueCat의 Play Store Product 입력값은 **Play Console의 ID 값과 1글자라도 다르면 안 됩니다**.
- 대소문자/언더스코어(`_`)까지 동일해야 합니다.
- 먼저 Play Console에서 구독 + Base plan을 만든 뒤 RevenueCat에 `Import`하는 순서를 가장 권장합니다.

### 2-4-2. RevenueCat `App Store > New Product` 화면 입력 방법 (현재 UI 기준)

RevenueCat UI에서 `ExpenseDiary (App Store) > + New`를 눌렀을 때 보이는 입력 필드는,
Apple App Store Connect에 이미 만들어 둔 구독 상품 정보를 기준으로 맞춰야 합니다.

가장 쉬운 방법(권장):
- 가능하면 `Import Products`를 먼저 사용하세요.
- RevenueCat가 App Store Connect 상품을 자동으로 가져오므로 수동 입력 실수를 줄일 수 있습니다.

Play Store와 다른 점(중요):
- Apple은 Google Play의 `Base plan ID` 개념이 없습니다.
- 대신 보통 `Subscription Group` + 각 구독 상품(Product ID, 기간) 조합으로 관리합니다.

수동 입력 시 필드 의미(필드명은 UI 버전에 따라 약간 다를 수 있음):
- `Display name`
  - RevenueCat 대시보드에서 보이는 관리용 이름입니다.
  - 예시: `cloud_monthly`, `report_monthly` 또는 `Cloud Monthly`
- `Product type`
  - 구독이면 `Subscription` 선택
- `Product ID` / `Subscription` / `Identifier` (UI 버전별 이름 차이)
  - **App Store Connect의 Product ID와 정확히 동일**해야 합니다.
  - 예시: `cloud_monthly` / `report_monthly`
  - 주의: `Cloud` 같은 표시용 이름이 아니라 **Product ID 값**을 넣어야 합니다.
- `Duration` / `Subscription duration` (표시되는 경우)
  - App Store Connect에서 만든 구독 기간과 동일하게 선택
  - 예시: `Monthly`
- `Subscription group` (표시되는 경우)
  - App Store Connect에서 해당 구독이 속한 그룹과 동일하게 맞춤
  - 예시: `ExpenseDiary Premium` (운영에서 정한 그룹명)
- `RevenueCat product identifier`
  - 자동 생성값을 보통 그대로 사용하면 됩니다. (관리용)

예시 (Cloud 월간):
- `Display name`: `cloud_monthly`
- `Product type`: `Subscription`
- `Product ID`(또는 동등 필드): `cloud_monthly`
- `Duration`: `Monthly` (필드가 보이는 UI인 경우)

예시 (Report 월간):
- `Display name`: `report_monthly`
- `Product type`: `Subscription`
- `Product ID`(또는 동등 필드): `report_monthly`
- `Duration`: `Monthly` (필드가 보이는 UI인 경우)

중요:
- RevenueCat의 App Store Product 입력값은 **App Store Connect Product ID와 1글자라도 다르면 안 됩니다**.
- 대소문자/언더스코어(`_`)까지 동일해야 합니다.
- 먼저 App Store Connect에서 Auto-Renewable Subscription 상품을 만든 뒤 RevenueCat에 `Import`하는 순서를 가장 권장합니다.

## 2-5. Entitlement에 Product 연결

각 상품을 해당 Entitlement에 연결합니다.

- `cloud_monthly` -> `cloud`
- `report_monthly` -> `report`

연결이 없으면 구매는 되어도 권한 판정이 앱에서 기대대로 동작하지 않을 수 있습니다.

## 2-6. Offerings 생성 및 Package 연결

`Product catalog > Offerings` 에서 아래 Offering을 생성합니다.

- `cloud`
- `report`

각 Offering 내부에서 package를 연결합니다.

예시:
- `cloud` offering -> monthly package -> `cloud_monthly`
- `report` offering -> monthly package -> `report_monthly`

운영 메모:
- `default` offering이 있어도 괜찮습니다.
- 현재 앱은 `cloud`, `report` offering을 직접 조회하므로 두 offering의 package 연결이 가장 중요합니다.

현재 앱의 Paywall(`lib/screen/paywall_screen.dart`)은 `cloud`, `report` offering을 로드하여 표시하도록 구현되어 있습니다.

## 2-7. Test Store와 실제 스토어의 차이

RevenueCat `Products`에 `Test Store`만 보이는 경우는 정상일 수 있습니다.

의미:
- RevenueCat 내부 테스트용 상품만 있는 상태
- 아직 Android/iOS 앱이 RevenueCat에 등록되지 않았거나, 스토어 연결이 안 된 상태

이 상태에서도 기본 UI/연동 확인은 가능할 수 있지만, 실제 스토어 구매/복원 검증을 하려면 아래 `Apps & providers` 설정이 필요합니다.

## 3. RevenueCat에서 앱 연결 (Apps & providers)

`API keys` 화면에서 `SDK API keys`에 `Test Store`만 보인다면, 아직 플랫폼 앱이 추가되지 않은 상태입니다.

`Apps & providers`는 RevenueCat 프로젝트에 "실제 플랫폼 앱(Android/iOS)"와 "스토어 연결 정보"를 등록하는 곳입니다.

여기서 하는 일:
- Android 앱 등록 (패키지명)
- iOS 앱 등록 (Bundle ID)
- Google Play / App Store provider 연결
- 연결 완료 후 플랫폼별 Public SDK key 생성 확인

핵심 개념:
- `Product catalog`는 "상품/권한 구조"를 정의하는 곳
- `Apps & providers`는 "어느 플랫폼 앱/스토어와 연결할지"를 정의하는 곳

즉, 둘 다 설정되어야 실제 구매 검증이 가능합니다.

해야 할 일:
- `Apps & providers`로 이동
- Android 앱 추가 (패키지명 입력)
- iOS 앱 추가 (Bundle ID 입력)

권장 진행 순서:
1. Android 앱 추가
2. iOS 앱 추가
3. 스토어 Provider 연결 상태 확인 (Play / App Store)
4. `API keys`로 돌아와 플랫폼별 Public SDK key 생성 여부 확인

앱 추가 후:
- `API keys` -> `SDK API keys` 에 Android용 / iOS용 `Public API key`가 생성됩니다.

중요:
- 앱에서 사용하는 키는 `Secret API key`가 아니라 `SDK API keys > Public API key` 입니다.
- `Secret API key`는 서버 전용이며 앱 코드/클라이언트에 넣으면 안 됩니다.

키 선택 기준:
- 초기 연동 확인: `Test Store` Public key 사용 가능
- Android 실구매 테스트: Android 앱의 Public SDK key 사용
- iOS 실구매 테스트: iOS 앱의 Public SDK key 사용

## 3-0. Apps & providers 상세 절차 (권장 순서)

UI 버전에 따라 버튼/탭 이름은 조금 다를 수 있지만, 순서는 거의 동일합니다.

1. RevenueCat 좌측 하단 `Apps & providers` 이동
2. `Add app` 또는 `+ New app` 선택
3. Android 앱 추가
4. iOS(App Store) 앱 추가
5. 각 플랫폼의 provider 연결 상태 확인
6. `API keys`로 이동해 플랫폼별 `SDK API keys` 생성 확인

중요:
- `Apps & providers`에 앱을 추가해도, 스토어 상품/자격증명(provider) 연결이 미완료면 실제 결제/복원 테스트는 실패할 수 있습니다.
- 반대로 `Product catalog`만 잘 만들어도 Paywall UI는 일부 동작할 수 있습니다.

## 3-0-1. Android 앱 추가 (Google Play)

입력값(일반적):
- App name: 예) `ExpenseDiary (Google Play)` (관리용 이름)
- Package name / Application ID: `com.ysh.expense_diary`

입력 시 주의:
- Android `applicationId`와 정확히 일치해야 함
- 오타/대소문자/점(`.`) 차이도 다른 앱으로 인식됨

현재 프로젝트 기준:
- `android/app/build.gradle.kts:39` -> `applicationId = "com.ysh.expense_diary"`

추가 후 확인할 것:
- `Apps & providers` 목록에 Android 앱이 생성됨
- 상태가 "앱 등록됨"으로 보임 (provider 연결 전 상태일 수 있음)
- `API keys`에 Android용 `SDK API key` row가 생성되었는지 확인

## 3-0-2. iOS 앱 추가 (App Store)

입력값(일반적):
- App name: 예) `ExpenseDiary (App Store)` (관리용 이름)
- App Bundle ID: `com.ysh.expenseDiary`
- In-app purchase key configuration:
  - `.p8` 파일 업로드
  - `Key ID`
  - `Issuer ID`

입력 시 주의:
- iOS Bundle ID와 정확히 일치해야 함
- `.p8`, `Key ID`, `Issuer ID`는 RevenueCat 값이 아니라 Apple에서 발급된 값

현재 프로젝트 기준:
- `ios/Runner.xcodeproj/project.pbxproj:504` 등 -> `PRODUCT_BUNDLE_IDENTIFIER = com.ysh.expenseDiary`

추가 후 확인할 것:
- `Apps & providers` 목록에 iOS 앱이 생성됨
- `API keys`에 iOS용 `SDK API key` row가 생성되었는지 확인

## 3-0-3. Provider 연결 (스토어 자격증명 연결) 개념

`Apps & providers`에서 앱 등록과 provider 연결은 별개 단계일 수 있습니다.

예시:
- Android 앱은 추가했지만 Google Play 서비스 계정/연동 미완료
- iOS 앱은 추가했지만 In-App Purchase key 설정 미완료

이 경우 가능한 현상:
- SDK 초기화는 될 수 있음
- Paywall 상품 표시도 일부 될 수 있음
- 실제 구매/복원/영수증 반영은 실패하거나 누락될 수 있음

확인 포인트:
- RevenueCat `Apps & providers` 화면에서 각 앱의 provider 상태가 경고/미완료인지 확인
- 경고가 있으면 해당 플랫폼 자격증명 입력 완료

## 3-0-4. Apps & providers 설정 후 `API keys`에서 확인할 것

`API keys` 화면에서 꼭 확인해야 하는 것:

1. `Secret API keys`가 아니라 `SDK API keys` 섹션을 본다
2. `Test Store` 외에 Android/iOS 앱 row가 생겼는지 확인한다
3. 각 row의 `Public API key`를 복사할 수 있는지 확인한다

키 사용 규칙:
- Flutter 앱에는 `SDK API keys > Public API key`만 사용
- 서버(있을 경우)에만 `Secret API key` 사용

실행에 연결:
- Android 테스트 시 `RC_ANDROID_PUBLIC_SDK_KEY`
- iOS 테스트 시 `RC_IOS_PUBLIC_SDK_KEY`

## 3-0-5. Apps & providers에서 자주 막히는 케이스

1. `API keys`에 `Test Store`만 계속 보임
- 원인: Android/iOS 앱을 아직 추가하지 않음
- 해결: `Apps & providers`에서 플랫폼 앱 추가

2. 앱은 추가했는데 실제 구매가 안 됨
- 원인: provider(스토어 자격증명) 연결 미완료
- 해결: Google Play / App Store 자격증명 설정 완료 후 재테스트

3. iOS 앱 추가 시 `.p8`, `Key ID`, `Issuer ID`에서 막힘
- 원인: App Store Connect `앱 내 구입 생성` 화면을 열었기 때문 (구독 상품 생성 화면)
- 해결: `Users and Access > Integrations > In-App Purchase`에서 키 생성/확인

4. Android/iOS 키를 넣었는데 앱에서 여전히 RevenueCat 비활성
- 원인: `flutter run`/IDE 실행 설정에 `--dart-define` 누락
- 해결: 실행 명령/Run Configuration에 키 전달 확인

5. 플랫폼 식별자 오타 (패키지명/Bundle ID)
- 원인: 앱 추가 시 잘못된 식별자 입력
- 해결: 프로젝트 실제 값과 다시 대조 (`android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`)

## 3-1. Android App의 패키지명 / iOS App의 Bundle ID는 어디서 찾나요?

RevenueCat `Apps & providers`에서 앱 추가 시 입력하는 값은 프로젝트의 실제 식별자와 일치해야 합니다.

현재 프로젝트(`expense_diary`) 기준 실제 값:
- Android 패키지명 (`applicationId`): `com.ysh.expense_diary`
- iOS Bundle ID (`PRODUCT_BUNDLE_IDENTIFIER`): `com.ysh.expenseDiary`

프로젝트에서 확인하는 위치:
- Android
  - `android/app/build.gradle.kts`의 `applicationId`
  - 현재 값: `android/app/build.gradle.kts:39`
  - 참고용 `namespace`: `android/app/build.gradle.kts:23`
- iOS
  - `ios/Runner.xcodeproj/project.pbxproj`의 `PRODUCT_BUNDLE_IDENTIFIER`
  - 현재 값 예시: `ios/Runner.xcodeproj/project.pbxproj:504`
  - `ios/Runner/Info.plist`에는 실제 문자열 대신 `$(PRODUCT_BUNDLE_IDENTIFIER)` 참조가 보임 (`ios/Runner/Info.plist:12`)

RevenueCat 입력 시 사용 방법:
- Android App 추가 화면의 Package name/App identifier -> `com.ysh.expense_diary`
- iOS App 추가 화면의 App Bundle ID -> `com.ysh.expenseDiary`

주의:
- Android와 iOS 식별자는 서로 동일할 필요가 없습니다.
- 각 플랫폼에서 실제 빌드에 사용되는 값과만 일치하면 됩니다.

## 3-2. App Store 앱 추가 시 `Key ID` / `Issuer ID`는 어디서 얻나요?

RevenueCat에서 iOS(App Store) 앱을 추가할 때 `.p8` 키 업로드와 함께 `Key ID`, `Issuer ID`를 요구할 수 있습니다.

이 값들은 App Store Connect / Apple Developer에서 가져옵니다.

먼저 구분 (중요):
- App Store Connect의 `앱 내 구입 생성` 화면은 구독 상품(`cloud_monthly`, `report_monthly`)을 만드는 화면입니다.
- RevenueCat iOS 앱 연결에 필요한 `.p8`, `Key ID`, `Issuer ID`를 만드는 화면이 아닙니다.
- RevenueCat용 키는 보통 `Users and Access > Integrations > In-App Purchase` 경로에서 생성/확인합니다.

### 준비물

- In-App Purchase key (`.p8` 파일)
- `Key ID`
- `Issuer ID`

### 가져오는 위치 (일반적인 경로)

1. App Store Connect 또는 Apple Developer 계정에서 In-App Purchase / App Store Server API용 키를 생성
2. 키 생성 후 `.p8` 파일 다운로드
3. 같은 화면(또는 키 상세 화면)에서 `Key ID` 확인
4. 계정의 API issuer 정보에서 `Issuer ID` 확인 (UUID 형식)

실무적으로는 아래 화면 중 하나에서 찾게 됩니다.
- App Store Connect의 Users and Access / Integrations / API Keys 관련 화면
- Apple Developer의 App Store Connect API / In-App Purchase key 생성 화면

### 클릭 경로 예시 (App Store Connect / Apple Developer)

UI 버전에 따라 메뉴명이 조금 다를 수 있지만, 보통 아래 경로에서 찾습니다.

App Store Connect 기준(권한 필요):
1. `App Store Connect` 로그인
2. 상단 또는 우측 상단 계정 메뉴에서 `Users and Access` 이동
3. `Integrations` 탭 이동
4. 좌측 `Keys` 영역에서 `In-App Purchase` 선택
5. `Generate In-App Purchase Key` (또는 `+`) 클릭
6. 키 생성 후 `.p8` 파일 다운로드
7. 같은 화면/키 상세에서 `Key ID` 확인
8. `Issuer ID` 확인 (UUID 형식, 상단/Integrations 정보 영역)

Apple Developer 기준(대체 경로):
1. `Apple Developer` 로그인
2. `Certificates, Identifiers & Profiles` 또는 App Store Connect API/Keys 관련 메뉴 이동
3. In-App Purchase / App Store Server API용 키 생성
4. `.p8` 파일 다운로드
5. 생성 완료 화면/키 상세에서 `Key ID` 확인
6. 계정의 API issuer 정보에서 `Issuer ID` 확인

권한 관련 주의:
- 계정 권한이 부족하면 `Users and Access`, `Integrations`, `API Keys` 메뉴가 보이지 않거나 키 생성이 불가능할 수 있습니다.
- 이 경우 App Store Connect `Admin` 또는 적절한 권한을 가진 계정으로 진행해야 합니다.

형식 체크:
- `Key ID`: 보통 짧은 영문/숫자 조합 (예: `ABC123DEFG`)
- `Issuer ID`: UUID 형식 (예: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

RevenueCat 입력 방법:
- `P8 key file from App Store Connect` -> 다운로드한 `.p8` 업로드
- `Key ID` -> 키 생성 화면에 표시된 Key ID 입력
- `Issuer ID` -> Apple 계정의 Issuer ID(UUID) 입력

실무 팁:
- 먼저 App Store Connect에서 구독 상품(`앱 내 구입`)을 만드는 작업과, RevenueCat용 In-App Purchase key 생성 작업은 별개로 진행하세요.
- 둘 다 필요하지만 목적이 다릅니다.

입력 전에 확인할 것:
- RevenueCat iOS App 추가 화면의 `App Bundle ID`가 프로젝트 iOS Bundle ID(`com.ysh.expenseDiary`)와 일치하는지
- 업로드하는 `.p8` 키가 App Store/In-App Purchase용 키인지

주의:
- `Key ID`와 `Issuer ID`는 RevenueCat에서 생성되는 값이 아닙니다.
- Apple 쪽에서 발급된 값을 그대로 입력해야 합니다.
- `.p8` 파일은 재다운로드가 제한적일 수 있으므로 안전하게 보관하세요.

## 4. Flutter에서 RevenueCat 연동하는 방법 (이 프로젝트 기준)

## 4-1. SDK 설치

이 프로젝트는 이미 `purchases_flutter`를 사용 중입니다.

패키지:
- `purchases_flutter`

참고:
- RevenueCat 온보딩에서 `purchases_ui_flutter` 설치를 제안할 수 있지만, 현재 프로젝트는 커스텀 Paywall을 구현했으므로 필수는 아닙니다.

## 4-2. API 키는 어디에 작성하나요? (중요)

이 프로젝트는 RevenueCat 키를 소스코드에 하드코딩하지 않습니다.

키를 읽는 위치:
- `lib/core/subscription/revenuecat_provider.dart`

읽는 방식:
- `String.fromEnvironment(...)` (`--dart-define` 기반)

즉, 키를 특정 `.dart` 파일에 직접 쓰는 방식이 아니라, 실행/빌드 시 주입합니다.

### "어느 파일? 어디에 작성?"에 대한 실제 답변

- `.dart` 파일에 작성하지 않습니다.
- 이 프로젝트는 `lib/core/subscription/revenuecat_provider.dart`에서 `String.fromEnvironment(...)`로 읽습니다.
- 따라서 실제 값은 실행/빌드 명령(`--dart-define`) 또는 IDE/CI 설정에 넣습니다.

권장 저장 위치:
- 로컬 터미널 실행 명령
- 로컬 스크립트(예: `scripts/run_local.sh`, Git 미추적)
- VS Code `launch.json`
- Android Studio Run Configuration
- CI/CD Secret 환경변수 + build step

### 사용되는 `dart-define` 키 이름

- `RC_ANDROID_PUBLIC_SDK_KEY`
- `RC_IOS_PUBLIC_SDK_KEY`
- `RC_ENTITLEMENT_CLOUD` (기본값 `cloud`)
- `RC_ENTITLEMENT_REPORT` (기본값 `report`)
- `RC_OFFERING_CLOUD` (기본값 `cloud`)
- `RC_OFFERING_REPORT` (기본값 `report`)

## 4-3. 앱 실행/빌드 시 키 전달 예시

### 로컬 실행 (`flutter run`)

```bash
flutter run \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=YOUR_ANDROID_PUBLIC_SDK_KEY \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=YOUR_IOS_PUBLIC_SDK_KEY \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud \
  --dart-define=RC_OFFERING_REPORT=report
```

### `Test Store`로 먼저 확인하는 예시 (초기 연동 단계)

```bash
flutter run \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=test_xxx \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=test_xxx \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud \
  --dart-define=RC_OFFERING_REPORT=report
```

메모:
- `test_xxx`는 RevenueCat `API keys > SDK API keys`의 `Test Store` Public key입니다.
- 이 단계는 "연동 확인" 목적입니다.
- 실제 스토어 테스트 전에는 반드시 Android/iOS Public SDK key로 교체하세요.

### 빌드 시 (`flutter build apk/ios`)

동일하게 `--dart-define`를 붙여서 전달합니다.

예:
```bash
flutter build apk \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=YOUR_ANDROID_PUBLIC_SDK_KEY \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud \
  --dart-define=RC_OFFERING_REPORT=report
```

운영 권장:
- 로컬 쉘 스크립트 또는 IDE launch configuration에 저장
- 저장소(Git)에 실제 키 커밋 금지

### 로컬 실행 스크립트 예시 (권장)

매번 `flutter run --dart-define=...`를 길게 입력하지 않도록 로컬 스크립트를 만들어 사용할 수 있습니다.

예시 파일:
- `scripts/run_with_revenuecat.sh` (Git 미추적 권장)

예시 내용:

```bash
#!/usr/bin/env bash
set -euo pipefail

flutter run \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY="${RC_ANDROID_PUBLIC_SDK_KEY:-}" \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY="${RC_IOS_PUBLIC_SDK_KEY:-}" \
  --dart-define=RC_ENTITLEMENT_CLOUD="${RC_ENTITLEMENT_CLOUD:-cloud}" \
  --dart-define=RC_ENTITLEMENT_REPORT="${RC_ENTITLEMENT_REPORT:-report}" \
  --dart-define=RC_OFFERING_CLOUD="${RC_OFFERING_CLOUD:-cloud}" \
  --dart-define=RC_OFFERING_REPORT="${RC_OFFERING_REPORT:-report}"
```

사용 예시:

```bash
export RC_ANDROID_PUBLIC_SDK_KEY="your_android_public_sdk_key"
export RC_IOS_PUBLIC_SDK_KEY="your_ios_public_sdk_key"
bash scripts/run_with_revenuecat.sh
```

팁:
- 초기 연동 확인 단계에서는 `your_*_public_sdk_key` 대신 `Test Store` Public key(`test_xxx`)를 넣어 사용할 수 있습니다.
- 실스토어 테스트 단계에서는 반드시 Android/iOS 앱용 Public SDK key로 교체하세요.

### VS Code `launch.json` 예시

VS Code를 사용하면 실행 버튼으로도 `dart-define`를 자동 전달할 수 있습니다.

예시 파일:
- `.vscode/launch.json`

예시 내용:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (RevenueCat)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define=RC_ANDROID_PUBLIC_SDK_KEY=YOUR_ANDROID_PUBLIC_SDK_KEY",
        "--dart-define=RC_IOS_PUBLIC_SDK_KEY=YOUR_IOS_PUBLIC_SDK_KEY",
        "--dart-define=RC_ENTITLEMENT_CLOUD=cloud",
        "--dart-define=RC_ENTITLEMENT_REPORT=report",
        "--dart-define=RC_OFFERING_CLOUD=cloud",
        "--dart-define=RC_OFFERING_REPORT=report"
      ]
    }
  ]
}
```

운영 팁:
- 팀 공용 `launch.json`에 실제 키를 넣지 마세요.
- 개인 로컬 설정으로 관리하거나, 예시 템플릿만 커밋하세요.
- 필요하면 `Flutter (RevenueCat-TestStore)` / `Flutter (RevenueCat-Prod)`처럼 실행 구성을 2개로 분리하세요.

### Android Studio Run Configuration 예시

Android Studio에서도 Flutter Run Configuration에 `--dart-define`를 저장할 수 있습니다.

일반적인 설정 경로:
1. 상단 실행 구성 드롭다운 클릭
2. `Edit Configurations...`
3. Flutter 실행 구성 선택 (없으면 새로 생성)
4. `Additional run args` 또는 `Additional arguments` 입력란에 `--dart-define` 추가

예시 (`Additional run args`):

```bash
--dart-define=RC_ANDROID_PUBLIC_SDK_KEY=YOUR_ANDROID_PUBLIC_SDK_KEY \
--dart-define=RC_IOS_PUBLIC_SDK_KEY=YOUR_IOS_PUBLIC_SDK_KEY \
--dart-define=RC_ENTITLEMENT_CLOUD=cloud \
--dart-define=RC_ENTITLEMENT_REPORT=report \
--dart-define=RC_OFFERING_CLOUD=cloud \
--dart-define=RC_OFFERING_REPORT=report
```

운영 팁:
- `RevenueCat-TestStore` / `RevenueCat-Store` 실행 구성을 분리해두면 전환이 편합니다.
- 개인 로컬 설정에 실제 키를 저장하고, 팀 공유 설정에는 템플릿 값만 두는 것을 권장합니다.
- Android만 테스트 중이어도, 공통 실행 설정 재사용을 위해 iOS 키까지 같이 넣어두는 방식이 편할 수 있습니다.

#### Android Studio에서 `Test Store`로 테스트하는 방법 (권장)

초기 연동 확인 단계에서는 Android Studio 실행 구성에 `Test Store` Public key를 넣어 빠르게 테스트할 수 있습니다.

권장 실행 구성 이름:
- `Flutter (RC TestStore)`

`Additional run args` 예시 (`Test Store`):

```bash
--dart-define=RC_ANDROID_PUBLIC_SDK_KEY=test_xxx \
--dart-define=RC_IOS_PUBLIC_SDK_KEY=test_xxx \
--dart-define=RC_ENTITLEMENT_CLOUD=cloud \
--dart-define=RC_ENTITLEMENT_REPORT=report \
--dart-define=RC_OFFERING_CLOUD=cloud \
--dart-define=RC_OFFERING_REPORT=report
```

설명:
- `test_xxx`는 RevenueCat `API keys > SDK API keys`의 `Test Store` Public key입니다.
- Android 실행 시 실제로는 `RC_ANDROID_PUBLIC_SDK_KEY`가 사용되지만, iOS 키도 같은 값으로 넣어두면 실행 구성 재사용이 편합니다.

정상 확인 포인트:
- 앱 실행 후 `RevenueCat 비활성` 메시지가 사라짐
- Paywall에서 Cloud/Report 상품이 표시됨
- 구매/복원 버튼 플로우가 끊기지 않음

주의:
- `Test Store`는 연동/플로우 확인용입니다.
- 실제 Google Play 결제 검증은 `Apps & providers` + Play Console 설정 완료 후 Android Public SDK key로 다시 테스트해야 합니다.

### `--dart-define-from-file` 사용 예시 (선택)

명령어가 길어지는 것이 불편하면 파일 기반 주입을 사용할 수 있습니다.

예시:

```json
{
  "RC_ANDROID_PUBLIC_SDK_KEY": "YOUR_ANDROID_PUBLIC_SDK_KEY",
  "RC_IOS_PUBLIC_SDK_KEY": "YOUR_IOS_PUBLIC_SDK_KEY",
  "RC_ENTITLEMENT_CLOUD": "cloud",
  "RC_ENTITLEMENT_REPORT": "report",
  "RC_OFFERING_CLOUD": "cloud",
  "RC_OFFERING_REPORT": "report"
}
```

실행:

```bash
flutter run --dart-define-from-file=env/revenuecat.dev.json
```

주의:
- Flutter 버전/환경에 따라 `--dart-define-from-file` 지원 여부를 확인하세요.
- 이 파일에도 실제 키가 들어가므로 Git 추적 제외(`.gitignore`)를 권장합니다.

## 4-4. 프로젝트 코드에서 실제로 어디서 연결되는가

### 앱 시작 초기화

- `lib/main.dart`
  - `SubscriptionService`를 `GetIt`에 등록
  - 앱 시작 시 `subscriptionService.init(...)` 호출

### RevenueCat 설정/오퍼링/구매/복원 래퍼

- `lib/core/subscription/revenuecat_provider.dart`
  - 플랫폼별 Public SDK key 읽기
  - Offering 로드
  - 구매/복원 호출 래핑
  - 키 누락/예외 시 안전하게 처리

### 플랜 상태 전역 관리

- `lib/core/subscription/subscription_service.dart`
  - 초기화 `init()`
  - 현재 플랜 `currentPlan`
  - `refreshPlan()`
  - RevenueCat CustomerInfo -> `PlanType` 변환
  - 실패 시 `free` 폴백 (크래시 방지)

### Firebase Auth 로그인/로그아웃 연동

- `lib/auth/auth_repository.dart`
  - 로그인 성공 시 `SubscriptionService.onUserSignedIn(uid)` 호출
  - 로그아웃 시 `SubscriptionService.onUserSignedOut()` 호출

효과:
- Firebase Auth 사용자와 RevenueCat app user가 동기화됨
- 로그인/로그아웃 후 플랜이 즉시 갱신됨

### Paywall 화면

- `lib/screen/paywall_screen.dart`
  - RevenueCat Offering 로드
  - Cloud/Report 상품 표시
  - 구매 처리
  - Restore 처리
  - 성공 시 `SubscriptionService.refreshPlan()` 반영

## 4-5. RevenueCat 비활성 메시지가 뜨는 경우

앱에서 아래와 같은 메시지가 보이면:
- "RevenueCat 비활성"
- "SDK 키가 설정되지 않아 현재 Free 모드로 동작 중입니다."

원인:
- `RC_ANDROID_PUBLIC_SDK_KEY` / `RC_IOS_PUBLIC_SDK_KEY` 미설정
- 또는 빈 값 전달

해결:
- `API keys` 화면의 `SDK API keys > Public API key`를 확인
- `flutter run --dart-define=...`로 키 전달

추가 점검:
- IDE로 실행 중이라면 Run Configuration에 `dart-define`가 빠져 있을 수 있음
- `Test Store` 키만 넣은 상태에서 실제 스토어 구매까지 기대하면 안 됨
- 키 변경 후 이상하면 `flutter clean` 후 재실행해 캐시 영향 제거

## 5. Google Play Console에서 해야 할 것 (Android)

RevenueCat 설정만으로는 실제 Android 구매 테스트가 완료되지 않습니다. Play Console 설정이 필요합니다.

핵심:
- RevenueCat `Product catalog`에서 만든 상품 구조(`cloud_monthly`, `report_monthly`)
- Play Console에서 만든 실제 구독 상품
- RevenueCat `Apps & providers`의 Android 앱/Google Play provider 연결

이 3개가 모두 맞아야 실제 테스트 구매가 정상 동작합니다.

## 5-0. Android 전체 흐름 (권장 순서)

1. Play Console에서 앱 생성/접근 권한 확인
2. Android 앱 패키지명 확인 (`com.ysh.expense_diary`)
3. Play Console에서 구독 상품 생성 (`cloud_monthly`, `report_monthly`)
4. 테스트 트랙(Internal/Closed) 업로드 및 배포
5. 테스터 계정 등록
6. RevenueCat `Apps & providers`에서 Google Play provider 연결 완료
7. RevenueCat Android Public SDK key로 앱 실행
8. 실제 테스트 계정으로 구매/복원 검증

## 5-1. 앱 패키지명 확인

RevenueCat `Apps & providers`에 등록한 Android 패키지명이 실제 Flutter Android 앱 패키지명과 일치해야 합니다.

확인 위치(프로젝트):
- `android/app/build.gradle.kts` 또는 `android/app/build.gradle` (applicationId)
- 또는 AndroidManifest 관련 설정

현재 프로젝트 기준:
- `android/app/build.gradle.kts:39` -> `applicationId = "com.ysh.expense_diary"`

Play Console / RevenueCat 입력 시 이 값을 기준으로 맞춥니다.

## 5-2. 구독 상품 생성

Play Console에서 구독 상품을 생성합니다.

예시 상품 ID:
- `cloud_monthly`
- `report_monthly`

주의:
- 이 ID는 RevenueCat `Products`의 Identifier와 동일해야 합니다.

### Play Console에서 어디서 만드나요? (일반적 경로)

UI가 바뀔 수 있지만 보통 아래 경로입니다.

1. `Google Play Console` 로그인
2. 대상 앱 선택
3. `수익 창출(Monetize)` 또는 `제품(Product)` 영역 이동
4. `구독(Subscriptions)` 선택
5. `새 구독 만들기(Create subscription)` 클릭

입력값(권장):
- Product ID: `cloud_monthly` 또는 `report_monthly`
- 이름(관리용): `Cloud Monthly`, `Report Monthly`
- 혜택/설명: 운영 정책에 맞게 작성

### 생성 후 추가로 해야 하는 것

- 기본 요금제(Base plan) 생성 (월간)
- 가격 설정
- 지역/판매 국가 설정
- 활성화(테스트 가능한 상태)

주의:
- Product ID는 생성 후 변경이 어렵거나 불가한 경우가 많습니다.
- RevenueCat `Products`와 불일치하면 상품 조회/구매 매핑이 깨집니다.
- `cloud_monthly`, `report_monthly`를 그대로 맞추는 것을 권장합니다.

## 5-3. 테스트 트랙/테스터 설정

실제 구매 테스트를 위해:
- 내부 테스트(Internal testing) 또는 닫힌 테스트(Closed testing) 트랙 배포
- 테스트 계정(구글 계정) 등록

테스트 APK/AAB를 배포하지 않으면 실제 구매 플로우가 정상 동작하지 않을 수 있습니다.

### 권장 테스트 방식

- 초기에는 `Internal testing` 트랙 사용 권장 (가장 빠름)
- 필요 시 `Closed testing`으로 확장

### 일반적인 작업 순서

1. `테스트(Test)` -> `내부 테스트(Internal testing)` 이동
2. 테스트 릴리스 생성
3. AAB/APK 업로드
4. 릴리스 노트 입력(간단히 가능)
5. 검토/배포
6. 테스터(구글 계정 이메일) 등록
7. 제공된 테스트 링크로 앱 설치

### 구매 테스트 전 체크

- 테스트 계정이 실제 기기 Play Store에 로그인되어 있는지
- 설치한 앱이 테스트 트랙 버전인지
- 구독 상품이 활성 상태인지
- 앱 패키지명이 테스트 트랙 앱과 RevenueCat Android 앱 설정과 일치하는지

## 5-4. RevenueCat와 Play 연결

RevenueCat `Apps & providers`에서 Google Play 연동을 완료해야 합니다.

확인 포인트:
- Android 앱이 RevenueCat에 추가됨
- Play 스토어 연결 상태 정상
- RevenueCat `Products`에서 Play 기반 상품이 보이거나 매핑됨

### Apps & providers에서 추가로 확인할 것 (Android)

- Android 앱의 Package name이 `com.ysh.expense_diary`인지
- Google Play provider 연결 경고가 없는지
- RevenueCat `API keys`에서 Android `SDK API key` row가 생성되었는지

### 연결이 불완전할 때 나타나는 현상

- SDK 초기화는 되지만 구매 시 실패
- 상품이 RevenueCat/스토어 간 불일치로 보이지 않음
- 구매 후 entitlement 반영이 지연/누락됨

이 경우 다음을 다시 점검하세요.
- Play Console 상품 ID (`cloud_monthly`, `report_monthly`)
- RevenueCat `Products` Identifier
- RevenueCat `Entitlements` / `Offerings` 연결
- Android 앱 패키지명
- 테스트 트랙/테스터 설정

## 5-5. Google Play 쪽에서 자주 막히는 케이스

1. 상품을 만들었는데 앱에서 안 보임
- 원인: Play 상품 ID와 RevenueCat Product ID 불일치
- 해결: 두 시스템의 ID를 동일하게 맞춤

2. 테스트 계정인데 구매 버튼이 비활성/오류
- 원인: 테스트 트랙 배포 전이거나 테스터 등록 누락
- 해결: Internal/Closed 테스트 배포 + 테스터 등록 + 테스트 링크 설치

3. 앱은 설치됐는데 실제 스토어 구매가 안 됨
- 원인: 디버그 로컬 설치본 사용 중일 수 있음 (테스트 트랙 설치본 필요)
- 해결: Play 테스트 링크로 설치한 빌드로 재확인

4. RevenueCat에서는 상품 구조가 맞는데 Android Public SDK key가 없음
- 원인: `Apps & providers`에 Android 앱 추가 안 됨
- 해결: RevenueCat Android 앱 추가 후 `API keys` 재확인

## 6. Apple App Store Connect에서 해야 할 것 (iOS)

## 6-1. Bundle ID 일치 확인

RevenueCat `Apps & providers`에 등록한 iOS Bundle ID가 Xcode/Flutter iOS 앱의 Bundle ID와 일치해야 합니다.

## 6-2. 구독 상품 생성 (App Store Connect)

App Store Connect에서 Auto-Renewable Subscription 상품을 생성합니다.

예시 Product ID:
- `cloud_monthly`
- `report_monthly`

주의:
- RevenueCat `Products`의 Identifier와 동일해야 합니다.

## 6-3. Sandbox 테스트 계정 준비

iOS 구매 테스트를 위해:
- App Store Connect Sandbox Tester 계정 생성
- 테스트 기기에서 Sandbox 계정으로 결제 테스트

## 6-4. RevenueCat와 App Store 연결

RevenueCat `Apps & providers`에서 Apple App Store 연동이 필요합니다.

확인 포인트:
- iOS 앱이 RevenueCat에 추가됨
- App Store 연결 상태 정상
- iOS Public SDK key가 `API keys`에 생성됨

## 7. 실제 검증 순서 (권장)

아래 순서로 검증하면 문제를 빨리 분리할 수 있습니다.

1. 1차 검증 (Test Store 기반)
- `API keys`에서 `Test Store` Public key 확인
- `flutter run --dart-define=...`로 `Test Store` 키 주입
- 앱에서 `RevenueCat 비활성` 메시지 제거 확인
- Paywall에서 Cloud/Report 상품 로딩 및 구매/복원 흐름(코드) 확인

2. RevenueCat 대시보드 구조 확인
- Entitlements: `cloud`, `report`
- Offerings: `cloud`, `report`
- Products: `cloud_monthly`, `report_monthly`

3. RevenueCat 앱 키 확인
- `API keys`에서 Android/iOS `Public API key` 생성 여부 확인
- `Test Store` 키만 있으면 `Apps & providers`에 플랫폼 앱 추가 필요

4. 앱 실행 시 `--dart-define` 주입
- `RevenueCat 비활성` 메시지 사라지는지 확인

5. Paywall 확인
- 설정 화면에서 Paywall 진입
- Cloud/Report 상품이 표시되는지 확인

6. 로그인/로그아웃 연동 확인
- 로그인 후 플랜 갱신
- 로그아웃 후 `free` 폴백

7. 실제 구매/복원 테스트 (플랫폼별)
- Android: Play 테스트 계정
- iOS: Sandbox tester
- 구매/복원 후 광고 숨김/권한 변화 즉시 반영 확인

프로젝트 QA 체크리스트 참고:
- `docs/qa/manual_validation_round1.md`

## 8. 자주 발생하는 문제와 원인

## 8-0. Test Store를 선택했는데 실제 결제가 안 됨

정상일 수 있습니다.

원인:
- `Test Store`는 RevenueCat 내부 테스트용이며 실제 Play/App Store 결제를 대체하지 않습니다.

해결:
- `Apps & providers`에서 Android/iOS 앱 추가
- Play Console / App Store Connect 상품 생성 및 연결
- RevenueCat `Products/Entitlements/Offerings` 매핑 확인
- 플랫폼별 Public SDK key로 앱 재실행
- 실제 테스트 계정(Play 내부 테스트 / iOS Sandbox)으로 검증

## 8-1. Paywall에서 상품이 안 보임

가능한 원인:
- Offering ID 불일치 (`cloud`, `report`)
- Offering에 package 미연결
- Product 미생성
- RevenueCat 키 미설정

확인 위치:
- `Product catalog > Offerings`
- `lib/core/subscription/revenuecat_provider.dart`

## 8-2. 구매는 됐는데 플랜이 안 올라감

가능한 원인:
- Entitlement 연결 누락
- Entitlement ID 불일치 (`cloud`/`report`)
- RevenueCat customer info 갱신 실패 (네트워크)

확인 포인트:
- `Product catalog > Entitlements`
- `SubscriptionService.refreshPlan()`

## 8-3. 앱에서 RevenueCat 비활성으로 계속 나옴

가능한 원인:
- `--dart-define` 누락/오타
- 잘못된 키 사용 (`Secret API key` 사용 등)
- `Test Store` 키만 사용 중이고 플랫폼 앱 키 미생성

확인 포인트:
- `API keys > SDK API keys > Public API key`

## 8-4. Free/Cloud/Report가 의도와 다르게 보임

가능한 원인:
- `report` entitlement가 cloud보다 우선 적용되는 규칙을 모름
- 특정 상품이 두 entitlement에 잘못 연결됨

현재 프로젝트 규칙:
- `report` 활성 시 무조건 `report` 플랜으로 판정

## 9. 운영/보안/배포 시 추가로 해야 하는 것

## 9-1. 키 관리

- Public SDK key라도 소스코드 하드코딩은 지양
- `--dart-define` / CI secrets / 로컬 실행 스크립트 사용
- `Secret API key`는 서버에서만 사용

## 9-2. 테스트 시나리오 문서화

- 구매 성공
- 구매 취소
- 복원 성공/실패
- 로그인 상태 변경 후 플랜 반영
- 네트워크 실패 시 free 폴백

권장:
- `docs/qa/manual_validation_round1.md`에 결과를 기록

## 9-3. 릴리스 전 확인

- Android/iOS 각각 Public SDK key 적용 여부
- Entitlement/Offering/Product ID 이름 일치 여부
- Paywall 상품 표시 확인
- 구매/복원 후 광고/권한 즉시 반영 확인
- 로그아웃 후 `free` 폴백 확인

## 10. 빠른 체크리스트 (요약)

- 개발 초반에는 `Test Store`로 시작 가능
- 실제 구매 검증/출시 전에는 Play/App Store 연결 필수
- RevenueCat `Entitlements`: `cloud`, `report`
- RevenueCat `Offerings`: `cloud`, `report`
- RevenueCat `Products`: `cloud_monthly`, `report_monthly`
- Product -> Entitlement 연결 완료
- Offering -> package 연결 완료
- `Apps & providers`에서 Android/iOS 앱 추가 완료
- `API keys`에서 Android/iOS Public SDK key 확인
- `flutter run --dart-define=...`로 키 전달
- 앱에서 `RevenueCat 비활성` 메시지 사라짐
- Paywall 상품 표시 확인
- 구매/복원 후 플랜 반영 확인
