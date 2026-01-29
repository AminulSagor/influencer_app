// lib/modules/auth/signup_brand/signup_brand_tin_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/file_upload_tile.dart';
import 'package:influencer_app/core/widgets/signup_info_row.dart';
import 'package:influencer_app/core/widgets/signup_page_header.dart';
import 'package:influencer_app/core/widgets/signup_section_title.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_brand_controller.dart';

class SignupBrandTinView extends GetView<SignupBrandController> {
  const SignupBrandTinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.tinFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBackAndStep(currentStep: 9, onGoBack: controller.goBack),

                SizedBox(height: 32.h),

                // Header
                SignupPageHeader(
                  title: 'brand_tin_title'.tr,
                  subtitle: 'brand_tin_subtitle'.tr,
                  body: 'brand_tin_body'.tr,
                ),

                SizedBox(height: 32.h),

                // Info row
                SignupInfoRow(
                  text: 'brand_tin_info'.tr,
                  iconData: Icons.verified_outlined,
                ),

                SizedBox(height: 32.h),

                // Section title
                SignupSectionTitle(
                  title: 'brand_tin_section_title'.tr,
                  iconData: Icons.verified_user_outlined,
                ),

                SizedBox(height: 24.h),

                // TIN number
                CustomTextFormField(
                  title: 'brand_tin_tin_label'.tr,
                  hintText: 'brand_tin_tin_hint'.tr,
                  controller: controller.tinNumberController,
                  keyboardType: TextInputType.number,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_tin_tin_error'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Upload TIN certificate
                Text(
                  'brand_tin_upload_label'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    color: AppPalette.secondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => FileUploadTile(
                    onTap: controller.pickTinCertificate,
                    helperText: 'brand_tin_upload_helper'.tr,
                    filePath: controller.tinCertificatePath.value,
                    isImage: false,
                  ),
                ),

                SizedBox(height: 24.h),

                // BIN number (optional)
                CustomTextFormField(
                  title: 'brand_tin_bin_label'.tr,
                  hintText: 'brand_tin_bin_hint'.tr,
                  controller: controller.binNumberController,
                  keyboardType: TextInputType.number,
                  contentPadding: EdgeInsets.all(12.w),
                ),

                SizedBox(height: 32.h),

                // Skip button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.onTinSkip,
                    child: Text(
                      'brand_tin_skip'.tr,
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
                  onTap: controller.onTinContinue,
                  btnText: 'btn_finish'.tr,
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
