import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';
import 'package:influencer_app/core/widgets/custom_multi_select_drop_down_menu.dart';
import 'package:influencer_app/modules/brand/create_campaign/widgets/top_progress_section.dart';

import '../../../core/models/job_item.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import 'create_campaign_controller.dart';

class CreateCampaignStep2View extends GetView<CreateCampaignController> {
  const CreateCampaignStep2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.background,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => TopProgressSection(
                        onPrevious: controller.onPrevious,
                        stepText: controller.stepText,
                        progressPercentText: controller.progressPercentText,
                        progress: controller.progress,
                      ),
                    ),

                    18.h.verticalSpace,

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'create_campaign_step2_title'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    6.h.verticalSpace,
                    Text(
                      'create_campaign_step2_subtitle'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color: AppPalette.black,
                      ),
                    ),

                    18.h.verticalSpace,

                    Obx(() {
                      final type = controller.selectedType.value;

                      if (type == null) {
                        return _EmptyState(onBack: controller.onPrevious);
                      }

                      if (type == CampaignType.influencerPromotion) {
                        return _InfluencerPromotionStep2(
                          controller: controller,
                        );
                      }

                      return _PaidAdStep2(controller: controller);
                    }),

                    24.h.verticalSpace,
                  ],
                ),
              ),
            ),
          ),

          Obx(() => _bottomButtons()),
        ],
      ),
    );
  }

  Widget _bottomButtons() {
    final disabled = !controller.canGoNext;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        border: Border(
          top: BorderSide(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              btnText: 'common_previous'.tr,
              btnColor: AppPalette.white,
              borderColor: AppPalette.border1,
              textColor: AppPalette.black,
              onTap: controller.onPrevious,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: CustomButton(
              btnText: 'common_next'.tr,
              btnColor: disabled
                  ? AppPalette.defaultFill
                  : AppPalette.secondary,
              textColor: disabled ? AppPalette.greyText : AppPalette.white,
              borderColor: Colors.transparent,
              showBorder: false,
              isDisabled: disabled,
              onTap: controller.onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfluencerPromotionStep2 extends StatelessWidget {
  final CreateCampaignController controller;

  const _InfluencerPromotionStep2({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Product type
        Obx(() {
          return CustomDropDownMenu(
            title: 'create_campaign_product_type_label'.tr,
            titleTextStyle: AppTheme.textStyle.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
            hintText: 'create_campaign_product_type_label'.tr,
            options: controller.productTypeOptions,
            value: controller.selectedProductType.value,
            onChanged: (value) => controller.selectedProductType.value = value,
          );
        }),

        18.h.verticalSpace,

        /// Niche (multi)
        Obx(() {
          return CustomMultiSelectDropDownMenu(
            title: 'create_campaign_niche_label'.tr,
            titleTextStyle: AppTheme.textStyle.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
            hintText: 'create_campaign_niche_label'.tr,
            options: controller.nicheOptions,
            selectedValues: controller.selectedNiches.toList(),
            onChanged: (values) => controller.selectedNiches.value = values,
          );
        }),

        18.h.verticalSpace,

        /// Preferred influencers
        CustomTextFormField(
          title: 'create_campaign_preferred_influencers_label'.tr,
          titleTextStyle: AppTheme.textStyle.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
          hintText: 'create_campaign_preferred_influencers_hint'.tr,
          controller: controller.preferredInputCtrl,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              size: 20.sp,
              color: AppPalette.primary,
            ),
            onPressed: controller.commitPreferredInput,
          ),
          onChanged: controller.onPreferredTyping,
        ),
        Obx(() {
          final query = controller.preferredQuery.value;
          final suggestions = controller.preferredSuggestionsFiltered();
          if (query.trim().isEmpty || suggestions.isEmpty) {
            return const SizedBox.shrink();
          }
          return _SuggestionList(
            controller: controller.preferredSuggestionScroll,
            items: suggestions.map((e) => e.name).toList(growable: false),
            onTap: (name) {
              InfluencerUiModel? match;
              for (final item in suggestions) {
                if (item.name == name) {
                  match = item;
                  break;
                }
              }
              if (match != null) {
                controller.selectPreferredSuggestion(match);
              }
            },
          );
        }),
        12.h.verticalSpace,
        Obx(() {
          final items = controller.preferredInfluencers.toList();
          return _ChipBox(items: items, onRemove: controller.removePreferred);
        }),

        18.h.verticalSpace,

        /// Not preferred influencers
        CustomTextFormField(
          title: 'create_campaign_not_preferred_influencers_label'.tr,
          titleTextStyle: AppTheme.textStyle.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
          hintText: 'create_campaign_not_preferred_influencers_hint'.tr,
          controller: controller.notPreferredInputCtrl,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              size: 20.sp,
              color: AppPalette.primary,
            ),
            onPressed: controller.commitNotPreferredInput,
          ),
          onChanged: controller.onNotPreferredTyping,
        ),
        Obx(() {
          final query = controller.notPreferredQuery.value;
          final suggestions = controller.notPreferredSuggestionsFiltered();
          if (query.trim().isEmpty || suggestions.isEmpty) {
            return const SizedBox.shrink();
          }
          return _SuggestionList(
            controller: controller.notPreferredSuggestionScroll,
            items: suggestions.map((e) => e.name).toList(growable: false),
            onTap: (name) {
              InfluencerUiModel? match;
              for (final item in suggestions) {
                if (item.name == name) {
                  match = item;
                  break;
                }
              }
              if (match != null) {
                controller.selectNotPreferredSuggestion(match);
              }
            },
          );
        }),
        12.h.verticalSpace,
        Obx(() {
          final items = controller.notPreferredInfluencers.toList();
          return _ChipBox(
            items: items,
            onRemove: controller.removeNotPreferred,
          );
        }),
      ],
    );
  }
}

