import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_pagination_row.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/sort_toggle_chip.dart';
import '../../../core/widgets/transaction_card.dart';
import 'analytics_controller.dart';
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
            _SectionCard(
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
                    nextLabel: 'analytics_next'.tr,
                  ),
                ],
              ),
            ),
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
