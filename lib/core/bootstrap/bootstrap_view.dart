import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import 'bootstrap_controller.dart';

class BootstrapView extends GetView<BootstrapController> {
  const BootstrapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80.h,
              width: 80.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppPalette.thirdColor,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppPalette.secondary,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'BrandGuru',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: 26.w,
              height: 26.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
