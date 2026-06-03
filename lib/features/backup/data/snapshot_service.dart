import 'package:drift/drift.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/features/backup/data/firebase_snapshot_repository.dart';
import 'package:expense_diary/features/backup/domain/snapshot.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  Future<Snapshot> buildLocalSnapshot({DateTime? now, String? name}) async {
    final expenses = await _localDatabase.select(_localDatabase.expenses).get();
    final categories =
        await _localDatabase.select(_localDatabase.category).get();
    final allPaymentMethods =
        await _localDatabase.select(_localDatabase.paymentMethods).get();
    final allRecurringExpenses =
        await _localDatabase.select(_localDatabase.recurringExpenses).get();
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();

    final transactionsJson = expenses
      .map((e) => Map<String, dynamic>.from(e.toJson()))
      .toList(growable: false)..sort((a, b) => _compareNum(a['id'], b['id']));

    final categoriesJson = categories
      .map((c) => Map<String, dynamic>.from(c.toJson()))
      .toList(growable: false)..sort((a, b) => _compareNum(a['id'], b['id']));

    final paymentMethodsJson = allPaymentMethods
      .map((m) => Map<String, dynamic>.from(m.toJson()))
      .toList(growable: false)..sort((a, b) => _compareNum(a['id'], b['id']));

    final recurringExpensesJson = allRecurringExpenses
      .map((r) => Map<String, dynamic>.from(r.toJson()))
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
      paymentMethods: paymentMethodsJson,
      recurringExpenses: recurringExpensesJson,
      settings: settingsJson,
    );

    final createdAt = now ?? DateTime.now().toUtc();
    return Snapshot.create(
      snapshotId: _uuid.v4(),
      createdAt: createdAt,
      name: name?.trim() ?? '',
      schemaVersion: _localDatabase.schemaVersion,
      appVersion: _appVersion,
      payload: payload,
    );
  }

  Future<void> uploadSnapshot(String uid, Snapshot snapshot) {
    return _firebaseRepository.uploadSnapshot(uid, snapshot);
  }

  Future<({DateTime? lastBackupAt, String? lastBackupWeekKey})>
  getBackupMetadata(String uid) {
    return _firebaseRepository.getBackupMetadata(uid);
  }

  Future<List<SnapshotMeta>> listSnapshots(String uid) {
    return _firebaseRepository.listSnapshots(uid);
  }

  Future<void> deleteSnapshot(String uid, String snapshotId) {
    return _firebaseRepository.deleteSnapshot(uid, snapshotId);
  }

  Future<void> deleteAllSnapshots(String uid) {
    return _firebaseRepository.deleteAllSnapshots(uid);
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

    await _localDatabase.transaction(() async {
      // FK 순서에 따라 참조 테이블부터 삭제
      await _localDatabase.delete(_localDatabase.expenses).go();
      await _localDatabase.delete(_localDatabase.recurringExpenses).go();
      await _localDatabase.delete(_localDatabase.category).go();
      await _localDatabase.delete(_localDatabase.paymentMethods).go();

      // 결제 수단 복원 (이전 백업에 없으면 빈 목록)
      final pmList =
          payload.paymentMethods..sort((a, b) => _compareNum(a['id'], b['id']));
      for (final pm in pmList) {
        await _localDatabase
            .into(_localDatabase.paymentMethods)
            .insert(
              PaymentMethodsCompanion(
                id: Value(pm['id'] as int),
                type: Value(pm['type'] as String? ?? 'other'),
                name: Value(pm['name'] as String? ?? ''),
                memo: Value(pm['memo'] as String?),
                sortOrder: Value(
                  pm['sort_order'] as int? ?? pm['sortOrder'] as int? ?? 0,
                ),
                isArchived: Value(
                  pm['is_archived'] as bool? ??
                      pm['isArchived'] as bool? ??
                      false,
                ),
                createdAt: Value(
                  _parseDateTime(pm['created_at'] ?? pm['createdAt']),
                ),
                updatedAt: Value(
                  _parseDateTime(pm['updated_at'] ?? pm['updatedAt']),
                ),
              ),
            );
      }

      // 분류 복원
      final catList =
          payload.categories..sort((a, b) => _compareNum(a['id'], b['id']));
      for (final cat in catList) {
        await _localDatabase
            .into(_localDatabase.category)
            .insert(
              CategoryCompanion(
                id: Value(cat['id'] as int),
                categoryName: Value(
                  cat['category_name'] as String? ??
                      cat['categoryName'] as String? ??
                      '',
                ),
                usePresetAmount: Value(
                  cat['use_preset_amount'] as bool? ??
                      cat['usePresetAmount'] as bool? ??
                      false,
                ),
                presetAmount: Value(
                  cat['preset_amount'] as int? ?? cat['presetAmount'] as int?,
                ),
                autoFillExpenseName: Value(
                  cat['auto_fill_expense_name'] as bool? ??
                      cat['autoFillExpenseName'] as bool? ??
                      false,
                ),
              ),
            );
      }

      // 고정 지출 복원 (이전 백업에 없으면 빈 목록)
      final reList =
          payload.recurringExpenses
            ..sort((a, b) => _compareNum(a['id'], b['id']));
      for (final re in reList) {
        await _localDatabase
            .into(_localDatabase.recurringExpenses)
            .insert(
              RecurringExpensesCompanion(
                id: Value(re['id'] as int),
                name: Value(re['name'] as String? ?? ''),
                amount: Value(re['amount'] as int? ?? 0),
                categoryId: Value(
                  re['category_id'] as int? ?? re['categoryId'] as int?,
                ),
                paymentMethodId: Value(
                  re['payment_method_id'] as int? ??
                      re['paymentMethodId'] as int?,
                ),
                detail: Value(re['detail'] as String?),
                frequency: Value(re['frequency'] as String? ?? 'monthly'),
                interval: Value(re['interval'] as int? ?? 1),
                startDate: Value(
                  _parseDateTime(re['start_date'] ?? re['startDate']),
                ),
                endDate: Value(
                  _parseDateTimeNullable(re['end_date'] ?? re['endDate']),
                ),
                nextRunDate: Value(
                  _parseDateTime(re['next_run_date'] ?? re['nextRunDate']),
                ),
                isActive: Value(
                  re['is_active'] as bool? ?? re['isActive'] as bool? ?? true,
                ),
                createdAt: Value(
                  _parseDateTime(re['created_at'] ?? re['createdAt']),
                ),
                updatedAt: Value(
                  _parseDateTime(re['updated_at'] ?? re['updatedAt']),
                ),
              ),
            );
      }

      // 지출 복원
      final expList =
          payload.transactions..sort((a, b) => _compareNum(a['id'], b['id']));
      for (final exp in expList) {
        await _localDatabase
            .into(_localDatabase.expenses)
            .insert(
              ExpensesCompanion(
                id: Value(exp['id'] as int),
                categoryId: Value(
                  exp['category_id'] as int? ?? exp['categoryId'] as int?,
                ),
                expenseName: Value(
                  exp['expense_name'] as String? ??
                      exp['expenseName'] as String? ??
                      '',
                ),
                expense: Value(exp['expense'] as int? ?? 0),
                expenseDate: Value(
                  _parseDateTime(exp['expense_date'] ?? exp['expenseDate']),
                ),
                expenseDetail: Value(
                  exp['expense_detail'] as String? ??
                      exp['expenseDetail'] as String?,
                ),
                paymentMethodId: Value(
                  exp['payment_method_id'] as int? ??
                      exp['paymentMethodId'] as int?,
                ),
                recurringExpenseId: Value(
                  exp['recurring_expense_id'] as int? ??
                      exp['recurringExpenseId'] as int?,
                ),
                recurringOccurrenceDate: Value(
                  _parseDateTimeNullable(
                    exp['recurring_occurrence_date'] ??
                        exp['recurringOccurrenceDate'],
                  ),
                ),
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

  /// Drift 기본 직렬화는 DateTime을 unix timestamp(ms, int)로 저장한다.
  /// String(ISO 8601), DateTime 객체, int/double 모두 처리한다.
  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.now();
  }

  DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }
}
