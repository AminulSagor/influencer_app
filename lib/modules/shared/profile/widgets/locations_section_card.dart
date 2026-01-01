import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../models/user_location.dart';
import '../profile_controller.dart';

class LocationsSectionCard extends StatelessWidget {
  final ProfileController controller;

  const LocationsSectionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: controller.toggleLocations,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kBorderRadius.r),
                topRight: Radius.circular(kBorderRadius.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                child: Row(
                  children: [
                    Text(
                      'locations_title'.tr, // "Your Locations" / "আপনার ঠিকানা"
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                    8.w.horizontalSpace,
                    Image.asset(
                      'assets/icons/edit.png',
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.cover,
                      color: AppPalette.primary,
                    ),
                    const Spacer(),
                    Icon(
                      controller.locationsExpanded.value
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 28.sp,
                      color: AppPalette.black,
                    ),
                  ],
                ),
              ),
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: Column(
                  children: [
                    // Existing locations list
                    if (controller.locations.isNotEmpty) ...[
                      ...List.generate(controller.locations.length, (i) {
                        final loc = controller.locations[i];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _LocationTile(
                            location: loc,
                            onEdit: () => controller.startEditLocation(i),
                          ),
                        );
                      }),
                    ],

                    // Add/Edit form
                    if (controller.showNewLocationForm.value) ...[
                      _AddLocationForm(controller: controller),
                      12.h.verticalSpace,
                    ],

                    // Dotted button (show when form is hidden)
                    if (!controller.showNewLocationForm.value)
                      CustomButton.dotted(
                        height: 46.h,
                        width: double.infinity,
                        onTap: controller.startAddLocation,
                        btnText: '+  ${'locations_add_another'.tr}',
                        btnColor: AppPalette.white,
                        borderColor: AppPalette.secondary,
                        textColor: AppPalette.secondary,
                        borderRadius: 10.r,
                        dashPattern: const [4, 3],
                      ),
                  ],
                ),
              ),
              crossFadeState: controller.locationsExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final UserLocation location;
  final VoidCallback onEdit;

  const _LocationTile({required this.location, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.thirdColor.withAlpha(60),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.secondary, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppPalette.secondary,
            size: 22.sp,
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primary,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  location.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.subtext,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          InkWell(
            onTap: onEdit,
            child: Icon(Icons.edit, size: 18.sp, color: AppPalette.secondary),
          ),
        ],
      ),
    );
  }
}

class _AddLocationForm extends StatelessWidget {
  final ProfileController controller;

  const _AddLocationForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border1, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'locations_add_new_title'
                    .tr, // "Add New Address" / "নতুন ঠিকানা যোগ করুন"
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.primary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: controller.cancelLocationForm,
                child: Icon(
                  Icons.close,
                  size: 22.sp,
                  color: AppPalette.secondary,
                ),
              ),
            ],
          ),

          12.h.verticalSpace,

          Text(
            'locations_give_name'.tr, // "Give A Name" / "একটি নাম দিন"
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
          8.h.verticalSpace,
          CustomTextFormField(
            hintText: 'locations_give_name_hint'.tr,
            controller: controller.locationNameController,
          ),

          12.h.verticalSpace,

          Text(
            'locations_thana'.tr, // "Thana *" / "থানা *"
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
          8.h.verticalSpace,
          Obx(
            () => _LocationDropDown(
              hintText: 'locations_select_thana'.tr,
              value: controller.selectedLocationThana.value,
              options: controller.thanaList,
              onChanged: controller.setLocationThana,
            ),
          ),

          12.h.verticalSpace,

          Text(
            'locations_zilla'.tr, // "Zilla *" / "জেলা *"
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
          8.h.verticalSpace,
          Obx(
            () => _LocationDropDown(
              hintText: 'locations_select_zilla'.tr,
              value: controller.selectedLocationZilla.value,
              options: controller.zillaList,
              onChanged: controller.setLocationZilla,
            ),
          ),

          12.h.verticalSpace,

          Text(
            'locations_full_address'.tr, // "Full Address *" / "পূর্ণ ঠিকানা *"
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
          8.h.verticalSpace,
          CustomTextFormField(
            hintText: 'locations_full_address_hint'.tr,
            controller: controller.locationFullAddressController,
            maxLines: 4,
          ),

          16.h.verticalSpace,

          CustomButton.dotted(
            height: 46.h,
            width: double.infinity,
            onTap: controller.saveLocationForm,
            btnText: controller.editingLocationIndex.value == null
                ? '+  ${'locations_add_another'.tr}'
                : 'locations_save_btn'.tr, // "Save Address" / "সেভ করুন"
            btnColor: AppPalette.white,
            borderColor: AppPalette.secondary,
            textColor: AppPalette.secondary,
            borderRadius: 10.r,
            dashPattern: const [4, 3],
          ),
        ],
      ),
    );
  }
}

class _LocationDropDown extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<String> options;
  final ValueChanged<String?>? onChanged;

  const _LocationDropDown({
    required this.hintText,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppPalette.border1, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hintText,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12.sp,
              color: AppPalette.subtext,
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 24.sp),
          dropdownColor: AppPalette.white,
          borderRadius: BorderRadius.circular(10.r),
          items: options
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: AppPalette.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
