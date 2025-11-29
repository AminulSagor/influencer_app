import 'package:get/get.dart';
import 'package:influencer_app/modules/ad_agency/notification/notifications_controller.dart';

import 'bottom_nav_controller.dart';
import '../home/home_controller.dart';
import '../jobs/jobs_controller.dart';
import '../earnings/earnings_controller.dart';
import '../profile/profile_controller.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavController(), permanent: true);

    // Tab controllers
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<JobsController>(() => JobsController(), fenix: true);
    Get.lazyPut<EarningsController>(() => EarningsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
      fenix: true,
    );
  }
}
