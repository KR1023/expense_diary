import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const currencyPreferenceKey = 'user_currency';
  static const defaultCurrency = 'KRW';
  static const supportedCurrencies = ['KRW', 'USD'];

  static const themeModePreferenceKey = 'theme_mode';
  static const defaultThemeModeName = 'system';
  static const supportedThemeModeNames = ['system', 'light', 'dark'];

  static const backgroundIndexKey = 'background_index';
  static const defaultBackgroundIndex = 0; // 0 = gradient
  static const solidBackgroundCount = 8;

  AppSettings({
    required String currencyCode,
    String themeModeName = defaultThemeModeName,
    int backgroundIndex = defaultBackgroundIndex,
  }) : _currencyCode = currencyCode,
       _themeModeName =
           supportedThemeModeNames.contains(themeModeName)
               ? themeModeName
               : defaultThemeModeName,
       _backgroundIndex = backgroundIndex;

  String _currencyCode;
  String _themeModeName;
  int _backgroundIndex;

  String get currencyCode => _currencyCode;
  String get themeModeName => _themeModeName;
  ThemeMode get themeMode {
    return switch (_themeModeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  int get backgroundIndex => _backgroundIndex;

  Future<void> setCurrencyCode(String currencyCode) async {
    if (!supportedCurrencies.contains(currencyCode)) return;
    if (_currencyCode == currencyCode) return;

    _currencyCode = currencyCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currencyPreferenceKey, currencyCode);
  }

  Future<void> setThemeModeName(String themeModeName) async {
    if (!supportedThemeModeNames.contains(themeModeName)) return;
    if (_themeModeName == themeModeName) return;

    _themeModeName = themeModeName;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModePreferenceKey, themeModeName);
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
