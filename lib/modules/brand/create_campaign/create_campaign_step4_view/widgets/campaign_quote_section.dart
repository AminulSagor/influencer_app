import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step4_view/widgets/quote_card.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../create_campaign_controller/create_campaign_controller.dart';

class CampaignQuoteSection extends StatelessWidget {
  final CreateCampaignController controller;

  const CampaignQuoteSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create_campaign_step4_quote'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),

        7.h.verticalSpace,

        Obx(() {
          return QuoteCard(
            base: controller.baseBudgetText,
            vat: controller.vatAmountText,
            total: controller.totalBudgetText,
            vatPercent: (controller.vatPercent * 100).round(),
          );
        }),
      ],
    );
  }
}