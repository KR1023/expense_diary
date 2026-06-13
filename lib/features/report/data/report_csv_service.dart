import 'dart:io';

import 'package:drift/drift.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CsvExportResult {
  const CsvExportResult({required this.file, required this.rowCount});

  final File file;
  final int rowCount;
}

class ReportCsvService {
  ReportCsvService({required LocalDatabase localDatabase})
    : _db = localDatabase;

  final LocalDatabase _db;

  Future<CsvExportResult> exportExpensesCsv({
    required DateTime startInclusive,
    required DateTime endExclusive,
    required String languageCode,
    String? fileNamePrefix,
  }) async {
    final query =
        _db.select(_db.expenses).join([
            leftOuterJoin(
              _db.category,
              _db.category.id.equalsExp(_db.expenses.categoryId),
            ),
          ])
          ..where(
            _db.expenses.expenseDate.isBiggerOrEqualValue(startInclusive) &
                _db.expenses.expenseDate.isSmallerThanValue(endExclusive),
          )
          ..orderBy([OrderingTerm.asc(_db.expenses.expenseDate)]);

    final result = await query.get();
    final labels = _CsvLabels.fromLanguageCode(languageCode);

    final csv = StringBuffer();
    csv.writeln(
      [
        labels.id,
        labels.expenseDate,
        labels.expenseName,
        labels.amount,
        labels.categoryId,
        labels.categoryName,
        labels.expenseDetail,
      ].join(','),
    );

    for (final row in result) {
      final expense = row.readTable(_db.expenses);
      final category = row.readTableOrNull(_db.category);

      csv.writeln(
        [
          expense.id,
          expense.expenseDate.toUtc().toIso8601String(),
          _escapeCsv(expense.expenseName),
          expense.expense,
          expense.categoryId ?? '',
          _escapeCsv(category?.categoryName ?? ''),
          _escapeCsv(expense.expenseDetail ?? ''),
        ].join(','),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(dir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final baseName = fileNamePrefix ?? 'expense_report';
    final file = File(p.join(exportDir.path, '${baseName}_$timestamp.csv'));
    await file.writeAsString(csv.toString());

    return CsvExportResult(file: file, rowCount: result.length);
  }

  String _escapeCsv(String raw) {
    final escaped = raw.replaceAll('"', '""');
    return '"$escaped"';
  }
}

class _CsvLabels {
  const _CsvLabels({
    required this.id,
    required this.expenseDate,
    required this.expenseName,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.expenseDetail,
  });

  final String id;
  final String expenseDate;
  final String expenseName;
  final String amount;
  final String categoryId;
  final String categoryName;
  final String expenseDetail;

  factory _CsvLabels.fromLanguageCode(String languageCode) {
    final normalized = languageCode.toLowerCase();
    if (normalized.startsWith('ko')) {
      return const _CsvLabels(
        id: '아이디',
        expenseDate: '지출일',
        expenseName: '지출명',
        amount: '금액',
        categoryId: '분류ID',
        categoryName: '분류명',
        expenseDetail: '메모',
      );
    }

    return const _CsvLabels(
      id: 'id',
      expenseDate: 'expenseDate',
      expenseName: 'expenseName',
      amount: 'amount',
      categoryId: 'categoryId',
      categoryName: 'categoryName',
      expenseDetail: 'expenseDetail',
    );
  }
}
