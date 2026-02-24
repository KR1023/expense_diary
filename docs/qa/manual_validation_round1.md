# Manual Validation Round 1 (RevenueCat + Backup/Restore + Report Export)

기준일: 2026-02-23  
목적: EPIC 1~3의 핵심 사용자 플로우를 실기기/테스트 계정으로 검증

이 문서는 현재 구현된 기능의 "실동작 검증 라운드" 체크리스트입니다.

## 1) 범위

- RevenueCat
  - Paywall 오퍼링 로드
  - 구매 / 복원
  - 로그인/로그아웃 시 플랜 갱신
- 광고 게이트
  - Free: 광고 표시
  - Cloud/Report: 광고 비표시
- 백업/복원 (Firestore)
  - 스냅샷 업로드/목록/다운로드
  - Free 주 1회 제한
  - 전체 덮어쓰기 복원
- Report 기능
  - 통계 화면 진입/값 표시
  - CSV 생성/공유
  - PDF 생성/공유

## 2) 사전 준비

### 테스트 계정

- Firebase Auth 테스트 계정 3개 권장
  - `free_test@...`
  - `cloud_test@...`
  - `report_test@...`
- Google 로그인 테스트 계정(선택)

### RevenueCat 설정 확인

- Entitlement IDs
  - `cloud`
  - `report`
- Offering IDs (기본값 기준)
  - `cloud`
  - `report`
- 앱 실행 시 `dart-define` 설정

```bash
flutter run \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=xxx \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=xxx \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud \
  --dart-define=RC_OFFERING_REPORT=report
```

### Firebase/Firestore 확인

- Firestore Rules가 `users/{uid}/...` 경로 접근 허용인지 확인
- 테스트용 데이터 경로 예상
  - 백업 스냅샷: `users/{uid}/snapshots/{snapshotId}`
  - 클라우드 거래(기존 테스트 화면): `users/{uid}/transactions/{txId}`

## 3) 검증 매트릭스 (핵심)

### A. Free 계정

- 기대 플랜: `Free`
- 기대 동작:
  - 광고 표시됨
  - Cloud 기능 진입 시 Paywall 유도
  - Report 기능 진입 시 Paywall 유도
  - 백업: 같은 KST 주차 1회만 허용
  - 복원: 무제한 허용

### B. Cloud 계정

- 기대 플랜: `Cloud`
- 기대 동작:
  - 광고 숨김
  - Cloud 기능 진입 허용
  - Report 기능 진입 시 Paywall 유도
  - 백업 무제한
  - 복원 무제한

### C. Report 계정

- 기대 플랜: `Report`
- 기대 동작:
  - 광고 숨김
  - Cloud/Report 기능 모두 허용
  - 통계/CSV/PDF 화면 진입 및 생성 가능
  - 백업 무제한
  - 복원 무제한

## 4) 테스트 시나리오 상세

### 4-1. 로그인/로그아웃 + 플랜 갱신

1. 앱 실행 (비로그인)
2. 설정 탭 진입
3. 기대 결과
   - 구독 타일에 `구독 업그레이드`
   - 광고 표시(Free)
4. 로그인 (Free 계정)
5. 기대 결과
   - 현재 플랜 `Free`
   - 광고 유지
6. 로그아웃
7. 기대 결과
   - 플랜 `Free` 유지(비로그인 fallback)
   - 크래시 없음

확인 포인트:
- `AuthRepository` 로그인/로그아웃 시 `SubscriptionService` 연동이 끊기지 않는지
- RevenueCat 실패 시에도 로그인 자체는 성공하는지

### 4-2. Paywall 오퍼링/구매/복원

1. Free 계정 로그인
2. 설정 탭 > `구독 업그레이드` > Paywall 진입
3. 기대 결과
   - Cloud/Report 카드 표시
   - 오퍼링 미설정 시에도 크래시 없이 안내 문구 표시
4. Cloud 구매 (Sandbox/Test 구매)
5. 기대 결과
   - 구매 성공 Snackbar
   - 설정 화면 복귀 후 플랜이 `Cloud`
   - 광고 즉시 숨김
6. 로그아웃/재로그인 또는 별도 기기에서 `구매 복원`
7. 기대 결과
   - 플랜 복원됨
   - 광고 숨김 유지

### 4-3. 광고 게이트 (AdGate)

확인 화면:
- 홈
- 카테고리
- 설정

체크:
- Free 계정: 배너 노출
- Cloud/Report 계정: 배너 미노출
- 플랜 변경 직후 화면 재진입 없이도 반영되는지(설정 화면부터 우선 확인)

### 4-4. 백업 (Free 주 1회 제한 / Cloud+ 무제한)

사전 준비:
- 로그인 상태
- 로컬 데이터(지출/카테고리) 몇 개 생성

#### Free 계정

1. 설정 탭 > `클라우드 백업` 카드 확인
2. 기대 결과
   - `이번 주 남은 백업 1/1` (초기 상태 기준)
3. `지금 백업`
4. 기대 결과
   - 성공 Snackbar
   - `마지막 백업` 시각 업데이트
   - `이번 주 남은 백업 0/1`
5. 같은 주차에서 다시 `지금 백업`
6. 기대 결과
   - 차단 안내 메시지
   - Firestore 스냅샷 추가 생성되지 않음

#### Cloud/Report 계정

