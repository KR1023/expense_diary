# App Store Connect x RevenueCat(iOS) 연동 상세 가이드

이 문서는 ExpenseDiary의 iOS 구독(정기 결제)을 App Store Connect와 RevenueCat에 연결하고,
실제 테스트/제출 가능한 상태로 만드는 전체 절차를 정리한 운영 문서입니다.

관련 문서:
- `docs/revenueCat.md`
- `docs/play_revenuecat_provider_setup.md`
- `docs/play_store_subscription.md`

---

## 0. 핵심 요약

iOS 구독 연동은 아래 3개가 모두 맞아야 정상 동작합니다.

1. App Store Connect 구독 상품 상태(메타데이터/가격/제출 준비)
2. RevenueCat iOS 앱 Bundle ID와 실제 Xcode/App Store Bundle ID 일치
3. RevenueCat에 올린 Apple 자격증명(`.p8`, Key ID, Issuer ID) 정상

---

## 1. ID 일치 확인 (가장 먼저)

현재 프로젝트 iOS Bundle ID:
- `com.ysh.expenseDiary`

아래 3곳의 값이 문자 하나까지 동일해야 합니다.
- Xcode 프로젝트 Bundle ID
- App Store Connect 앱 Bundle ID
- RevenueCat `Apps & providers`의 iOS App Bundle ID

주의:
- `com.ysh.expense_diary` 와 `com.ysh.expenseDiary`는 서로 다른 ID입니다.
- 언더스코어/대소문자 차이도 불일치로 처리됩니다.

---

## 2. App Store Connect에서 구독 생성

권장 Product ID:
- `cloud_monthly`
- `report_monthly`

구독 생성 시:
- Product ID는 변경이 어렵거나 불가
- Subscription Group을 먼저/함께 구성

---

## 3. RevenueCat용 Apple 자격증명 준비

RevenueCat iOS 연결 시 가장 중요한 값:
- `.p8` (In-App Purchase Key)
- `Key ID`
- `Issuer ID`

주의:
- `In-App Purchase Key`와 `App Store Connect API Key`를 혼동하지 않기
- RevenueCat iOS provider 연결에는 In-App Purchase key 구성이 핵심

권장 키 이름 예시:
- `RevenueCat-ExpenseDiary-Prod`
- `RevenueCat-ExpenseDiary-Dev`

---

## 4. RevenueCat iOS Provider 연결

경로:
1. RevenueCat -> `Apps & providers`
2. `ExpenseDiary (App Store)` 선택
3. `In-app purchase key configuration`에 아래 입력
   - `.p8` 업로드
   - `Key ID`
   - `Issuer ID`
4. 저장 후 상태 확인

오류 예시:
- `Credentials need attention`

주요 원인:
- Bundle ID 불일치
- 키/ID 오입력
- 다른 Apple 팀에서 생성한 키 사용

---

## 5. Products Import 및 매핑

경로:
1. RevenueCat -> `Product catalog` -> `Products`
2. `ExpenseDiary (App Store)` 영역에서 `Import Products`

확인 대상:
- `cloud_monthly`
- `report_monthly`

Import 후 필수 연결:
- Entitlements:
  - `cloud_monthly -> cloud`
  - `report_monthly -> report`
- Offerings:
  - `cloud` offering monthly package -> `cloud_monthly`
  - `report` offering monthly package -> `report_monthly`

---

## 6. `MISSING_METADATA` 대응 체크리스트

RevenueCat에 `Missing Metadata (MISSING_METADATA)`가 뜨면 App Store Connect 상품 정보가 완성되지 않은 상태입니다.

각 구독 상품에서 아래 항목 점검:

1. 로컬라이제이션(Localizations)
- 표시 이름/설명 저장

2. 가격(Subscription Price)
- `신규 구독자에게 적용되는 현재 가격`에서 실제 가격 티어 설정/저장

3. 사용 가능 여부(Availability)
- 판매 국가/지역 설정

4. 심사 정보(App Review Information)
- 스크린샷 업로드(권장: 실제 구독/Paywall 화면)
- 필요 시 심사 추가 정보 작성

5. 세금 카테고리 확인
- 기본 카테고리/적용 상태 점검

추가 공통 점검:
- `Agreements, Tax, and Banking`에서 유료 앱 계약 미완료 항목 없는지

---

## 7. 첫 구독 제출 시 중요한 점

첫 구독은 보통 앱 버전 심사와 함께 제출해야 합니다.

절차:
1. App Store Connect `배포`의 앱 버전 페이지로 이동
2. `앱 내 구입 및 구독` 섹션에서
   - `cloud_monthly`
   - `report_monthly`
   추가
3. 앱 버전과 함께 심사 제출

주의:
- 구독 상품만 따로 만들어두고 앱 버전에 연결하지 않으면 판매 가능 상태 전환이 지연될 수 있음

---

## 8. 앱 실행 키(iOS)

앱 테스트 시 iOS Public SDK key 사용:
- `RC_IOS_PUBLIC_SDK_KEY=appl_xxx`

주의:
- `Secret API key`는 앱 코드에 넣지 않음

---

## 9. 테스트 전략

권장 순서:
1. RevenueCat 연결/Import/매핑 검증
2. iOS 실기기 Sandbox 또는 TestFlight에서 구매/복원 검증
3. 플랜 반영(Free/Cloud/Report) 확인
4. 만료/취소 반영 지연 시간 확인

---

## 10. 자주 막히는 케이스

1. RevenueCat iOS Bundle ID 오입력
- 예: `com.ysh.expense_diary`로 넣고 실제는 `com.ysh.expenseDiary`

2. In-App Purchase key 대신 다른 키를 업로드

3. Product ID 불일치
- App Store Connect와 RevenueCat ID가 다름

4. 메타데이터 누락
- 가격/심사정보/로컬라이즈 일부 미완료

5. 반영 지연
- App Store Connect/RevenueCat 상태 반영에 시간 소요 가능

---

## 11. 빠른 운영 체크리스트

- [ ] Xcode/App Store/RevenueCat Bundle ID 일치
- [ ] In-App Purchase `.p8`, Key ID, Issuer ID 입력 완료
- [ ] App Store 구독 `cloud_monthly`, `report_monthly` 생성
- [ ] RevenueCat Import 성공
- [ ] Entitlement/Offering 연결 완료
- [ ] App Store 상품 메타데이터(가격/로컬라이즈/심사정보) 완료
- [ ] 앱 버전에 구독 항목 추가 후 함께 제출
- [ ] iOS Public SDK key로 실기기 테스트 완료
