import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/models/job_item.dart';
import 'brand_campaign_details_controller.dart';

class BrandCampaignDetailsView extends GetView<BrandCampaignDetailsController> {
  const BrandCampaignDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CampaignDetailsCard(),
                12.h.verticalSpace,

                // ✅ Show agency quotations tab if bids exist (any campaign type)
                Obx(() {
                  controller.campaignType.value;
                  final isPaidAd = controller.isPaidAd;
                  final showAgencyTabs = controller.agencyOffers.isNotEmpty;

                  Widget detailsColumn() {
                    return Column(
                      children: [
                        _CampaignProgressCard(),
                        12.h.verticalSpace,
                        _MilestonesCard(),
                        14.h.verticalSpace,
                        _RatingCard(),
                        12.h.verticalSpace,
                        _BriefCard(),
                        12.h.verticalSpace,
                        _ContentAssetsCard(),
                        12.h.verticalSpace,
                        _TermsCard(),
                        if (isPaidAd) ...[
                          12.h.verticalSpace,
                          _BrandAssetsCard(),
                        ],
                      ],
                    );
                  }

                  if (!showAgencyTabs) {
                    return detailsColumn();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PaidAdTabPills(),
                      12.h.verticalSpace,

                      Obx(() {
                        final tab = controller.paidAdTabIndex.value;

                        // 0 = Agency bids
                        if (tab == 0) return _AgencyBidsTab();

                        // 1 = Campaign details
                        return detailsColumn();
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- COMMON CARD ----------------

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _CardShell({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: child,
    );
  }
}

/// ---------------- CAMPAIGN DETAILS CARD ----------------

class _CampaignDetailsCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.black12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.gradient1, AppPalette.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              InkWell(
                onTap: () => Get.back(id: 1),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
              ),
              10.w.horizontalSpace,
              Expanded(
                child: Text(
                  'brand_campaign_details_campaign_details'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.textStyle.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          10.h.verticalSpace,

          // Campaign name + amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/icons/online_ads.png',
                width: 28.w,
                height: 28.w,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.campaignTitle.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      formatCurrencyByLocale(controller.totalCost),
                      style: TextStyle(
                        color: AppPalette.thirdColor,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.h.verticalSpace,

          // ✅ PaidAd: Targeting row | other: Influencers row
          Obx(() {
            controller.campaignType.value;
            final isAgencyAccepet = controller.isAgencyAccepet;
            if (isAgencyAccepet) {
              return Row(
                children: [
                  Text(
                    'brand_campaign_details_agency'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  10.w.horizontalSpace,
                  _Chip(text: controller.job?.clientName ?? 'Unknown'),
                ],
              );
            }

            if (controller.isPaidAd) return SizedBox.shrink();

            return Row(
              children: [
                Text(
                  'brand_campaign_details_influencers'.tr,
                  style: TextStyle(
                    color: AppPalette.thirdColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                10.w.horizontalSpace,
                Expanded(
                  child: Obx(() {
                    final list = controller.influencers.toList(growable: false);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: list
                            .map((name) => _Chip(text: name))
                            .toList(),
                      ),
                    );
                  }),
                ),
              ],
            );
          }),

          10.h.verticalSpace,
          Divider(color: AppPalette.thirdColor.withAlpha(150), height: 1),
          10.h.verticalSpace,

          // Platforms
          Row(
            children: [
              Text(
                'brand_campaign_details_platforms'.tr,
                style: TextStyle(
                  color: AppPalette.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              10.w.horizontalSpace,
              Obx(() {
                return Row(
                  children: controller.platformsImagePath
                      .map(
                        (ic) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _MiniPlatform(iconPath: ic),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
          12.h.verticalSpace,

          // Deadline box
          Obx(() {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadius.r),
                gradient: const LinearGradient(
                  colors: [AppPalette.secondary, AppPalette.gradient1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppPalette.border1,
                  width: kBorderWeight1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'campaign_deadline'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${controller.daysRemaining.value} ${'brand_campaign_details_days_remaining'.tr}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 14.sp,
                        color: AppPalette.thirdColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        controller.deadlineDateText.value,
                        style: TextStyle(
                          color: AppPalette.thirdColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          10.h.verticalSpace,
          Align(
            alignment: Alignment.center,
            child: Obx(() {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadius.r),
                  border: Border.all(
                    color: AppPalette.secondary,
                    width: kBorderWidth0_5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppPalette.white, AppPalette.thirdColor],
                  ),
                ),
                child: Text(
                  controller.budgetStatusText.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppPalette.secondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppPalette.thirdColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.textStyle.copyWith(
          color: AppPalette.primary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _MiniPlatform extends StatelessWidget {
  final String iconPath;
  const _MiniPlatform({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(iconPath, width: 24.w, height: 24.w, fit: BoxFit.cover);
  }
}

/// ---------------- CAMPAIGN PROGRESS ----------------

class _CampaignProgressCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            iconPath: 'assets/icons/goal.png',
            title: 'brand_campaign_details_campaign_progress'.tr,
          ),
          12.h.verticalSpace,
          Obx(() {
            final current = controller.progressStep.value;

            bool isActive(CampaignProgressStep step) {
              // submitted always true in UI
              if (step == CampaignProgressStep.submitted) return true;
              return current.index >= step.index;
            }

            return Column(
              children: [
                _ProgressRow(
                  icon: Icons.check_circle_rounded,
                  title: 'brand_campaign_details_submitted'.tr,
                  subtitle: 'brand_campaign_details_submitted_sub'.tr,
                  active: isActive(CampaignProgressStep.submitted),
                ),
                _ProgressRow(
                  icon: Icons.format_quote_rounded,
                  title: 'brand_campaign_details_quoted'.tr,
                  subtitle: 'brand_campaign_details_quoted_sub'.tr,
                  active: isActive(CampaignProgressStep.quoted),
                ),
                _ProgressRow(
                  icon: Icons.payments_rounded,
                  title: 'brand_campaign_details_paid'.tr,
                  subtitle: 'brand_campaign_details_paid_sub'.tr,
                  active: isActive(CampaignProgressStep.paid),
                ),
                _ProgressRow(
                  icon: Icons.campaign_rounded,
                  title: 'brand_campaign_details_promoting'.tr,
                  subtitle: 'brand_campaign_details_promoting_sub'.tr,
                  active: isActive(CampaignProgressStep.promoting),
                ),
                30.h.horizontalSpace,
                _ProgressRow(
                  icon: Icons.task_alt_rounded,
                  title: 'brand_campaign_details_completed'.tr,
                  subtitle: 'brand_campaign_details_completed_sub'.tr,
                  active: isActive(CampaignProgressStep.completed),
                ),
                _QuoteDetailsCard(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;

  const _ProgressRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = active ? AppPalette.primary : AppPalette.greyText;
    final subColor = active
        ? AppPalette.greyText
        : AppPalette.greyText.withOpacity(.75);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: active ? AppPalette.primary : AppPalette.border1,
            size: 18.sp,
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
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: titleColor,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w400,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- QUOTE DETAILS ----------------
/// (unchanged – kept your existing UI)

class _QuoteDetailsCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _CardTitle(
                  title: 'brand_campaign_details_quote_details'.tr,
                ),
              ),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: AppPalette.thirdColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '৳',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF315719),
                  ),
                ),
              ),
            ],
          ),
          12.h.verticalSpace,
          Obx(() {
            final showDue =
                controller.showDueButton.value && !controller.isPendingAgency;
            final amountColor = !showDue
                ? AppPalette.secondary
                : AppPalette.subtext;
            return Column(
              children: [
                _KVRow(
                  k: 'brand_campaign_details_base_campaign_budget'.tr,
                  v: formatCurrencyByLocale(controller.baseBudget.value),
                  amountColor: amountColor,
                ),
                6.h.verticalSpace,
                _KVRow(
                  k: 'brand_campaign_details_vat_tax'.tr,
                  v: formatCurrencyByLocale(controller.vatAmount.value),
                  amountColor: amountColor,
                ),
                10.h.verticalSpace,
                Divider(color: AppPalette.border1, height: 1),
                10.h.verticalSpace,
                _KVRow(
                  k: 'brand_campaign_details_total_campaign_cost'.tr,
                  v: formatCurrencyByLocale(controller.totalCost),
                  amountColor: amountColor,
                ),
                if (showDue) ...[
                  10.h.verticalSpace,
                  _KVRow(
                    k: 'brand_campaign_details_paid_campaign_amount'.tr,
                    v: formatCurrencyByLocale(controller.paidAmount.value),
                  ),
                  10.h.verticalSpace,
                  Divider(color: AppPalette.border1, height: 1),
                  10.h.verticalSpace,
                  _KVRow(
                    k: 'brand_campaign_details_due_campaign_amount'.tr,
                    v: formatCurrencyByLocale(controller.dueAmount.value),
                    fontSize: 20.sp,
                  ),
                ],
              ],
            );
          }),
          12.h.verticalSpace,
          Obx(() {
            final campStatus = controller.campaignStatus.value;
            final isNegotiating =
                campStatus.contains('received') ||
                campStatus.contains('negotia');
            final isPendingAgency = controller.isPendingAgency;
            if (isNegotiating && !controller.showDueButton.value) {
              return Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      btnText: 'brand_campaign_details_requote'.tr,
                      btnColor: AppPalette.white,
                      borderColor: AppPalette.border1,
                      textColor: AppPalette.black,
                      isDisabled: !controller.isYourTurn.value,
                      onTap: controller.onRequestQuote,
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: CustomButton(
                      btnText: 'brand_campaign_details_accept_quote'.tr,
                      btnColor: AppPalette.secondary,
                      borderColor: Colors.transparent,
                      showBorder: false,
                      textColor: AppPalette.white,
                      isDisabled: !controller.isYourTurn.value,
                      onTap: controller.onAcceptQuote,
                    ),
                  ),
                ],
              );
            }
            if (controller.dueAmount.value > 0 &&
                controller.showDueButton.value &&
                !isPendingAgency) {
              return CustomButton(
                width: double.infinity,
                btnText: 'brand_campaign_details_pay_due'.tr,
                btnColor: AppPalette.secondary,
                borderColor: Colors.transparent,
                showBorder: false,
                textColor: AppPalette.white,
                isDisabled: !controller.showDueButton.value,
                onTap: controller.openFundCampaignDialog,
              );
            }
            if (isPendingAgency) {
              return CustomButton(
                width: double.infinity,
                btnText: 'brand_campaign_details_budget_confirmed'.tr,
                btnColor: AppPalette.defaultFill,
                borderColor: Colors.transparent,
                showBorder: false,
                textColor: AppPalette.black,
                isDisabled: true,
                onTap: null,
              );
            }

            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String k;
  final String v;
  final Color? amountColor;
  final double? fontSize;
  const _KVRow({
    required this.k,
    required this.v,
    this.amountColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
              color: AppPalette.black,
            ),
          ),
        ),
        10.w.horizontalSpace,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            v,
            style: TextStyle(
              fontSize: fontSize ?? 15.sp,
              fontWeight: FontWeight.w500,
              color: amountColor ?? AppPalette.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------- MILESTONES ----------------

class _MilestonesCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          InkWell(
            onTap: controller.toggleMilestones,
            child: Row(
              children: [
                Expanded(
                  child: _CardTitle(
                    iconPath: 'assets/icons/mission.png',
                    title: 'brand_campaign_details_campaign_milestones'.tr,
                  ),
                ),
                Obx(() {
                  return Icon(
                    controller.milestonesExpanded.value
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppPalette.greyText,
                  );
                }),
              ],
            ),
          ),
          10.h.verticalSpace,
          Obx(() {
            if (!controller.milestonesExpanded.value) {
              return const SizedBox.shrink();
            }

            final list = controller.milestones.toList(growable: false);

            final completedCount = list
                .where((m) => m.isApproved || m.isPaid)
                .length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!controller.isPaidAd) ...[
                  _DropdownPill(text: controller.milestoneStatusLabel.value),
                  10.h.verticalSpace,
                ],
                Row(
                  children: [
                    Text(
                      'brand_campaign_details_progress'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$completedCount ${'brand_campaign_details_of'.tr} ${list.length} ${'brand_campaign_details_completed_small'.tr}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.black,
                      ),
                    ),
                  ],
                ),
                8.h.verticalSpace,
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: 0,
                    minHeight: 8.h,
                    backgroundColor: AppPalette.border1,
                    color: AppPalette.secondary,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
                22.h.verticalSpace,
                ...list.map((m) => _MilestoneCard(milestone: m)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  final String text;
  const _DropdownPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppPalette.defaultFill,
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
                fontWeight: FontWeight.w400,
                color: AppPalette.greyText,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: AppPalette.greyText),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final Milestone milestone;

  const _MilestoneCard({required this.milestone});

  Color get _cardBg {
    switch (milestone.status) {
      case MilestoneStatus.paid:
        return AppPalette.thirdColor;
      case MilestoneStatus.approved:
        return AppPalette.thirdColor;
      case MilestoneStatus.partialPaid:
        return AppPalette.thirdColor;
      case MilestoneStatus.inReview:
        return AppPalette.gradient2;
      case MilestoneStatus.declined:
        return AppPalette.errorGradient;
      case MilestoneStatus.todo:
        return AppPalette.gradient3;
    }
  }

  String get _statusLabel {
    switch (milestone.status) {
      case MilestoneStatus.todo:
        return 'brand_campaign_details_pending'.tr;
      case MilestoneStatus.inReview:
        return 'ms_in_review'.tr;
      case MilestoneStatus.paid:
      case MilestoneStatus.approved:
      case MilestoneStatus.partialPaid:
        return 'brand_campaign_details_completed'.tr;
      case MilestoneStatus.declined:
        return 'brand_campaign_details_declined'.tr;
    }
  }

  Color get _statusBg {
    switch (milestone.status) {
      case MilestoneStatus.paid:
        return AppPalette.secondary;
      case MilestoneStatus.approved:
        return AppPalette.secondary;
      case MilestoneStatus.partialPaid:
        return AppPalette.secondary;
      case MilestoneStatus.inReview:
        return AppPalette.complemetaryFill;
      case MilestoneStatus.declined:
        return AppPalette.requiredColor;
      case MilestoneStatus.todo:
        return AppPalette.neutralGrey;
    }
  }

  Color get _statusTextColor {
    switch (milestone.status) {
      case MilestoneStatus.inReview:
        return AppPalette.complemetary;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignController = Get.find<BrandCampaignDetailsController>();
    return InkWell(
      onTap: () async {
        final result = await Get.toNamed(
          AppRoutes.milestoneDetails,
          arguments: {'milestone': milestone, 'job': campaignController.job},
          id: 1,
        );

        if (result is Map && result['refresh'] == true) {
          await campaignController.refreshAfterMilestoneUpdate();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [AppPalette.white, _cardBg],
          ),
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: _statusBg, width: kBorderWidth0_5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // first row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: milestone.status == MilestoneStatus.inReview
                        ? AppPalette.complemetary
                        : _statusBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    milestone.stepLabel,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.white,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    milestone.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: _statusTextColor,
                    ),
                  ),
                ),
              ],
            ),

            if (milestone.subtitle != null) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      milestone.subtitle!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppPalette.greyText,
                      ),
                    ),
                  ),
                  Text(
                    milestone.dayLabel ?? 'Day 0',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.greyText,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ---------------- RATING / BRIEF / CONTENT ASSETS / TERMS ----------------
/// (kept your existing widgets unchanged)

class _RatingCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
      child: Column(
        children: [
          Obx(() {
            final r = controller.rating.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final idx = i + 1;
                final filled = idx <= r;
                return InkWell(
                  onTap: () => controller.setRating(idx),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 25.sp,
                      color: filled ? AppPalette.secondary : AppPalette.border1,
                    ),
                  ),
                );
              }),
            );
          }),
          10.h.verticalSpace,
          Obx(() {
            return CustomButton(
              onTap: controller.provideRating,
              btnText: 'brand_campaign_details_provide_rating'.tr,
              width: double.infinity,
              btnColor: controller.rating.value > 0
                  ? AppPalette.secondary
                  : AppPalette.border1,
              textColor: AppPalette.white,
            );
          }),
        ],
      ),
    );
  }
}

class _BriefCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          InkWell(
            onTap: controller.toggleBrief,
            child: Row(
              children: [
                Expanded(
                  child: _CardTitle(
                    iconPath: 'assets/icons/terms_condition.png',
                    title: 'brand_campaign_details_campaign_brief'.tr,
                  ),
                ),
                Obx(() {
                  return Icon(
                    controller.briefExpanded.value
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppPalette.greyText,
                  );
                }),
              ],
            ),
          ),
          10.h.verticalSpace,
          Obx(() {
            if (!controller.briefExpanded.value) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BriefBlock(
                  iconPath: 'assets/icons/goal.png',
                  title: 'brand_campaign_details_campaign_goals'.tr,
                  text: controller.campaignGoals.value,
                ),
                12.h.verticalSpace,
                _BriefBlock(
                  iconPath: 'assets/icons/goal.png',
                  title: 'brand_campaign_details_product_service'.tr,
                  text: controller.productServiceDetails.value,
                ),
                12.h.verticalSpace,
                _BulletBlock(
                  iconPath: 'assets/icons/requirement.png',
                  title: 'brand_campaign_details_content_requirements'.tr,
                  bullets: controller.contentRequirements.toList(
                    growable: false,
                  ),
                ),
                12.h.verticalSpace,
                Text(
                  'brand_campaign_details_dos_donts'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
                10.h.verticalSpace,
                _DoDontBox(
                  isDo: true,
                  title: 'brand_campaign_details_dos'.tr,
                  bullets: controller.dosLines,
                ),
                10.h.verticalSpace,
                _DoDontBox(
                  isDo: false,
                  title: 'brand_campaign_details_donts'.tr,
                  bullets: controller.dontsLines,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BriefBlock extends StatelessWidget {
  final String iconPath;
  final String title;
  final String text;
  const _BriefBlock({
    required this.iconPath,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              iconPath,
              width: 20.w,
              fit: BoxFit.cover,
              color: AppPalette.primary,
            ),
            8.w.horizontalSpace,
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ),
          ],
        ),
        8.h.verticalSpace,
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            height: 1.35,
            color: AppPalette.greyText,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _BulletBlock extends StatelessWidget {
  final String iconPath;
  final String title;
  final List<String> bullets;
  const _BulletBlock({
    required this.iconPath,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              iconPath,
              width: 20.w,
              fit: BoxFit.cover,
              color: AppPalette.primary,
            ),
            8.w.horizontalSpace,
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ),
          ],
        ),
        8.h.verticalSpace,
        ...bullets.map(
          (b) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: TextStyle(fontSize: 12.sp, color: AppPalette.greyText),
                ),
                Expanded(
                  child: Text(
                    b,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.35,
                      color: AppPalette.greyText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DoDontBox extends StatelessWidget {
  final bool isDo;
  final String title;
  final List<String> bullets;
  const _DoDontBox({
    required this.isDo,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final tint = isDo ? AppPalette.color1fill : AppPalette.color2fill;
    final border = isDo ? AppPalette.color1stroke : AppPalette.color2stroke;
    final titleColor = isDo ? AppPalette.color1text : AppPalette.color2text;
    final icon = isDo
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: titleColor),
              8.w.horizontalSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ],
          ),
          8.h.verticalSpace,
          ...bullets.map(
            (b) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: TextStyle(fontSize: 10.sp, color: titleColor),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 10.sp,
                        height: 1.35,
                        color: titleColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentAssetsCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          InkWell(
            onTap: controller.toggleAssets,
            child: Row(
              children: [
                Expanded(
                  child: _CardTitle(
                    iconPath: 'assets/icons/download.png',
                    title: 'brand_campaign_details_content_assets'.tr,
                  ),
                ),
                Obx(() {
                  return Icon(
                    controller.assetsExpanded.value
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppPalette.greyText,
                  );
                }),
              ],
            ),
          ),
          10.h.verticalSpace,
          Obx(() {
            if (!controller.assetsExpanded.value) {
              return const SizedBox.shrink();
            }
            final list = controller.contentAssets.toList(growable: false);

            return Column(
              children: [
                ...List.generate(
                  list.length,
                  (i) => _AssetTile(
                    asset: list[i],
                    onTap: () => controller.onDownloadAsset(i),
                  ),
                ),
                10.h.verticalSpace,
                CustomButton.dotted(
                  height: 42.h,
                  btnText: 'brand_campaign_details_upload_another_asset'.tr,
                  btnColor: Colors.transparent,
                  borderColor: AppPalette.secondary,
                  textColor: AppPalette.secondary,
                  onTap: controller.openUploadAnotherAssetDialog,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final JobAsset asset;
  final VoidCallback onTap;
  const _AssetTile({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData iconFor(JobAssetKind k) {
      switch (k) {
        case JobAssetKind.image:
          return Icons.image_outlined;
        case JobAssetKind.video:
          return Icons.play_circle_outline;
        case JobAssetKind.document:
          return Icons.description_outlined;
        case JobAssetKind.other:
          return Icons.insert_drive_file_outlined;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Row(
        children: [
          Icon(iconFor(asset.kind), color: AppPalette.primary, size: 18.sp),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.primary,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  asset.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.greyText,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          InkWell(
            onTap: onTap,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppPalette.border1,
                  width: kBorderWidth0_5,
                ),
              ),
              child: Icon(
                Icons.download_rounded,
                size: 18.sp,
                color: AppPalette.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          InkWell(
            onTap: controller.toggleTerms,
            child: Row(
              children: [
                Expanded(
                  child: _CardTitle(
                    iconPath: 'assets/icons/terms_condition.png',
                    title: 'brand_campaign_details_terms_conditions'.tr,
                  ),
                ),
                Obx(() {
                  return Icon(
                    controller.termsExpanded.value
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppPalette.greyText,
                  );
                }),
              ],
            ),
          ),
          10.h.verticalSpace,
          Obx(() {
            if (!controller.termsExpanded.value) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TermBlock(
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'brand_campaign_details_reporting_requirements'.tr,
                  text: controller.reportingRequirements.value,
                ),
                12.h.verticalSpace,
                _TermBlock(
                  icon: Icons.copyright_rounded,
                  title: 'brand_campaign_details_usage_rights'.tr,
                  text: controller.usageRights.value,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TermBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _TermBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppPalette.primary),
              8.w.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          8.h.verticalSpace,
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.35,
              color: AppPalette.greyText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ✅ BRAND ASSETS (PaidAd screenshot) ----------------

class _BrandAssetsCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            iconPath: 'assets/icons/download.png',
            title: 'brand_campaign_details_brand_assets'.tr,
          ),
          12.h.verticalSpace,
          Obx(() {
            final list = controller.brandAssets.toList(growable: false);

            return Column(
              children: [
                ...List.generate(
                  list.length,
                  (i) => _BrandAssetTile(
                    asset: list[i],
                    onRemove: () => controller.removeBrandAsset(i),
                  ),
                ),
                10.h.verticalSpace,
                CustomButton.dotted(
                  height: 42.h,
                  btnText:
                      'brand_campaign_details_upload_another_brand_asset'.tr,
                  btnColor: Colors.transparent,
                  borderColor: AppPalette.secondary,
                  textColor: AppPalette.secondary,
                  onTap: controller.openUploadAnotherBrandAssetDialog,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BrandAssetTile extends StatelessWidget {
  final BrandAssetLink asset;
  final VoidCallback onRemove;

  const _BrandAssetTile({required this.asset, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: AppPalette.defaultFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(asset.icon, size: 18.sp, color: AppPalette.primary),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.primary,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  asset.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.greyText,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          InkWell(
            onTap: onRemove,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppPalette.border1,
                  width: kBorderWidth0_5,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: AppPalette.greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String? iconPath;
  final String title;
  const _CardTitle({this.iconPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (iconPath != null) ...[
          Image.asset(
            iconPath!,
            width: 25.w,
            height: 25.w,
            fit: BoxFit.cover,
            color: AppPalette.primary,
          ),
          10.w.horizontalSpace,
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaidAdTabPills extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.paidAdTabIndex.value; // 0/1

      Widget pill({
        required String text,
        required bool active,
        required VoidCallback onTap,
      }) {
        return Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999.r),
            child: Container(
              height: 44.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppPalette.primary : AppPalette.defaultFill,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: AppPalette.border1,
                  width: kBorderWidth0_5,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: active ? AppPalette.white : AppPalette.greyText,
                ),
              ),
            ),
          ),
        );
      }

      return Row(
        children: [
          pill(
            text: 'brand_campaign_details_agency_quotes_tab'.tr,
            active: selected == 0,
            onTap: () => controller.setPaidAdTab(0),
          ),
          10.w.horizontalSpace,
          pill(
            text: 'brand_campaign_details_campaign_overview_tab'.tr,
            active: selected == 1,
            onTap: () => controller.setPaidAdTab(1),
          ),
        ],
      );
    });
  }
}

class _AgencyBidsTab extends GetView<BrandCampaignDetailsController> {
  static const double _fxRate = 122.09; // screenshot shows ~122.xx

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'brand_campaign_details_agency_quotations_count'.trParams({
                    'count': controller.agencyOffers.length.toString(),
                  }),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.primary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppPalette.defaultFill,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: AppPalette.border1,
                    width: kBorderWidth0_5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'common_low_to_high'.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.greyText,
                      ),
                    ),
                    6.w.horizontalSpace,
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppPalette.greyText,
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.h.verticalSpace,

          Obx(() {
            final list = controller.agencyOffers.toList(growable: false);
            final total = controller.totalCost <= 0
                ? 110000
                : controller.totalCost;

            return Column(
              children: [
                ...list.map((o) {
                  final hasBackendBreakdown = o.totalPayableExcludingFee > 0;
                  final fee = hasBackendBreakdown
                      ? (total - o.totalPayableExcludingFee).clamp(0, total)
                      : (total * (o.agencyFeePercent / 100)).round();
                  final excl = hasBackendBreakdown
                      ? o.totalPayableExcludingFee
                      : (total - fee).clamp(0, total);
                  final fxRate = o.dollarRate > 0 ? o.dollarRate : _fxRate;
                  final usd = fxRate <= 0 ? 0 : (excl / fxRate);

                  return _AgencyOfferCard(
                    name: o.name,
                    agencyFeePercent: o.agencyFeePercent,
                    fxRate: fxRate,
                    agencyFeeBdt: fee,
                    budgetExclAgencyBdt: excl,
                    usdValue: usd.toDouble(),
                    onAcceptAndPay: () =>
                        controller.onAcceptAgencyOfferAndPay(o),
                  );
                }).toList(),

                6.h.verticalSpace,
                Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 40.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppPalette.defaultFill,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppPalette.border1,
                          width: kBorderWidth0_5,
                        ),
                      ),
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                    10.w.horizontalSpace,
                    Text(
                      'common_of_n'.trParams({'n': '30'}),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.greyText,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppPalette.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'common_next'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: AppPalette.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _AgencyOfferCard extends StatelessWidget {
  final String name;
  final int agencyFeePercent;
  final double fxRate;
  final int agencyFeeBdt;
  final int budgetExclAgencyBdt;
  final double usdValue;
  final VoidCallback onAcceptAndPay;

  const _AgencyOfferCard({
    required this.name,
    required this.agencyFeePercent,
    required this.fxRate,
    required this.agencyFeeBdt,
    required this.budgetExclAgencyBdt,
    required this.usdValue,
    required this.onAcceptAndPay,
  });

  String _bdt(int v) => '৳$v';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: AppPalette.defaultFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppPalette.border1,
                    width: kBorderWidth0_5,
                  ),
                ),
              ),
              10.w.horizontalSpace,
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.primary,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'brand_campaign_details_fx_rate'.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.greyText,
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    '৳${fxRate.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          10.h.verticalSpace,

          Row(
            children: [
              Expanded(
                child: Text(
                  'brand_campaign_details_agency_fee_percent'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.greyText,
                  ),
                ),
              ),
              Text(
                '$agencyFeePercent%',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),
          10.h.verticalSpace,

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            child: Column(
              children: [
                _miniRow(
                  'brand_campaign_details_agency_fee_bdt'.tr,
                  _bdt(agencyFeeBdt),
                ),
                6.h.verticalSpace,
                _miniRow(
                  'brand_campaign_details_budget_excl_agency'.tr,
                  _bdt(budgetExclAgencyBdt),
                ),
                6.h.verticalSpace,
                _miniRow(
                  'brand_campaign_details_fx_rate_bdt'.tr,
                  fxRate.toStringAsFixed(2),
                ),
                6.h.verticalSpace,
                _miniRow(
                  'brand_campaign_details_usd_value'.tr,
                  usdValue.toStringAsFixed(2),
                ),
              ],
            ),
          ),
          12.h.verticalSpace,

          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: onAcceptAndPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'brand_campaign_details_accept_quote_and_pay'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniRow(String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.greyText,
            ),
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w900,
            color: AppPalette.primary,
          ),
        ),
      ],
    );
  }
}
