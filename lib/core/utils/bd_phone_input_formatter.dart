import 'package:flutter/services.dart';

class BdPhoneInputFormatter extends TextInputFormatter {
  static const String _uiPrefix = '+88 ';
  static const int _maxDigitsAfterPrefix = 11; // user types: 01xxxxxxxxx
  static final RegExp _digitsOnly = RegExp(r'[^0-9]');

  const BdPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Always keep prefix
    String text = newValue.text;

    // If user tries to clear, reset to prefix
    if (text.isEmpty) {
      return _value(_uiPrefix);
    }

    // Ensure prefix exists and cannot be edited
    if (!text.startsWith(_uiPrefix)) {
      // If user removed prefix partially, restore it and keep what they typed as digits
      final digits = _extractDigits(text);
      final rebuilt = _uiPrefix + digits;
      return _value(_clampAndValidate(rebuilt, fallback: oldValue.text));
    }

    // Disallow any spaces except the one in prefix
    // remove any spaces after prefix
    final after = text.substring(_uiPrefix.length).replaceAll(' ', '');
    final digits = after.replaceAll(_digitsOnly, '');

    // Must start with 0 then 1 (as user types)
    // Allow partial typing: "", "0", "01", "01..."
    if (digits.isNotEmpty) {
      if (digits.length == 1 && digits != '0') return oldValue;
      if (digits.length >= 2 && !digits.startsWith('01')) return oldValue;
    }

    // Clamp length
    final limited = digits.length > _maxDigitsAfterPrefix
        ? digits.substring(0, _maxDigitsAfterPrefix)
        : digits;

    return _value(_uiPrefix + limited);
  }

  String _extractDigits(String s) => s.replaceAll(_digitsOnly, '');

  String _clampAndValidate(String s, {required String fallback}) {
    if (!s.startsWith(_uiPrefix)) return fallback;

    final after = s.substring(_uiPrefix.length).replaceAll(' ', '');
    final digits = after.replaceAll(_digitsOnly, '');

    if (digits.isNotEmpty) {
      if (digits.length == 1 && digits != '0') return fallback;
      if (digits.length >= 2 && !digits.startsWith('01')) return fallback;
    }

    final limited = digits.length > _maxDigitsAfterPrefix
        ? digits.substring(0, _maxDigitsAfterPrefix)
        : digits;

    return _uiPrefix + limited;
  }

  TextEditingValue _value(String text) {
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String toApiPhone(String uiText) {
    final trimmed = uiText.trim();
    final noSpace = trimmed.replaceAll(' ', '');
    return noSpace;
  }
}