class _PaidAdStep2 extends StatelessWidget {
  final CreateCampaignController controller;

  const _PaidAdStep2({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Niche dropdown ──
        Obx(() {
          final value = controller.selectedPaidAdNiche.value;
          return CustomDropDownMenu(
            title: 'create_campaign_niche_label'.tr,
            titleTextStyle: AppTheme.textStyle.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
            hintText: 'create_campaign_niche_hint'.tr,
            options: controller.nicheOptions,
            value: value,
            onChanged: controller.onPaidAdNicheChanged,
          );
        }),

        18.h.verticalSpace,

        // ── Recommended agencies (horizontal scroll with auto-pagination) ──
        Obx(() {
          final items = controller.recommendedAgencies.toList();
          final selectedIds = controller.selectedAgencyIds.toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'create_campaign_recommended_agencies_label'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              12.h.verticalSpace,
              SizedBox(
                height: 120.h,
                child: ListView.separated(
                  controller: controller.recommendedAgencyScroll,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => 12.w.horizontalSpace,
                  itemBuilder: (_, i) {
                    final a = items[i];
                    final selected = selectedIds.contains(a.id);
                    return _AgencySquareCard(
                      name: a.name,
                      subtitle: a.subtitle,
                      selected: selected,
                      onTap: () => controller.toggleAgencySelection(a),
                    );
                  },
                ),
              ),
              18.h.verticalSpace,
            ],
          );
        }),

        // ── Other agencies (vertical scroll with auto-pagination) ──
        Obx(() {
          final items = controller.otherAgencies.toList();
          final selectedIds = controller.selectedAgencyIds.toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'create_campaign_other_agencies_label'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              12.h.verticalSpace,
              SizedBox(
                height: 280.h,
                child: ListView.separated(
                  controller: controller.otherAgencyScroll,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => 12.h.verticalSpace,
                  itemBuilder: (_, i) {
                    final a = items[i];
                    final selected = selectedIds.contains(a.id);
                    return _AgencyWideCard(
                      name: a.name,
                      subtitle: a.subtitle,
                      selected: selected,
                      onTap: () => controller.toggleAgencySelection(a),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _ChipBox extends StatelessWidget {
  final List<String> items;
  final void Function(String) onRemove;

  const _ChipBox({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: items.isEmpty
          ? Text(
              'create_campaign_chip_empty'.tr,
              style: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
            )
          : Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: items.map((name) {
                return Container(
                  constraints: BoxConstraints(maxWidth: 160.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.thirdColor,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppPalette.primary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      8.w.horizontalSpace,
                      GestureDetector(
                        onTap: () => onRemove(name),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: AppPalette.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final ScrollController? controller;
  final List<String> items;
  final void Function(String) onTap;

  const _SuggestionList({
    this.controller,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: SizedBox(
        height: 200.h,
        child: ListView.separated(
          controller: controller,
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: AppPalette.border1),
          itemBuilder: (_, i) {
            final name = items[i];
            return ListTile(
              dense: true,
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, color: AppPalette.black),
              ),
              onTap: () => onTap(name),
            );
          },
        ),
      ),
    );
  }
}

class _AgencySquareCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AgencySquareCard({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? LinearGradient(
            colors: [AppPalette.secondary, AppPalette.gradient1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPalette.secondary.withAlpha(230),
              AppPalette.gradient1.withAlpha(230),
            ],
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 140.w,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: selected ? AppPalette.secondary : Colors.transparent,
            width: selected ? 2 : 1,
          ),
          gradient: bg,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppPalette.defaultFill.withAlpha(220),
                    ),
                  ),
                ),
                5.h.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textStyle.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.thirdColor,
                    ),
                  ),
                ),
                2.h.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w300,
                      color: AppPalette.white.withAlpha(220),
                    ),
                  ),
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppPalette.white,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14.sp,
                    color: AppPalette.secondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AgencyWideCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AgencyWideCard({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? LinearGradient(
            colors: [AppPalette.secondary, AppPalette.gradient1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPalette.secondary.withAlpha(230),
              AppPalette.gradient1.withAlpha(230),
            ],
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: bg,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: selected ? AppPalette.secondary : Colors.transparent,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.defaultFill.withAlpha(220),
              ),
            ),
            14.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textStyle.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.thirdColor,
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w300,
                      color: AppPalette.thirdColor,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.white,
                ),
                child: Icon(
                  Icons.check,
                  size: 16.sp,
                  color: AppPalette.secondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'create_campaign_step2_missing_type'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppPalette.black),
            ),
            14.h.verticalSpace,
            CustomButton(
              btnText: 'common_previous'.tr,
              onTap: onBack,
              btnColor: AppPalette.secondary,
              borderColor: Colors.transparent,
              showBorder: false,
              textColor: AppPalette.white,
            ),
          ],
        ),
      ),
    );
  }
}
