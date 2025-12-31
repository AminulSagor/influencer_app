import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';

class ProgressRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;

  const ProgressRow({super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = active ? AppPalette.primary : AppPalette.greyText;
    final subColor = active
        ? AppPalette.greyText
        : AppPalette.greyText.withOpacity(.75);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: active ? AppPalette.primary : AppPalette.border1,
            size: 32.sp,
          ),

          10.w.horizontalSpace,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.black,
                  ),
                ),

                2.h.verticalSpace,

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w400,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ProgressRowLevel extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool active;

  const ProgressRowLevel({super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = active ? AppPalette.primary : AppPalette.greyText;
    final subColor = active
        ? AppPalette.greyText
        : AppPalette.greyText.withOpacity(.75);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [

          Container(
            height: 32, width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.r),
                color: Color(0xFFE3E3E3),
              ),
              child: Image.asset(icon, height: 18, width: 10, color: active ? AppPalette.primary : AppPalette.border1)),

          10.w.horizontalSpace,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.black,
                  ),
                ),

                2.h.verticalSpace,

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w400,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}