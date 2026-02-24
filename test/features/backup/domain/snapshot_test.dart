import 'package:expense_diary/features/backup/domain/snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SnapshotPayload hash', () {
    test('is stable for same logical map order', () {
      final a = SnapshotPayload(
        transactions: const [
          {'id': 1, 'expense': 100, 'name': 'coffee'},
        ],
        categories: const [
          {'id': 10, 'categoryName': 'Food'},
        ],
        settings: const {
          'userCurrency': 'KRW',
          'followSystemLocale': true,
          'userLocale': 'ko',
        },
      );

      final b = SnapshotPayload(
        transactions: const [
          {'name': 'coffee', 'expense': 100, 'id': 1},
        ],
        categories: const [
          {'categoryName': 'Food', 'id': 10},
        ],
        settings: const {
          'userLocale': 'ko',
          'followSystemLocale': true,
          'userCurrency': 'KRW',
        },
      );

      expect(a.sha256Hex(), b.sha256Hex());
      expect(a.sizeBytes(), b.sizeBytes());
    });
  });

  group('Snapshot hash verification', () {
    test('verifyHash passes for newly created snapshot', () {
      final payload = SnapshotPayload(
        transactions: const [],
        categories: const [],
        settings: const {'userCurrency': 'KRW'},
      );

      final snapshot = Snapshot.create(
        snapshotId: 's1',
        createdAt: DateTime.utc(2026, 2, 23),
        schemaVersion: 1,
        appVersion: '2.1.0',
        payload: payload,
      );

      expect(snapshot.verifyHash(), isTrue);
    });
  });
}
