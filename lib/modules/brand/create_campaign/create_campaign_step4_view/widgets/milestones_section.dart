import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step2_view/widgets/empty_state.dart';

import '../../../../../core/models/job_item.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../create_campaign_controller/create_campaign_controller.dart';
import 'add_another_milestone_button.dart';
import 'milestone_card.dart';
import 'milestone_editor_card.dart';
import 'milestone_editor_promotion_card.dart';

class MilestonesSection extends StatelessWidget {
  final CreateCampaignController controller;
  const MilestonesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.milestonesExpanded.value;
      final list = controller.milestones.toList(growable: false);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 23, vertical: 25),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: controller.toggleMilestonesExpanded,
              child: Row(
                children: [

                  Image.asset(AppAssets.mission, height: 23, width: 23,color: AppPalette.primary),

                  5.w.horizontalSpace,

                  Expanded(
                    child: Text(
                      'create_campaign_step4_milestones'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),

                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 25.sp,
                    color: AppPalette.primary,
                  ),
                ],
              ),
            ),

            if (!expanded) const SizedBox.shrink(),

            if (expanded) ...[
              18.h.verticalSpace,

              ...List.generate(list.length, (i) {
                final m = list[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: MilestoneCard(
                    index: i + 1,
                    title: m.title,
                    subtitle: m.subtitle ?? '',
                    dayLabel: m.dayLabel ?? '',
                  ),
                );
              }),

              Obx(() {
                if (!controller.isAddingMilestone.value) {
                  return AddAnotherMilestoneButton(
                    onTap: controller.startAddMilestone,
                  );
                }

                return Obx(() {
                  final type = controller.selectedType.value;

                  if (type == null) {
                    return EmptyState(onBack: controller.onPrevious);
                  }

                  if (type == CampaignType.influencerPromotion) {
                    return MilestoneEditorCard(controller: controller);
                  }

                  return MilestoneEditorPromotionCard(controller: controller);
                });
                // return MilestoneEditorCard(controller: controller);
              }),
            ],
          ],
        ),
      );
    });
  }
}