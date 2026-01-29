// lib/modules/auth/verification/verification_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/routes/app_routes.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import '../../../core/enums/account_type.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class VerificationController extends GetxController {
  final PageController progressController = PageController();

  // 4-digit OTP controllers + focus nodes
  final List<TextEditingController> digitControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  final RxBool isLoading = false.obs;
  late final String phoneNumber;
  late final AccountType accountType;

  final RxBool isCodeComplete = false.obs;

  String get code => digitControllers.map((c) => c.text.trim()).join();
  final AuthService _authService = Get.find<AuthService>();
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

  void onResend() async {
    final result = await ApiErrorHandler.call(
      () => _authService.resendOtp(phone: phoneNumber),
    );
    if (result.isSuccess && result.data!.message.isNotEmpty) {
      Get.snackbar('info'.tr, result.data!.message);
    }
  }

  Future<void> onContinue() async {
    if (!isCodeComplete.value) {
      Get.snackbar('error'.tr, 'otp_incomplete_error'.tr);
      return;
    }

    final enteredCode = code;
    isLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _authService.verifyOtp(phone: phoneNumber, otp: enteredCode),
    );

    isLoading.value = false;

    if (result.isSuccess) {
      final token = result.data!.accessToken;
      final payload = JwtDecoder.decode(token);

      final role =
          payload['role'] ??
          payload['accountType'] ??
          (payload['user'] is Map ? payload['user']['role'] : null);

      if (role == null) {
        Get.snackbar('error'.tr, 'Role not found in token');
        return;
      }

      // Pass the account type to the phone verified page
      Get.offAllNamed(
        AppRoutes.phoneVerified,
        arguments: {'phone': phoneNumber, 'accountType': accountType},
      );
    }
  }

  void onPhoneVerifiedGoNext() {
    // Navigate according to account type
    switch (accountType) {
      case AccountType.brand:
        Get.toNamed(AppRoutes.signupBrandAddress);
        break;
      case AccountType.influencer:
        Get.toNamed(AppRoutes.signupInfluencerAddress);
        break;
      case AccountType.adAgency:
        Get.toNamed(AppRoutes.signupAgencyAddress);
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
