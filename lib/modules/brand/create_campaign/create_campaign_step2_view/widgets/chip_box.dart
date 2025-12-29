import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class ChipBox extends StatelessWidget {
  final List<String> items;
  final void Function(String) onRemove;

  const ChipBox({super.key, required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: items.isEmpty
          ? Text(
        'create_campaign_chip_empty'.tr,
        style: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
      )
          : Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: items.map((name) {
          return Container(
            constraints: BoxConstraints(maxWidth: 160.w),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: AppPalette.defaultFill,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                8.w.horizontalSpace,
                GestureDetector(
                  onTap: () => onRemove(name),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: AppPalette.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}