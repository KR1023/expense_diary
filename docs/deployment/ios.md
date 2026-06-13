# iOS (App Store) 배포

## 앱 정보

| 항목 | 값 |
|---|---|
| Bundle ID | `com.ysh.expenseDiary` |
| Development Team | `6Z7459R7NZ` |
| Apple ID | `shgyo23@naver.com` |

---

## 배포 전 체크리스트

- [ ] `pubspec.yaml` 버전 및 빌드번호 증가
- [ ] Xcode에 Apple ID 로그인 상태 확인
- [ ] iOS Distribution 인증서 유효 확인
- [ ] `RC_FORCE_ENTITLED` 빌드 인자에 포함되지 않았는지 확인
- [ ] `ADMOB_IOS_BANNER_ID`가 실제 iOS 배너 광고 단위 ID인지 확인
- [ ] App Store Connect에 앱 빌드 슬롯 준비

---

## 1. 버전 번호 올리기

`pubspec.yaml`:

```yaml
version: 2.2.0+10   # 버전명+빌드번호
```

빌드번호는 App Store Connect에 업로드된 이전 빌드보다 반드시 커야 한다.

---

## 2. Xcode 서명 설정 확인

최초 배포 또는 인증서 만료 시 필요.

```
Xcode → Settings (⌘,) → Accounts 탭
→ shgyo23@naver.com 로그인 확인
→ Manage Certificates → Apple Distribution 인증서 존재 확인
  없으면: + 버튼 → Apple Distribution 선택 → 자동 생성

Xcode → Runner.xcworkspace 열기
→ Runner 타겟 → Signing & Capabilities
→ Team: 6Z7459R7NZ 확인
→ Automatically manage signing 체크 확인
```

---

## 3. IPA 빌드

```bash
flutter build ipa \
  --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-5444803558030319/5504549409 \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY=appl_nfQCULthfEqbagScUuIkVIQbneG \
  --dart-define=RC_ENTITLEMENT_CLOUD=cloud \
  --dart-define=RC_OFFERING_CLOUD=cloud_monthly
```

결과물: `build/ios/ipa/*.ipa`

---

## 4. App Store Connect 업로드

### 방법 A: Transporter 앱 (권장)

```
Mac App Store → "Transporter" 검색 후 설치
→ Transporter 실행 → shgyo23@naver.com 로그인
→ build/ios/ipa/*.ipa 파일을 창에 드래그 앤 드롭
→ Deliver 버튼 클릭 → 업로드 완료 대기 (1~5분)
```

> Transporter 로그인 오류 시 앱 전용 비밀번호 필요:
> `appleid.apple.com → 보안 → 앱 전용 암호 생성`

### 방법 B: xcrun altool (터미널)

```bash
xcrun altool --upload-app \
  --type ios \
  -f build/ios/ipa/*.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

App Store Connect API Key는 `App Store Connect → 사용자 및 액세스 → 통합 → API`에서 발급.

---

## 5. App Store Connect 처리 및 심사 제출

```
appstoreconnect.apple.com → 앱 선택
→ TestFlight 탭에서 빌드 처리 완료 확인 (5~10분, 이메일 알림)
→ 앱 스토어 탭 → + 버튼으로 버전 생성 → 빌드 선택
→ 출시 노트 작성 (ko, en)
→ 심사 제출
```

심사 기간: 보통 1~3일 (첫 심사는 더 걸릴 수 있음)

---

## 트러블슈팅

### "No signing certificate iOS Distribution found"

```
Xcode → Settings → Accounts → Manage Certificates
→ + → Apple Distribution → 생성
```

### "Unable to log in with account"

```
Xcode → Settings → Accounts
→ 기존 계정 제거 후 재로그인
또는
appleid.apple.com에서 앱 전용 암호 생성 후 사용
```

### 빌드번호 중복 오류

`pubspec.yaml`의 빌드번호(+숫자)를 이전보다 크게 수정 후 재빌드.
