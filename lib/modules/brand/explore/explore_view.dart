import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_pagination_row.dart';
import '../../../core/widgets/app_pill_tabs.dart';
import 'explore_controller.dart';
import 'models/explore_item.dart';
import 'widgets/explore_list_item.dart';
import 'widgets/explore_pagination.dart';
import 'widgets/explore_tabs.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'explore_title'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.black,
              ),
            ),
            4.h.verticalSpace,
            Text(
              'explore_subtitle'.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.black,
              ),
            ),
            12.h.verticalSpace,

            Obx(
              () => AppPillTabs<ExploreType>(
                selected: controller.selectedType.value,
                onChanged: controller.changeType,
                items: [
                  AppPillTabItem(
                    value: ExploreType.influencer,
                    label: 'explore_tab_influencers'.tr,
                  ),
                  AppPillTabItem(
                    value: ExploreType.adAgency,
                    label: 'explore_tab_ad_agencies'.tr,
                  ),
                ],
              ),
            ),
            12.h.verticalSpace,

            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: AppPalette.white,
                  borderRadius: BorderRadius.circular(kBorderRadius.r),
                  border: Border.all(color: AppPalette.border1),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // Search
                    CustomTextFormField(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18.sp,
                        color: AppPalette.subtext,
                      ),
                      fillColor: AppPalette.white,
                      hintText: 'explore_search_hint'.tr,
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                    ),
                    8.h.verticalSpace,

                    Obx(() {
                      final showing = controller.items.length;
                      final total = controller.totalResults.value;
                      return Text(
                        'explore_showing'.trParams({
                          'showing': '$showing',
                          'total': '$total',
                        }),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppPalette.subtext,
                        ),
                      );
                    }),
                    10.h.verticalSpace,

                    // List inside a rounded card like screenshot
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.items.isEmpty) {
                          return Center(
                            child: Text(
                              'explore_empty'.tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppPalette.subtext,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.items.length,
                          separatorBuilder: (_, __) => 10.h.verticalSpace,
                          itemBuilder: (_, index) {
                            final item = controller.items[index];
                            return ExploreListItem(item: item);
                          },
                        );
                      }),
                    ),

                    12.h.verticalSpace,
                    AppPaginationRow(
                      page: controller.currentPage,
                      totalPages: controller.totalPages,
                      isLoading: controller.isLoading,
                      onPrev: controller.prevPage,
                      onNext: controller.nextPage,
                      pageLabel: 'explore_page'.tr,
                      ofLabel: 'explore_of'.tr,
                      nextLabel: 'explore_next'.tr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
