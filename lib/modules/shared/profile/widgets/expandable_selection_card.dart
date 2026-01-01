import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';

class ExpandableSectionCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const ExpandableSectionCard({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kBorderRadius.r),
              topRight: Radius.circular(kBorderRadius.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppPalette.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 28.sp,
                    color: AppPalette.black,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
