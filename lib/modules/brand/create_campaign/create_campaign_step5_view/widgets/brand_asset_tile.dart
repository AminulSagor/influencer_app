import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrandAssetTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const BrandAssetTile({super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: _softBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _softBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: _primary.withOpacity(.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.facebook,
                size: 18.sp,
                color: _primary.withOpacity(.75),
              ),
            ),
            12.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary.withOpacity(.75),
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _primary.withOpacity(.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: _primary.withOpacity(.55)),
          ],
        ),
      ),
    );
  }
}