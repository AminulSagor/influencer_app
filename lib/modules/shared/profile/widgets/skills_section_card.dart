import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

import '../profile_controller.dart';

class SkillsSectionCard extends StatelessWidget {
  final ProfileController controller;

  const SkillsSectionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.skillsExpanded.value;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: controller.toggleSkills,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kBorderRadius.r),
                topRight: Radius.circular(kBorderRadius.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Title + edit
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'skills_title'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.primary,
                          ),
                        ),
                        8.w.horizontalSpace,
                        GestureDetector(
                          onTap: controller.showAddSkillDialog,
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18.sp,
                            color: AppPalette.black.withAlpha(180),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Verified by admin
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Text(
                            'verified_by_admin'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppPalette.secondary,
                            ),
                          ),
                          8.w.horizontalSpace,
                          Icon(
                            Icons.check_circle,
                            size: 18.sp,
                            // if you have a dedicated blue in palette, replace below
                            color: AppPalette.secondary,
                          ),
                        ],
                      ),
                    ),

                    10.w.horizontalSpace,

                    Icon(
                      isExpanded
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
                child: _SkillsBody(controller: controller),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      );
    });
  }
}

class _SkillsBody extends StatelessWidget {
  final ProfileController controller;

  const _SkillsBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...controller.skills.map(
                (skill) => Chip(
                  backgroundColor: AppPalette.thirdColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppPalette.primary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      6.w.horizontalSpace,
                      Icon(
                        Icons.check_circle,
                        size: 12.sp,
                        color: AppPalette.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          12.h.verticalSpace,

          CustomButton.dotted(
            height: 42.h,
            width: double.infinity,
            borderRadius: 99.r,
            onTap: controller.showAddSkillDialog,
            btnText: '+ ${'skills_add_another'.tr}',
            btnColor: AppPalette.white,
            borderColor: AppPalette.secondary,
            textColor: AppPalette.secondary,
            dashPattern: const [4, 3],
          ),
        ],
      );
    });
  }
}
