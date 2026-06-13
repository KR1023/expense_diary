import 'dart:io';

import 'package:drift/drift.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportResult {
  const PdfExportResult({
    required this.file,
    required this.transactionCount,
    required this.categoryTopCount,
    required this.paymentMethodTotalCount,
    required this.previewLines,
  });

  final File file;
  final int transactionCount;
  final int categoryTopCount;
  final int paymentMethodTotalCount;
  final List<String> previewLines;
}

class ReportPdfService {
  ReportPdfService({required LocalDatabase localDatabase})
    : _db = localDatabase;

  final LocalDatabase _db;

  Future<PdfExportResult> exportMonthlyReportPdf({
    required DateTime month,
    required String languageCode,
    String? fileNamePrefix,
  }) {
    final startInclusive = DateTime(month.year, month.month, 1);
    final endExclusive = DateTime(month.year, month.month + 1, 1);
    return exportReportPdf(
      startInclusive: startInclusive,
      endExclusive: endExclusive,
      languageCode: languageCode,
      isMonthlyRange: true,
      monthAnchor: month,
      fileNamePrefix: fileNamePrefix,
    );
  }

  Future<PdfExportResult> exportReportPdf({
    required DateTime startInclusive,
    required DateTime endExclusive,
    required String languageCode,
    required bool isMonthlyRange,
    DateTime? monthAnchor,
    String? fileNamePrefix,
  }) async {
    final (effectiveStart, effectiveEnd) = _effectiveRange(
      startInclusive: startInclusive,
      endExclusive: endExclusive,
      isMonthlyRange: isMonthlyRange,
      monthAnchor: monthAnchor,
    );

    final txQuery =
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
    final txRows = await txQuery.get();
    final totalExpense = txRows.fold<int>(
      0,
      (sum, row) => sum + row.readTable(_db.expenses).expense,
    );
    final topCategories = _buildTopCategories(txRows);
    final paymentMethodTotals = _buildPaymentMethodTotals(txRows);
    final pdfThemeContext = await _buildPdfThemeContext();
    final supportsUnicode = pdfThemeContext.supportsUnicode;
    final labels = _PdfLabels.fromLanguageCode(languageCode);

    final pdf = pw.Document(
      title: _safeText(labels.documentTitle, allowUnicode: supportsUnicode),
      author: 'expense_diary',
      creator: 'expense_diary',
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          pageFormat: PdfPageFormat.a4,
          theme: pdfThemeContext.theme,
        ),
        footer:
            (context) => pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                '${_safeText(labels.pageLabel, allowUnicode: supportsUnicode)} ${context.pageNumber} / ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  _safeText(
                    _reportTitle(
                      labels: labels,
                      startInclusive: effectiveStart,
                      endExclusive: effectiveEnd,
                      isMonthlyRange: isMonthlyRange,
                      monthAnchor: monthAnchor,
                      languageCode: languageCode,
                    ),
                    allowUnicode: supportsUnicode,
                  ),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                _safeText(
                  labels.summaryDescription,
                  allowUnicode: supportsUnicode,
                ),
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: [
                  _safeText(labels.metricHeader, allowUnicode: supportsUnicode),
                  _safeText(labels.valueHeader, allowUnicode: supportsUnicode),
                ],
                data: [
                  [
                    _safeText(
                      labels.totalExpense,
                      allowUnicode: supportsUnicode,
                    ),
                    totalExpense.toString(),
                  ],
                  [
                    _safeText(
                      labels.transactions,
                      allowUnicode: supportsUnicode,
                    ),
                    txRows.length.toString(),
                  ],
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                _safeText(
                  '${labels.categoryTop} (${topCategories.length})',
                  allowUnicode: supportsUnicode,
                ),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: [
                  _safeText(labels.rankHeader, allowUnicode: supportsUnicode),
                  _safeText(
                    labels.categoryHeader,
                    allowUnicode: supportsUnicode,
                  ),
                  _safeText(labels.amountHeader, allowUnicode: supportsUnicode),
                ],
                data: topCategories
                    .asMap()
                    .entries
                    .map(
                      (entry) => [
                        '${entry.key + 1}',
                        _safeText(
                          entry.value.category.isEmpty
                              ? labels.unclassified
                              : entry.value.category,
                          allowUnicode: supportsUnicode,
                        ),
                        entry.value.total.toString(),
                      ],
                    )
                    .toList(growable: false),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                _safeText(
                  '${labels.paymentMethodTotals} (${paymentMethodTotals.length})',
                  allowUnicode: supportsUnicode,
                ),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: [
                  _safeText(labels.rankHeader, allowUnicode: supportsUnicode),
                  _safeText(
                    labels.paymentMethodHeader,
                    allowUnicode: supportsUnicode,
                  ),
                  _safeText(labels.amountHeader, allowUnicode: supportsUnicode),
                ],
                data: paymentMethodTotals
                    .asMap()
                    .entries
                    .map(
                      (entry) => [
                        '${entry.key + 1}',
                        _safeText(
                          entry.value.name.isEmpty
                              ? labels.noPaymentMethod
                              : entry.value.name,
                          allowUnicode: supportsUnicode,
                        ),
                        entry.value.total.toString(),
                      ],
                    )
                    .toList(growable: false),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                _safeText(
                  labels.transactionsSection,
                  allowUnicode: supportsUnicode,
                ),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: [
                  _safeText(
                    labels.sequenceHeader,
                    allowUnicode: supportsUnicode,
                  ),
                  _safeText(labels.dateHeader, allowUnicode: supportsUnicode),
                  _safeText(labels.nameHeader, allowUnicode: supportsUnicode),
                  _safeText(
                    labels.categoryHeader,
                    allowUnicode: supportsUnicode,
                  ),
                  _safeText(
                    labels.paymentMethodHeader,
                    allowUnicode: supportsUnicode,
                  ),
                  _safeText(labels.amountHeader, allowUnicode: supportsUnicode),
                  _safeText(labels.memoHeader, allowUnicode: supportsUnicode),
                ],
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                data: txRows
                    .asMap()
                    .entries
                    .map((entry) {
                      final row = entry.value;
                      final expense = row.readTable(_db.expenses);
                      final category = row.readTableOrNull(_db.category);
                      final paymentMethod = row.readTableOrNull(
                        _db.paymentMethods,
                      );
                      return [
                        '${entry.key + 1}',
                        _dateOnly(expense.expenseDate),
                        _safeText(
                          expense.expenseName,
                          allowUnicode: supportsUnicode,
                        ),
                        _safeText(
                          category?.categoryName ?? '',
                          allowUnicode: supportsUnicode,
                        ),
                        _safeText(
                          paymentMethod?.name ?? labels.noPaymentMethod,
                          allowUnicode: supportsUnicode,
                        ),
                        expense.expense.toString(),
                        _safeText(
                          expense.expenseDetail ?? '',
                          allowUnicode: supportsUnicode,
                        ),
                      ];
                    })
                    .toList(growable: false),
              ),
            ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(dir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final baseName = fileNamePrefix ?? 'expense_report_pdf';
    final file = File(p.join(exportDir.path, '${baseName}_$timestamp.pdf'));
    await file.writeAsBytes(await pdf.save());

    return PdfExportResult(
      file: file,
      transactionCount: txRows.length,
      categoryTopCount: topCategories.length,
      paymentMethodTotalCount: paymentMethodTotals.length,
      previewLines: _buildPreviewLines(
        labels: labels,
        title: _reportTitle(
          labels: labels,
          startInclusive: effectiveStart,
          endExclusive: effectiveEnd,
          isMonthlyRange: isMonthlyRange,
          monthAnchor: monthAnchor,
          languageCode: languageCode,
        ),
        totalExpense: totalExpense,
        txRows: txRows,
        topCategories: topCategories,
        paymentMethodTotals: paymentMethodTotals,
      ),
    );
  }

