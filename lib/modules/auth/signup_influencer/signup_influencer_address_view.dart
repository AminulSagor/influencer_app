// lib/modules/auth/signup_influencer/signup_influencer_address_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_drop_down_menu.dart';
import 'signup_influencer_controller.dart';

class SignupInfluencerAddressView extends GetView<SignupInfluencerController> {
  const SignupInfluencerAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isBrand = accountTypeService.isBrand;
    final isInfluencer = accountTypeService.isInfluencer;

    final title = isInfluencer
        ? 'influ_addr_title'.tr
        : isBrand
        ? 'brand_addr_title'.tr
        : 'agency_addr_title'.tr;
    final subTitle = isInfluencer
        ? 'influ_addr_subtitle'.tr
        : isBrand
        ? 'brand_addr_subtitle'.tr
        : 'agency_addr_subtitle'.tr;
    final body = isInfluencer
        ? 'influ_addr_body'.tr
        : isBrand
        ? 'brand_addr_body'.tr
        : 'agency_addr_body'.tr;

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
                TopBackAndStep(currentStep: 5),

                SizedBox(height: 32.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title.tr,
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Subtitle line
                FittedBox(
                  fit: .scaleDown,
                  child: Text(
                    subTitle.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Subtitle body
                Text(
                  body.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: .w300,
                    color: AppPalette.primary,
                  ),
                ),

                SizedBox(height: 40.h),

                // Info row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/icons/tracking.png', width: 34.w),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'influ_addr_info'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50.h),

                // Address heading
                Row(
                  children: [
                    Image.asset('assets/icons/place_marker.png', width: 34.w),
                    SizedBox(width: 10.w),
                    Text(
                      'influ_addr_section_title'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // Thana dropdown
                Obx(() {
                  return CustomDropDownMenu(
                    title: 'influ_addr_thana_label'.tr,
                    hintText: 'influ_addr_thana_hint'.tr,
                    options: controller.thanaOptions,
                    value: controller.selectedThana.value,
                    onChanged: (value) =>
                        controller.selectedThana.value = value,
                  );
                }),

                SizedBox(height: 20.h),

                // Zilla dropdown
                Obx(() {
                  return CustomDropDownMenu(
                    title: 'influ_addr_zilla_label'.tr,
                    hintText: 'influ_addr_zilla_hint'.tr,
                    options: controller.zillaOptions,
                    value: controller.selectedZilla.value,
                    onChanged: (value) =>
                        controller.selectedZilla.value = value,
                  );
                }),

                SizedBox(height: 20.h),

                // Full address
                CustomTextFormField(
                  title: 'influ_addr_full_label'.tr,
                  controller: controller.fullAddressController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_addr_full_error'.tr;
                    }
                    return null;
                  },
                  hintText: 'influ_addr_full_hint'.tr,
                  maxLines: 5,
                ),

                SizedBox(height: 60.h),

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
        const _ProgressDots(activeIndex: 3, total: 7),
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

class _DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.hintText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppPalette.primary),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
