import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/brand_campaign_details_controller.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/custom_button.dart';
import 'KV_row.dart';
import 'card_shell.dart';
import 'card_title.dart';

class QuoteDetailsCard extends GetView<BrandCampaignDetailsController> {
  const QuoteDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Expanded(
              //   child: CardTitle(
              //     icon: AppAssets.tergetGoal,
              //     title: 'brand_campaign_details_quote_details'.tr,
              //   ),
              // ),

              Text(
                'brand_campaign_details_quote_details'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),

              Container(
                height: 41,
                width: 41,
                decoration: BoxDecoration(
                  color: AppPalette.thirdColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text("৳", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.sp),),
              ),
            ],
          ),

          12.h.verticalSpace,

          Obx(() {
            return Column(
              children: [
                KVRow(
                  k: 'brand_campaign_details_base_campaign_budget'.tr,
                  v: '৳${controller.baseBudget.value}',
                ),

                6.h.verticalSpace,

                KVRow(
                  k: 'brand_campaign_details_vat_tax'.tr,
                  v: '৳${controller.vatAmount.value}',
                ),

                10.h.verticalSpace,

                Divider(color: AppPalette.border1, height: 1),

                10.h.verticalSpace,

                KVRow(
                  k: 'brand_campaign_details_total_campaign_cost'.tr,
                  v: '৳${controller.totalCost}',
                  strong: true,
                ),
              ],
            );
          }),

          15.h.verticalSpace,

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  btnText: 'brand_campaign_details_requote'.tr,
                  btnColor: AppPalette.white,
                  borderColor: AppPalette.border1,
                  textColor: AppPalette.black,
                  onTap: controller.onRequestQuote,
                ),
              ),

              12.w.horizontalSpace,

              Expanded(
                child: CustomButton(
                  btnText: 'brand_campaign_details_accept_quote'.tr,
                  btnColor: AppPalette.primary,
                  borderColor: Colors.transparent,
                  showBorder: false,
                  textColor: AppPalette.white,
                  onTap: controller.onAcceptQuote,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}