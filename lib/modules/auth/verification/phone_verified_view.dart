import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';
import 'package:influencer_app/modules/auth/verification/verification_controller.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';

class PhoneVerifiedView extends GetView<VerificationController> {
  const PhoneVerifiedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              TopBackAndStep(currentStep: 4),

              SizedBox(height: 80.h),

              // Check icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppPalette.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 64.sp,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 15.h),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'phone_verified_title'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                      height: 1.2,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 78.h),

              // Body text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Text(
                  'phone_verified_body'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w300,
                    color: AppPalette.black,
                  ),
                ),
              ),

              SizedBox(height: 37.h),

              // Continue button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: CustomButton(
                  onTap: controller.onPhoneVerifiedGoNext,
                  btnText: 'btn_continue'.tr,
                  height: 64.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6.h,
      child: Row(
        children: [
          Expanded(
            flex: 3, // active segment
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: AppPalette.primary,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          // remaining dots (just 5 small circles like design)
          ...List.generate(5, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: AppPalette.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
