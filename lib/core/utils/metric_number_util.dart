class MetricNumberUtil {
  const MetricNumberUtil._();

  static final RegExp _metricPattern = RegExp(
    r'^\s*([+-]?\d+(?:\.\d+)?)\s*([kKmMbB]?)\s*$',
  );

  /// Accepts:
  /// 2000
  /// 2K / 2k
  /// 2.4M / 2.4m
  /// 2B / 2.75B
  ///
  /// Returns direct integer value for API.
  /// Examples:
  /// 2K -> 2000
  /// 2.4M -> 2400000
  /// 2B -> 2000000000
  static int? parseToInt(String? input) {
    if (input == null) return null;

    final raw = input.trim();
    if (raw.isEmpty) return null;

    final normalized = raw.replaceAll(',', '');
    final match = _metricPattern.firstMatch(normalized);
    if (match == null) return null;

    final numberPart = double.tryParse(match.group(1) ?? '');
    if (numberPart == null) return null;

    final suffix = (match.group(2) ?? '').toUpperCase();

    double multiplier = 1;
    switch (suffix) {
      case 'K':
        multiplier = 1000;
        break;
      case 'M':
        multiplier = 1000000;
        break;
      case 'B':
        multiplier = 1000000000;
        break;
    }

    return (numberPart * multiplier).round();
  }

  /// Converts direct number to compact UI format.
  ///
  /// Examples:
  /// 950 -> 950
  /// 2000 -> 2K
  /// 2400000 -> 2.4M
  /// 2000000000 -> 2B
  static String format(num? value, {int fractionDigits = 1}) {
    if (value == null) return '0';

    final absValue = value.abs().toDouble();
    final isNegative = value < 0;

    String result;

    if (absValue >= 1000000000) {
      result = _formatScaled(absValue / 1000000000, fractionDigits, 'B');
    } else if (absValue >= 1000000) {
      result = _formatScaled(absValue / 1000000, fractionDigits, 'M');
    } else if (absValue >= 1000) {
      result = _formatScaled(absValue / 1000, fractionDigits, 'K');
    } else {
      result = value.toInt().toString();
    }

    return isNegative ? '-$result' : result;
  }

  /// Converts text input to normalized compact text for UI.
  ///
  /// Examples:
  /// "2400" -> "2.4K"
  /// "2.40m" -> "2.4M"
  /// "2000000" -> "2M"
  static String normalizeInput(String? input, {int fractionDigits = 1}) {
    final parsed = parseToInt(input);
    if (parsed == null) return input?.trim() ?? '';
    return format(parsed, fractionDigits: fractionDigits);
  }

  static String _formatScaled(double value, int fractionDigits, String suffix) {
    final fixed = value.toStringAsFixed(fractionDigits);
    final cleaned = fixed.contains('.')
        ? fixed.replaceAll(RegExp(r'\.?0+$'), '')
        : fixed;
    return '$cleaned$suffix';
  }
}
