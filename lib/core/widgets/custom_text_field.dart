import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextStyle? textStyle;
  final TextEditingController controller;
  final bool? enabled;
  final int? maxLines;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final TextAlign? textAlign;
  const CustomTextField({
    super.key,
    required this.hintText,
    this.textStyle,
    required this.controller,
    this.enabled,
    this.maxLines,
    this.contentPadding,
    this.fillColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        textStyle ?? TextStyle(fontSize: 12.sp, color: AppPalette.subtext);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      borderSide: const BorderSide(
        color: AppPalette.border1,
        width: kBorderWidth0_5,
      ),
    );
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      style: style,
      textAlign: textAlign ?? TextAlign.start,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: style.copyWith(color: AppPalette.subtext),
        labelStyle: style,
        errorStyle: style,
        fillColor: fillColor,
        filled: fillColor != null ? true : false,
        border: border,
        enabledBorder: border,
        contentPadding: contentPadding ?? EdgeInsets.all(12.w),
      ),
    );
  }
}
