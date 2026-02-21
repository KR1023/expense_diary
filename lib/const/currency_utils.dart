import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String formatAmount(int amount, String currencyCode) {
    final formatted = NumberFormat('#,###').format(amount);
    if (currencyCode == 'USD') {
      return '\$$formatted';
    }
    return '$formatted원';
  }

  static String inputSuffix(String currencyCode) {
    if (currencyCode == 'USD') return 'USD';
    return '원';
  }
}
