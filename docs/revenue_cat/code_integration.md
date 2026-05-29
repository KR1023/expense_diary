# RevenueCat 코드 통합

## 관련 파일

| 파일 | 역할 |
|---|---|
| `lib/const/revenuecat_config.dart` | API 키·엔타이틀먼트 ID 상수 |
| `lib/core/subscription/subscription_service.dart` | RevenueCat 초기화, 엔타이틀먼트 상태 관리 |
| `lib/screen/paywall_screen.dart` | 구독 유도 화면 |
| `lib/screen/statistics_tab_screen.dart` | report 엔타이틀먼트 게이트 |
| `lib/screen/config_screen.dart` | cloud 엔타이틀먼트 + 무료 제한 적용 |
| `pubspec.yaml` | `purchases_flutter: ^8.0.0` |

---

## 플랫폼 정책

```
Android: RevenueCat 구독 확인
iOS:     구독 없이 모든 기능 무료 제공 (사업자 등록 전)
```

`SubscriptionService`의 getter가 플랫폼을 분기한다:

```dart
bool get isCloudEntitled  => Platform.isIOS || _cloudEntitled;
bool get isReportEntitled => Platform.isIOS || _reportEntitled;
```

iOS에서는 RevenueCat SDK를 초기화하지 않는다(`_configure()`에서 early return).

---

## SubscriptionService

`ChangeNotifier`를 상속. `main()`에서 `runApp()` 전에 `await SubscriptionService.init()`으로 초기화 후 GetIt 싱글톤 등록.

```dart
final subscriptionService = await SubscriptionService.init();
GetIt.I.registerSingleton<SubscriptionService>(subscriptionService);
```

| 메서드 | 설명 |
|---|---|
| `init()` | 초기화 후 인스턴스 반환 (static factory) |
| `refresh()` | CustomerInfo 재조회, 상태 갱신 후 notifyListeners |
| `purchase(package)` | 패키지 결제. 취소 시 null 반환, 실패 시 rethrow |
| `restorePurchases()` | 구매 복원 |

---

## PaywallScreen

`PaywallScreen(entitlement: '...')` 형태로 push. 전달받은 엔타이틀먼트로 패키지 식별자를 결정한다:

```
entitlement == 'cloud'  → packageId = 'cloud_monthly'
entitlement == 'report' → packageId = 'report_monthly'
```

결제 성공 시 `Navigator.pop(true)` 반환. 취소·실패 시 화면 유지(snackBar 표시).

---

## 기능 게이트 동작

### 통계·리포트 (report 엔타이틀먼트)

`StatisticsTabScreen`의 각 메뉴 항목이 `_navigateWithGate()`를 통해 진입 제어:

```
isReportEntitled == true  → 해당 화면으로 push
isReportEntitled == false → PaywallScreen으로 push
```

탭 화면 자체는 `AnimatedBuilder`로 `SubscriptionService`를 감시하여 자물쇠 아이콘을 실시간 갱신한다.

### 클라우드 백업·복원 (cloud 엔타이틀먼트)

구독자는 백업·복원 횟수 제한 없음. 비구독자(로그인 상태)는 아래 무료 제한이 적용된다.

---

## 무료 사용자 제한

비구독자라도 로그인된 상태면 백업·복원을 제한적으로 사용할 수 있다.

| 기능 | 무료 제한 | 초기화 기준 |
|---|---|---|
| 클라우드 백업 | 주 1회 | KST ISO 주차 경계 (월요일 00:00 KST) |
| 스냅샷 복원 | 일 1회 | KST 자정 00:00 |

### 구현 방식

제한 상태는 `SharedPreferences`에 문자열 키로 저장된다:

| SharedPreferences 키 | 값 형식 | 예시 |
|---|---|---|
| `backup.last_backup_week_key` | `YYYY-WW` (ISO 주차) | `2026-22` |
| `backup.last_restore_day_key` | `YYYY-MM-DD` (KST 날짜) | `2026-05-30` |

키 상수는 `BackupMetadataKeys` 클래스(`lib/features/backup/data/backup_metadata_keys.dart`)에서 관리.

### 백업 주간 제한 흐름 (`_runBackup`)

```
1. 로그인 여부 확인
2. isCloudEntitled == false 이면:
   - 저장된 lastBackupWeekKey == 현재 KST 주차 키 → 스낵바("이번 주 무료 백업 사용") 후 return
3. 백업 실행
4. 성공 시 lastBackupWeekKey 갱신 (SharedPreferences + state)
```

### 복원 일간 제한 흐름 (`_openSnapshotRestore`)

```
1. 로그인 여부 확인
2. isCloudEntitled == false 이면:
   - 저장된 lastRestoreDayKey == 오늘 KST 날짜 키 → 스낵바("오늘 복원 사용") 후 return
3. SnapshotRestoreScreen push
4. 복원 성공(pop(true)) 시 lastRestoreDayKey 갱신 (SharedPreferences + state)
```

### UI 힌트

백업/복원 제한에 도달한 경우 설정 화면에서 다음 가능 일시를 표시한다:

- **백업**: `KstWeekKey.startOfNextWeekKst(now)` → 다음 월요일 00:00 KST
- **복원**: `KstWeekKey.tomorrowKst(now)` → 내일 00:00 KST

형식: `yyyy.MM.dd HH:mm` (예: `2026.06.01 00:00`)
