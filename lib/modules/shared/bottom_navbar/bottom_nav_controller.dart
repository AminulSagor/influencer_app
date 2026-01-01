import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../brand/analytics/analytics_controller.dart';
import '../../brand/explore/explore_controller.dart';
import '../earnings/earnings_controller.dart';
import '../home/home_controller.dart';
import '../../ad_agency/home_locked/agency_home_locked_controller.dart';
import '../jobs/jobs_controller.dart';
import '../notification/notifications_controller.dart';
import '../profile/profile_controller.dart';

class BottomNavController extends GetxController {
  final currentIndex = 0.obs;

  late final bool isAccountVerified;
  late final AccountTypeService _accountTypeService;

  bool get isBrand => _accountTypeService.isBrand;

  @override
  void onInit() {
    _accountTypeService = Get.find<AccountTypeService>();

    if (Get.arguments != null) {
      isAccountVerified = Get.arguments['isAccountVerified'];
    } else {
      isAccountVerified = true;
    }

    super.onInit();
  }

  void onTabChanged(int index) {
    currentIndex.value = index;

    if (!isAccountVerified) {
      currentIndex.value = 0;
      Get.offAllNamed(AppRoutes.agencyHomeLocked, id: 1);
      return;
    }

    if (isBrand) {
      switch (index) {
        case 0:
          Get.offAllNamed(AppRoutes.home, id: 1);
          break;
        case 1:
          Get.offAllNamed(AppRoutes.jobs, id: 1);
          break;
        case 2:
          Get.offAllNamed(AppRoutes.analytics, id: 1);
          break;
        case 3:
          Get.offAllNamed(AppRoutes.explore, id: 1);
          break;
        case 4:
          Get.offAllNamed(AppRoutes.profile, id: 1);
          break;
        default:
          Get.offAllNamed(AppRoutes.home, id: 1);
      }
      return;
    }

    // Existing (non-brand) flow
    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.home, id: 1);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.jobs, id: 1);
        break;
      case 2:
        Get.offAllNamed(AppRoutes.earnings, id: 1);
        break;
      case 3:
        Get.offAllNamed(AppRoutes.profile, id: 1);
        break;
    }
  }

  void openNotifications() {
    Get.toNamed(AppRoutes.notifications, id: 1);
  }
}

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavController(), permanent: true);

    Get.lazyPut<AgencyHomeLockedController>(
      () => AgencyHomeLockedController(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<JobsController>(() => JobsController(), fenix: true);
    Get.lazyPut<EarningsController>(() => EarningsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
      fenix: true,
    );

    Get.lazyPut<ExploreController>(() => ExploreController(), fenix: true);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(), fenix: true);
  }
}
