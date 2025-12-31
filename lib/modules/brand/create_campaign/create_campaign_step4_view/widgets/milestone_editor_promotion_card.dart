import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/core/utils/app_assets.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step3_view/widgets/multiline_box.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step4_view/widgets/select_field.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';
import '../../create_campaign_controller/create_campaign_controller.dart';
import 'mini_metric_field.dart';
import 'mini_metric_promotion_field.dart';

class MilestoneEditorPromotionCard extends StatelessWidget {
  final CreateCampaignController controller;
  const MilestoneEditorPromotionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final idx = controller.milestones.length + 1;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.primary.withAlpha(90), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppPalette.primary.withAlpha(180),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$idx',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                  splashRadius: 20.r,
                  onPressed: controller.saveMilestone,
                  icon: Image.asset(AppAssets.done, height: 16, width: 16, color: AppPalette.primary)
              ),
              IconButton(
                  splashRadius: 20.r,
                  onPressed: controller.closeMilestoneEditor,
                  icon: Image.asset(AppAssets.close, height: 18, width: 18, color: AppPalette.primary)
              ),
            ],
          ),

          10.h.verticalSpace,

          CustomTextFormField(
            hintText: 'create_campaign_step4_milestone_title_hint'.tr,
            controller: controller.milestoneTitleCtrl,
            textInputAction: TextInputAction.next,
          ),

          10.h.verticalSpace,

          Obx(() {
            final v = controller.selectedMilestonePlatform.value;
            return SelectField(
              text: v ?? 'create_campaign_step4_milestone_platform_hint'.tr,
              isPlaceholder: v == null,
              onTap: controller.openPlatformPicker,
            );
          }),

          10.h.verticalSpace,

          CustomTextFormField(
            hintText: 'create_campaign_step4_milestone_deliverable_hint'.tr,
            controller: controller.milestoneDeliverableCtrl,
            textInputAction: TextInputAction.next,
          ),
          10.h.verticalSpace,

          Obx(() {
            final d = controller.selectedMilestoneDay.value;
            return SelectField(
              text: d == null
                  ? 'create_campaign_step4_milestone_day_hint'.tr
                  : 'DAY $d',
              isPlaceholder: d == null,
              onTap: controller.openDayPicker,
            );
          }),

          25.h.verticalSpace,

          Row(
            children: [

              Image.asset(AppAssets.increase, height: 20, width: 20,color: AppPalette.black),

              8.w.horizontalSpace,

              Text(
                'create_campaign_step4_promo_target'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),

          16.h.verticalSpace,

          MiniMetricPromotionField(
            label: 'create_campaign_step6_campaign_target_title'.tr,
            controller: controller.reachCtrl, hint: 'Reach',
          ),

          12.h.verticalSpace,

          MiniMetricPromotionField(
            label: 'create_campaign_step6_campaign_target_amount'.tr,
            controller: controller.viewsCtrl, hint: '2.5M',
          ),

          8.h.verticalSpace,

          Row(
            children: [

              Image.asset(AppAssets.increase, height: 20, width: 20,color: AppPalette.black),

              8.w.horizontalSpace,

              Text(
                'create_campaign_step6_campaign_promotion_goal'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),

          8.w.horizontalSpace,

          Container(
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            child: TextFormField(
              maxLines: 4,
              style: TextStyle(fontSize: 12.sp, color: AppPalette.greyText, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'create_campaign_step6_campaign_describe_your_campaign_goal'.tr,
                hintStyle: TextStyle(fontSize: 12.sp, color: AppPalette.subtext, fontWeight: FontWeight.w400),
              ),
            ),
          )

        ],
      ),
    );
  }
}