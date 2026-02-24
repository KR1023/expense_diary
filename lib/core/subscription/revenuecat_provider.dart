import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatEntitlementIds {
  const RevenueCatEntitlementIds._();

  static const String cloud = String.fromEnvironment(
    'RC_ENTITLEMENT_CLOUD',
    defaultValue: 'cloud',
  );

  static const String report = String.fromEnvironment(
    'RC_ENTITLEMENT_REPORT',
    defaultValue: 'report',
  );
}

class RevenueCatOfferingIds {
  const RevenueCatOfferingIds._();

  static const String cloud = String.fromEnvironment(
    'RC_OFFERING_CLOUD',
    defaultValue: 'cloud',
  );

  static const String report = String.fromEnvironment(
    'RC_OFFERING_REPORT',
    defaultValue: 'report',
  );
}

class RevenueCatApiKeys {
  const RevenueCatApiKeys._();

  static const String android = String.fromEnvironment(
    'RC_ANDROID_PUBLIC_SDK_KEY',
    defaultValue: '',
  );

  static const String ios = String.fromEnvironment(
    'RC_IOS_PUBLIC_SDK_KEY',
    defaultValue: '',
  );
}

class RevenueCatProvider {
  RevenueCatProvider();

  CustomerInfoUpdateListener? _listener;
  bool _listenerAttached = false;

  Future<bool> configure({
    String? appUserId,
    CustomerInfoUpdateListener? onCustomerInfoUpdated,
  }) async {
    final apiKey = _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint(
        'RevenueCatProvider: API key missing for current platform. Running in free mode.',
      );
      return false;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final isConfigured = await Purchases.isConfigured;
      if (!isConfigured) {
        final configuration = PurchasesConfiguration(apiKey);
        if (appUserId != null && appUserId.trim().isNotEmpty) {
          configuration.appUserID = appUserId.trim();
        }
        await Purchases.configure(configuration);
      } else if (appUserId != null && appUserId.trim().isNotEmpty) {
        await Purchases.logIn(appUserId.trim());
      }

      if (onCustomerInfoUpdated != null && !_listenerAttached) {
        _listener = onCustomerInfoUpdated;
        Purchases.addCustomerInfoUpdateListener(onCustomerInfoUpdated);
        _listenerAttached = true;
      }

      return true;
    } catch (e) {
      debugPrint('RevenueCatProvider.configure failed: $e');
      return false;
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCatProvider.getCustomerInfo failed: $e');
      return null;
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCatProvider.getOfferings failed: $e');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      debugPrint(
        'RevenueCatProvider.purchasePackage failed: ${code.name}, ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('RevenueCatProvider.purchasePackage failed: $e');
      rethrow;
    }
  }

  Future<CustomerInfo?> logIn(String appUserId) async {
    final uid = appUserId.trim();
    if (uid.isEmpty) return null;

    try {
      final result = await Purchases.logIn(uid);
      return result.customerInfo;
    } catch (e) {
      debugPrint('RevenueCatProvider.logIn failed: $e');
      return null;
    }
  }

  Future<CustomerInfo?> logOut() async {
    try {
      return await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCatProvider.logOut failed: $e');
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('RevenueCatProvider.restorePurchases failed: $e');
      rethrow;
    }
  }

  Future<bool> isConfigured() async {
    try {
      return await Purchases.isConfigured;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    final listener = _listener;
    if (listener != null && _listenerAttached) {
      Purchases.removeCustomerInfoUpdateListener(listener);
    }
    _listener = null;
    _listenerAttached = false;
  }

  String? _resolveApiKey() {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return RevenueCatApiKeys.android;
      case TargetPlatform.iOS:
        return RevenueCatApiKeys.ios;
      default:
        return null;
    }
  }
}
