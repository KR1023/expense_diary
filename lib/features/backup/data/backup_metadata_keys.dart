class BackupMetadataKeys {
  const BackupMetadataKeys._();

  static const String lastBackupAt = 'backup.last_backup_at';
  static const String lastBackupWeekKey = 'backup.last_backup_week_key';

  // Keep existing Firestore field names so previously saved metadata remains readable.
  static const String cloudLastBackupAt = 'lastBackupAt';
  static const String cloudLastBackupWeekKey = 'lastBackupWeekKey';
}