  List<String> _buildPreviewLines({
    required _PdfLabels labels,
    required String title,
    required int totalExpense,
    required List<TypedResult> txRows,
    required List<_CategoryTotal> topCategories,
    required List<_PaymentMethodTotal> paymentMethodTotals,
  }) {
    final lines = <String>[
      title,
      '',
      labels.summaryDescription,
      '${labels.totalExpense}: $totalExpense',
      '${labels.transactions}: ${txRows.length}',
      '',
      '${labels.categoryTop} (${topCategories.length})',
      ...topCategories.take(8).map((item) {
        final name =
            item.category.isEmpty ? labels.unclassified : item.category;
        return '- $name: ${item.total}';
      }),
      '',
      '${labels.paymentMethodTotals} (${paymentMethodTotals.length})',
      ...paymentMethodTotals.take(8).map((item) {
        final name = item.name.isEmpty ? labels.noPaymentMethod : item.name;
        return '- $name: ${item.total}';
      }),
      '',
      labels.transactionsSection,
      [
        labels.sequenceHeader,
        labels.dateHeader,
        labels.nameHeader,
        labels.categoryHeader,
        labels.paymentMethodHeader,
        labels.amountHeader,
        labels.memoHeader,
      ].join(' | '),
    ];

    for (final entry in txRows.take(30).toList().asMap().entries) {
      final row = entry.value;
      final expense = row.readTable(_db.expenses);
      final category = row.readTableOrNull(_db.category);
      final paymentMethod = row.readTableOrNull(_db.paymentMethods);
      lines.add(
        [
          '${entry.key + 1}',
          _dateOnly(expense.expenseDate),
          expense.expenseName,
          category?.categoryName ?? '',
          paymentMethod?.name ?? labels.noPaymentMethod,
          '${expense.expense}',
          expense.expenseDetail ?? '',
        ].join(' | '),
      );
    }

    if (txRows.length > 30) {
      lines.add('... ${txRows.length - 30} more');
    }

    return lines;
  }

