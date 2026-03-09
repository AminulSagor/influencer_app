// lib/modules/auth/signup_agency/signup_agency_trade_license_view.dart
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
import 'signup_agency_controller.dart';

class SignupAgencyTradeLicenseView extends GetView<SignupAgencyController> {
  const SignupAgencyTradeLicenseView({super.key});

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
                TopBackAndStep(currentStep: 8, onGoBack: controller.goBack),

                SizedBox(height: 32.h),

                // Header
                SignupPageHeader(
                  title: 'agency_tl_title'.tr,
                  subtitle: 'agency_tl_subtitle'.tr,
                  body: 'agency_tl_body'.tr,
                ),

                SizedBox(height: 32.h),

                // Info row
                SignupInfoRow(
                  text: 'brand_tl_info'.tr,
                  iconAsset: 'assets/icons/security_lock.png',
                ),

                SizedBox(height: 32.h),

                // Section title
                SignupSectionTitle(title: 'brand_tl_section_title'.tr),

                SizedBox(height: 24.h),

                // Trade license number
                CustomTextFormField(
                  title: 'brand_tl_number_label'.tr,
                  hintText: 'brand_tl_number_hint'.tr,
                  controller: controller.tradeLicenseNumberController,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'brand_tl_number_error'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 28.h),

                // Upload tile
                Text(
                  'brand_tl_upload_label'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    color: AppPalette.secondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => FileUploadTile(
                    onTap: controller.pickTradeLicense,
                    helperText: 'brand_tl_upload_helper'.tr,
                    filePath: controller.tradeLicenseFilePath.value,
                    isImage: false,
                  ),
                ),

                SizedBox(height: 32.h),

                // Skip button
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
