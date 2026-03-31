import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../profile_controller.dart';

class VerificationSection extends StatelessWidget {
  final ProfileController controller;

  const VerificationSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isBrand = controller.accountTypeService.isBrand;
    final isInfluencer = controller.accountTypeService.isInfluencer;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBrand)
            Obx(() {
              final isVerified = controller.isClientVerificationComplete;
              final bgColor = isVerified
                  ? const Color(0xFFEAF7EC)
                  : const Color(0xFFFFECEC);
              final textColor = isVerified
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD9363E);
              final message = isVerified
                  ? 'Verified all provided documents'
                  : 'Verification Required. Please Provide Documents.';

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),

          if (isInfluencer) ...[
            CustomTextFormField(
              title: 'influ_kyc_nid_label'.tr,
              hintText: 'influ_kyc_nid_hint'.tr,
              controller: controller.nidNumberController,
              titleTextStyle: AppTheme.textStyle.copyWith(
                color: AppPalette.complemetary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            12.h.verticalSpace,
            Obx(() {
              return _ImagePickerContainer(
                title: 'influ_kyc_front_label'.tr,
                helperText: 'influ_kyc_upload_helper'.tr,
                onTap: () async {
                  controller.nidFrontPic.value = await controller.pickImage();
                },
                image: controller.nidFrontPic.value,
                imageUrl: controller.nidFrontUploadedUrl.value,
              );
            }),
            12.h.verticalSpace,
            Obx(() {
              return _ImagePickerContainer(
                title: 'influ_kyc_back_label'.tr,
                helperText: 'influ_kyc_upload_helper'.tr,
                onTap: () async {
                  controller.nidBackPic.value = await controller.pickImage();
                },
                image: controller.nidBackPic.value,
                imageUrl: controller.nidBackUploadedUrl.value,
              );
            }),
            18.h.verticalSpace,
            Obx(
              () => CustomButton(
                width: double.infinity,
                onTap: controller.isSavingInfluencerNid.value
                    ? null
                    : controller.saveInfluencerNidVerification,
                btnText: 'save'.tr,
                btnColor: AppPalette.secondary,
                textColor: AppPalette.white,
                isLoading: controller.isSavingInfluencerNid.value,
              ),
            ),
          ] else ...[
            CustomTextFormField(
              title: 'Your NID Number',
              controller: controller.nidNumberController,
              titleTextStyle: AppTheme.textStyle.copyWith(
                color: AppPalette.complemetary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            12.h.verticalSpace,
            Obx(() {
              return _ImagePickerContainer(
                title: 'Front Side of NID',
                onTap: () async {
                  controller.nidFrontPic.value = await controller.pickImage();
                },
                image: controller.nidFrontPic.value,
                imageUrl: controller.nidFrontUploadedUrl.value,
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
                imageUrl: controller.nidBackUploadedUrl.value,
              );
            }),
            40.h.verticalSpace,
            CustomTextFormField(
              title: 'Your Trade license Number',
              controller: controller.tradeNumberController,
              titleTextStyle: AppTheme.textStyle.copyWith(
                color: AppPalette.complemetary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            12.h.verticalSpace,
            Obx(() {
              return _ImagePickerContainer(
                title: 'Upload Trade License',
                onTap: () async {
                  controller.tradeLicensePic.value = await controller
                      .pickImage();
                },
                image: controller.tradeLicensePic.value,
                imageUrl: controller.tradeLicenseUploadedUrl.value,
              );
            }),
            40.h.verticalSpace,
            CustomTextFormField(
              title: 'Your TIN Number',
              controller: controller.tinNumberController,
              titleTextStyle: AppTheme.textStyle.copyWith(
                color: AppPalette.complemetary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            12.h.verticalSpace,
            Obx(() {
              return _ImagePickerContainer(
                title: 'Upload TIN Certificate',
                onTap: () async {
                  controller.tinCertificatePic.value = await controller
                      .pickImage();
                },
                image: controller.tinCertificatePic.value,
                imageUrl: controller.tinUploadedUrl.value,
              );
            }),
            40.h.verticalSpace,
            CustomTextFormField(
              title: 'Your BIN Number',
              controller: controller.binNumberController,
              titleTextStyle: AppTheme.textStyle.copyWith(
                color: AppPalette.complemetary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isBrand) ...[
              18.h.verticalSpace,
              Obx(
                () => CustomButton(
                  width: double.infinity,
                  onTap: controller.isSavingVerificationSection.value
                      ? null
                      : controller.saveClientVerificationMethods,
                  btnText: 'Save Update',
                  btnColor: AppPalette.secondary,
                  textColor: AppPalette.white,
                  isLoading: controller.isSavingVerificationSection.value,
                ),
              ),
            ],

            if (controller.accountTypeService.isAdAgency) ...[
              18.h.verticalSpace,
              Obx(
                () => CustomButton(
                  width: double.infinity,
                  onTap: controller.isSavingAgencyVerification.value
                      ? null
                      : controller.saveAgencyVerificationMethods,
                  btnText: 'save'.tr,
                  btnColor: AppPalette.secondary,
                  textColor: AppPalette.white,
                  isLoading: controller.isSavingAgencyVerification.value,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ImagePickerContainer extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final File? image;
  final String? imageUrl;
  final String? helperText;

  const _ImagePickerContainer({
    required this.onTap,
    this.image,
    this.imageUrl,
    required this.title,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  ? ((imageUrl ?? '').trim().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              kBorderRadius.r,
                            ),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => _emptyState(),
                            ),
                          )
                        : _emptyState())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/upward_arrow.png',
          width: 30.w,
          fit: BoxFit.cover,
        ),
        15.h.verticalSpace,
        Text(
          helperText ?? 'PNG, JPEG (Max 2MB)',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppPalette.subtext,
          ),
        ),
      ],
    );
  }
}
