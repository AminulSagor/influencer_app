import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/models/job_item.dart';

class MilestoneTile extends StatelessWidget {
  final Milestone m;
  const MilestoneTile({super.key, required this.m});

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: _primary.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                m.stepLabel,
                style: TextStyle(
                  color: _primary.withOpacity(.85),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: _primary.withOpacity(.85),
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  m.subtitle ?? m.deliverable ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          if ((m.dayLabel ?? '').isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _primary.withOpacity(.07),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _softBorder),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  m.dayLabel!,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: _primary.withOpacity(.75),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
