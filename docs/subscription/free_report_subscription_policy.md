# 리포트 무료화 및 구독 정책 변경 가이드

## 1. 변경 목적

현재 앱은 리포트/통계 기능을 `Report` 구독 플랜으로 제공하고 있다. 앞으로는 앱 유입과 초기 사용 경험을 높이기 위해 **통계 보기, CSV 내보내기, PDF 내보내기를 무료 기능으로 전환**하고, 구독은 **광고 제거와 클라우드 백업/복원 강화** 중심으로 단순화한다.

핵심 방향은 다음과 같다.

| 구분 | 기존 | 변경 후 |
|---|---|---|
| 통계 보기 | Report 구독 필요 | 무료 제공 |
| CSV 내보내기 | Report 구독 필요 | 무료 제공 |
| PDF 내보내기 | Report 구독 필요 | 무료 제공 |
| 광고 제거 | Cloud/Report 구독 | Cloud 구독 |
| 클라우드 백업/복원 무제한 | Cloud/Report 구독 | Cloud 구독 |
| 결제 수단 제한 해제 | Cloud/Report 구독 | Cloud 구독 |
| 고정 지출 제한 해제 | Cloud/Report 구독 | Cloud 구독 |

## 2. 변경 후 플랜 구성

### Free 플랜

무료 사용자는 앱의 핵심 기록/분석 기능을 모두 사용할 수 있다.

제공 기능:

- 지출 추가/수정/삭제
- 지출 내역 조회
- 캘린더 조회
- 분류 관리
- 결제 수단 관리 기본 사용
- 고정 지출 기본 사용
- 통계 보기
- CSV 내보내기
- PDF 내보내기
- 제한적 클라우드 백업/복원
- 광고 표시

제한 사항:

| 항목 | Free 제한 |
|---|---|
| 광고 | 표시 |
| 클라우드 백업 | KST 기준 주 1회 |
| 클라우드 복원 | KST 기준 일 1회 |
| 결제 수단 | 활성 결제 수단 5개 제한 |
| 고정 지출 | 활성 고정 지출 10개 제한 |

### Cloud 플랜

Cloud 플랜은 앱 사용 편의성과 데이터 안정성을 강화하는 구독 플랜으로 유지한다.

제공 기능:

- 광고 제거
- 클라우드 백업 무제한
- 클라우드 복원 무제한
- 결제 수단 개수 제한 해제
- 고정 지출 개수 제한 해제

### Report 플랜

변경 후에는 신규 사용자에게 Report 플랜을 판매하지 않는다.

권장 처리:

- 앱 UI에서는 Report 플랜 노출 제거
- RevenueCat Offering에서 Report 패키지 제거 또는 비활성화
- Google Play Console에서는 Report 구독 상품을 신규 구매 불가 상태로 전환
- 기존 Report 구독자가 있다면 남은 구독 기간 동안 최소한 Cloud 플랜과 동일한 혜택을 제공

중요:

Report 기능 자체가 무료화되므로 `report` 엔타이틀먼트는 더 이상 통계/CSV/PDF 접근 제어에 사용하지 않는다. 다만 기존 Report 구독자 보호를 위해 한동안 `report` 엔타이틀먼트는 Cloud 혜택을 포함하는 호환 레이어로 남겨둘 수 있다.

## 3. 앱 코드 변경 방향

### 3.1 통계 탭 게이트 제거

현재 `lib/screen/statistics_tab_screen.dart`는 통계, CSV, PDF 항목 접근 시 `RevenueCatConfig.entitlementReport`를 확인한다.

변경 방향:

- `StatisticsTabScreen`에서 `isReportEntitled` 확인 제거
- 통계/CSV/PDF 항목의 잠금 아이콘 제거
- 항목 탭 시 바로 화면으로 이동
- 비로그인/구독 유도/paywall 이동 제거

대상 화면:

- `ReportStatisticsScreen`
- `ReportCsvExportScreen`
- `ReportPdfExportScreen`

변경 후 동작:

```text
통계 탭 → 통계 보기 → 즉시 진입
통계 탭 → CSV 보고서 다운로드 → 즉시 진입
통계 탭 → PDF 보고서 다운로드 → 즉시 진입
```

### 3.2 CSV/PDF 화면 문구 수정

현재 CSV/PDF 화면에는 `Report 플랜 전용` 문구가 직접 들어가 있다.

수정 대상:

