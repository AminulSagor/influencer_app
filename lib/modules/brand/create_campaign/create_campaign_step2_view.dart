// lib/modules/brand/create_campaign/create_campaign_step2_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
                    /// ✅ Progress reads Rx -> MUST be inside Obx
                    Obx(() => _progressSectionWithBack()),

                    18.h.verticalSpace,

                    /// Title + Save as draft (no Rx needed)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'create_campaign_step2_title'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.primary,
                            ),
                          ),
                        ),
                        12.w.horizontalSpace,
                        CustomButton(
                          height: 34.h,
                          width: 132.w,
                          borderRadius: 999,
                          btnColor: AppPalette.secondary,
                          borderColor: Colors.transparent,
                          showBorder: false,
                          textColor: AppPalette.white,
                          btnText: 'create_campaign_save_draft'.tr,
                          onTap: controller.saveAsDraft,
                        ),
                      ],
                    ),
                    6.h.verticalSpace,
                    Text(
                      'create_campaign_step2_subtitle'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                        color: AppPalette.greyText,
                      ),
                    ),

                    18.h.verticalSpace,

                    /// ✅ Body switches by type -> Obx required
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

          /// ✅ Bottom buttons depend on Rx -> Obx required
          Obx(() => _bottomButtons()),
        ],
      ),
    );
  }

  Widget _progressSectionWithBack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(999.r),
              onTap: controller.onPrevious,
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: AppPalette.black,
                ),
              ),
            ),
            6.w.horizontalSpace,
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  controller.stepText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.black,
                  ),
                ),
              ),
            ),
            Text(
              controller.progressPercentText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.black,
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: controller.progress,
            minHeight: 10.h,
            backgroundColor: AppPalette.defaultFill,
            color: AppPalette.primary,
          ),
        ),
      ],
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
        Text(
          'create_campaign_product_type_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,
        Obx(() {
          final value = controller.selectedProductType.value; // ✅ reads Rx
          return _SelectField(
            text: value ?? 'create_campaign_product_type_hint'.tr,
            isPlaceholder: value == null,
            onTap: controller.openProductTypePicker,
          );
        }),

        18.h.verticalSpace,

        /// Niche (multi)
        Text(
          'create_campaign_niche_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,
        Obx(() {
          final selected = controller.selectedNiches.toList(); // ✅ IMPORTANT
          final text = selected.isEmpty
              ? 'create_campaign_niche_hint'.tr
              : selected.join(', ');
          return _SelectField(
            text: text,
            isPlaceholder: selected.isEmpty,
            onTap: controller.openNichePicker,
          );
        }),

        18.h.verticalSpace,

        /// Preferred influencers
        Text(
          'create_campaign_preferred_influencers_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,
        CustomTextFormField(
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
        12.h.verticalSpace,
        Obx(() {
          final items = controller.preferredInfluencers.toList(); // ✅ IMPORTANT
          return _ChipBox(items: items, onRemove: controller.removePreferred);
        }),

        18.h.verticalSpace,

        /// Not preferred influencers
        Text(
          'create_campaign_not_preferred_influencers_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,
        CustomTextFormField(
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
        12.h.verticalSpace,
        Obx(() {
          final items = controller.notPreferredInfluencers
              .toList(); // ✅ IMPORTANT
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
        /// Paid Ad Niche (single)
        Text(
          'create_campaign_niche_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,
        Obx(() {
          final value = controller.selectedPaidAdNiche.value; // ✅ reads Rx
          return _SelectField(
            text: value ?? 'create_campaign_niche_hint'.tr,
            isPlaceholder: value == null,
            onTap: controller.openPaidAdNichePicker,
          );
        }),

        18.h.verticalSpace,

        /// Recommended agencies
        Text(
          'create_campaign_recommended_agencies_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        12.h.verticalSpace,
        SizedBox(
          height: 145.h,
          child: Obx(() {
            final items = controller.recommendedAgencies
                .toList(); // ✅ IMPORTANT
            final selectedName =
                controller.selectedAgencyName.value; // ✅ reads Rx
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => 12.w.horizontalSpace,
              itemBuilder: (_, i) {
                final a = items[i];
                final selected = selectedName == a.name;
                return _AgencySquareCard(
                  name: a.name,
                  subtitle: a.subtitle,
                  selected: selected,
                  onTap: () => controller.selectAgency(a.name),
                );
              },
            );
          }),
        ),

        18.h.verticalSpace,

        /// Other agencies (vertical)
        Text(
          'create_campaign_other_agencies_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        12.h.verticalSpace,
        Obx(() {
          final items = controller.otherAgencies.toList(); // ✅ IMPORTANT
          final selectedName =
              controller.selectedAgencyName.value; // ✅ reads Rx
          return Column(
            children: items.map((a) {
              final selected = selectedName == a.name;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _AgencyWideCard(
                  name: a.name,
                  subtitle: a.subtitle,
                  selected: selected,
                  onTap: () => controller.selectAgency(a.name),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  final String text;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _SelectField({
    required this.text,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isPlaceholder ? AppPalette.subtext : AppPalette.black,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22.sp,
              color: AppPalette.black,
            ),
          ],
        ),
      ),
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
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.defaultFill,
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
                            fontSize: 12.sp,
                            color: AppPalette.primary,
                            fontWeight: FontWeight.w500,
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
        ? AppPalette.primary
        : AppPalette.primary.withAlpha(210);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 140.w,
        height: 145.h,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppPalette.secondary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.defaultFill.withAlpha(220),
                ),
              ),
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.white,
                letterSpacing: -0.2,
              ),
            ),
            2.h.verticalSpace,
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.white.withAlpha(220),
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
        ? AppPalette.primary
        : AppPalette.primary.withAlpha(210);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppPalette.secondary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58.w,
              height: 58.w,
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
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                      color: AppPalette.white.withAlpha(220),
                    ),
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
