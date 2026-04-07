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
    _ensureControllerForRoute(initialNestedRoute);
  }

  @override
  void onReady() {
    super.onReady();

    Future.microtask(() async {
      await syncVerificationFromSession(forceRefresh: false);

      final route = isAccountVerified.value ? AppRoutes.home : lockedRoute;
      _ensureControllerForRoute(route);

      Get.offAllNamed(route, id: 1);
    });
  }

  void _hydrateVerificationState() {
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
      if (currentIndex.value != profileIndex) {
        currentIndex.value = 0;
        _ensureControllerForRoute(lockedRoute);
        Get.offAllNamed(lockedRoute, id: 1);
      }
      return;
    }

    if (currentIndex.value == 0) {
      _ensureControllerForRoute(AppRoutes.home);
      Get.offAllNamed(AppRoutes.home, id: 1);
    }
  }

  void onTabChanged(int index) {
    if (currentIndex.value == index) {
      Get.until((route) => route.isFirst, id: 1);
      return;
    }

    if (!isAccountVerified.value && index != profileIndex) {
      currentIndex.value = 0;
      _ensureControllerForRoute(lockedRoute);
      Get.offAllNamed(lockedRoute, id: 1);
      return;
    }

    currentIndex.value = index;

    final route = _routeForIndex(index);
    _ensureControllerForRoute(route);
    Get.offAllNamed(route, id: 1);
  }

  String _routeForIndex(int index) {
    if (isBrand) {
      switch (index) {
        case 0:
          return isAccountVerified.value ? AppRoutes.home : lockedRoute;
        case 1:
          return AppRoutes.jobs;
        case 2:
          return AppRoutes.analytics;
        case 3:
          return AppRoutes.explore;
        case 4:
          return AppRoutes.profile;
        default:
          return isAccountVerified.value ? AppRoutes.home : lockedRoute;
      }
    }

    switch (index) {
      case 0:
        return isAccountVerified.value ? AppRoutes.home : lockedRoute;
      case 1:
        return AppRoutes.jobs;
      case 2:
        return AppRoutes.earnings;
      case 3:
        return AppRoutes.profile;
      default:
        return isAccountVerified.value ? AppRoutes.home : lockedRoute;
    }
  }

  void _ensureControllerForRoute(String route) {
    switch (route) {
      case AppRoutes.home:
        _putPermanentIfNeeded<HomeController>(() => HomeController());
        break;
      case AppRoutes.jobs:
        _putPermanentIfNeeded<JobsController>(() => JobsController());
        break;
      case AppRoutes.earnings:
        _putPermanentIfNeeded<EarningsController>(() => EarningsController());
        break;
      case AppRoutes.profile:
        _putPermanentIfNeeded<ProfileController>(() => ProfileController());
        break;
      case AppRoutes.explore:
        _putPermanentIfNeeded<ExploreController>(() => ExploreController());
        break;
      case AppRoutes.analytics:
        _putPermanentIfNeeded<AnalyticsController>(() => AnalyticsController());
        break;
      case AppRoutes.agencyHomeLocked:
        _putPermanentIfNeeded<AgencyHomeLockedController>(
          () => AgencyHomeLockedController(),
        );
        break;
      case AppRoutes.brandHomeLocked:
        _putPermanentIfNeeded<BrandHomeLockedController>(
          () => BrandHomeLockedController(),
        );
        break;
      case AppRoutes.influencerHomeLocked:
        _putPermanentIfNeeded<InfluencerHomeLockedController>(
          () => InfluencerHomeLockedController(),
        );
        break;
    }
  }

  void _putPermanentIfNeeded<T>(T Function() builder) {
    if (Get.isRegistered<T>()) return;
    Get.put<T>(builder(), permanent: true);
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

    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }
    if (Get.isRegistered<JobsController>()) {
      Get.delete<JobsController>(force: true);
    }
    if (Get.isRegistered<EarningsController>()) {
      Get.delete<EarningsController>(force: true);
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
    if (Get.isRegistered<ExploreController>()) {
      Get.delete<ExploreController>(force: true);
    }
    if (Get.isRegistered<AnalyticsController>()) {
      Get.delete<AnalyticsController>(force: true);
    }
    if (Get.isRegistered<AgencyHomeLockedController>()) {
      Get.delete<AgencyHomeLockedController>(force: true);
    }
    if (Get.isRegistered<BrandHomeLockedController>()) {
      Get.delete<BrandHomeLockedController>(force: true);
    }
    if (Get.isRegistered<InfluencerHomeLockedController>()) {
      Get.delete<InfluencerHomeLockedController>(force: true);
    }

    Get.put(BottomNavController(), permanent: true);
  }
}
