import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';

class CardTitle extends StatelessWidget {
  final String icon;
  final String title;
  const CardTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(icon, height: 25, width: 25),

        10.w.horizontalSpace,

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}