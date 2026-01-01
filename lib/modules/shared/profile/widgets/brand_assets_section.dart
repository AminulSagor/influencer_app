import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../models/brand_asset.dart';
import '../profile_controller.dart';

class BrandAssetsSection extends GetView<ProfileController> {
  const BrandAssetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'brand_assets_title'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
          ),

          14.h.verticalSpace,

          // Website
          CustomTextFormField(
            title: 'brand_assets_website_label'.tr,
            hintText: 'brand_assets_website_hint'.tr,
            controller: controller.brandWebsiteController,
            fillColor: AppPalette.white,
          ),

          14.h.verticalSpace,

          // Social Handles label
          Text(
            'brand_assets_social_handles'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppPalette.primary,
            ),
          ),

          10.h.verticalSpace,

          // Existing handles list
          Obx(() {
            if (controller.brandAssets.isEmpty) return const SizedBox.shrink();

            return Column(
              children: List.generate(controller.brandAssets.length, (index) {
                final item = controller.brandAssets[index];

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.platformKey.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.secondary,
                        ),
                      ),
                      6.h.verticalSpace,
                      CustomTextFormField(
                        hintText: 'brand_assets_link_hint'.tr,
                        controller: item.controller,
                        suffixIcon: IconButton(
                          onPressed: () => controller.removeBrandAsset(index),
                          icon: Icon(Icons.close, size: 18.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          }),

          8.h.verticalSpace,

          // Choose handle dropdown
          Text(
            'brand_assets_choose_handle'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppPalette.secondary,
            ),
          ),
          6.h.verticalSpace,

          Obx(
            () => _BrandPlatformDropdown(
              value: controller.selectedBrandPlatform.value,
              onChanged: (v) => controller.selectedBrandPlatform.value = v,
              items: controller.brandPlatforms,
            ),
          ),

          10.h.verticalSpace,

          // Enter link
          CustomTextFormField(
            hintText: 'brand_assets_enter_link'.tr,
            controller: controller.brandNewLinkController,
          ),

          12.h.verticalSpace,

          // Dotted add button (functional)
          CustomButton.dotted(
            height: 44.h,
            width: double.infinity,
            onTap: controller.addBrandAsset,
            btnText: '+  ${'brand_assets_add_another'.tr}',
            btnColor: AppPalette.white,
            borderColor: AppPalette.secondary,
            textColor: AppPalette.secondary,
            borderRadius: kBorderRadius.r,
            dashPattern: const [4, 3],
          ),

          16.h.verticalSpace,

          // Save button (functional)
          CustomButton(
            width: double.infinity,
            onTap: controller.saveBrandAssets,
            btnText: 'brand_assets_save'.tr,
            btnColor: AppPalette.secondary,
            textColor: AppPalette.white,
          ),
        ],
      ),
    );
  }
}

class _BrandPlatformDropdown extends StatelessWidget {
  final BrandHandlePlatform? value;
  final ValueChanged<BrandHandlePlatform?> onChanged;
  final List<BrandHandlePlatform> items;

  const _BrandPlatformDropdown({
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BrandHandlePlatform>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 24.sp),
          dropdownColor: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          hint: Text(
            'brand_assets_choose_handle_hint'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
              color: AppPalette.subtext,
            ),
          ),
          items: items
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    _labelForPlatform(p).tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
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

  String _labelForPlatform(BrandHandlePlatform p) {
    switch (p) {
      case BrandHandlePlatform.facebook:
        return 'brand_platform_facebook';
      case BrandHandlePlatform.instagram:
        return 'brand_platform_instagram';
      case BrandHandlePlatform.tiktok:
        return 'brand_platform_tiktok';
      case BrandHandlePlatform.youtube:
        return 'brand_platform_youtube';
      case BrandHandlePlatform.linkedin:
        return 'brand_platform_linkedin';
      case BrandHandlePlatform.x:
        return 'brand_platform_x';
      case BrandHandlePlatform.website:
        return 'brand_platform_website';
    }
  }
}
