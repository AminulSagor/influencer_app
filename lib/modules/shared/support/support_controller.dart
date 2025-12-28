// lib/modules/ad_agency/support/support_controller.dart
import 'package:get/get.dart';

class SupportController extends GetxController {
  // later you can load these from API/settings if needed
  final helplines = const [
    _HelplineData(labelKey: 'support_help_line_1', phone: '+8801234567890'),
    _HelplineData(labelKey: 'support_help_line_2', phone: '+8801234567890'),
    _HelplineData(labelKey: 'support_help_line_3', phone: '+8801234567890'),
  ];

  final timeKey = 'support_time_10_8'; // "10AM–8PM"

  final emails = const ['support1@brandguru.io', 'support2@brandguru.io'];

  void onBack() {
    Get.back(id: 1);
  }

  void callNumber(String phone) {
    // TODO: integrate url_launcher or native dialer
    // e.g. launchUrl(Uri.parse('tel:$phone'));
  }

  void emailTo(String email) {
    // TODO: integrate mailto handler
    // e.g. launchUrl(Uri.parse('mailto:$email'));
  }
}

class _HelplineData {
  final String labelKey;
  final String phone;

  const _HelplineData({required this.labelKey, required this.phone});
}

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController());
  }
}
