import 'dart:convert';
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
    bool isMonthlyRange = false,
    DateTime? monthAnchor,
    String? fileNamePrefix,
  }) async {
    final (effectiveStart, effectiveEnd) = _effectiveRange(
      startInclusive: startInclusive,
      endExclusive: endExclusive,
      isMonthlyRange: isMonthlyRange,
      monthAnchor: monthAnchor,
    );

    final query =
        _db.select(_db.expenses).join([
            leftOuterJoin(
              _db.category,
              _db.category.id.equalsExp(_db.expenses.categoryId),
            ),
            leftOuterJoin(
              _db.paymentMethods,
              _db.paymentMethods.id.equalsExp(_db.expenses.paymentMethodId),
            ),
          ])
          ..where(
            _db.expenses.expenseDate.isBiggerOrEqualValue(effectiveStart) &
                _db.expenses.expenseDate.isSmallerThanValue(effectiveEnd),
          )
          ..orderBy([OrderingTerm.asc(_db.expenses.expenseDate)]);

    final result = await query.get();
    final labels = _CsvLabels.fromLanguageCode(languageCode);

    final csv = StringBuffer();
    csv.writeln(
      [
        labels.sequence,
        labels.expenseDate,
        labels.expenseName,
        labels.amount,
        labels.categoryId,
        labels.categoryName,
        labels.paymentMethodId,
        labels.paymentMethodName,
        labels.paymentMethodType,
        labels.expenseDetail,
      ].join(','),
    );

    final paymentMethodTotals = _buildPaymentMethodTotals(result);

    for (final entry in result.asMap().entries) {
      final row = entry.value;
      final expense = row.readTable(_db.expenses);
      final category = row.readTableOrNull(_db.category);
      final paymentMethod = row.readTableOrNull(_db.paymentMethods);

      csv.writeln(
        [
          entry.key + 1,
          _dateOnly(expense.expenseDate),
          _escapeCsv(expense.expenseName),
          expense.expense,
          expense.categoryId ?? '',
          _escapeCsv(category?.categoryName ?? ''),
          expense.paymentMethodId ?? '',
          _escapeCsv(paymentMethod?.name ?? labels.noPaymentMethod),
          _escapeCsv(paymentMethod?.type ?? ''),
          _escapeCsv(expense.expenseDetail ?? ''),
        ].join(','),
      );
    }

    csv.writeln();
    csv.writeln(_escapeCsv(labels.paymentMethodSummary));
    csv.writeln(
      [
        labels.paymentMethodId,
        labels.paymentMethodName,
        labels.paymentMethodType,
        labels.amount,
      ].join(','),
    );
    for (final item in paymentMethodTotals) {
      csv.writeln(
        [
          item.id ?? '',
          _escapeCsv(item.name.isEmpty ? labels.noPaymentMethod : item.name),
          _escapeCsv(item.type),
          item.total,
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
    // Excel/Numbers on mobile can mis-detect plain UTF-8 CSV as legacy
    // encodings. A UTF-8 BOM keeps Korean text readable after sharing.
    await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(csv.toString())]);

    return CsvExportResult(file: file, rowCount: result.length);
  }

  String _escapeCsv(String raw) {
    final escaped = raw.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _dateOnly(DateTime date) {
    final localDate = date.isUtc ? date.toLocal() : date;
    final y = localDate.year.toString().padLeft(4, '0');
    final m = localDate.month.toString().padLeft(2, '0');
    final d = localDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  (DateTime, DateTime) _effectiveRange({
    required DateTime startInclusive,
    required DateTime endExclusive,
    required bool isMonthlyRange,
    required DateTime? monthAnchor,
  }) {
    if (isMonthlyRange) {
      final month = monthAnchor ?? startInclusive;
      return (
        DateTime(month.year, month.month, 1),
        DateTime(month.year, month.month + 1, 1),
      );
    }

    return (
      DateTime(startInclusive.year, startInclusive.month, startInclusive.day),
      DateTime(endExclusive.year, endExclusive.month, endExclusive.day),
    );
  }

  List<_PaymentMethodTotal> _buildPaymentMethodTotals(List<TypedResult> rows) {
    final totals = <String, _PaymentMethodTotal>{};
    for (final row in rows) {
      final expense = row.readTable(_db.expenses);
      final paymentMethod = row.readTableOrNull(_db.paymentMethods);
      final id = expense.paymentMethodId;
      final key = id?.toString() ?? 'none';
      final current = totals[key];
      totals[key] = _PaymentMethodTotal(
        id: id,
        name: paymentMethod?.name ?? '',
        type: paymentMethod?.type ?? '',
        total: (current?.total ?? 0) + expense.expense,
      );
    }

    return totals.values.toList(growable: false)
      ..sort((a, b) => b.total.compareTo(a.total));
  }
}

class _CsvLabels {
  const _CsvLabels({
    required this.sequence,
    required this.expenseDate,
    required this.expenseName,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.paymentMethodType,
    required this.paymentMethodSummary,
    required this.noPaymentMethod,
    required this.expenseDetail,
  });

  final String sequence;
  final String expenseDate;
  final String expenseName;
  final String amount;
  final String categoryId;
  final String categoryName;
  final String paymentMethodId;
  final String paymentMethodName;
  final String paymentMethodType;
  final String paymentMethodSummary;
  final String noPaymentMethod;
  final String expenseDetail;

  factory _CsvLabels.fromLanguageCode(String languageCode) {
    final normalized = languageCode.toLowerCase();
    if (normalized.startsWith('ko')) {
      return const _CsvLabels(
        sequence: '지출 순서',
        expenseDate: '지출일',
        expenseName: '지출명',
        amount: '금액',
        categoryId: '분류ID',
        categoryName: '분류명',
        paymentMethodId: '결제수단ID',
        paymentMethodName: '결제수단',
        paymentMethodType: '결제수단유형',
        paymentMethodSummary: '결제 수단별 합계',
        noPaymentMethod: '미지정',
        expenseDetail: '메모',
      );
    }

    return const _CsvLabels(
      sequence: 'No.',
      expenseDate: 'expenseDate',
      expenseName: 'expenseName',
      amount: 'amount',
      categoryId: 'categoryId',
      categoryName: 'categoryName',
      paymentMethodId: 'paymentMethodId',
      paymentMethodName: 'paymentMethod',
      paymentMethodType: 'paymentMethodType',
      paymentMethodSummary: 'Payment Method Totals',
      noPaymentMethod: 'Unspecified',
      expenseDetail: 'expenseDetail',
    );
  }
}

class _PaymentMethodTotal {
  const _PaymentMethodTotal({
    required this.id,
    required this.name,
    required this.type,
    required this.total,
  });

  final int? id;
  final String name;
  final String type;
  final int total;
}
