import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/core/subscription/plan_type.dart';
import 'package:expense_diary/core/subscription/revenuecat_provider.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loadingOfferings = true;
  bool _purchasing = false;
  bool _restoring = false;
  String? _errorText;
  Offerings? _offerings;

  SubscriptionService get _subscription => GetIt.I<SubscriptionService>();
  AuthRepository get _auth => GetIt.I<AuthRepository>();

  bool get _isLoggedIn => _auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _errorText = null;
    });

    try {
      final offerings = await _subscription.loadOfferings();
      if (!mounted) return;
      setState(() {
        _offerings = offerings;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'paywall.msg.offering_load_failed'.tr();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingOfferings = false;
        });
      }
    }
  }

  Future<void> _purchasePackage(Package package) async {
    if (_purchasing) return;
    if (!_isLoggedIn) {
      _showSnackBar('paywall.msg.login_required_for_purchase'.tr());
      return;
    }

    setState(() {
      _purchasing = true;
    });

    try {
      await _subscription.purchasePackage(package);
      await _subscription.refreshPlan();
      if (!mounted) return;
      _showSnackBar('paywall.msg.purchase_completed'.tr());
      Navigator.of(context).pop(true);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return;
      }
      _showSnackBar(_messageForPurchasesError(code));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('paywall.msg.purchase_failed_retry'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _purchasing = false;
        });
      }
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    if (!_isLoggedIn) {
      _showSnackBar('paywall.msg.login_required_for_restore'.tr());
      return;
    }

    setState(() {
      _restoring = true;
    });

    try {
      await _subscription.restoreAndRefreshPlan();
      if (!mounted) return;
      _showSnackBar('paywall.msg.restore_completed'.tr());
      Navigator.of(context).pop(true);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final code = PurchasesErrorHelper.getErrorCode(e);
      _showSnackBar(_messageForPurchasesError(code));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('paywall.msg.restore_failed_retry'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _restoring = false;
        });
      }
    }
  }

  Future<void> _openSubscriptionManagement() async {
    if (!_isLoggedIn) {
      _showSnackBar('paywall.msg.login_required_for_management'.tr());
      return;
    }

    Uri? uri;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final managementUrl = customerInfo.managementURL?.trim();
      if (managementUrl != null && managementUrl.isNotEmpty) {
        uri = Uri.tryParse(managementUrl);
      }
    } catch (_) {
      // Fall back to a platform store URL below.
    }

    uri ??= _subscriptionManagementUri();
    if (uri == null) {
      _showSnackBar('paywall.msg.management_url_unavailable_platform'.tr());
      return;
    }

    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      if (!mounted) return;
      _showSnackBar(_subscriptionManagementUnavailableMessage());
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showSnackBar(_subscriptionManagementUnavailableMessage());
    }
  }

  Uri? _subscriptionManagementUri() {
    if (kIsWeb) return null;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => Uri.parse(
        'https://play.google.com/store/account/subscriptions',
      ),
      TargetPlatform.iOS => Uri.parse(
        'https://apps.apple.com/account/subscriptions',
      ),
      _ => null,
    };
  }

  String _subscriptionManagementUnavailableMessage() {
    if (_subscription.currentPlan == PlanType.free) {
      return 'paywall.msg.management_url_unavailable_free'.tr();
    }

    return 'paywall.msg.management_url_unavailable_env'.tr();
  }

  String _messageForPurchasesError(PurchasesErrorCode code) {
    return 'paywall.msg.purchase_error_with_code'.tr(
      namedArgs: {'code': code.name},
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                    'paywall.title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                _isLoggedIn
                    ? 'paywall.subtitle_logged_in'.tr()
                    : 'paywall.subtitle_logged_out'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _subscription,
              builder:
                  (context, _) => Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'paywall.current_plan'.tr(
                            namedArgs: {
                              'plan': _planLabel(_subscription.currentPlan),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOfferings,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (_errorText != null)
                      _InfoCard(
                        icon: Icons.error_outline,
                        color: AppColors.danger,
                        title: 'paywall.info.offering_load_failed_title'.tr(),
                        body: _errorText!,
                        actionLabel: 'paywall.retry'.tr(),
                        onTap: _loadingOfferings ? null : _loadOfferings,
                      ),
                    if (_loadingOfferings)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      _buildPlanCard(
                        plan: PlanType.cloud,
                        headline: 'paywall.plan.cloud'.tr(),
                        benefits: _cloudBenefits(),
                        package: _resolvePackageForPlan(PlanType.cloud),
                      ),
                      const SizedBox(height: 12),
                      _buildPlanCard(
                        plan: PlanType.report,
                        headline: 'paywall.plan.report'.tr(),
                        benefits: _reportBenefits(),
                        package: _resolvePackageForPlan(PlanType.report),
                        highlight: true,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.restore_rounded),
                          title: Text('paywall.restore.title'.tr()),
                          subtitle: Text(
                            'paywall.restore.subtitle'.tr(),
                          ),
                          trailing:
                              _restoring
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.chevron_right),
                          onTap: _restoring || _purchasing ? null : _restore,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.manage_accounts_outlined),
                          title: Text('paywall.manage.title'.tr()),
                          subtitle: Text(
                            'paywall.manage.subtitle'.tr(),
                          ),
                          trailing: const Icon(Icons.open_in_new_rounded),
                          onTap:
                              _restoring || _purchasing
                                  ? null
                                  : _openSubscriptionManagement,
                        ),
                      ),
                      if (!_subscription.isRevenueCatEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _InfoCard(
                            icon: Icons.info_outline,
                            color: AppColors.primary,
                            title: 'paywall.info.revenuecat_disabled_title'.tr(),
                            body: 'paywall.info.revenuecat_disabled_body'.tr(),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required PlanType plan,
    required String headline,
    required List<String> benefits,
    required Package? package,
    bool highlight = false,
  }) {
    final product = package?.storeProduct;
    final priceText = product == null ? 'paywall.price_unlinked'.tr() : product.priceString;
    final currentPlan = _subscription.currentPlan;
    final alreadyIncluded =
        currentPlan == PlanType.report ||
        currentPlan == plan ||
        (currentPlan == PlanType.cloud && plan == PlanType.free);

    return Card(
      margin: EdgeInsets.zero,
      color:
          highlight
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  headline,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (highlight)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('paywall.badge.recommended'.tr()),
                  ),
                const Spacer(),
                if (alreadyIncluded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('paywall.badge.in_use'.tr()),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final benefit in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_outline, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              priceText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            if (package != null) ...[
              const SizedBox(height: 4),
              Text(
                product?.title ?? package.identifier,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    package == null ||
                            _purchasing ||
                            _restoring ||
                            alreadyIncluded
                        ? null
                        : () => _purchasePackage(package),
                child:
                    _purchasing
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          'paywall.buy_button'.tr(
                            namedArgs: {'plan': headline},
                          ),
                        ),
              ),
            ),
            if (package == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'paywall.unlinked_hint'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Package? _resolvePackageForPlan(PlanType plan) {
    final offerings = _offerings;
    if (offerings == null) return null;

    final targetOfferingId =
        plan == PlanType.report
            ? RevenueCatOfferingIds.report
            : RevenueCatOfferingIds.cloud;

    final exact = offerings.all[targetOfferingId];
    final heuristicOffering =
        exact ?? _findOfferingByIdHint(offerings, targetOfferingId);
    final package = _pickBestPackage(heuristicOffering);
    if (package != null) return package;

    return _findPackageByIdentifierHint(offerings, targetOfferingId);
  }

  Offering? _findOfferingByIdHint(Offerings offerings, String hint) {
    final lowerHint = hint.toLowerCase();
    for (final entry in offerings.all.entries) {
      if (entry.key.toLowerCase().contains(lowerHint)) {
        return entry.value;
      }
    }
    return null;
  }

  Package? _findPackageByIdentifierHint(Offerings offerings, String hint) {
    final lowerHint = hint.toLowerCase();
    for (final offering in offerings.all.values) {
      for (final package in offering.availablePackages) {
        final productId = package.storeProduct.identifier.toLowerCase();
        final packageId = package.identifier.toLowerCase();
        if (productId.contains(lowerHint) || packageId.contains(lowerHint)) {
          return package;
        }
      }
    }
    return null;
  }

  Package? _pickBestPackage(Offering? offering) {
    if (offering == null) return null;
    if (offering.monthly != null) return offering.monthly!;
    if (offering.annual != null) return offering.annual!;
    if (offering.availablePackages.isEmpty) return null;
    return offering.availablePackages.first;
  }

  String _planLabel(PlanType plan) {
    final key = switch (plan) {
      PlanType.free => 'paywall.plan.free',
      PlanType.cloud => 'paywall.plan.cloud',
      PlanType.report => 'paywall.plan.report',
    };
    return key.tr();
  }

  List<String> _cloudBenefits() {
    return [
      'paywall.benefit.cloud.unlimited_backup_restore'.tr(),
      'paywall.benefit.common.remove_ads'.tr(),
    ];
  }

  List<String> _reportBenefits() {
    return [
      'paywall.benefit.report.include_cloud'.tr(),
      'paywall.benefit.report.statistics'.tr(),
      'paywall.benefit.report.download_reports'.tr(),
      'paywall.benefit.common.remove_ads'.tr(),
    ];
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onTap;

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
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body),
            if (actionLabel != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onTap,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
