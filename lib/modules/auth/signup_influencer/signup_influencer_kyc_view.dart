// lib/modules/auth/signup_influencer/signup_influencer_kyc_view.dart
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_influencer_controller.dart';

class SignupInfluencerKycView extends GetView<SignupInfluencerController> {
  const SignupInfluencerKycView({super.key});

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
                TopBackAndStep(currentStep: 7),

                SizedBox(height: 32.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'influ_kyc_title'.tr,
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
                  'influ_kyc_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.secondary,
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
                Text(
                  'influ_kyc_section_title'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),

                SizedBox(height: 24.h),

                // NID number
                CustomTextFormField(
                  title: 'influ_kyc_nid_label'.tr,
                  hintText: 'influ_kyc_nid_hint'.tr,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_kyc_nid_error'.tr;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  controller: controller.nidNumberController,
                ),

                SizedBox(height: 28.h),

                // Front NID
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'influ_kyc_front_label'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppPalette.secondary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Obx(
                      () => _UploadTile(
                        onTap: controller.pickNidFront,
                        helperText: 'influ_kyc_upload_helper'.tr,
                        imagePath: controller.nidFrontPath.value,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Back NID
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'influ_kyc_back_label'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppPalette.secondary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Obx(
                      () => _UploadTile(
                        onTap: controller.pickNidBack,
                        helperText: 'influ_kyc_upload_helper'.tr,
                        imagePath: controller.nidBackPath.value,
                      ),
                    ),
                  ],
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
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.secondary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                CustomButton(
                  onTap: controller.onKycSubmit,
                  btnText: 'influ_kyc_submit'.tr,
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

class _InfoRow extends StatelessWidget {
  final String text;

  const _InfoRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/icons/security_lock.png', width: 35.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: AppPalette.primary),
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
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: [5, 5],
          strokeWidth: 1,
          padding: EdgeInsets.zero,
          radius: Radius.circular(kBorderRadius.r),
          color: AppPalette.secondary,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 140.h),
          padding: imagePath == null
              ? EdgeInsets.symmetric(vertical: 32.h)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppPalette.defaultFill,
            borderRadius: BorderRadius.circular(kBorderRadius.r),
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
      ),
    );
  }
}
