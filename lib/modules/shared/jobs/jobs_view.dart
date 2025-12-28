import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/utils/label_localizers.dart';
import 'package:influencer_app/core/utils/number_formatter.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/job_offer_card.dart';
import 'package:influencer_app/core/widgets/search_field.dart';
import 'package:influencer_app/routes/app_routes.dart';

import 'jobs_controller.dart';

class JobsView extends GetView<JobsController> {
  const JobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isBrand = accountTypeService.isBrand;

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              20.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      hintText: 'jobs_search_hint'.tr,
                      onChanged: (value) =>
                          controller.searchQuery.value = value,
                    ),
                  ),
                  if (isBrand) ...[
                    10.w.horizontalSpace,
                    CustomButton(
                      onTap: () {
                        Get.toNamed(AppRoutes.createCampaign, id: 1);
                      },
                      btnText: '+ New',
                      textColor: AppPalette.white,
                      height: 42.h,
                    ),
                    10.w.horizontalSpace,
                    Container(
                      height: 30.w,
                      width: 30.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(
                          color: AppPalette.secondary,
                          width: 3.w,
                        ),
                      ),
                      child: Icon(
                        Icons.question_mark_rounded,
                        color: AppPalette.secondary,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              _buildTopTabs(isBrand: isBrand),
              SizedBox(height: 12.h),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.white,
                    border: Border.all(
                      color: AppPalette.border1,
                      width: kBorderWidth0_5,
                    ),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 15.h,
                  ),
                  child: Obx(() {
                    if (isBrand) {
                      switch (controller.currentTabIndex.value) {
                        case 0:
                          return _buildBrandActiveTab();
                        case 1:
                          return _buildBrandBudgetingTab();
                        case 2:
                          return _buildBrandCompletedTab();
                        case 3:
                          return _buildBrandDraftsTab();
                        case 4:
                          return _buildBrandCanceledTab();
                        default:
                          return const SizedBox.shrink();
                      }
                    }

                    switch (controller.currentTabIndex.value) {
                      case 0:
                        return _buildNewOffersTab();
                      case 1:
                        return _buildActiveJobsTab();
                      case 2:
                        return _buildCompletedJobsTab();
                      case 3:
                        return _buildPendingTab();
                      case 4:
                        return _buildDeclinedTab();
                      default:
                        return const SizedBox.shrink();
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTabs({required bool isBrand}) {
    final labelKeys = isBrand
        ? [
            'jobs_tab_active_jobs',
            'jobs_tab_budgeting_quoting',
            'jobs_tab_completed',
            'jobs_tab_draft',
            'jobs_tab_canceled',
          ]
        : [
            'jobs_tab_new_offers',
            'jobs_tab_active_jobs',
            'jobs_tab_completed',
            'jobs_tab_pending',
            'jobs_tab_declined',
          ];

    return Container(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(labelKeys.length, (index) {
              final isActive = controller.currentTabIndex.value == index;

              // For influencer: last tab is declined.
              // For brand: last tab is canceled.
              final isDangerTab = index == 4;

              final count = controller.getCountForTab(index);

              // In the screenshots, Brand shows counts even when inactive.
              final showCount = isBrand ? count > 0 : (count > 0 && isActive);

              final activeColor = isDangerTab
                  ? AppPalette.complemetary
                  : AppPalette.secondary;
              final inactiveText = AppPalette.black;

              return Container(
                decoration: BoxDecoration(
                  border: isActive
                      ? Border(bottom: BorderSide(color: activeColor, width: 2))
                      : null,
                ),
                margin: EdgeInsets.only(
                  right: index == labelKeys.length - 1 ? 0 : 12.w,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.changeTab(index),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labelKeys[index].tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isActive
                                ? FontWeight.w400
                                : FontWeight.w300,
                            color: isActive ? activeColor : inactiveText,
                          ),
                        ),
                        if (showCount) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppPalette.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ---------------- COMMON HELPERS ----------------

  Widget _tabHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: controller.toggleSort,
          child: Obx(
            () => _filterChip(
              text: controller.isSortLowToHigh.value
                  ? 'jobs_sort_low_to_high'.tr
                  : 'jobs_sort_high_to_low'.tr,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip({required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppPalette.thirdColor,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.secondary, width: kBorderWeight1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_downward_rounded,
            size: 10.sp,
            color: AppPalette.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomLoader({required bool isLoading}) {
    if (!isLoading) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 40.h),
      child: Center(
        child: Text(
          'common_no_jobs_found'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppPalette.greyText),
        ),
      ),
    );
  }

  // ---------------- INFLUENCER / AGENCY TABS (unchanged UI) ----------------

  Widget _buildNewOffersTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_header_new_offers'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredNewOffers;
              final isLoading = controller.isLoadingNewOffers.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: JobOfferCard(
                        job: job,
                        type: 'new',
                        onAccept: () {},
                        onDecline: () {},
                        onView: () => controller.openJobDetails(job),
                      ),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobsTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 1),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_header_active_jobs'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredActiveJobs;
              final isLoading = controller.isLoadingActiveJobs.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: JobOfferCard(
                        job: job,
                        type: 'active',
                        onView: () => controller.openJobDetails(job),
                      ),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedJobsTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 2),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_header_completed_jobs'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredCompletedJobs;
              final isLoading = controller.isLoadingCompletedJobs.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: JobOfferCard(
                        job: job,
                        type: 'complete',
                        onView: () => controller.openJobDetails(job),
                      ),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 3),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_header_pending_payments'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredPendingPayments;
              final isLoading = controller.isLoadingPendingPayments.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: JobOfferCard(
                        job: job,
                        type: 'pending',
                        onView: () => controller.openJobDetails(job),
                      ),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclinedTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 4),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_header_declined_jobs'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredDeclinedJobs;
              final isLoading = controller.isLoadingDeclinedJobs.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: JobOfferCard(
                        job: job,
                        type: 'declined',
                        onView: () => controller.openJobDetails(job),
                      ),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------- BRAND TABS (matches screenshots) ----------------

  Widget _buildBrandActiveTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_header_active_jobs'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredBrandActive;
              final isLoading = controller.isLoadingBrandActive.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _brandActiveCard(job),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandBudgetingTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 1),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_tab_budgeting_quoting'.tr),
            SizedBox(height: 10.h),
            _brandBudgetingChips(),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredBrandBudgeting;
              final isLoading = controller.isLoadingBrandBudgeting.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _brandBudgetingCard(job),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _brandBudgetingChips() {
    return Obx(() {
      final selected = controller.brandBudgetChipIndex.value;
      final budgetPendingCount = controller.brandBudgetPendingCount;
      final quotationCount = controller.brandQuotationReceivedCount;

      Widget chip({required int index, required String text, int? badge}) {
        final isSelected = selected == index;
        return GestureDetector(
          onTap: () => controller.setBrandBudgetChip(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppPalette.secondary : AppPalette.white,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? AppPalette.white : AppPalette.black,
                  ),
                ),
                if (badge != null) ...[
                  SizedBox(width: 10.w),
                  Container(
                    width: 20.w,
                    height: 20.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppPalette.error,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      badge.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppPalette.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            chip(index: 0, text: 'All'),
            SizedBox(width: 10.w),
            chip(index: 1, text: 'Budget Pending', badge: budgetPendingCount),
            SizedBox(width: 10.w),
            chip(index: 2, text: 'Quotation Received', badge: quotationCount),
          ],
        ),
      );
    });
  }

  Widget _buildBrandCompletedTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 2),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_tab_completed'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredBrandCompleted;
              final isLoading = controller.isLoadingBrandCompleted.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _brandCompletedCard(job),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandDraftsTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 3),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_tab_draft'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredBrandDrafts;
              final isLoading = controller.isLoadingBrandDrafts.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _brandDraftOrCanceledCard(job, isCanceled: false),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandCanceledTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onNotification(notification, 4),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('jobs_tab_canceled'.tr),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredBrandCanceled;
              final isLoading = controller.isLoadingBrandCanceled.value;

              if (items.isEmpty && !isLoading) return _emptyState();

              return Column(
                children: [
                  ...items.map(
                    (job) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _brandDraftOrCanceledCard(job, isCanceled: true),
                    ),
                  ),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------- BRAND CARDS ----------------

  Widget _brandActiveCard(JobItem job) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    if ((job.subTitle ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        job.subTitle!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.greyText,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Text(
                      formatCurrencyByLocale(job.budget),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if ((job.dueLabel ?? '').isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
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
                    localizeDueLabel(job.dueLabel),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.complemetary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.person, size: 16.sp, color: AppPalette.complemetary),
              SizedBox(width: 8.w),
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
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 16.sp,
                color: AppPalette.complemetary,
              ),
              SizedBox(width: 8.w),
              Text(
                job.dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.openJobDetails(job),
                child: Text(
                  '${'common_view'.tr} >',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: (job.progressPercent ?? 0) / 100,
            minHeight: 8.h,
            backgroundColor: AppPalette.secondary.withAlpha(60),
            color: AppPalette.secondary,
            borderRadius: BorderRadius.circular(kBorderRadiusSmall.r),
          ),
          SizedBox(height: 8.h),
          Text(
            '${formatNumberByLocale(job.progressPercent ?? 0)}% Complete',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppPalette.complemetary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandBudgetingCard(JobItem job) {
    final status = (job.profitLabel ?? '')
        .trim(); // using as "Budget Pending" / "Quotation Received"
    final isQuotation = status == 'Quotation Received';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    if ((job.subTitle ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        job.subTitle!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.greyText,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.openJobDetails(job),
                child: Text(
                  '${'common_view'.tr} >',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isQuotation ? AppPalette.greenBg : AppPalette.defaultFill,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(
                color: isQuotation
                    ? AppPalette.greenBorder
                    : AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.isEmpty ? 'Budget Pending' : status,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isQuotation
                              ? AppPalette.greenText
                              : AppPalette.primary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        isQuotation
                            ? formatNumberByLocale(job.progressPercent ?? 0)
                            : formatCurrencyByLocale(job.budget),
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: isQuotation
                              ? AppPalette.secondary
                              : AppPalette.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((job.totalEarningsLabel ?? '').isNotEmpty)
                  Text(
                    job.totalEarningsLabel!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.greyText,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 16.sp,
                color: AppPalette.complemetary,
              ),
              SizedBox(width: 8.w),
              Text(
                job.dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.openJobDetails(job),
                child: Text(
                  '${'common_view'.tr} >',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brandCompletedCard(JobItem job) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    if ((job.subTitle ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        job.subTitle!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.greyText,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Text(
                      formatCurrencyByLocale(job.budget),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.openJobDetails(job),
                child: Text(
                  '${'common_view'.tr} >',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.person, size: 16.sp, color: AppPalette.complemetary),
              SizedBox(width: 8.w),
              Text(
                job.clientName,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _ratingStars(job.rating ?? 0),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 16.sp,
                color: AppPalette.complemetary,
              ),
              SizedBox(width: 8.w),
              Text(
                job.dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brandDraftOrCanceledCard(JobItem job, {required bool isCanceled}) {
    final cTitle = isCanceled ? AppPalette.defaultStroke : AppPalette.primary;
    final cSub = isCanceled ? AppPalette.defaultStroke : AppPalette.greyText;
    final cMoney = isCanceled ? AppPalette.defaultStroke : AppPalette.secondary;
    final cIcon = isCanceled
        ? AppPalette.defaultStroke
        : AppPalette.complemetary;
    final cDate = isCanceled
        ? AppPalette.defaultStroke
        : AppPalette.complemetary;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: cTitle,
                      ),
                    ),
                    if ((job.subTitle ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        job.subTitle!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: cSub,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Text(
                      formatCurrencyByLocale(job.budget),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: cMoney,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.openJobDetails(job),
                child: Text(
                  'Edit >',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isCanceled
                        ? AppPalette.defaultStroke
                        : AppPalette.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.access_time_filled, size: 16.sp, color: cIcon),
              SizedBox(width: 8.w),
              Text(
                job.dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: cDate,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(
          Icons.star_rounded,
          size: 16.sp,
          color: filled ? AppPalette.starDark : AppPalette.backgroundDark,
        );
      }),
    );
  }

  bool _onNotification(ScrollNotification notification, int index) {
    final m = notification.metrics;

    // 1) Avoid triggering on first build when list isn't scrollable yet
    if (m.maxScrollExtent <= 0) return false;

    // 2) Optional: avoid triggering when you're still at top
    if (m.pixels <= 0) return false;

    // 3) Near bottom → load more AFTER this frame
    if (m.pixels >= m.maxScrollExtent - 120) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadMoreForTab(index);
      });
    }

    return false;
  }
}
