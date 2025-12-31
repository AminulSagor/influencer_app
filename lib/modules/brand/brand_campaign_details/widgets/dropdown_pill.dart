import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';

class DropdownPill extends StatelessWidget {
  final String text;
  const DropdownPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppPalette.defaultFill,
        borderRadius: BorderRadius.circular(10.r),
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
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.greyText,
              ),
            ),
          ),

          Icon(Icons.keyboard_arrow_down_rounded, color: AppPalette.greyText),
        ],
      ),
    );
  }
}