  List<_CategoryTotal> _buildTopCategories(List<TypedResult> txRows) {
    final totals = <String, int>{};
    for (final row in txRows) {
      final expense = row.readTable(_db.expenses);
      final category = row.readTableOrNull(_db.category);
      final categoryName = category?.categoryName ?? '';
      totals.update(
        categoryName,
        (v) => v + expense.expense,
        ifAbsent: () => expense.expense,
      );
    }

    final items = totals.entries
      .map((entry) => _CategoryTotal(category: entry.key, total: entry.value))
      .toList(growable: false)..sort((a, b) => b.total.compareTo(a.total));

    return items.take(10).toList(growable: false);
  }

  List<_PaymentMethodTotal> _buildPaymentMethodTotals(
    List<TypedResult> txRows,
  ) {
    final totals = <String, _PaymentMethodTotal>{};
    for (final row in txRows) {
      final expense = row.readTable(_db.expenses);
      final paymentMethod = row.readTableOrNull(_db.paymentMethods);
      final id = expense.paymentMethodId;
      final key = id?.toString() ?? 'none';
      final current = totals[key];
      totals[key] = _PaymentMethodTotal(
        id: id,
        name: paymentMethod?.name ?? '',
        total: (current?.total ?? 0) + expense.expense,
      );
    }

    return totals.values.toList(growable: false)
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  String _reportTitle({
    required _PdfLabels labels,
    required DateTime startInclusive,
    required DateTime endExclusive,
    required bool isMonthlyRange,
    required DateTime? monthAnchor,
    required String languageCode,
  }) {
    final normalized = languageCode.toLowerCase();
    if (isMonthlyRange) {
      final month = monthAnchor ?? startInclusive;
      if (normalized.startsWith('ko')) {
        return '${DateFormat('yyyy.MM').format(month)} ${labels.monthlySuffix}';
      }
      return '${labels.documentTitle} (${DateFormat('yyyy-MM').format(month)})';
    }

    final endInclusive = endExclusive.subtract(const Duration(days: 1));
    if (normalized.startsWith('ko')) {
      return '${labels.documentTitle} (${DateFormat('yyyy.MM.dd').format(startInclusive)} ~ ${DateFormat('yyyy.MM.dd').format(endInclusive)})';
    }
    return '${labels.documentTitle} (${DateFormat('yyyy-MM-dd').format(startInclusive)} ~ ${DateFormat('yyyy-MM-dd').format(endInclusive)})';
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

  String _safeText(String value, {required bool allowUnicode}) {
    // Minimal template: avoid layout breaks from line breaks and tabs.
    final normalized = value
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\t', ' ');
    if (allowUnicode) return normalized;

    final buffer = StringBuffer();
    for (final rune in normalized.runes) {
      if (rune >= 0x20 && rune <= 0x7E) {
        buffer.writeCharCode(rune);
      } else {
        buffer.write('?');
      }
    }
    return buffer.toString();
  }

  Future<_PdfThemeContext> _buildPdfThemeContext() async {
    final font = await _loadKoreanCapableFont();
    if (font == null) {
      return _PdfThemeContext(
        theme: pw.ThemeData.base(),
        supportsUnicode: false,
      );
    }

    return _PdfThemeContext(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font,
        italic: font,
        boldItalic: font,
      ),
      supportsUnicode: true,
    );
  }

  Future<pw.Font?> _loadKoreanCapableFont() async {
    final assetCandidates = [
      'assets/fonts/NanumGothic-Regular.ttf',
      'asset/fonts/NotoSansKR-Regular.ttf',
      'assets/fonts/NotoSansKR-Regular.ttf',
    ];

    for (final assetPath in assetCandidates) {
      try {
        final bytes = await rootBundle.load(assetPath);
        return pw.Font.ttf(bytes);
      } catch (_) {
        // Try next candidate.
      }
    }

    final fileCandidates = <String>[
      const String.fromEnvironment('PDF_KR_FONT_PATH', defaultValue: ''),
      '/System/Library/Fonts/Supplemental/AppleGothic.ttf',
      '/System/Library/Fonts/AppleSDGothicNeo.ttc',
    ].where((e) => e.isNotEmpty);

    for (final path in fileCandidates) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        return pw.Font.ttf(bytes.buffer.asByteData());
      } catch (e) {
        debugPrint('ReportPdfService font load failed for $path: $e');
      }
    }

