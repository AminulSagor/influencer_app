// lib/modules/auth/signup_agency/signup_agency_social_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/signup_info_row.dart';
import 'package:influencer_app/core/widgets/signup_page_header.dart';
import 'package:influencer_app/core/widgets/signup_section_title.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_agency_controller.dart';

class SignupAgencySocialView extends GetView<SignupAgencyController> {
  const SignupAgencySocialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.socialFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBackAndStep(currentStep: 6, onGoBack: controller.goBack),

                SizedBox(height: 32.h),

                // Header
                SignupPageHeader(
                  title: 'agency_social_title'.tr,
                  subtitle: 'agency_social_subtitle'.tr,
                  body: 'agency_social_body'.tr,
                ),

                SizedBox(height: 30.h),

                // Info row
                SignupInfoRow(
                  text: 'influ_social_info'.tr,
                  iconAsset: 'assets/icons/handshake.png',
                ),

                SizedBox(height: 42.h),

                // Section title
                SignupSectionTitle(
                  title: 'influ_social_section_title'.tr,
                  iconAsset: 'assets/icons/media.png',
                ),

                SizedBox(height: 32.h),

                // Website (optional)
                CustomTextFormField(
                  title: 'influ_social_website_label'.tr,
                  hintText: 'influ_social_website_hint'.tr,
                  controller: controller.websiteController,
                  keyboardType: TextInputType.url,
                  contentPadding: EdgeInsets.all(12.w),
                ),

                SizedBox(height: 16.h),

                // Platform dropdown
                Obx(() {
                  return CustomDropDownMenu(
                    title: 'influ_social_platform_label'.tr,
                    hintText: 'influ_social_platform_hint'.tr,
                    options: controller.platformOptions,
                    value: controller.selectedPlatform.value,
                    validator: (value) {
                      if (controller.socialLinks.isNotEmpty) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'influ_social_platform_error'.tr;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      controller.selectedPlatform.value = value;
                    },
                    fillColor: AppPalette.thirdColor,
                  );
                }),

                SizedBox(height: 16.h),

                // Profile link
                CustomTextFormField(
                  title: 'influ_social_profile_label'.tr,
                  hintText: 'influ_social_profile_hint'.tr,
                  controller: controller.profileLinkController,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) {
                    if (controller.socialLinks.isNotEmpty) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_social_profile_error'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 30.h),

                // Add another platform link
                CustomButton.dotted(
                  onTap: controller.addAnotherLink,
                  btnText: 'influ_social_add_another'.tr,
                  height: 41.h,
                  width: double.infinity,
                  textColor: AppPalette.secondary,
                  btnColor: AppPalette.white,
                ),

                SizedBox(height: 32.h),

                CustomButton(
                  onTap: controller.onSocialContinue,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
