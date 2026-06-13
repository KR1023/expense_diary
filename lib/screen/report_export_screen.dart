import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/app_theme.dart';
import 'package:expense_diary/features/report/data/report_csv_service.dart';
import 'package:expense_diary/features/report/data/report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

enum _ExportFormat { csv, pdf }

enum _ExportRangeType { month, custom }

class ReportExportScreen extends StatefulWidget {
  const ReportExportScreen({super.key});

  @override
  State<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends State<ReportExportScreen> {
  _ExportFormat _format = _ExportFormat.csv;
  _ExportRangeType _rangeType = _ExportRangeType.month;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _customStart;
  late DateTime _customEnd;
  bool _exporting = false;
  File? _lastFile;
  _ExportPreview? _preview;

  ReportCsvService get _csvService => GetIt.I<ReportCsvService>();
  ReportPdfService get _pdfService => GetIt.I<ReportPdfService>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _customStart = DateTime(now.year, now.month, 1);
    _customEnd = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final (start, endExclusive) = _effectiveRange();
    final endInclusive = endExclusive.subtract(const Duration(days: 1));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'report.export.title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                'report.export.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'report.export.format'.tr(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<_ExportFormat>(
                      segments: [
                        ButtonSegment(
                          value: _ExportFormat.csv,
                          icon: const Icon(Icons.table_chart_outlined),
                          label: Text('report.export.csv'.tr()),
                        ),
                        ButtonSegment(
                          value: _ExportFormat.pdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: Text('report.export.pdf'.tr()),
                        ),
                      ],
                      selected: {_format},
                      onSelectionChanged: (value) {
                        setState(() {
                          _format = value.first;
                          _clearGeneratedFile();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'report.export.range'.tr(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<_ExportRangeType>(
                      segments: [
                        ButtonSegment(
                          value: _ExportRangeType.month,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text('report.export.month'.tr()),
                        ),
                        ButtonSegment(
                          value: _ExportRangeType.custom,
                          icon: const Icon(Icons.date_range_outlined),
                          label: Text('report.export.custom'.tr()),
                        ),
                      ],
                      selected: {_rangeType},
                      onSelectionChanged: (value) {
                        setState(() {
                          _rangeType = value.first;
                          _clearGeneratedFile();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_rangeType == _ExportRangeType.month)
                      _MonthPicker(
                        month: _selectedMonth,
                        onChanged: (value) {
                          setState(() {
                            _selectedMonth = DateTime(value.year, value.month);
                            _clearGeneratedFile();
                          });
                        },
                      )
                    else
                      _CustomRangeSelector(
                        start: _customStart,
                        end: _customEnd,
                        onStartChanged: (value) {
                          setState(() {
                            _customStart = DateTime(
                              value.year,
                              value.month,
                              value.day,
                            );
                            if (_customEnd.isBefore(_customStart)) {
                              _customEnd = _customStart;
                            }
                            _clearGeneratedFile();
                          });
                        },
                        onEndChanged: (value) {
                          setState(() {
                            _customEnd = DateTime(
                              value.year,
                              value.month,
                              value.day,
                            );
                            if (_customEnd.isBefore(_customStart)) {
                              _customStart = _customEnd;
                            }
                            _clearGeneratedFile();
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _rangeLabel(start, endInclusive),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _exporting ? null : _export,
                            icon:
                                _exporting
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.download_rounded),
                            label: Text(
                              _exporting
                                  ? 'report.export.generating'.tr()
                                  : 'report.export.generate'.tr(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                (_exporting || _lastFile == null)
                                    ? null
                                    : () => _shareLastFile(context),
                            icon: const Icon(Icons.share_outlined),
                            label: Text('report.export.share'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _preview == null
                      ? _ExportPreviewPlaceholder(format: _format)
                      : _GeneratedPreviewCard(preview: _preview!),
            ),
          ],
        ),
      ),
    );
  }

  (DateTime, DateTime) _effectiveRange() {
    if (_rangeType == _ExportRangeType.month) {
      final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      return (start, end);
    }

    final start = DateTime(
      _customStart.year,
      _customStart.month,
      _customStart.day,
    );
    final end = DateTime(_customEnd.year, _customEnd.month, _customEnd.day + 1);
    return (start, end);
  }

  Future<void> _export() async {
    if (_exporting) return;

    setState(() {
      _exporting = true;
    });

    try {
      final (start, endExclusive) = _effectiveRange();
      final endInclusive = endExclusive.subtract(const Duration(days: 1));
      final languageCode = context.locale.languageCode;
      final rangeLabel = _rangeLabel(start, endInclusive);

      if (_format == _ExportFormat.csv) {
        final result = await _csvService.exportExpensesCsv(
          startInclusive: start,
          endExclusive: endExclusive,
          languageCode: languageCode,
          isMonthlyRange: _rangeType == _ExportRangeType.month,
          monthAnchor:
              _rangeType == _ExportRangeType.month ? _selectedMonth : null,
          fileNamePrefix: _localizedPrefix(languageCode, 'csv'),
        );
        final lines = await _buildCsvPreviewLines(result.file);
        if (!mounted) return;
        setState(() {
          _lastFile = result.file;
          _preview = _ExportPreview(
            format: _ExportFormat.csv,
            fileName: p.basename(result.file.path),
            rangeLabel: rangeLabel,
            summary: 'report.export.csv_done'.tr(
              namedArgs: {'count': '${result.rowCount}'},
            ),
            rows: lines,
          );
        });
      } else {
        final result = await _pdfService.exportReportPdf(
          startInclusive: start,
          endExclusive: endExclusive,
          languageCode: languageCode,
          isMonthlyRange: _rangeType == _ExportRangeType.month,
          monthAnchor:
              _rangeType == _ExportRangeType.month ? _selectedMonth : null,
          fileNamePrefix: _localizedPrefix(languageCode, 'pdf'),
        );
        if (!mounted) return;
        setState(() {
          _lastFile = result.file;
          _preview = _ExportPreview(
            format: _ExportFormat.pdf,
            fileName: p.basename(result.file.path),
            rangeLabel: rangeLabel,
            summary: 'report.export.pdf_done'.tr(
              namedArgs: {'count': '${result.transactionCount}'},
            ),
            rows: [
              'report.export.preview_pdf_line_range'.tr(
                namedArgs: {'range': rangeLabel},
              ),
              'report.export.preview_pdf_line_transactions'.tr(
                namedArgs: {'count': '${result.transactionCount}'},
              ),
              'report.export.preview_pdf_line_categories'.tr(
                namedArgs: {'count': '${result.categoryTopCount}'},
              ),
              'report.export.preview_pdf_line_payment_methods'.tr(
                namedArgs: {'count': '${result.paymentMethodTotalCount}'},
              ),
            ],
          );
        });
      }
      _showSnackBar('report.export.done'.tr());
    } catch (e) {
      if (!mounted) return;
      debugPrint('ReportExportScreen._export failed: $e');
      _showSnackBar('report.export.failed'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  Future<List<String>> _buildCsvPreviewLines(File file) async {
    final raw = await file.readAsLines();
    if (raw.isEmpty) return const [];
    final summaryIndex = raw.indexWhere((line) => line.trim().isEmpty);
    if (summaryIndex < 0) {
      return raw.take(12).toList(growable: false);
    }

    return [
      ...raw.take(7),
      if (summaryIndex > 7) '...',
      ...raw.skip(summaryIndex + 1).take(8),
    ];
  }

  Future<void> _shareLastFile(BuildContext context) async {
    final file = _lastFile;
    if (file == null) return;

    try {
      final box = context.findRenderObject() as RenderBox?;
      final shareOrigin =
          box == null ? null : box.localToGlobal(Offset.zero) & box.size;
      await Share.shareXFiles([
        XFile(
          file.path,
          name: p.basename(file.path),
          mimeType:
              _format == _ExportFormat.csv ? 'text/csv' : 'application/pdf',
        ),
      ], sharePositionOrigin: shareOrigin);
    } catch (e) {
      if (!mounted) return;
      debugPrint('ReportExportScreen._shareLastFile failed: $e');
      _showSnackBar('report.export.share_failed'.tr());
    }
  }

  String _localizedPrefix(String languageCode, String ext) {
    final normalized = languageCode.toLowerCase();
    final range = _rangeType == _ExportRangeType.month ? 'month' : 'range';
    if (normalized.startsWith('ko')) {
      return ext == 'csv' ? '지출_보고서_CSV_$range' : '지출_보고서_PDF_$range';
    }
    return 'expense_report_${ext}_$range';
  }

  String _rangeLabel(DateTime start, DateTime endInclusive) {
    return 'report.export.selected_range'.tr(
      namedArgs: {
        'start': DateFormat('yyyy.MM.dd').format(start),
        'end': DateFormat('yyyy.MM.dd').format(endInclusive),
      },
    );
  }

  void _clearGeneratedFile() {
    _lastFile = null;
    _preview = null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ExportPreview {
  const _ExportPreview({
    required this.format,
    required this.fileName,
    required this.rangeLabel,
    required this.summary,
    required this.rows,
  });

  final _ExportFormat format;
  final String fileName;
  final String rangeLabel;
  final String summary;
  final List<String> rows;
}

class _ExportPreviewPlaceholder extends StatelessWidget {
  const _ExportPreviewPlaceholder({required this.format});

  final _ExportFormat format;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                format == _ExportFormat.csv
                    ? Icons.table_chart_outlined
                    : Icons.picture_as_pdf_outlined,
                size: 42,
                color: AppColors.mutedOf(context),
              ),
              const SizedBox(height: 12),
              Text(
                'report.export.preview_empty'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneratedPreviewCard extends StatelessWidget {
  const _GeneratedPreviewCard({required this.preview});

  final _ExportPreview preview;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  preview.format == _ExportFormat.csv
                      ? Icons.table_chart_outlined
                      : Icons.picture_as_pdf_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'report.export.preview_title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PreviewMetaRow(
              label: 'report.export.file_name'.tr(),
              value: preview.fileName,
            ),
            const SizedBox(height: 6),
            _PreviewMetaRow(
              label: 'report.export.range'.tr(),
              value: preview.rangeLabel,
            ),
            const SizedBox(height: 6),
            _PreviewMetaRow(
              label: 'report.export.summary'.tr(),
              value: preview.summary,
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  preview.format == _ExportFormat.csv
                      ? _CsvPreview(lines: preview.rows)
                      : _PdfPreview(lines: preview.rows),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMetaRow extends StatelessWidget {
  const _PreviewMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.mutedOf(context)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _CsvPreview extends StatelessWidget {
  const _CsvPreview({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          lines.isEmpty
              ? 'report.export.preview_no_rows'.tr()
              : lines.join('\n'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _PdfPreview extends StatelessWidget {
  const _PdfPreview({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf_outlined),
                const SizedBox(width: 8),
                Text(
                  'report.export.pdf'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  line,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'report.export.preview_pdf_note'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final picked = await AppTheme.showDatePickerDialog(
                context: context,
                initialDate: month,
              );
              if (picked == null) return;
              onChanged(DateTime(picked.year, picked.month));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                DateFormat('yyyy.MM').format(month),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _CustomRangeSelector extends StatelessWidget {
  const _CustomRangeSelector({
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final DateTime start;
  final DateTime end;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DatePickerTile(
          label: 'report.export.start_date'.tr(),
          date: start,
          onChanged: onStartChanged,
        ),
        const SizedBox(height: 8),
        _DatePickerTile(
          label: 'report.export.end_date'.tr(),
          date: end,
          onChanged: onEndChanged,
        ),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await AppTheme.showDatePickerDialog(
          context: context,
          initialDate: date,
        );
        if (picked == null) return;
        onChanged(DateTime(picked.year, picked.month, picked.day));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Row(
          children: [
            Text(DateFormat('yyyy.MM.dd').format(date)),
            const Spacer(),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }
}
