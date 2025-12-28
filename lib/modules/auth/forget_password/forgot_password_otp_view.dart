// lib/modules/auth/forgot_password/forgot_password_otp_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordOtpView extends GetView<ForgotPasswordController> {
  const ForgotPasswordOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Back button
              GestureDetector(
                onTap: controller.goBack,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20.sp,
                  color: AppPalette.primary,
                ),
              ),

              SizedBox(height: 80.h),

              // Title
              Text(
                'fp_verify_title'.tr,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12.h),

              // Subtitle with phone/email
              Obx(
                () => Text(
                  'fp_verify_subtitle'.trParams({
                    'phone': controller.contactValue.value,
                  }),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // OTP boxes – same behaviour as signup verification
              SizedBox(
                height: 80.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return _OtpBox(
                      controller: controller.otpControllers[index],
                      focusNode: controller.otpFocusNodes[index],
                      onChanged: (value) =>
                          controller.onOtpDigitChanged(value, index),
                    );
                  }),
                ),
              ),

              SizedBox(height: 18.h),

              // Resend
              Center(
                child: GestureDetector(
                  onTap: controller.resendCode,
                  child: Text(
                    'fp_resend'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Continue button – disabled until 4 digits entered
              Obx(
                () => CustomButton(
                  onTap: controller.onVerifyOtp,
                  btnText: 'fp_otp_continue'.tr,
                  width: double.infinity,
                  height: 56.h,
                  isDisabled: !controller.isOtpComplete.value,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // “Already have an account? Login”
              GestureDetector(
                onTap: controller.goToLogin,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'fp_login_question'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFFD1D5DB),
                      ),
                      children: [
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: 'fp_login'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
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

/// Single OTP digit box (same behaviour as signup VerificationView)
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
      height: 80.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: AppPalette.primary,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: const Color(0xFFCDD5DF), width: 2.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppPalette.primary, width: 2.w),
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
