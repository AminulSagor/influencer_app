import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';

/// Reusable page header for signup flows.
/// Contains title, subtitle and optional body text.
class SignupPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? body;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? bodyStyle;

  const SignupPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.body,
    this.titleStyle,
    this.subtitleStyle,
    this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            maxLines: 1,
            style:
                titleStyle ??
                TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 14.h),
          Text(
            subtitle!,
            style:
                subtitleStyle ??
                TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.secondary,
                ),
          ),
        ],
        if (body != null) ...[
          SizedBox(height: 8.h),
          Text(
            body!,
            style:
                bodyStyle ??
                TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w300,
                  color: AppPalette.primary,
                ),
          ),
        ],
      ],
    );
  }
}
