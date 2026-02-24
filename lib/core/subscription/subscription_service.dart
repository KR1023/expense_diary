import 'dart:async';

import 'package:expense_diary/core/subscription/plan_policy.dart';
import 'package:expense_diary/core/subscription/plan_type.dart';
import 'package:expense_diary/core/subscription/revenuecat_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService({RevenueCatProvider? revenueCatProvider})
    : _revenueCatProvider = revenueCatProvider ?? RevenueCatProvider();

  final RevenueCatProvider _revenueCatProvider;
  final StreamController<PlanType> _planController =
      StreamController<PlanType>.broadcast();

  PlanType _currentPlan = PlanType.free;
  bool _initialized = false;
  bool _revenueCatEnabled = false;
  bool _hasAuthenticatedUser = false;

  PlanType get currentPlan => _currentPlan;

  PlanPolicy get currentPolicy => PlanPolicy(_currentPlan);

  Stream<PlanType> get planStream => _planController.stream;

  bool get isRevenueCatEnabled => _revenueCatEnabled;

  Future<void> init({String? initialUserId}) async {
    final normalizedUserId = initialUserId?.trim();
    _hasAuthenticatedUser =
        normalizedUserId != null && normalizedUserId.isNotEmpty;

    if (_initialized) {
      if (_hasAuthenticatedUser) {
        await onUserSignedIn(normalizedUserId!);
      } else {
        await onUserSignedOut();
      }
      return;
    }

    _revenueCatEnabled = await _revenueCatProvider.configure(
      appUserId: normalizedUserId,
      onCustomerInfoUpdated: _handleCustomerInfoUpdated,
    );
    _initialized = true;

    if (!_revenueCatEnabled) {
      _setPlan(PlanType.free);
      return;
    }

    if (!_hasAuthenticatedUser) {
      _setPlan(PlanType.free);
      return;
    }

    await refreshPlan();
  }

  Future<PlanType> refreshPlan() async {
    if (!_initialized) {
      await init();
    }

    if (!_revenueCatEnabled) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    if (!_hasAuthenticatedUser) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    final customerInfo = await _revenueCatProvider.getCustomerInfo();
    if (customerInfo == null) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    _setPlan(_mapCustomerInfoToPlan(customerInfo));
    return _currentPlan;
  }

  Future<PlanType> onUserSignedIn(String uid) async {
    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      return onUserSignedOut();
    }
    _hasAuthenticatedUser = true;

    if (!_initialized) {
      await init(initialUserId: normalizedUid);
      return _currentPlan;
    }

    if (!_revenueCatEnabled) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    final customerInfo = await _revenueCatProvider.logIn(normalizedUid);
    if (customerInfo == null) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    _setPlan(_mapCustomerInfoToPlan(customerInfo));
    return _currentPlan;
  }

  Future<PlanType> onUserSignedOut() async {
    _hasAuthenticatedUser = false;

    if (!_initialized) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    if (!_revenueCatEnabled) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    await _revenueCatProvider.logOut();
    _setPlan(PlanType.free);
    return _currentPlan;
  }

  Future<Offerings?> loadOfferings() async {
    if (!_initialized) {
      await init();
    }

    if (!_revenueCatEnabled) return null;
    return _revenueCatProvider.getOfferings();
  }

  Future<PlanType> purchasePackage(Package package) async {
    if (!_initialized) {
      await init();
    }

    if (!_revenueCatEnabled || !_hasAuthenticatedUser) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    final customerInfo = await _revenueCatProvider.purchasePackage(package);
    if (customerInfo != null) {
      _setPlan(_mapCustomerInfoToPlan(customerInfo));
      return _currentPlan;
    }

    return refreshPlan();
  }

  Future<PlanType> restoreAndRefreshPlan() async {
    if (!_initialized) {
      await init();
    }

    if (!_revenueCatEnabled || !_hasAuthenticatedUser) {
      _setPlan(PlanType.free);
      return _currentPlan;
    }

    final customerInfo = await _revenueCatProvider.restorePurchases();
    if (customerInfo != null) {
      _setPlan(_mapCustomerInfoToPlan(customerInfo));
    }
    return refreshPlan();
  }

  @visibleForTesting
  PlanType mapEntitlementsToPlan(Iterable<String> activeEntitlementIds) {
    final active = activeEntitlementIds.toSet();

    if (active.contains(RevenueCatEntitlementIds.report)) {
      return PlanType.report;
    }
    if (active.contains(RevenueCatEntitlementIds.cloud)) {
      return PlanType.cloud;
    }
    return PlanType.free;
  }

  @override
  void dispose() {
    _revenueCatProvider.dispose();
    _planController.close();
    super.dispose();
  }

  void _handleCustomerInfoUpdated(CustomerInfo customerInfo) {
    if (!_hasAuthenticatedUser) {
      _setPlan(PlanType.free);
      return;
    }
    _setPlan(_mapCustomerInfoToPlan(customerInfo));
  }

  PlanType _mapCustomerInfoToPlan(CustomerInfo customerInfo) {
    return mapEntitlementsToPlan(customerInfo.entitlements.active.keys);
  }

  void _setPlan(PlanType nextPlan) {
    if (_currentPlan == nextPlan) return;
    _currentPlan = nextPlan;
    notifyListeners();
    _planController.add(nextPlan);
  }
}
