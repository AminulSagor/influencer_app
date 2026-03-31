import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../profile_controller.dart';

class ProfileSettingsSection extends StatelessWidget {
  final ProfileController controller;

  const ProfileSettingsSection({super.key, required this.controller});

  bool _isZillaField(String label) {
    final lower = label.trim().toLowerCase();
    return lower == 'zilla';
  }

  bool _isThanaField(String label) {
    final lower = label.trim().toLowerCase();
    return lower == 'thana';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAgency = controller.accountTypeService.isAdAgency;
      final isClient = controller.accountTypeService.isBrand;

      return Column(
        children: [
          Row(
            children: [
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  dashPattern: [5, 5],
                  radius: Radius.circular(999.r),
                  color: AppPalette.defaultStroke,
                  strokeWidth: 1,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    width: 74.w,
                    height: 74.w,
                    color: AppPalette.defaultFill,
                    child: Obx(() {
                      final imageFile = controller.profileImageFile.value;
                      final imageUrl = controller.profileImageUrl.value;

                      if (imageFile != null) {
                        return Image.file(imageFile, fit: BoxFit.cover);
                      }

                      if (imageUrl.isNotEmpty) {
                        return Image.network(imageUrl, fit: BoxFit.cover);
                      }

                      return const SizedBox.shrink();
                    }),
                  ),
                ),
              ),
              20.w.horizontalSpace,
              Expanded(
                child: Column(
                  children: [
                    CustomButton(
                      onTap: controller.changeProfilePhoto,
                      btnText: 'Change Photo',
                      width: double.infinity,
                      textColor: AppPalette.white,
                    ),
                    10.h.verticalSpace,
                    CustomButton(
                      onTap: controller.removeProfilePhoto,
                      btnText: 'Remove',
                      width: double.infinity,
                      btnColor: AppPalette.defaultFill,
                      borderColor: AppPalette.defaultStroke,
                    ),
                  ],
                ),
              ),
            ],
          ),
          33.h.verticalSpace,

          ...controller.profileFields.expand((field) {
            if ((isAgency || isClient) && _isZillaField(field.label)) {
              return [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Obx(
                    () => CustomDropDownMenu(
                      title: field.label + (field.isRequired ? ' *' : ''),
                      hintText: isAgency
                          ? (controller.isLoadingAgencyZillas.value
                                ? 'Loading zilla...'
                                : 'Select zilla')
                          : (controller.isLoadingLocationZillas.value
                                ? 'Loading zilla...'
                                : 'Select zilla'),
                      options: isAgency
                          ? controller.agencyZillaList
                          : controller.zillaList,
                      value: isAgency
                          ? controller.selectedAgencyZilla.value
                          : controller.selectedLocationZilla.value,
                      onChanged: isAgency
                          ? controller.setAgencyZilla
                          : controller.setLocationZilla,
                    ),
                  ),
                ),
              ];
            }

            if ((isAgency || isClient) && _isThanaField(field.label)) {
              return [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Obx(() {
                    final enabled = isAgency
                        ? controller.selectedAgencyZillaId.value != null
                        : controller.selectedLocationZillaId.value != null;

                    return Opacity(
                      opacity: enabled ? 1 : 0.6,
                      child: AbsorbPointer(
                        absorbing: !enabled,
                        child: CustomDropDownMenu(
                          title: field.label + (field.isRequired ? ' *' : ''),
                          hintText: !enabled
                              ? 'Select zilla first'
                              : isAgency
                              ? (controller.isLoadingAgencyThanas.value
                                    ? 'Loading thana...'
                                    : 'Select thana')
                              : (controller.isLoadingLocationThanas.value
                                    ? 'Loading thana...'
                                    : 'Select thana'),
                          options: isAgency
                              ? controller.agencyThanaList
                              : controller.thanaList,
                          value: isAgency
                              ? controller.selectedAgencyThana.value
                              : controller.selectedLocationThana.value,
                          onChanged: isAgency
                              ? controller.setAgencyThana
                              : controller.setLocationThana,
                        ),
                      ),
                    );
                  }),
                ),
              ];
            }

            return [
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      title: field.label + (field.isRequired ? ' *' : ''),
                      hintText: field.hintText,
                      initialValue: controller.profileFieldValue(
                        field.label,
                        field.value,
                      ),
                      enabled: !field.isReadOnly,
                      onChanged: (value) =>
                          controller.setProfileFieldValue(field.label, value),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12.sp,
                        color: AppPalette.black,
                      ),
                      maxLines: field.label.contains('Full Address') ? 5 : 1,
                    ),
                  ],
                ),
              ),
            ];
          }),

          if (controller.accountTypeService.isBrand) ...[
            8.h.verticalSpace,
            CustomButton(
              onTap: controller.isSavingProfileSettings.value
                  ? null
                  : controller.saveClientProfileSettings,
              btnText: 'Update Profile',
              width: double.infinity,
              btnColor: AppPalette.secondary,
              textColor: AppPalette.white,
              isLoading: controller.isSavingProfileSettings.value,
            ),
          ],

          if (controller.accountTypeService.isInfluencer) ...[
            8.h.verticalSpace,
            Obx(
              () => CustomButton(
                onTap: controller.isSavingInfluencerSettings.value
                    ? null
                    : controller.saveInfluencerProfileSettings,
                btnText: 'save'.tr,
                width: double.infinity,
                textColor: AppPalette.white,
                isLoading: controller.isSavingInfluencerSettings.value,
              ),
            ),
          ],

          if (controller.accountTypeService.isAdAgency) ...[
            8.h.verticalSpace,
            Obx(
              () => CustomButton(
                onTap: controller.isSavingAgencySettings.value
                    ? null
                    : controller.saveAgencyProfileSettings,
                btnText: 'save'.tr,
                width: double.infinity,
                textColor: AppPalette.white,
                isLoading: controller.isSavingAgencySettings.value,
              ),
            ),
          ],
        ],
      );
    });
  }
}
