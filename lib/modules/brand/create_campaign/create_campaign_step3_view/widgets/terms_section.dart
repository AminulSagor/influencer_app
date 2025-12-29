import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/constants.dart';
import '../../create_campaign_controller/create_campaign_controller.dart';
import 'multiline_box.dart';

class TermsSection extends StatelessWidget {
  final CreateCampaignController controller;
  const TermsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 19, vertical: 22),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(
          color: AppPalette.border1,
          width: kBorderWidth0_5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [

              Image.asset(AppAssets.presentation, height: 20, width: 20,color: AppPalette.primary),

              Text(
                'create_campaign_reporting_requirements_label'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),

          10.h.verticalSpace,

          MultilineBox(
            controller: controller.reportingReqCtrl,
            hint: 'create_campaign_reporting_requirements_hint'.tr,
            onChanged: controller.onReportingReqChanged,
          ),

          14.h.verticalSpace,

          Row(
            spacing: 10,
            children: [
              Image.asset(AppAssets.copyright, height: 20, width: 20,color: AppPalette.primary),

              Text(
                'create_campaign_usage_rights_label'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),

          6.h.verticalSpace,

          MultilineBox(
            controller: controller.usageRightsCtrl,
            hint: 'create_campaign_usage_rights_hint'.tr,
            onChanged: controller.onUsageRightsChanged,
          ),
        ],
      ),
    );
  }
}