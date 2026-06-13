import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/app_theme.dart';
import 'package:expense_diary/features/report/data/report_csv_service.dart';
import 'package:expense_diary/features/report/data/report_pdf_service.dart';
import 'package:expense_diary/service/app_settings.dart';
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
    final exportTheme = _ExportTheme.of(context);
    final compactSettings = _preview != null || _exporting;
    final settingsPadding = compactSettings ? 12.0 : 16.0;
    final sectionGap = compactSettings ? 10.0 : 16.0;
    final controlGap = compactSettings ? 6.0 : 8.0;

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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: exportTheme.cardColor,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: exportTheme.outlineColor),
                boxShadow: [
                  BoxShadow(
                    color: exportTheme.accentColor.withValues(
                      alpha: exportTheme.isDark ? 0.12 : 0.10,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(settingsPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!compactSettings) ...[
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: exportTheme.gradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.ios_share_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'report.export.options_title'.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SectionLabel(
                      icon: Icons.insert_drive_file_outlined,
                      label: 'report.export.format'.tr(),
                    ),
                    SizedBox(height: controlGap),
                    _ExportPillTabs<_ExportFormat>(
                      value: _format,
                      compact: compactSettings,
                      items: [
                        _ExportPillTabItem(
                          value: _ExportFormat.csv,
                          icon: Icons.table_chart_outlined,
                          label: 'report.export.csv'.tr(),
                        ),
                        _ExportPillTabItem(
                          value: _ExportFormat.pdf,
                          icon: Icons.picture_as_pdf_outlined,
                          label: 'report.export.pdf'.tr(),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _format = value;
                          _clearGeneratedFile();
                        });
                      },
                    ),
                    SizedBox(height: sectionGap),
                    _SectionLabel(
                      icon: Icons.event_note_outlined,
                      label: 'report.export.range'.tr(),
                    ),
                    SizedBox(height: controlGap),
                    _ExportPillTabs<_ExportRangeType>(
                      value: _rangeType,
                      compact: compactSettings,
                      items: [
                        _ExportPillTabItem(
                          value: _ExportRangeType.month,
                          icon: Icons.calendar_month_outlined,
                          label: 'report.export.month'.tr(),
                        ),
                        _ExportPillTabItem(
                          value: _ExportRangeType.custom,
                          icon: Icons.date_range_outlined,
                          label: 'report.export.custom'.tr(),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _rangeType = value;
                          _clearGeneratedFile();
                        });
                      },
                    ),
                    SizedBox(height: compactSettings ? 10 : 14),
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
                    SizedBox(height: compactSettings ? 10 : 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: exportTheme.softAccentColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: exportTheme.accentColor.withValues(
                            alpha: exportTheme.isDark ? 0.24 : 0.18,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: exportTheme.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _rangeLabel(start, endInclusive),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppColors.inkOf(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    _GradientExportButton(
                      onPressed: _exporting ? null : _export,
                      compact: compactSettings,
                      icon:
                          _exporting
                              ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    exportTheme.foregroundColor,
                                  ),
                                ),
                              )
                              : const Icon(Icons.download_rounded),
                      label: Text(
                        _exporting
                            ? 'report.export.generating'.tr()
                            : 'report.export.generate'.tr(),
                      ),
                    ),
                    if (_lastFile != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _TextExportActionButton(
                          onPressed:
                              _exporting ? null : () => _shareLastFile(context),
                          icon: const Icon(Icons.share_outlined),
                          label: Text('report.export.share'.tr()),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_exporting) ...[
              _ExportingNotice(format: _format),
              const SizedBox(height: 12),
            ],
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
            rows: [...result.previewLines],
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
      return raw.take(80).toList(growable: false);
    }

    return [
      ...raw.take(40),
      if (summaryIndex > 40) '...',
      ...raw.skip(summaryIndex + 1).take(30),
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

class _ExportTheme {
  _ExportTheme({
    required this.gradient,
    required this.accentColor,
    required this.cardColor,
    required this.outlineColor,
    required this.softAccentColor,
    required this.foregroundColor,
    required this.isDark,
  });

  final LinearGradient gradient;
  final Color accentColor;
  final Color cardColor;
  final Color outlineColor;
  final Color softAccentColor;
  final Color foregroundColor;
  final bool isDark;

  factory _ExportTheme.of(BuildContext context) {
    final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
    final accentColor = AppColors.accentColorForBackground(bgIndex, context);
    final isDark = AppColors.isDark(context);

    return _ExportTheme(
      gradient: AppColors.heroGradientForBackground(bgIndex, context),
      accentColor: accentColor,
      cardColor: AppColors.cardColorOf(bgIndex, context),
      outlineColor: AppColors.outlineColorOf(bgIndex, context),
      softAccentColor: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
      foregroundColor: Colors.white,
      isDark: isDark,
    );
  }
}

class _ExportPillTabItem<T> {
  const _ExportPillTabItem({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;
}

class _ExportPillTabs<T> extends StatelessWidget {
  const _ExportPillTabs({
    required this.value,
    required this.items,
    required this.onChanged,
    this.compact = false,
  });

  final T value;
  final List<_ExportPillTabItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: exportTheme.softAccentColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: exportTheme.outlineColor),
      ),
      child: Row(
        children: items
            .map((item) {
              final selected = item.value == value;
              final foreground =
                  selected
                      ? exportTheme.foregroundColor
                      : exportTheme.accentColor;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: selected ? null : () => onChanged(item.value),
                      child: Ink(
                        height: compact ? 40 : 46,
                        decoration: BoxDecoration(
                          gradient: selected ? exportTheme.gradient : null,
                          color: selected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconTheme(
                          data: IconThemeData(color: foreground, size: 19),
                          child: DefaultTextStyle.merge(
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: foreground,
                              fontWeight:
                                  selected ? FontWeight.w900 : FontWeight.w800,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item.icon),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    item.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);

    return Row(
      children: [
        Icon(icon, size: 17, color: exportTheme.accentColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.inkOf(context),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GradientExportButton extends StatelessWidget {
  const _GradientExportButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Ink(
          height: compact ? 44 : 50,
          decoration: BoxDecoration(
            gradient: enabled ? exportTheme.gradient : null,
            color: enabled ? null : AppColors.surfaceAltOf(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  enabled
                      ? Colors.transparent
                      : AppColors.outlineColorOf(
                        GetIt.I<AppSettings>().backgroundIndex,
                        context,
                      ),
            ),
          ),
          child: IconTheme(
            data: IconThemeData(
              color:
                  enabled
                      ? exportTheme.foregroundColor
                      : AppColors.mutedOf(context),
              size: 20,
            ),
            child: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color:
                    enabled
                        ? exportTheme.foregroundColor
                        : AppColors.mutedOf(context),
                fontWeight: FontWeight.w800,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 7),
                  Flexible(child: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextExportActionButton extends StatelessWidget {
  const _TextExportActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);
    final enabled = onPressed != null;
    final color =
        enabled ? exportTheme.accentColor : AppColors.mutedOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? exportTheme.softAccentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: IconTheme(
            data: IconThemeData(color: color, size: 18),
            child: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 7),
                  Flexible(child: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportingNotice extends StatelessWidget {
  const _ExportingNotice({required this.format});

  final _ExportFormat format;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);
    final formatLabel =
        format == _ExportFormat.csv
            ? 'report.export.csv'.tr()
            : 'report.export.pdf'.tr();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: exportTheme.softAccentColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: exportTheme.accentColor.withValues(
            alpha: exportTheme.isDark ? 0.28 : 0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation<Color>(
                exportTheme.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'report.export.generating_notice'.tr(
                    namedArgs: {'format': formatLabel},
                  ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.inkOf(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'report.export.generating_notice_desc'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportPreviewPlaceholder extends StatelessWidget {
  const _ExportPreviewPlaceholder({required this.format});

  final _ExportFormat format;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: exportTheme.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: exportTheme.outlineColor),
      ),
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
                color: exportTheme.accentColor,
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
    final exportTheme = _ExportTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: exportTheme.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: exportTheme.outlineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  preview.format == _ExportFormat.csv
                      ? Icons.table_chart_outlined
                      : Icons.picture_as_pdf_outlined,
                  color: exportTheme.accentColor,
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
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PreviewMetaChip(
                    icon: Icons.description_outlined,
                    value: preview.fileName,
                  ),
                  const SizedBox(width: 6),
                  _PreviewMetaChip(
                    icon: Icons.date_range_outlined,
                    value: preview.rangeLabel,
                  ),
                  const SizedBox(width: 6),
                  _PreviewMetaChip(
                    icon: Icons.summarize_outlined,
                    value: preview.summary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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

class _PreviewMetaChip extends StatelessWidget {
  const _PreviewMetaChip({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: exportTheme.softAccentColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: exportTheme.accentColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedOf(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CsvPreview extends StatelessWidget {
  const _CsvPreview({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final exportTheme = _ExportTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: exportTheme.softAccentColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: exportTheme.outlineColor),
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
    final exportTheme = _ExportTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: exportTheme.softAccentColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: exportTheme.outlineColor),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  color: exportTheme.accentColor,
                ),
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
    final exportTheme = _ExportTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: exportTheme.softAccentColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: exportTheme.outlineColor),
      ),
      child: Row(
        children: [
          IconButton(
            color: exportTheme.accentColor,
            onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final picked = await AppTheme.showDatePickerDialog(
                  context: context,
                  initialDate: month,
                );
                if (picked == null) return;
                onChanged(DateTime(picked.year, picked.month));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  DateFormat('yyyy.MM').format(month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.inkOf(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            color: exportTheme.accentColor,
            onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
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
    final exportTheme = _ExportTheme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final picked = await AppTheme.showDatePickerDialog(
          context: context,
          initialDate: date,
        );
        if (picked == null) return;
        onChanged(DateTime(picked.year, picked.month, picked.day));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: exportTheme.softAccentColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: exportTheme.outlineColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 19,
              color: exportTheme.accentColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.mutedOf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('yyyy.MM.dd').format(date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkOf(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.expand_more_rounded, color: exportTheme.accentColor),
          ],
        ),
      ),
    );
  }
}
