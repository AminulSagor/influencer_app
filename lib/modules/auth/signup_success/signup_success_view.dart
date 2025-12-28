import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_success_controller.dart';

class SignupSuccessView extends GetView<SignupSuccessController> {
  const SignupSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + subtitle
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'influ_success_title'.tr,
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'influ_success_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.secondary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'influ_success_body'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppPalette.primary,
                    fontWeight: .w300,
                  ),
                ),

                SizedBox(height: 32.h),

                // Illustration placeholder
                Center(
                  child: Image.asset(
                    'assets/images/welcome.png',
                    width: 263.w,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 32.h),

                // Info row + hint text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/project_management.png',
                      width: 36.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'influ_success_hint'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppPalette.secondary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 60.h),

                // Button
                CustomButton(
                  onTap: controller.goToDashboard,
                  btnText: 'influ_success_btn'.tr,
                  height: 64.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
