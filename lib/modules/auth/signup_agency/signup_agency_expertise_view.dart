// lib/modules/auth/signup_agency/signup_agency_expertise_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';
import 'package:influencer_app/core/widgets/signup_info_row.dart';
import 'package:influencer_app/core/widgets/signup_page_header.dart';
import 'package:influencer_app/core/widgets/signup_section_title.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_agency_controller.dart';

class SignupAgencyExpertiseView extends GetView<SignupAgencyController> {
  const SignupAgencyExpertiseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.expertiseFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBackAndStep(currentStep: 3, onGoBack: controller.goBack),

                SizedBox(height: 32.h),

                // Header
                SignupPageHeader(
                  title: 'agency_expertise_title'.tr,
                  subtitle: 'agency_expertise_subtitle'.tr,
                  body: 'agency_expertise_body'.tr,
                ),

                SizedBox(height: 28.h),

                // Info row
                SignupInfoRow(
                  text: 'agency_expertise_info'.tr,
                  iconData: Icons.filter_alt_rounded,
                ),

                SizedBox(height: 32.h),

                // Section title
                SignupSectionTitle(
                  title: 'agency_expertise_section_title'.tr,
                  iconData: Icons.category_outlined,
                ),

                SizedBox(height: 24.h),

                // Platform blocks
                Obx(
                  () => Column(
                    children: [
                      for (int i = 0; i < controller.platforms.length; i++)
                        _PlatformBlock(
                          index: i,
                          controller: controller,
                          canRemove: controller.platforms.length > 1,
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Add another platform
                GestureDetector(
                  onTap: controller.addPlatform,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: const Color(0xFFD4E0C2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20.sp, color: AppPalette.primary),
                        SizedBox(width: 8.w),
                        Text(
                          'agency_expertise_add_platform'.tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                CustomButton(
                  onTap: controller.onExpertiseContinue,
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

class _PlatformBlock extends StatelessWidget {
  final int index;
  final SignupAgencyController controller;
  final bool canRemove;

  const _PlatformBlock({
    required this.index,
    required this.controller,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    final entry = controller.platforms[index];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'agency_expertise_platform'.tr} ${index + 1}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              if (canRemove)
                GestureDetector(
                  onTap: () => controller.removePlatform(index),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: AppPalette.secondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            return CustomDropDownMenu(
              title: 'agency_expertise_platform_label'.tr,
              hintText: 'agency_expertise_platform_hint'.tr,
              options: controller.platformOptions,
              value: entry.selectedPlatform.value,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
              onChanged: (value) {
                entry.selectedPlatform.value = value;
              },
            );
          }),
          SizedBox(height: 12.h),
          // Niches selector (read-only field that opens dialog)
          GestureDetector(
            onTap: () => controller.openNicheDialog(entry),
            child: AbsorbPointer(
              child: Obx(() {
                // Rebuild when niches change
                entry.workedNiches.length;
                return CustomTextFormField(
                  title: 'agency_expertise_niches_label'.tr,
                  hintText: 'agency_expertise_niches_hint'.tr,
                  controller: entry.nicheSummaryController,
                  contentPadding: EdgeInsets.all(12.w),
                  enabled: false,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: AppPalette.secondary,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
