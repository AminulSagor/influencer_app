import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_palette.dart';
import '../models/explore_item.dart';

class ExploreListItem extends StatelessWidget {
  final ExploreItem item;
  const ExploreListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.secondary, AppPalette.primary],
        ),
      ),
      child: Row(
        children: [
          // avatar
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.65),
                ],
              ),
            ),
          ),
          12.w.horizontalSpace,

          // text area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.white,
                    ),
                  ),
                ),
                2.h.verticalSpace,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: item.icons
                        .take(4)
                        .map(
                          (ic) => Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: Icon(
                              ic,
                              size: 14.sp,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                2.h.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _Stars(rating: item.rating),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor().clamp(0, 5);
    final hasHalf = (rating - full) >= 0.5 && full < 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) {
          return Icon(
            Icons.star_rounded,
            size: 12.sp,
            color: AppPalette.starDark,
          );
        }
        if (i == full && hasHalf) {
          return Stack(
            children: [
              Icon(Icons.star_rounded, size: 12.sp, color: AppPalette.white),
              Icon(
                Icons.star_half_rounded,
                size: 12.sp,
                color: AppPalette.starDark,
              ),
            ],
          );
        }
        return Icon(Icons.star_rounded, size: 12.sp, color: AppPalette.white);
      }),
    );
  }
}
