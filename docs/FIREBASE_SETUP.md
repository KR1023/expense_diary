# Firebase Setup Guide

이 문서는 이 저장소의 Flutter 앱(iOS/Android)에 Firebase를 반복 가능하게 연결하는 절차를 정리합니다.

기본 원칙:
- 로컬 우선(`Drift` 기반) + Firebase는 동기화/백업 레이어
- Firebase 연결은 가능하면 `FlutterFire CLI`로 자동화
- 보안 규칙은 유저별 데이터 분리 기본

## 1) 사전 준비

필수 설치:
- Flutter SDK
- Xcode (iOS 빌드 시)
- Android Studio / Android SDK
- Node.js + npm (Firebase CLI 설치용)

권장 확인:
```bash
flutter --version
dart --version
node --version
npm --version
```

## 2) Firebase Console에서 할 일

### 2-1. Firebase 프로젝트 생성
1. Firebase Console 접속
2. `프로젝트 추가` 클릭
3. 프로젝트 이름 입력 (예: `expense-diary-prod`)
4. Google Analytics는 필요 시 활성화 (초기에는 비활성도 가능)

### 2-2. Authentication 활성화
1. Firebase Console > `Authentication`
2. `시작하기`
3. `Sign-in method` 탭에서 사용할 Provider 활성화
4. 이 티켓 기준 필수:
- `Email/Password` 활성화 (회원가입/로그인 기능용)
5. 최소 권장:
- `Anonymous` (초기 백업/복원 테스트에 유용)
- `Google` (구글 계정 로그인 기능 사용 시 필수)
- 이후 필요 시 `Apple` 추가

주의:
- `Email/Password` Provider가 비활성화되어 있으면 앱에서 회원가입/로그인 시 `operation-not-allowed` 오류가 발생합니다.
- `Google` Provider 사용 시 Android 디버그/릴리즈 SHA-1, SHA-256를 Firebase Android 앱 설정에 등록해야 인증 구성이 정상 동작합니다.

### 2-3. (중요) Android SHA 지문 등록 (Google 로그인/일부 Auth 흐름 안정화)
Firebase Console > 프로젝트 설정 > Android 앱(`com.ysh.expense_diary`)에서 다음 지문을 등록하세요.

확인 명령:
```bash
cd android
./gradlew signingReport
```

등록 대상:
- Debug SHA-1 / SHA-256 (로컬 개발용)
- Release SHA-1 / SHA-256 (배포용)

등록 후 권장 절차:
1. `google-services.json` 다시 다운로드하여 `android/app/google-services.json` 교체
2. `flutterfire configure` 재실행 (선택)
3. `flutter clean && flutter pub get && flutter run`

### 2-4. Cloud Firestore 생성
1. Firebase Console > `Firestore Database`
2. `데이터베이스 만들기`
3. 모드 선택:
- 초기 개발: `테스트 모드`로 시작 가능 (단, 즉시 Rules 적용 권장)
- 권장: 생성 후 아래 보안 규칙으로 바로 교체
4. 리전 선택 (예: `asia-northeast3`, `us-central1`)

리전은 나중에 변경이 어려우므로 팀 기준으로 고정하세요.

### 2-5. iOS 앱 등록 (Console)
1. Firebase 프로젝트 설정 > `일반`
2. `앱 추가` > iOS
3. `iOS bundle ID` 입력 (`ios/Runner.xcodeproj` 기준)
4. 앱 등록

주의:
- FlutterFire CLI를 사용할 경우 `GoogleService-Info.plist` 수동 관리보다 CLI 기반 생성/설정을 우선합니다.

### 2-6. Android 앱 등록 (Console)
1. Firebase 프로젝트 설정 > `일반`
2. `앱 추가` > Android
3. `Android package name` 입력 (`android/app/build.gradle*`의 `applicationId`)
4. 앱 등록

주의:
- FlutterFire CLI를 사용할 경우 `google-services.json` 수동 배치보다 CLI 기반 절차를 우선합니다.

## 3) Firebase CLI / FlutterFire CLI 설치 및 로그인

### 3-1. Firebase CLI 설치
```bash
npm install -g firebase-tools
firebase --version
```

### 3-2. Firebase 로그인
```bash
firebase login
```

로그인 확인:
```bash
firebase projects:list
```

### 3-3. FlutterFire CLI 설치
```bash
dart pub global activate flutterfire_cli
```

PATH 이슈가 있으면(`flutterfire` 명령어를 못 찾는 경우):
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

확인:
```bash
flutterfire --version
```

## 4) FlutterFire CLI로 프로젝트 연결 (권장)

