import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/revenuecat_config.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/screen/login_screen.dart';
import 'package:expense_diary/screen/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  Offerings? _offerings;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOfferings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      GetIt.I<SubscriptionService>().refresh();
    }
  }

  Future<void> _loadOfferings() async {
    if (Platform.isIOS ||
        GetIt.I<SubscriptionService>().currentPlan == SubscriptionPlan.report) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final offerings = await Purchases.getOfferings();
      if (!mounted) return;
      setState(() {
        _offerings = offerings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'subscription.loading_error'.tr();
        _isLoading = false;
      });
    }
  }

  String? _priceFor(String packageId) {
    final pkg = _offerings?.current?.availablePackages
        .where((p) => p.identifier == packageId)
        .firstOrNull;
    return pkg?.storeProduct.priceString;
  }

  String? _expirationFor(String entitlementId) {
    final expDateStr = GetIt.I<SubscriptionService>()
        .customerInfo
        ?.entitlements
        .active[entitlementId]
        ?.expirationDate;
    if (expDateStr == null) return null;
    final parsed = DateTime.tryParse(expDateStr);
    if (parsed == null) return null;
    return DateFormat('yyyy.MM.dd').format(parsed.toLocal());
  }

  Future<void> _navigateToPaywall(String entitlement) async {
    final user = GetIt.I<AuthRepository>().currentUser;
    if (user == null) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted) return;
      if (GetIt.I<AuthRepository>().currentUser == null) return;
      if (loggedIn == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth.success'.tr())),
        );
      }
    }

    if (!mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(entitlement: entitlement),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('subscription.purchase_success'.tr())),
      );
      setState(() => _isLoading = true);
      await _loadOfferings();
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await GetIt.I<SubscriptionService>().restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('paywall.restore'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _openCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('subscription.cancel_dialog_title'.tr()),
        content: Text('subscription.cancel_dialog_desc'.tr()),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('subscription.go_to_store'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final managementUrl =
        GetIt.I<SubscriptionService>().customerInfo?.managementURL;
    final uri = managementUrl != null
        ? Uri.parse(managementUrl)
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                Text(
                  'subscription.title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: AnimatedBuilder(
                  animation: GetIt.I<SubscriptionService>(),
                  builder: (context, _) {
                    if (Platform.isIOS) return _buildIosFreeContent();
                    return _buildContent();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIosFreeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('subscription.current_plan_section'.tr()),
          const SizedBox(height: 8),
          _CurrentPlanCard(
            planLabel: 'subscription.plan_report'.tr(),
            icon: Icons.workspace_premium_rounded,
            features: [
              'subscription.feature_ads'.tr(),
              'subscription.feature_backup'.tr(),
              'subscription.feature_stats'.tr(),
              'subscription.feature_export'.tr(),
            ],
            footnote: 'subscription.ios_free_desc'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final service = GetIt.I<SubscriptionService>();
    final plan = service.currentPlan;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: AppColors.danger),
              ),
            ),

          // 현재 플랜
          _SectionLabel('subscription.current_plan_section'.tr()),
          const SizedBox(height: 8),
          _buildCurrentPlanCard(plan),
          const SizedBox(height: 20),

          // 업그레이드 섹션
          if (plan != SubscriptionPlan.report) ...[
            _SectionLabel('subscription.upgrade_section'.tr()),
            const SizedBox(height: 8),
            if (plan == SubscriptionPlan.free)
              _PlanOfferCard(
                icon: Icons.backup_outlined,
                title: 'subscription.plan_cloud'.tr(),
                price: _priceFor(RevenueCatConfig.offeringCloud),
                features: [
                  'subscription.feature_ads'.tr(),
                  'subscription.feature_backup'.tr(),
                ],
                buttonLabel: 'subscription.subscribe'.tr(),
                onTap: () =>
                    _navigateToPaywall(RevenueCatConfig.entitlementCloud),
              ),
            if (plan == SubscriptionPlan.free) const SizedBox(height: 12),
            _PlanOfferCard(
              icon: Icons.bar_chart_rounded,
              title: 'subscription.plan_report'.tr(),
              price: _priceFor(RevenueCatConfig.offeringReport),
              features: [
                'subscription.feature_cloud_all'.tr(),
                'subscription.feature_stats'.tr(),
                'subscription.feature_export'.tr(),
              ],
              buttonLabel: plan == SubscriptionPlan.free
                  ? 'subscription.subscribe'.tr()
                  : 'subscription.upgrade'.tr(),
              onTap: () =>
                  _navigateToPaywall(RevenueCatConfig.entitlementReport),
            ),
            const SizedBox(height: 20),
          ],

          // 구매 복원 (비구독 시)
          if (plan == SubscriptionPlan.free) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restorePurchases,
                child: Text('subscription.restore'.tr()),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 구독 관리 (구독 중인 경우)
          if (plan != SubscriptionPlan.free) ...[
            _SectionLabel('subscription.manage_section'.tr()),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(
                  Icons.cancel_outlined,
                  color: AppColors.danger,
                ),
                title: Text(
                  'subscription.cancel'.tr(),
                  style: TextStyle(color: AppColors.danger),
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: _openCancelDialog,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return _CurrentPlanCard(
          planLabel: 'subscription.plan_free'.tr(),
          icon: Icons.person_outline,
          subtitle: 'subscription.free_desc'.tr(),
          features: [
            'subscription.feature_backup_free'.tr(),
          ],
        );
      case SubscriptionPlan.cloud:
        final expiry =
            _expirationFor(RevenueCatConfig.entitlementCloud);
        return _CurrentPlanCard(
          planLabel: 'subscription.plan_cloud'.tr(),
          icon: Icons.backup_outlined,
          subtitle: expiry != null
              ? 'subscription.next_renewal'.tr(namedArgs: {'date': expiry})
              : null,
          features: [
            'subscription.feature_ads'.tr(),
            'subscription.feature_backup'.tr(),
          ],
          isActive: true,
        );
      case SubscriptionPlan.report:
        final expiry =
            _expirationFor(RevenueCatConfig.entitlementReport);
        return _CurrentPlanCard(
          planLabel: 'subscription.plan_report'.tr(),
          icon: Icons.workspace_premium_rounded,
          subtitle: expiry != null
              ? 'subscription.next_renewal'.tr(namedArgs: {'date': expiry})
              : null,
          features: [
            'subscription.feature_ads'.tr(),
            'subscription.feature_backup'.tr(),
            'subscription.feature_stats'.tr(),
            'subscription.feature_export'.tr(),
          ],
          isActive: true,
        );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.mutedOf(context),
          ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.planLabel,
    required this.icon,
    required this.features,
    this.subtitle,
    this.footnote,
    this.isActive = false,
  });

  final String planLabel;
  final IconData icon;
  final String? subtitle;
  final List<String> features;
  final String? footnote;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: isActive ? AppColors.primary : AppColors.mutedOf(context)),
                const SizedBox(width: 8),
                Text(
                  planLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.primary : null,
                      ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedOf(context),
                    ),
              ),
            ],
            const SizedBox(height: 12),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.mutedOf(context)),
                    const SizedBox(width: 6),
                    Text(f,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            if (footnote != null) ...[
              const SizedBox(height: 8),
              Text(
                footnote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedOf(context),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanOfferCard extends StatelessWidget {
  const _PlanOfferCard({
    required this.icon,
    required this.title,
    required this.features,
    required this.buttonLabel,
    required this.onTap,
    this.price,
  });

  final IconData icon;
  final String title;
  final String? price;
  final List<String> features;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (price != null)
                  Text(
                    price!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.mutedOf(context)),
                    const SizedBox(width: 6),
                    Text(f, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTap,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
