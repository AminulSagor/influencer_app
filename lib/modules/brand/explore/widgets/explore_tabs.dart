import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';
import '../../../../../core/theme/app_palette.dart';
import '../explore_controller.dart';
import '../models/explore_item.dart';

class ExploreTabs extends GetView<ExploreController> {
  const ExploreTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final type = controller.selectedType.value;

      Widget tab({required ExploreType t, required String labelKey}) {
        final active = type == t;
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.changeType(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(vertical: 7.h),
              decoration: BoxDecoration(
                color: active ? AppPalette.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(999.r),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  labelKey.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: active ? FontWeight.w500 : FontWeight.w300,
                    color: active ? AppPalette.white : AppPalette.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWeight1),
        ),
        child: Row(
          children: [
            tab(t: ExploreType.influencer, labelKey: 'explore_tab_influencers'),
            tab(t: ExploreType.adAgency, labelKey: 'explore_tab_ad_agencies'),
          ],
        ),
      );
    });
  }
}
