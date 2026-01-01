import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_palette.dart';
import '../utils/constants.dart';

class SortToggleChip extends StatelessWidget {
  final bool isLowToHigh;
  final VoidCallback onTap;
  final String lowToHighText;
  final String highToLowText;

  const SortToggleChip({
    super.key,
    required this.isLowToHigh,
    required this.onTap,
    required this.lowToHighText,
    required this.highToLowText,
  });

  @override
  Widget build(BuildContext context) {
    final label = isLowToHigh ? lowToHighText : highToLowText;
    final icon = isLowToHigh
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppPalette.thirdColor,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: AppPalette.secondary,
            width: kBorderWeight1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10.sp, color: AppPalette.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
