// lib/modules/brand/create_campaign/create_campaign_step4_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step4_view/widgets/quote_card.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step4_view/widgets/suggestion_chip.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../create_campaign_controller.dart';
import 'widgets/milestones_section.dart';

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
                          return SuggestionChip(
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
                      return QuoteCard(
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

                    Obx(() {
                      return Text(
                        '৳ ${controller.totalBudgetText}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.secondary,
                        ),
                      );
                    }),

                    18.h.verticalSpace,

                    MilestonesSection(controller: controller),

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
