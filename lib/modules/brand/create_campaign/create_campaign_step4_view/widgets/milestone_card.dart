import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class MilestoneCard extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String dayLabel;

  const MilestoneCard({super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.dayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.primary.withAlpha(90), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.primary.withAlpha(180),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppPalette.thirdColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),

                3.h.verticalSpace,

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: AppPalette.greyText, fontWeight: FontWeight.w400,),
                ),
              ],
            ),
          ),

          10.w.horizontalSpace,

          Text(
            dayLabel,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.secondary,
            ),
          ),
          6.w.horizontalSpace,
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20.sp,
            color: AppPalette.primary,
          ),
        ],
      ),
    );
  }
}