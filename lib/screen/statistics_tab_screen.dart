import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/core/subscription/plan_guard.dart';
import 'package:expense_diary/core/subscription/plan_type.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/screen/report_csv_export_screen.dart';
import 'package:expense_diary/screen/report_pdf_export_screen.dart';
import 'package:expense_diary/screen/report_statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class StatisticsTabScreen extends StatelessWidget {
  const StatisticsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                Text('통계', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                AnimatedBuilder(
                  animation: GetIt.I<SubscriptionService>(),
                  builder: (context, _) {
                    final plan = GetIt.I<SubscriptionService>().currentPlan;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '현재 플랜: ${_planLabel(plan)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Report 플랜에서 상세 통계와 CSV/PDF 보고서를 사용할 수 있습니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('Report 통계'),
                    subtitle: const Text('월별 집계 + 카테고리 TOP N'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await PlanGuard.requireReport(
                        context,
                        onAllowed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportStatisticsScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.file_download_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('CSV 보고서 다운로드'),
                    subtitle: const Text('월/기간 기준 CSV 내보내기'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await PlanGuard.requireReport(
                        context,
                        onAllowed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportCsvExportScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('PDF 보고서 다운로드'),
                    subtitle: const Text('월간 요약 PDF (최소 템플릿)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await PlanGuard.requireReport(
                        context,
                        onAllowed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportPdfExportScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  String _planLabel(PlanType plan) {
    return switch (plan) {
      PlanType.free => 'Free',
      PlanType.cloud => 'Cloud',
      PlanType.report => 'Report',
    };
  }
}
