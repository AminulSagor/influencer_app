// lib/modules/auth/influencer_profile/influencer_profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/widgets/custom_text_form_field.dart';
import 'signup_influencer_controller.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/language_switcher.dart';

class SignupInfluencerView extends GetView<SignupInfluencerController> {
  const SignupInfluencerView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isInfluencer = accountTypeService.isInfluencer;
    final isAdAgency = accountTypeService.isAdAgency;
    final isBrand = accountTypeService.isBrand;

    final topTitle = isBrand
        ? 'brand_profile_title'
        : isInfluencer
        ? 'infl_profile_title'
        : 'agency_profile_title';

    final totalSteps = isBrand
        ? 9
        : isAdAgency
        ? 10
        : 7;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBackAndStep(currentStep: 2, totalSteps: totalSteps),
                SizedBox(height: 28.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    topTitle.tr,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                Text(
                  isBrand
                      ? 'brand_profile_subtitle'.tr
                      : 'infl_profile_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w300,
                    color: AppPalette.primary,
                  ),
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
                if (isBrand)
                  CustomTextFormField(
                    title: 'brand_name_label'.tr,
                    hintText: 'brand_name_hint'.tr,
                    controller: controller.firstNameController,
                    textInputAction: TextInputAction.next,
                    contentPadding: EdgeInsets.all(12.w),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                SizedBox(height: 15.h),

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

                CustomTextFormField(
                  title: 'infl_phone_label'.tr,
                  hintText: 'infl_phone_hint'.tr,
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 15.h),

                // language switcher segment
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: LanguageSwitcher(),
                ),
                SizedBox(height: 28.h),

                // Continue button
                CustomButton(
                  onTap: controller.onStep1Continue,
                  btnText: 'btn_continue'.tr,
                  height: 64.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.white,
                  ),
                ),
                SizedBox(height: 20.h),

                // Already have account
                Center(
                  child: GestureDetector(
                    onTap: controller.goToLogin,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppPalette.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: '${'auth_already_have_account'.tr} '),
                          TextSpan(
                            text: 'auth_login'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppPalette.black,
                              fontWeight: FontWeight.w500,
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
