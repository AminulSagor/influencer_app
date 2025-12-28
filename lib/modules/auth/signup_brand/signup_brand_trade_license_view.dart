// lib/modules/auth/signup_brand/signup_brand_trade_license_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_brand_controller.dart';

class SignupBrandTradeLicenseView extends GetView<SignupBrandController> {
  const SignupBrandTradeLicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.tradeLicenseFormKey,
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
                    'brand_tl_title'.tr, // "Make it Official!"
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
                  'brand_tl_subtitle'.tr, // "Become a Certified Partner"
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
                SizedBox(height: 10.h),

                // Body text
                Text(
                  'brand_tl_body'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppPalette.primary.withOpacity(0.85),
                  ),
                ),

                SizedBox(height: 32.h),

                // Info row
                _InfoRow(text: 'brand_tl_info'.tr),

                SizedBox(height: 32.h),

                // Section title
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 24.sp,
                      color: AppPalette.primary,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'brand_tl_section_title'
                          .tr, // "Provide Your Trade License"
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Trade license number
                _FieldLabel(text: 'brand_tl_number_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.tradeLicenseNumberController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_tl_number_error'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'brand_tl_number_hint'.tr,
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // Upload tile
                _FieldLabel(text: 'brand_tl_upload_label'.tr),
                SizedBox(height: 8.h),
                Obx(
                  () => _UploadTile(
                    helperText: 'brand_tl_upload_helper'.tr,
                    filePath: controller.tradeLicenseFilePath.value,
                    onTap: controller.pickTradeLicense,
                  ),
                ),

                SizedBox(height: 32.h),

                // Skip + Continue
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.onTradeLicenseSkip,
                    child: Text(
                      'brand_tl_skip'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                CustomButton(
                  onTap: controller.onTradeLicenseContinue,
                  btnText: 'brand_tl_continue'.tr,
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
        const _ProgressDots(activeIndex: 7, total: 9),
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

class _InfoRow extends StatelessWidget {
  final String text;

  const _InfoRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            Icons.security_outlined,
            color: AppPalette.primary,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
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

class _UploadTile extends StatelessWidget {
  final VoidCallback onTap;
  final String helperText;
  final String? filePath;

  const _UploadTile({
    required this.onTap,
    required this.helperText,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = filePath != null && filePath!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: double.infinity,
        height: 170.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            style: BorderStyle.solid,
          ),
        ),
        child: hasFile
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Image.file(
                  File(filePath!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 32.sp,
                    color: AppPalette.primary,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    helperText,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppPalette.primary.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
