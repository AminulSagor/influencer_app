import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;

  const SectionTitle({
    required this.icon,
    required this.title,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: iconColor ?? AppPalette.primary),
        10.w.horizontalSpace,
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}