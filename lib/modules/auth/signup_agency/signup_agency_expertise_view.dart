// lib/modules/auth/signup_agency/signup_agency_expertise_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/constants.dart';
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
                  iconAsset: 'assets/icons/tracking.png',
                ),

                SizedBox(height: 32.h),

                // Section title
                SignupSectionTitle(
                  title: 'agency_expertise_section_title'.tr,
                  iconAsset: 'assets/icons/place_marker.png',
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
                CustomButton.dotted(
                  onTap: controller.addPlatform,
                  btnText: 'agency_expertise_add_platform'.tr,
                  btnColor: AppPalette.white,
                  width: double.infinity,
                  height: 41.h,
                  textStyle: AppTheme.textStyle.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.secondary,
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
        borderRadius: BorderRadius.circular(kBorderRadius.r),
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
          GestureDetector(
            onTap: () async {
              await controller.openNicheDialog(entry);
              // ✅ force rebuild/validation if you want
              Form.of(context).validate();
            },
            child: AbsorbPointer(
              child: CustomTextFormField(
                title: 'Select Niches *',
                hintText: 'Search & Select Niches',
                controller: entry.selectNicheController, // stays empty
                enabled: false,
                contentPadding: EdgeInsets.all(12.w),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: AppPalette.secondary,
                ),
                validator: (_) =>
                    entry.workedNiches.isEmpty ? 'Required' : null,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // ---------------- Worked Niches (chips container) ----------------
          FormField<List<String>>(
            initialValue: entry.workedNiches.toList(growable: false),
            validator: (_) => entry.workedNiches.isEmpty ? 'Required' : null,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Worked Niches *',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() {
                    entry.workedNiches.length;
                    final items = entry.workedNiches.toList(growable: false);

                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(kBorderRadius.r),
                        border: Border.all(
                          color: state.hasError
                              ? Colors.red
                              : const Color(0xFFD1D5DB),
                          width: kBorderWidth0_5,
                        ),
                      ),
                      child: items.isEmpty
                          ? Text(
                              'Select From Above',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey[500],
                              ),
                            )
                          : Wrap(
                              spacing: 10.w,
                              runSpacing: 10.h,
                              children: items.map((niche) {
                                return _SelectedNicheChip(
                                  label: niche,
                                  onRemove: () {
                                    controller.removeWorkedNiche(entry, niche);
                                    state.didChange(
                                      entry.workedNiches.toList(),
                                    );
                                    state.validate();
                                  },
                                );
                              }).toList(),
                            ),
                    );
                  }),

                  if (state.hasError) ...[
                    SizedBox(height: 6.h),
                    Text(
                      state.errorText ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelectedNicheChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SelectedNicheChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8D9),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.primary,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14.sp, color: AppPalette.primary),
          ),
        ],
      ),
    );
  }
}
