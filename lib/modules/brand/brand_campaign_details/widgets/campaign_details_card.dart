import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/brand_campaign_details_controller.dart';

import 'chip_title.dart';

class CampaignDetailsCard extends GetView<BrandCampaignDetailsController> {
  const CampaignDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final green = AppPalette.primary;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppPalette.secondary,
            AppPalette.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'brand_campaign_details_campaign_details'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppPalette.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          10.h.verticalSpace,

          // Campaign name + amount
          Row(
            crossAxisAlignment: .start,
            spacing: 16,
            children: [

              Image.asset(AppAssets.onlineAds, width: 30, height: 30),

              Column(
                crossAxisAlignment: .start,
                children: [
                  Obx(() {
                    return Text(
                      controller.campaignTitle.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  }),

                  Obx(() {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        controller.budgetText.value,
                        style: TextStyle(
                          color: AppPalette.thirdColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              )
            ],
          ),

          10.h.verticalSpace,

          // ✅ PaidAd: Targeting row | other: Influencers row
          Obx(() {
            controller.campaignType.value;
            final isPaidAd = controller.isPaidAd;
            if (isPaidAd) {
              return Row(
                children: [
                  Text(
                    'brand_campaign_details_targeting'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  10.w.horizontalSpace,
                  ChipTitle(
                    text: controller.targetingText.value.trim().isEmpty
                        ? 'Crowd'
                        : controller.targetingText.value,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Text(
                  'brand_campaign_details_influencers'.tr,
                  style: TextStyle(
                    color: AppPalette.thirdColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                10.w.horizontalSpace,

                Expanded(
                  child: Obx(() {
                    final list = controller.influencers.toList(growable: false);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: list.map((name) => ChipTitle(text: name)).toList(),
                      ),
                    );
                  }),
                ),
              ],
            );
          }),

          10.h.verticalSpace,

          Divider(color: AppPalette.white, height: 1),

          10.h.verticalSpace,

          // Platforms
          Row(
            children: [
              Text(
                'brand_campaign_details_platforms'.tr,
                style: TextStyle(
                  color: AppPalette.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              10.w.horizontalSpace,

              // Image.asset(icon, height: 25, width: 25),

              Obx(() {
                return Row(
                  children: controller.platforms
                      .map((ic) =>
                        Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Image.asset(ic, height: 25, width: 25, color: AppPalette.white),
                        ),
                  ).toList(),
                );
              }),
            ],
          ),

          12.h.verticalSpace,

          Obx(() {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppPalette.secondary,
                    AppPalette.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withOpacity(.25)),
              ),
              child: Column(
                children: [
                  Text(
                    'brand_campaign_details_deadline'.tr,
                    style: TextStyle(
                      color: AppPalette.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  6.h.verticalSpace,

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${controller.daysRemaining.value} ${'brand_campaign_details_days_remaining'.tr}',
                      style: TextStyle(
                        color: AppPalette.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  4.h.verticalSpace,

                  Text(
                    controller.deadlineDateText.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),

          10.h.verticalSpace,

          Align(
            alignment: Alignment.center,
            child: Obx(() {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppPalette.thirdColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.white.withOpacity(.22)),
                ),
                child: Text(
                  controller.budgetStatusText.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppPalette.secondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
