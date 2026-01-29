import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';

/// Reusable section title widget for signup flows.
/// Displays an icon (either Image.asset or Icon) with title text.
class SignupSectionTitle extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final IconData? iconData;
  final Color? iconColor;
  final TextStyle? textStyle;

  const SignupSectionTitle({
    super.key,
    required this.title,
    this.iconAsset,
    this.iconData,
    this.iconColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (iconAsset != null)
          Image.asset(iconAsset!, width: 34.w)
        else if (iconData != null)
          Icon(iconData, size: 24.sp, color: iconColor ?? AppPalette.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
          ),
        ),
      ],
    );
  }
}
