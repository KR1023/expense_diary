# 구독(Free / Cloud / Report) 테스트 가이드

이 문서는 현재 프로젝트의 구독 기능(RevenueCat + Paywall + 플랜 권한)을 테스트하는 방법을 정리한 운영/QA 문서입니다.

대상 범위:
- Free / Cloud / Report 플랜별 동작 검증
- Test Store 기반 1차 검증
- 실제 스토어(Play / App Store Sandbox) 기반 검증
- 플랜 변경(업그레이드/복원/로그아웃) 검증

관련 문서:
- `docs/revenueCat.md` (RevenueCat 설정/연동 방법)
- `docs/qa/manual_validation_round1.md` (수동 검증 체크리스트)

## 1. 현재 플랜 규칙 요약 (테스트 기준)

현재 앱의 플랜/권한 규칙:

- `Free`
  - 광고 표시
  - 클라우드 백업 주 1회 (KST 기준)
  - 클라우드 복원 무제한
- `Cloud`
  - Free 포함
  - 백업/복원 무제한
  - 광고 제거
- `Report`
  - Cloud 포함
  - 통계 기능 접근 가능
  - 보고서 다운로드(CSV/PDF) 가능
  - 광고 제거

Entitlement -> Plan 매핑 우선순위:
- `report` 활성 -> `Report`
- 아니고 `cloud` 활성 -> `Cloud`
- 둘 다 아니면 -> `Free`

## 2. 테스트 전 준비 (필수)

## 2-1. 앱/환경 준비

- RevenueCat 대시보드 설정 완료
  - Entitlements: `cloud`, `report`
  - Offerings: `cloud`, `report`
  - Products: `cloud_monthly`, `report_monthly` (예시)
- Firebase Auth 로그인 가능 상태
- Firebase 백업 테스트를 할 경우 Firestore 권한/연결 정상
- 앱 실행 시 RevenueCat 키가 `--dart-define`로 주입됨

확인 포인트:
- 앱 실행 후 `RevenueCat 비활성` 메시지가 보이지 않아야 함

## 2-2. 실행 방법 (권장)

### 터미널 스크립트 사용

프로젝트에 추가된 스크립트:
- `scripts/run_with_revenuecat.sh`

Test Store 기반 1차 테스트:
```bash
RC_TEST_STORE_KEY=test_xxx bash scripts/run_with_revenuecat.sh
```

실스토어 키 테스트:
```bash
RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx \
RC_IOS_PUBLIC_SDK_KEY=appl_xxx \
bash scripts/run_with_revenuecat.sh
```

### Android Studio 사용

- `Edit Configurations...`
- Flutter Run Configuration 선택
- `Additional run args`에 `--dart-define=...` 설정

Test Store 설정 예시는 `docs/revenueCat.md` 참고

## 2-3. 테스트 데이터/계정 전략 (권장)

권장 방법 1 (가장 단순):
- 테스트 계정 1개로 순차 테스트
- Free -> Cloud -> Report -> 로그아웃/복원

권장 방법 2 (더 깔끔함):
- 테스트 계정 3개 사용
  - 계정 A: Free 전용
  - 계정 B: Cloud 테스트
  - 계정 C: Report 테스트

장점:
- 상태 꼬임(이전 구매/복원 영향) 감소

## 3. 1차 테스트 (Test Store 기반)

목적:
- 결제 시스템 연동/플로우/권한 반영/UI 동작 확인
- 실제 Play/App Store 결제 검증 전 빠른 확인

주의:
- Test Store는 실제 스토어 결제를 대체하지 않습니다.
- 최종 릴리스 전에는 반드시 Play / App Store Sandbox로 재검증해야 합니다.

## 3-1. 공통 시작 체크

1. 앱 실행
2. 설정 화면 이동
3. `구독 업그레이드`(Paywall) 진입
4. 확인:
- `RevenueCat 비활성` 메시지 없음
- Cloud / Report 상품 카드 또는 상품 정보 표시

실패 시:
- `docs/revenueCat.md`의 RevenueCat / Apps & providers / API key 설정 다시 확인

## 4. Free 플랜 테스트

Free는 "기본 상태"입니다. 아래 방법 중 하나로 진입합니다.

Free 상태로 만드는 방법:
- 로그아웃 상태로 앱 사용
- 로그인 상태이지만 `cloud`, `report` entitlement 없는 계정 사용

## 4-1. Free 플랜 확인 항목 (핵심)

