import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/job_offer_card.dart';
import 'package:influencer_app/core/widgets/search_field.dart';

import 'jobs_controller.dart';

class JobsView extends GetView<JobsController> {
  const JobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              20.h.verticalSpace,
              SearchField(
                hintText: 'Search By Job Name, Client Name',
                onChanged: (value) => controller.searchQuery.value = value,
              ),
              SizedBox(height: 12.h),
              _buildTopTabs(),
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

  // ---------------- TOP TAB BAR ----------------

  Widget _buildTopTabs() {
    final labels = [
      'New Offers',
      'Active Jobs',
      'Completed',
      'Pending',
      'Declined',
    ];

    return Container(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(labels.length, (index) {
              final isActive = controller.currentTabIndex.value == index;
              final count = controller.getCountForTab(index);
              final isDeclined = labels[index] == 'Declined';

              return Container(
                decoration: BoxDecoration(
                  border: isActive
                      ? Border(
                          bottom: BorderSide(
                            color: isDeclined
                                ? AppPalette.complemetary
                                : AppPalette.secondary,
                            width: 2,
                          ),
                        )
                      : null,
                ),
                margin: EdgeInsets.only(
                  right: index == labels.length - 1 ? 0 : 12.w,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.changeTab(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isActive
                                  ? FontWeight.w400
                                  : FontWeight.w300,
                              color: isActive
                                  ? isDeclined
                                        ? AppPalette.complemetary
                                        : AppPalette.secondary
                                  : AppPalette.black,
                            ),
                          ),
                          if (count > 0 && isActive) ...[
                            SizedBox(width: 5.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDeclined
                                    ? AppPalette.complemetary
                                    : AppPalette.secondary,
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ---------------- TAB WRAPPERS ----------------

  Widget _buildNewOffersTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 120) {
          controller.loadMoreForTab(0);
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('New Offers Just For You!'),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredNewOffers;
              final isLoading = controller.isLoadingNewOffers.value;

              if (items.isEmpty && !isLoading) {
                return _emptyState();
              }

              return Column(
                children: [
                  ...items
                      .map(
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
                      )
                      .toList(),
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
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 120) {
          controller.loadMoreForTab(1);
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('Active Jobs'),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredActiveJobs;
              final isLoading = controller.isLoadingActiveJobs.value;

              if (items.isEmpty && !isLoading) {
                return _emptyState();
              }

              return Column(
                children: [
                  ...items
                      .map(
                        (job) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: JobOfferCard(
                            job: job,
                            type: 'active',
                            onView: () => controller.openJobDetails(job),
                          ),
                        ),
                      )
                      .toList(),
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
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 120) {
          controller.loadMoreForTab(2);
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('Completed Jobs'),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredCompletedJobs;
              final isLoading = controller.isLoadingCompletedJobs.value;

              if (items.isEmpty && !isLoading) {
                return _emptyState();
              }

              return Column(
                children: [
                  ...items
                      .map(
                        (job) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: JobOfferCard(
                            job: job,
                            type: 'complete',
                            onView: () => controller.openJobDetails(job),
                          ),
                        ),
                      )
                      .toList(),
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
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 120) {
          controller.loadMoreForTab(3);
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('Pending Payments'),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredPendingPayments;
              final isLoading = controller.isLoadingPendingPayments.value;

              if (items.isEmpty && !isLoading) {
                return _emptyState();
              }

              return Column(
                children: [
                  ...items
                      .map(
                        (job) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: JobOfferCard(
                            job: job,
                            type: 'pending',
                            onView: () => controller.openJobDetails(job),
                          ),
                        ),
                      )
                      .toList(),
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
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 120) {
          controller.loadMoreForTab(4);
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('Declined Jobs'),
            SizedBox(height: 12.h),
            Obx(() {
              final items = controller.filteredDeclinedJobs;
              final isLoading = controller.isLoadingDeclinedJobs.value;

              if (items.isEmpty && !isLoading) {
                return _emptyState();
              }

              return Column(
                children: [
                  ...items
                      .map(
                        (job) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: JobOfferCard(
                            job: job,
                            type: 'declined',
                            onView: () => controller.openJobDetails(job),
                          ),
                        ),
                      )
                      .toList(),
                  _bottomLoader(isLoading: isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------- SHARED HEADER & FILTER ----------------

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
        _filterChip(),
      ],
    );
  }

  Widget _filterChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
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
            'Low To High',
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
          'No jobs found',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
