import 'package:expense_diary/core/time/week_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KstWeekKey', () {
    test('returns YYYY-WW format', () {
      final key = KstWeekKey.fromDateTime(DateTime.utc(2026, 2, 23, 0));
      expect(RegExp(r'^\d{4}-\d{2}$').hasMatch(key), isTrue);
    });

    test('changes at Monday 00:00 KST boundary', () {
      final justBefore = DateTime.utc(
        2026,
        2,
        22,
        14,
        59,
        59,
      ); // Sun 23:59:59 KST
      final atBoundary = DateTime.utc(
        2026,
        2,
        22,
        15,
        0,
        0,
      ); // Mon 00:00:00 KST

      final beforeKey = KstWeekKey.fromDateTime(justBefore);
      final afterKey = KstWeekKey.fromDateTime(atBoundary);

      expect(beforeKey, isNot(equals(afterKey)));
    });

    test('startOfWeekKst returns Monday 00:00 KST wall time', () {
      final start = KstWeekKey.startOfWeekKst(DateTime.utc(2026, 2, 25, 3));

      expect(start.weekday, DateTime.monday);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });
  });
}
