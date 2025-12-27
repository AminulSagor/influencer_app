import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/brand_campaign_details_controller.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/brand_campaign_details_view.dart';
import 'package:influencer_app/modules/brand/brand_milestone_details/brand_milestone_details_controller.dart';
import 'package:influencer_app/modules/brand/brand_milestone_details/brand_milestone_details_view.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_controller.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step2_view.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_view.dart';
import 'package:influencer_app/modules/shared/language/language_view.dart';

import '../../../../core/services/account_type_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../brand/create_campaign/create_campaign_step3_view.dart';
import '../../../brand/create_campaign/create_campaign_step4_view.dart';
import '../../../brand/create_campaign/create_campaign_step5_view.dart';
import '../../../brand/create_campaign/create_campaign_step6_view.dart';
import '../../campaign_details/campaign_details_controller.dart';
import '../../campaign_details/campaign_details_view.dart';
import '../../earnings/earnings_view.dart';
import '../../../ad_agency/home_locked/agency_home_locked_view.dart';
import '../../jobs/jobs_view.dart';
import '../../milestone_details/milestone_details_controller.dart';
import '../../milestone_details/milestone_details_view.dart';
import '../../notification/notifications_view.dart';
import '../../profile/profile_view.dart';
import '../../home/home_view.dart';
import '../../report_log/report_log_controller.dart';
import '../../report_log/report_log_view.dart';
import '../../support/support_controller.dart';
import '../../support/support_view.dart';

class BottomNavRouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // We grab the service to check permissions for exclusive routes
    final accountService = Get.find<AccountTypeService>();

    if (!accountService.hasSelectedRole) {
      return _errorRoute('No selected role found!');
    }

    switch (settings.name) {
      // -----------------------------------------------------------
      // 1. SHARED ROUTES (Used by Agency, Influencer, maybe Brand)
      // -----------------------------------------------------------
      // The Views themselves handle the UI differences (if/else widgets)
      case AppRoutes.home:
        return GetPageRoute(settings: settings, page: () => const HomeView());

      case AppRoutes.jobs:
        return GetPageRoute(settings: settings, page: () => const JobsView());

      case AppRoutes.earnings:
        return GetPageRoute(
          settings: settings,
          page: () => const EarningsView(),
        );

      case AppRoutes.profile:
        return GetPageRoute(
          settings: settings,
          page: () => const ProfileView(),
        );

      case AppRoutes.notifications:
        return GetPageRoute(
          settings: settings,
          page: () => const NotificationsView(),
        );

      case AppRoutes.support:
        return GetPageRoute(
          settings: settings,
          page: () => const SupportView(),
          binding: SupportBinding(),
        );
      case AppRoutes.language:
        return GetPageRoute(
          settings: settings,
          page: () => const LanguageView(),
        );
      case AppRoutes.reportLog:
        return GetPageRoute(
          settings: settings,
          page: () => const ReportLogView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<ReportLogController>(() => ReportLogController());
          }),
        );
      case AppRoutes.createCampaign:
        return GetPageRoute(
          settings: settings,
          page: () => const CreateCampaignView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<CreateCampaignController>(
              () => CreateCampaignController(),
            );
          }),
        );
      case AppRoutes.createCampaignStep2:
        return GetPageRoute(
          settings: settings,
          page: () => CreateCampaignStep2View(),
        );
      case AppRoutes.createCampaignStep3:
        return GetPageRoute(
          settings: settings,
          page: () => const CreateCampaignStep3View(),
        );
      case AppRoutes.createCampaignStep4:
        return GetPageRoute(
          settings: settings,
          page: () => const CreateCampaignStep4View(),
        );
      case AppRoutes.createCampaignStep5:
        return GetPageRoute(
          settings: settings,
          page: () => const CreateCampaignStep5View(),
        );
      case AppRoutes.createCampaignStep6:
        return GetPageRoute(
          settings: settings,
          page: () => const CreateCampaignStep6View(),
        );
      case AppRoutes.agencyHomeLocked:
        return GetPageRoute(
          settings: settings,
          page: () => const AgencyHomeLockedView(),
        );

      case AppRoutes.campaignDetails:
        return GetPageRoute(
          settings: settings,
          page: () => CampaignDetailsView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<CampaignDetailsController>(
              () => CampaignDetailsController(settings.arguments),
            );
          }),
        );

      case AppRoutes.brandCampaignDetails:
        return GetPageRoute(
          settings: settings,
          page: () => BrandCampaignDetailsView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<BrandCampaignDetailsController>(
              () => BrandCampaignDetailsController(settings.arguments),
            );
          }),
        );
      case AppRoutes.brandMilestoneDetails:
        return GetPageRoute(
          settings: settings,
          page: () => BrandMilestoneDetailsView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<BrandMilestoneDetailsController>(
              () => BrandMilestoneDetailsController(),
            );
          }),
        );

      case AppRoutes.milestoneDetails:
        return GetPageRoute(
          settings: settings,
          page: () => MilestoneDetailsView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<MilestoneDetailsController>(
              () => MilestoneDetailsController(settings.arguments),
            );
          }),
        );
      default:
        // Default fallback to Home
        return GetPageRoute(settings: settings, page: () => const HomeView());
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return GetPageRoute(
      page: () => Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: Center(child: Text(message)),
      ),
    );
  }
}
