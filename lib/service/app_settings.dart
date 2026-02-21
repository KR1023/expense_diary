import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const currencyPreferenceKey = 'user_currency';
  static const defaultCurrency = 'KRW';
  static const supportedCurrencies = ['KRW', 'USD'];

  AppSettings({required String currencyCode}) : _currencyCode = currencyCode;

  String _currencyCode;

  String get currencyCode => _currencyCode;

  Future<void> setCurrencyCode(String currencyCode) async {
    if (!supportedCurrencies.contains(currencyCode)) return;
    if (_currencyCode == currencyCode) return;

    _currencyCode = currencyCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currencyPreferenceKey, currencyCode);
  }
}