프로젝트 루트에서 실행:
```bash
flutterfire configure
```

또는 이 저장소의 보조 스크립트 사용:
```bash
./scripts/firebase_configure.sh
```

이 스크립트는 아래를 순서대로 점검/실행합니다.
- `flutter` 확인
- `firebase` CLI 존재 확인
- `flutterfire` CLI 존재 확인
- `flutter pub get`
- `flutterfire configure`

일반적인 흐름:
1. Firebase 프로젝트 선택
2. 플랫폼 선택 (`ios`, `android`)
3. 앱 등록/연결 자동 수행
4. Flutter 설정 파일 생성

### 핵심 산출물: `firebase_options.dart`

`FlutterFire CLI`는 `lib/firebase_options.dart` 파일을 생성합니다. 이 파일에는 플랫폼별 Firebase 설정값이 포함되며, 앱 부트스트랩에서 `Firebase.initializeApp(...)`에 사용됩니다.

예시(개념):
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

중요:
- `firebase_options.dart`는 FlutterFire CLI가 생성/갱신하는 파일입니다.
- Firebase 프로젝트를 바꾸거나 플랫폼을 추가하면 `flutterfire configure`를 다시 실행하세요.
- `flutterfire configure` 재실행은 정상적인 갱신 절차이며, 설정이 깨졌을 때 복구 경로로도 사용합니다.

## 5) 앱 코드 초기화(개념)

실제 구현 티켓에서 반영할 예정이지만, 일반적으로 `main.dart` 초기화 순서는 아래와 같습니다.

1. Flutter 바인딩 초기화
2. (필요 시) i18n 초기화
3. Firebase 초기화 (`firebase_options.dart` 사용)
4. 로컬 DB/서비스 로케이터 초기화
5. 앱 실행

## 6) Firestore 보안 규칙 (유저별 데이터 분리 기본)

기본 원칙:
- 인증된 사용자만 접근 가능
- 각 사용자는 자신의 문서만 읽기/쓰기 가능

예시 구조:
- `/users/{uid}/...`

예시 Rules (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

이 저장소에는 위 정책이 `repo root`의 `firestore.rules` 파일로 포함되어 있습니다.

주의:
- 이 앱은 로컬 우선 구조이므로 Firebase에는 동기화/백업에 필요한 데이터만 저장하는 방향을 유지합니다.
- 삭제/병합 정책은 이후 동기화 티켓에서 명확히 정의하세요.

## 7) Rules 배포 방식

이 저장소에 `firebase.json`이 있으므로, Rules 파일을 repo에 두고 CLI로 배포하는 방식을 권장합니다.

예시:
```bash
firebase use <project-id>
firebase deploy --only firestore:rules
```

스크립트 사용 (권장):
```bash
./scripts/firebase_deploy_firestore_rules.sh <project-id>
```

현재 Firebase CLI 프로젝트가 이미 선택되어 있으면:
```bash
./scripts/firebase_deploy_firestore_rules.sh
```

권장 운영:
- `firestore.rules`를 Git으로 관리
- Rules 변경 시 PR 리뷰 후 배포
- 운영/개발 프로젝트 분리 (`prod`, `dev`)

## 8) 로컬 개발 (Emulator 포함)

### 8-1. Emulator 실행 (선택)
```bash
firebase emulators:start
```

### 8-2. Auth Emulator 연결 예시 (필수 항목)

개발 환경에서만 연결:
```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<void> configureFirebaseEmulators() async {
  const useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
  if (!useEmulator) return;

  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

실행 예시:
```bash
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

참고:
- iOS 시뮬레이터는 보통 `localhost` 사용 가능
- Android 에뮬레이터는 환경에 따라 `10.0.2.2`가 필요할 수 있음

## 9) 새 기기에서 재설정 체크리스트

1. Flutter / Xcode / Android SDK 설치
2. `npm install -g firebase-tools`
3. `firebase login`
4. `dart pub global activate flutterfire_cli`
5. `flutter pub get`
6. 프로젝트 루트에서 `flutterfire configure`
7. 필요 시 `firebase use <project-id>`
8. `./scripts/firebase_deploy_firestore_rules.sh <project-id>` (Rules 배포)
9. `flutter run` (또는 플랫폼별 실행)

## 10) 팀 운영 팁 (권장)

- Firebase 프로젝트 ID를 문서/노션에 고정
- `dev` / `prod` 프로젝트 분리
- 인증 Provider 변경/Rules 변경 시 변경 이력 기록
- 배포 전 `firebase_options.dart`가 올바른 프로젝트를 가리키는지 확인
