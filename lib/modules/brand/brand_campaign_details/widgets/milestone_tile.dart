import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/widgets/status_pill.dart';

import '../../../../core/models/job_item.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';

class MilestoneTile extends StatelessWidget {
  final Milestone m;
  const MilestoneTile({super.key, required this.m});

  String _statusText(MilestoneStatus s) {
    switch (s) {
      case MilestoneStatus.todo:
        return 'brand_campaign_details_pending'.tr;
      case MilestoneStatus.inReview:
        return 'brand_campaign_details_in_review'.tr;
      case MilestoneStatus.paid:
      case MilestoneStatus.approved:
      case MilestoneStatus.partialPaid:
        return 'brand_campaign_details_completed'.tr;
      case MilestoneStatus.declined:
        return 'brand_campaign_details_declined'.tr;
    }
  }

  ({
  Color bg,
  Color border,
  Color pillBg,
  Color pillBorder,
  Color pillText,
  Color titleColor,
  })
  _style(MilestoneStatus s) {
    switch (s) {
      case MilestoneStatus.approved:
      case MilestoneStatus.paid:
      case MilestoneStatus.partialPaid:
        return (
        bg: const Color(0xFFEFF8E8),
        border: const Color(0xFFBFD7A5),
        pillBg: const Color(0xFFBFD7A5),
        pillBorder: const Color(0xFFBFD7A5),
        pillText: AppPalette.primary,
        titleColor: AppPalette.primary,
        );

      case MilestoneStatus.inReview:
        return (
        bg: const Color(0xFFFFF4E6),
        border: const Color(0xFFF3C68C),
        pillBg: const Color(0xFFFFE7C6),
        pillBorder: const Color(0xFFF3C68C),
        pillText: const Color(0xFFB36B00),
        titleColor: const Color(0xFFB36B00),
        );

      case MilestoneStatus.declined:
        return (
        bg: const Color(0xFFFFEBEB),
        border: const Color(0xFFFFB9B9),
        pillBg: const Color(0xFFFFD6D6),
        pillBorder: const Color(0xFFFFB9B9),
        pillText: const Color(0xFFB32020),
        titleColor: const Color(0xFFB32020),
        );

      case MilestoneStatus.todo:
        return (
        bg: AppPalette.white,
        border: AppPalette.border1,
        pillBg: AppPalette.defaultFill,
        pillBorder: AppPalette.border1,
        pillText: AppPalette.greyText,
        titleColor: AppPalette.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText(m.status);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _style(m.status).bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: AppPalette.defaultFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              m.stepLabel,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppPalette.greyText,
              ),
            ),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.primary,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  m.subtitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.greyText,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusPill(text: statusText),
              6.h.verticalSpace,
              Text(
                m.dayLabel ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}