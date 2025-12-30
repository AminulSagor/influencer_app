import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';

import '../../create_campaign_controller/create_campaign_controller.dart';

class TermsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const TermsBlock({super.key, required this.controller});

  static const _primary = Color(0xFF2F4F1F);

  Widget _item({
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Image.asset(icon, height: 20, width: 20, color: AppPalette.primary),

        // Icon(icon, color: _primary, size: 18.sp),

        10.w.horizontalSpace,

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),

              6.h.verticalSpace,

              Text(
                value.trim().isEmpty ? '-' : value.trim(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Column(
      children: [
        _item(
          icon: AppAssets.presentation,
          title: 'create_campaign_step6_reporting_requirements'.tr,
          value: c.reportingRequirements.value,
        ),
        12.h.verticalSpace,
        _item(
          icon: AppAssets.copyright,
          title: 'create_campaign_step6_usage_rights'.tr,
          value: c.usageRights.value,
        ),
      ],
    );
  }
}