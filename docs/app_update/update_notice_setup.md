# 앱 업데이트 알림 설정 가이드

## 목적

앱 실행 시 현재 설치된 앱 버전이 운영 기준보다 낮은 경우 업데이트 안내를 표시한다.

권장 방식은 Firebase Remote Config를 사용해 서버 측에서 최신 버전, 최소 지원 버전, 강제 업데이트 여부를 제어하는 것이다.

---

## 기본 개념

앱은 실행 시 다음 값을 Firebase Remote Config에서 읽는다.

```text
latest_version_android
latest_version_ios
minimum_supported_version_android
minimum_supported_version_ios
force_update_android
force_update_ios
android_store_url
ios_store_url
```

앱 내부에서는 `package_info_plus`로 현재 앱 버전을 읽고 Remote Config 값과 비교한다.

예:

```text
현재 앱 버전: 2.2.1
minimum_supported_version_ios: 2.3.0
```

위 경우 현재 앱이 최소 지원 버전보다 낮으므로 업데이트 안내를 표시한다.

---

## 업데이트 알림 유형

### 1. 선택 업데이트

사용자가 나중에 업데이트할 수 있다.

예시 문구:

```text
새 버전이 있습니다.
더 안정적인 사용을 위해 최신 버전으로 업데이트해 주세요.
[나중에] [업데이트]
```

사용 조건:

```text
current_version < latest_version
force_update = false
current_version >= minimum_supported_version
```

### 2. 강제 업데이트

사용자가 업데이트 전까지 앱을 계속 사용할 수 없도록 막는다.

예시 문구:

```text
업데이트가 필요합니다.
현재 버전은 더 이상 지원되지 않습니다. 최신 버전으로 업데이트해 주세요.
[업데이트]
```

사용 조건:

```text
current_version < minimum_supported_version
```

또는 운영 정책에 따라:

```text
force_update = true
current_version < latest_version
```

---

## 사용자 직접 설정 작업

## 1. Firebase Remote Config 활성화

Firebase Console에서 진행한다.

1. Firebase Console 접속
2. 프로젝트 선택

```text
expense-diary-4892a
```

3. 왼쪽 메뉴에서 `Remote Config` 선택
4. 처음 사용하는 경우 `시작하기` 클릭
5. 아래 파라미터를 추가한다.

---

## 2. Remote Config 파라미터 추가

### 필수 파라미터

| Key | Type | 예시값 | 설명 |
|---|---|---|---|
| `latest_version_android` | String | `2.3.0` | Android 최신 권장 버전 |
| `latest_version_ios` | String | `2.3.0` | iOS 최신 권장 버전 |
| `minimum_supported_version_android` | String | `2.2.0` | Android 최소 지원 버전 |
| `minimum_supported_version_ios` | String | `2.2.0` | iOS 최소 지원 버전 |
| `force_update_android` | Boolean | `false` | Android 강제 업데이트 여부 |
| `force_update_ios` | Boolean | `false` | iOS 강제 업데이트 여부 |
| `android_store_url` | String | `https://play.google.com/store/apps/details?id=com.ysh.expense_diary` | Android 스토어 URL |
| `ios_store_url` | String | `https://apps.apple.com/app/id6749577301` | iOS App Store URL |

---

## 3. 권장 초기값

현재 제출/운영 기준 버전이 `2.3.0`이라면 처음에는 강제 업데이트가 걸리지 않게 설정한다.

```text
latest_version_android = 2.3.0
latest_version_ios = 2.3.0
minimum_supported_version_android = 2.2.0
minimum_supported_version_ios = 2.2.0
force_update_android = false
force_update_ios = false
android_store_url = https://play.google.com/store/apps/details?id=com.ysh.expense_diary
ios_store_url = https://apps.apple.com/app/id6749577301
```

이 설정은 기존 사용자는 업데이트 안내를 볼 수 있지만, 강제로 차단되지는 않게 한다.

---

## 4. 스토어 URL 확인

### Android

Google Play Console에서 패키지명을 확인한다.

현재 예상 URL:

```text
https://play.google.com/store/apps/details?id=com.ysh.expense_diary
```

패키지명이 다르면 URL도 수정해야 한다.

### iOS

App Store Connect에서 Apple ID를 확인한다.

현재 앱 Apple ID가 `6749577301`이면 URL은 다음과 같다.

```text
https://apps.apple.com/app/id6749577301
```

---

## 5. 운영 정책 결정

### 평상시 권장 정책

```text
force_update_android = false
force_update_ios = false
minimum_supported_version_android = 직전 안정 버전 또는 더 낮은 버전
minimum_supported_version_ios = 직전 안정 버전 또는 더 낮은 버전
```

이 경우 사용자는 업데이트 안내를 받지만 앱 사용은 계속 가능하다.

### 강제 업데이트가 필요한 경우

다음과 같은 경우에만 최소 지원 버전을 올리거나 `force_update`를 켠다.

```text
- 치명적인 크래시
- 보안 문제
- DB/백업 호환성 문제
- 기존 버전에서 서버 기능을 더 이상 정상 사용할 수 없는 경우
```

### 강제 업데이트 설정 예시

```text
latest_version_ios = 2.4.0
minimum_supported_version_ios = 2.4.0
force_update_ios = true
```

