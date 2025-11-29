import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';
import '../utils/constants.dart';

class CustomTextFormField extends StatelessWidget {
  final String? initialValue;
  final String hintText;
  final TextStyle? textStyle;
  final TextEditingController? controller;
  final bool? enabled;
  final int? maxLines;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final TextAlign? textAlign;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.textStyle,
    this.controller,
    this.enabled,
    this.maxLines,
    this.contentPadding,
    this.fillColor,
    this.textAlign,
    this.initialValue,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        textStyle ?? TextStyle(fontSize: 12.sp, color: AppPalette.black);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      borderSide: const BorderSide(
        color: AppPalette.border1,
        width: kBorderWidth0_5,
      ),
    );

    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      style: style,
      textAlign: textAlign ?? TextAlign.start,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: style.copyWith(color: AppPalette.subtext),
        isDense: true,
        labelStyle: style,
        errorStyle: style,
        fillColor: fillColor,
        filled: fillColor != null ? true : false,
        border: border,
        enabledBorder: border,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }
}
