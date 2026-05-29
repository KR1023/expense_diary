import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/screen/report_csv_export_screen.dart';
import 'package:expense_diary/screen/report_pdf_export_screen.dart';
import 'package:expense_diary/screen/report_statistics_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
                Text(
                  'tab.stats'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'report.menu.subtitle'.tr(),
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
                    title: Text('report.menu.item_stats_title'.tr()),
                    subtitle: Text('report.menu.item_stats_subtitle'.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportStatisticsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.file_download_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text('report.menu.item_csv_title'.tr()),
                    subtitle: Text('report.menu.item_csv_subtitle'.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportCsvExportScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text('report.menu.item_pdf_title'.tr()),
                    subtitle: Text('report.menu.item_pdf_subtitle'.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportPdfExportScreen(),
                        ),
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
}
