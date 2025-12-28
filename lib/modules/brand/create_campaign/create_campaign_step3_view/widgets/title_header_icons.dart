import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

class TitleHeaderIcons extends StatelessWidget {
  final String text;
  final String icon;
  final String? extraIcon;

  const TitleHeaderIcons({
    super.key,
    required this.text,
    required this.icon,
    this.extraIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Image.asset(
          icon,
          height: 20,
          width: 20,
          color: AppPalette.primary,
        ),

        if (extraIcon != null && extraIcon!.isNotEmpty) ...[
          Image.asset(
            extraIcon!,
            height: 20,
            width: 20,
            color: AppPalette.primary,
          ),
        ],

        Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
      ],
    );
  }
}