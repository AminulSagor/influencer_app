import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';

/// Reusable info row widget for signup flows.
/// Displays an icon (either Image.asset or Icon) with text.
class SignupInfoRow extends StatelessWidget {
  final String text;
  final String? iconAsset;
  final IconData? iconData;
  final Color? iconColor;
  final Color? backgroundColor;

  const SignupInfoRow({
    super.key,
    required this.text,
    this.iconAsset,
    this.iconData,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (iconAsset != null)
          Image.asset(iconAsset!, width: 34.w)
        else if (iconData != null)
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFFE7F3D9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              iconData,
              color: iconColor ?? AppPalette.primary,
              size: 24.sp,
            ),
          ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: AppPalette.primary),
          ),
        ),
      ],
    );
  }
}
