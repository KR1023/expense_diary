import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/app_theme.dart';
import 'package:expense_diary/features/report/data/report_csv_service.dart';
import 'package:expense_diary/features/report/data/report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  String? _lastSummary;

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
                          _lastFile = null;
                          _lastSummary = null;
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
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'report.export.selected_range'.tr(
                        namedArgs: {
                          'start': DateFormat('yyyy.MM.dd').format(start),
                          'end': DateFormat('yyyy.MM.dd').format(endInclusive),
                        },
                      ),
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
                                    : _shareLastFile,
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
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'report.export.result'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (_lastFile == null)
                        Text(
                          'report.export.no_file'.tr(),
                          style: TextStyle(color: AppColors.mutedOf(context)),
                        )
                      else ...[
                        Text(_lastSummary ?? ''),
                        const SizedBox(height: 6),
                        Text(
                          _lastFile!.path,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedOf(context)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
      final languageCode = context.locale.languageCode;
      if (_format == _ExportFormat.csv) {
        final result = await _csvService.exportExpensesCsv(
          startInclusive: start,
          endExclusive: endExclusive,
          languageCode: languageCode,
          fileNamePrefix: _localizedPrefix(languageCode, 'csv'),
        );
        if (!mounted) return;
        setState(() {
          _lastFile = result.file;
          _lastSummary = 'report.export.csv_done'.tr(
            namedArgs: {'count': '${result.rowCount}'},
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
          _lastSummary = 'report.export.pdf_done'.tr(
            namedArgs: {'count': '${result.transactionCount}'},
          );
        });
      }
      _showSnackBar('report.export.done'.tr());
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('report.export.failed'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  Future<void> _shareLastFile() async {
    final file = _lastFile;
    if (file == null) return;

    final shareText =
        _format == _ExportFormat.csv
            ? 'report.export.csv_share'.tr()
            : 'report.export.pdf_share'.tr();
    await Share.shareXFiles([XFile(file.path)], text: shareText);
  }

  String _localizedPrefix(String languageCode, String ext) {
    final normalized = languageCode.toLowerCase();
    final range = _rangeType == _ExportRangeType.month ? 'month' : 'range';
    if (normalized.startsWith('ko')) {
      return ext == 'csv' ? '지출_보고서_CSV_$range' : '지출_보고서_PDF_$range';
    }
    return 'expense_report_${ext}_$range';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
