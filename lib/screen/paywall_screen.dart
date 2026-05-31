import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/revenuecat_config.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, required this.entitlement});

  final String entitlement;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offering? _offering;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    if (Platform.isIOS) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (!mounted) return;
      setState(() {
        _offering = offering;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Package? get _targetPackage {
    if (_offering == null) return null;
    final packageId =
        widget.entitlement == RevenueCatConfig.entitlementCloud
            ? RevenueCatConfig.offeringCloud
            : RevenueCatConfig.offeringReport;
    return _offering!.availablePackages
        .where((p) => p.identifier == packageId)
        .firstOrNull;
  }

  Future<void> _purchase() async {
    final package = _targetPackage;
    if (package == null || _isPurchasing) return;

    setState(() => _isPurchasing = true);
    try {
      final result = await GetIt.I<SubscriptionService>().purchase(package);
      if (!mounted) return;
      if (result != null) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('paywall.purchase_cancelled'.tr())),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('paywall.purchase_failed'.tr())));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    try {
      await GetIt.I<SubscriptionService>().restorePurchases();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('paywall.restore_failed'.tr())));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCloud = widget.entitlement == RevenueCatConfig.entitlementCloud;

    if (Platform.isIOS) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      size: 64,
                      color: AppColors.mutedOf(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'subscription.ios_coming_soon_title'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'subscription.ios_coming_soon_desc'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.close),
            ),
            const SizedBox(height: 16),
            Text(
              isCloud
                  ? 'paywall.cloud.title'.tr()
                  : 'paywall.report.title'.tr(),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isCloud
                  ? 'paywall.cloud.description'.tr()
                  : 'paywall.report.description'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(child: Text(_errorMessage!))
            else if (_targetPackage != null) ...[
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(
                    isCloud ? Icons.backup_outlined : Icons.bar_chart_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(_targetPackage!.storeProduct.title),
                  subtitle: Text(_targetPackage!.storeProduct.description),
                  trailing: Text(
                    _targetPackage!.storeProduct.priceString,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isPurchasing ? null : _purchase,
                  child:
                      _isPurchasing
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text('paywall.subscribe'.tr()),
                ),
              ),
            ],
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: _isPurchasing ? null : _restore,
                child: Text(
                  'paywall.restore'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
