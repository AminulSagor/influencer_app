// lib/modules/auth/forgot_password/forgot_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import '../../../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  // ----------------- Services -----------------
  final AuthService authService = Get.find<AuthService>();

  // ----------------- Step 1: contact (phone / email) -----------------
  final contactFormKey = GlobalKey<FormState>();
  final contactController = TextEditingController();

  // value used in the OTP subtitle: "We sent a code to ..."
  final RxString contactValue = ''.obs;

  final RxBool isSending = false.obs;

  Future<void> onSendResetLink() async {
    contactValue.value = contactController.text.trim();

    if (contactValue.value.isEmpty) {
      Get.snackbar('Error', 'Please enter email or phone');
      return;
    }

    isSending.value = true;

    final result = await ApiErrorHandler.call(
      () => authService.forgotPassword(identifier: contactValue.value),
    );

    isSending.value = false;

    if (result.isSuccess) {
      Get.snackbar('Success', result.data!.message);
      Get.toNamed(
        AppRoutes.forgotPasswordOtp,
        arguments: {'contact': contactValue.value},
      );
    }
  }

  // ----------------- Step 2: OTP -----------------
  final otpFormKey = GlobalKey<FormState>();

  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> otpFocusNodes;

  // for enabling/disabling Continue button
  final RxBool isOtpComplete = false.obs;

  // store verified OTP so reset step can use it
  final RxString verifiedOtp = ''.obs;

  // loading state for verify/resend
  final RxBool isVerifyingOtp = false.obs;
  final RxBool isResending = false.obs;

  String get otpCode => otpControllers.map((c) => c.text).join();

  void onOtpDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < otpFocusNodes.length - 1) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        otpFocusNodes[index - 1].requestFocus();
      }
    }

    isOtpComplete.value = otpCode.length == 4;
  }

  Future<void> resendCode() async {
    if (contactValue.value.isEmpty) {
      Get.snackbar('Error', 'Missing contact info');
      return;
    }

    // clear boxes UI
    for (final c in otpControllers) {
      c.clear();
    }
    isOtpComplete.value = false;
    verifiedOtp.value = '';
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes.first.requestFocus();
    }

    isResending.value = true;

    final result = await ApiErrorHandler.call(
      () => authService.forgotPassword(identifier: contactValue.value),
    );

    isResending.value = false;

    if (result.isSuccess) {
      Get.snackbar('Success', result.data!.message);
    }
  }

  Future<void> onVerifyOtp() async {
    if (!isOtpComplete.value) return;
    if (contactValue.value.isEmpty) {
      Get.snackbar('Error', 'Missing contact info');
      return;
    }

    final code = otpCode;
    if (code.length != 4) {
      Get.snackbar('Error', 'OTP must be 4 digits');
      return;
    }

    isVerifyingOtp.value = true;

    final result = await ApiErrorHandler.call(
      () => authService.forgotPasswordVerifyOtp(
        identifier: contactValue.value,
        otp: code,
      ),
    );

    isVerifyingOtp.value = false;

    if (result.isSuccess) {
      verifiedOtp.value = code;
      Get.toNamed(AppRoutes.resetPassword);
    }
  }

  // ----------------- Step 3: reset password -----------------
  final resetFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isResetting = false.obs;

  Future<void> onResetPassword() async {
    final newPass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (contactValue.value.isEmpty) {
      Get.snackbar('Error', 'Missing contact info');
      return;
    }
    if (verifiedOtp.value.isEmpty) {
      Get.snackbar('Error', 'OTP not verified');
      return;
    }
    if (newPass.isEmpty || confirm.isEmpty) {
      Get.snackbar('Error', 'Please enter password and confirm password');
      return;
    }
    if (newPass.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }
    if (newPass != confirm) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isResetting.value = true;

    final result = await ApiErrorHandler.call(
      () => authService.resetPassword(
        identifier: contactValue.value,
        otp: verifiedOtp.value,
        newPassword: newPass,
      ),
    );

    isResetting.value = false;

    if (result.isSuccess) {
      Get.toNamed(AppRoutes.resetPasswordSuccess);
    }
  }

  // ----------------- Navigation helpers -----------------
  void goBack() => Get.back();

  void goToLogin() {
    // Close keyboard first to prevent text input from accessing controller during navigation
    FocusManager.instance.primaryFocus?.unfocus();

    // First, pop back until we reach the login route (or before forgot password)
    // This properly disposes each page one by one
    Get.until((route) => route.settings.name == AppRoutes.login);

    // If we didn't reach login (e.g., came from somewhere else), navigate to it
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ----------------- Lifecycle -----------------
  @override
  void onInit() {
    super.onInit();

    otpControllers = List.generate(4, (_) => TextEditingController());
    otpFocusNodes = List.generate(4, (_) => FocusNode());

    final args = Get.arguments;
    if (args is Map && args['contact'] is String) {
      contactValue.value = args['contact'];
    }

    Future.microtask(() {
      if (otpFocusNodes.isNotEmpty) otpFocusNodes.first.requestFocus();
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
