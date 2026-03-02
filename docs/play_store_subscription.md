# Google Play 정기 결제(구독) 생성 가이드

이 문서는 Play Console에서 `정기 결제`를 만들 때 필요한 입력값을 현재 프로젝트(ExpenseDiary) 기준으로 정리한 문서입니다.

관련 문서:
- `docs/play_store_seller.md` (판매자 프로필/결제 프로필/Base plan 개념)
- `docs/revenueCat.md` (RevenueCat 연결/Import/Entitlement/Offering)

## 1. 생성할 구독 ID (권장)

- Cloud 월간: `cloud_monthly`
- Report 월간: `report_monthly`

원칙:
- `제품 ID`는 나중에 변경이 어렵거나 불가
- 영문 소문자 + 숫자 + `_` 조합 권장

## 2. Play Console 경로

1. `Play를 통한 수익 창출`
2. `제품`
3. `정기 결제`
4. `구독 만들기`

참고:
- UI에서 `구독` 대신 `정기 결제`로 보일 수 있음

## 3. 구독 만들기 화면 입력값

예시 1) Cloud
- `제품 ID`: `cloud_monthly`
- `이름`: `Cloud Monthly` (사용자 표시명)

예시 2) Report
- `제품 ID`: `report_monthly`
- `이름`: `Report Monthly`

주의:
- `제품 ID`와 `이름`은 다름
- `제품 ID`는 시스템 식별자, `이름`은 사용자 표시명

## 4. 기본 요금제(Base plan) 추가

구독 생성 후 `기본 요금제 추가` 화면에서 아래처럼 설정:

- `기본 요금제 ID`: `monthly` 권장
- `유형`: `자동 갱신` 선택
- `기간`: `1개월`
- `태그`: 선택(비워도 됨, 쓰면 `monthly` 정도 권장)

주의:
- `기본 요금제 ID`도 나중에 변경이 어렵거나 불가
- 대문자/형식 오류가 나면 소문자 ID(`monthly`)로 입력

## 5. 생성 후 필수 작업

1. 가격 설정
2. 판매 국가/지역 설정
3. 활성화(테스트 가능한 상태)

테스트 전 확인:
- 테스트 트랙(내부/비공개)에 AAB 릴리스가 게시 상태인지
- 테스터 계정이 등록되어 있는지

## 6. RevenueCat 매핑 규칙

Play Console에서 아래를 만든 뒤 RevenueCat에 동일하게 연결:

- Product ID: `cloud_monthly`, `report_monthly`
- Base plan ID: `monthly`

권장:
- RevenueCat `Products`에서 수동 입력보다 `Import Products` 사용

## 7. 빠른 체크리스트

- [ ] `cloud_monthly` 생성
- [ ] `report_monthly` 생성
- [ ] 두 구독 모두 Base plan `monthly` 생성
- [ ] 자동 갱신 + 1개월로 설정
- [ ] 가격/국가 설정 및 활성화
- [ ] RevenueCat에서 Import 또는 동일 ID로 연결
