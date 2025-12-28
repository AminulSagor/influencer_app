import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          child: Form(
            key: controller.contactFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // back
                InkWell(
                  onTap: controller.goBack,
                  borderRadius: BorderRadius.circular(999.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22.sp,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                SizedBox(height: 80.h),

                // title
                Text(
                  'fp_title'.tr,
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'fp_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 40.h),

                // input
                TextFormField(
                  controller: controller.contactController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'fp_input_hint'.tr,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: const Color(0xFF9CA3AF),
                      size: 22.sp,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppPalette.primary,
                        width: 1.4,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                CustomButton(
                  onTap: controller.onSendResetLink,
                  btnText: 'fp_continue'.tr,
                  height: 56.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 24.h),

                Center(
                  child: GestureDetector(
                    onTap: controller.goToLogin,
                    child: RichText(
                      text: TextSpan(
                        text: 'fp_login_question'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFD1D5DB),
                        ),
                        children: [
                          TextSpan(
                            text: '  ${'fp_login'.tr}',
                            style: TextStyle(
                              fontSize: 14.sp,
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
      ),
    );
  }
}
