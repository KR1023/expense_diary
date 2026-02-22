# Firebase Troubleshooting

Flutter(iOS/Android) + Firebase 연동 시 자주 발생하는 문제와 해결 방법을 정리합니다.

## 1) `flutterfire configure` 로그인/토큰 문제

증상 예시:
- `Failed to fetch Firebase projects`
- `Not logged in`
- 브라우저 로그인 후에도 권한 없음

확인 순서:
1. Firebase CLI 로그인 상태 확인
```bash
firebase login:list
firebase projects:list
```
2. 필요 시 재로그인
```bash
firebase logout
firebase login
```
3. FlutterFire CLI 재실행
```bash
flutterfire configure
```

추가 점검:
- Google 계정이 해당 Firebase 프로젝트에 권한이 있는지 확인
- 회사/개인 계정이 섞이지 않았는지 확인

## 2) `flutterfire` 명령어를 찾을 수 없음

증상:
- `zsh: command not found: flutterfire`

원인:
- `dart pub global activate flutterfire_cli` 후 PATH 미설정

해결:
```bash
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutterfire --version
```

영구 반영(예: `~/.zshrc`)도 권장합니다.

## 3) `firebase_options.dart`가 생성되지 않음 / 오래된 설정 사용

증상:
- `lib/firebase_options.dart` 없음
- Firebase 프로젝트를 바꿨는데 앱이 이전 프로젝트에 연결됨

해결:
1. 프로젝트 루트에서 실행했는지 확인
2. `flutterfire configure` 재실행
3. 생성된 `lib/firebase_options.dart` 확인

핵심:
- `firebase_options.dart`는 FlutterFire CLI가 생성/갱신합니다.
- 플랫폼 추가/프로젝트 변경 시 반드시 재생성하세요.

## 4) Android: `google-services` 플러그인 누락

증상 예시:
- `No matching client found for package name`
- Firebase 초기화/빌드 실패
- Gradle sync 오류

확인 포인트(프로젝트 구조에 따라 파일 위치 다를 수 있음):
- `android/app/build.gradle` 또는 `android/app/build.gradle.kts`
- `com.google.gms.google-services` 플러그인 적용 여부

예시 (Groovy):
```gradle
plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
    id "com.google.gms.google-services"
}
```

예시 (의존성/버전 관리는 루트 Gradle 또는 settings에서 처리될 수 있음):
- Google Services plugin 버전 선언이 빠지지 않았는지 확인

추가 점검:
- `applicationId`와 Firebase에 등록한 Android package name이 일치하는지 확인

## 5) iOS: CocoaPods / 배포 타겟 문제

증상 예시:
- `pod install` 실패
- iOS deployment target too low
- Firebase pod 버전 충돌

해결 순서:
1. CocoaPods 설치/업데이트 확인
```bash
pod --version
```
2. iOS 배포 타겟 확인 (`ios/Podfile`, Xcode target settings)
3. Pods 재설치
```bash
cd ios
pod repo update
pod install
cd ..
```

문제가 지속되면 정리 후 재설치:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

추가 점검:
- Xcode에서 `Runner` 타겟의 iOS Deployment Target이 Podfile 설정과 일치하는지 확인

## 6) iOS: `GoogleService-Info.plist` 관련 혼선

증상:
- 수동 plist와 FlutterFire CLI 설정이 섞여서 잘못된 프로젝트로 연결됨

권장:
- 가능하면 FlutterFire CLI 기반 설정을 단일 소스로 유지
- `firebase_options.dart` 기준으로 초기화
- 수동 설정 파일 사용 여부를 팀 내에서 명확히 통일

## 7) Android: `google-services.json` 관련 혼선

증상:
- 빌드는 되지만 다른 Firebase 프로젝트로 연결됨

확인:
- Firebase Console의 Android 앱 package name 일치 여부
- `flutterfire configure` 이후 생성물/설정이 최신인지 확인
- flavor를 쓰는 경우 flavor별 설정 분리 여부 확인

## 8) Auth Emulator 연결이 안 됨

증상:
- 로컬 에뮬레이터 실행 중인데 실제 Firebase Auth로 붙음
- `connection refused`

점검:
1. Emulator 실행 여부
```bash
firebase emulators:start
```
2. 코드에서 `useAuthEmulator(...)`가 `Firebase.initializeApp()` 이후 호출되는지 확인
3. 플랫폼별 host 확인
- iOS 시뮬레이터: `localhost`
- Android 에뮬레이터: 종종 `10.0.2.2`

예시:
```dart
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

## 9) 권한 오류 (Firestore Rules)

증상:
- `PERMISSION_DENIED`

원인 후보:
- 로그인 안 됨 (`request.auth == null`)
- 문서 경로가 `/users/{uid}/...` 규칙과 다름
- 다른 사용자의 경로 접근 시도

확인 항목:
- 현재 로그인된 `uid`
- 실제 Firestore write/read 경로
- 배포된 Rules가 최신인지 (`firebase deploy --only firestore:rules`)

## 10) Auth 로그인/회원가입이 바로 실패함 (`operation-not-allowed`)

증상:
- 이메일/비밀번호 회원가입 또는 로그인 시 FirebaseAuthException 발생
- 코드 예: `operation-not-allowed`

원인:
- Firebase Console에서 `Authentication > Sign-in method > Email/Password` Provider가 비활성화됨

해결:
1. Firebase Console > `Authentication`
2. `Sign-in method`
3. `Email/Password` 활성화 후 저장

## 11) Android 회원가입/로그인 시 `CONFIGURATION_NOT_FOUND` (reCAPTCHA 관련)

증상 예시:
- `RecaptchaAction(...signUpPassword)... CONFIGURATION_NOT_FOUND`
- `FirebaseAuthException(code: unknown, ...)`

원인 후보:
- Firebase Authentication 설정 미완료 (특히 Provider 비활성화)
- Android 앱 SHA-1 / SHA-256 미등록
- SHA 등록 후 `google-services.json` 미갱신

해결 순서:
1. Firebase Console > `Authentication > Sign-in method`
   - `Email/Password` 활성화 확인
   - `Google` 로그인 사용 시 `Google` Provider도 활성화
2. Firebase Console > 프로젝트 설정 > Android 앱
   - Debug/Release `SHA-1`, `SHA-256` 등록
3. `google-services.json` 재다운로드 후 `android/app/google-services.json` 교체
4. 앱 재빌드
```bash
flutter clean
flutter pub get
flutter run
```

## 12) Flutter 빌드 캐시/플러그인 꼬임

증상:
- 설정 수정 후에도 동일 오류 반복

기본 정리 순서:
```bash
flutter clean
flutter pub get
```

플랫폼별 추가:
- iOS: `pod install` 재실행
- Android: Gradle sync / rebuild

## 13) 빠른 점검 체크리스트

- `firebase login` 완료
- `flutterfire configure` 완료
- `lib/firebase_options.dart` 생성됨
- `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` 적용됨
- Android package name / iOS bundle ID 일치
- Auth provider 활성화됨
- Firestore 생성됨
- Firestore Rules 배포됨
