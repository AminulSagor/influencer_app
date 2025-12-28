// lib/modules/auth/login/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/enums/account_type.dart';
import 'package:influencer_app/core/services/account_type_service.dart';

import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordObscured = true.obs;
  final RxBool isLoading = false.obs;

  final _accountTypeService = Get.find<AccountTypeService>();

  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  Future<void> submitLogin() async {
    // simple placeholder
    // if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
    //   Get.snackbar('Error', 'Please fill all fields');
    //   return;
    // }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;

    // _accountTypeService.setRole(AccountType.adAgency);
    // _accountTypeService.setRole(AccountType.influencer);
    _accountTypeService.setRole(AccountType.brand);

    Get.offAllNamed(AppRoutes.bottomNav);
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
