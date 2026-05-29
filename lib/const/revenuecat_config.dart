class RevenueCatConfig {
  const RevenueCatConfig._();

  static const String androidApiKey = String.fromEnvironment(
    'RC_ANDROID_PUBLIC_SDK_KEY',
  );
  static const String iosApiKey = String.fromEnvironment(
    'RC_IOS_PUBLIC_SDK_KEY',
  );

  // RevenueCat Billing 테스트 스토어 키. 비어 있으면 androidApiKey 사용.
  static const String testStoreKey = String.fromEnvironment(
    'RC_TEST_STORE_KEY',
    defaultValue: '',
  );

  static const String entitlementCloud = String.fromEnvironment(
    'RC_ENTITLEMENT_CLOUD',
    defaultValue: 'cloud',
  );
  static const String entitlementReport = String.fromEnvironment(
    'RC_ENTITLEMENT_REPORT',
    defaultValue: 'report',
  );

  static const String offeringCloud = String.fromEnvironment(
    'RC_OFFERING_CLOUD',
    defaultValue: 'cloud_monthly',
  );
  static const String offeringReport = String.fromEnvironment(
    'RC_OFFERING_REPORT',
    defaultValue: 'report_monthly',
  );
}
