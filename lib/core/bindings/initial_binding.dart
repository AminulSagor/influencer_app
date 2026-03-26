import 'package:get/get.dart';
import 'package:influencer_app/core/services/location_service.dart';
import 'package:influencer_app/core/services/notification_navigation_service.dart';

import '../controllers/language_controller.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_onboarding_service.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_dashboard_service.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_profile_service.dart';
import 'package:influencer_app/modules/ad_agency/services/upload_service.dart';
import 'package:influencer_app/modules/influencer/services/influencer_onboarding_services.dart';
import 'package:influencer_app/modules/influencer/services/influencer_profile_service.dart';
import 'package:influencer_app/modules/influencer/services/influencer_dashboard_service.dart';
import 'package:influencer_app/modules/brand/services/brand_onboarding_services.dart';
import 'package:influencer_app/core/services/services.dart';
import 'package:influencer_app/core/services/analytics_service.dart';
import 'package:influencer_app/core/services/report_service.dart';
import 'package:influencer_app/core/services/earnings_service.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/modules/brand/services/brand_dashboard_service.dart';
import 'package:influencer_app/modules/brand/explore/services/explore_service.dart';
import 'package:influencer_app/modules/shared/notification/notifications_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LanguageController(), permanent: true);
    Get.put<AccountTypeService>(AccountTypeService(), permanent: true);

    Get.put<TokenService>(TokenService(), permanent: true);

    Get.put<ApiClient>(ApiClient(Get.find<TokenService>()), permanent: true);

    Get.put<AuthService>(
      AuthService(
        apiClient: Get.find<ApiClient>(),
        tokenService: Get.find<TokenService>(),
      ),
      permanent: true,
    );

    Get.put(CampaignService(Get.find<ApiClient>()), permanent: true);

    Get.lazyPut<LocationService>(
      () => LocationService(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.put<OnboardingCheckService>(OnboardingCheckService(), permanent: true);

    Get.put(
      InfluencerOnboardingService(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put(AgencyOnboardingService(Get.find<ApiClient>()), permanent: true);
    Get.put(AgencyDashboardService(Get.find<ApiClient>()), permanent: true);
    Get.put(AgencyProfileService(Get.find<ApiClient>()), permanent: true);
    Get.put(InfluencerProfileService(Get.find<ApiClient>()), permanent: true);
    Get.put(InfluencerDashboardService(Get.find<ApiClient>()), permanent: true);

    Get.put(UploadService(Get.find<ApiClient>()), permanent: true);
    Get.put(BrandOnboardingService(Get.find<ApiClient>()), permanent: true);
    Get.put(BrandDashboardService(Get.find<ApiClient>()), permanent: true);
    Get.put(ExploreService(Get.find<ApiClient>()), permanent: true);
    Get.put(AnalyticsService(Get.find<ApiClient>()), permanent: true);
    Get.put(ReportService(Get.find<ApiClient>()), permanent: true);
    Get.put(EarningsService(Get.find<ApiClient>()), permanent: true);

    Get.lazyPut<NotificationService>(
      () => NotificationService(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.put<AppUserSessionController>(
      AppUserSessionController(),
      permanent: true,
    );

    Get.lazyPut<NotificationsController>(
      () => NotificationsController(service: Get.find<NotificationService>()),
      fenix: true,
    );

    final notificationNavigationService = Get.put(
      NotificationNavigationService(),
      permanent: true,
    );
    notificationNavigationService.init();
  }
}
