// lib/modules/auth/login/login_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/enums/account_type.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/services/onboarding_check_service.dart';
import '../../../routes/app_routes.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:influencer_app/core/services/token_service.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordObscured = true.obs;
  final RxBool isLoading = false.obs;

  final _accountTypeService = Get.find<AccountTypeService>();
  final _authService = Get.find<AuthService>();
  final _tokenService = Get.find<TokenService>();
  final _onboardingService = Get.find<OnboardingCheckService>();

  @override
  void onInit() {
    super.onInit();
    // if (phoneController.text.trim().isEmpty) {
    //   phoneController.text = '+88 ';
    // }
  }

  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  String _toApiPhone(String uiText) {
    return uiText; //TODO TEMPORARY DISABLED
    // uiText looks like: "+88 01xxxxxxxxx"
    final trimmed = uiText.trim(); // "+88 01..."
    final noSpace = trimmed.replaceAll(' ', ''); // "+8801..."
    return noSpace;
  }

  Future<void> submitLogin() async {
    final phoneUi = phoneController.text;
    final phone = _toApiPhone(phoneUi);
    final password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    /// TODO TEMPORARY DISABLED!!!
    // if (!RegExp(r'^\+8801\d{9}$').hasMatch(phone)) {
    //   Get.snackbar('error'.tr, 'Enter valid phone like 01XXXXXXXXX');
    //   return;
    // }

    isLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _authService.login(phone: phone, password: password),
    );

    if (!result.isSuccess) {
      isLoading.value = false;
      return;
    }

    final token = result.data!.accessToken;
    await _tokenService.saveAccessToken(token);

    final payload = JwtDecoder.decode(token);

    // Debug: Print decoded token payload
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🔐 DECODED JWT TOKEN:');
    debugPrint('═══════════════════════════════════════════════════════════');
    payload.forEach((key, value) {
      debugPrint('  $key: $value');
    });
    debugPrint('═══════════════════════════════════════════════════════════');

    final role =
        payload['role'] ??
        payload['accountType'] ??
        (payload['user'] is Map ? payload['user']['role'] : null);

    if (role == null) {
      isLoading.value = false;
      Get.snackbar('error'.tr, 'Role not found in token');
      return;
    }

    // Set account type based on role
    if (role == 'influencer') {
      _accountTypeService.setRole(AccountType.influencer);
    } else if (role == 'brand' || role == 'client') {
      _accountTypeService.setRole(AccountType.brand);
    } else if (role == 'agency') {
      _accountTypeService.setRole(AccountType.adAgency);
    }

    // Get admin verification status from JWT token
    // Dashboard is locked only if user is NOT verified by admin
    // Incomplete onboarding doesn't lock the dashboard
    final isVerifiedByAdmin = payload['isVerified'] as bool? ?? false;

    debugPrint('🔓 Dashboard Lock Status:');
    debugPrint('  isVerified (from JWT): $isVerifiedByAdmin');
    debugPrint(
      '  → Dashboard will be: ${isVerifiedByAdmin ? "UNLOCKED ✅" : "LOCKED 🔒"}',
    );

    isLoading.value = false;

    Get.snackbar('Success', result.data!.message);
    Get.offAllNamed(
      AppRoutes.bottomNav,
      arguments: {'isAccountVerified': isVerifiedByAdmin},
    );
  }

  void goToSignUp() {
    Get.toNamed(AppRoutes.signupAccountType);
  }

  void forgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
