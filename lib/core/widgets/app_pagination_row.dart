import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_palette.dart';
import '../utils/constants.dart';
import 'custom_button.dart';

class AppPaginationRow extends StatelessWidget {
  final RxInt page;
  final RxInt totalPages;
  final RxBool? isLoading;

  final VoidCallback onNext;
  final VoidCallback? onPrev;

  final String pageLabel;
  final String ofLabel;
  final String nextLabel;

  const AppPaginationRow({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onNext,
    this.onPrev,
    this.isLoading,
    required this.pageLabel,
    required this.ofLabel,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = page.value;
      final total = totalPages.value;
      final loading = isLoading?.value ?? false;

      return Row(
        children: [
          Text(
            pageLabel,
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
                '$p',
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
            '$ofLabel $total',
            style: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
          ),

          const Spacer(),

          if (onPrev != null)
            IconButton(
              onPressed: (loading || p <= 1) ? null : onPrev,
              icon: Icon(Icons.chevron_left_rounded, size: 22.sp),
            ),

          CustomButton(
            onTap: (loading || p >= total) ? () {} : onNext,
            btnText: nextLabel,
            textColor: AppPalette.white,
          ),
        ],
      );
    });
  }
}
