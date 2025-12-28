import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../core/theme/app_palette.dart';

class DraftButton extends StatelessWidget {
  final VoidCallback onTap;
  const DraftButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppPalette.secondary,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          'create_campaign_save_draft'.tr,
          style: TextStyle(
            color: AppPalette.thirdColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}