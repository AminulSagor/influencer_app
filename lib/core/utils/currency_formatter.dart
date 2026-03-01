import 'package:get/get.dart';
import 'package:intl/intl.dart';

String formatCurrencyByLocale(num amount) {
  final localeCode = Get.locale?.toLanguageTag() ?? 'en_US';

  final hasDecimal = amount % 1 != 0;
  final decimalDigits = hasDecimal ? 2 : 0;

  final patternBn = hasDecimal ? '\u00a4#,##,##0.00' : '\u00a4#,##,##0';
  final patternEn = hasDecimal ? '\u00a4#,##,##0.00' : '\u00a4#,##,##0';

  final format = NumberFormat.currency(
    locale: localeCode.startsWith('bn') ? localeCode : 'en_US',
    name: 'BDT',
    symbol: '৳',
    decimalDigits: decimalDigits,
    customPattern: localeCode.startsWith('bn') ? patternBn : patternEn,
  );

  return format.format(amount);
}
