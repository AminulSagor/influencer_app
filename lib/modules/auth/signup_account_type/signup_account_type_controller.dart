import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/services/account_type_service.dart';

class SignupAccountTypeController extends GetxController {
  final Rx<AccountType> selectedType = AccountType.influencer.obs;
  final accountTypeService = Get.find<AccountTypeService>();
  final totalSteps = 0.obs;
  @override
  void onInit() {
    super.onInit();

    // Apply default selection properly
    selectType(selectedType.value);
  }

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
    switch (selectedType.value) {
      case AccountType.influencer:
        Get.toNamed(AppRoutes.signupInfluencer);
        break;
      case AccountType.brand:
        Get.toNamed(AppRoutes.signupBrand);
        break;
      case AccountType.adAgency:
        Get.toNamed(AppRoutes.signupAgency);
        break;
    }
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
