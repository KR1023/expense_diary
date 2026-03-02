# 배포 시 RevenueCat 키 주입 가이드

이 문서는 ExpenseDiary 배포 빌드(iOS/Android)에서 RevenueCat 키를 안전하게 주입하는 방법을 정리합니다.

## 1) 핵심 원칙

- 앱에 포함해도 되는 값:
  - `RC_IOS_PUBLIC_SDK_KEY` (`appl_...`)
  - `RC_ANDROID_PUBLIC_SDK_KEY` (`goog_...`)
- 앱에 포함하면 안 되는 값:
  - RevenueCat Secret API Key
  - Google/Apple 서비스 계정 비밀키(JSON, p8 등)

즉, **모바일 앱에는 Public SDK Key만** 넣습니다.

## 2) 이 프로젝트에서 사용하는 dart-define 키

- `RC_IOS_PUBLIC_SDK_KEY`
- `RC_ANDROID_PUBLIC_SDK_KEY`
- `RC_ENTITLEMENT_CLOUD` (기본값: `cloud`)
- `RC_ENTITLEMENT_REPORT` (기본값: `report`)
- `RC_OFFERING_CLOUD` (기본값: `cloud`)
- `RC_OFFERING_REPORT` (기본값: `report`)

## 3) iOS 배포 빌드 (권장: flutter build ipa)

```bash
flutter build ipa --release \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=appl_xxx \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud \
  --dart-define=RC_OFFERING_REPORT=report
```

생성된 IPA를 App Store Connect(TestFlight/Release)로 업로드합니다.

## 4) Android 배포 빌드 (AAB)

```bash
flutter build appbundle --release \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=appl_xxx \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud \
  --dart-define=RC_OFFERING_REPORT=report
```

생성된 AAB를 Play Console 내부 테스트/운영 트랙에 업로드합니다.

## 5) CI/CD 권장 방식

- 키를 코드/저장소에 하드코딩하지 않습니다.
- CI Secret 환경변수로 관리하고, 빌드 시 `--dart-define`로 주입합니다.
- 팀 공유용 문서에는 실제 키가 아닌 placeholder만 기록합니다.

예시:

```bash
flutter build ipa --release \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=$RC_IOS_PUBLIC_SDK_KEY \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=$RC_ANDROID_PUBLIC_SDK_KEY \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud \
  --dart-define=RC_OFFERING_REPORT=report
```

## 6) 배포 전 체크리스트

- RevenueCat Offering ID가 앱 코드와 일치 (`cloud`, `report`)
- Entitlement ID가 앱 코드와 일치 (`cloud`, `report`)
- Product ID 매핑 확인 (`cloud_monthly`, `report_monthly`)
- iOS: App Store 상품 상태/제출 상태 확인
- Android: Play 정기결제/베이스플랜 활성 상태 확인
- 앱 실행 로그에 `API key missing for current platform`가 없는지 확인

