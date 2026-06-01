# 고정 지출 / 결제 수단 기능 구현 티켓

## 목적

지출 입력 기능을 확장하여 사용자가 직접 결제 수단을 관리하고, 매일/매주/매월/매년 반복되는 고정 지출을 자동으로 실제 지출 내역에 반영할 수 있도록 한다.

최종 목표는 다음과 같다.

- 지출 추가/수정 시 결제 수단을 선택할 수 있다.
- 사용자는 카드, 현금, 계좌, 간편결제 등 결제 수단 목록을 직접 추가/수정/삭제할 수 있다.
- 고정 지출 탭에서 반복되는 고정 지출을 등록하고 관리할 수 있다.
- 반복 지출은 미래 데이터를 미리 생성하지 않고, 필요한 시점에 실제 지출로 생성한다.
- 시작일은 필수, 종료일은 선택이며 종료일이 없으면 무기한 반복한다.

---

## 현재 앱 구조 참고

- Flutter / Dart
- 로컬 DB: Drift + SQLite
- DB 파일: `lib/database/drift_database.dart`
- 모델: `lib/model/`
- 화면: `lib/screen/`
- 공통 컴포넌트: `lib/component/`
- 현재 지출 테이블: `lib/model/expense.dart`
- 현재 분류 테이블: `lib/model/category.dart`
- 현재 탭 구조: `lib/screen/root_screen.dart`

Drift 테이블 변경 후 아래 명령으로 generated code를 갱신해야 한다.

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 최종 탭 구조 제안

기존 탭에 `고정 지출` 탭을 추가한다.

```text
지출 / 지출 내역 / 분류 / 고정 지출 / 설정
```

각 탭 역할:

```text
지출
- 일반 지출 추가
- 분류 선택
- 결제 수단 선택

지출 내역
- 날짜별/월별 지출 확인
- 분류와 결제 수단 표시

분류
- 지출 분류 관리

고정 지출
- 반복/고정 지출 목록
- 반복 지출 추가/수정
- 활성/비활성 토글
- 다음 생성일 표시

설정
- 언어/통화
- 계정/백업/구독
- 결제 수단 관리
- 데이터 초기화
```

---

## 1. 결제 수단 기능

### 1.1 데이터 모델

새 테이블 `PaymentMethods`를 추가한다.

권장 파일:

```text
lib/model/payment_method.dart
```

권장 컬럼:

```text
PaymentMethod
- id: int autoIncrement
- type: text
- name: text
- memo: text nullable
- sortOrder: int
- isArchived: bool
- createdAt: DateTime
- updatedAt: DateTime
```

`type` 값은 문자열 enum 형태로 저장한다.

```text
cash
card
bank
mobilePay
other
```

UI 표시명:

```text
현금
카드
계좌
간편결제
기타
```

예시 데이터:

```text
type: cash, name: 현금
type: card, name: 현대카드
type: card, name: 신한카드
type: card, name: 비씨카드
type: bank, name: 국민은행
type: mobilePay, name: 카카오페이
```

### 1.2 기존 Expense 확장

`Expenses` 테이블에 아래 컬럼을 추가한다.

```text
paymentMethodId nullable
recurringExpenseId nullable
recurringOccurrenceDate nullable
```

권장 의미:

```text
paymentMethodId
- 사용자가 선택한 결제 수단
- 기존 데이터 보호를 위해 nullable

recurringExpenseId
- 고정 지출에서 생성된 실제 지출이면 원본 반복 규칙 ID 저장
- 일반 수동 지출이면 null

recurringOccurrenceDate
- 반복 지출 발생일
- 중복 생성 방지에 사용
```

### 1.3 중복 방지 인덱스

반복 생성 지출 중복을 막기 위해 가능한 경우 아래 unique index를 둔다.

```text
UNIQUE(recurringExpenseId, recurringOccurrenceDate)
```

주의:

