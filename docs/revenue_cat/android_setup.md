# RevenueCat Android (Google Play) 설정

## 현재 상태

| 항목 | 값 |
|---|---|
| 연동 상태 | 완료 |
| Android API Key | `goog_BWfATQigKwKTGYMoNlyeAVwpJFB` |
| 패키지명 | `com.ysh.expense_diary` |
| 엔타이틀먼트 | `cloud`, `report` |

---

## 1. Google Play 서비스 계정 연동

RevenueCat이 Play Store 구독 상태를 서버에서 검증하기 위해 서비스 계정 키가 필요하다.

1. **Google Cloud Console** → 서비스 계정 생성
2. **Play Console → 설정 → API 액세스** → 서비스 계정 연결 → 재무 데이터 조회 권한 부여
3. 서비스 계정 JSON 키 다운로드
4. **RevenueCat 대시보드 → 앱 설정** → JSON 키 업로드

---

## 2. Play Store 구독 상품

Play Console에 등록된 구독 상품:

| 상품 ID | 기준 플랜 ID | 제공 기능 |
|---|---|---|
| `cloud_monthly` | `monthly2` | 광고 제거, 무제한 백업/복원 |
| `report_monthly` | `monthly` | Cloud 플랜 포함 + 통계/CSV/PDF |

상품 등록 경로: Play Console → 수익 창출 → 구독 → 새 구독 만들기

---

## 3. RevenueCat 프로젝트 설정

### 앱 추가
```
RevenueCat 대시보드 → 프로젝트 → Add an app → Google Play Store
→ 패키지명: com.ysh.expense_diary
→ 서비스 계정 JSON 업로드
→ 저장 → Android API Key 확인
```

### 상품 등록
```
Products → Import subscription products
→ Play Store에서 cloud_monthly, report_monthly 가져오기
```

### 엔타이틀먼트 구성

| 엔타이틀먼트 ID | 연결 상품 | 잠금 기능 |
|---|---|---|
| `cloud` | `cloud_monthly:monthly2` | 광고 제거, 무제한 백업/복원 |
| `report` | `report_monthly:monthly` | 통계, CSV/PDF 내보내기 |

> Report 엔타이틀먼트는 Cloud 기능을 포함한다 (코드에서 `isCloudEntitled`가 `_reportEntitled`도 포함).

```
Entitlements → cloud → Attach → cloud_monthly:monthly2
Entitlements → report → Attach → report_monthly:monthly
```

### 오퍼링(Offerings) 구성

Default offering에 패키지 2개:

| 패키지 식별자 | 연결 상품 |
|---|---|
| `cloud_monthly` | `cloud_monthly:monthly2` |
| `report_monthly` | `report_monthly:monthly` |

---

## 4. 테스트

### 라이선스 테스터 등록 (실제 결제 없이 전체 플로우 테스트)
```
Play Console → 설정 → 라이선스 테스트 → 테스트 계정 이메일 추가
→ 내부 테스트 트랙에 서명된 AAB 업로드
→ 해당 계정으로 기기에서 설치 후 구독 시도
→ "테스트 결제" 문구 확인
```

### Force Entitled (UI만 빠르게 테스트)
```
Android Studio → main.dart (Force Entitled) 설정 선택
→ --dart-define=RC_FORCE_ENTITLED=true 포함됨
→ 구독 없이 모든 기능 열림
```

> 프로덕션 빌드에 `RC_FORCE_ENTITLED` 절대 포함 금지.

---

## 5. 프로덕션 빌드 명령어

```bash
flutter build appbundle \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_BWfATQigKwKTGYMoNlyeAVwpJFB \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=appl_nfQCULthfEqbagScUuIkVIQbneG \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_ENTITLEMENT_REPORT=report \
  --dart-define=RC_OFFERING_CLOUD=cloud_monthly \
  --dart-define=RC_OFFERING_REPORT=report_monthly
```

결과물: `build/app/outputs/bundle/release/app-release.aab`

---

## 6. 구독 취소 처리

앱 내에서 직접 취소 불가. 구독 해지 버튼 탭 시 Google Play 구독 관리 페이지로 이동:

```dart
// customerInfo.managementURL 또는 fallback
Uri.parse('https://play.google.com/store/account/subscriptions')
```
