import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';

class FilterChip extends StatelessWidget {
  final String text;
  const FilterChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppPalette.thirdColor,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.secondary, width: kBorderWeight1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_downward_rounded,
            size: 10.sp,
            color: AppPalette.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
    );
  }
}
