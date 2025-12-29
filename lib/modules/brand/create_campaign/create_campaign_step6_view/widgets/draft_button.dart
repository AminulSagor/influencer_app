import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class DraftButton extends StatelessWidget {
  final VoidCallback onTap;
  const DraftButton({required this.onTap});

  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _primary.withOpacity(.7),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          'create_campaign_save_draft'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}