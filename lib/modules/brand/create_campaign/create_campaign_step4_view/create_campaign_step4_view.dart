// lib/modules/brand/create_campaign/create_campaign_step4_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../create_campaign_controller.dart';

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
                    _progressSectionWithBack(),

                    18.h.verticalSpace,

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'create_campaign_step4_title'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
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
                      'create_campaign_step4_subtitle'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color: AppPalette.black,
                      ),
                    ),

                    17.h.verticalSpace,

                    Text(
                      'create_campaign_step4_suggestions'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),

                    11.h.verticalSpace,

                    SizedBox(
                      height: 38.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.budgetSuggestions.length,
                        separatorBuilder: (_, __) => 10.w.horizontalSpace,
                        itemBuilder: (_, i) {
                          final v = controller.budgetSuggestions[i];
                          return _SuggestionChip(
                            text: '৳ ${_fmtInt(v)}',
                            onTap: () => controller.setBudgetFromSuggestion(v),
                          );
                        },
                      ),
                    ),

                    17.h.verticalSpace,

                    Text(
                      'create_campaign_step4_enter_budget'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),

                    5.h.verticalSpace,

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

                    7.h.verticalSpace,

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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    8.h.verticalSpace,
                    Obx(() {
                      return Text(
                        '৳ ${controller.totalBudgetText}',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.primary.withAlpha(210),
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

  Widget _progressSectionWithBack() {
    return Obx(() {
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
    });
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '৳',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.secondary,
                ),
              ),
              8.w.horizontalSpace,
              Expanded(
                child: TextField(
                  controller: controller.budgetTextCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
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
              '${'create_campaign_step4_min'.tr}: ৳ ${_fmtInt(controller.minBudget)}',
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
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: AppPalette.defaultFill.withAlpha(140),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.primary.withAlpha(90), width: 1),
      ),
      child: Column(
        children: [

          _quoteRow('create_campaign_step4_base'.tr, '৳$base'),

          8.h.verticalSpace,

          _quoteRow(
            'create_campaign_step4_vat'.tr.replaceAll('{p}', '$vatPercent'),
            '৳$vat',
          ),
          10.h.verticalSpace,
          Divider(color: AppPalette.primary.withAlpha(90), height: 1),
          10.h.verticalSpace,
          _quoteRow('create_campaign_step4_total'.tr, '৳$total',),
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
            fontWeight: FontWeight.w500,
            color: AppPalette.primary,
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

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: controller.toggleMilestonesExpanded,
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18.sp,
                    color: AppPalette.primary,
                  ),
                  10.w.horizontalSpace,
                  Expanded(
                    child: Text(
                      'create_campaign_step4_milestones'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22.sp,
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
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _MilestoneCard(
                    index: i + 1,
                    title: m.title,
                    subtitle: m.subtitle ?? '',
                    dayLabel: m.dayLabel ?? '',
                  ),
                );
              }),

              Obx(() {
                if (!controller.isAddingMilestone.value) {
                  return _AddAnotherMilestoneButton(
                    onTap: controller.startAddMilestone,
                  );
                }
                return _MilestoneEditorCard(controller: controller);
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

  const _MilestoneCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.dayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.primary.withAlpha(90), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.primary.withAlpha(180),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppPalette.white,
                fontWeight: FontWeight.w700,
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primary,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AppPalette.greyText),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          Text(
            dayLabel,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary.withAlpha(170),
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
    );
  }
}

class _MilestoneEditorCard extends StatelessWidget {
  final CreateCampaignController controller;
  const _MilestoneEditorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final idx = controller.milestones.length + 1;

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
                width: 26.w,
                height: 26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppPalette.primary.withAlpha(180),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$idx',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.white,
                    fontWeight: FontWeight.w700,
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
                  color: AppPalette.primary,
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
            final v = controller.selectedMilestonePlatform.value;
            return _SelectField(
              text: v ?? 'create_campaign_step4_milestone_platform_hint'.tr,
              isPlaceholder: v == null,
              onTap: controller.openPlatformPicker,
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
            final d = controller.selectedMilestoneDay.value;
            return _SelectField(
              text: d == null
                  ? 'create_campaign_step4_milestone_day_hint'.tr
                  : 'DAY $d',
              isPlaceholder: d == null,
              onTap: controller.openDayPicker,
            );
          }),

          14.h.verticalSpace,

          Row(
            children: [
              Icon(
                Icons.query_stats_rounded,
                size: 18.sp,
                color: AppPalette.primary,
              ),
              8.w.horizontalSpace,
              Text(
                'create_campaign_step4_promo_target'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
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
                  label: 'create_campaign_step4_reach'.tr,
                  controller: controller.reachCtrl,
                ),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: _MiniMetricField(
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
                  label: 'create_campaign_step4_likes'.tr,
                  controller: controller.likesCtrl,
                ),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: _MiniMetricField(
                  label: 'create_campaign_step4_comments'.tr,
                  controller: controller.commentsCtrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetricField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _MiniMetricField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        8.h.verticalSpace,
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            filled: true,
            fillColor: AppPalette.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppPalette.primary.withAlpha(140),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddAnotherMilestoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAnotherMilestoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppPalette.primary.withAlpha(120),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Text(
            'create_campaign_step4_add_milestone'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary.withAlpha(190),
            ),
          ),
        ),
      ),
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppPalette.defaultFill.withAlpha(160),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: AppPalette.primary.withAlpha(120),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary.withAlpha(190),
            ),
          ),
        ),
      ),
    );
  }
}

String _fmtInt(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i;
    b.write(s[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) b.write(',');
  }
  return b.toString();
}
