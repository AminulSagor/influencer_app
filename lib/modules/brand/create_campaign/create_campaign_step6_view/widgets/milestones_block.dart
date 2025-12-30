import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

import '../../create_campaign_controller/create_campaign_controller.dart';
import 'milestone_tile.dart';

class MilestonesBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const MilestonesBlock({super.key, required this.controller});

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final ms = c.milestones.toList(growable: false);

      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF3),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _softBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'create_campaign_step6_total_budget'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            '৳',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.primary,
                            ),
                          ),

                          6.w.horizontalSpace,

                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                c.totalBudgetText,
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'create_campaign_step6_budget_including_vat'.trParams({
                          'vat': '${(c.vatPercent * 100).round()}%',
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),

                10.w.horizontalSpace,

                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.secondary),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '৳',
                    style: TextStyle(
                      color: _primary.withOpacity(.8),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          12.h.verticalSpace,

          if (ms.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '-',
                style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
              ),
            )
          else
            ...ms.map(
                  (m) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: MilestoneTile(m: m),
              ),
            ),
        ],
      );
    });
  }
}