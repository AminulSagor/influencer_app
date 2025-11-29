import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/widgets/earnings_overview_card.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => EarningsOverviewCard(
                  lifetimeEarnings: controller.lifetimeEarnings.value,
                  pendingEarnings: controller.pendingEarnings.value,
                ),
              ),
              SizedBox(height: 12.h),
              _buildSummaryRow(),
              SizedBox(height: 12.h),
              _buildWorkInProgressSection(),
              SizedBox(height: 12.h),
              _buildLifetimeSummarySection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- ACTIVE JOBS / NEW OFFERS ----------------

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            iconPath: 'assets/icons/suitcase.png',
            title: 'Active Jobs',
            value: Obx(
              () => Text(
                controller.activeJobs.toString(),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.secondary,
                ),
              ),
            ),
            trailingText: 'View All',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _summaryCard(
            iconPath: 'assets/icons/sand_watch2.png',
            title: 'New Offers For You',
            value: Obx(
              () => Text(
                controller.newOffers.toString(),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.secondary,
                ),
              ),
            ),
            trailingText: 'View All',
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String iconPath,
    required String title,
    required Widget value,
    required String trailingText,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisSize: .max,
            mainAxisAlignment: .spaceBetween,
            children: [
              Container(
                height: 30.h,
                width: 30.h,
                padding: EdgeInsets.only(bottom: 5.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppPalette.defaultFill,
                  borderRadius: BorderRadius.circular(kBorderRadius2.r),
                  border: Border.all(
                    color: AppPalette.defaultStroke,
                    width: kBorderWidth0_5,
                  ),
                ),
                child: Image.asset(
                  iconPath,
                  width: 20.w,
                  fit: BoxFit.cover,
                  color: AppPalette.secondary,
                ),
              ),
              Text(
                '$trailingText >',
                style: TextStyle(
                  color: AppPalette.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          value,
          SizedBox(height: 4.h),
          FittedBox(
            fit: .scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppPalette.black,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- WORK IN PROGRESS ----------------

  Widget _buildWorkInProgressSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Work In Progress',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppPalette.secondary,
                  borderRadius: BorderRadius.circular(kBorderRadius2.r),
                  border: Border.all(
                    color: AppPalette.defaultStroke,
                    width: kBorderWidth0_5,
                  ),
                ),
                child: Text(
                  '4 Active',
                  style: TextStyle(
                    color: AppPalette.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Obx(
            () => Column(
              children: controller.jobsInProgress
                  .map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _jobCard(job),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppPalette.secondary,
                  width: kBorderWidth0_5,
                ),
                backgroundColor: AppPalette.thirdColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadius.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
              ),
              onPressed: () {},
              child: Text(
                'View All Jobs →',
                style: TextStyle(
                  color: const Color(0xFF315719),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(HomeJob job) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + due
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${job.sharePercent}% ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppPalette.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppPalette.complemetaryFill,
                  borderRadius: BorderRadius.circular(kBorderRadius2.r),
                  border: Border.all(
                    color: AppPalette.complemetary,
                    width: kBorderWeight1,
                  ),
                ),
                child: Text(
                  job.dueLabel,
                  style: TextStyle(
                    color: AppPalette.complemetary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.person, size: 15.sp, color: AppPalette.complemetary),
              SizedBox(width: 6.w),
              Text(
                job.clientName,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 14.sp,
                color: AppPalette.complemetary,
              ),
              SizedBox(width: 6.w),
              Text(
                job.dueDate,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Spacer(),
              Text(
                'Budget: ${formatCurrencyByLocale(job.budget)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: job.progressPercent / 100,
            minHeight: 6.h,
            backgroundColor: AppPalette.secondary.withAlpha(77),
            color: AppPalette.secondary,
            borderRadius: BorderRadius.circular(kBorderRadius2.r),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                '${job.progressPercent}% Complete',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                'View >',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppPalette.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- LIFETIME SUMMARY ----------------

  Widget _buildLifetimeSummarySection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lifetime Summary',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.topClientName.value,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Obx(
                  () => Text(
                    '${controller.topClientJobsCompleted} Jobs Completed',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top client',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppPalette.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'Last Job: 12 Dec 2025',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppPalette.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return _smallStatCard(
                    title: 'Total Jobs Completed',
                    value: controller.totalJobsCompleted.toString(),
                  );
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(() {
                  return _smallStatCard(
                    title: 'Total Earnings',
                    value: '৳${controller.totalEarningsK}k'.replaceAll(
                      'k00',
                      'k',
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return _smallStatCard(
                    title: 'Total Jobs Declined',
                    value: controller.totalJobsDeclined.toString(),
                  );
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(() {
                  return _smallStatCard(
                    title: 'Most Used Platform',
                    value: controller.mostUsedPlatform.value,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallStatCard({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.secondary,
                ),
              ),
              Icon(Icons.chevron_right, size: 12),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppPalette.black,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
