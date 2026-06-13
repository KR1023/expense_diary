import 'dart:io';
import 'package:expense_diary/const/app_theme.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/features/report/data/report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';

enum _PdfExportRangeType { month, custom }

class ReportPdfExportScreen extends StatefulWidget {
  const ReportPdfExportScreen({super.key});

  @override
  State<ReportPdfExportScreen> createState() => _ReportPdfExportScreenState();
}

class _ReportPdfExportScreenState extends State<ReportPdfExportScreen> {
  _PdfExportRangeType _rangeType = _PdfExportRangeType.month;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _customStart;
  late DateTime _customEnd;
  bool _exporting = false;
  File? _lastFile;
  int? _lastTxCount;
  int? _lastCategoryCount;

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
    final (startInclusive, endExclusive) = _effectiveRange();

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
                    'PDF 보고서 다운로드',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                '월간 요약, 분류별 합계, 지출 내역이 포함된 PDF 보고서를 생성합니다.',
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
                    SegmentedButton<_PdfExportRangeType>(
                      segments: const [
                        ButtonSegment(
                          value: _PdfExportRangeType.month,
                          icon: Icon(Icons.calendar_month_outlined),
                          label: Text('월별'),
                        ),
                        ButtonSegment(
                          value: _PdfExportRangeType.custom,
                          icon: Icon(Icons.date_range_outlined),
                          label: Text('기간'),
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
                    if (_rangeType == _PdfExportRangeType.month)
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
                        onStartChanged: (v) {
                          setState(() {
                            _customStart = DateTime(v.year, v.month, v.day);
                            if (_customEnd.isBefore(_customStart)) {
                              _customEnd = _customStart;
                            }
                          });
                        },
                        onEndChanged: (v) {
                          setState(() {
                            _customEnd = DateTime(v.year, v.month, v.day);
                            if (_customEnd.isBefore(_customStart)) {
                              _customStart = _customEnd;
                            }
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                    Text(
                      '내보내기 범위: ${DateFormat('yyyy.MM.dd').format(startInclusive)} ~ '
                      '${DateFormat('yyyy.MM.dd').format(endExclusive.subtract(const Duration(days: 1)))}',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _exporting ? null : _generatePdf,
                            icon:
                                _exporting
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.picture_as_pdf_outlined),
                            label: Text(_exporting ? '생성 중...' : 'PDF 생성'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                (_exporting || _lastFile == null)
                                    ? null
                                    : _sharePdf,
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('공유'),
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
                        '생성 결과',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (_lastFile == null)
                        Text(
                          '아직 생성된 PDF가 없습니다.',
                          style: TextStyle(color: AppColors.mutedOf(context)),
                        )
                      else ...[
                        Text('파일 경로: ${_lastFile!.path}'),
                        const SizedBox(height: 6),
                        Text('거래 행 수: ${_lastTxCount ?? 0}'),
                        Text('카테고리 TOP 수: ${_lastCategoryCount ?? 0}'),
                        const SizedBox(height: 6),
                        Text(
                          '파일 크기: ${_lastFile!.existsSync() ? _lastFile!.lengthSync() : 0} bytes',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '최소 템플릿 PDF 1종(월간 요약/카테고리 TOP/거래 리스트) 생성 완료.',
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

  Future<void> _generatePdf() async {
    if (_exporting) return;

    setState(() {
      _exporting = true;
    });

    try {
      final (startInclusive, endExclusive) = _effectiveRange();
      final languageCode = context.locale.languageCode;
      final result = await _pdfService.exportReportPdf(
        startInclusive: startInclusive,
        endExclusive: endExclusive,
        languageCode: languageCode,
        isMonthlyRange: _rangeType == _PdfExportRangeType.month,
        monthAnchor:
            _rangeType == _PdfExportRangeType.month ? _selectedMonth : null,
        fileNamePrefix:
            _rangeType == _PdfExportRangeType.month
                ? _localizedPrefix(languageCode, monthly: true)
                : _localizedPrefix(languageCode, monthly: false),
      );
      if (!mounted) return;
      setState(() {
        _lastFile = result.file;
        _lastTxCount = result.transactionCount;
        _lastCategoryCount = result.categoryTopCount;
      });
      _showSnackBar('PDF 생성 완료');
    } catch (e, st) {
      debugPrint('ReportPdfExportScreen._generatePdf failed: $e\n$st');
      if (!mounted) return;
      _showSnackBar('PDF 생성 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  Future<void> _sharePdf() async {
    final file = _lastFile;
    if (file == null) return;

    try {
      final languageCode = context.locale.languageCode.toLowerCase();
      final shareText =
          languageCode.startsWith('ko') ? '지출 보고서 PDF' : 'Expense report PDF';
      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('공유 실패: ${e.runtimeType}');
    }
  }

  (DateTime, DateTime) _effectiveRange() {
    if (_rangeType == _PdfExportRangeType.month) {
      final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endExclusive = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      return (start, endExclusive);
    }

    final start = DateTime(
      _customStart.year,
      _customStart.month,
      _customStart.day,
    );
    final endExclusive = DateTime(
      _customEnd.year,
      _customEnd.month,
      _customEnd.day + 1,
    );
    return (start, endExclusive);
  }

  String _localizedPrefix(String languageCode, {required bool monthly}) {
    final normalized = languageCode.toLowerCase();
    if (normalized.startsWith('ko')) {
      return monthly ? '지출_보고서_PDF_월별' : '지출_보고서_PDF_기간';
    }
    return monthly ? 'expense_report_pdf_month' : 'expense_report_pdf_range';
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
        _DatePickerTile(label: '시작일', date: start, onChanged: onStartChanged),
        const SizedBox(height: 8),
        _DatePickerTile(label: '종료일', date: end, onChanged: onEndChanged),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Text(
              DateFormat('yyyy.MM.dd').format(date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 6),
            const Icon(Icons.edit_calendar_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
