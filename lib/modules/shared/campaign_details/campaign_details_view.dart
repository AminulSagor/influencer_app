// campaign_details_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/utils/number_formatter.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

import '../../../core/models/job_item.dart';
import 'campaign_details_controller.dart';

class CampaignDetailsView extends GetView<CampaignDetailsController> {
  const CampaignDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();

    return Obx(() {
      final job = controller.job;
      final status = controller.campaignStatus.value;

      return Scaffold(
        backgroundColor: AppPalette.background,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.h.verticalSpace,
              _CampaignOverviewCard(job: job),
              SizedBox(height: 12.h),

              // NEW OFFER ONLY: quote card
              if (controller.showQuoteCard &&
                  accountTypeService.isAdAgency) ...[
                _QuoteDetailsCard(job: job),
                SizedBox(height: 16.h),
              ],

              // --------- Payment Milestones ----------
              Obx(() {
                return _PaymentMilestonesSection(
                  job: job,
                  status: status,
                  isExpanded: controller.milestonesExpanded.value,
                  onToggle: controller.toggleMilestones,
                );
              }),
              SizedBox(height: 12.h),

              // --------- Campaign Brief ----------
              Obx(
                () => _ExpandableSection(
                  title: 'campaign_brief'.tr,
                  iconPath: 'assets/icons/terms_condition.png',
                  isExpanded: controller.briefExpanded.value,
                  onToggle: controller.toggleBrief,
                  child: const _CampaignBrief(),
                ),
              ),
              SizedBox(height: 12.h),

              // --------- Content Assets ----------
              Obx(
                () => _ExpandableSection(
                  title: 'campaign_content_assets'.tr,
                  iconPath: 'assets/icons/download.png',
                  isExpanded: controller.contentAssetsExpanded.value,
                  onToggle: controller.toggleContentAssets,
                  child: const _ContentAssets(),
                ),
              ),
              SizedBox(height: 12.h),

              // --------- Terms & Conditions ----------
              Obx(
                () => _ExpandableSection(
                  title: 'campaign_terms_conditions'.tr,
                  iconPath: 'assets/icons/terms_condition.png',
                  isExpanded: controller.termsExpanded.value,
                  onToggle: controller.toggleTerms,
                  child: const _TermsAndConditions(),
                ),
              ),
              SizedBox(height: 12.h),

              // --------- Brand Assets ----------
              Obx(
                () => _ExpandableSection(
                  title: 'campaign_brand_assets'.tr,
                  iconPath: 'assets/icons/download.png',
                  isExpanded: controller.brandAssetsExpanded.value,
                  onToggle: controller.toggleBrandAssets,
                  child: const _BrandAssets(),
                ),
              ),
              SizedBox(height: 24.h),

              if (controller.showAgreementBar)
                _AgreementSection(
                  isChecked: controller.agreeToTerms.value,
                  onToggle: controller.toggleAgree,
                  onAccept: controller.onAccept,
                  onDecline: controller.onDecline,
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// TOP GREEN CAMPAIGN CARD
// ---------------------------------------------------------------------------

class _CampaignOverviewCard extends StatelessWidget {
  final JobItem job;

  const _CampaignOverviewCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignDetailsController>();
    final accountTypeService = Get.find<AccountTypeService>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        gradient: const LinearGradient(
          colors: [AppPalette.gradient1, AppPalette.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + label
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(id: 1),
                child: Icon(Icons.arrow_back, size: 16.sp, color: Colors.white),
              ),
              SizedBox(width: 6.w),
              Text(
                'campaign_details_title'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Icon + Title + Budget
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
                      job.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      formatCurrencyByLocale(job.budget),
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

          Row(
            children: [
              const Spacer(),
              Text(
                '${'common_client'.tr}: ${job.clientName}',
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),
          Divider(color: AppPalette.thirdColor.withAlpha(150), height: 1),
          SizedBox(height: 12.h),

          // Platforms row
          Row(
            children: [
              Text(
                'common_platforms'.tr,
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              12.w.horizontalSpace,
              Image.asset(
                'assets/icons/instagram.png',
                width: 24.w,
                height: 24.w,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 8.w),
              Image.asset(
                'assets/icons/youTube.png',
                width: 24.w,
                height: 24.w,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 8.w),
              Image.asset(
                'assets/icons/tikTok.png',
                width: 24.w,
                height: 24.w,
                fit: BoxFit.cover,
              ),
            ],
          ),

          SizedBox(height: 12.h),
          if (accountTypeService.isAdAgency) ...[
            Divider(color: AppPalette.thirdColor.withAlpha(150), height: 1),
            SizedBox(height: 12.h),
          ],

          // Profit
          if (accountTypeService.isAdAgency)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/icons/dollar_bag.png',
                  width: 28.w,
                  height: 28.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'campaign_your_profit'.trParams({
                        'percent': formatNumberByLocale(job.sharePercent),
                      }),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      job.profitLabel ?? '-',
                      style: TextStyle(
                        color: AppPalette.thirdColor,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          SizedBox(height: 16.h),

          // Deadline big pill
          Container(
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
                  controller.deadlineMainText,
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
                      job.dateLabel,
                      style: TextStyle(
                        color: AppPalette.thirdColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QUOTE DETAILS CARD
// ---------------------------------------------------------------------------

class _QuoteDetailsCard extends StatelessWidget {
  final JobItem job;

  const _QuoteDetailsCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final String campaignBudget = formatCurrencyByLocale(job.budget);
    final String vatLabel = job.vatLabel ?? '৳10,000';
    final String totalCost =
        job.totalCostLabel ?? formatCurrencyByLocale(job.budget);
    final String profitAmount = job.profitLabel ?? '৳16,500';

    final labelStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w300,
      color: AppPalette.black,
    );

    final valueStyle = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w500,
      color: AppPalette.secondary,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Text(
                  'campaign_quote_details'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
                const Spacer(),
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

            SizedBox(height: 18.h),

            // TOP (Budget + VAT)
            Container(
              padding: EdgeInsets.only(bottom: 12.h),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppPalette.border1, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('campaign_budget'.tr, style: labelStyle),
                      ),
                      Text(campaignBudget, style: valueStyle),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('campaign_vat_tax'.tr, style: labelStyle),
                            SizedBox(width: 4.w),
                            Text(
                              '(${formatNumberByLocale(15)}%)',
                              style: labelStyle,
                            ),
                          ],
                        ),
                      ),
                      Text(vatLabel, style: valueStyle),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // BOTTOM (Total + Profit)
            Row(
              children: [
                Expanded(
                  child: Text('campaign_total_cost'.tr, style: labelStyle),
                ),
                Text(totalCost, style: valueStyle),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'campaign_your_profit'.trParams({
                      'percent': formatNumberByLocale(15),
                    }),
                    style: labelStyle,
                  ),
                ),
                Text(profitAmount, style: valueStyle),
              ],
            ),

            SizedBox(height: 18.h),

            // REQUEST BUTTON
            CustomButton(
              onTap: () {},
              btnText: 'campaign_request_requote'.tr,
              btnColor: AppPalette.fill2,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PAYMENT MILESTONES
// ---------------------------------------------------------------------------

class _MilestoneCard extends GetView<CampaignDetailsController> {
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
      case MilestoneStatus.paid:
        return 'ms_paid'.tr;
      case MilestoneStatus.approved:
        return 'Approved';
      case MilestoneStatus.partialPaid:
        return 'ms_partial_paid'.tr;
      case MilestoneStatus.inReview:
        return 'ms_in_review'.tr;
      case MilestoneStatus.declined:
        return 'ms_declined'.tr;
      case MilestoneStatus.todo:
        return 'ms_todo'.tr;
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
    return InkWell(
      onTap: () => controller.openMilestoneDetails(milestone),
      child: Container(
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
              Text(
                milestone.subtitle!,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
              ),
            ],

            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  milestone.amountLabel,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF315719),
                  ),
                ),
                const Spacer(),
                if (milestone.dayLabel != null)
                  Text(
                    milestone.dayLabel!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BRIEF / CONTENT ASSETS / TERMS / BRAND ASSETS / AGREEMENT
// ---------------------------------------------------------------------------

class _CampaignBrief extends StatelessWidget {
  const _CampaignBrief();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/icons/goal.png',
              width: 20.w,
              height: 20.w,
              color: AppPalette.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              'campaign_goals'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          'campaign_goals_desc'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppPalette.subtext,
            letterSpacing: -0.04,
          ),
          textAlign: TextAlign.justify,
        ),

        SizedBox(height: 14.h),
        Row(
          children: [
            Image.asset(
              'assets/icons/goal.png',
              width: 20.w,
              height: 20.w,
              color: AppPalette.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              'campaign_content_requirements'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _BulletText('campaign_req_1'.tr),
        _BulletText('campaign_req_2'.tr),
        _BulletText('campaign_req_3'.tr),

        SizedBox(height: 14.h),
        Text(
          'campaign_dos_donts'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.primary,
          ),
        ),
        SizedBox(height: 10.h),

        // DO
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppPalette.greenBg,
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(
              color: AppPalette.greenBorder,
              width: kBorderWeight1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/check_mark.png',
                    width: 20.w,
                    height: 20.w,
                    color: AppPalette.greenText,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'campaign_dos'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.greenText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              _BulletText('campaign_dos_1'.tr, fontColor: AppPalette.greenText),
              _BulletText('campaign_dos_2'.tr, fontColor: AppPalette.greenText),
              _BulletText('campaign_dos_3'.tr, fontColor: AppPalette.greenText),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // DONT
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppPalette.redBg,
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(
              color: AppPalette.color2stroke,
              width: kBorderWeight1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/cancel_outline.png',
                    width: 20.w,
                    height: 20.w,
                    color: AppPalette.color2text,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'campaign_donts'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              _BulletText(
                'campaign_donts_1'.tr,
                fontColor: AppPalette.color2text,
              ),
              _BulletText(
                'campaign_donts_2'.tr,
                fontColor: AppPalette.color2text,
              ),
              _BulletText(
                'campaign_donts_3'.tr,
                fontColor: AppPalette.color2text,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentAssets extends StatelessWidget {
  const _ContentAssets();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AssetRow(
          title: 'campaign_asset_logo_pack'.tr,
          subtitle: 'PNG, SVG · 24 MB',
        ),
        const SizedBox(height: 8),
        _AssetRow(
          leadingIconPath: 'assets/icons/video.png',
          title: 'campaign_asset_demo_video'.tr,
          subtitle: 'MP4 · 80 MB',
        ),
        const SizedBox(height: 8),
        _AssetRow(
          leadingIconPath: 'assets/icons/document.png',
          title: 'campaign_asset_guidelines'.tr,
          subtitle: 'PDF · 750 KB',
        ),
      ],
    );
  }
}

class _TermsAndConditions extends StatelessWidget {
  const _TermsAndConditions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/icons/presentation.png',
              width: 20.w,
              height: 20.w,
              color: AppPalette.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              'campaign_reporting_requirements'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _BulletText('campaign_report_1'.tr),
        _BulletText('campaign_report_2'.tr),

        SizedBox(height: 14.h),

        Row(
          children: [
            Image.asset(
              'assets/icons/copyright.png',
              width: 20.w,
              height: 20.w,
              color: AppPalette.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              'campaign_usage_rights'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _BulletText('campaign_usage_1'.tr),
        _BulletText('campaign_usage_2'.tr),
      ],
    );
  }
}

class _BrandAssets extends StatelessWidget {
  const _BrandAssets();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AssetRow(
          leadingIconPath: 'assets/icons/facebook.png',
          title: 'campaign_asset_facebook_page'.tr,
          subtitle: 'campaign_asset_facebook_sub'.tr,
          trailingIconPath: 'assets/icons/cancel_outline.png',
        ),
      ],
    );
  }
}

class _AgreementSection extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onToggle;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _AgreementSection({
    required this.isChecked,
    required this.onToggle,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (accountTypeService.isAdAgency) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: isChecked
                            ? const Color(0xFF7BB23B)
                            : const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: isChecked
                          ? Icon(Icons.check, size: 18.sp, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.subtext,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'campaign_agree_prefix'.tr),
                          TextSpan(
                            text: 'campaign_agree_ula'.tr,
                            style: TextStyle(
                              color: AppPalette.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: 'campaign_agree_mid'.tr),
                          TextSpan(
                            text: 'campaign_agree_terms'.tr,
                            style: TextStyle(
                              color: AppPalette.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: 'campaign_agree_suffix'.tr),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: onDecline,
                    btnText: 'common_decline'.tr,
                    textColor: AppPalette.black,
                    btnColor: AppPalette.white,
                    borderColor: AppPalette.border1,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    onTap: onAccept,
                    btnText: 'common_accept'.tr,
                    textColor: AppPalette.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SMALL REUSABLE WIDGETS
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _SectionCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: child,
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? fontColor;

  const _BulletText(this.text, {this.fontSize, this.fontColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: fontSize ?? 12.sp,
              color: fontColor ?? AppPalette.subtext,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 12.sp,
                color: fontColor ?? AppPalette.subtext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leadingIconPath;
  final String trailingIconPath;

  const _AssetRow({
    required this.title,
    required this.subtitle,
    this.leadingIconPath = 'assets/icons/image.png',
    this.trailingIconPath = 'assets/icons/download.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [AppPalette.white, AppPalette.white, AppPalette.thirdColor],
        ),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.secondary, width: kBorderWidth0_5),
      ),
      child: Row(
        children: [
          Image.asset(
            leadingIconPath,
            width: 24.w,
            height: 24.w,
            fit: BoxFit.cover,
            color: AppPalette.secondary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.secondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.secondary.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            trailingIconPath,
            width: 24.w,
            height: 24.w,
            fit: BoxFit.cover,
            color: AppPalette.secondary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ExpandableSection – stateless, controlled by controller
// ---------------------------------------------------------------------------

class _ExpandableSection extends StatelessWidget {
  final String title;
  final String iconPath;
  final Widget child;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableSection({
    required this.title,
    required this.iconPath,
    required this.child,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              onTap: onToggle,
              child: Row(
                children: [
                  Image.asset(
                    iconPath,
                    width: 24.w,
                    height: 24.w,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 32.sp,
                    color: AppPalette.black,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: child,
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMilestonesSection extends StatelessWidget {
  final JobItem job;
  final CampaignStatus status;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _PaymentMilestonesSection({
    required this.job,
    required this.status,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final milestones = job.milestones ?? const <Milestone>[];
    final totalCount = milestones.length;

    final paidCount = milestones
        .where(
          (m) =>
              m.status == MilestoneStatus.paid ||
              m.status == MilestoneStatus.partialPaid,
        )
        .length;

    final double progress = totalCount == 0
        ? 0.0
        : paidCount / totalCount.toDouble();

    final totalEarnings = job.totalEarningsLabel ?? '৳0';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: onToggle,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/mission.png',
                    width: 23.w,
                    height: 23.w,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'campaign_payment_milestones'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 32.sp,
                    color: AppPalette.primary,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Progress row
            Row(
              children: [
                Text(
                  'campaign_progress'.tr,
                  style: TextStyle(fontSize: 10.sp, color: AppPalette.primary),
                ),
                const Spacer(),
                Text(
                  'campaign_paid_of_total'.trParams({
                    'paid': formatNumberByLocale(paidCount),
                    'total': formatNumberByLocale(totalCount),
                  }),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // pill progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: AppPalette.secondary.withAlpha(80),
                color: AppPalette.secondary,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),

            if (isExpanded) ...[
              SizedBox(height: 16.h),
              _TotalEarningsCard(
                jobTitle: job.title,
                totalEarnings: totalEarnings,
                status: status,
              ),
              SizedBox(height: 8.h),
              Divider(color: AppPalette.border1),
              SizedBox(height: 12.h),
              ...milestones.map(
                (m) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _MilestoneCard(milestone: m),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TotalEarningsCard extends StatelessWidget {
  final String jobTitle;
  final String totalEarnings;
  final CampaignStatus status;

  const _TotalEarningsCard({
    required this.totalEarnings,
    required this.status,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.secondary, width: kBorderWidth0_5),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        gradient: const LinearGradient(
          colors: [AppPalette.thirdColor, AppPalette.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'campaign_total_earnings'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                    color: AppPalette.black,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  totalEarnings,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
                if (status == CampaignStatus.complete) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppPalette.white, AppPalette.thirdColor],
                      ),
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      border: Border.all(
                        color: AppPalette.secondary,
                        width: kBorderWidth0_5,
                      ),
                    ),
                    child: Text(
                      'common_completed'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.secondary,
                      ),
                    ),
                  ),
                ],

                if (accountTypeService.isInfluencer) ...[
                  4.h.verticalSpace,
                  CustomButton(
                    onTap: () {
                      Get.dialog(
                        _WithdrawalSuccessDialog(
                          title: jobTitle,
                          amount: totalEarnings,
                        ),
                        barrierDismissible: true,
                      );
                    },
                    btnText: 'campaign_withdrawal_request'.tr,
                    btnColor: AppPalette.secondary,
                    textStyle: AppTheme.textStyle.copyWith(
                      fontSize: 12.sp,
                      color: AppPalette.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [AppPalette.thirdColor, AppPalette.white],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.secondary,
                width: kBorderWidth0_5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '৳',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalSuccessDialog extends StatelessWidget {
  final String title;
  final String amount;

  const _WithdrawalSuccessDialog({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.close,
                  size: 24.sp,
                  color: AppPalette.secondary,
                ),
              ),
            ),

            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: AppPalette.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 45.sp, color: Colors.white),
            ),
            SizedBox(height: 24.h),

            Text(
              'campaign_withdraw_sent'.tr,
              textAlign: TextAlign.center,
              style: AppTheme.textStyle.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'campaign_withdraw_msg'.tr,
              textAlign: TextAlign.center,
              style: AppTheme.textStyle.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.primary,
              ),
            ),
            SizedBox(height: 26.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppPalette.primary, AppPalette.secondary],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/online_ads.png',
                        color: Colors.white,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.textStyle.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w300,
                                color: AppPalette.white,
                              ),
                            ),
                            Text(
                              amount,
                              style: AppTheme.textStyle.copyWith(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(color: Colors.white.withOpacity(0.5), height: 1),
                  SizedBox(height: 10.h),

                  Row(
                    children: [
                      Text(
                        'common_platforms'.tr,
                        style: AppTheme.textStyle.copyWith(
                          color: AppPalette.thirdColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.w.horizontalSpace,
                      const Spacer(),
                      Image.asset(
                        'assets/icons/instagram.png',
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8.w),
                      Image.asset(
                        'assets/icons/youTube.png',
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8.w),
                      Image.asset(
                        'assets/icons/tikTok.png',
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.cover,
                      ),
                    ],
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
