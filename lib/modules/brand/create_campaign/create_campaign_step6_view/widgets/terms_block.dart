import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../create_campaign_controller/create_campaign_controller.dart';

class TermsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const TermsBlock({super.key, required this.controller});

  static const _primary = Color(0xFF2F4F1F);

  Widget _item({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primary, size: 18.sp),
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
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              6.h.verticalSpace,
              Text(
                value.trim().isEmpty ? '-' : value.trim(),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: Colors.black54,
                  height: 1.35,
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
          icon: Icons.analytics_outlined,
          title: 'create_campaign_step6_reporting_requirements'.tr,
          value: c.reportingRequirements.value,
        ),
        12.h.verticalSpace,
        _item(
          icon: Icons.copyright_outlined,
          title: 'create_campaign_step6_usage_rights'.tr,
          value: c.usageRights.value,
        ),
      ],
    );
  }
}