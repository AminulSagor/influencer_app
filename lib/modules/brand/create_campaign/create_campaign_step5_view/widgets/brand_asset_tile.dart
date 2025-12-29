import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';

class BrandAssetTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const BrandAssetTile({super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: _softBg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: _softBorder),
        ),
        child: Row(
          children: [
            
            Image.asset(AppAssets.facebook, width: 30, height: 30),

            16.w.horizontalSpace,

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
                      fontWeight: FontWeight.w500,
                      color: AppPalette.secondary,
                    ),
                  ),

                  2.h.verticalSpace,

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.primary.withOpacity(.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppPalette.primary.withOpacity(.55)),
          ],
        ),
      ),
    );
  }
}