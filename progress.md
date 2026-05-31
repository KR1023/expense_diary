# 개발 진행 사항

## 최근 작업 내역

---

### 1. 클라우드 백업 — Firebase Storage 전환 (`9a9e98a`)

**배경**
Firestore 문서 1MB 제한으로 인해 데이터가 늘어날수록 백업 실패 가능성이 있었음.

**변경 내용**
- 백업 페이로드(JSON)를 Firestore 문서 인라인 저장 → Firebase Storage(`users/{uid}/snapshots/{id}.json`)로 전환
- Firestore에는 메타데이터 + `payloadStoragePath` 필드만 저장
- 복원 시 `payloadStoragePath` 유무로 신/구 포맷 자동 구분 (하위 호환 유지)
- Firebase Storage 보안 규칙: 인증된 사용자가 자신의 경로만 읽기/쓰기 가능

**관련 파일**
- `lib/features/backup/data/firebase_snapshot_repository.dart`
- `lib/features/backup/domain/snapshot.dart`

---

### 2. RevenueCat 구독 재통합 (`6c6d7d8`)

**배경**
이전에 구독 서비스를 제거한 상태에서 재통합. Android 전용(iOS는 사업자 등록 후 추가 예정).

**플랜 구성**

| 플랜 | 기능 |
|---|---|
| Free (비구독) | 주 1회 백업, 일 1회 복원, 광고 표시 |
| Cloud 플랜 | 광고 제거, 무제한 백업/복원 |
| Report 플랜 | Cloud 플랜 포함 + 통계/CSV/PDF 내보내기 |

**변경 내용**
- `SubscriptionService`: RevenueCat SDK 초기화, 엔타이틀먼트 상태 관리 (`ChangeNotifier`)
- `RevenueCatConfig`: API 키 및 엔타이틀먼트 ID를 `--dart-define`으로 주입
- `PaywallScreen`: 플랜별 구독 화면
- `StatisticsTabScreen`: `report` 엔타이틀먼트 게이트 (잠금 아이콘)
- `BannerAdWidget`: 구독 시 광고 자동 숨김 (`AnimatedBuilder` 반응형)
- 무료 사용자 제한:
  - 백업: KST 주차 기준 주 1회 (`lastBackupWeekKey`)
  - 복원: KST 자정 기준 일 1회 (`lastRestoreDayKey`)
  - 설정 화면에 다음 가능 일시 표시

**Android Studio 실행 설정**
- `main.dart`: 프로덕션 키
- `main.dart (Force Entitled)`: UI 테스트용 (모든 기능 강제 활성화)

**관련 파일**
- `lib/const/revenuecat_config.dart`
- `lib/core/subscription/subscription_service.dart`
- `lib/screen/paywall_screen.dart`
- `lib/screen/subscription_screen.dart`
- `lib/screen/statistics_tab_screen.dart`
- `lib/screen/config_screen.dart`
- `lib/component/banner_ad_widget.dart`
- `.idea/runConfigurations/`

---

### 3. UX 개선 — 토스트 및 확인 팝업 (`75997d3`)

**변경 내용**
- 로그인 성공 시 토스트 표시 (모든 로그인 진입점 공통)
- 로그아웃 시 확인 팝업 (구독 기능 제한 안내 문구 포함)
- 구독 완료 시 토스트 표시
- 구독 버튼 탭 시 비로그인이면 로그인 화면 먼저 진입 (iOS 제외)

---

### 4. RevenueCat — Firebase UID 연동 (`5d60c46`)

**배경**
기존에는 RevenueCat이 기기별 익명 ID로 구독을 관리하여 기기 교체 시 구독 인식 불가.

**변경 내용**
- Firebase 로그인 시 `Purchases.logIn(uid)` → 구독이 Firebase 계정에 귀속
- Firebase 로그아웃 시 `Purchases.logOut()` → 익명 상태로 전환, 엔타이틀먼트 즉시 비활성화
- 앱 시작 시 이미 로그인된 상태면 즉시 UID 연동
- 익명 구독이 있는 경우 `logIn()` 호출 시 RevenueCat이 자동 병합

**동작 요약**

| 상황 | 결과 |
|---|---|
| 로그인 | 해당 계정의 구독 상태 즉시 적용 |
| 로그아웃 | 모든 구독 기능 차단 |
| 기기 교체 후 로그인 | 구독 자동 복원 |
| 여러 기기 동시 사용 | 동일 계정이면 모두 동일 구독 상태 |

**관련 파일**
- `lib/core/subscription/subscription_service.dart`
- `lib/main.dart`

---

### 5. iOS 구독 임시 처리 (`34ff237`)

**배경**
iOS는 사업자 등록 전으로 App Store 구독 불가. 구독 관련 기능 클릭 시 크래시 발생.

**변경 내용**
- iOS에서 RevenueCat SDK 미초기화 유지 (크래시 방지)
- `isCloudEntitled` / `isReportEntitled`에서 `Platform.isIOS` 제거 → iOS도 Free 플랜으로 동작
- `PaywallScreen`: iOS에서 결제 UI 대신 "준비 중" 안내 화면 표시
- 구독 버튼 진입 시 iOS는 로그인 요구 없이 바로 "준비 중" 화면으로 이동

**iOS 현재 동작**

| 기능 | iOS |
|---|---|
| 광고 | 표시됨 (Free) |
| 백업/복원 | 주 1회 / 일 1회 제한 (Free) |
| 통계/리포트 | 잠금 아이콘 → 탭 시 "준비 중" |
| 구독하기 버튼 | "준비 중" 안내 |

**iOS App Store 연동 시 해야 할 작업** (`docs/revenue_cat/ios_setup.md` 참고)
1. 사업자 등록 완료
2. App Store Connect 구독 상품 등록
3. Shared Secret / API Key 발급
4. RevenueCat iOS 앱 추가 및 상품 연결
5. `SubscriptionService._configure()`의 iOS 예외 제거

---

## 문서

| 파일 | 내용 |
|---|---|
| `docs/revenue_cat/console_setup.md` | RevenueCat 콘솔 초기 설정 |
| `docs/revenue_cat/code_integration.md` | RevenueCat 코드 통합 및 무료 제한 로직 |
| `docs/revenue_cat/android_setup.md` | Android Play Store 연동 상세 |
| `docs/revenue_cat/ios_setup.md` | iOS App Store 연동 절차 (사업자 등록 후 진행) |
| `docs/deployment/android.md` | Android 배포 절차 및 빌드 명령어 |
| `docs/deployment/ios.md` | iOS 배포 절차 및 트러블슈팅 |
| `docs/Structure/local_data_storage.md` | 로컬 데이터 저장 구조 |
| `docs/Structure/cloud_storage.md` | 클라우드 저장 구조 (Firestore + Storage) |
