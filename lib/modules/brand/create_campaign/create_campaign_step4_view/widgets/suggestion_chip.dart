import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';

class SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SuggestionChip({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppPalette.defaultFill.withAlpha(160),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: AppPalette.primary.withAlpha(120),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary.withAlpha(190),
            ),
          ),
        ),
      ),
    );
  }
}