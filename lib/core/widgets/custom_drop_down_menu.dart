import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/utils.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class CustomDropDownMenu extends StatelessWidget {
  final String? title;
  final TextStyle? titleTextStyle;
  final String hintText;
  final String? value;
  final List<String> options;
  final Color? fillColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final Function(String?)? onChanged;
  const CustomDropDownMenu({
    super.key,
    required this.hintText,
    required this.options,
    this.onChanged,
    required this.value,
    this.title,
    this.titleTextStyle,
    this.fillColor,
    this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final dropDown = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      // height: 48.h,
      decoration: BoxDecoration(
        color: fillColor ?? AppPalette.defaultFill,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hintText,
            style:
                textStyle ??
                TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12.sp,
                  color: textColor ?? AppPalette.black,
                ),
          ),
          isDense: true,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 24.sp),
          dropdownColor: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          items: options
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.tr,
                    style:
                        textStyle ??
                        TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12.sp,
                          color: textColor ?? AppPalette.black,
                        ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
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
                AppTheme.textStyle.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.secondary,
                ),
          ),
          SizedBox(height: 5.h),
          dropDown,
        ],
      );
    }

    return dropDown;
  }
}
