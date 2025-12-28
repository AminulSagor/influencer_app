// lib/modules/auth/login/login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/language_switcher.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top language switcher
              SizedBox(height: 20.h),
              const Align(
                alignment: Alignment.topRight,
                child: LanguageSwitcher(),
              ),
              SizedBox(height: 40.h),

              // Title + subtitle
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'login_title'.tr,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 52.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'login_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w300,
                    color: AppPalette.primary,
                  ),
                ),
              ),

              SizedBox(height: 60.h),

              // Phone field
              CustomTextFormField(
                hintText: 'login_phone_hint'.tr,
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 16.h,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  size: 24.sp,
                  color: AppPalette.greyText,
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: .w400,
                  color: AppPalette.greyText,
                ),
              ),
              SizedBox(height: 12.h),

              // Password field
              Obx(() {
                return CustomTextFormField(
                  hintText: 'login_password_hint'.tr,
                  controller: controller.passwordController,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: 24.sp,
                    color: AppPalette.greyText,
                  ),
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: .w400,
                    color: AppPalette.greyText,
                  ),
                  obscureText: controller.isPasswordObscured.value,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 16.h,
                  ),
                  suffixIcon: IconButton(
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      controller.isPasswordObscured.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp,
                      color: AppPalette.greyText,
                    ),
                  ),
                );
              }),

              SizedBox(height: 18.h),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: controller.forgotPassword,
                  child: Text(
                    'login_forgot_password'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.black,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Login button
              Obx(
                () => CustomButton(
                  onTap: controller.isLoading.value
                      ? null
                      : controller.submitLogin,
                  btnText: 'login_button'.tr,
                  height: 64.h,
                  width: double.infinity,
                  isLoading: controller.isLoading.value,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const Spacer(),

              // Bottom "Don't have an account" row
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'login_no_account'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.greyText,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: controller.goToSignUp,
                        child: Text(
                          'login_sign_up'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
