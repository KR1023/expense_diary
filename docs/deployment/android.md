# Android (Google Play) 배포

## 앱 정보

| 항목 | 값 |
|---|---|
| 패키지명 | `com.ysh.expense_diary` |
| 서명 키 | `/Users/ysh/upload-keystore.jks` |
| key.properties | `android/key.properties` |

---

## 배포 전 체크리스트

- [ ] `pubspec.yaml` 버전 및 빌드번호 증가 (빌드번호는 이전보다 반드시 커야 함)
- [ ] `RC_FORCE_ENTITLED` 빌드 인자에 포함되지 않았는지 확인
- [ ] `RC_TEST_STORE_KEY` 빌드 인자에 포함되지 않았는지 확인
- [ ] `ADMOB_ANDROID_BANNER_ID`가 실제 Android 배너 광고 단위 ID인지 확인
- [ ] `/Users/ysh/upload-keystore.jks` 접근 가능한지 확인
- [ ] RevenueCat 대시보드 — 프로덕션 오퍼링 상품 연결 상태 확인

---

## 1. 버전 번호 올리기

`pubspec.yaml`:

```yaml
version: 2.2.0+10   # 버전명+빌드번호
```

- **버전명**: 사용자에게 표시 (major.minor.patch)
- **빌드번호**: Play Store 업로드마다 반드시 1 이상 증가

---

## 2. AAB 빌드

```bash
flutter build appbundle \
  --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-5444803558030319/2084179141 \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY=goog_BWfATQigKwKTGYMoNlyeAVwpJFB \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=appl_nfQCULthfEqbagScUuIkVIQbneG \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_OFFERING_CLOUD=cloud_monthly
```

결과물: `build/app/outputs/bundle/release/app-release.aab`

---

## 3. Play Console 업로드

```
play.google.com/console → 지출일기 앱 선택
→ 프로덕션 → 새 버전 만들기
→ app-release.aab 업로드
→ 출시 노트 작성 (ko-KR, en-US)
→ 저장 → 검토 후 출시
```

### 내부 테스트 트랙 먼저 검증하는 경우

```
→ 내부 테스트 → 새 버전 만들기 → AAB 업로드 → 출시
→ 구독 플로우 및 주요 기능 검증 후
→ 프로덕션 트랙으로 승격
```

---

## 4. 구독 테스트 (라이선스 테스터)

```
Play Console → 설정 → 라이선스 테스트
→ 테스트 계정 이메일 등록
→ 내부 테스트 트랙 빌드 설치 후 구독 시도
→ "테스트 결제" 문구 확인 (실제 청구 없음)
```

---

## Android Studio 실행 설정

| 설정 이름 | 용도 |
|---|---|
| `main.dart` | 프로덕션 키로 실행 |
| `main.dart (Force Entitled)` | 구독 없이 모든 기능 열어서 UI 테스트 |

설정 파일 위치: `.idea/runConfigurations/`
