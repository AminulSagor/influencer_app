import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/widgets/custom_button.dart';
import 'forgot_password_controller.dart';

class ResetPasswordView extends GetView<ForgotPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          child: Form(
            key: controller.resetFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80.h),

                Text(
                  'fp_new_title'.tr,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'fp_new_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                SizedBox(height: 40.h),

                TextFormField(
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'fp_new_password_hint'.tr,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 20.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'fp_confirm_password_hint'.tr,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 20.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                CustomButton(
                  onTap: controller.onResetPassword,
                  btnText: 'fp_reset_button'.tr,
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
      ),
    );
  }
}
