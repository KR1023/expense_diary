# Google Play x RevenueCat 연동 상세 운영 가이드

이 문서는 `Google Play 구독 상품`을 `RevenueCat`에 연동해서 `Import Products`가 정상 동작하도록 만드는 전체 절차를 단계별로 정리한 문서입니다.

대상:
- Android 실스토어 테스트(내부/비공개 트랙 포함)
- Play Console 구독(`정기 결제`)과 RevenueCat 연결

관련 문서:
- `docs/play_store_seller.md`
- `docs/play_store_subscription.md`
- `docs/revenueCat.md`

---

## 0. 먼저 알아야 할 핵심 (가장 중요)

이 작업에는 "키/자격증명"이 3종류 있습니다.

1) Google Cloud **서비스 계정 JSON 키**
- 용도: RevenueCat이 Play 정보를 읽기 위한 서버 간 연동
- 사용 위치: RevenueCat `Apps & providers`에서 Google Play provider 연결 시 업로드

2) RevenueCat **Android Public SDK key** (`goog_...`)
- 용도: 앱에서 RevenueCat SDK 초기화
- 사용 위치: 앱 실행 시 `--dart-define=RC_ANDROID_PUBLIC_SDK_KEY=...`

3) RevenueCat **Secret API key**
- 용도: 서버 전용
- 주의: 앱 코드에 넣으면 안 됨

---

## 1. 사전 준비

- Play Console에서 앱이 생성되어 있어야 함
- 앱 패키지명 확인: `com.ysh.expense_diary`
- Play Console에서 구독 생성:
  - `cloud_monthly`
  - `report_monthly`
- 각 구독에 Base plan 생성(예: `monthly`) + 활성화

---

## 2. Google Cloud Console 설정

### 2-1. API 활성화 (API key 생성 아님)

경로:
1. `console.cloud.google.com`
2. 프로젝트 선택 (서비스 계정을 만들 프로젝트)
3. `API 및 서비스` -> `라이브러리`
4. 아래 API 2개 각각 `사용 설정`

활성화 대상:
- `Google Play Android Developer API` (필수)
- `Google Play Developer Reporting API` (권장)

중요:
- 여기서 말하는 건 "API 사용 설정"입니다.
- API key 생성 단계가 아닙니다.

### 2-2. 서비스 계정 생성

경로:
1. `IAM 및 관리자` -> `서비스 계정`
2. `서비스 계정 만들기`

권장 입력:
- 이름: `revenuecat-play-import`
- 설명: `RevenueCat Google Play integration`

생성 마법사 단계 중 `권한(선택사항)`:
- 이 단계에서는 **비워도 됨**
- 핵심 권한은 다음 단계(Play Console)에서 부여

### 2-3. JSON 키 발급

경로:
1. 방금 만든 서비스 계정 클릭
2. `키` 탭 -> `키 추가` -> `새 키 만들기`
3. `JSON` 선택 후 다운로드

주의:
- JSON 파일은 민감 정보이므로 안전한 위치에 보관
- Git에 커밋 금지

---

## 3. Google Play Console 권한 부여

핵심:
- 서비스 계정 생성만으로는 부족
- Play Console에 해당 이메일을 사용자로 추가해야 RevenueCat가 접근 가능

경로:
1. `Play Console` -> `사용자 및 권한`
2. 서비스 계정 이메일(`...iam.gserviceaccount.com`) 추가
3. 앱 선택: `com.ysh.expense_diary`
4. 권한 부여 후 저장

권장 권한(RevenueCat 연동 기준):
- `View app information and download bulk reports (read-only)`
- `View financial data, orders, and cancellation survey responses`
- `Manage orders and subscriptions`

추가 확인:
- 초대/활성 상태가 완료되었는지 확인

---

## 4. RevenueCat에서 Google Play Provider 연결

경로:
1. RevenueCat -> `Apps & providers`
2. Android 앱 선택(패키지명 `com.ysh.expense_diary`)
3. Google Play provider 연결 메뉴 진입
4. 2-3에서 받은 서비스 계정 JSON 업로드
5. 저장

정상 기준:
- provider 상태에 경고가 없음

---

## 5. RevenueCat Product Import

경로:
1. `Product catalog` -> `Products`
2. `ExpenseDiary (Play Store)` 영역
3. `Import Products`

기대 결과:
- `cloud_monthly`
- `report_monthly`
- base plan(`monthly`)이 함께 보임

안 보이면 점검:
- Play 구독/요금제 상태가 초안인지
- 서비스 계정 권한 누락인지
- 패키지명 불일치인지
- 반영 지연(수분~최대 24~36시간)인지

---

## 6. Import 후 필수 연결

### 6-1. Entitlements 연결
- `cloud_monthly` -> `cloud`
- `report_monthly` -> `report`

### 6-2. Offerings 연결
- Offering `cloud`: monthly package -> `cloud_monthly`
- Offering `report`: monthly package -> `report_monthly`

---

## 7. 앱 실행/검증

앱 실행 키:
- Android는 반드시 RevenueCat Android Public SDK key 사용
- 예시:
  - `--dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx`

검증 항목:
1. Paywall에서 상품이 표시되는지
2. 구매 후 플랜이 Free -> Cloud/Report로 바뀌는지
3. 복원이 동작하는지
4. 로그아웃/로그인 시 계정별 플랜 반영이 맞는지

---

## 8. 자주 헷갈리는 질문

### Q1. GCP에서 어떤 API "키"를 만들어야 하나요?
A. API key가 아니라 API를 "사용 설정"해야 합니다.  
그리고 RevenueCat에는 서비스 계정 JSON 키를 업로드합니다.

### Q2. 서비스 계정 생성 시 `권한(선택사항)`에서 역할 줘야 하나요?
A. 그 단계는 비워도 됩니다.  
실제 핵심은 Play Console `사용자 및 권한`에서 부여하는 권한입니다.

### Q3. RevenueCat Test Store로도 같은 연동이 필요한가요?
A. Test Store만 쓸 때는 불필요할 수 있습니다.  
실제 Play 결제/복원 테스트를 하려면 본 문서 절차가 필요합니다.

---

## 9. 운영 체크리스트 (복붙용)

- [ ] Play 구독 `cloud_monthly` 생성
- [ ] Play 구독 `report_monthly` 생성
- [ ] 두 구독 모두 base plan `monthly` 생성/활성화
- [ ] GCP API 2개 활성화
- [ ] 서비스 계정 생성 + JSON 키 발급
- [ ] Play Console 사용자/권한에 서비스 계정 이메일 추가
- [ ] RevenueCat Apps & providers에 JSON 업로드
- [ ] RevenueCat Products에서 Import 성공
- [ ] Entitlement/Offering 연결 완료
- [ ] 앱에서 `RC_ANDROID_PUBLIC_SDK_KEY`로 실구매 테스트
