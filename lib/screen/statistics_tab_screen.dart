import 'dart:io';

import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/revenuecat_config.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/screen/login_screen.dart';
import 'package:expense_diary/screen/paywall_screen.dart';
import 'package:expense_diary/screen/report_csv_export_screen.dart';
import 'package:expense_diary/screen/report_pdf_export_screen.dart';
import 'package:expense_diary/screen/report_statistics_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class StatisticsTabScreen extends StatelessWidget {
  const StatisticsTabScreen({super.key});

  Future<void> _navigateWithGate(
    BuildContext context,
    String entitlement,
    Widget screen,
  ) async {
    final service = GetIt.I<SubscriptionService>();
    final entitled = entitlement == RevenueCatConfig.entitlementReport
        ? service.isReportEntitled
        : service.isCloudEntitled;

    if (entitled) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
      return;
    }

    if (!Platform.isIOS) {
      final user = GetIt.I<AuthRepository>().currentUser;
      if (user == null) {
        final loggedIn = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        if (!context.mounted) return;
        if (GetIt.I<AuthRepository>().currentUser == null) return;
        if (loggedIn == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('auth.success'.tr())),
          );
        }
      }
    }

    if (!context.mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(entitlement: entitlement),
      ),
    );
    if (context.mounted && result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('subscription.purchase_success'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: AnimatedBuilder(
          animation: GetIt.I<SubscriptionService>(),
          builder: (context, _) {
            final isEntitled =
                GetIt.I<SubscriptionService>().isReportEntitled;
            return Column(
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
                        subtitle:
                            Text('report.menu.item_stats_subtitle'.tr()),
                        trailing: Icon(
                          isEntitled
                              ? Icons.chevron_right
                              : Icons.lock_outline,
                        ),
                        onTap: () => _navigateWithGate(
                          context,
                          RevenueCatConfig.entitlementReport,
                          const ReportStatisticsScreen(),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.file_download_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text('report.menu.item_csv_title'.tr()),
                        subtitle:
                            Text('report.menu.item_csv_subtitle'.tr()),
                        trailing: Icon(
                          isEntitled
                              ? Icons.chevron_right
                              : Icons.lock_outline,
                        ),
                        onTap: () => _navigateWithGate(
                          context,
                          RevenueCatConfig.entitlementReport,
                          const ReportCsvExportScreen(),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.picture_as_pdf_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text('report.menu.item_pdf_title'.tr()),
                        subtitle:
                            Text('report.menu.item_pdf_subtitle'.tr()),
                        trailing: Icon(
                          isEntitled
                              ? Icons.chevron_right
                              : Icons.lock_outline,
                        ),
                        onTap: () => _navigateWithGate(
                          context,
                          RevenueCatConfig.entitlementReport,
                          const ReportPdfExportScreen(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                BannerAdWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
