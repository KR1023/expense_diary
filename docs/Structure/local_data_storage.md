# 로컬 데이터 저장 방식

## 저장 위치

기기 내부 앱 전용 디렉터리에 단일 SQLite 파일로 저장됩니다.

```
getApplicationDocumentsDirectory() / db.sqlite
```

앱 삭제 시 함께 삭제되며, 다른 앱에서 접근 불가능합니다.

---

## 테이블 구조

### `Category` 테이블 (`lib/model/category.dart`)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | int (PK, auto) | 자동 증가 |
| categoryName | text (unique) | 카테고리명, 중복 불가 |

### `Expenses` 테이블 (`lib/model/expense.dart`)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | int (PK, auto) | 자동 증가 |
| expenseName | text | 지출 이름 |
| expense | int | 금액 (정수) |
| expenseDate | DateTime | 날짜 |
| categoryId | int? (FK) | Category.id 참조, nullable |
| expenseDetail | text? | 메모, nullable |

---

## 쿼리 방식

모든 쿼리는 `LocalDatabase` 한 곳에 집중되어 있습니다 (`lib/database/drift_database.dart`).

### 실시간 스트림 쿼리 (`Stream<T>` 반환)

UI가 `StreamBuilder`로 구독하며, DB 변경 시 화면이 자동 갱신됩니다.

| 메서드 | 반환 타입 | 용도 |
|---|---|---|
| `watchExpense(date)` | `Stream<List<Map>>` | 특정 날짜 지출 목록 (카테고리 JOIN) |
| `selectDayExpense(date)` | `Stream<int>` | 특정 날짜 합계 |
| `selectMonthExpense(date)` | `Stream<int>` | 월간 합계 |
| `selectWeekExpense(start, end)` | `Stream<int>` | 주간 합계 |
| `watchDailyExpenseTotals(date)` | `Stream<Map<DateTime, int>>` | 월간 일별 합계 맵 (캘린더용) |
| `watchMonthlyCategoryExpense(date)` | `Stream<List<CategoryExpense>>` | 월간 카테고리별 합계 (통계용) |
| `watchCategory(keyword)` | `Stream<List<CategoryData>>` | 카테고리 목록 (검색 포함) |

### 단건 Future 쿼리

| 메서드 | 용도 |
|---|---|
| `createExpense(data)` | 지출 추가 |
| `updateExpense(data)` | 지출 수정 |
| `removeExpense(id)` | 지출 삭제 |
| `addCategory(data)` | 카테고리 추가 |
| `updateCategory(data)` | 카테고리 수정 |
| `deleteCategory(id)` | 카테고리 삭제 |
| `countExpensesByCategory(id)` | 카테고리 연결 지출 수 조회 (삭제 방지용) |
| `deleteAllData()` | 전체 초기화 (트랜잭션) |

---

## 접근 패턴

Repository 레이어 없이 각 화면이 `GetIt.I<LocalDatabase>()`로 직접 접근합니다.

```dart
StreamBuilder(
  stream: GetIt.I<LocalDatabase>().watchExpense(today),
  builder: (context, snapshot) { ... },
)
```

---

## 앱 설정 (SharedPreferences)

지출/카테고리 외 앱 설정은 `SharedPreferences`에 키-값으로 별도 저장됩니다.

| 키 | 내용 | 기본값 |
|---|---|---|
| `user_currency` | 통화 (KRW/USD) | KRW |
| `follow_system_locale` | 시스템 언어 따르기 | true |
| `user_locale` | 수동 언어 설정 | en |
| `backup.last_backup_at` | 마지막 백업 시각 (로컬 캐시) | — |
| `backup.last_backup_week_key` | 마지막 백업 주차 (로컬 캐시) | — |

`AppSettings`(`lib/service/app_settings.dart`)가 통화 값을 메모리에서 관리하며, 변경 시 SharedPreferences에 동기화합니다.

---

## 스키마 버전

현재 `schemaVersion = 1`이며 마이그레이션 로직은 미구현 상태입니다. 테이블 구조 변경 시 `build_runner` 재실행과 함께 마이그레이션 코드 추가가 필요합니다.
