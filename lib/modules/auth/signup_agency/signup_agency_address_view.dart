// lib/modules/auth/signup_agency/signup_agency_address_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/signup_info_row.dart';
import 'package:influencer_app/core/widgets/signup_page_header.dart';
import 'package:influencer_app/core/widgets/signup_section_title.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_drop_down_menu.dart';
import 'signup_agency_controller.dart';

class SignupAgencyAddressView extends GetView<SignupAgencyController> {
  const SignupAgencyAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onAddressPageOpened();
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBackAndStep(currentStep: 5, onGoBack: controller.goBack),

                SizedBox(height: 32.h),

                // Header
                SignupPageHeader(
                  title: 'agency_addr_title'.tr,
                  subtitle: 'agency_addr_subtitle'.tr,
                  body: 'agency_addr_body'.tr,
                ),

                SizedBox(height: 40.h),

                // Info row
                SignupInfoRow(
                  text: 'influ_addr_info'.tr,
                  iconAsset: 'assets/icons/tracking.png',
                ),

                SizedBox(height: 50.h),

                // Section title
                SignupSectionTitle(
                  title: 'influ_addr_section_title'.tr,
                  iconAsset: 'assets/icons/place_marker.png',
                ),

                SizedBox(height: 28.h),

                // Zilla dropdown
                Obx(() {
                  return CustomDropDownMenu(
                    title: 'influ_addr_zilla_label'.tr,
                    hintText: controller.isLoadingZillas.value
                        ? 'Loading zilla...'
                        : 'influ_addr_zilla_hint'.tr,
                    options: controller.zillaOptions,
                    value: controller.selectedZilla.value,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'influ_addr_select_error'.tr
                        : null,
                    onChanged: controller.onZillaChanged,
                  );
                }),

                SizedBox(height: 20.h),

                // Thana dropdown
                Obx(() {
                  final enabled = controller.selectedZillaId.value != null;

                  return Opacity(
                    opacity: enabled ? 1 : 0.6,
                    child: AbsorbPointer(
                      absorbing: !enabled,
                      child: CustomDropDownMenu(
                        title: 'influ_addr_thana_label'.tr,
                        hintText: !enabled
                            ? 'Select zilla first'
                            : controller.isLoadingThanas.value
                            ? 'Loading thana...'
                            : 'influ_addr_thana_hint'.tr,
                        options: controller.thanaOptions,
                        value: controller.selectedThana.value,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'influ_addr_select_error'.tr
                            : null,
                        onChanged: controller.onThanaChanged,
                      ),
                    ),
                  );
                }),

                SizedBox(height: 20.h),

                // Full address
                CustomTextFormField(
                  title: 'influ_addr_full_label'.tr,
                  hintText: 'influ_addr_full_hint'.tr,
                  controller: controller.fullAddressController,
                  maxLines: 4,
                  contentPadding: EdgeInsets.all(12.w),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_addr_full_error'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 40.h),

                CustomButton(
                  onTap: controller.onAddressContinue,
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
