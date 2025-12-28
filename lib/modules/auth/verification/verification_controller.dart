// lib/modules/auth/verification/verification_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../../core/enums/account_type.dart';

class VerificationController extends GetxController {
  final PageController progressController = PageController();

  // 4-digit OTP controllers + focus nodes
  final List<TextEditingController> digitControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  late final String phoneNumber;
  late final AccountType accountType;

  final RxBool isCodeComplete = false.obs;

  String get code => digitControllers.map((c) => c.text.trim()).join();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    phoneNumber = args?['phone'] as String? ?? '';
    accountType =
        args?['accountType'] as AccountType? ?? AccountType.influencer;

    for (final c in digitControllers) {
      c.addListener(_handleCodeChange);
    }

    if (digitControllers.isNotEmpty) {
      focusNodes.first.requestFocus();
    }
  }

  void _handleCodeChange() {
    isCodeComplete.value = code.length == digitControllers.length;
  }

  /// Called from each field's onChanged
  void onDigitChanged(String value, int index) {
    // keep only the last character if user pasted/typed multiple
    if (value.length > 1) {
      final last = value.characters.last;
      digitControllers[index]
        ..text = last
        ..selection = TextSelection.fromPosition(const TextPosition(offset: 1));
    }

    if (digitControllers[index].text.isNotEmpty &&
        index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (digitControllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    _handleCodeChange();
  }

  void onBack() {
    Get.back();
  }

  void onResend() {
    // TODO: call API to resend OTP
    Get.snackbar('info'.tr, 'otp_resent_message'.tr);
  }

  void onContinue() {
    if (!isCodeComplete.value) {
      Get.snackbar('error'.tr, 'otp_incomplete_error'.tr);
      return;
    }

    final enteredCode = code;
    // TODO: verify [enteredCode] with backend.

    Get.toNamed(AppRoutes.phoneVerified);
  }

  void onPhoneVerifiedGoNext() {
    // Navigate according to account type
    switch (accountType) {
      case AccountType.brand:
        Get.offAllNamed(AppRoutes.signupBrandAddress);
        break;
      case AccountType.influencer:
        Get.toNamed(AppRoutes.signupInfluencerAddress);
        break;
      case AccountType.adAgency:
        Get.offAllNamed(AppRoutes.signupAgencyAddress);
        break;
    }
  }

  void goToLogin() {
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    for (final c in digitControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}

class VerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerificationController>(() => VerificationController());
  }
}