- `lib/screen/report_csv_export_screen.dart`
- `lib/screen/report_pdf_export_screen.dart`

변경 예시:

```text
기존: Report 플랜 전용. 로컬 SQLite 거래 내역을 CSV로 저장하고 공유할 수 있습니다.
변경: 로컬 지출 내역을 CSV로 저장하고 공유할 수 있습니다.
```

```text
기존: Report 플랜 전용. 월간 요약 + 카테고리 TOP + 거래 리스트가 포함된 PDF를 생성합니다.
변경: 월간 요약, 분류별 합계, 거래 리스트가 포함된 PDF를 생성합니다.
```

### 3.3 구독 화면에서 Report 플랜 제거

현재 `lib/screen/subscription_screen.dart`는 Free 사용자에게 Cloud와 Report 플랜을 모두 보여준다.

변경 방향:

- 구독 화면에는 Cloud 플랜만 표시
- Report 플랜 카드 제거
- Report 업그레이드 버튼 제거
- 현재 플랜 표시에서 `SubscriptionPlan.report`는 기존 구독자 호환 용도로만 처리

권장 표시:

```text
현재 플랜
- Free
- Cloud

구독 혜택
- 광고 제거
- 클라우드 백업/복원 무제한
- 결제 수단 제한 해제
- 고정 지출 제한 해제
```

### 3.4 SubscriptionService 정리

현재 구조:

```dart
enum SubscriptionPlan { free, cloud, report }

bool get isCloudEntitled => ... || _reportEntitled;
bool get isReportEntitled => ... || _reportEntitled;
```

권장 방향:

1. 단기 호환
   - `report` 엔타이틀먼트는 유지
   - `isReportEntitled`는 더 이상 UI 게이트에 사용하지 않음
   - `isCloudEntitled`는 기존처럼 `_reportEntitled`를 포함해 기존 Report 구독자에게 광고 제거/백업 무제한 제공

2. 장기 정리
   - 신규 Report 판매가 완전히 종료되고 기존 구독자가 없어진 뒤 `SubscriptionPlan.report`, `_reportEntitled`, `isReportEntitled` 제거 검토
   - `RC_ENTITLEMENT_REPORT`, `RC_OFFERING_REPORT` dart-define 제거 검토

권장 단기 유지 이유:

- 기존 Report 구독자가 있을 수 있음
- RevenueCat/Play Console 설정 변경 직후에도 앱이 기존 구매 상태를 안전하게 처리해야 함
- 기존 권한 문서(`userEntitlements`)의 `role: report`, `manualReport`와 호환 가능

### 3.5 수동 권한 문서 처리

현재 Firestore `userEntitlements/{uid}`는 다음 필드를 지원한다.

```text
role: normal | cloud | report | special | admin
manualCloud: boolean
manualReport: boolean
manualAdsRemoved: boolean
```

변경 후 권장 해석:

| 필드 | 변경 후 의미 |
|---|---|
| `manualCloud` | 광고 제거 + 백업/복원 무제한 + 제한 해제 |
| `manualReport` | 신규 부여 비권장. 기존 호환용 |
| `role: report` | 신규 부여 비권장. 기존 호환용으로 Cloud 혜택 포함 |
| `role: special/admin` | 전체 제한 해제 유지 |

새 테스트/운영 권한 부여 시에는 `manualReport` 대신 `manualCloud` 또는 `role: special/admin`을 사용한다.

## 4. RevenueCat 설정 변경

### 4.1 목표 상태

RevenueCat에서는 신규 판매 플랜을 Cloud 하나로 단순화한다.

권장 상태:

| 항목 | 유지 여부 | 설명 |
|---|---|---|
| Product `cloud_monthly` | 유지 | 신규 판매 구독 상품 |
| Entitlement `cloud` | 유지 | 광고 제거/백업 무제한 권한 |
| Offering package `cloud_monthly` | 유지 | 앱에서 구매하는 Cloud 패키지 |
| Product `report_monthly` | 신규 판매 중단 | 기존 구독자 호환용으로만 유지 가능 |
| Entitlement `report` | 단기 유지 | 기존 Report 구독자 판정용 |
| Offering package `report_monthly` | 제거 권장 | 신규 구매 화면에서 노출하지 않음 |

### 4.2 RevenueCat 대시보드 작업 순서

