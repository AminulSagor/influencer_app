// lib/modules/auth/verification/verification_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              TopBackAndStep(currentStep: 3),

              SizedBox(height: 70.h),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      'otp_title'.tr,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: AppTheme.textStyle.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Subtitle (with phone)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'otp_subtitle'.trParams({'phone': controller.phoneNumber}),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppPalette.primary,
                    fontWeight: .w300,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // OTP fields
              SizedBox(
                height: 80.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return _OtpBox(
                      controller: controller.digitControllers[index],
                      focusNode: controller.focusNodes[index],
                      onChanged: (value) =>
                          controller.onDigitChanged(value, index),
                    );
                  }),
                ),
              ),

              SizedBox(height: 18.h),

              // "Didn't receive? Resend"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'otp_didnt_receive'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppPalette.greyText,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: controller.onResend,
                    child: Text(
                      'otp_resend'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 84.h),

              // Continue button
              Obx(
                () => CustomButton(
                  onTap: controller.onContinue,
                  btnText: 'btn_continue'.tr,
                  height: 64.h,
                  width: double.infinity,
                  textStyle: AppTheme.textStyle.copyWith(
                    fontSize: 18.sp,
                    fontWeight: .w600,
                    color: AppPalette.white,
                  ),
                  isDisabled: !controller.isCodeComplete.value,
                ),
              ),
              const Spacer(),

              // Already have account? Login
              GestureDetector(
                onTap: controller.goToLogin,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'otp_have_account'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[400],
                      ),
                      children: [
                        TextSpan(text: ' '),
                        TextSpan(
                          text: 'auth_login'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
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

/// Single OTP digit box
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74.w,
      height: 90.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 35.sp,
          fontWeight: FontWeight.w600,
          color: AppPalette.secondary,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kBorderRadius.r),
            borderSide: BorderSide(color: AppPalette.defaultStroke, width: 1.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kBorderRadius.r),
            borderSide: BorderSide(color: AppPalette.secondary, width: 2.w),
          ),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
      ),
    );
  }
}