    debugPrint(
      'ReportPdfService: Korean-capable font not found. Falling back to default PDF font.',
    );
    return null;
  }
}

class _PdfThemeContext {
  const _PdfThemeContext({required this.theme, required this.supportsUnicode});

  final pw.ThemeData theme;
  final bool supportsUnicode;
}

class _CategoryTotal {
  const _CategoryTotal({required this.category, required this.total});

  final String category;
  final int total;
}

class _PaymentMethodTotal {
  const _PaymentMethodTotal({
    required this.id,
    required this.name,
    required this.total,
  });

  final int? id;
  final String name;
  final int total;
}

class _PdfLabels {
  const _PdfLabels({
    required this.documentTitle,
    required this.monthlySuffix,
    required this.summaryDescription,
    required this.metricHeader,
    required this.valueHeader,
    required this.totalExpense,
    required this.transactions,
    required this.categoryTop,
    required this.paymentMethodTotals,
    required this.transactionsSection,
    required this.rankHeader,
    required this.categoryHeader,
    required this.paymentMethodHeader,
    required this.sequenceHeader,
    required this.amountHeader,
    required this.dateHeader,
    required this.nameHeader,
    required this.memoHeader,
    required this.unclassified,
    required this.noPaymentMethod,
    required this.pageLabel,
  });

  final String documentTitle;
  final String monthlySuffix;
  final String summaryDescription;
  final String metricHeader;
  final String valueHeader;
  final String totalExpense;
  final String transactions;
  final String categoryTop;
  final String paymentMethodTotals;
  final String transactionsSection;
  final String rankHeader;
  final String categoryHeader;
  final String paymentMethodHeader;
  final String sequenceHeader;
  final String amountHeader;
  final String dateHeader;
  final String nameHeader;
  final String memoHeader;
  final String unclassified;
  final String noPaymentMethod;
  final String pageLabel;

  factory _PdfLabels.fromLanguageCode(String languageCode) {
    final normalized = languageCode.toLowerCase();
    if (normalized.startsWith('ko')) {
      return const _PdfLabels(
        documentTitle: '지출 보고서',
        monthlySuffix: '월간 보고서',
        summaryDescription: '요약 (현재 SQLite 스키마 기준)',
        metricHeader: '항목',
        valueHeader: '값',
        totalExpense: '총 지출',
        transactions: '거래 건수',
        categoryTop: '카테고리 TOP',
        paymentMethodTotals: '결제 수단별 합계',
        transactionsSection: '거래 내역',
        rankHeader: '순위',
        categoryHeader: '카테고리',
        paymentMethodHeader: '결제 수단',
        sequenceHeader: '순서',
        amountHeader: '금액',
        dateHeader: '날짜',
        nameHeader: '지출명',
        memoHeader: '메모',
        unclassified: '미분류',
        noPaymentMethod: '미지정',
        pageLabel: '페이지',
      );
    }

    return const _PdfLabels(
      documentTitle: 'Expense Report',
      monthlySuffix: 'Monthly Report',
      summaryDescription: 'Summary (SQLite-based)',
      metricHeader: 'Metric',
      valueHeader: 'Value',
      totalExpense: 'Total Expense',
      transactions: 'Transactions',
      categoryTop: 'Category Top',
      paymentMethodTotals: 'Payment Method Totals',
      transactionsSection: 'Transactions',
      rankHeader: 'Rank',
      categoryHeader: 'Category',
      paymentMethodHeader: 'Payment Method',
      sequenceHeader: 'No.',
      amountHeader: 'Amount',
      dateHeader: 'Date',
      nameHeader: 'Name',
      memoHeader: 'Memo',
      unclassified: 'Unclassified',
      noPaymentMethod: 'Unspecified',
      pageLabel: 'Page',
    );
  }
}
