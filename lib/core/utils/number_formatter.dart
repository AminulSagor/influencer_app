import 'package:get/get.dart';
import 'package:intl/intl.dart';

String formatNumberByLocale(num value, {int decimalDigits = 0}) {
  final localeTag = (Get.locale?.toLanguageTag() ?? 'en_US');
  final isBn = localeTag.startsWith('bn');

  final locale = isBn ? 'bn_BD' : 'en_US';

  // decimalPattern supports proper grouping; bn_BD also uses Bangla digits.
  final formatter = NumberFormat.decimalPattern(locale);

  if (decimalDigits <= 0) {
    return formatter.format(value.round());
  }

  // If you ever need decimals:
  final fixed = value.toStringAsFixed(decimalDigits);
  final asNum = num.tryParse(fixed) ?? value;
  return NumberFormat.decimalPattern(locale).format(asNum);
}

/// Optional: if you ever have a custom string that includes digits only.
String localizeDigits(String input) {
  final localeTag = (Get.locale?.toLanguageTag() ?? 'en_US');
  if (!localeTag.startsWith('bn')) return input;

  const map = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    buffer.write(map[ch] ?? ch);
  }
  return buffer.toString();
}
