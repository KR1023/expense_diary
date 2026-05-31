import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 숫자 입력 시 3자리마다 쉼표를 자동 삽입하는 포매터.
/// onSaved 콜백에서는 replaceAll(',', '') 후 int.parse 필요.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final parsed = int.tryParse(digits);
    if (parsed == null) return oldValue;

    final formatted = NumberFormat('#,###').format(parsed);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// 저장 전 쉼표 제거 후 int 파싱.
  static int parse(String value) =>
      int.parse(value.replaceAll(',', ''));

  /// 기존 숫자 값을 표시용 문자열로 변환.
  static String format(int value) => NumberFormat('#,###').format(value);
}
