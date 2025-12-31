import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/app_assets.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/brand_campaign_details_controller.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/widgets/auote_details_card.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/widgets/progress_row.dart';

import '../brand_campaign_details_view.dart';
import 'card_shell.dart';
import 'card_title.dart';

class CampaignProgressCard extends GetView<BrandCampaignDetailsController> {
  const CampaignProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          CardTitle(
            icon: AppAssets.tergetGoal,
            title: 'brand_campaign_details_campaign_progress'.tr,
          ),

          12.h.verticalSpace,

          Obx(() {
            final current = controller.progressStep.value;

            bool isActive(CampaignProgressStep step) {
              // submitted always true in UI
              if (step == CampaignProgressStep.submitted) return true;
              return current.index >= step.index;
            }

            return Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                children: [
                  ProgressRow(
                    icon: Icons.check_circle_rounded,
                    title: 'brand_campaign_details_submitted'.tr,
                    subtitle: 'brand_campaign_details_submitted_sub'.tr,
                    active: isActive(CampaignProgressStep.submitted),
                  ),

                  ProgressRow(
                    icon: Icons.format_quote_outlined,
                    title: 'brand_campaign_details_quoted'.tr,
                    subtitle: 'brand_campaign_details_quoted_sub'.tr,
                    active: isActive(CampaignProgressStep.quoted),
                  ),

                  ProgressRowLevel(
                    icon: AppAssets.paidBill,
                    title: 'brand_campaign_details_paid'.tr,
                    subtitle: 'brand_campaign_details_paid_sub'.tr,
                    active: isActive(CampaignProgressStep.paid),
                  ),

                  ProgressRowLevel(
                    icon: AppAssets.onlineAdsShade,
                    title: 'brand_campaign_details_promoting'.tr,
                    subtitle: 'brand_campaign_details_promoting_sub'.tr,
                    active: isActive(CampaignProgressStep.promoting),
                  ),

                  ProgressRowLevel(
                    icon: AppAssets.taskCompleted,
                    title: 'brand_campaign_details_completed'.tr,
                    subtitle: 'brand_campaign_details_completed_sub'.tr,
                    active: isActive(CampaignProgressStep.completed),
                  ),
                ],
              ),
            );
          }),

          12.h.verticalSpace,

          QuoteDetailsCard(),
        ],
      ),
    );
  }
}
