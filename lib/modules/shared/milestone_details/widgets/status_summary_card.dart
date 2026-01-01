import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';

class StatusSummaryCard extends StatelessWidget {
  final String statusText;
  final Color statusColor;
  final Color statusTextColor;
  final Color statusChipTextColor;
  final Color statusBgColor;
  final String dateLabel;

  const StatusSummaryCard({
    super.key,
    required this.statusText,
    required this.statusColor,
    required this.statusTextColor,
    required this.dateLabel,
    required this.statusChipTextColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppPalette.white, statusBgColor]),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: statusTextColor, width: kBorderWidth0_5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Status',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: statusTextColor,
            ),
          ),
          SizedBox(height: 10.h),

          // Center pill with current status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: statusChipTextColor,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Date row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_filled,
                size: 12.sp,
                color: statusTextColor,
              ),
              SizedBox(width: 6.w),
              Text(
                dateLabel,
                style: TextStyle(fontSize: 12.sp, color: statusTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
