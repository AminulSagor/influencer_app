import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class MiniMetricPromotionField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const MiniMetricPromotionField({super.key, required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.primary,
          ),
        ),

        8.h.verticalSpace,

        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppPalette.greyText,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            filled: true,
            fillColor: AppPalette.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppPalette.primary.withAlpha(140),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}