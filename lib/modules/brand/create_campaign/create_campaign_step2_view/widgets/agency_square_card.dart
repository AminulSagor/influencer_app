import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_palette.dart';

class AgencySquareCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const AgencySquareCard({super.key,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppPalette.primary
        : AppPalette.primary.withAlpha(210);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 140.w,
        height: 145.h,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7A9B57),
              AppPalette.primary,
            ],
          ),
          color: bg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppPalette.secondary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      AppPalette.secondary,
                      AppPalette.white,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            3.h.verticalSpace,

            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.thirdColor,
                letterSpacing: -0.2,
              ),
            ),

            2.h.verticalSpace,

            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.thirdColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}