기대 결과:
- 광고 표시됨
- Cloud 기능 접근 시 Paywall 유도
- Report 기능 접근 시 Paywall 유도
- 클라우드 백업은 주 1회만 허용
- 복원 기능은 접근 가능 (무제한)

확인 포인트:
- 설정/홈 등 광고 위치에서 배너가 렌더링되는지
- `고급 통계 / 보고서` 진입 시 Paywall로 이동되는지
- Cloud 관련 진입 시 Paywall로 이동되는지

## 4-2. Free 백업 제한 (주 1회) 테스트

사전 조건:
- 로그인 상태(백업은 사용자 uid 필요)
- Firestore 연결 정상

절차:
1. Free 상태로 로그인
2. 설정 > 백업 카드에서 백업 실행 (1회차)
3. 성공 메시지 및 마지막 백업 시각 표시 확인
4. 같은 주(KST 기준) 안에서 다시 백업 실행 (2회차)

기대 결과:
- 1회차: 성공
- 2회차: 차단 + 안내 메시지
- Free 표시 영역에 `이번 주 남은 백업 0/1`

테스트 리셋 팁:
- 현재 구현은 주간 제한 상태를 로컬에 저장합니다 (`lastBackupAt`, `lastBackupWeekKey`)
- 같은 주에 재테스트가 필요하면:
  - 앱 데이터 삭제/재설치
  - 다른 테스트 계정 사용
  - 다음 주(KST)까지 대기

## 5. Cloud 플랜 테스트

Cloud 상태로 만드는 방법:
- Paywall에서 Cloud 상품 구매 (Test Store)
- 또는 기존 Cloud entitlement가 있는 테스트 계정 로그인

## 5-1. Cloud 구매/반영 테스트

절차:
1. Free 상태에서 Paywall 진입
2. Cloud 상품 구매
3. 구매 성공 후 Paywall 종료 또는 화면 복귀

기대 결과:
- 플랜이 `Cloud`로 갱신됨 (내부적으로 `SubscriptionService.refreshPlan()`)
- 광고가 즉시 사라짐 (`AdGate`)
- Cloud 기능 접근 가능
- Report 기능은 여전히 Paywall 유도

UI 기반 확인 포인트:
- 광고 영역이 더 이상 렌더링되지 않음
- 설정의 Report 기능 진입 시 여전히 Paywall

## 5-2. Cloud 백업 무제한 테스트

절차:
1. Cloud 상태 확인
2. 설정 > 백업 실행 (1회차)
3. 바로 다시 백업 실행 (2회차)

기대 결과:
- 1회차/2회차 모두 성공
- Free의 주간 제한 메시지가 표시되지 않음
- `이번 주 백업: 무제한` 또는 동등한 안내

## 5-3. Cloud 복원 테스트

절차:
1. Cloud 상태에서 스냅샷 목록 진입
2. 복원할 스냅샷 선택
3. 경고 다이얼로그 확인 후 복원

기대 결과:
- 복원 성공
- 로컬 데이터(캘린더/리스트/합계)가 갱신됨

참고:
- 복원은 모든 플랜에서 가능하므로, Cloud 전용 기능 검증이라기보다 "Cloud에서도 정상 동작" 확인 목적

## 6. Report 플랜 테스트

Report 상태로 만드는 방법:
- Paywall에서 Report 상품 구매 (Test Store)
- 또는 기존 Report entitlement가 있는 테스트 계정 로그인

## 6-1. Report 구매/반영 테스트

절차:
1. Free 또는 Cloud 상태에서 Paywall 진입
2. Report 상품 구매
3. 성공 후 화면 복귀

기대 결과:
- 플랜이 `Report`로 갱신됨
- 광고 비노출 유지
- Cloud 기능 포함 + Report 기능 활성화

## 6-2. Report 전용 통계 화면 테스트

절차:
1. 설정 > `고급 통계` 진입
2. 월 선택 변경
3. 차트/리스트 확인

기대 결과:
- Paywall로 가지 않고 통계 화면 진입 성공
- 월별 지출 합계 / 카테고리 TOP 리스트 표시
- 로컬 SQLite 데이터와 값이 대략 일치

주의:
- 현재 스키마상 수입 데이터가 없으면 수입 합계는 `0`으로 표시될 수 있음 (현재 구현 정상)

## 6-3. Report 전용 CSV 다운로드 테스트

