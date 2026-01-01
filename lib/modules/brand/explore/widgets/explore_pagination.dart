import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import '../../../../core/theme/app_palette.dart';
import '../explore_controller.dart';

class ExplorePagination extends GetView<ExploreController> {
  const ExplorePagination({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.currentPage.value;
      final total = controller.totalPages.value;
      final loading = controller.isLoading.value;

      return Row(
        children: [
          Text(
            'explore_page'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.subtext,
            ),
          ),
          8.w.horizontalSpace,

          Container(
            width: 44.w,
            height: 30.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.thirdColor,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(color: AppPalette.secondary),
            ),
            child: FittedBox(
              child: Text(
                '$page',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppPalette.subtext,
                ),
              ),
            ),
          ),

          8.w.horizontalSpace,
          Text(
            '${'explore_of'.tr} $total',
            style: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
          ),

          const Spacer(),

          // Optional Prev (kept small)
          IconButton(
            onPressed: (loading || page <= 1) ? null : controller.prevPage,
            icon: Icon(Icons.chevron_left_rounded, size: 22.sp),
          ),

          CustomButton(
            onTap: controller.nextPage,
            btnText: 'explore_next'.tr,
            textColor: AppPalette.white,
          ),
        ],
      );
    });
  }
}
