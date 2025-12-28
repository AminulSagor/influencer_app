import 'package:get/get.dart';

import 'package:influencer_app/routes/app_routes.dart';

class SignupSuccessController extends GetxController {
  void goToDashboard() {
    Get.offAllNamed(
      AppRoutes.bottomNav,
      arguments: {'isAccountVerified': false},
    );
  }
}
