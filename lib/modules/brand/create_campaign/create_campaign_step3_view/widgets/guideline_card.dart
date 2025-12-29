import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class GuidelineCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color tint;
  final Color border;
  final Color titleColor;

  final TextEditingController controller;
  final void Function(String) onChanged;
  final String exampleHint;

  const GuidelineCard({
    required this.title,
    required this.icon,
    required this.tint,
    required this.border,
    required this.titleColor,
    required this.controller,
    required this.onChanged,
    required this.exampleHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header like screenshot (icon + title)
          Row(
            children: [
              Image.asset(icon, height: 18.sp,width: 18.sp, color: titleColor),

              10.w.horizontalSpace,

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),

          12.h.verticalSpace,

          // Inner bordered field box
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(color: border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  onChanged: onChanged,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: titleColor.withOpacity(.78),
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: exampleHint, // multi-line bullet hint
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: titleColor.withOpacity(.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}