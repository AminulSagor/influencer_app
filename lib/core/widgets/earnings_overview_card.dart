import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_palette.dart';
import '../utils/currency_formatter.dart';

class EarningsOverviewCard extends StatelessWidget {
  final int lifetimeEarnings;
  final int pendingEarnings;

  const EarningsOverviewCard({
    super.key,
    required this.lifetimeEarnings,
    required this.pendingEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: const LinearGradient(
          colors: [AppPalette.gradient1, AppPalette.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/fire.png',
                height: 33.h,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 8.w),
              Text(
                'home_earnings_overview'.tr,
                style: TextStyle(
                  color: AppPalette.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _earningsItem(
                  iconPath: 'assets/icons/goal.png',
                  label: 'home_lifetime_earnings'.tr,
                  amount: formatCurrencyByLocale(lifetimeEarnings),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _earningsItem(
                  iconPath: 'assets/icons/sand_watch.png',
                  label: 'home_pending_earnings'.tr,
                  amount: formatCurrencyByLocale(pendingEarnings),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningsItem({
    required String iconPath,
    required String label,
    required String amount,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 15.w,
                height: 15.h,
                fit: BoxFit.cover,
                color: AppPalette.white,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: AppPalette.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            amount,
            style: TextStyle(
              color: AppPalette.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
