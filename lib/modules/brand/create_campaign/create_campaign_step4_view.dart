// lib/modules/brand/create_campaign/create_campaign_step4_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import 'create_campaign_controller.dart';
import 'widgets/top_progress_section.dart';

class CreateCampaignStep4View extends GetView<CreateCampaignController> {
  const CreateCampaignStep4View({super.key});

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

                    Text(
                      'create_campaign_step4_title'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    6.h.verticalSpace,
                    Text(
                      'create_campaign_step4_subtitle'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color: AppPalette.black,
                      ),
                    ),

                    18.h.verticalSpace,

                    Text(
                      'create_campaign_step4_suggestions'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    10.h.verticalSpace,
                    SizedBox(
                      height: 30.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.budgetSuggestions.length,
                        separatorBuilder: (_, _) => 10.w.horizontalSpace,
                        itemBuilder: (_, i) {
                          final v = controller.budgetSuggestions[i];
                          return _SuggestionChip(
                            text: formatCurrencyByLocale(v),
                            onTap: () => controller.setBudgetFromSuggestion(v),
                          );
                        },
                      ),
                    ),

                    18.h.verticalSpace,

                    Text(
                      'create_campaign_step4_enter_budget'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    10.h.verticalSpace,
                    _BudgetInputCard(controller: controller),

                    18.h.verticalSpace,

                    Text(
                      'create_campaign_step4_quote'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    10.h.verticalSpace,
                    Obx(() {
                      return _QuoteCard(
                        base: controller.baseBudgetText,
                        vat: controller.vatAmountText,
                        total: controller.totalBudgetText,
                        vatPercent: (controller.vatPercent * 100).round(),
                      );
                    }),

                    18.h.verticalSpace,

                    Text(
                      'create_campaign_step4_net_payable'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    8.h.verticalSpace,
                    Obx(() {
                      return Text(
                        controller.totalBudgetText,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.secondary,
                        ),
                      );
                    }),

                    18.h.verticalSpace,

                    _MilestonesSection(controller: controller),

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

class _BudgetInputCard extends StatelessWidget {
  final CreateCampaignController controller;
  const _BudgetInputCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 34.h,
        bottom: 12.h,
        right: 14.w,
        left: 14.w,
      ),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.budgetTextCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.secondary.withAlpha(210),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                  onChanged: controller.onBudgetTextChanged,
                ),
              ),
            ],
          ),
          6.h.verticalSpace,
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${'create_campaign_step4_min'.tr}: ${formatCurrencyByLocale(controller.minBudget)}',
              style: TextStyle(fontSize: 11.sp, color: AppPalette.greyText),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String base;
  final String vat;
  final String total;
  final int vatPercent;

  const _QuoteCard({
    required this.base,
    required this.vat,
    required this.total,
    required this.vatPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.thirdColor, AppPalette.white],
        ),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.secondary, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          _quoteRow('create_campaign_step4_base'.tr, base),
          8.h.verticalSpace,
          _quoteRow(
            'create_campaign_step4_vat'.tr.replaceAll('{p}', '$vatPercent'),
            vat,
          ),
          10.h.verticalSpace,
          Divider(color: AppPalette.primary.withAlpha(90), height: 1),
          10.h.verticalSpace,
          _quoteRow('create_campaign_step4_total'.tr, total),
        ],
      ),
    );
  }

  Widget _quoteRow(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w300,
              color: AppPalette.black,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w300,
            color: AppPalette.secondary,
          ),
        ),
      ],
    );
  }
}

class _MilestonesSection extends StatelessWidget {
  final CreateCampaignController controller;
  const _MilestonesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.milestonesExpanded.value;
      final list = controller.milestones.toList(growable: false);
      final editIndex = controller.editingMilestoneIndex.value;

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: controller.toggleMilestonesExpanded,
              child: Row(
                children: [
                  Image.asset('assets/icons/mission.png', width: 23.w),
                  10.w.horizontalSpace,
                  Expanded(
                    child: Text(
                      'create_campaign_step4_milestones'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 30.sp,
                    color: AppPalette.primary,
                  ),
                ],
              ),
            ),
            if (!expanded) const SizedBox.shrink(),
            if (expanded) ...[
              12.h.verticalSpace,

              ...List.generate(list.length, (i) {
                final m = list[i];

                // If this milestone is being edited, show the editor in its place
                if (editIndex == i && controller.isAddingMilestone.value) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _MilestoneEditorCard(controller: controller),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _MilestoneCard(
                    index: i + 1,
                    title: m.title,
                    subtitle: m.subtitle ?? '',
                    dayLabel: m.dayLabel ?? '',
                    onTap: controller.isAddingMilestone.value
                        ? null
                        : () => controller.startEditMilestone(i),
                  ),
                );
              }),

              // Show "Add" button or editor for NEW milestones only (not editing)
              Obx(() {
                if (!controller.isAddingMilestone.value) {
                  return CustomButton.dotted(
                    btnText: 'create_campaign_step4_add_milestone'.tr,
                    textStyle: AppTheme.textStyle.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.secondary,
                    ),
                    onTap: controller.startAddMilestone,
                    btnColor: AppPalette.white,
                    height: 95.h,
                    width: double.infinity,
                  );
                }
                // Show editor at bottom only when adding NEW (editIndex == null)
                if (controller.editingMilestoneIndex.value == null) {
                  return _MilestoneEditorCard(controller: controller);
                }
                return const SizedBox.shrink();
              }),
            ],
          ],
        ),
      );
    });
  }
}

