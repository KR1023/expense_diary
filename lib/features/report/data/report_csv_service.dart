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
            _db.expenses.expenseDate.isBetweenValues(
              startInclusive,
              endExclusive,
            ),
          )
          ..orderBy([OrderingTerm.asc(_db.expenses.expenseDate)]);

    final result = await query.get();

    final csv = StringBuffer();
    csv.writeln(
      [
        'id',
        'expenseDate',
        'expenseName',
        'amount',
        'categoryId',
        'categoryName',
        'expenseDetail',
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
