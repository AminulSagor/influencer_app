import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

String formatCurrencyByLocale(num amount) {
  Locale? currentLocale = Get.locale;
  String localeCode = currentLocale?.toLanguageTag() ?? 'en_US';

  if (localeCode.startsWith('bn')) {
    // Uses Lakh/Crore grouping (৳ 1,23,45,678)
    final bdtFormat = NumberFormat.currency(
      locale: localeCode,
      name: 'BDT',
      symbol: '৳',
      decimalDigits: 0,
      customPattern: '\u00a4#,##,##0',
    );
    return bdtFormat.format(amount);
  } else {
    // Uses international grouping (৳ 12,345,678.90) and forces ৳ at the beginning.
    final defaultFormat = NumberFormat.currency(
      locale: 'en_US',
      name: 'BDT',
      symbol: '৳',
      decimalDigits: 0,
      customPattern: '\u00a4#,##0',
    );
    return defaultFormat.format(amount);
  }
}
