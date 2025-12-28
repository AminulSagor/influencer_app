import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';
import 'forgot_password_controller.dart';

class ResetPasswordSuccessView extends GetView<ForgotPasswordController> {
  const ResetPasswordSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 72.sp, color: AppPalette.primary),
              SizedBox(height: 24.h),
              Text(
                'fp_success_title'.tr,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.primary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'fp_success_subtitle'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF374151),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.h),
              CustomButton(
                onTap: () {
                  // go to dashboard/home
                  Get.offAllNamed(AppRoutes.login); // adjust route
                },
                btnText: 'fp_success_button'.tr,
                width: double.infinity,
                height: 56.h,
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
