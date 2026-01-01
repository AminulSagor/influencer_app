import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_pagination_row.dart';
import '../../../core/widgets/app_pill_tabs.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/sort_toggle_chip.dart';
import '../../../core/widgets/transaction_card.dart';
import 'analytics_controller.dart';
import 'models/analytics_models.dart';
import 'widgets/top_summary_card.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            TopSummaryCard(
              topCampaign: controller.topCampaign,
              topInfluencer: controller.topInfluencer,
            ),
            12.h.verticalSpace,

            Obx(
              () => AppPillTabs<bool>(
                selected: controller.isAnalyticsTab.value,
                onChanged: (v) => controller.onTabChanged(v),
                items: [
                  AppPillTabItem(
                    value: true,
                    label: 'analytics_tab_analytics'.tr,
                  ),
                  AppPillTabItem(
                    value: false,
                    label: 'analytics_tab_transactions'.tr,
                  ),
                ],
              ),
            ),
            10.h.verticalSpace,
            Obx(() {
              if (controller.isAnalyticsTab.value) {
                return Column(
                  children: [
                    _SectionCard(
                      title: 'analytics_section_influencers'.tr,
                      subtitle: 'analytics_showing_results'.trParams({
                        'count': '${controller.showingCount}',
                        'total': '${controller.totalResults}',
                      }),
                      child: Column(
                        children: [
                          CustomTextFormField(
                            hintText: 'analytics_search_client'.tr,
                            controller: controller.searchCtrl,
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Icon(
                                Icons.search,
                                size: 18.sp,
                                color: AppPalette.subtext,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 10.h,
                            ),
                          ),
                          10.h.verticalSpace,
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const _LoadingBlock();
                            }
                            return _InfluencerTable(
                              rows: controller.influencers,
                            );
                          }),
                          12.h.verticalSpace,
                          AppPaginationRow(
                            page: controller.page,
                            totalPages: controller.totalPages,
                            isLoading: controller.isLoading,
                            onPrev: controller.prevPage,
                            onNext: controller.nextPage,
                            pageLabel: 'analytics_page'.tr,
                            ofLabel: 'analytics_of'.tr,
                            nextLabel: 'analytics_next'.tr,
                          ),
                        ],
                      ),
                    ),
                    12.h.verticalSpace,
                    _PlatformsCard(platforms: controller.platforms),
                  ],
                );
              }

              // Transactions tab
              return _SectionCard(
                title: 'analytics_section_recent_transactions'.tr,
                subtitle: 'analytics_showing_results'.trParams({
                  'count': '${controller.showingCount}',
                  'total': '${controller.totalResults}',
                }),
                child: Column(
                  children: [
                    CustomTextFormField(
                      hintText: 'analytics_search_campaign_client'.tr,
                      controller: controller.searchCtrl,
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Icon(
                          Icons.search,
                          size: 18.sp,
                          color: AppPalette.subtext,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 10.h,
                      ),
                    ),
                    10.h.verticalSpace,
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const _LoadingBlock();
                      }
                      return _TransactionList(items: controller.transactions);
                    }),
                    12.h.verticalSpace,
                    AppPaginationRow(
                      page: controller.page,
                      totalPages: controller.totalPages,
                      isLoading: controller.isLoading,
                      onPrev: controller.prevPage,
                      onNext: controller.nextPage,
                      pageLabel: 'analytics_page'.tr,
                      ofLabel: 'analytics_of'.tr,
                      nextLabel: 'analytics_next'.tr,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------- UI WIDGETS ----------------

class _SectionCard extends GetView<AnalyticsController> {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.border1, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppPalette.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => SortToggleChip(
                  isLowToHigh: controller.isSortLowToHigh.value,
                  onTap: controller.toggleSort,
                  lowToHighText: 'jobs_sort_low_to_high'.tr,
                  highToLowText: 'jobs_sort_high_to_low'.tr,
                ),
              ),
            ],
          ),
          2.h.verticalSpace,
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppPalette.subtext,
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          10.h.verticalSpace,
          child,
        ],
      ),
    );
  }
}

class _InfluencerTable extends StatelessWidget {
  final List<InfluencerRowModel> rows;

  const _InfluencerTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: 0.5),
      ),
      child: Column(
        children: [
          // header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppPalette.secondary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(kBorderRadius.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16.sp, color: AppPalette.white),
                      8.w.horizontalSpace,
                      Expanded(
                        child: Text(
                          'analytics_table_influencer'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppPalette.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 16.sp,
                        color: AppPalette.white,
                      ),
                      8.w.horizontalSpace,
                      Flexible(
                        child: Text(
                          'analytics_table_campaign_done'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppPalette.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // rows
          ListView.separated(
            itemCount: rows.length.clamp(0, 5),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Divider(height: 1, color: AppPalette.border1),
            ),
            itemBuilder: (_, i) {
              final r = rows[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: AppPalette.thirdColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppPalette.secondary,
                          width: kBorderWeight1,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 16.sp,
                        color: AppPalette.secondary,
                      ),
                    ),
                    10.w.horizontalSpace,
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppPalette.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    10.w.horizontalSpace,
                    SizedBox(
                      width: 50.w,
                      child: Text(
                        '${r.campaignDone}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: AppPalette.secondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlatformsCard extends GetView<AnalyticsController> {
  final List<PlatformStatModel> platforms;

  const _PlatformsCard({required this.platforms});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          10.h.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'analytics_section_platforms'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppPalette.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => SortToggleChip(
                  isLowToHigh: controller.isSortLowToHigh.value,
                  onTap: controller.toggleSort,
                  lowToHighText: 'jobs_sort_low_to_high'.tr,
                  highToLowText: 'jobs_sort_high_to_low'.tr,
                ),
              ),
            ],
          ),
          10.h.verticalSpace,
          GridView.builder(
            itemCount: platforms.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (_, i) => _PlatformTile(item: platforms[i]),
          ),
        ],
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final PlatformStatModel item;

  const _PlatformTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.jobsCompleted}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppPalette.secondary,
              fontSize: 26.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          2.h.verticalSpace,
          Text(
            'analytics_jobs_completed'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppPalette.subtext,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Image.asset(
                item.iconAsset,
                width: 20.w,
                fit: BoxFit.cover,
                color: AppPalette.secondary,
              ),
              8.w.horizontalSpace,
              Expanded(
                child: Text(
                  item.platformName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppPalette.black,
                    fontSize: 12.sp,
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
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> items;

  const _TransactionList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Text(
          'analytics_empty'.tr,
          style: TextStyle(color: AppPalette.subtext, fontSize: 12.sp),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length.clamp(0, 5), // ✅ was 10
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => 12.h.verticalSpace,
      itemBuilder: (_, i) => TransactionCard(item: items[i]),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          10.w.horizontalSpace,
          Text(
            'analytics_loading'.tr,
            style: TextStyle(color: AppPalette.subtext, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
