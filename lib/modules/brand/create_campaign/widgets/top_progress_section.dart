import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';

class TopProgressSection extends StatelessWidget {
  final VoidCallback? onPrevious;
  final String stepText;
  final String progressPercentText;
  final double progress;
  const TopProgressSection({
    super.key,
    required this.stepText,
    required this.progressPercentText,
    required this.progress,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onPrevious != null) ...[
              InkWell(
                borderRadius: BorderRadius.circular(999.r),
                onTap: onPrevious,
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.arrow_back,
                    size: 14.sp,
                    color: AppPalette.black,
                  ),
                ),
              ),
              6.w.horizontalSpace,
            ],
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stepText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                    color: AppPalette.black,
                  ),
                ),
              ),
            ),
            Text(
              progressPercentText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.black,
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: progress,
            borderRadius: BorderRadius.circular(100),
            minHeight: 9.h,
            backgroundColor: AppPalette.secondary.withAlpha(100),
            color: AppPalette.primary,
          ),
        ),
      ],
    );
  }
}
