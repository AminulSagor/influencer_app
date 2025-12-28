// lib/modules/auth/signup_influencer/signup_influencer_address_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_agency_controller.dart';

class SignupAgencyAddressView extends GetView<SignupAgencyController> {
  const SignupAgencyAddressView({super.key});

  @override
  Widget build(BuildContext context) {
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
                _TopBar(onBack: controller.goBack),

                SizedBox(height: 32.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'influ_addr_title'.tr,
                    style: TextStyle(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Subtitle line
                Text(
                  'influ_addr_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
                SizedBox(height: 8.h),

                // Subtitle body
                Text(
                  'influ_addr_body'.tr,
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
                        Icons.location_on_outlined,
                        color: AppPalette.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'influ_addr_info'.tr,
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

                // Address heading
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 24.sp,
                      color: AppPalette.primary,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'influ_addr_section_title'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // Thana dropdown
                _FieldLabel(text: 'influ_addr_thana_label'.tr),
                SizedBox(height: 6.h),
                Obx(
                  () => _DropdownField(
                    value: controller.selectedThana.value,
                    items: controller.thanaOptions,
                    hintText: 'influ_addr_thana_hint'.tr,
                    onChanged: (value) =>
                        controller.selectedThana.value = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'influ_addr_select_error'.tr;
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Zilla dropdown
                _FieldLabel(text: 'influ_addr_zilla_label'.tr),
                SizedBox(height: 6.h),
                Obx(
                  () => _DropdownField(
                    value: controller.selectedZilla.value,
                    items: controller.zillaOptions,
                    hintText: 'influ_addr_zilla_hint'.tr,
                    onChanged: (value) =>
                        controller.selectedZilla.value = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'influ_addr_select_error'.tr;
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Full address
                _FieldLabel(text: 'influ_addr_full_label'.tr),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.fullAddressController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'influ_addr_full_error'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'influ_addr_full_hint'.tr,
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

                SizedBox(height: 40.h),

                CustomButton(
                  onTap: controller.onAddressContinue,
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
