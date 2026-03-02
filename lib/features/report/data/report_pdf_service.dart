import 'dart:io';

import 'package:drift/drift.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    String? fileNamePrefix,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final endExclusive = DateTime(month.year, month.month + 1, 1);

    final monthlyExpense = await _db.selectMonthExpense(month).first;
    final categoryItems = await _db.watchMonthlyCategoryExpense(month).first;
    final sortedCategories = [...categoryItems]
      ..sort((a, b) => b.total.compareTo(a.total));
    final topCategories = sortedCategories.take(10).toList(growable: false);

    final txQuery =
        _db.select(_db.expenses).join([
            leftOuterJoin(
              _db.category,
              _db.category.id.equalsExp(_db.expenses.categoryId),
            ),
          ])
          ..where(_db.expenses.expenseDate.isBetweenValues(start, endExclusive))
          ..orderBy([OrderingTerm.asc(_db.expenses.expenseDate)]);
    final txRows = await txQuery.get();
    final pdfThemeContext = await _buildPdfThemeContext();
    final supportsUnicode = pdfThemeContext.supportsUnicode;

    final pdf = pw.Document(
      title: 'Expense Monthly Report',
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
                'Page ${context.pageNumber} / ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Expense Monthly Report (${month.year}-${month.month.toString().padLeft(2, '0')})',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Summary (SQLite-based, income is not stored in current schema)',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: const ['Metric', 'Value'],
                data: [
                  ['Total Expense', monthlyExpense.toString()],
                  ['Transactions', txRows.length.toString()],
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'Category Top (${topCategories.length})',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: const ['Rank', 'Category', 'Amount'],
                data: topCategories
                    .asMap()
                    .entries
                    .map(
                      (entry) => [
                        '${entry.key + 1}',
                        _safeText(
                          entry.value.category.isEmpty
                              ? 'Unclassified'
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
                'Transactions',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: const ['Date', 'Name', 'Category', 'Amount', 'Memo'],
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
