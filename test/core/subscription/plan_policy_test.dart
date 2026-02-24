import 'package:expense_diary/core/subscription/plan_policy.dart';
import 'package:expense_diary/core/subscription/plan_type.dart';
import 'package:expense_diary/core/time/week_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlanPolicy flags', () {
    test('Free plan capabilities', () {
      const policy = PlanPolicy(PlanType.free);

      expect(policy.isCloudOrAbove, isFalse);
      expect(policy.isReport, isFalse);
      expect(policy.canViewAds, isTrue);
      expect(policy.canBackupUnlimited, isFalse);
    });

    test('Cloud plan capabilities', () {
      const policy = PlanPolicy(PlanType.cloud);

      expect(policy.isCloudOrAbove, isTrue);
      expect(policy.isReport, isFalse);
      expect(policy.canViewAds, isFalse);
      expect(policy.canBackupUnlimited, isTrue);
    });

    test('Report plan capabilities', () {
      const policy = PlanPolicy(PlanType.report);

      expect(policy.isCloudOrAbove, isTrue);
      expect(policy.isReport, isTrue);
      expect(policy.canViewAds, isFalse);
      expect(policy.canBackupUnlimited, isTrue);
    });
  });

  group('PlanPolicy.canBackupThisWeek', () {
    const freePolicy = PlanPolicy(PlanType.free);
    const cloudPolicy = PlanPolicy(PlanType.cloud);
    final now = DateTime.utc(2026, 2, 23, 1);

    test('Free allows backup when no previous backup info exists', () {
      expect(freePolicy.canBackupThisWeek(null, now: now), isTrue);
      expect(freePolicy.canBackupThisWeek('', now: now), isTrue);
    });

    test('Free blocks backup when already backed up in same KST week', () {
      final currentWeek = KstWeekKey.now(now: now);
      expect(freePolicy.canBackupThisWeek(currentWeek, now: now), isFalse);
    });

    test('Free allows backup when last backup was in different KST week', () {
      final previousWeekInstant = DateTime.utc(2026, 2, 15, 12);
      final previousWeekKey = KstWeekKey.fromDateTime(previousWeekInstant);

      expect(freePolicy.canBackupThisWeek(previousWeekKey, now: now), isTrue);
    });

    test('Cloud ignores weekly limit', () {
      final currentWeek = KstWeekKey.now(now: now);
      expect(cloudPolicy.canBackupThisWeek(currentWeek, now: now), isTrue);
    });
  });

  group('BackupLimitStorageKeys', () {
    test('defines local state keys for weekly backup quota', () {
      expect(BackupLimitStorageKeys.lastBackupAt, isNotEmpty);
      expect(BackupLimitStorageKeys.lastBackupWeekKey, isNotEmpty);
    });
  });
}
