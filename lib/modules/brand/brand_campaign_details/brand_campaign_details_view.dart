import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/app_pagination_row.dart';
import '../../../core/widgets/app_pill_tabs.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/models/job_item.dart';
import '../../../core/utils/shimmer_utils.dart';
import '../../../core/widgets/sort_toggle_chip.dart';
import 'brand_campaign_details_controller.dart';
import 'widgets/provide_rating_dialog.dart';

class BrandCampaignDetailsView extends GetView<BrandCampaignDetailsController> {
  const BrandCampaignDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return ShimmerUtils.campaignDetailsShimmer();
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshCampaignDetails,
            child: SingleChildScrollView(
              key: const PageStorageKey<String>(
                'brand_campaign_details_scroll',
              ),
              controller: controller.pageScrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CampaignDetailsCard(),
                  12.h.verticalSpace,

                  Obx(() {
                    controller.campaignType.value;
                    final isPaidAd = controller.isPaidAd;
                    final progressStep = controller.progressStep.value;

                    final shouldShowAgencyTabs =
                        controller.agencyOffers.isNotEmpty &&
                        (progressStep == CampaignProgressStep.submitted ||
                            progressStep == CampaignProgressStep.quoted);

                    dev.log(
                      'campaignStatus: ${controller.campaignStatus.value}, '
                      'progressStep: $progressStep, '
                      'agencyOffers: ${controller.agencyOffers.length}, '
                      'shouldShowAgencyTabs: $shouldShowAgencyTabs',
                    );

                    Widget detailsColumn() {
                      return Column(
                        children: [
                          _CampaignProgressCard(),
                          12.h.verticalSpace,
                          _ShippingAddressCard(),
                          12.h.verticalSpace,
                          _MilestonesCard(),
                          12.h.verticalSpace,
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
                          Obx(() {
                            if (!controller.showDangerZone) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [12.h.verticalSpace, _DangerZoneCard()],
                            );
                          }),
                        ],
                      );
                    }

                    if (!shouldShowAgencyTabs) {
                      return detailsColumn();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => AppPillTabs<bool>(
                            selected: controller.paidAdTabIndex.value == 0,
                            onChanged: (v) =>
                                controller.setPaidAdTab(v ? 0 : 1),
                            items: [
                              AppPillTabItem(
                                value: true,
                                label:
                                    'brand_campaign_details_agency_quotes_tab'
                                        .tr,
                              ),
                              AppPillTabItem(
                                value: false,
                                label:
                                    'brand_campaign_details_campaign_overview_tab'
                                        .tr,
                              ),
                            ],
                          ),
                        ),
                        12.h.verticalSpace,
                        Obx(() {
                          final tab = controller.paidAdTabIndex.value;

                          if (tab == 0) return _AgencyBidsTab();

                          return detailsColumn();
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
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
          Obx(() {
            final showRating = controller.isRated.value;
            final rating = controller.rating.value;

            return Row(
              children: [
                InkWell(
                  onTap: () => Get.back(id: 1),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20.sp,
                  ),
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
                if (showRating) ...[_RatingStars(rating: rating.toDouble())],
              ],
            );
          }),
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
                    Obx(() {
                      return Text(
                        controller.campaignTitle.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      );
                    }),
                    SizedBox(height: 6.h),
                    Obx(() {
                      return Text(
                        formatCurrencyByLocale(controller.totalCost),
                        style: TextStyle(
                          color: AppPalette.thirdColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
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

            if (controller.isPaidAd || controller.influencers.isEmpty) {
              return SizedBox.shrink();
            }

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
          Obx(() {
            final keys = controller.platformKeys.toList(growable: false);

            final iconPaths = keys.isEmpty
                ? <String>[
                    'assets/icons/instagram.png',
                    'assets/icons/youTube.png',
                    'assets/icons/tikTok.png',
                  ]
                : keys
                      .map(_platformAssetPath)
                      .where((e) => e.isNotEmpty)
                      .toList(growable: false);

            return Row(
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
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: iconPaths
                          .map(
                            (path) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Image.asset(
                                path,
                                width: 24.w,
                                height: 24.w,
                                fit: BoxFit.cover,
                                color: AppPalette
                                    .thirdColor, // same style as overview header
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          }),
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
              final isActive =
                  controller.progressStep.value ==
                      CampaignProgressStep.promoting ||
                  controller.progressStep.value == CampaignProgressStep.paid ||
                  controller.progressStep.value ==
                      CampaignProgressStep.quoted ||
                  controller.progressStep.value ==
                      CampaignProgressStep.completed;
              if (isActive && controller.showDueButton.value) {
                return Column(
                  children: [
                    Image.asset(
                      'assets/icons/not_expensive.png',
                      width: 21.w,

                      fit: BoxFit.cover,
                    ),
                    6.h.verticalSpace,
                    Text(
                      'brand_campaign_fund_total_due'.tr,
                      style: AppTheme.textStyle.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.white,
                      ),
                    ),
                    Text(
                      formatCurrencyByLocale(controller.dueAmount.value),
                      style: AppTheme.textStyle.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.thirdColor,
                      ),
                    ),
                  ],
                );
              }
              if (isActive && !controller.showDueButton.value) {
                return SizedBox.shrink();
              }
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

  static String _platformAssetPath(String platformKey) {
    final key = platformKey.trim().toLowerCase();

    if (key.contains('youtube') || key == 'yt') {
      return 'assets/icons/youTube.png';
    }
    if (key.contains('tik') || key.contains('tiktok')) {
      return 'assets/icons/tikTok.png';
    }
    if (key.contains('facebook')) {
      return 'assets/icons/facebook.png';
    }
    if (key.contains('instagram') || key.contains('insta')) {
      return 'assets/icons/instagram.png';
    }

    return 'assets/icons/instagram.png'; // fallback
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
              if (step == CampaignProgressStep.submitted) return true;
              return current.index >= step.index;
            }

            final paymentStatus = controller.paymentStatus.value;
            final hasPaidAmount = controller.paidAmount.value > 0;

            return Column(
              children: [
                _ProgressRow(
                  iconAssetPath: 'assets/icons/done2.png',
                  title: 'brand_campaign_details_submitted'.tr,
                  subtitle: 'brand_campaign_details_submitted_sub'.tr,
                  active: isActive(CampaignProgressStep.submitted),
                ),
                _ProgressRow(
                  iconAssetPath: 'assets/icons/get_quote.png',
                  title: 'brand_campaign_details_quoted'.tr,
                  subtitle: 'brand_campaign_details_quoted_sub'.tr,
                  active: isActive(CampaignProgressStep.quoted),
                ),
                _ProgressRow(
                  iconAssetPath: 'assets/icons/paid_bill.png',
                  title: paymentStatus.toLowerCase().contains('partial')
                      ? 'brand_campaign_details_paid_partial'.tr
                      : 'brand_campaign_details_paid'.tr,
                  subtitle: 'brand_campaign_details_paid_sub'.tr,
                  active: hasPaidAmount && isActive(CampaignProgressStep.paid),
                ),
                _ProgressRow(
                  iconAssetPath: 'assets/icons/online_ads.png',
                  title: 'brand_campaign_details_promoting'.tr,
                  subtitle: 'brand_campaign_details_promoting_sub'.tr,
                  active: isActive(CampaignProgressStep.promoting),
                ),
                _ProgressRow(
                  iconAssetPath: 'assets/icons/task_completed.png',
                  title: 'brand_campaign_details_completed'.tr,
                  subtitle: 'brand_campaign_details_completed_sub'.tr,
                  active: isActive(CampaignProgressStep.completed),
                  isLast: true,
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
  final String iconAssetPath;
  final String title;
  final String subtitle;
  final bool active;
  final bool isLast;

  const _ProgressRow({
    required this.iconAssetPath,
    required this.title,
    required this.subtitle,
    required this.active,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = AppPalette.black;
    final subColor = AppPalette.greyText;

    final circleBg = active ? AppPalette.primary : AppPalette.greyFill;
    final lineColor = active ? AppPalette.primary : AppPalette.greyFill;
    final iconColor = active ? AppPalette.white : AppPalette.greyText;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58.w,
            child: Column(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBg,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    iconAssetPath,
                    width: 17.w,
                    fit: BoxFit.cover,
                    color: iconColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 0.h),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h, bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: subColor,
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
            final isPaidAd = controller.isPaidAd;
            final campaignStatus = controller.campaignStatus.value
                .trim()
                .toLowerCase();
            final isCampaignActive = campaignStatus == 'active';
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
                if (showDue && (!isPaidAd || isCampaignActive)) ...[
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
                    child: Obx(() {
                      return CustomButton(
                        btnText: 'brand_campaign_details_accept_quote'.tr,
                        btnColor: AppPalette.secondary,
                        borderColor: Colors.transparent,
                        showBorder: false,
                        textColor: AppPalette.white,
                        isDisabled:
                            !controller.isYourTurn.value ||
                            controller.isAcceptQuoteLoading.value,
                        isLoading: controller.isAcceptQuoteLoading.value,
                        onTap: controller.onAcceptQuote,
                      );
                    }),
                  ),
                ],
              );
            }

            final isPaidAd = controller.isPaidAd;
            final campaignStatus = controller.campaignStatus.value
                .trim()
                .toLowerCase();
            final isCampaignActive = campaignStatus == 'active';
            if (controller.dueAmount.value > 0 &&
                controller.showDueButton.value &&
                !isPendingAgency &&
                (!isPaidAd || isCampaignActive)) {
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
            if (!isPendingAgency && !(!isPaidAd || isCampaignActive)) {
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
                  Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.black,
                    ),
                  ),
                  6.h.verticalSpace,
                  Obx(() {
                    return Text(
                      '${controller.operationalProgressText.value} Completed',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.complemetary,
                      ),
                    );
                  }),
                  14.h.verticalSpace,
                  Obx(() {
                    final selected = controller.assignedInfluencers
                        .firstWhereOrNull(
                          (e) =>
                              e.assignmentId ==
                              controller.selectedAssignmentId.value,
                        );

                    final name =
                        selected?.name ?? controller.milestoneStatusLabel.value;
                    final avatar = selected?.image;

                    return _DropdownPill(
                      text: name,
                      avatarUrl: avatar,
                      onTap: controller.openInfluencerMilestonePickerSheet,
                    );
                  }),
                  12.h.verticalSpace,
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
                    value: list.isEmpty
                        ? 0
                        : (completedCount / list.length).clamp(0.0, 1.0),
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

class _ShippingAddressCard extends GetView<BrandCampaignDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isPaidAd || controller.assignedInfluencers.isEmpty) {
        return const SizedBox.shrink();
      }

      final selected = controller.selectedAssignedInfluencer;
      final name = selected?.name ?? 'Influencer';
      final avatar = selected?.image;
      final address = controller.selectedShippingAddress;

      return _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 22.sp,
                  color: AppPalette.primary,
                ),
                10.w.horizontalSpace,
                Expanded(
                  child: Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
              ],
            ),
            12.h.verticalSpace,
            _DropdownPill(
              text: name,
              avatarUrl: avatar,
              onTap: controller.openInfluencerMilestonePickerSheet,
            ),
            12.h.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.circular(kBorderRadius.r),
                border: Border.all(color: AppPalette.border1, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Icon(
                      Icons.place_outlined,
                      size: 18.sp,
                      color: AppPalette.secondary,
                    ),
                  ),
                  8.w.horizontalSpace,
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.greyText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _DropdownPill extends StatelessWidget {
  final String text;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const _DropdownPill({required this.text, this.avatarUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E4C8),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            ),
            12.w.horizontalSpace,
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppPalette.primary,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppPalette.black,
              size: 24.sp,
            ),
          ],
        ),
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
        return 'brand_submission_declined'.tr;
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
            controller.rating.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.star_rounded,
                    size: 25.sp,
                    color: AppPalette.starDark,
                  ),
                );
              }),
            );
          }),
          10.h.verticalSpace,
          CustomButton(
            onTap: controller.provideRating,
            btnText: controller.isPaidAd
                ? 'Provide Ratings To This Agency'
                : 'Provide Ratings To Influencers',
            width: double.infinity,
            btnColor: AppPalette.secondary,
            textColor: AppPalette.white,
          ),
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
                  height: 54.h,
                  width: double.infinity,
                  leading: Transform.flip(
                    flipY: true,
                    child: Image.asset(
                      'assets/icons/download.png',
                      width: 23.1.w,
                      color: AppPalette.secondary,
                    ),
                  ),
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

