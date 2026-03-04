// lib/modules/ad_agency/support/support_controller.dart
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> callNumber(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        Get.snackbar('Support', 'Unable to open dialer right now.');
      }
    } catch (_) {
      Get.snackbar('Support', 'Dialer is unavailable right now.');
    }
  }

  Future<void> emailTo(String email) async {
    final cleaned = email.trim();
    if (cleaned.isEmpty) return;

    final uri = Uri(scheme: 'mailto', path: cleaned);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        Get.snackbar('Support', 'Unable to open email app right now.');
      }
    } catch (_) {
      Get.snackbar('Support', 'Email app is unavailable right now.');
    }
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