- Drift에서 nullable unique index 동작을 확인할 것.
- nullable unique index가 애매하면 생성 전 조회로 중복을 방지한다.

### 1.4 삭제 정책

결제 수단은 실제 삭제보다 보관 처리한다.

```text
isArchived = true
```

이유:

- 과거 지출이 해당 결제 수단을 참조할 수 있음
- 완전 삭제 시 과거 지출의 표시가 깨질 수 있음
- 사용자에게는 “삭제”처럼 보이되 내부적으로는 목록에서 숨김 처리

### 1.5 결제 수단 관리 위치

결제 수단은 설정 탭에서 관리한다.

```text
설정 → 결제 수단 관리
```

설정 탭에 메뉴를 추가한다.

```text
결제 수단 관리
자주 사용하는 카드, 현금, 계좌, 간편결제를 관리합니다.
```

### 1.6 결제 수단 관리 화면

새 화면 권장:

```text
lib/screen/payment_method_screen.dart
```

화면 구성:

```text
결제 수단 관리

카드
- 현대카드
- 신한카드
- 비씨카드

현금
- 현금

계좌
- 국민은행

간편결제
- 카카오페이

[+ 결제 수단 추가]
```

기능:

- 결제 수단 추가
- 결제 수단 이름 수정
- 결제 수단 유형 수정
- 메모 수정
- 삭제 버튼 클릭 시 `isArchived = true`
- archived 항목은 기본 목록에서 숨김

### 1.7 결제 수단 추가/수정 폼

입력 항목:

```text
이름: 필수
유형: 필수
메모: 선택
```

예시:

```text
이름: 현대카드
유형: 카드
메모: 생활비 카드
```

### 1.8 지출 추가/수정 화면 반영

`AddScreen`, `DetailScreen`에 결제 수단 셀렉트 박스를 추가한다.

권장 위치:

```text
지출명
지출일자
지출금액
분류
결제 수단
상세내용
```

미선택 문구:

```text
결제 수단 선택
```

기존 `SelectField` 공통 컴포넌트를 재사용한다.

현재 관련 파일:

```text
lib/component/common/select_field.dart
lib/component/category_select.dart
```

새 컴포넌트 권장:

```text
lib/component/payment_method_select.dart
```

### 1.9 지출 내역 표시

지출 카드/목록에는 결제 수단을 작게 표시한다.

예시:

```text
점심 식사
식비 · 현대카드
12,000원
```

또는 badge 형태:

```text
[식비] [현대카드]
```

표시 대상 파일 후보:

```text
lib/component/expense_card.dart
lib/component/expense_by_date.dart
```

---

## 2. 고정 지출 기능

### 2.1 데이터 모델

새 테이블 `RecurringExpenses`를 추가한다.

권장 파일:

```text
lib/model/recurring_expense.dart
```

권장 컬럼:

```text
RecurringExpense
- id: int autoIncrement
- name: text
- amount: int
- categoryId: int nullable
- paymentMethodId: int nullable
- detail: text nullable
- frequency: text
- interval: int
- startDate: DateTime
- endDate: DateTime nullable
- nextRunDate: DateTime
- isActive: bool
- createdAt: DateTime
- updatedAt: DateTime
```

`frequency` 값:

```text
daily
weekly
monthly
yearly
```

`interval` 의미:

```text
1 = 매일 / 매주 / 매월 / 매년
2 = 2일마다 / 2주마다 / 2개월마다 / 2년마다
```

처음에는 UI 복잡도를 줄이기 위해 `interval = 1`만 지원해도 된다.

### 2.2 시작일/종료일 정책

```text
startDate: 필수
endDate: nullable
```

정책:

```text
endDate == null → 무기한 반복
endDate != null → nextRunDate <= endDate 까지만 생성
nextRunDate > endDate → 더 이상 생성하지 않음
```

종료일이 지난 경우:

```text
isActive = false 처리 가능
```

### 2.3 미래 데이터 미리 생성 금지

중요 정책:

