import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class MultilineBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final void Function(String) onChanged;

  const MultilineBox({super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 4,
        style: TextStyle(fontSize: 12.sp, color: AppPalette.greyText, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12.sp, color: AppPalette.subtext, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}