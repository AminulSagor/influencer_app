import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/widgets/custom_button.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const EmptyState({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'create_campaign_step2_missing_type'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppPalette.black),
            ),
            14.h.verticalSpace,
            CustomButton(
              btnText: 'common_previous'.tr,
              onTap: onBack,
              btnColor: AppPalette.secondary,
              borderColor: Colors.transparent,
              showBorder: false,
              textColor: AppPalette.white,
            ),
          ],
        ),
      ),
    );
  }
}