```text
미래의 Expense를 미리 전부 생성하지 않는다.
```

반복 지출 테이블에는 “규칙”만 저장한다.

실제 `Expense`는 아래 조건일 때만 생성한다.

```text
nextRunDate <= today
```

이유:

- 무기한 반복인 경우 미래 데이터가 무한히 증가할 수 있음
- 사용자가 반복 규칙을 수정했을 때 이미 생성된 미래 지출 처리 문제가 생김
- 앱 성능과 DB 용량에 불필요한 부담이 생김

### 2.4 자동 생성 흐름

앱 실행 또는 고정 지출 탭 진입 시 due 항목을 생성한다.

Pseudo flow:

```text
for each active recurringExpense:
  while recurringExpense.nextRunDate <= today:
    if endDate != null and nextRunDate > endDate:
      isActive = false
      break

    if Expense(recurringExpenseId, recurringOccurrenceDate) does not exist:
      create Expense

    nextRunDate = calculateNextRunDate(nextRunDate, frequency, interval)

    if generatedCount >= maxGenerateCount:
      stop
```

### 2.5 실행 타이밍

처음 구현 시 추천:

```text
앱 시작 직후
고정 지출 탭 진입 시
반복 지출 추가/수정 직후
```

나중에 필요하면 foreground 복귀 시점도 추가한다.

### 2.6 부하 방지

앱을 오래 실행하지 않은 경우 누락분이 많이 생길 수 있다.

예:

```text
5년간 앱 미실행 + 매일 반복 지출 = 1800건 이상 생성 가능
```

초기 구현 권장 제한:

```text
한 번의 실행에서 자동 생성 최대 100건
```

100건 초과 시 우선 중단한다.

추후 개선:

```text
생성할 고정 지출이 많습니다. 나머지도 생성하시겠습니까?
```

초기 버전에서는 안내 없이 100건 제한만 적용해도 된다.

### 2.7 중복 생성 방지

실제 지출 생성 전 반드시 중복 체크한다.

조건:

```text
recurringExpenseId == currentRecurringExpense.id
recurringOccurrenceDate == nextRunDate
```

이미 있으면 새로 만들지 않는다.

### 2.8 월말 처리 정책

매월 31일 반복 같은 edge case를 처리해야 한다.

권장 정책:

```text
해당 월에 같은 일이 없으면 그 달의 말일에 생성
```

예:

```text
1월 31일
2월 28일 또는 29일
3월 31일
4월 30일
```

연간 반복에서도 2월 29일 같은 edge case는 해당 연도에 날짜가 없으면 2월 말일로 처리한다.

### 2.9 반복 지출 수정 정책

반복 규칙 수정 시 기본 정책:

```text
앞으로 생성될 지출에만 반영
이미 생성된 Expense는 수정하지 않음
```

이유:

- 과거 지출은 실제 기록으로 간주
- 반복 규칙 변경이 과거 회계 데이터를 바꾸면 사용자가 혼란스러움

### 2.10 반복 지출 삭제 정책

완전 삭제보다 비활성화 권장.

```text
isActive = false
```

사용자에게는 “삭제”처럼 표현할 수 있다.

과거 자동 생성 지출은 유지한다.

---

## 3. 고정 지출 탭 UI

### 3.1 탭 추가

`RootScreen`에 탭을 추가한다.

```text
지출 / 지출 내역 / 분류 / 고정 지출 / 설정
```

새 화면 권장:

```text
lib/screen/recurring_expense_screen.dart
```

### 3.2 고정 지출 목록 화면

구성:

```text
고정 지출
반복되는 고정 지출을 관리합니다.

[+ 고정 지출 추가]

활성
- 넷플릭스
  매월 10일 · 15,000원 · 현대카드
  다음 생성일: 2026.06.10

- 월세
  매월 1일 · 500,000원 · 계좌이체
  다음 생성일: 2026.07.01

비활성
- 이전 구독 서비스
```

