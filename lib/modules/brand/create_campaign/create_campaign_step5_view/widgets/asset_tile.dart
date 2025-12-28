import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

import '../../../../../core/utils/app_assets.dart';

class AssetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  const AssetTile({super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _softBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [

          Icon(icon, color: AppPalette.primary.withOpacity(.75), size: 26.sp),

          15.w.horizontalSpace,

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

          InkWell(
            onTap: onRemove,
            child:  Image.asset(AppAssets.close, height: 18, width: 18, color: AppPalette.primary.withOpacity(.5)),
          ),
        ],
      ),
    );
  }
}