class _MilestoneCard extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String dayLabel;
  final VoidCallback? onTap;

  const _MilestoneCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.dayLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: AppPalette.secondary,
            width: kBorderWidth0_5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.h,
              height: 20.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppPalette.secondary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppPalette.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            10.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.greyText,
                    ),
                  ),
                ],
              ),
            ),
            10.w.horizontalSpace,
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.secondary,
              ),
            ),
            6.w.horizontalSpace,
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: AppPalette.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneEditorCard extends StatelessWidget {
  final CreateCampaignController controller;
  const _MilestoneEditorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final editIndex = controller.editingMilestoneIndex.value;
    final idx = editIndex != null
        ? editIndex + 1
        : controller.milestones.length + 1;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.primary.withAlpha(90), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 20.h,
                height: 20.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppPalette.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$idx',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppPalette.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                splashRadius: 20.r,
                onPressed: controller.saveMilestone,
                icon: Icon(
                  Icons.check_rounded,
                  color: AppPalette.primary,
                  size: 22.sp,
                ),
              ),
              IconButton(
                splashRadius: 20.r,
                onPressed: controller.closeMilestoneEditor,
                icon: Icon(
                  Icons.close_rounded,
                  color: editIndex != null ? Colors.red : AppPalette.primary,
                  size: 22.sp,
                ),
              ),
            ],
          ),

          10.h.verticalSpace,

          CustomTextFormField(
            hintText: 'create_campaign_step4_milestone_title_hint'.tr,
            controller: controller.milestoneTitleCtrl,
            textInputAction: TextInputAction.next,
          ),
          10.h.verticalSpace,

          Obx(() {
            return CustomDropDownMenu(
              hintText: 'create_campaign_step4_milestone_platform_hint'.tr,
              options: controller.platformOptions,
              value: controller.selectedMilestonePlatform.value,
              onChanged: (value) {
                controller.selectedMilestonePlatform.value = value;
              },
              fillColor: AppPalette.white,
            );
          }),

          10.h.verticalSpace,

          CustomTextFormField(
            hintText: 'create_campaign_step4_milestone_deliverable_hint'.tr,
            controller: controller.milestoneDeliverableCtrl,
            textInputAction: TextInputAction.next,
          ),
          10.h.verticalSpace,

          Obx(() {
            final opts = controller.milestoneDayOptions
                .map((d) => 'DAY $d')
                .toList();
            final selected = controller.selectedMilestoneDay.value == null
                ? null
                : 'DAY ${controller.selectedMilestoneDay.value}';
            return CustomDropDownMenu(
              hintText: 'create_campaign_step4_milestone_day_hint'.tr,
              options: opts,
              value: selected,
              onChanged: (value) {
                final n = int.tryParse(
                  (value ?? '1').replaceAll(RegExp(r'[^0-9]'), ''),
                );
                controller.selectedMilestoneDay.value = n;
              },
              fillColor: AppPalette.white,
            );
          }),

          14.h.verticalSpace,

          Row(
            children: [
              Image.asset('assets/icons/increase.png', width: 20.w),
              8.w.horizontalSpace,
              Text(
                'create_campaign_step4_promo_target'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),
          10.h.verticalSpace,

          Row(
            children: [
              Expanded(
                child: _MiniMetricField(
                  iconPath: 'assets/icons/eye.png',
                  label: 'create_campaign_step4_reach'.tr,
                  controller: controller.reachCtrl,
                ),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: _MiniMetricField(
                  iconPath: 'assets/icons/play.png',
                  label: 'create_campaign_step4_views'.tr,
                  controller: controller.viewsCtrl,
                ),
              ),
            ],
          ),
          12.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _MiniMetricField(
                  iconPath: 'assets/icons/love.png',
                  label: 'create_campaign_step4_likes'.tr,
                  controller: controller.likesCtrl,
                ),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: _MiniMetricField(
                  iconPath: 'assets/icons/speech_bubble.png',
                  label: 'create_campaign_step4_comments'.tr,
                  controller: controller.commentsCtrl,
                ),
              ),
            ],
          ),

          if (controller.selectedType.value == CampaignType.paidAd) ...[
            10.h.verticalSpace,
            Row(
              children: [
                Image.asset('assets/icons/increase.png', width: 20.w),
                8.w.horizontalSpace,
                Text(
                  'create_campaign_step4_promo_goal'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
              ],
            ),
            10.h.verticalSpace,
            CustomTextFormField(
              hintText: 'create_campaign_step4_promo_goal_hint'.tr,
              maxLines: 4,
              controller: controller.promoGoalCtrl,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniMetricField extends StatelessWidget {
  final String iconPath;
  final String label;
  final TextEditingController controller;

  const _MiniMetricField({
    required this.label,
    required this.controller,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(iconPath, width: 15.w, color: AppPalette.black),
            5.w.horizontalSpace,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        8.h.verticalSpace,
        CustomTextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          hintText: '0',
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 12.h,
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.5.h),
        decoration: BoxDecoration(
          color: AppPalette.thirdColor,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: AppPalette.secondary, width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppPalette.primary.withAlpha(190),
            ),
          ),
        ),
      ),
    );
  }
}