class _AssetTile extends GetView<BrandCampaignDetailsController> {
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

    return InkWell(
      onTap: () => controller.openAssetLink(asset.pathOrUrl),
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: AppPalette.secondary,
            width: kBorderWidth0_5,
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [AppPalette.white, AppPalette.white, AppPalette.thirdColor],
          ),
        ),
        child: Row(
          children: [
            Icon(iconFor(asset.kind), color: AppPalette.secondary, size: 25.sp),
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.secondary,
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    asset.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.secondary.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            10.w.horizontalSpace,
            InkWell(
              onTap: () => controller.openAssetLink(asset.pathOrUrl),
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Image.asset(
                  'assets/icons/download.png',
                  width: 23.w,
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
                  iconPath: 'assets/icons/presentation.png',
                  title: 'brand_campaign_details_reporting_requirements'.tr,
                  text: controller.reportingRequirements.value,
                ),
                12.h.verticalSpace,
                _TermBlock(
                  iconPath: 'assets/icons/copyright.png',
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
  final String iconPath;
  final String title;
  final String text;
  const _TermBlock({
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
            Image.asset(iconPath, width: 20.w, color: AppPalette.primary),
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
            title: 'campaign_brand_assets'.tr,
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
                  height: 54.h,
                  width: double.infinity,
                  btnText:
                      'brand_campaign_details_upload_another_brand_asset'.tr,
                  leading: Transform.flip(
                    flipY: true,
                    child: Image.asset(
                      'assets/icons/download.png',
                      width: 23.1.w,
                      color: AppPalette.secondary,
                    ),
                  ),
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

class _BrandAssetTile extends GetView<BrandCampaignDetailsController> {
  final BrandAssetLink asset;
  final VoidCallback onRemove;

  const _BrandAssetTile({required this.asset, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.openAssetLink(asset.url),
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: AppPalette.secondary,
            width: kBorderWidth0_5,
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [AppPalette.white, AppPalette.white, AppPalette.thirdColor],
          ),
        ),
        child: Row(
          children: [
            Icon(asset.icon, size: 30.sp, color: AppPalette.secondary),
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    asset.url ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.secondary.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            10.w.horizontalSpace,
            InkWell(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 20.sp,
                color: AppPalette.secondary,
              ),
            ),
          ],
        ),
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
              ),
              Obx(() {
                return SortToggleChip(
                  isLowToHigh: controller.isSortLowToHigh.value,
                  onTap: controller.toggleSort,
                  lowToHighText: 'jobs_sort_low_to_high'.tr,
                  highToLowText: 'jobs_sort_high_to_low'.tr,
                );
              }),
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
                    logo: o.logo,
                    agencyFeePercent: o.agencyFeePercent,
                    fxRate: fxRate,
                    agencyFeeBdt: fee,
                    budgetExclAgencyBdt: excl,
                    usdValue: usd.toDouble(),
                    onAcceptAndPay: () =>
                        controller.onAcceptAgencyOfferAndPay(o),
                    isLoading:
                        controller.payingAgencyOfferId.value == o.agencyId,
                  );
                }).toList(),

                6.h.verticalSpace,
                AppPaginationRow(
                  page: controller.page,
                  totalPages: controller.totalPages,
                  isLoading: controller.isLoading,
                  onPrev: controller.prevPage,
                  onNext: controller.nextPage,
                  pageLabel: 'analytics_page'.tr,
                  // ofLabel: 'analytics_of'.tr,
                  nextLabel: 'analytics_next'.tr,
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
  final String logo;
  final int agencyFeePercent;
  final double fxRate;
  final int agencyFeeBdt;
  final int budgetExclAgencyBdt;
  final double usdValue;
  final VoidCallback onAcceptAndPay;
  final bool isLoading;

  const _AgencyOfferCard({
    required this.name,
    required this.logo,
    required this.agencyFeePercent,
    required this.fxRate,
    required this.agencyFeeBdt,
    required this.budgetExclAgencyBdt,
    required this.usdValue,
    required this.onAcceptAndPay,
    required this.isLoading,
  });

  String _bdt(int v) => '৳$v';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: AppPalette.defaultFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppPalette.border1,
                    width: kBorderWidth0_5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  logo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.person,
                        size: 18.sp,
                        color: AppPalette.greyText,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
              10.w.horizontalSpace,
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          10.h.verticalSpace,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'brand_campaign_details_agency_fee_percent'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.black,
                    ),
                  ),
                  Text(
                    '$agencyFeePercent%',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.secondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'brand_campaign_details_fx_rate'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.black,
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    '৳${fxRate.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          10.h.verticalSpace,

          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 14.w,
              top: 10.h,
              bottom: 10.h,
              right: 10.w,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(
                color: AppPalette.secondary,
                width: kBorderWidth0_5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPalette.thirdColor, AppPalette.white],
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

          CustomButton(
            onTap: isLoading ? null : onAcceptAndPay,
            btnText: 'brand_campaign_details_accept_quote_and_pay'.tr,
            textColor: AppPalette.white,
            width: double.infinity,
            isLoading: isLoading,
            isDisabled: isLoading,
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
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.black,
            ),
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.secondary,
          ),
        ),
      ],
    );
  }
}

