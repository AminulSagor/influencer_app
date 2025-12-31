import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/brand_campaign_details_controller.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_assets.dart';
import '../../create_campaign/create_campaign_step6_view/widgets/milestone_tile.dart';
import '../brand_campaign_details_view.dart';
import 'card_shell.dart';
import 'card_title.dart';
import 'dropdown_pill.dart';

class MilestonesCard extends GetView<BrandCampaignDetailsController> {
  const MilestonesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        children: [
          InkWell(
            onTap: controller.toggleMilestones,
            child: Row(
              children: [

                Expanded(
                  child: CardTitle(
                    icon: AppAssets.mission,
                    title: 'brand_campaign_details_campaign_milestones'.tr,
                  ),
                ),
                Obx(() {
                  return Icon(
                    controller.milestonesExpanded.value
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppPalette.greyText,
                  );
                }),
              ],
            ),
          ),

          10.h.verticalSpace,

          Obx(() {
            if (!controller.milestonesExpanded.value)
              return const SizedBox.shrink();

            final list = controller.milestones.toList(growable: false);

            final completedCount = list.where((m) => m.isApproved || m.isPaid).length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownPill(text: controller.milestoneStatusLabel.value),

                10.h.verticalSpace,

                Row(
                  children: [
                    Text(
                      'brand_campaign_details_progress'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.black,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '$completedCount ${'brand_campaign_details_of'.tr} ${list.length} ${'brand_campaign_details_completed_small'.tr}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.black,
                      ),
                    ),
                  ],
                ),
                10.h.verticalSpace,
                ...list.map((m) => MilestoneTile(m: m)).toList(),
              ],
            );
          }),
        ],
      ),
    );
  }
}