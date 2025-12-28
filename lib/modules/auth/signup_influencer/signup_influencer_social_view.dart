// lib/modules/auth/signup_influencer/signup_influencer_social_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/services/account_type_service.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_influencer_controller.dart';

class SignupInfluencerSocialView extends GetView<SignupInfluencerController> {
  const SignupInfluencerSocialView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isBrand = accountTypeService.isBrand;
    final isInfluencer = accountTypeService.isInfluencer;

    final title = isInfluencer
        ? 'influ_social_title'.tr
        : isBrand
        ? 'brand_social_title'.tr
        : 'agency_social_title'.tr;
    final subTitle = isInfluencer
        ? 'influ_social_subtitle'.tr
        : isBrand
        ? 'brand_social_subtitle'.tr
        : 'agency_social_subtitle'.tr;
    final body = isInfluencer
        ? 'influ_social_body'.tr
        : isBrand
        ? 'brand_social_body'.tr
        : 'agency_social_body'.tr;

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
                TopBackAndStep(currentStep: 6),

                SizedBox(height: 32.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title.tr,
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Subtitle
                Text(
                  subTitle.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.secondary,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  body.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppPalette.primary,
                    fontWeight: .w300,
                  ),
                ),

                SizedBox(height: 30.h),

                // Info row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/handshake.png', width: 30.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'influ_social_info'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 42.h),

                // Section title
                Row(
                  children: [
                    Image.asset('assets/icons/media.png', width: 30.w),
                    SizedBox(width: 10.w),
                    Text(
                      'influ_social_section_title'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // Website (optional)
                CustomTextFormField(
                  title: 'influ_social_website_label'.tr,
                  hintText: 'influ_social_website_hint'.tr,
                  controller: controller.websiteController,
                  keyboardType: TextInputType.url,
                ),

                SizedBox(height: 16.h),

                // Platform dropdown
                Obx(() {
                  return CustomDropDownMenu(
                    title: 'influ_social_platform_label'.tr,
                    hintText: 'influ_social_platform_hint'.tr,
                    options: controller.platformOptions,
                    value: controller.selectedPlatform.value,
                    onChanged: (value) {
                      controller.selectedPlatform.value = value;
                    },
                    fillColor: AppPalette.thirdColor,
                    textStyle: AppTheme.textStyle.copyWith(
                      fontWeight: .w500,
                      color: AppPalette.secondary,
                      fontSize: 12.sp,
                    ),
                  );
                }),

                SizedBox(height: 20.h),

                // Profile link
                CustomTextFormField(
                  title: 'influ_social_profile_label'.tr,
                  hintText: 'influ_social_profile_hint'.tr,
                  controller: controller.profileLinkController,
                ),

                SizedBox(height: 30.h),

                // Add another
                CustomButton.dotted(
                  onTap: controller.addAnotherLink,
                  btnText: 'influ_social_add_another'.tr,
                  height: 41.h,
                  width: double.infinity,
                  textColor: AppPalette.secondary,
                  btnColor: AppPalette.white,
                ),

                SizedBox(height: 40.h),

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

// ----------------- Reusable widgets -----------------

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(999.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: AppPalette.primary,
            ),
          ),
        ),
        const Spacer(),
        const _ProgressDots(activeIndex: 4, total: 7),
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int activeIndex;
  final int total;

  const _ProgressDots({required this.activeIndex, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index == activeIndex;
        final isBar = index == activeIndex;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isBar ? 70.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: AppPalette.primary,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
        );
      }),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppPalette.primary,
      ),
    );
  }
}

/// Reusable styled dropdown
class PrimaryDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hintText;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;

  const PrimaryDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      items: items
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppPalette.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    );
  }
}