이 경우 `2.4.0` 미만 iOS 앱은 업데이트 전까지 차단된다.

---

## iOS App Review 주의사항

App Store 심사 중인 빌드에는 강제 업데이트가 걸리면 안 된다.

예를 들어 제출 빌드가 `2.3.0`이면 심사 중에는 다음처럼 설정한다.

```text
latest_version_ios = 2.3.0
minimum_supported_version_ios = 2.2.0
force_update_ios = false
```

잘못된 설정 예:

```text
latest_version_ios = 2.4.0
minimum_supported_version_ios = 2.4.0
force_update_ios = true
```

위 설정은 심사자가 제출 빌드 `2.3.0`을 실행하자마자 업데이트 요구 화면에 막히게 만들 수 있다.

---

## 구현 시 필요한 패키지

Flutter 앱 구현에는 다음 패키지가 필요하다.

```yaml
firebase_remote_config: ^latest
package_info_plus: ^latest
url_launcher: 이미 사용 중
```

현재 앱에는 `url_launcher`가 이미 포함되어 있다.

---

## 구현 요구사항

앱 시작 시 다음 흐름으로 동작한다.

```text
1. Firebase 초기화
2. Remote Config fetch/activate
3. package_info_plus로 현재 버전 확인
4. 플랫폼별 Remote Config 값 선택
5. 버전 비교
6. 필요 시 업데이트 다이얼로그 표시
7. 업데이트 버튼 클릭 시 플랫폼별 스토어 URL 열기
```

---

## 버전 비교 규칙

버전은 semantic version 형식으로 비교한다.

```text
2.3.0 > 2.2.9
2.3.1 > 2.3.0
2.10.0 > 2.9.9
```

빌드 번호(`+14`)는 기본적으로 비교하지 않는다.

예:

```text
pubspec.yaml: 2.3.0+14
비교 대상: 2.3.0
```

필요하면 추후 빌드 번호 비교를 별도 키로 확장할 수 있다.

---

## 다이얼로그 UX 요구사항

### 선택 업데이트

- 닫을 수 있음
- `나중에`, `업데이트` 버튼 제공
- 하루 1회만 표시 같은 제한은 선택 사항

권장 문구:

```text
새 버전이 있습니다.
더 안정적인 사용을 위해 최신 버전으로 업데이트해 주세요.
```

### 강제 업데이트

- 닫을 수 없음
- `업데이트` 버튼만 제공
- Android back 버튼으로도 닫히지 않게 처리

권장 문구:

```text
업데이트가 필요합니다.
현재 버전은 더 이상 지원되지 않습니다. 최신 버전으로 업데이트해 주세요.
```

---

## i18n 키 제안

```json
{
  "app_update": {
    "optional_title": "새 버전이 있습니다",
    "optional_message": "더 안정적인 사용을 위해 최신 버전으로 업데이트해 주세요.",
    "required_title": "업데이트가 필요합니다",
    "required_message": "현재 버전은 더 이상 지원되지 않습니다. 최신 버전으로 업데이트해 주세요.",
    "later": "나중에",
    "update": "업데이트"
  }
}
```

영문:

```json
{
  "app_update": {
    "optional_title": "A new version is available",
    "optional_message": "Please update to the latest version for a more stable experience.",
    "required_title": "Update required",
    "required_message": "This version is no longer supported. Please update to the latest version.",
    "later": "Later",
    "update": "Update"
  }
}
```

---

## 테스트 시나리오

### 1. 업데이트 없음

```text
현재 앱 버전: 2.3.0
latest_version: 2.3.0
minimum_supported_version: 2.2.0
force_update: false
```

결과:

```text
팝업 없음
```

### 2. 선택 업데이트

```text
현재 앱 버전: 2.3.0
latest_version: 2.4.0
minimum_supported_version: 2.3.0
force_update: false
```

결과:

```text
선택 업데이트 팝업 표시
나중에 가능
```

### 3. 강제 업데이트

```text
현재 앱 버전: 2.3.0
latest_version: 2.4.0
minimum_supported_version: 2.4.0
force_update: true
```

결과:

```text
강제 업데이트 팝업 표시
닫기 불가
```

### 4. Remote Config 실패

네트워크 장애 등으로 Remote Config fetch가 실패하는 경우:

```text
앱 실행은 계속 허용
업데이트 팝업 표시하지 않음
로그만 남김
```

---

## 운영 체크리스트

- [ ] Firebase Remote Config 활성화
- [ ] 필수 파라미터 8개 추가
- [ ] Android Store URL 확인
- [ ] iOS Store URL 확인
- [ ] 초기값은 강제 업데이트가 걸리지 않게 설정
- [ ] iOS 심사 중 `force_update_ios=false` 유지
- [ ] 심사 통과 후 필요한 경우 `latest_version_ios`만 최신 값으로 조정
- [ ] 강제 업데이트는 치명적 이슈 때만 사용

---

## 구현자에게 전달할 기본값

```text
Android Store URL: https://play.google.com/store/apps/details?id=com.ysh.expense_diary
iOS Store URL: https://apps.apple.com/app/id6749577301
latest_version_android: 2.3.0
latest_version_ios: 2.3.0
minimum_supported_version_android: 2.2.0
minimum_supported_version_ios: 2.2.0
force_update_android: false
force_update_ios: false
```
