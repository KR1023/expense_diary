import 'dart:io';

class AdMobConfig {
  const AdMobConfig._();

  static const String _defaultAndroidBannerId =
      'ca-app-pub-5444803558030319/2084179141';
  static const String _defaultIosBannerId =
      'ca-app-pub-5444803558030319/5504549409';

  static const String androidBannerId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
    defaultValue: _defaultAndroidBannerId,
  );

  static const String iosBannerId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
    defaultValue: _defaultIosBannerId,
  );

  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (androidBannerId.trim().isNotEmpty) return androidBannerId.trim();
      return _defaultAndroidBannerId;
    }

    if (Platform.isIOS) {
      if (iosBannerId.trim().isNotEmpty) return iosBannerId.trim();
      return _defaultIosBannerId;
    }

    return null;
  }
}
