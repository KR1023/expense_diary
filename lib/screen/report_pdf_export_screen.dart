import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/features/report/data/report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';

class ReportPdfExportScreen extends StatefulWidget {
  const ReportPdfExportScreen({super.key});

  @override
  State<ReportPdfExportScreen> createState() => _ReportPdfExportScreenState();
}

class _ReportPdfExportScreenState extends State<ReportPdfExportScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _exporting = false;
  File? _lastFile;
  int? _lastTxCount;
  int? _lastCategoryCount;

  ReportPdfService get _pdfService => GetIt.I<ReportPdfService>();

  @override
  Widget build(BuildContext context) {
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
                'Report 플랜 전용. 월간 요약 + 카테고리 TOP + 거래 리스트가 포함된 PDF를 생성합니다.',
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
                    _MonthPicker(
                      month: _selectedMonth,
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = DateTime(value.year, value.month);
                        });
                      },
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
      final result = await _pdfService.exportMonthlyReportPdf(
        month: _selectedMonth,
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
      await Share.shareXFiles([XFile(file.path)], text: 'Expense report PDF');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('공유 실패: ${e.runtimeType}');
    }
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
