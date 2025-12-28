import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../core/theme/app_palette.dart';

class AddAnotherMilestoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddAnotherMilestoneButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppPalette.primary.withAlpha(120),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(

          child: Text(
            'create_campaign_step4_add_milestone'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppPalette.secondary,
            ),
          ),
        ),
      ),
    );
  }
}