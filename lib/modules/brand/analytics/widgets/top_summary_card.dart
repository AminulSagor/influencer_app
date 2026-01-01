import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/constants.dart';

import '../../../../core/theme/app_palette.dart';

class TopSummaryCard extends StatelessWidget {
  final RxString topCampaign;
  final RxString topInfluencer;

  const TopSummaryCard({
    super.key,
    required this.topCampaign,
    required this.topInfluencer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        gradient: const LinearGradient(
          colors: [AppPalette.gradient1, AppPalette.secondary],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _SummaryColumn(
                icon: Icons.water_drop_rounded,
                label: 'analytics_top_campaign'.tr,
                value: topCampaign.value,
              ),
            ),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Obx(
              () => _SummaryColumn(
                icon: Icons.person_rounded,
                label: 'analytics_top_influencer'.tr,
                value: topInfluencer.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: AppPalette.white),
            5.w.horizontalSpace,
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.textStyle.copyWith(
                  color: AppPalette.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        2.h.verticalSpace,
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.textStyle.copyWith(
            color: AppPalette.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
