import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/services/account_type_service.dart';

class SignupAccountTypeController extends GetxController {
  final Rx<AccountType> selectedType = AccountType.influencer.obs;
  final accountTypeService = Get.find<AccountTypeService>();
  final totalSteps = 0.obs;

  void selectType(AccountType type) {
    selectedType.value = type;
    accountTypeService.setRole(type);

    totalSteps.value = type == AccountType.brand
        ? 9
        : type == AccountType.adAgency
        ? 10
        : 7;
  }

  void onBack() {
    Get.back();
  }

  void onContinue() {
    if (selectedType.value == AccountType.adAgency) {
      final locale = const Locale('en', 'US');
      Get.updateLocale(locale);
    }
    Get.toNamed(AppRoutes.signupInfluencer);
  }
}

class SignupAccountTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupAccountTypeController>(
      () => SignupAccountTypeController(),
    );
  }
}
