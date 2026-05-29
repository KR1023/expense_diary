# 클라우드 데이터 저장 방식 (Firestore)

## 개요

Firebase Firestore를 사용하며, 로그인한 사용자 단위로 데이터가 격리됩니다.  
현재 두 가지 용도로 사용됩니다.

| 용도 | 상태 |
|---|---|
| 클라우드 백업/복원 (스냅샷) | 활성 |
| 클라우드 트랜잭션 (`FirestoreTransactionRepository`) | 구현 존재, UI 진입점 없음 |

---

## Firestore 컬렉션 구조

```
users/{uid}/
  snapshots/{snapshotId}    ← 백업 스냅샷 본문
  meta/backupQuota          ← 마지막 백업 메타데이터
  transactions/{txId}       ← 클라우드 트랜잭션 (UI 미연결)
```

---

## 1. 백업 스냅샷 (`snapshots/{snapshotId}`)

### 도큐먼트 필드

**메타 (SnapshotMeta)**

| 필드 | 타입 | 설명 |
|---|---|---|
| snapshotId | string | UUID v4 |
| createdAt | Timestamp | 생성 시각 (UTC) |
| schemaVersion | int | SQLite 스키마 버전 |
| appVersion | string | 앱 버전 |
| dataHash | string | payload의 SHA-256 해시 (무결성 검증용) |
| sizeBytes | int | payload JSON의 UTF-8 바이트 크기 |
| payloadStoragePath | string? | 향후 Firebase Storage 확장용 (현재 미사용) |

**페이로드 (SnapshotPayload)**

| 필드 | 타입 | 설명 |
|---|---|---|
| payload.transactions | array | Expenses 테이블 전체 (JSON 배열, id 순 정렬) |
| payload.categories | array | Category 테이블 전체 (JSON 배열, id 순 정렬) |
| payload.settings | object | 앱 설정 (통화, 언어) |

`payload.settings` 구조:
```json
{
  "followSystemLocale": true,
  "userLocale": "ko",
  "userCurrency": "KRW"
}
```

### 직렬화 규칙

- 모든 Map의 키를 `SplayTreeMap`으로 알파벳순 정렬 (canonical JSON)
- `DateTime`은 UTC ISO 8601 문자열로 직렬화
- SHA-256은 canonical JSON의 UTF-8 바이트에서 계산

---

## 2. 백업 메타데이터 (`meta/backupQuota`)

백업 성공 시마다 스냅샷 저장과 동일 트랜잭션으로 갱신됩니다.

| 필드 | 타입 | 설명 |
|---|---|---|
| lastBackupAt | Timestamp | 마지막 백업 시각 |
| lastBackupWeekKey | string | 마지막 백업 주차 키 (KST 기준) |

앱은 이 값을 설정 화면 진입 시 읽어 SharedPreferences에 로컬 캐시합니다.  
(`BackupMetadataKeys`: `lib/features/backup/data/backup_metadata_keys.dart`)

---

## 3. 클라우드 트랜잭션 (`transactions/{txId}`) — UI 미연결

`FirestoreTransactionRepository`가 구현되어 있지만 현재 UI 진입점이 없습니다.

| 필드 | 타입 | 설명 |
|---|---|---|
| amount | int | 금액 |
| type | string | `"income"` 또는 `"expense"` |
| categoryId | string | 카테고리 ID |
| memo | string | 메모 |
| spentAt | Timestamp | 지출 일시 |
| createdAt | Timestamp | 생성 일시 |
| updatedAt | Timestamp | 수정 일시 |
| deleted | bool | 소프트 삭제 플래그 |

---

## 백업 흐름

```
[설정 화면 → 지금 백업]
        │
        ▼
SnapshotService.buildLocalSnapshot()
  - SQLite Expenses/Category 전체 조회
  - SharedPreferences 설정 읽기
  - canonical JSON 직렬화 (키 정렬)
  - SHA-256 해시 + 바이트 크기 계산
        │
        ▼
FirebaseSnapshotRepository.uploadSnapshot()
  - Firestore 트랜잭션:
      snapshots/{snapshotId} 저장
      meta/backupQuota 갱신 (lastBackupAt, lastBackupWeekKey)
        │
        ▼
ConfigScreen 로컬 메타데이터 갱신
  - SharedPreferences backup.last_backup_at 저장
  - SharedPreferences backup.last_backup_week_key 저장
```

---

## 복원 흐름

```
[설정 화면 → 스냅샷 목록 → 복원 선택]
        │
        ▼
FirebaseSnapshotRepository.downloadSnapshot()
  - snapshots/{snapshotId} 도큐먼트 다운로드
  - Firestore Timestamp → DateTime 정규화
        │
        ▼
SnapshotService.restoreSnapshotToLocal()
  - SHA-256 해시 검증 (불일치 시 SnapshotIntegrityException)
  - Drift 트랜잭션:
      Expenses 전체 삭제
      Category 전체 삭제
      Category 재삽입 (id 순)
      Expenses 재삽입 (id 순)
  - SharedPreferences 설정 복원 (통화, 언어)
```

---

## 관련 파일

| 파일 | 역할 |
|---|---|
| `lib/features/backup/domain/snapshot.dart` | 도메인 모델 (`Snapshot`, `SnapshotMeta`, `SnapshotPayload`) |
| `lib/features/backup/data/snapshot_service.dart` | 백업/복원 오케스트레이션 |
| `lib/features/backup/data/firebase_snapshot_repository.dart` | Firestore CRUD |
| `lib/features/backup/data/backup_metadata_keys.dart` | 메타데이터 키 상수 |
| `lib/data/firestore/firestore_transaction_repository.dart` | 클라우드 트랜잭션 저장소 (UI 미연결) |
| `lib/data/firestore/transaction_dto.dart` | 클라우드 트랜잭션 DTO |
