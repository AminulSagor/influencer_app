// lib/modules/auth/signup_influencer/signup_influencer_kyc_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_brand_controller.dart';

class SignupBrandKycView extends GetView<SignupBrandController> {
  const SignupBrandKycView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.nidFormKey,
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
                    'influ_kyc_title'.tr,
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
                  'influ_kyc_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
                SizedBox(height: 10.h),

                // Body
                Text(
                  'influ_kyc_body'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppPalette.primary.withOpacity(0.85),
                  ),
                ),

                SizedBox(height: 32.h),

                // Info row
                _InfoRow(text: 'influ_kyc_info'.tr),

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
                      'influ_kyc_section_title'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // NID number
                _FieldLabel(text: 'influ_kyc_nid_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.nidNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_kyc_nid_error'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'influ_kyc_nid_hint'.tr,
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

                // Front NID
                _FieldLabel(text: 'influ_kyc_front_label'.tr),
                SizedBox(height: 8.h),
                Obx(
                  () => _UploadTile(
                    onTap: controller.pickNidFront,
                    helperText: 'influ_kyc_upload_helper'.tr,
                    imagePath: controller.nidFrontPath.value,
                  ),
                ),

                SizedBox(height: 24.h),

                // Back NID
                _FieldLabel(text: 'influ_kyc_back_label'.tr),
                SizedBox(height: 8.h),
                Obx(
                  () => _UploadTile(
                    onTap: controller.pickNidBack,
                    helperText: 'influ_kyc_upload_helper'.tr,
                    imagePath: controller.nidBackPath.value,
                  ),
                ),

                SizedBox(height: 32.h),

                // Skip + Submit
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.onKycSkip,
                    child: Text(
                      'influ_kyc_skip'.tr,
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
                  onTap: controller.onKycSubmit,
                  btnText: 'influ_kyc_submit'.tr,
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
        const _ProgressDots(activeIndex: 6, total: 7),
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
  final String? imagePath;

  const _UploadTile({
    required this.onTap,
    required this.helperText,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 140.h),
        padding: imagePath == null
            ? EdgeInsets.symmetric(vertical: 32.h)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            style: BorderStyle.solid,
          ),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(
                  File(imagePath!),
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
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
