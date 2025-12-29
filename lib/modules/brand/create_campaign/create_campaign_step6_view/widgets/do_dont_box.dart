import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

class DoDontBox extends StatelessWidget {
  final String title;
  final List<String> lines;
  final bool positive;

  const DoDontBox({super.key,
    required this.title,
    required this.lines,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final bg = positive ? const Color(0xFFE8F6EA) : const Color(0xFFFFE7E7);
    final border = positive ? const Color(0xFFBFE6C6) : const Color(0xFFF2B9B9);
    final icon = positive ? Icons.check_circle_outline : Icons.cancel_outlined;
    final accent = positive ? const Color(0xFF1C7C3E) : const Color(0xFFCC2B2B);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              Icon(icon, color: accent, size: 18.sp),

              8.w.horizontalSpace,

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppPalette.color2text,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          8.h.verticalSpace,

          if (lines.isEmpty)
            Text(
              '-',
              style: TextStyle(
                fontSize: 12.5.sp,
                color: accent.withOpacity(.8),
              ),
            )
          else
            ...lines.map(
                  (e) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: accent.withOpacity(.85),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: accent.withOpacity(.85),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}