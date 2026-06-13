# 리포트 무료화 및 Report 플랜 제거 티켓

## 1. 목적

현재 앱은 리포트/통계 기능을 `Report` 구독 플랜으로 제공하고 있다. 하지만 리포트/통계/CSV/PDF는 로컬 DB 기반 기능이라 서버 비용 부담이 낮고, 무료 사용자에게 앱의 핵심 가치를 보여주기 좋은 기능이다.

따라서 이번 작업의 목표는 다음과 같다.

- 통계 보기 무료화
- CSV 내보내기 무료화
- PDF 내보내기 무료화
- `Report` 플랜 신규 판매 및 앱 내 노출 제거
- 유료 구독은 `Cloud` 플랜 하나로 단순화
- `Cloud` 플랜은 광고 제거, 클라우드 백업/복원 무제한, 결제 수단/고정 지출 제한 해제에 집중

현재 확인된 전제:

- `Report` 플랜을 구독 중인 사용자는 없다.
- 따라서 기존 Report 구독자 호환 레이어를 장기간 유지할 필요는 없다.
- 다만 RevenueCat/Play Console의 상품/엔타이틀먼트 삭제는 이력 관리와 롤백 가능성을 위해 마지막 단계로 처리한다.

현재 구현 상태:

- 앱 코드에서는 통계/CSV/PDF 권한 게이트와 Report 구매 경로를 제거했다.
- 앱 UI에서는 Cloud 단일 플랜만 표시한다.
- `role: report`, `manualReport`, `report` alias는 앱에서 유료 권한으로 해석하지 않는다.
- RevenueCat/Google Play Console의 Report 상품 신규 판매 중단은 운영 콘솔에서 별도로 처리해야 한다.

## 2. 변경 후 플랜 구조

| 기능 | Free | Cloud |
|---|---|---|
| 지출 추가/수정/삭제 | 제공 | 제공 |
| 지출 내역 조회 | 제공 | 제공 |
| 캘린더 조회 | 제공 | 제공 |
| 분류 관리 | 제공 | 제공 |
| 결제 수단 관리 | 5개 제한 | 무제한 |
| 고정 지출 관리 | 10개 제한 | 무제한 |
| 통계 보기 | 제공 | 제공 |
| CSV 내보내기 | 제공 | 제공 |
| PDF 내보내기 | 제공 | 제공 |
| 광고 | 표시 | 제거 |
| 클라우드 백업 | KST 기준 주 1회 | 무제한 |
| 클라우드 복원 | KST 기준 일 1회 | 무제한 |

## 3. 제거 대상

### 3.1 앱 UI에서 제거

- `Report` 플랜 카드
- `Report` 업그레이드 버튼
- 통계/CSV/PDF 잠금 아이콘
- 통계/CSV/PDF 진입 시 구독 유도 동작
- CSV/PDF 화면의 `Report 플랜 전용` 문구
- 설정 또는 구독 화면에서 사용자에게 보이는 `Report 플랜` 표시

### 3.2 앱 코드에서 제거 또는 정리

대상 파일:

- `lib/screen/statistics_tab_screen.dart`
- `lib/screen/subscription_screen.dart`
- `lib/screen/paywall_screen.dart`
- `lib/screen/report_csv_export_screen.dart`
- `lib/screen/report_pdf_export_screen.dart`
- `lib/core/subscription/subscription_service.dart`
- `lib/const/revenuecat_config.dart`
- `assets/locales/ko.json`
- `assets/locales/en.json`

정리 방향:

- `StatisticsTabScreen`에서 `isReportEntitled` 또는 `RevenueCatConfig.entitlementReport` 기반 접근 제어를 제거한다.
- 통계/CSV/PDF 항목은 탭하면 바로 진입한다.
- `SubscriptionScreen`은 Cloud 플랜만 보여준다.
- `PaywallScreen`은 Cloud 결제만 처리하도록 단순화한다.
- `SubscriptionPlan.report`는 제거한다.
- `_reportEntitled`, `isReportEntitled`는 제거한다.
- `RC_ENTITLEMENT_REPORT`, `RC_OFFERING_REPORT`, `RevenueCatConfig.entitlementReport`, `RevenueCatConfig.offeringReport`는 제거한다.
- `paywall.report.*`, `subscription.report.*`처럼 Report 전용 번역 key는 사용처 제거 후 삭제한다.

주의:

- `role: report`, `manualReport` 같은 Firestore 수동 권한도 앱 코드에서 제거한다.
- 기존 Firestore 문서에 해당 필드가 남아 있어도 앱은 이를 유료 권한으로 해석하지 않는다.
- 운영 중 직접 부여할 권한은 `manualCloud`, `manualAdsRemoved`, `role: cloud`, `role: special`, `role: admin`만 사용한다.
- `special`, `admin` 권한은 기존처럼 전체 유료 기능 해제 역할을 유지한다.

## 4. 구현 상세

### 4.1 통계 탭 무료화

현재 동작:

```text
통계 탭 → 통계/CSV/PDF 선택 → Report 권한 확인 → 없으면 Paywall 이동
```

변경 후 동작:

```text
통계 탭 → 통계 보기 → 즉시 진입
통계 탭 → CSV 보고서 다운로드 → 즉시 진입
통계 탭 → PDF 보고서 다운로드 → 즉시 진입
```

작업 항목:

- [x] `StatisticsTabScreen`에서 권한 체크 제거
- [x] 잠금 아이콘 제거
- [x] Paywall 이동 로직 제거
- [x] 통계/CSV/PDF 항목을 일반 메뉴처럼 표시

### 4.2 CSV/PDF 화면 문구 수정

CSV 기존 문구:

```text
Report 플랜 전용. 로컬 SQLite 거래 내역을 CSV로 저장하고 공유할 수 있습니다.
```

CSV 변경 문구:

```text
로컬 지출 내역을 CSV로 저장하고 공유할 수 있습니다.
```

PDF 기존 문구:

```text
Report 플랜 전용. 월간 요약 + 카테고리 TOP + 거래 리스트가 포함된 PDF를 생성합니다.
```

PDF 변경 문구:

```text
월간 요약, 분류별 합계, 지출 내역이 포함된 PDF 보고서를 생성합니다.
```

작업 항목:

- [x] `Report 플랜 전용` 문구 제거
- [x] `카테고리 TOP`처럼 순위형 표현이 실제 화면 정책과 맞지 않으면 `분류별 합계`로 변경
- [x] 한국어/영어 번역 파일에 동일한 의미 반영

### 4.3 구독 화면 Cloud 단일화

변경 후 구독 화면은 Cloud 플랜만 표시한다.

권장 표시:

```text
Cloud 플랜
광고 없이 더 편하게 사용하고, 데이터를 안전하게 백업하세요.
```

기능 목록:

```text
- 광고 제거
- 클라우드 백업/복원 무제한
- 결제 수단 제한 해제
- 고정 지출 제한 해제
```

작업 항목:

- [x] Report 플랜 카드 제거
- [x] Report 구매 버튼 제거
- [x] 현재 플랜 표시에서 Report 분기 제거
- [x] 구독 복원 후 Report 상태 표시 분기 제거
- [x] iOS에서는 기존처럼 구독 준비 중 안내 유지

### 4.4 Paywall Cloud 전용화

현재 Paywall은 entitlement에 따라 Cloud/Report 문구와 상품을 나눠 보여줄 수 있다.

변경 방향:

- 앱 내 Paywall 진입은 Cloud만 허용한다.
- Report entitlement로 Paywall을 여는 경로는 제거한다.
- 방어 코드가 필요하다면 Report 값이 들어와도 Cloud Paywall로 대체한다.

작업 항목:

- [x] `PaywallScreen`의 Report 분기 제거
- [x] `paywall.report.*` 번역 key 사용 제거
- [x] 상품 조회는 Cloud offering/package만 사용
- [x] Report package가 RevenueCat Offering에 없어도 앱 코드가 Report package를 조회하지 않도록 정리

### 4.5 SubscriptionService 정리

현재 구조 예시:

```dart
enum SubscriptionPlan { free, cloud, report }

bool get isCloudEntitled => ... || _reportEntitled;
bool get isReportEntitled => ... || _reportEntitled;
```

변경 후 권장 구조:

```dart
enum SubscriptionPlan { free, cloud }

bool get isCloudEntitled => _cloudEntitled || manualCloudLikeEntitled;
bool get isAdsRemoved => isCloudEntitled || manualAdsRemovedLikeEntitled;
```

정리 항목:

- [x] `SubscriptionPlan.report` 제거
- [x] `_reportEntitled` 제거
- [x] `isReportEntitled` 제거
- [x] `currentPlan`에서 Report 반환 제거
- [x] RevenueCat customer info 파싱에서 `entitlementReport` 조회 제거
- [x] 수동 권한의 `role: report`는 앱에서 무시

수동 권한 권장 해석:

| 필드 | 변경 후 처리 |
|---|---|
| `manualCloud` | Cloud 혜택 부여 |
| `manualAdsRemoved` | 광고 제거만 부여 |
| `manualReport` | 제거. 값이 남아 있어도 앱에서 무시 |
| `role: cloud` | Cloud 혜택 부여 |
| `role: report` | 제거. 값이 남아 있어도 앱에서 무시 |
| `role: special/admin` | 전체 제한 해제 유지 |

추천:

- 운영 중 직접 부여할 권한은 `manualCloud` 또는 `role: special/admin`만 사용한다.
- `manualReport`, `role: report`는 제거된 권한으로 취급한다.
- 이미 Report 구독자가 0명이므로 RevenueCat `report` entitlement는 코드에서 읽지 않는다.

### 4.6 RevenueCatConfig 정리

제거 대상:

```text
RC_ENTITLEMENT_REPORT
RC_OFFERING_REPORT
RevenueCatConfig.entitlementReport
RevenueCatConfig.offeringReport
```

유지 대상:

```text
RC_ANDROID_PUBLIC_SDK_KEY
RC_IOS_PUBLIC_SDK_KEY
RC_TEST_STORE_KEY
RC_FORCE_ENTITLED
RC_ENTITLEMENT_CLOUD
RC_OFFERING_CLOUD
```

기본값:

```text
RC_ENTITLEMENT_CLOUD=cloud
RC_OFFERING_CLOUD=cloud_monthly
```

Android release build 예시:

```bash
flutter build appbundle \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_OFFERING_CLOUD=cloud_monthly
```

## 5. RevenueCat 콘솔 작업

### 5.1 목표 상태

| 항목 | 처리 |
|---|---|
| Product `cloud_monthly` | 유지 |
| Entitlement `cloud` | 유지 |
| Offering package `cloud_monthly` | 유지 |
| Product `report_monthly` | 신규 판매 중단. 가능하면 비노출 상태로 보관 |
| Entitlement `report` | 앱 코드에서 미사용. 즉시 삭제보다 보관 권장 |
| Offering package `report_monthly` | 제거 |

### 5.2 작업 순서

1. RevenueCat 대시보드 접속
2. 현재 `report_monthly` 구독자가 0명인지 다시 확인
3. Products에서 `cloud_monthly` 유지 확인
4. Entitlements에서 `cloud` 유지 확인
5. Offerings로 이동
6. 앱에서 사용하는 Offering 확인
7. 해당 Offering의 Packages에서 `report_monthly` 제거
8. `cloud_monthly`만 남김
9. 저장
10. 앱에서 구독 화면 진입 시 Cloud만 표시되는지 확인

주의:

- Product와 Entitlement 삭제는 즉시 하지 않는 것을 권장한다.
- 삭제보다 Offering에서 제거하는 방식이 롤백과 이력 관리에 유리하다.
- 코드에서 Report 구매 경로를 제거한 앱 버전이 배포된 뒤 RevenueCat Offering을 정리하는 것이 가장 안전하다.

## 6. Google Play Console 작업

### 6.1 목표 상태

| 구독 상품 | 처리 |
|---|---|
| `cloud_monthly` | 유지 |
| `report_monthly` | 신규 구매 중단 또는 비활성화 |

### 6.2 작업 순서

1. Google Play Console 접속
2. 앱 선택
3. 수익 창출 또는 Monetize 메뉴로 이동
4. 구독 상품 목록 진입
5. `cloud_monthly` 확인
6. `report_monthly` 구독자가 0명인지 확인
7. `report_monthly` 베이스 플랜의 신규 구매 가능 상태를 중단
8. 가능한 경우 비활성화 또는 판매 중지 처리
9. 저장
10. 내부 테스트 또는 비공개 테스트 트랙에서 구독 화면 확인

주의:

- 이미 생성된 구독 상품은 완전 삭제가 제한될 수 있다.
- 이름은 남아 있어도 앱과 RevenueCat Offering에서 노출하지 않으면 신규 구매 경로는 사라진다.
- 기존 구독자가 0명이라는 사실을 작업 메모로 남긴다.

## 7. iOS 처리

현재 iOS는 구독 구매 UI가 임시 비활성화되어 있고 “준비 중”을 표시한다.

이번 변경 후 방향:

- 통계/CSV/PDF는 iOS에서도 무료 제공
- iOS 구독 화면은 기존처럼 준비 중으로 유지하거나 Cloud 준비 안내만 표시
- 추후 App Store 구독을 도입하더라도 `cloud_monthly`만 생성
- `report_monthly`는 생성하지 않음

## 8. 배포 순서

권장 순서:

1. 앱 코드 수정
   - 통계/CSV/PDF 무료화
   - Report UI 제거
   - Report Paywall 제거
   - SubscriptionService/RevenueCatConfig 정리
   - 번역 문구 정리
2. 로컬 테스트
3. Android 내부 테스트 또는 비공개 테스트 배포
4. iOS 시뮬레이터/실기기 테스트
5. 앱 새 버전 배포
6. 새 버전에서 Report 구매 경로가 사라진 것을 확인
7. RevenueCat Offering에서 `report_monthly` 제거
8. Play Console에서 `report_monthly` 신규 구매 중단
9. 일정 기간 모니터링
10. 문제가 없으면 장기적으로 RevenueCat의 미사용 Report product/entitlement 삭제 검토

## 9. 테스트 체크리스트

### Free 사용자

- [ ] 통계 탭에 잠금 아이콘이 표시되지 않는다.
- [ ] 통계 화면에 바로 진입할 수 있다.
- [ ] CSV를 생성할 수 있다.
- [ ] PDF를 생성할 수 있다.
- [ ] 통계/CSV/PDF 진입 시 Paywall이 열리지 않는다.
- [ ] 광고는 표시된다.
- [ ] 백업 주 1회 제한이 적용된다.
- [ ] 복원 일 1회 제한이 적용된다.
- [ ] 결제 수단 5개 제한이 적용된다.
- [ ] 고정 지출 10개 제한이 적용된다.

### Cloud 구독 사용자

- [ ] 광고가 표시되지 않는다.
- [ ] 백업 제한이 없다.
- [ ] 복원 제한이 없다.
- [ ] 결제 수단 제한이 없다.
- [ ] 고정 지출 제한이 없다.
- [ ] 통계/CSV/PDF를 사용할 수 있다.

### 구독 화면

- [ ] Cloud 플랜만 표시된다.
- [ ] Report 플랜 카드가 표시되지 않는다.
- [ ] Report 구매 버튼이 없다.
- [ ] 복원 버튼은 정상 동작한다.
- [ ] iOS에서는 준비 중 안내가 정상 표시된다.

### RevenueCat/Play 설정 이후

- [ ] RevenueCat Offering에 `cloud_monthly`만 남아 있어도 앱이 정상 동작한다.
- [ ] `report_monthly` package가 없어도 앱에서 오류가 발생하지 않는다.
- [ ] Play Console에서 Report 신규 구매가 불가능하다.
- [ ] Cloud 구매 플로우는 정상 동작한다.

### 회귀 테스트

- [ ] 앱 시작 시 RevenueCat 초기화 오류 없음
- [ ] 로그인/로그아웃 후 권한 상태 갱신 정상
- [ ] 광고 제거 권한 반영 정상
- [ ] 백업/복원 제한 반영 정상
- [ ] 결제 수단 제한 반영 정상
- [ ] 고정 지출 제한 반영 정상

## 10. 완료 조건

이 티켓은 다음 조건을 모두 만족하면 완료로 본다.

- [x] Free 사용자가 통계/CSV/PDF를 사용할 수 있다.
- [x] 앱 UI에서 Report 플랜이 보이지 않는다.
- [x] 앱 코드에서 Report 구매 진입점이 제거되었다.
- [x] 구독 화면은 Cloud 단일 플랜 기준으로 동작한다.
- [ ] Android에서 Cloud 구매/복원 흐름이 깨지지 않는다.
- [x] iOS에서 구독 준비 중 화면이 깨지지 않는다.
- [x] RevenueCat Offering에서 Report package를 제거해도 앱 코드가 Report package를 조회하지 않는다.
- [ ] Play Console에서 Report 신규 구매 경로를 중단할 수 있는 상태다.
- [x] 변경 대상 파일 기준 `flutter analyze`가 통과한다.
- [ ] 관련 수동 테스트 결과가 확인되었다.

## 11. 최종 정책 문구

스토어와 앱 내 설명은 다음 방향으로 정리한다.

```text
무료 = 기록 + 분석 + 내보내기
구독 = 광고 제거 + 백업/복원 무제한 + 사용 제한 해제
```

이 구조가 유리한 이유:

- 통계/리포트는 로컬 DB 기반이라 서버 비용 부담이 낮다.
- 사용자가 앱의 핵심 가치를 무료로 체감할 수 있다.
- 광고 제거와 백업/복원은 사용자가 데이터를 쌓은 뒤 결제 필요성을 느끼기 쉽다.
- 유료 플랜이 하나로 단순해져 스토어 설명, 앱 심사, 고객 응대가 쉬워진다.