각 항목:

```text
이름
금액
반복 주기
분류
결제 수단
시작일
종료일 또는 무기한
다음 생성일
활성/비활성 토글
수정 버튼
삭제 버튼
```

### 3.3 고정 지출 추가/수정 화면

새 화면 권장:

```text
lib/screen/recurring_expense_form_screen.dart
```

입력 항목:

```text
이름: 필수
금액: 필수
분류: 선택
결제 수단: 선택
반복 주기: 필수
시작일: 필수
종료일: 선택
상세 메모: 선택
```

반복 주기 옵션:

```text
매일
매주
매월
매년
```

종료일 UI:

```text
[ ] 종료일 없음
종료일 선택
```

또는:

```text
종료일
[무기한] [날짜 선택]
```

초기 구현은 nullable date field로 충분하다.

---

## 4. 서비스/유틸 구조

### 4.1 반복 주기 계산 유틸

권장 파일:

```text
lib/core/recurring/recurring_schedule.dart
```

필요 함수:

```text
DateTime calculateNextRunDate({
  required DateTime current,
  required String frequency,
  required int interval,
})
```

월말 처리 함수:

```text
DateTime addMonthsClamped(DateTime date, int months)
```

연간 처리 함수:

```text
DateTime addYearsClamped(DateTime date, int years)
```

### 4.2 자동 생성 서비스

권장 파일:

```text
lib/core/recurring/recurring_expense_service.dart
```

역할:

```text
- 활성 반복 지출 조회
- due 항목 확인
- 실제 Expense 생성
- nextRunDate 갱신
- 종료일 초과 시 비활성화
- 중복 생성 방지
- 생성 개수 제한
```

권장 메서드:

```text
Future<int> generateDueExpenses({DateTime? now, int limit = 100})
```

반환값:

```text
생성된 Expense 개수
```

---

## 5. 백업/복원 고려사항

현재 백업/복원은 Firebase Storage + Firestore metadata 구조로 동작한다.

새 테이블 추가 시 백업 payload에 포함해야 한다.

포함 대상:

```text
paymentMethods
recurringExpenses
expenses.paymentMethodId
expenses.recurringExpenseId
expenses.recurringOccurrenceDate
```

하위 호환:

- 기존 백업 파일에는 paymentMethods/recurringExpenses가 없을 수 있음
- 복원 시 누락된 필드는 빈 목록 또는 null로 처리
- 기존 Expense에는 paymentMethodId가 없을 수 있으므로 nullable 처리

관련 파일 후보:

```text
lib/features/backup/domain/snapshot.dart
lib/features/backup/data/firebase_snapshot_repository.dart
lib/features/backup/data/snapshot_service.dart
```

---

## 6. 통계/리포트 확장 여지

초기 구현 필수는 아니지만, 구조상 아래 기능으로 확장 가능해야 한다.

```text
결제 수단별 월간 지출
카드별 지출 랭킹
고정 지출 총액
고정비/변동비 구분
CSV/PDF에 결제 수단 컬럼 추가
```

초기 구현에서는 기존 통계 화면을 크게 바꾸지 않고, 지출 내역 표시까지만 반영해도 된다.

---

## 7. 구독 플랜과의 관계

초기 구현에서는 결제 수단/고정 지출에 구독 제한을 걸지 않는다.

이유:

- 핵심 기능 안정화가 먼저
- 제한 정책을 먼저 넣으면 테스트 복잡도 증가

추후 제한을 둔다면 예:

```text
Free
- 결제 수단 관리 가능
- 고정 지출 3개까지

Cloud
- 고정 지출 무제한
- 광고 제거
- 백업/복원 무제한

Report
- 결제 수단별 통계
- 카드별 월간 지출 리포트
- CSV/PDF 내보내기
```

---

## 8. 구현 순서 제안

### Phase 1. 결제 수단 기반 작업

