// lib/modules/auth/forgot_password/forgot_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  // ----------------- Step 1: contact (phone / email) -----------------
  final contactFormKey = GlobalKey<FormState>();
  final contactController = TextEditingController();

  // value used in the OTP subtitle: "We sent a code to ..."
  final RxString contactValue = ''.obs;

  void onSendResetLink() {
    // if (contactFormKey.currentState?.validate() != true) return;

    contactValue.value = contactController.text.trim();

    // TODO: call API to send OTP here

    Get.toNamed(
      AppRoutes.forgotPasswordOtp,
      arguments: {'contact': contactValue.value},
    );
  }

  // ----------------- Step 2: OTP -----------------
  final otpFormKey = GlobalKey<FormState>();

  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> otpFocusNodes;

  // for enabling/disabling Continue button
  final RxBool isOtpComplete = false.obs;

  String get otpCode => otpControllers.map((c) => c.text).join();

  void onOtpDigitChanged(String value, int index) {
    // move forward when a digit is entered
    if (value.isNotEmpty) {
      if (index < otpFocusNodes.length - 1) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
      }
    } else {
      // move back when deleting
      if (index > 0) {
        otpFocusNodes[index - 1].requestFocus();
      }
    }

    isOtpComplete.value = otpCode.length == 4;
  }

  void resendCode() {
    // TODO: hit resend API
    // you can also clear previous values if you want:
    for (final c in otpControllers) {
      c.clear();
    }
    isOtpComplete.value = false;
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes.first.requestFocus();
    }
  }

  void onVerifyOtp() {
    if (!isOtpComplete.value) return;

    // TODO: verify OTP with backend, then:
    Get.toNamed(AppRoutes.resetPassword);
  }

  // ----------------- Step 3: reset password -----------------
  final resetFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void onResetPassword() {
    // if (resetFormKey.currentState?.validate() != true) return;

    // TODO: call API to set new password
    Get.toNamed(AppRoutes.resetPasswordSuccess);
  }

  // ----------------- Navigation helpers -----------------
  void goBack() => Get.back();

  void goToLogin() => Get.offAllNamed('/login');

  // ----------------- Lifecycle -----------------
  @override
  void onInit() {
    super.onInit();

    // OTP controllers + focus nodes
    otpControllers = List.generate(4, (_) => TextEditingController());
    otpFocusNodes = List.generate(4, (_) => FocusNode());

    // get contact from previous page if passed
    final args = Get.arguments;
    if (args is Map && args['contact'] is String) {
      contactValue.value = args['contact'] as String;
    }

    // focus first OTP box slightly later so the widget tree is ready
    Future.microtask(() {
      if (otpFocusNodes.isNotEmpty) {
        otpFocusNodes.first.requestFocus();
      }
    });
  }

  @override
  void onClose() {
    contactController.dispose();

    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }

    passwordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ForgotPasswordController>(ForgotPasswordController());
  }
}
