import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class SelectLikeField extends StatelessWidget {
  final String text;
  final bool isPlaceholder;
  final IconData trailing;
  final VoidCallback onTap;

  const SelectLikeField({super.key,
    required this.text,
    required this.isPlaceholder,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isPlaceholder ? AppPalette.subtext : AppPalette.black,
                ),
              ),
            ),
            Icon(trailing, size: 20.sp, color: AppPalette.black),
          ],
        ),
      ),
    );
  }
}