1. `지금 백업` 연속 2회 실행
2. 기대 결과
   - 둘 다 성공
   - `이번 주 백업: 무제한`
   - Firestore에 스냅샷 2건 이상 누적

Firestore 콘솔 확인:
- `users/{uid}/snapshots` 문서 생성 여부
- 필드 존재 여부
  - `snapshotId`, `createdAt`, `schemaVersion`, `appVersion`, `dataHash`, `sizeBytes`, `payload`

### 4-5. 복원 (모든 플랜 무제한)

1. 로그인 상태에서 백업 1개 이상 존재 확인
2. 설정 탭 > `클라우드 백업` 카드 > `스냅샷 목록 / 복원`
3. 기대 결과
   - 스냅샷 목록 로드됨
4. 스냅샷 선택 > 복원 버튼
5. 경고 다이얼로그에서 `전체 덮어쓰기 복원`
6. 기대 결과
   - 복원 성공 Snackbar
   - 설정 화면 복귀
   - 홈/캘린더/카테고리 데이터가 스냅샷 기준으로 반영

추가 검증:
- 복원 전에 로컬 데이터 일부 변경 후 복원했을 때 변경 내용이 덮어쓰기되는지
- 복원 후 통화 설정(`KRW`/`USD`) 반영되는지

### 4-6. Report 통계 화면 (Report 전용)

1. Free 또는 Cloud 계정으로 설정 탭 > `Report 통계`
2. 기대 결과
   - Paywall로 유도
3. Report 계정으로 동일 진입
4. 기대 결과
   - 통계 화면 진입 성공
   - 월 선택 가능
   - 월별 총 지출 값이 홈/캘린더 데이터와 대략 일치
   - 카테고리 TOP 리스트/차트 값 일치

주의:
- 현재 총 수입은 SQLite 스키마 제한으로 `0` 표시가 정상

### 4-7. CSV 다운로드 (Report 전용)

1. Free/Cloud 계정에서 `CSV 보고서 다운로드` 진입
2. 기대 결과
   - Paywall
3. Report 계정에서 진입
4. 월/기간 선택 후 `CSV 생성`
5. 기대 결과
   - 파일 생성 성공
   - 결과 영역에 경로/행 수 표시
6. `공유`
7. 기대 결과
   - OS 공유 시트/공유 플로우 정상 표시

CSV 내용 샘플 확인:
- 헤더 존재
- row count가 화면 표시와 일치
- 날짜/금액/카테고리/메모 값 정상

### 4-8. PDF 다운로드 (Report 전용)

1. Free/Cloud 계정에서 `PDF 보고서 다운로드` 진입
2. 기대 결과
   - Paywall
3. Report 계정에서 진입
4. 월 선택 후 `PDF 생성`
5. 기대 결과
   - 파일 생성 성공
   - 결과 영역에 경로/건수/크기 표시
6. `공유`
7. 기대 결과
   - OS 공유 시트 표시
8. PDF 열어서 확인
9. 기대 결과
   - 최소 템플릿(월간 요약 / 카테고리 TOP / 거래 리스트) 렌더링
   - 한글 거래명/카테고리/메모가 깨지지 않는지 확인

폰트 관련 참고:
- 현재 PDF 서비스는 한글 폰트를 다음 순서로 탐색
  1. 앱 asset (`asset/fonts/NotoSansKR-Regular.ttf` or `assets/fonts/...`)
  2. `PDF_KR_FONT_PATH` 환경변수
  3. macOS `AppleGothic.ttf`
  4. 기본 폰트 fallback

## 5) 실패 시 우선 점검 포인트

### RevenueCat

- `dart-define` 키 누락 여부
- Offering/Entitlement ID가 코드 기본값(`cloud`, `report`)과 일치하는지
- Store sandbox 계정/테스트 카드 상태

### Firestore 백업/복원

- Firebase 로그인 상태
- Firestore Rules (`users/{uid}/snapshots/*`)
- 네트워크 상태
- payload 크기(문서 최대 크기 한계 근접 여부)

### CSV/PDF 공유

- 플랫폼 공유 시트 권한/OS 제약
- 생성 파일 경로 접근 가능 여부
- `share_plus` 플러그인 플랫폼 설정 누락 여부

## 6) 실행 결과 기록 템플릿

### 테스트 정보

- 기기/OS:
- 앱 빌드:
- Firebase 프로젝트:
- RevenueCat 프로젝트:
- 테스트 날짜:

### 결과 요약

- [ ] Free 플로우 통과
- [ ] Cloud 플로우 통과
- [ ] Report 플로우 통과
- [ ] 백업/복원 Firestore 실동작 확인
- [ ] CSV 생성/공유 확인
- [ ] PDF 생성/공유 확인

### 이슈 기록

- 항목:
- 재현 절차:
- 기대 결과:
- 실제 결과:
- 로그/스크린샷:

## 7) 현재 알려진 구현 메모 (검증 시 참고)

- `Report 통계`의 총 수입은 현재 SQLite 스키마 제약으로 `0`이 정상
- Free 백업 주 1회 제한은 현재 로컬(`SharedPreferences`) 기준
  - 기기 변경 시 주간 제한 일관성은 아직 클라우드 동기화 미구현
- `ConfigScreen`에 기존 lint info 1건(`use_build_context_synchronously`) 남아 있으나 기능 동작과 직접 무관

