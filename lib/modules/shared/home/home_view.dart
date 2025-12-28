import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/services/account_type_service.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/earnings_overview_card.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!accountTypeService.isBrand) ...[
                Obx(
                  () => EarningsOverviewCard(
                    lifetimeEarnings: controller.lifetimeEarnings.value,
                    pendingEarnings: controller.pendingEarnings.value,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
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
    final accountTypeService = Get.find<AccountTypeService>();
    final isBrand = accountTypeService.isBrand;

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            iconPath: 'assets/icons/suitcase.png',
            title: 'home_active_jobs'.tr,
            value: Obx(
              () => Text(
                formatNumberByLocale(controller.activeJobs.value),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  color: isBrand ? AppPalette.thirdColor : AppPalette.secondary,
                ),
              ),
            ),
            trailingText: 'home_view_all'.tr,
            isGradient: isBrand,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _summaryCard(
            iconPath: 'assets/icons/sand_watch2.png',
            title: 'home_new_offers_for_you'.tr,
            value: Obx(
              () => Text(
                formatNumberByLocale(controller.newOffers.value),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  color: isBrand ? AppPalette.thirdColor : AppPalette.secondary,
                ),
              ),
            ),
            trailingText: 'home_view_all'.tr,
            isGradient: accountTypeService.isBrand,
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
    bool isGradient = false,
  }) {
    final textColor = isGradient ? AppPalette.thirdColor : AppPalette.black;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: !isGradient
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPalette.primary, AppPalette.secondary],
              ),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 30.h,
                width: 30.h,
                padding: EdgeInsets.only(bottom: 5.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppPalette.defaultFill,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall.r),
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
                  color: textColor,
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
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor,
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
                'home_work_in_progress'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              const Spacer(),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.secondary,
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall.r),
                    border: Border.all(
                      color: AppPalette.defaultStroke,
                      width: kBorderWidth0_5,
                    ),
                  ),
                  child: Text(
                    'home_active_badge'.trParams({
                      'count': formatNumberByLocale(
                        controller.jobsInProgress.length,
                      ),
                    }),
                    style: TextStyle(
                      color: AppPalette.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
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
                'home_view_all_jobs'.tr,
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

  String _dueLabel(JobItem job) {
    // Prefer computing from dueInDays for localization correctness
    final dueInDays = job.dueInDays;
    if (dueInDays != null) {
      if (dueInDays <= 1) return 'label_due_tomorrow'.tr;
      return 'label_due_days'.trParams({
        'days': formatNumberByLocale(dueInDays),
      });
    }

    // Fallback if provided as ready text
    return job.dueLabel?.trim() ?? '';
  }

  Widget _jobCard(JobItem job) {
    final dueText = _dueLabel(job);
    final progress = (job.progressPercent ?? 0).clamp(0, 100);
    final accoutnTypeService = Get.find<AccountTypeService>();
    final isBrand = accoutnTypeService.isBrand;

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
                    if (isBrand)
                      Text(
                        job.subTitle ?? '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppPalette.subtext,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      isBrand
                          ? formatCurrencyByLocale(job.budget)
                          : '${formatNumberByLocale(job.sharePercent)}%',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppPalette.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (dueText.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.complemetaryFill,
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall.r),
                    border: Border.all(
                      color: AppPalette.complemetary,
                      width: kBorderWeight1,
                    ),
                  ),
                  child: Text(
                    dueText,
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
                job.dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (!isBrand)
                Text(
                  '${'common_budget'.tr}: ${formatCurrencyByLocale(job.budget)}',
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
            value: progress / 100,
            minHeight: 6.h,
            backgroundColor: AppPalette.secondary.withAlpha(77),
            color: AppPalette.secondary,
            borderRadius: BorderRadius.circular(kBorderRadiusSmall.r),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                'home_progress_complete_line'.trParams({
                  'percent': formatNumberByLocale(progress),
                }),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                '${'common_view'.tr} >',
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
    final isBrand = Get.find<AccountTypeService>().isBrand;
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
            'home_lifetime_summary'.tr,
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
                    '${controller.topClientJobsCompleted} ${'home_jobs_completed_suffix'.tr}',
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
                      isBrand ? 'top_influencer'.tr : 'home_top_client'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppPalette.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'home_last_job'.tr,
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
                    titleKey: 'home_total_jobs_completed',
                    value: controller.totalJobsCompleted.toString(),
                  );
                }),
              ),
              SizedBox(width: 12.w),
              if (!isBrand)
                Expanded(
                  child: Obx(() {
                    return _smallStatCard(
                      titleKey: 'home_total_earnings',
                      value: '৳${controller.totalEarningsK}k'.replaceAll(
                        'k00',
                        'k',
                      ),
                    );
                  }),
                ),
              if (isBrand)
                Expanded(
                  child: Obx(() {
                    return _smallStatCard(
                      titleKey: 'home_total_jobs_declined',
                      value: controller.totalJobsDeclined.toString(),
                      isDeclined: true,
                    );
                  }),
                ),
            ],
          ),
          if (!isBrand) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return _smallStatCard(
                      titleKey: 'home_total_jobs_declined',
                      value: controller.totalJobsDeclined.toString(),
                      isDeclined: true,
                    );
                  }),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() {
                    return _smallStatCard(
                      titleKey: 'home_most_used_platform',
                      value: controller.mostUsedPlatform.value,
                    );
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _smallStatCard({
    required String titleKey,
    required String value,
    bool isDeclined = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: isDeclined
                      ? AppPalette.complemetary
                      : AppPalette.secondary,
                ),
              ),
              const Icon(Icons.chevron_right, size: 12),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            titleKey.tr,
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
