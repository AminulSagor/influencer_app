import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_brand_controller.dart';

class SignupBrandView extends GetView<SignupBrandController> {
  const SignupBrandView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.formKey,
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
                    'brand_step1_title'.tr,
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
                  'brand_step1_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),

                SizedBox(height: 32.h),

                // Section title
                Text(
                  'brand_step1_section_title'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primary,
                  ),
                ),

                SizedBox(height: 20.h),

                // Brand name
                _FieldLabel(text: 'brand_step1_brand_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.brandNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_step1_brand_error'.tr;
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'brand_step1_brand_hint'.tr,
                  ),
                ),

                SizedBox(height: 18.h),

                // First name
                _FieldLabel(text: 'brand_step1_first_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.firstNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_step1_first_error'.tr;
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'brand_step1_first_hint'.tr,
                  ),
                ),

                SizedBox(height: 18.h),

                // Last name
                _FieldLabel(text: 'brand_step1_last_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.lastNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_step1_last_error'.tr;
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'brand_step1_last_hint'.tr,
                  ),
                ),

                SizedBox(height: 18.h),

                // Email
                _FieldLabel(text: 'brand_step1_email_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_step1_email_error'.tr;
                    }
                    if (!GetUtils.isEmail(value.trim())) {
                      return 'brand_step1_email_invalid'.tr;
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'brand_step1_email_hint'.tr,
                  ),
                ),

                SizedBox(height: 18.h),

                // Phone
                _FieldLabel(text: 'brand_step1_phone_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_step1_phone_error'.tr;
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'brand_step1_phone_hint'.tr,
                  ),
                ),

                SizedBox(height: 24.h),

                // Language toggle
                Obx(
                  () => _LanguageToggle(
                    isEnglish: controller.isEnglish.value,
                    onEnglishTap: () => controller.setLanguage('en'),
                    onBanglaTap: () => controller.setLanguage('bn'),
                  ),
                ),

                SizedBox(height: 28.h),

                // Continue button
                CustomButton(
                  onTap: controller.onContinue,
                  btnText: 'btn_continue'.tr,
                  height: 56.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.white,
                  ),
                ),

                SizedBox(height: 20.h),

                // Login footer
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'brand_step1_footer_title'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: controller.goToLogin,
                        child: Text(
                          'brand_step1_footer_login'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------

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
        const _ProgressDots(activeIndex: 0, total: 8),
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

class _LanguageToggle extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onEnglishTap;
  final VoidCallback onBanglaTap;

  const _LanguageToggle({
    required this.isEnglish,
    required this.onEnglishTap,
    required this.onBanglaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppPalette.primary),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onEnglishTap,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isEnglish ? AppPalette.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'brand_step1_lang_en'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isEnglish ? Colors.white : AppPalette.primary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onBanglaTap,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isEnglish ? AppPalette.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'brand_step1_lang_bn'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: !isEnglish ? Colors.white : AppPalette.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