절차:
1. 설정 > 보고서(CSV) 내보내기 진입
2. 기간 선택 (월 또는 사용자 지정 기간)
3. CSV 생성/저장/공유 실행

기대 결과:
- Paywall 없이 진입
- CSV 파일 생성 성공
- 공유 시트 또는 저장 동작 실행

## 6-4. Report 전용 PDF 다운로드 테스트

절차:
1. 설정 > 보고서(PDF) 내보내기 진입
2. 월 선택
3. PDF 생성/공유 실행

기대 결과:
- Paywall 없이 진입
- PDF 파일 생성 성공
- 공유 동작 실행

추가 확인:
- 한글 데이터가 있는 경우 폰트 렌더링 상태 확인

## 7. 플랜 전환/복원 테스트 (중요)

구독 기능은 "구매 자체"보다 "상태 전환이 즉시 반영되는지"가 중요합니다.

## 7-1. 로그인/로그아웃 전환 테스트

절차:
1. Cloud 또는 Report 상태 계정으로 로그인
2. 광고/권한 상태 확인
3. 로그아웃

기대 결과:
- 로그아웃 후 플랜이 `Free`로 폴백
- 광고 다시 표시
- Report/Cloud 기능 진입 시 Paywall 유도

## 7-2. 복원(Restore) 테스트

절차:
1. 구매 이력이 있는 계정 상태 준비
2. Paywall에서 `Restore` 실행

기대 결과:
- 복원 성공 시 플랜 갱신
- 권한(광고/기능 접근) 즉시 반영

테스트 케이스:
- Cloud 구매 계정 -> Restore 후 Cloud 반영
- Report 구매 계정 -> Restore 후 Report 반영

## 7-3. 업그레이드 경로 테스트 (Cloud -> Report)

절차:
1. Cloud 상태 확인
2. Paywall에서 Report 구매
3. 구매 성공 후 상태 확인

기대 결과:
- 최종 플랜은 `Report`
- Report 기능 접근 가능
- 광고 비노출 유지

## 8. 실제 스토어 테스트 (Play / App Store Sandbox)

Test Store 1차 검증 이후 반드시 수행 권장:

- Android: Play Console 내부 테스트/닫힌 테스트 + 테스터 계정
- iOS: App Store Sandbox Tester 계정

검증 목적:
- 실제 결제 팝업/구매 완료/복원
- 스토어 영수증 처리
- RevenueCat entitlement 반영
- 앱의 권한 반영

현재 프로젝트에서 확인할 대표 결과:
- 구매 성공 후 광고 즉시 숨김
- Report 구매 후 통계/CSV/PDF 진입 가능
- 로그아웃 후 Free 폴백
- Restore 후 원래 플랜 복구

## 9. 문제 발생 시 확인 순서 (빠른 트러블슈팅)

1. 앱에서 `RevenueCat 비활성` 메시지가 보이는지 확인
- 보이면 `dart-define` 누락/오타 가능성 높음

2. Paywall에 상품이 보이는지 확인
- 안 보이면 RevenueCat `Offerings` / package 연결 확인

3. 구매 후 플랜이 안 바뀌는지 확인
- RevenueCat `Entitlements` 연결 확인 (`cloud`, `report`)
- 로그인 사용자(uid) 상태 확인

4. 실제 스토어 구매가 실패하는지 확인
- Play/App Store 테스트 계정/트랙/상품 활성화 상태 확인
- RevenueCat `Apps & providers` provider 연결 상태 확인

## 10. 결과 기록 템플릿 (권장)

테스트 실행 시 아래 형식으로 기록하면 재현/수정이 쉬워집니다.

- 테스트 일시:
- 플랫폼/기기:
- RevenueCat 키 종류: `Test Store` / `Android Public` / `iOS Public`
- 로그인 계정(Firebase uid 또는 식별 가능한 별칭):
- 테스트 플랜: `Free` / `Cloud` / `Report`
- 수행 절차:
- 기대 결과:
- 실제 결과:
- 스크린샷/영상:
- 비고 (오류 메시지/로그):

## 11. 추천 테스트 순서 (처음 한 번)

1. Test Store로 `Free -> Cloud -> Report` UI/플로우 검증
2. Free 주 1회 백업 제한 검증
3. Cloud 백업 무제한 검증
4. Report 통계/CSV/PDF 접근 검증
5. 로그아웃 후 Free 폴백 검증
6. Restore 검증
7. Play / App Store Sandbox 실구매 검증