1. RevenueCat 대시보드 접속
2. 해당 프로젝트 선택
3. Products 확인
   - `cloud_monthly` 유지
   - `report_monthly`는 삭제하지 말고 일단 유지 권장
4. Entitlements 확인
   - `cloud` 유지
   - `report`는 단기 호환용으로 유지
5. Offerings 이동
6. 앱에서 사용하는 현재 Offering 확인
7. 현재 Offering의 Packages에서 `report_monthly` 제거
8. `cloud_monthly`만 남김
9. 저장 후 RevenueCat 대시보드에서 Offering 상태 확인

주의:

- `report_monthly` Product나 `report` Entitlement를 즉시 삭제하지 않는 것을 권장한다.
- 기존 Report 구독자가 남아 있을 경우, 삭제 시 앱이 기존 구매 상태를 해석하지 못할 수 있다.
- 앱 코드에서 Report 구매 진입점을 제거한 뒤 Offering에서 Report 패키지를 제거해야 사용자가 신규 Report를 구매하지 않는다.

### 4.3 RevenueCat Entitlement 연결 권장

기존 Report 구독자를 Cloud 혜택으로 계속 인정하려면 두 가지 방식 중 하나를 선택한다.

#### 권장안 A: 코드 호환 유지

현재 코드처럼 `isCloudEntitled`가 `_reportEntitled`도 포함하게 둔다.

장점:

- RevenueCat 설정 변경이 적음
- 기존 Report 구독자가 자동으로 Cloud 혜택을 받음
- 롤백이 쉬움

단점:

- 코드에 Report 호환 로직이 남음

#### 권장안 B: RevenueCat에서 report 상품을 cloud entitlement에도 연결

RevenueCat Entitlements에서 `cloud`에 기존 `report_monthly`도 attach한다.

장점:

- RevenueCat 기준으로도 Report 구독자가 Cloud 권한을 갖게 됨

단점:

- 설정 의도가 다소 혼란스러울 수 있음
- 나중에 정리할 때 추적할 항목이 늘어남

추천은 **권장안 A**다. 앱 코드의 기존 호환 로직을 유지하고, Report 신규 판매만 중단하는 방식이 가장 안전하다.

## 5. Google Play Console 설정 변경

### 5.1 목표 상태

Play Console에서는 Cloud 구독 상품만 신규 판매 대상으로 유지한다.

| 구독 상품 | 처리 |
|---|---|
| `cloud_monthly` | 유지 |
| `report_monthly` | 신규 구매 중단 또는 비활성화 |

### 5.2 작업 전 확인 사항

- 현재 `report_monthly` 구독자가 있는지 확인
- 실제 판매 중인 국가/가격/베이스 플랜 확인
- 앱 코드에서 Report 구매 진입점 제거가 먼저 배포될 예정인지 확인

기존 구독자가 있는 경우:

- 즉시 삭제보다 신규 구매만 막는 방향이 안전하다.
- 기존 구독자는 남은 기간 또는 자동 갱신 상태에 따라 계속 관리되어야 한다.
- 앱에서는 기존 Report 구독자를 Cloud 혜택으로 인정해야 한다.

### 5.3 Play Console 작업 순서

1. Google Play Console 접속
2. 앱 선택
3. 수익 창출 또는 Monetize 메뉴로 이동
4. 구독 상품 목록 진입
5. `cloud_monthly` 확인
   - 활성 상태 유지
   - 베이스 플랜/가격 정상 확인
6. `report_monthly` 확인
7. `report_monthly`의 신규 구매 가능 상태를 중단
   - 가능한 경우 베이스 플랜 비활성화 또는 판매 중지
   - 삭제보다는 비활성/판매 중지 권장
8. 저장
9. 내부 테스트 또는 비공개 테스트 트랙에서 구독 화면 확인

주의:

- Play Console UI 명칭은 시점에 따라 `수익 창출`, `구독`, `제품`, `베이스 플랜` 등으로 다르게 보일 수 있다.
- 이미 판매 중인 구독 상품은 완전 삭제가 제한될 수 있다.
- 기존 구독자 보호를 위해 Report 상품을 무리하게 삭제하지 않는다.

## 6. 앱스토어 iOS 처리

현재 iOS는 구독 구매 UI를 임시 비활성화하고 “준비 중”으로 표시한다.

이번 정책 변경 후 iOS 방향:

