import 'dart:io';

import 'package:expense_diary/const/revenuecat_config.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionPlan { free, cloud, report }

class SubscriptionService extends ChangeNotifier {
  bool _cloudEntitled = false;
  bool _reportEntitled = false;
  CustomerInfo? _customerInfo;

  static const bool _forceEntitled = bool.fromEnvironment(
    'RC_FORCE_ENTITLED',
    defaultValue: false,
  );

  // Report 플랜은 Cloud 플랜 기능을 포함한다.
  bool get isCloudEntitled =>
      _forceEntitled || Platform.isIOS || _cloudEntitled || _reportEntitled;
  bool get isReportEntitled =>
      _forceEntitled || Platform.isIOS || _reportEntitled;

  bool get isAdsRemoved => isCloudEntitled;

  SubscriptionPlan get currentPlan {
    if (_forceEntitled || _reportEntitled) return SubscriptionPlan.report;
    if (_cloudEntitled) return SubscriptionPlan.cloud;
    return SubscriptionPlan.free;
  }

  CustomerInfo? get customerInfo => _customerInfo;

  static Future<SubscriptionService> init() async {
    final service = SubscriptionService();
    await service._configure();
    return service;
  }

  Future<void> _configure() async {
    if (Platform.isIOS) return; // iOS는 사업자 등록 전까지 무료 제공

    final isTest = RevenueCatConfig.testStoreKey.isNotEmpty;
    final apiKey = isTest
        ? RevenueCatConfig.testStoreKey
        : RevenueCatConfig.androidApiKey;

    await Purchases.setLogLevel(isTest ? LogLevel.debug : LogLevel.error);
    await Purchases.configure(PurchasesConfiguration(apiKey));
    Purchases.addCustomerInfoUpdateListener((_) => _refresh());
    await _refresh();
  }

  Future<void> _refresh() async {
    if (Platform.isIOS) return;

    try {
      final info = await Purchases.getCustomerInfo();
      _customerInfo = info;
      _cloudEntitled = info.entitlements.active
          .containsKey(RevenueCatConfig.entitlementCloud);
      _reportEntitled = info.entitlements.active
          .containsKey(RevenueCatConfig.entitlementReport);
      notifyListeners();
    } catch (e) {
      debugPrint('SubscriptionService._refresh error: $e');
    }
  }

  Future<void> refresh() => _refresh();

  Future<CustomerInfo?> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      await _refresh();
      return result;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return null;
      rethrow;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      await _refresh();
      return info;
    } catch (e) {
      debugPrint('SubscriptionService.restorePurchases error: $e');
      rethrow;
    }
  }
}
