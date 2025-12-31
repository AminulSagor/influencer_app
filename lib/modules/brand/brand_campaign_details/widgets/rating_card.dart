import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../core/theme/app_palette.dart';
import '../brand_campaign_details_controller.dart';
import 'card_shell.dart';

class RatingCard extends GetView<BrandCampaignDetailsController> {
  const RatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        children: [
          Obx(() {
            final r = controller.rating.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final idx = i + 1;
                final filled = idx <= r;
                return InkWell(
                  onTap: () => controller.setRating(idx),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 24.sp,
                      color: filled ? AppPalette.border1 : AppPalette.border1,
                    ),
                  ),
                );
              }),
            );
          }),

          Container(
            height: 31,
            width:MediaQuery.sizeOf(context).width,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFFB7B7B7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text(
              'brand_campaign_details_provide_rating'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}