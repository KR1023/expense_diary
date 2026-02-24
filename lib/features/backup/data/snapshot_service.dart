import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/core/time/week_key.dart';
import 'package:expense_diary/features/backup/data/firebase_snapshot_repository.dart';
import 'package:expense_diary/features/backup/domain/snapshot.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class BackupQuotaExceededException implements Exception {
  const BackupQuotaExceededException();
}

class SnapshotService {
  SnapshotService({
    required LocalDatabase localDatabase,
    FirebaseSnapshotRepository? firebaseRepository,
    SharedPreferences? sharedPreferences,
    AppSettings? appSettings,
    Uuid? uuid,
    String? appVersion,
  }) : _localDatabase = localDatabase,
       _firebaseRepository = firebaseRepository ?? FirebaseSnapshotRepository(),
       _sharedPreferences = sharedPreferences,
       _appSettings = appSettings,
       _uuid = uuid ?? const Uuid(),
       _appVersion =
           appVersion ??
           const String.fromEnvironment('APP_VERSION', defaultValue: 'unknown');

  final LocalDatabase _localDatabase;
  final FirebaseSnapshotRepository _firebaseRepository;
  final SharedPreferences? _sharedPreferences;
  final AppSettings? _appSettings;
  final Uuid _uuid;
  final String _appVersion;

  Future<Snapshot> buildLocalSnapshot({DateTime? now}) async {
    final expenses = await _localDatabase.select(_localDatabase.expenses).get();
    final categories =
        await _localDatabase.select(_localDatabase.category).get();
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();

    final transactionsJson = expenses
      .map((e) => Map<String, dynamic>.from(e.toJson()))
      .toList(growable: false)..sort((a, b) => _compareNum(a['id'], b['id']));

    final categoriesJson = categories
      .map((c) => Map<String, dynamic>.from(c.toJson()))
      .toList(growable: false)..sort((a, b) => _compareNum(a['id'], b['id']));

    final settingsJson = <String, dynamic>{
      'followSystemLocale': prefs.getBool('follow_system_locale') ?? true,
      'userLocale': prefs.getString('user_locale') ?? 'en',
      'userCurrency':
          prefs.getString(AppSettings.currencyPreferenceKey) ??
          AppSettings.defaultCurrency,
    };

    final payload = SnapshotPayload(
      transactions: transactionsJson,
      categories: categoriesJson,
      settings: settingsJson,
    );

    final createdAt = now ?? DateTime.now().toUtc();
    return Snapshot.create(
      snapshotId: _uuid.v4(),
      createdAt: createdAt,
      schemaVersion: _localDatabase.schemaVersion,
      appVersion: _appVersion,
      payload: payload,
    );
  }

  Future<void> uploadSnapshot(String uid, Snapshot snapshot) {
    return _firebaseRepository.uploadSnapshot(uid, snapshot);
  }

  Future<void> uploadSnapshotForFreePlan(String uid, Snapshot snapshot) async {
    final weekKey = KstWeekKey.fromDateTime(snapshot.meta.createdAt.toUtc());
    try {
      await _firebaseRepository.uploadSnapshotWithWeeklyQuotaCheck(
        uid,
        snapshot,
        weekKey: weekKey,
      );
    } on WeeklyBackupQuotaExceededException {
      throw const BackupQuotaExceededException();
    }
  }

  Future<({DateTime? lastBackupAt, String? lastBackupWeekKey})> getBackupQuota(
    String uid,
  ) {
    return _firebaseRepository.getBackupQuota(uid);
  }

  Future<List<SnapshotMeta>> listSnapshots(String uid) {
    return _firebaseRepository.listSnapshots(uid);
  }

  Future<Snapshot> downloadSnapshot(
    String uid,
    String snapshotId, {
    bool verifyHash = true,
  }) async {
    final snapshot = await _firebaseRepository.downloadSnapshot(
      uid,
      snapshotId,
    );
    if (verifyHash && !snapshot.verifyHash()) {
      throw const SnapshotIntegrityException(
        'Downloaded snapshot hash does not match payload hash.',
      );
    }
    return snapshot;
  }

  Future<void> restoreSnapshotToLocal(
    Snapshot snapshot, {
    bool verifyHash = true,
  }) async {
    if (verifyHash && !snapshot.verifyHash()) {
      throw const SnapshotIntegrityException(
        'Snapshot hash verification failed before restore.',
      );
    }

    final payload = snapshot.payload;
    final categories = payload.categories
      .map(CategoryData.fromJson)
      .toList(growable: false)..sort((a, b) => a.id.compareTo(b.id));
    final expenses = payload.transactions
      .map(Expense.fromJson)
      .toList(growable: false)..sort((a, b) => a.id.compareTo(b.id));

    await _localDatabase.transaction(() async {
      await _localDatabase.delete(_localDatabase.expenses).go();
      await _localDatabase.delete(_localDatabase.category).go();

      for (final category in categories) {
        await _localDatabase
            .into(_localDatabase.category)
            .insert(
              CategoryCompanion(
                id: Value(category.id),
                categoryName: Value(category.categoryName),
              ),
            );
      }

      for (final expense in expenses) {
        await _localDatabase
            .into(_localDatabase.expenses)
            .insert(
              ExpensesCompanion(
                id: Value(expense.id),
                categoryId:
                    expense.categoryId == null
                        ? const Value.absent()
                        : Value(expense.categoryId),
                expenseName: Value(expense.expenseName),
                expense: Value(expense.expense),
                expenseDate: Value(expense.expenseDate),
                expenseDetail:
                    expense.expenseDetail == null
                        ? const Value.absent()
                        : Value(expense.expenseDetail),
              ),
            );
      }
    });

    await _restoreSettings(payload.settings);
  }

  Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();

    final followSystemLocale = settings['followSystemLocale'];
    if (followSystemLocale is bool) {
      await prefs.setBool('follow_system_locale', followSystemLocale);
    }

    final userLocale = settings['userLocale'];
    if (userLocale is String && userLocale.isNotEmpty) {
      await prefs.setString('user_locale', userLocale);
    }

    final userCurrency = settings['userCurrency'];
    if (userCurrency is String && userCurrency.isNotEmpty) {
      final appSettings = _appSettings;
      if (appSettings != null) {
        await appSettings.setCurrencyCode(userCurrency);
      } else {
        await prefs.setString(AppSettings.currencyPreferenceKey, userCurrency);
      }
    }
  }

  int _compareNum(dynamic a, dynamic b) {
    final ai = (a as num?)?.toInt() ?? 0;
    final bi = (b as num?)?.toInt() ?? 0;
    return ai.compareTo(bi);
  }
}
