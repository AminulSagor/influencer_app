import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';

import '../../create_campaign_controller.dart';

class GreenCampaignDetailsCard extends StatelessWidget {
  final CreateCampaignController controller;
  const GreenCampaignDetailsCard({super.key, required this.controller});

  String _safeTitle(CreateCampaignController c) {
    final t = c.campaignName.value.trim();
    if (t.isNotEmpty) return t;
    return c.campaignNameCtrl.text.trim().isNotEmpty
        ? c.campaignNameCtrl.text.trim()
        : 'create_campaign_step6_campaign_title_fallback'.tr;
  }

  String _deadlineText(CreateCampaignController c) {
    return c.deadlineLabelForStep6;
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    final totalBudget = c.totalBudgetText;
    final vatLabel = '${(c.vatPercent * 100).round()}%';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 23, vertical: 25),
      decoration: BoxDecoration(
        color: AppPalette.primary.withOpacity(.85),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'create_campaign_step6_campaign_details'.tr,
            style: TextStyle(
              color: AppPalette.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          12.h.verticalSpace,

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(AppAssets.onlineAds, height: 30, width: 30),

              10.w.horizontalSpace,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "create_campaign_step6_summer_fashion_campaign".tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppPalette.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    6.h.verticalSpace,

                    Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '৳',
                            style: TextStyle(
                              color: AppPalette.thirdColor,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        6.w.horizontalSpace,

                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              totalBudget,
                              style: TextStyle(
                                color: AppPalette.thirdColor,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          34.h.verticalSpace,

          Divider(color: Colors.white.withOpacity(.35), height: 1),

          13.h.verticalSpace,

          Row(
            children: [
              Text(
                'common_platforms'.tr,
                style: TextStyle(
                  color: AppPalette.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              11.w.horizontalSpace,

              Image.asset(AppAssets.instagram, height: 25, width: 25),

              5.w.horizontalSpace,

              Image.asset(AppAssets.youTube, height: 25, width: 25),

              5.w.horizontalSpace,

              Image.asset(AppAssets.tikTok, height: 25, width: 25),
              // const Spacer(),
              // Text(
              //   'create_campaign_step6_including_vat'.trParams({
              //     'vat': vatLabel,
              //   }),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: TextStyle(
              //     color: const Color(0xFFDCE8CB),
              //     fontSize: 11.5.sp,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
            ],
          ),

          30.h.verticalSpace,

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withOpacity(.22)),
            ),
            child: Column(
              children: [
                Text(
                  'create_campaign_step6_deadline'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                6.h.verticalSpace,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Image.asset(AppAssets.clock, color: AppPalette.white, height: 22, width: 22),
                    Text(
                      _deadlineText(c),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}