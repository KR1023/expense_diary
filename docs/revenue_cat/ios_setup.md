# RevenueCat iOS (App Store) 설정

## 현재 상태

| 항목 | 값 |
|---|---|
| 연동 상태 | **미완료** (사업자 등록 후 진행 예정) |
| iOS API Key | `appl_nfQCULthfEqbagScUuIkVIQbneG` (발급됨, 미적용) |
| Bundle ID | `com.ysh.expense_diary` |

### 임시 처리 (현재 적용 중)
- RevenueCat SDK iOS에서 초기화하지 않음
- iOS 사용자는 Free 플랜으로 동작 (광고 표시, 주 1회 백업, 일 1회 복원)
- 구독 버튼 탭 시 "준비 중" 안내 화면만 표시

---

## 사업자 등록 완료 후 진행 순서

### 1. App Store Connect — 구독 상품 등록

```
App Store Connect → 앱 선택 → 수익 창출 → 구독
→ 구독 그룹 생성 (예: "expense_diary_subscriptions")
→ 상품 등록 (Android와 동일한 ID 사용 권장)
```

| 상품 ID | 플랜 | 기능 |
|---|---|---|
| `cloud_monthly` | Cloud 플랜 (월간) | 광고 제거, 무제한 백업/복원 |
| `report_monthly` | Report 플랜 (월간) | Cloud 포함 + 통계/CSV/PDF |

> 상품 등록 후 Apple 심사 제출 필요 (보통 1~3일 소요).

---

### 2. App Store Connect — API 키 발급

RevenueCat이 Apple 서버와 통신하기 위해 필요하다.

```
App Store Connect → 사용자 및 액세스 → 통합 → App Store Connect API
→ 새 키 생성 (역할: 앱 관리자)
→ Key ID, Issuer ID 메모
→ .p8 파일 다운로드 (재다운로드 불가, 반드시 보관)
```

---

### 3. App Store Connect — 공유 암호(Shared Secret) 발급

영수증 검증에 사용한다.

```
App Store Connect → 앱 선택 → 수익 창출 → 앱별 공유 암호
→ 생성 → 값 복사
```

---

### 4. RevenueCat 대시보드 — iOS 앱 추가

```
RevenueCat → 프로젝트 → Add an app → App Store
→ Bundle ID: com.ysh.expense_diary
→ App Store Connect API Key 업로드 (Key ID, Issuer ID, .p8 파일)
→ 저장 → iOS API Key 확인 (appl_...)
```

---

### 5. RevenueCat 대시보드 — 상품 및 엔타이틀먼트 연결

```
Products → Import → App Store에서 cloud_monthly, report_monthly 가져오기

Entitlements → cloud → Attach → cloud_monthly (iOS 상품)
Entitlements → report → Attach → report_monthly (iOS 상품)
```

Android 엔타이틀먼트에 iOS 상품을 추가로 Attach하면
하나의 엔타이틀먼트로 양 플랫폼을 모두 관리할 수 있다.

---

### 6. 코드 수정

**`SubscriptionService._configure()` — iOS 초기화 활성화**

```dart
Future<void> _configure() async {
  // if (Platform.isIOS) return;  ← 이 줄 제거

  final isTest = RevenueCatConfig.testStoreKey.isNotEmpty;
  final apiKey = isTest
      ? RevenueCatConfig.testStoreKey
      : Platform.isIOS
          ? RevenueCatConfig.iosApiKey      // iOS 키 사용
          : RevenueCatConfig.androidApiKey;

  await Purchases.setLogLevel(isTest ? LogLevel.debug : LogLevel.error);
  await Purchases.configure(PurchasesConfiguration(apiKey));
  Purchases.addCustomerInfoUpdateListener((_) => _refresh());
  await _refresh();
}
```

**`SubscriptionService.loginUser() / logoutUser()` — iOS 예외 제거**

```dart
Future<void> loginUser(String uid) async {
  // if (Platform.isIOS) return;  ← 이 줄 제거
  ...
}

Future<void> logoutUser() async {
  // if (Platform.isIOS) return;  ← 이 줄 제거
  ...
}
```

**`PaywallScreen._loadOffering()` — iOS 조기 종료 제거**

```dart
Future<void> _loadOffering() async {
  // if (Platform.isIOS) { ... return; }  ← 이 블록 제거
  ...
}
```

**`PaywallScreen.build()` — iOS "준비 중" 화면 제거**

```dart
// if (Platform.isIOS) { return Scaffold(...coming soon...); }  ← 제거
```

---

### 7. iOS 구독 테스트

**Sandbox 테스트 계정 생성**
```
App Store Connect → 사용자 및 액세스 → 샌드박스 → 테스터
→ 새 테스터 추가 (별도 Apple ID 필요)
```

**기기에서 테스트**
```
iOS 기기 → 설정 → App Store → 샌드박스 계정 로그인
→ 앱 실행 → 구독 시도 → 샌드박스 결제 진행 (실제 청구 없음)
```

---

### 8. 구독 취소 처리 (iOS)

앱 내에서 직접 취소 불가. `customerInfo.managementURL`이 App Store 구독 관리 페이지를 반환한다.

---

## 관련 파일

| 파일 | 변경 내용 |
|---|---|
| `lib/const/revenuecat_config.dart` | `iosApiKey` 이미 선언됨 |
| `lib/core/subscription/subscription_service.dart` | iOS 예외 제거 |
| `lib/screen/paywall_screen.dart` | iOS "준비 중" 화면 제거 |
