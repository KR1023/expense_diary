# RevenueCat 콘솔 설정

## 현재 상태 요약

| 항목 | 값 |
|---|---|
| 플랫폼 | Android 전용 (iOS는 사업자 등록 후 추가 예정) |
| Android API Key | `goog_BWfATQigKwKTGYMoNlyeAVwpJFB` |
| Android 패키지명 | `com.ysh.expense_diary` |
| 엔타이틀먼트 | `cloud`, `report` |
| 오퍼링 | Default offering (패키지 2개) |

---

## 1. 프로젝트 생성

1. [RevenueCat 대시보드](https://app.revenuecat.com) 접속 후 새 프로젝트 생성
2. **Add an app** → **Google Play Store** 선택
3. Android 패키지명 입력: `com.ysh.expense_diary`
4. Google Play 서비스 계정 JSON 키 업로드 (Play Console → 설정 → API 액세스에서 발급)
5. 저장 후 Android API Key 확인 (`goog_BWf...`)

---

## 2. Play Store 상품 (Subscriptions)

Play Console에 등록된 구독 상품:

| 상품 ID | 기준 플랜 ID | 기능 |
|---|---|---|
| `cloud_monthly` | `monthly2` | 클라우드 백업/복원 무제한 |
| `report_monthly` | `monthly` | 통계·CSV·PDF 내보내기 |

RevenueCat에서 **Import subscription products** 기능으로 Play Store 상품을 가져온 후 Products 목록에 등록.

---

## 3. 엔타이틀먼트 (Entitlements)

기능 접근 권한을 엔타이틀먼트 단위로 관리. 코드에서는 엔타이틀먼트 키만 참조.

| 엔타이틀먼트 ID | 연결 상품 | 잠금 기능 |
|---|---|---|
| `cloud` | `cloud_monthly:monthly2` | 클라우드 백업 무제한, 복원 무제한 |
| `report` | `report_monthly:monthly` | 통계, CSV 내보내기, PDF 내보내기 |

설정 경로: RevenueCat 대시보드 → Entitlements → 각 엔타이틀먼트에 상품 Attach

---

## 4. 오퍼링 (Offerings & Packages)

Default offering에 패키지 2개 구성:

| 패키지 식별자 | 연결 상품 | 역할 |
|---|---|---|
| `cloud_monthly` | `cloud_monthly:monthly2` | 클라우드 백업 구독 패키지 |
| `report_monthly` | `report_monthly:monthly` | 리포트 구독 패키지 |

`PaywallScreen`에서 `Purchases.getOfferings()`로 current offering을 로드한 뒤, 엔타이틀먼트에 따라 `cloud_monthly` 또는 `report_monthly` 패키지를 찾아 결제 진행.

---

## 5. iOS 추가 예정

iOS는 현재 사업자 등록 전으로 구독 기능을 제공하지 않는다. 사업자 등록 완료(약 2~3개월) 후 아래 작업이 필요하다:

1. RevenueCat 프로젝트에 App Store 앱 추가
2. App Store Connect에서 구독 상품 생성 (상품 ID 동일하게 맞추기 권장)
3. iOS 엔타이틀먼트에 App Store 상품 Attach
4. `RevenueCatConfig`에 `iosApiKey` 추가
5. `SubscriptionService._configure()`의 iOS 예외 제거 및 플랫폼별 키 분기 처리
