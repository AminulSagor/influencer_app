import 'package:get/get.dart';
import 'package:influencer_app/routes/app_routes.dart';

class BottomNavController extends GetxController {
  final currentIndex = 0.obs;

  void onTabChanged(int index) {
    currentIndex.value = index;

    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.home, id: 1);
        break;
      case 1:
        Get.offNamed(AppRoutes.jobs, id: 1);
        break;
      case 2:
        Get.offNamed(AppRoutes.earnings, id: 1);
        break;
      case 3:
        Get.offNamed(AppRoutes.profile, id: 1);
        break;
    }
  }

  void openNotifications() {
    Get.toNamed(AppRoutes.notifications, id: 1);
  }
}