class _DangerZoneCard extends GetView<BrandCampaignDetailsController> {
  const _DangerZoneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Obx(() {
        final isExpanded = controller.dangerZoneExpanded.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.toggleDangerZone,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              child: Row(
                children: [
                  Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: const BoxDecoration(
                      color: AppPalette.error,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                  8.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'brand_campaign_details_danger_zone'.tr,
                          style: TextStyle(
                            color: AppPalette.error,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'brand_campaign_details_cancel_campaign'.tr,
                          style: TextStyle(
                            color: AppPalette.greyText,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppPalette.greenText,
                  ),
                ],
              ),
            ),

            if (isExpanded) ...[
              16.h.verticalSpace,
              CustomTextFormField(
                controller: controller.cancelReasonCtrl,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                hintText: 'brand_campaign_details_cancel_reason_hint'.tr,
                borderColor: AppPalette.error,
              ),
              18.h.verticalSpace,
              Obx(() {
                return CustomButton(
                  width: double.infinity,
                  btnText: 'brand_campaign_details_cancel_request_button'.tr,
                  btnColor: AppPalette.error,
                  showBorder: false,
                  textColor: AppPalette.white,
                  isDisabled: controller.isSubmittingCancellation.value,
                  onTap: controller.requestCancellation,
                );
              }),
            ],
          ],
        );
      }),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final diff = rating - index;

        IconData icon;
        Color color;

        if (diff >= 0.75) {
          icon = Icons.star_rounded;
          color = AppPalette.starDark;
        } else if (diff >= 0.25) {
          icon = Icons.star_half_rounded;
          color = AppPalette.starDark;
        } else {
          icon = Icons.star_rounded;
          color = AppPalette.white;
        }

        return Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Icon(icon, size: 18.sp, color: color),
        );
      }),
    );
  }
}
