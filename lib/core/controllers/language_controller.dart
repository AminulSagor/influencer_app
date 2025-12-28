import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  void changeToEnglish() {
    final locale = const Locale('en', 'US');
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  void changeToBangla() {
    final locale = const Locale('bn', 'BD');
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }
}
