import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../brand/analytics/analytics_controller.dart';
import '../../brand/explore/explore_controller.dart';
import '../earnings/earnings_controller.dart';
import '../home/home_controller.dart';
import '../../ad_agency/home_locked/agency_home_locked_controller.dart';
import '../../brand/home_locked/brand_home_locked_controller.dart';
import '../../influencer/home_locked/influencer_home_locked_controller.dart';
import '../jobs/jobs_controller.dart';
import '../notification/notifications_controller.dart';
import '../profile/profile_controller.dart';

class BottomNavController extends GetxController {
  final currentIndex = 0.obs;

  late final bool isAccountVerified;
  late final AccountTypeService _accountTypeService;

  bool get isBrand => _accountTypeService.isBrand;
  bool get isAgency => _accountTypeService.isAdAgency;
  bool get isInfluencer => _accountTypeService.isInfluencer;

  /// Returns the correct locked route based on account type
  String get lockedRoute {
    if (isInfluencer) return AppRoutes.influencerHomeLocked;
    if (isBrand) return AppRoutes.brandHomeLocked;
    return AppRoutes.agencyHomeLocked;
  }

  @override
  void onInit() {
    _accountTypeService = Get.find<AccountTypeService>();

    // Dev mode: ignore verification state
    isAccountVerified = true;

    super.onInit();
  }

  // @override
  // void onReady() {
  //   super.onReady();
  //   // Dev mode: always show dashboard home (no verification checks)
  //   currentIndex.value = 0;
  //   Get.offAllNamed(AppRoutes.home, id: 1);
  // }

  void onTabChanged(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;

    // Profile page (last tab) should always be accessible for onboarding
    final profileIndex = isBrand ? 4 : 3;

    if (!isAccountVerified && index != profileIndex) {
      currentIndex.value = 0;
      Get.offAllNamed(lockedRoute, id: 1);
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
    // Delete existing controller if any to ensure fresh state on each login
    Get.delete<BottomNavController>(force: true);
    Get.put(BottomNavController(), permanent: true);

    Get.lazyPut<AgencyHomeLockedController>(
      () => AgencyHomeLockedController(),
      fenix: true,
    );
    Get.lazyPut<BrandHomeLockedController>(
      () => BrandHomeLockedController(),
      fenix: true,
    );
    Get.lazyPut<InfluencerHomeLockedController>(
      () => InfluencerHomeLockedController(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<JobsController>(() => JobsController(), fenix: true);
    Get.lazyPut<EarningsController>(() => EarningsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    // Get.lazyPut<NotificationsController>(
    //   () => NotificationsController(service: ),
    //   fenix: true,
    // );

    Get.lazyPut<ExploreController>(() => ExploreController(), fenix: true);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(), fenix: true);
  }
}
