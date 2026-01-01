import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../profile_controller.dart';

class VerificationSection extends StatelessWidget {
  final ProfileController controller;

  const VerificationSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomTextFormField(
            title: 'Your NID Number',
            controller: controller.nidNumberController,
          ),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Front Side of NID',
              onTap: () async {
                controller.nidFrontPic.value = await controller.pickImage();
              },
              image: controller.nidFrontPic.value,
            );
          }),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Back Side of NID',
              onTap: () async {
                controller.nidBackPic.value = await controller.pickImage();
              },
              image: controller.nidBackPic.value,
            );
          }),
          40.h.verticalSpace,
          CustomTextFormField(
            title: 'Your Trade license Number',
            controller: controller.tradeNumberController,
          ),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Upload Trade License',
              onTap: () async {
                controller.tradeLicensePic.value = await controller.pickImage();
              },
              image: controller.tradeLicensePic.value,
            );
          }),
          40.h.verticalSpace,
          CustomTextFormField(
            title: 'Your TIN Number',
            controller: controller.nidNumberController,
          ),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Upload TIN Certificate',
              onTap: () async {
                controller.nidBackPic.value = await controller.pickImage();
              },
              image: controller.nidBackPic.value,
            );
          }),
          40.h.verticalSpace,
          CustomTextFormField(
            title: 'Your BIN Number',
            controller: controller.nidNumberController,
          ),
        ],
      ),
    );
  }
}

class _ImagePickerContainer extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final File? image;

  const _ImagePickerContainer({
    required this.onTap,
    this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            color: AppPalette.complemetary,
          ),
        ),
        10.h.verticalSpace,
        InkWell(
          radius: kBorderRadius.r,
          onTap: onTap,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: [5, 5],
              color: AppPalette.border1,
              radius: Radius.circular(kBorderRadius.r),
            ),
            child: Container(
              height: 114.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadius.r),
              ),
              child: image == null
                  ? Column(
                      mainAxisSize: .min,
                      mainAxisAlignment: .center,
                      children: [
                        Image.asset(
                          'assets/icons/upward_arrow.png',
                          width: 30.w,
                          fit: BoxFit.cover,
                        ),
                        15.h.verticalSpace,
                        Text(
                          'PNG, JPEG (Max 2MB)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppPalette.subtext,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      child: Image.file(image!, fit: BoxFit.cover),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
