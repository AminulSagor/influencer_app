// lib/modules/auth/signup_brand/signup_brand_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/signup_page_header.dart';
import 'signup_brand_controller.dart';

class SignupBrandView extends GetView<SignupBrandController> {
  const SignupBrandView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final totalSteps = accountTypeService.isBrand ? 9 : 7;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBackAndStep(
                  currentStep: 2,
                  totalSteps: totalSteps,
                  onGoBack: controller.goBack,
                ),
                SizedBox(height: 28.h),

                // Header
                SignupPageHeader(
                  title: 'brand_profile_title'.tr,
                  subtitle: 'brand_profile_subtitle'.tr,
                ),

                SizedBox(height: 27.h),

                // Section title
                Text(
                  'infl_profile_section_title'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
                SizedBox(height: 15.h),

                // Brand name
                CustomTextFormField(
                  title: 'brand_name_label'.tr,
                  hintText: 'brand_name_hint'.tr,
                  controller: controller.brandNameController,
                  textInputAction: TextInputAction.next,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 15.h),

                // First name
                CustomTextFormField(
                  title: 'infl_first_name_label'.tr,
                  hintText: 'infl_first_name_hint'.tr,
                  controller: controller.firstNameController,
                  textInputAction: TextInputAction.next,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 15.h),

                // Last name
                CustomTextFormField(
                  title: 'infl_last_name_label'.tr,
                  hintText: 'infl_last_name_hint'.tr,
                  controller: controller.lastNameController,
                  textInputAction: TextInputAction.next,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 15.h),

                // Email
                CustomTextFormField(
                  title: 'infl_email_label'.tr,
                  hintText: 'infl_email_hint'.tr,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (!GetUtils.isEmail(value.trim())) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),

                // Phone
                CustomTextFormField(
                  title: 'infl_phone_label'.tr,
                  hintText: 'infl_phone_hint'.tr,
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 15.h),

                // Password
                CustomTextFormField(
                  title: 'brand_step1_password_label'.tr,
                  hintText: 'brand_step1_password_hint'.tr,
                  controller: controller.passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (value.trim().length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Language toggle
                const LanguageSwitcher(),

                SizedBox(height: 28.h),

                // Continue button
                CustomButton(
                  onTap: controller.onContinue,
                  btnText: 'btn_continue'.tr,
                  height: 64.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.white,
                  ),
                ),

                SizedBox(height: 24.h),

                // Already have account
                Center(
                  child: GestureDetector(
                    onTap: controller.goToLogin,
                    child: RichText(
                      text: TextSpan(
                        text: 'auth_already_have_account'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppPalette.subtext,
                        ),
                        children: [
                          TextSpan(
                            text: ' ${'auth_login'.tr}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
