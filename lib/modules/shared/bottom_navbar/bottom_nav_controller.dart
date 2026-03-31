import 'dart:developer' as dev;

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
import '../profile/profile_controller.dart';
import '../../../core/controllers/app_user_session_controller.dart';

class BottomNavController extends GetxController {
  final currentIndex = 0.obs;

  // Default false so locked view is safe until session resolves
  final isAccountVerified = false.obs;

  late final AccountTypeService _accountTypeService;
  late final AppUserSessionController _session;

  bool get isBrand => _accountTypeService.isBrand;
  bool get isAgency => _accountTypeService.isAdAgency;
  bool get isInfluencer => _accountTypeService.isInfluencer;

  int get profileIndex => isBrand ? 4 : 3;

  String get lockedRoute {
    if (isInfluencer) return AppRoutes.influencerHomeLocked;
    if (isBrand) return AppRoutes.brandHomeLocked;
    return AppRoutes.agencyHomeLocked;
  }

  String get initialNestedRoute =>
      isAccountVerified.value ? AppRoutes.home : lockedRoute;

  @override
  void onInit() {
    super.onInit();
    _accountTypeService = Get.find<AccountTypeService>();
    _session = Get.find<AppUserSessionController>();

    _hydrateVerificationState();
  }

  @override
  void onReady() {
    super.onReady();

    Future.microtask(() async {
      await syncVerificationFromSession(forceRefresh: false);
      Get.offAllNamed(
        isAccountVerified.value ? AppRoutes.home : lockedRoute,
        id: 1,
      );
    });
  }

  void _hydrateVerificationState() {
    // Only trust the verification state derived from getProfile -> isVerified
    isAccountVerified.value = _session.isUserVerified();
    currentIndex.value = 0;

    dev.log(
      'BottomNav verification resolved',
      name: 'BottomNavController',
      error: {
        'isAccountVerified': isAccountVerified.value,
        'initialNestedRoute': initialNestedRoute,
      },
    );
  }

  Future<void> syncVerificationFromSession({bool forceRefresh = false}) async {
    await _session.preloadUserData(forceRefresh: forceRefresh);
    isAccountVerified.value = _session.isUserVerified();

    if (!isAccountVerified.value) {
      // Profile remains accessible even when unverified
      if (currentIndex.value != profileIndex) {
        currentIndex.value = 0;
        Get.offAllNamed(lockedRoute, id: 1);
      }
      return;
    }

    // If verified, home tab should open the real home screen
    if (currentIndex.value == 0) {
      Get.offAllNamed(AppRoutes.home, id: 1);
    }
  }

  void onTabChanged(int index) {
    if (currentIndex.value == index) {
      Get.until((route) => route.isFirst, id: 1);
      return;
    }

    // Profile is always allowed even when unverified
    if (!isAccountVerified.value && index != profileIndex) {
      currentIndex.value = 0;
      Get.offAllNamed(lockedRoute, id: 1);
      return;
    }

    currentIndex.value = index;

    if (isBrand) {
      switch (index) {
        case 0:
          Get.offAllNamed(
            isAccountVerified.value ? AppRoutes.home : lockedRoute,
            id: 1,
          );
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
          Get.offAllNamed(
            isAccountVerified.value ? AppRoutes.home : lockedRoute,
            id: 1,
          );
      }
      return;
    }

    switch (index) {
      case 0:
        Get.offAllNamed(
          isAccountVerified.value ? AppRoutes.home : lockedRoute,
          id: 1,
        );
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
      default:
        Get.offAllNamed(
          isAccountVerified.value ? AppRoutes.home : lockedRoute,
          id: 1,
        );
    }
  }

  void openNotifications() {
    Get.toNamed(AppRoutes.notifications, id: 1);
  }
}

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<BottomNavController>()) {
      Get.delete<BottomNavController>(force: true);
    }

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
    Get.lazyPut<ExploreController>(() => ExploreController(), fenix: true);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(), fenix: true);
  }
}
