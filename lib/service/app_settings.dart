import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const currencyPreferenceKey = 'user_currency';
  static const defaultCurrency = 'KRW';
  static const supportedCurrencies = ['KRW', 'USD'];

  static const backgroundIndexKey = 'background_index';
  static const defaultBackgroundIndex = 0; // 0 = gradient
  static const solidBackgroundCount = 8;

  AppSettings({
    required String currencyCode,
    int backgroundIndex = defaultBackgroundIndex,
  })  : _currencyCode = currencyCode,
        _backgroundIndex = backgroundIndex;

  String _currencyCode;
  int _backgroundIndex;

  String get currencyCode => _currencyCode;
  int get backgroundIndex => _backgroundIndex;

  Future<void> setCurrencyCode(String currencyCode) async {
    if (!supportedCurrencies.contains(currencyCode)) return;
    if (_currencyCode == currencyCode) return;

    _currencyCode = currencyCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currencyPreferenceKey, currencyCode);
  }

  Future<void> setBackgroundIndex(int index) async {
    if (index < 0 || index > solidBackgroundCount) return;
    if (_backgroundIndex == index) return;

    _backgroundIndex = index;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(backgroundIndexKey, index);
  }
}
