import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class SingleLineBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final void Function(String) onChanged;

  const SingleLineBox({super.key,
    required this.controller,
    required this.hint,
    required this.keyboardType,
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
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 12.sp, color: AppPalette.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12.sp, color: AppPalette.greyText,fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}