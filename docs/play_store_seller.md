# Google Play 판매자 프로필 / 구독 상품 설정 메모 (ExpenseDiary)

이 문서는 현재 프로젝트에서 `Google Play 실제 구독 테스트`를 시작하기 전에 필요한 판매자 프로필/구독 상품/RevenueCat 연결 관련 내용을 정리한 메모입니다.

관련 문서:
- `docs/revenueCat.md` (RevenueCat 전체 설정 가이드)
- `docs/how_to_test.md` (구독 테스트 절차)

## 1. 언제 판매자 프로필 설정이 필요한가?

- `RevenueCat Test Store`만 테스트할 때: 보통 불필요
- `Google Play 실제 구독 테스트`(내부 테스트 포함)할 때: 필요

이유:
- Play Console에서 실제 `구독(Subscription)`과 `Base plan`을 만들어야 하고
- 이 과정에서 판매자 계정/결제 프로필 설정이 요구될 수 있음

## 2. 개인(법인 아님) 판매자 프로필 작성 가이드

`공개 판매자 프로필` 작성 시 핵심은 `실제 연락 가능한 정보`와 `사용자가 결제 내역에서 알아볼 수 있는 이름`입니다.

### 2-1. 주요 입력 항목 (개인 기준)

- `업체명`
  - 개인이면 `본인 실명`, `상호(있으면)`, 또는 `브랜드명` 사용 가능
  - 예: `ExpenseDiary`, `홍길동`, `홍길동(ExpenseDiary)`
- `웹사이트 (선택)`
  - 없으면 비워도 됨
  - 있으면 앱 소개/문의 페이지 권장
- `판매하는 제품 및 서비스`
  - 앱/구독 성격에 맞는 항목 선택
  - 예: 소프트웨어/디지털 서비스 계열
- `고객지원 이메일`
  - 실제로 확인 가능한 이메일 필수
- `신용카드 명세서 이름`
  - 카드 명세서에 표시되는 이름(사용자가 결제 내역에서 알아볼 수 있어야 함)
  - 앱 하나 전용 이름보다 브랜드/운영자 공통명 권장
  - 예: `EXPENSEDIARY`, `YSH APPS`

### 2-2. 신용카드 명세서 이름 관련 메모

- 보통 나중에 변경 가능
- 과거 결제 명세서 기록까지 바뀌는 것은 아님 (이후 결제부터 반영되는 것으로 보는 것이 안전)
- 같은 `판매자 프로필(결제 프로필)`을 쓰는 본인 다른 앱들에도 공통으로 사용될 수 있음

## 3. Base plan ID란?

`Base plan ID`는 Google Play Console에서 구독 상품 내부의 Base plan을 만들 때 직접 정하는 값입니다.

즉:
- 외부에서 발급받는 값 X
- Play Console에서 생성/입력한 값을 RevenueCat에 그대로 입력 O

예시:
- `monthly`
- `p1m`

## 4. Base plan ID는 어디서 만들고 확인하나요?

일반적인 경로:
1. `Google Play Console`
2. 앱 선택
3. `수익 창출(Monetize)` -> `구독(Subscriptions)`
4. 구독 상품 선택 (예: `cloud_monthly`)
5. `Base plans and offers` (또는 유사 이름)
6. `Create base plan` 시 `Base plan ID` 입력
7. 저장 후 RevenueCat에 동일 값 입력

주의:
- Base plan을 아직 안 만들었으면 RevenueCat에 넣을 `Base plan ID`도 없음
- 먼저 Play Console에서 구독 + Base plan 생성 필요

## 5. RevenueCat Play Store Product 입력 규칙 (핵심)

RevenueCat `Product catalog > Products > ExpenseDiary (Play Store) > + New` 화면에서:

- `Subscription` 필드
  - `Cloud` 같은 표시명이 아니라 **Play Console 구독 상품 ID**
  - 예: `cloud_monthly`, `report_monthly`
- `Base plan ID` 필드
  - **Play Console Base plan ID**
  - 예: `monthly`

중요:
- ID 값은 1글자라도 다르면 안 됨 (대소문자/언더스코어 포함)

권장:
- 수동 입력보다 `Import Products` 사용 (오타 방지)

## 6. 실제 Play 구독 테스트 시작 전 체크리스트 (요약)

1. Play Console 준비
- 앱 생성 완료
- 판매자 계정/결제 프로필 설정 완료
- 패키지명 확인 (`com.ysh.expense_diary`)

2. Play 구독 상품 준비
- 구독 생성: `cloud_monthly`, `report_monthly`
- Base plan 생성: 예) `monthly`
- 가격/판매국가 설정
- 테스트 가능한 상태로 활성화

3. 테스트 배포
- `Internal testing` 트랙에 AAB 업로드
- 테스터 계정 등록
- 테스트 링크로 설치

4. RevenueCat 연결
- Android 앱 + Google Play provider 연결 완료
- Play 상품 `Import`
- Entitlements 연결 (`cloud`, `report`)
- Offerings 연결 (`cloud`, `report`)

5. 앱 실행
- `RC_ANDROID_PUBLIC_SDK_KEY`에 Android Public SDK key 사용
- `Test Store` 키가 아닌지 확인

## 7. Test Store와 실제 Play Store 테스트 차이 (중요)

- `RevenueCat Test Store`
  - RevenueCat 내부 테스트용
  - 실제 Play 결제/해지 화면과 다름
  - 앱의 `구독 해지 / 관리` 버튼이 실질적으로 동작하지 않을 수 있음
- `실제 Play Store 테스트` (내부 테스트)
  - 실제 스토어 구매/복원/구독 관리 화면 검증 가능

현재 앱 메모:
- `구독 해지 / 관리` 버튼은 스토어 구독 관리 화면을 여는 방식
- 테스트 스토어/지원 안 되는 환경에서는 안내 메시지를 보여주도록 구현됨

## 8. 운영 팁

- 판매자 프로필의 `신용카드 명세서 이름`은 앱 하나 전용 이름보다 `브랜드/운영자 공통명`이 안전함
- RevenueCat `Play Store Product`는 수동 입력보다 `Import Products` 우선
- 실제 결제 검증 전에는 `RevenueCat Test Store`로 UI/플로우부터 검증하면 시간 절약 가능
