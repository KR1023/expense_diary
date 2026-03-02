import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/features/report/data/report_csv_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';

enum _ExportRangeType { month, custom }

class ReportCsvExportScreen extends StatefulWidget {
  const ReportCsvExportScreen({super.key});

  @override
  State<ReportCsvExportScreen> createState() => _ReportCsvExportScreenState();
}

class _ReportCsvExportScreenState extends State<ReportCsvExportScreen> {
  _ExportRangeType _rangeType = _ExportRangeType.month;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _customStart;
  late DateTime _customEnd;
  bool _exporting = false;
  File? _lastFile;
  int? _lastRowCount;

  ReportCsvService get _csvService => GetIt.I<ReportCsvService>();

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
                    'CSV 보고서 다운로드',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                'Report 플랜 전용. 로컬 SQLite 거래 내역을 CSV로 저장하고 공유할 수 있습니다.',
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
                    SegmentedButton<_ExportRangeType>(
                      segments: const [
                        ButtonSegment(
                          value: _ExportRangeType.month,
                          icon: Icon(Icons.calendar_month_outlined),
                          label: Text('월별'),
                        ),
                        ButtonSegment(
                          value: _ExportRangeType.custom,
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
                    if (_rangeType == _ExportRangeType.month)
                      _MonthRangeSelector(
                        month: _selectedMonth,
                        onChanged: (next) {
                          setState(() {
                            _selectedMonth = DateTime(next.year, next.month);
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
                      '내보내기 범위: ${DateFormat('yyyy.MM.dd').format(start)} ~ '
                      '${DateFormat('yyyy.MM.dd').format(endExclusive.subtract(const Duration(days: 1)))}',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _exporting ? null : _exportCsv,
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
                            label: Text(_exporting ? '생성 중...' : 'CSV 생성'),
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
                        '내보내기 결과',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (_lastFile == null)
                        Text(
                          '아직 생성된 CSV가 없습니다.',
                          style: TextStyle(color: AppColors.mutedOf(context)),
                        )
                      else ...[
                        Text('파일 경로: ${_lastFile!.path}'),
                        const SizedBox(height: 6),
                        Text('행 수(헤더 제외): ${_lastRowCount ?? 0}'),
                        const SizedBox(height: 6),
                        Text(
                          '파일 크기: ${_lastFile!.existsSync() ? _lastFile!.lengthSync() : 0} bytes',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '앱 문서 디렉터리에 저장되며, 공유 버튼으로 외부 앱에 전달할 수 있습니다.',
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

  Future<void> _exportCsv() async {
    if (_exporting) return;

    setState(() {
      _exporting = true;
    });

    try {
      final (start, endExclusive) = _effectiveRange();
      final languageCode = context.locale.languageCode;
      final result = await _csvService.exportExpensesCsv(
        startInclusive: start,
        endExclusive: endExclusive,
        languageCode: languageCode,
        fileNamePrefix:
            _rangeType == _ExportRangeType.month
                ? _localizedPrefix(languageCode, monthly: true)
                : _localizedPrefix(languageCode, monthly: false),
      );

      if (!mounted) return;
      setState(() {
        _lastFile = result.file;
        _lastRowCount = result.rowCount;
      });
      _showSnackBar('CSV 생성 완료 (${result.rowCount}건)');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('CSV 생성 실패: ${e.runtimeType}');
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

    try {
      final languageCode = context.locale.languageCode.toLowerCase();
      final shareText =
          languageCode.startsWith('ko') ? '지출 보고서 CSV' : 'Expense report CSV';
      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('공유 실패: ${e.runtimeType}');
    }
  }

  String _localizedPrefix(String languageCode, {required bool monthly}) {
    final normalized = languageCode.toLowerCase();
    if (normalized.startsWith('ko')) {
      return monthly ? '지출_보고서_월별' : '지출_보고서_기간';
    }
    return monthly ? 'expense_report_month' : 'expense_report_range';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MonthRangeSelector extends StatelessWidget {
  const _MonthRangeSelector({required this.month, required this.onChanged});

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
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
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
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: date,
        );
        if (picked == null) return;
        onChanged(picked);
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
