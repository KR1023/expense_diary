import 'package:expense_diary/core/subscription/plan_type.dart';
import 'package:expense_diary/core/time/week_key.dart';

class BackupLimitStorageKeys {
  const BackupLimitStorageKeys._();

  /// ISO-8601 timestamp string (recommended UTC) of the last backup attempt/success.
  static const String lastBackupAt = 'backup.last_backup_at';

  /// KST ISO week key (`YYYY-WW`) used for Free weekly backup quota checks.
  static const String lastBackupWeekKey = 'backup.last_backup_week_key';

  // Optional cloud-mirrored fields for cross-device consistency.
  static const String cloudLastBackupAt = 'lastBackupAt';
  static const String cloudLastBackupWeekKey = 'lastBackupWeekKey';
}

class PlanPolicy {
  const PlanPolicy(this.planType);

  final PlanType planType;

  bool get isCloudOrAbove => planType.isCloudOrAbove;

  bool get isReport => planType.isReport;

  /// Ads are shown only on Free.
  bool get canViewAds => planType == PlanType.free;

  /// Cloud/Report plans have unlimited backup quota.
  bool get canBackupUnlimited => isCloudOrAbove;

  /// Free plan can back up once per KST ISO week (`YYYY-WW`).
  ///
  /// Returns `true` when:
  /// - plan is Cloud/Report, or
  /// - [lastBackupWeekKey] is null/empty, or
  /// - [lastBackupWeekKey] differs from the current KST week key.
  bool canBackupThisWeek(String? lastBackupWeekKey, {DateTime? now}) {
    if (canBackupUnlimited) return true;

    final normalized = lastBackupWeekKey?.trim();
    if (normalized == null || normalized.isEmpty) return true;

    final currentWeekKey = KstWeekKey.now(now: now);
    return normalized != currentWeekKey;
  }
}