1. `PaymentMethods` 테이블 추가
2. `Expenses.paymentMethodId` nullable 추가
3. Drift database version 증가 및 migration 작성
4. 기본 결제 수단 seed 추가
5. `PaymentMethodSelect` 컴포넌트 추가
6. 지출 추가 화면에 결제 수단 선택 추가
7. 지출 수정 화면에 결제 수단 선택 추가
8. 지출 카드/내역에 결제 수단 표시
9. 설정 탭에 `결제 수단 관리` 메뉴 추가
10. 결제 수단 관리 화면 추가
11. 결제 수단 추가/수정/삭제 처리

### Phase 2. 고정 지출 데이터/서비스

1. `RecurringExpenses` 테이블 추가
2. `Expenses.recurringExpenseId`, `recurringOccurrenceDate` 추가
3. Drift migration 작성
4. 반복 주기 계산 유틸 추가
5. 자동 생성 서비스 추가
6. 중복 생성 방지 로직 추가
7. 생성 제한 100건 적용
8. 앱 시작 시 due 지출 생성 연결

### Phase 3. 고정 지출 UI

1. `RootScreen`에 `고정 지출` 탭 추가
2. 고정 지출 목록 화면 추가
3. 고정 지출 추가/수정 화면 추가
4. 시작일 필수/종료일 선택 UI 구현
5. 활성/비활성 토글 추가
6. 다음 생성일 표시
7. 고정 지출 탭 진입 시 due 지출 생성 실행

### Phase 4. 백업/복원/테스트

1. 백업 payload에 새 테이블 포함
2. 복원 로직 하위 호환 처리
3. 반복 주기 계산 테스트 추가
4. 중복 생성 방지 테스트 추가
5. 종료일 처리 테스트 추가
6. 월말 처리 테스트 추가
7. 기존 지출 추가/수정 회귀 테스트

---

## 9. 테스트 시나리오

### 결제 수단

- 결제 수단 추가 가능
- 결제 수단 이름 수정 가능
- 결제 수단 유형 수정 가능
- 결제 수단 삭제 시 과거 지출 표시가 깨지지 않음
- archived 결제 수단은 새 지출 입력 목록에 표시되지 않음
- 기존 지출은 paymentMethodId가 null이어도 정상 표시

### 지출 입력/수정

- 지출 추가 시 결제 수단 선택 가능
- 결제 수단 미선택 저장 가능
- 지출 수정 시 기존 결제 수단 선택 상태 표시
- 결제 수단 변경 후 저장 가능

### 반복 지출

- 시작일 필수 검증
- 종료일 없이 무기한 저장 가능
- 종료일이 시작일보다 빠르면 저장 불가
- 매일 반복 생성
- 매주 반복 생성
- 매월 반복 생성
- 매년 반복 생성
- 종료일 이후 생성 중단
- 앱을 오래 안 켠 경우 누락분만 생성
- 한 번에 100건까지만 생성
- 같은 발생일의 반복 지출이 중복 생성되지 않음
- 매월 31일 반복 시 짧은 달은 말일로 생성

### 백업/복원

- paymentMethods 포함 백업 가능
- recurringExpenses 포함 백업 가능
- 기존 백업 파일 복원 가능
- 복원 후 고정 지출 생성 정상 동작

---

## 10. 주의사항

- 기존 사용자 데이터가 있으므로 새 컬럼은 nullable로 시작한다.
- 결제 수단 삭제는 실제 delete보다 archive 처리한다.
- 반복 지출은 미래 Expense를 미리 생성하지 않는다.
- 반복 규칙 수정은 앞으로 생성될 지출에만 반영한다.
- 과거에 이미 생성된 Expense는 사용자가 직접 수정/삭제할 수 있게 둔다.
- 앱 시작 시 자동 생성 로직이 너무 오래 걸리지 않도록 생성 개수 제한을 둔다.
- Drift migration 후 generated file을 반드시 갱신한다.
- 백업/복원 payload 하위 호환을 반드시 고려한다.
