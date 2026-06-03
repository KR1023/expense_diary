import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_diary/const/revenuecat_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionPlan { free, cloud, report }

class SubscriptionService extends ChangeNotifier {
  bool _cloudEntitled = false;
  bool _reportEntitled = false;
  bool _manualCloudEntitled = false;
  bool _manualReportEntitled = false;
  bool _manualAdsRemoved = false;
  bool _isConfigured = false;
  String _manualRole = 'normal';
  String? _currentUid;
  CustomerInfo? _customerInfo;

  static const bool _forceEntitled = bool.fromEnvironment(
    'RC_FORCE_ENTITLED',
    defaultValue: false,
  );

  // Report 플랜은 Cloud 플랜 기능을 포함한다.
  bool get isCloudEntitled =>
      _forceEntitled ||
      _hasFullAccessRole ||
      _hasCloudRole ||
      _manualCloudEntitled ||
      _manualReportEntitled ||
      _cloudEntitled ||
      _reportEntitled;
  bool get isReportEntitled =>
      _forceEntitled ||
      _hasFullAccessRole ||
      _hasReportRole ||
      _manualReportEntitled ||
      _reportEntitled;

  bool get isAdsRemoved => isCloudEntitled || _manualAdsRemoved;

  SubscriptionPlan get currentPlan {
    if (isReportEntitled) return SubscriptionPlan.report;
    if (isCloudEntitled) return SubscriptionPlan.cloud;
    return SubscriptionPlan.free;
  }

  CustomerInfo? get customerInfo => _customerInfo;
  String get manualRole => _manualRole;

  bool get _hasFullAccessRole =>
      _manualRole == 'admin' || _manualRole == 'special';
  bool get _hasCloudRole =>
      _manualRole == 'cloud' || _manualRole == 'report' || _hasFullAccessRole;
  bool get _hasReportRole => _manualRole == 'report' || _hasFullAccessRole;

  static Future<SubscriptionService> init() async {
    final service = SubscriptionService();
    await service._configure();
    return service;
  }

  Future<void> _configure() async {
    if (Platform.isIOS) return; // iOS는 사업자 등록 전까지 무료 제공

    final isTest = RevenueCatConfig.testStoreKey.trim().isNotEmpty;
    final apiKey =
        (isTest
                ? RevenueCatConfig.testStoreKey
                : RevenueCatConfig.androidApiKey)
            .trim();

    if (apiKey.isEmpty) {
      debugPrint(
        'SubscriptionService: RevenueCat API key is missing. Running as Free.',
      );
      return;
    }

    await Purchases.setLogLevel(isTest ? LogLevel.debug : LogLevel.error);
    await Purchases.configure(PurchasesConfiguration(apiKey));
    _isConfigured = true;
    Purchases.addCustomerInfoUpdateListener((_) => _refreshRevenueCat());
    await _refreshRevenueCat();
  }

  Future<void> _refreshRevenueCat() async {
    if (Platform.isIOS || !_isConfigured) return;

    try {
      final info = await Purchases.getCustomerInfo();
      _customerInfo = info;
      _cloudEntitled = info.entitlements.active.containsKey(
        RevenueCatConfig.entitlementCloud,
      );
      _reportEntitled = info.entitlements.active.containsKey(
        RevenueCatConfig.entitlementReport,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('SubscriptionService._refreshRevenueCat error: $e');
    }
  }

  Future<void> refresh() async {
    final uid = _currentUid;
    if (uid != null) {
      await _loadManualEntitlements(uid);
    }
    await _refreshRevenueCat();
  }

  /// Firebase 로그인 시 호출. RevenueCat 사용자를 Firebase UID로 식별한다.
  Future<void> loginUser(String uid) async {
    _currentUid = uid;
    await _loadManualEntitlements(uid);

    if (Platform.isIOS || !_isConfigured) return;
    try {
      await Purchases.logIn(uid);
      await _refreshRevenueCat();
    } catch (e) {
      debugPrint('SubscriptionService.loginUser error: $e');
    }
  }

  /// Firebase 로그아웃 시 호출. RevenueCat 사용자를 익명으로 초기화한다.
  Future<void> logoutUser() async {
    _currentUid = null;
    _clearManualEntitlements();

    if (Platform.isIOS || !_isConfigured) return;
    try {
      await Purchases.logOut();
      await _refreshRevenueCat();
    } catch (e) {
      debugPrint('SubscriptionService.logoutUser error: $e');
    }
  }

  Future<CustomerInfo?> purchase(Package package) async {
    if (Platform.isIOS || !_isConfigured) return null;

    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      await _refreshRevenueCat();
      return result.customerInfo;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return null;
      }
      rethrow;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    if (Platform.isIOS || !_isConfigured) return null;

    try {
      final info = await Purchases.restorePurchases();
      await _refreshRevenueCat();
      return info;
    } catch (e) {
      debugPrint('SubscriptionService.restorePurchases error: $e');
      rethrow;
    }
  }

  Future<void> _loadManualEntitlements(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('userEntitlements')
              .doc(uid)
              .get();
      final data = doc.data();
      if (data == null) {
        _setManualEntitlements(
          role: 'normal',
          cloud: false,
          report: false,
          adsRemoved: false,
        );
        return;
      }

      _setManualEntitlements(
        role: (data['role'] as String?)?.trim().toLowerCase() ?? 'normal',
        cloud: data['manualCloud'] as bool? ?? data['cloud'] as bool? ?? false,
        report:
            data['manualReport'] as bool? ?? data['report'] as bool? ?? false,
        adsRemoved:
            data['manualAdsRemoved'] as bool? ??
            data['adsRemoved'] as bool? ??
            false,
      );
    } catch (e) {
      debugPrint('SubscriptionService._loadManualEntitlements error: $e');
      _setManualEntitlements(
        role: 'normal',
        cloud: false,
        report: false,
        adsRemoved: false,
      );
    }
  }

  void _setManualEntitlements({
    required String role,
    required bool cloud,
    required bool report,
    required bool adsRemoved,
  }) {
    _manualRole = role.isEmpty ? 'normal' : role;
    _manualCloudEntitled = cloud;
    _manualReportEntitled = report;
    _manualAdsRemoved = adsRemoved;
    notifyListeners();
  }

  void _clearManualEntitlements() {
    _setManualEntitlements(
      role: 'normal',
      cloud: false,
      report: false,
      adsRemoved: false,
    );
  }
}
