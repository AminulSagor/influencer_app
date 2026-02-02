import 'package:get/get.dart';

import '../controllers/language_controller.dart';
import '../services/account_type_service.dart';
import '../services/api_client.dart';
import '../services/auth_services.dart';
import '../services/campaign_service.dart';
import '../services/token_service.dart';
import '../services/onboarding_check_service.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_onboarding_service.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_dashboard_service.dart';
import 'package:influencer_app/modules/ad_agency/services/upload_service.dart';
import 'package:influencer_app/modules/influencer/services/influencer_onboarding_services.dart';
import 'package:influencer_app/modules/brand/services/brand_onboarding_services.dart';
import 'package:influencer_app/modules/brand/services/brand_dashboard_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LanguageController(), permanent: true);
    Get.put<AccountTypeService>(AccountTypeService(), permanent: true);

    // Storage first
    Get.put<TokenService>(TokenService(), permanent: true);

    // ApiClient next (depends on TokenService)
    Get.put<ApiClient>(ApiClient(Get.find<TokenService>()), permanent: true);

    // Auth service (depends on ApiClient + TokenService)
    Get.put<AuthService>(
      AuthService(
        apiClient: Get.find<ApiClient>(),
        tokenService: Get.find<TokenService>(),
      ),
      permanent: true,
    );

    // Campaign service (depends on ApiClient)
    Get.put(CampaignService(Get.find<ApiClient>()), permanent: true);

    // Onboarding check service (depends on ApiClient)
    Get.put<OnboardingCheckService>(OnboardingCheckService(), permanent: true);

    // Feature services (depend on ApiClient)
    Get.put(
      InfluencerOnboardingService(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put(AgencyOnboardingService(Get.find<ApiClient>()), permanent: true);
    Get.put(AgencyDashboardService(Get.find<ApiClient>()), permanent: true);

    Get.put(UploadService(Get.find<ApiClient>()), permanent: true);
    Get.put(BrandOnboardingService(Get.find<ApiClient>()), permanent: true);
    Get.put(BrandDashboardService(Get.find<ApiClient>()), permanent: true);
  }
}
