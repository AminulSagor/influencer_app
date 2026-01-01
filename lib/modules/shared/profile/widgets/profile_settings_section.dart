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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
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
                  ),
                ),
              ),
              20.w.horizontalSpace,
              Expanded(
                child: Column(
                  children: [
                    CustomButton(
                      onTap: () {},
                      btnText: 'Change Photo',
                      width: double.infinity,
                      textColor: AppPalette.white,
                    ),
                    10.h.verticalSpace,
                    CustomButton(
                      onTap: () {},
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
          if (!controller.accountTypeService.isInfluencer)
            ...controller.profileFields.map((field) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomTextFormField(
                      title: field.label + (field.isRequired ? ' *' : ''),
                      hintText: field.hintText,
                      initialValue: field.value,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12.sp,
                        color: AppPalette.black,
                      ),
                      maxLines: field.label.contains('Full Address') ? 5 : 1,
                    ),
                    if (field.label.contains('Last')) ...[
                      12.h.verticalSpace,

                      /// ----- Thana -----
                      Obx(
                        () => CustomDropDownMenu(
                          title: "Thana *",
                          hintText: "Select Thana",
                          options: controller.thanaList,
                          value: controller.selectedThana.value,
                          onChanged: controller.setThana,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// ----- Zilla -----
                      Obx(
                        () => CustomDropDownMenu(
                          title: "Zilla *",
                          hintText: "Select Zilla",
                          options: controller.zillaList,
                          value: controller.selectedZilla.value,
                          onChanged: controller.setZilla,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
