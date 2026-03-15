import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format({
    required DateTime? date,
    required String pattern,
    String fallback = '-',
  }) {
    if (date == null) return fallback;

    final locale = _resolvedLocaleTag();
    return DateFormat(pattern, locale).format(date);
  }

  static String formatFromString({
    required String? date,
    required String pattern,
    String fallback = '-',
  }) {
    if (date == null || date.trim().isEmpty) return fallback;

    final parsed = DateTime.tryParse(date.trim());
    if (parsed == null) return fallback;

    return format(date: parsed, pattern: pattern, fallback: fallback);
  }

  static String _resolvedLocaleTag() {
    final locale = Get.locale;

    if (locale == null) return 'en_US';

    final languageCode = locale.languageCode.trim();
    final countryCode = locale.countryCode?.trim();

    if (languageCode.isEmpty) return 'en_US';

    if (countryCode != null && countryCode.isNotEmpty) {
      return '${languageCode}_$countryCode';
    }

    if (languageCode == 'bn') return 'bn_BD';
    if (languageCode == 'en') return 'en_US';

    return languageCode;
  }
}
