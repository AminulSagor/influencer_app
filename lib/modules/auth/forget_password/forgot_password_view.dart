import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.white,
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
                      Icons.arrow_back,
                      size: 22.sp,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                SizedBox(height: 80.h),

                // title
                Center(
                  child: Text(
                    'fp_title'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.black,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                Text(
                  'fp_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppPalette.black.withAlpha(220),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 20.h),

                // input
                CustomTextFormField(
                  controller: controller.contactController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'fp_input_hint'.tr,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 16.h,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppPalette.greyText,
                    size: 22.sp,
                  ),
                  textStyle: AppTheme.textStyle.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 40.h),

                CustomButton(
                  onTap: controller.onSendResetLink,
                  btnText: 'fp_continue'.tr,
                  height: 64.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 60.h),

                Center(
                  child: GestureDetector(
                    onTap: controller.goToLogin,
                    child: RichText(
                      text: TextSpan(
                        text: 'fp_login_question'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.greyText,
                        ),
                        children: [
                          TextSpan(
                            text: '  ${'fp_login'.tr}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppPalette.black,
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