- 통계/CSV/PDF는 iOS에서도 무료 제공
- 구독 화면은 계속 “준비 중” 또는 Cloud 구독 준비 안내로 유지
- iOS 구독을 추후 도입할 때도 Cloud 플랜만 App Store Connect에 생성하는 것을 권장
- Report 구독 상품은 iOS에 새로 만들지 않는다

추후 iOS 구독을 도입할 경우 생성할 상품:

| 상품 ID | 용도 |
|---|---|
| `cloud_monthly` | 광고 제거 + 백업/복원 무제한 |

생성하지 않을 상품:

| 상품 ID | 이유 |
|---|---|
| `report_monthly` | 리포트 기능 무료화로 신규 판매 불필요 |

## 7. 앱 내 문구 변경

### 7.1 통계 탭 문구

현재 문구 예시:

```text
상세 통계와 CSV/PDF 보고서를 사용할 수 있습니다.
```

유지 가능하지만, 구독 느낌을 제거하려면 다음처럼 변경할 수 있다.

```text
월별 통계와 CSV/PDF 보고서를 확인할 수 있습니다.
```

### 7.2 구독 화면 문구

Cloud 플랜 중심으로 정리한다.

권장 문구:

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

### 7.3 CSV/PDF 화면 문구

구독 전용 표현을 제거한다.

CSV:

```text
로컬 지출 내역을 CSV로 저장하고 공유할 수 있습니다.
```

PDF:

```text
월간 요약과 지출 내역이 포함된 PDF 보고서를 생성합니다.
```

## 8. 배포 순서 권장안

안전한 순서는 다음과 같다.

1. 앱 코드 수정
   - 통계/CSV/PDF 게이트 제거
   - 구독 화면에서 Report 플랜 제거
   - 문구 수정
2. 내부 테스트
   - Free 계정에서 통계/CSV/PDF 진입 확인
   - Free 계정에서 광고 표시 확인
   - Free 계정에서 백업/복원 제한 확인
   - Cloud 구독 계정에서 광고 제거/백업 무제한 확인
   - 기존 Report 구독 계정이 있다면 Cloud 혜택 유지 확인
3. 앱 새 버전 배포
4. RevenueCat Offering에서 Report 패키지 제거
5. Play Console에서 `report_monthly` 신규 구매 중단
6. 일정 기간 모니터링
7. 기존 Report 구독자가 0명이 된 뒤 코드/RevenueCat에서 Report 호환 레이어 제거 검토

## 9. 테스트 체크리스트

### Free 사용자

- [ ] 통계 화면에 잠금 아이콘이 표시되지 않음
- [ ] 통계 화면 진입 가능
- [ ] CSV 생성 가능
- [ ] PDF 생성 가능
- [ ] 광고 표시됨
- [ ] 백업 주 1회 제한 적용
- [ ] 복원 일 1회 제한 적용
- [ ] 결제 수단 5개 제한 적용
- [ ] 고정 지출 10개 제한 적용

### Cloud 구독 사용자

- [ ] 광고가 표시되지 않음
- [ ] 백업 제한 없음
- [ ] 복원 제한 없음
- [ ] 결제 수단 제한 없음
- [ ] 고정 지출 제한 없음
- [ ] 통계/CSV/PDF 사용 가능

### 기존 Report 구독 사용자

- [ ] 통계/CSV/PDF 사용 가능
- [ ] 광고가 표시되지 않음
- [ ] 백업/복원 제한 없음
- [ ] 앱 내에서 Report 신규 구매/업그레이드 카드가 표시되지 않음
- [ ] 구독 관리 진입 가능

### iOS 사용자

- [ ] 통계/CSV/PDF 무료 사용 가능
- [ ] 구독 화면은 준비 중 또는 Cloud 준비 안내로 표시
- [ ] RevenueCat 초기화 비활성 상태에서 크래시 없음

## 10. 최종 권장안

최종 권장 구조는 다음과 같다.

```text
무료 = 기록 + 분석 + 내보내기
구독 = 광고 제거 + 백업/복원 무제한 + 제한 해제
```

이 구조가 유리한 이유:

- 통계/리포트는 로컬 DB 기반이라 서버 비용 부담이 낮음
- 사용자가 앱의 핵심 가치를 무료로 충분히 체감할 수 있음
- 광고 제거와 백업은 사용자가 데이터를 쌓은 뒤 결제 필요성을 느끼기 쉬움
- 플랜이 단순해져 스토어 설명과 앱 심사 대응이 쉬워짐
