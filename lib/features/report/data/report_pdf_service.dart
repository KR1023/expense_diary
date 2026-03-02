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
  });

  final File file;
  final int transactionCount;
  final int categoryTopCount;
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
    final txQuery =
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
    final txRows = await txQuery.get();
    final totalExpense = txRows.fold<int>(
      0,
      (sum, row) => sum + row.readTable(_db.expenses).expense,
    );
    final topCategories = _buildTopCategories(txRows);
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
                      startInclusive: startInclusive,
                      endExclusive: endExclusive,
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
                  _safeText(labels.dateHeader, allowUnicode: supportsUnicode),
                  _safeText(labels.nameHeader, allowUnicode: supportsUnicode),
                  _safeText(
                    labels.categoryHeader,
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
                    .map((row) {
                      final expense = row.readTable(_db.expenses);
                      final category = row.readTableOrNull(_db.category);
                      return [
                        _dateOnly(expense.expenseDate),
                        _safeText(
                          expense.expenseName,
                          allowUnicode: supportsUnicode,
                        ),
                        _safeText(
                          category?.categoryName ?? '',
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
    );
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
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
    required this.transactionsSection,
    required this.rankHeader,
    required this.categoryHeader,
    required this.amountHeader,
    required this.dateHeader,
    required this.nameHeader,
    required this.memoHeader,
    required this.unclassified,
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
  final String transactionsSection;
  final String rankHeader;
  final String categoryHeader;
  final String amountHeader;
  final String dateHeader;
  final String nameHeader;
  final String memoHeader;
  final String unclassified;
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
        transactionsSection: '거래 내역',
        rankHeader: '순위',
        categoryHeader: '카테고리',
        amountHeader: '금액',
        dateHeader: '날짜',
        nameHeader: '지출명',
        memoHeader: '메모',
        unclassified: '미분류',
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
      transactionsSection: 'Transactions',
      rankHeader: 'Rank',
      categoryHeader: 'Category',
      amountHeader: 'Amount',
      dateHeader: 'Date',
      nameHeader: 'Name',
      memoHeader: 'Memo',
      unclassified: 'Unclassified',
      pageLabel: 'Page',
    );
  }
}
