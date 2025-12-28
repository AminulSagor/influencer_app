import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
                _TopBar(onBack: controller.goBack),

                SizedBox(height: 32.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'influ_social_title'.tr, // "Time to shine!"
                    style: TextStyle(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Subtitle
                Text(
                  'influ_social_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  'influ_social_body'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppPalette.primary.withOpacity(0.85),
                  ),
                ),

                SizedBox(height: 32.h),

                // Info row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F3D9),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.pan_tool_alt_outlined,
                        color: AppPalette.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'influ_social_info'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.5,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // Section title
                Row(
                  children: [
                    Icon(
                      Icons.video_collection_outlined,
                      size: 24.sp,
                      color: AppPalette.primary,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'influ_social_section_title'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // Website (optional)
                _FieldLabel(text: 'influ_social_website_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.websiteController,
                  decoration: _inputDecoration(
                    hintText: 'influ_social_website_hint'.tr,
                  ),
                  keyboardType: TextInputType.url,
                ),

                SizedBox(height: 20.h),

                // Platform dropdown
                _FieldLabel(text: 'influ_social_platform_label'.tr),
                SizedBox(height: 6.h),
                Obx(
                  () => PrimaryDropdown<String>(
                    value: controller.selectedPlatform.value,
                    items: controller.platformOptions,
                    hintText: 'influ_social_platform_hint'.tr,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'influ_social_platform_error'.tr;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      controller.selectedPlatform.value = value;
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Profile link
                _FieldLabel(text: 'influ_social_profile_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.profileLinkController,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_social_profile_error'.tr;
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'influ_social_profile_hint'.tr,
                  ),
                ),

                SizedBox(height: 24.h),

                // Add another
                GestureDetector(
                  onTap: controller.addAnotherLink,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: AppPalette.primary.withOpacity(0.4),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'influ_social_add_another'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                CustomButton(
                  onTap: controller.onSocialContinue,
                  btnText: 'btn_continue'.tr,
                  height: 56.h,
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

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
