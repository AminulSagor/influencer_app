import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String icon;
  final Widget child;

  const SectionCard({super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13, horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              Image.asset(icon, height: 25, width: 25,color: AppPalette.primary),

              6.w.horizontalSpace,

              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),

          30.h.verticalSpace,

          child,
        ],
      ),
    );
  }
}