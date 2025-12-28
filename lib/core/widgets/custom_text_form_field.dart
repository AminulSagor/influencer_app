import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';
import '../utils/constants.dart';

class CustomTextFormField extends StatelessWidget {
  final String? title;
  final TextStyle? titleTextStyle;
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
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
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
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.title,
    this.titleTextStyle,
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

    final textFormField = TextFormField(
      initialValue: initialValue,
      controller: controller,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      style: style,
      textAlign: textAlign ?? TextAlign.start,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
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
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );

    if (title != null) {
      return Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            title!,
            style:
                titleTextStyle ??
                TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
          ),
          5.h.verticalSpace,
          textFormField,
        ],
      );
    }
    return textFormField;
  }
}
