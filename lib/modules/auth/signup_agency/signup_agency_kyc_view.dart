// lib/modules/auth/signup_agency/signup_agency_kyc_view.dart
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

class SignupAgencyKycView extends GetView<SignupAgencyController> {
  const SignupAgencyKycView({super.key});

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
                TopBackAndStep(currentStep: 7, onGoBack: controller.goBack),

                SizedBox(height: 32.h),

                // Header
                SignupPageHeader(
                  title: 'agency_kyc_title'.tr,
                  subtitle: 'agency_kyc_subtitle'.tr,
                  body: 'agency_kyc_body'.tr,
                ),

                SizedBox(height: 32.h),

                // Info row
                SignupInfoRow(
                  text: 'influ_kyc_info'.tr,
                  iconAsset: 'assets/icons/security_lock.png',
                ),

                SizedBox(height: 32.h),

                // Section title
                SignupSectionTitle(
                  title: 'influ_kyc_section_title'.tr,
                  iconData: Icons.verified_user_outlined,
                ),

                SizedBox(height: 24.h),

                // NID number
                CustomTextFormField(
                  title: 'influ_kyc_nid_label'.tr,
                  hintText: 'influ_kyc_nid_hint'.tr,
                  controller: controller.nidNumberController,
                  keyboardType: TextInputType.number,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_kyc_nid_error'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 28.h),

                // Front NID
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
                  () => FileUploadTile(
                    onTap: controller.pickNidFront,
                    helperText: 'influ_kyc_upload_helper'.tr,
                    filePath: controller.nidFrontPath.value,
                  ),
                ),

                SizedBox(height: 24.h),

                // Back NID
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
                  () => FileUploadTile(
                    onTap: controller.pickNidBack,
                    helperText: 'influ_kyc_upload_helper'.tr,
                    filePath: controller.nidBackPath.value,
                  ),
                ),

                SizedBox(height: 32.h),

                // Skip button
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
