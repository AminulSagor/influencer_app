// campaign_details_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

import 'campaign_details_controller.dart';
import '../../../core/models/job_item.dart';

class CampaignDetailsView extends GetView<CampaignDetailsController> {
  const CampaignDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
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
              if (controller.showQuoteCard) ...[
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
                  title: 'Campaign Brief',
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
                  title: 'Content Assets',
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
                  title: 'Terms & Conditions',
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
                  title: 'Brand Assets',
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
// TOP GREEN CAMPAIGN CARD – MATCHES PROVIDED DESIGN
// ---------------------------------------------------------------------------

class _CampaignOverviewCard extends StatelessWidget {
  final JobItem job;

  const _CampaignOverviewCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignDetailsController>();

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
                'Campaign Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Icon + Title + Budget + Client
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
              Spacer(),
              Text(
                'Client: ${job.clientName}',
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
                'Platforms',
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
          Divider(color: AppPalette.thirdColor.withAlpha(150), height: 1),
          SizedBox(height: 12.h),

          // Profit
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // money icon
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
                    'Your Profit (${job.sharePercent}%)',
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
              gradient: LinearGradient(
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
                  'Deadline',
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
// QUOTE DETAILS CARD – unchanged logic
// ---------------------------------------------------------------------------

class _QuoteDetailsCard extends StatelessWidget {
  final JobItem job;

  const _QuoteDetailsCard({required this.job});

  @override
  Widget build(BuildContext context) {
    // fallback values (you can later move these into JobItem if you want)
    final String campaignBudget = formatCurrencyByLocale(
      job.budget,
    ); // ex: ৳100,000
    final String vatLabel = job.vatLabel ?? '৳10,000'; // optional field
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
            // --------- HEADER ROW ----------
            Row(
              children: [
                Text(
                  'Quote Details',
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

            // --------- TOP SECTION (BUDGET + VAT) ----------
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
                        child: Text('Campaign Budget', style: labelStyle),
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
                            Text('VAT/Tax', style: labelStyle),
                            SizedBox(width: 4.w),
                            Text('(15%)', style: labelStyle),
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

            // --------- BOTTOM SECTION (TOTAL + PROFIT) ----------
            Row(
              children: [
                Expanded(child: Text('Total Campaign Cost', style: labelStyle)),
                Text(totalCost, style: valueStyle),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(child: Text('Your Profit (15%)', style: labelStyle)),
                Text(profitAmount, style: valueStyle),
              ],
            ),

            SizedBox(height: 18.h),

            // --------- REQUEST BUTTON ----------
            CustomButton(
              onTap: () {},
              btnText: 'Request To Requote',
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
// PAYMENT MILESTONES (same as before)
// ---------------------------------------------------------------------------

class _MilestoneCard extends GetView<CampaignDetailsController> {
  final Milestone milestone;

  const _MilestoneCard({required this.milestone});

  Color get _cardBg {
    switch (milestone.status) {
      case MilestoneStatus.paid:
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
        return 'Paid';
      case MilestoneStatus.partialPaid:
        return 'Partial Paid';
      case MilestoneStatus.inReview:
        return 'In Review';
      case MilestoneStatus.declined:
        return 'Declined';
      case MilestoneStatus.todo:
        return 'To Do';
    }
  }

  Color get _statusBg {
    switch (milestone.status) {
      case MilestoneStatus.paid:
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
// (same as your last version – only using new ExpandableSection)
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
            Text(
              'Campaign Goals',
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
          'Promote our new summer skincare line to Gen Z and millennial audiences. Focus on natural ingredients and sustainable packaging',
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
            Text(
              'Content Requirements',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        const _BulletText('Minimum 1 feed post & 2–3 stories per platform.'),
        const _BulletText('Use the provided brand assets and hashtags.'),
        const _BulletText(
          'Tag the official brand account in every content piece.',
        ),
        SizedBox(height: 14.h),
        Text(
          'Do’s & Don’ts',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.primary,
          ),
        ),
        SizedBox(height: 10.h),
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
                  Text(
                    'Do’s',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.greenText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              const _BulletText(
                'Show authentic product usage in daily life.',
                fontColor: AppPalette.greenText,
              ),
              const _BulletText(
                'Keep captions clear and brand-safe.',
                fontColor: AppPalette.greenText,
              ),
              const _BulletText(
                'Highlight key campaign messages and benefits.',
                fontColor: AppPalette.greenText,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
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
                  Text(
                    'Don’ts',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              const _BulletText(
                'Avoid competing brand placements in the same frame.',
                fontColor: AppPalette.color2text,
              ),
              const _BulletText(
                'Do not mislead or over-claim performance.',
                fontColor: AppPalette.color2text,
              ),
              const _BulletText(
                'Avoid sensitive or inappropriate context.',
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
      children: const [
        _AssetRow(title: 'Brand Logo Pack', subtitle: 'PNG, SVG · 24 MB'),
        SizedBox(height: 8),
        _AssetRow(
          leadingIconPath: 'assets/icons/video.png',
          title: 'Product Demo Video',
          subtitle: 'MP4 · 80 MB',
        ),
        SizedBox(height: 8),
        _AssetRow(
          leadingIconPath: 'assets/icons/document.png',
          title: 'Brand Guidelines',
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
              'Content Requirements',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        const _BulletText(
          'Submit analytics screenshots within 7 days after content goes live.',
        ),
        const _BulletText(
          'Share reach, impressions, link clicks and saves where applicable.',
        ),
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
              'Content Requirements',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        const _BulletText(
          'Brand may repost content on their official channels with credit.',
        ),
        const _BulletText(
          'Paid media whitelisting requires separate written approval.',
        ),
      ],
    );
  }
}

class _BrandAssets extends StatelessWidget {
  const _BrandAssets();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AssetRow(
          leadingIconPath: 'assets/icons/facebook.png',
          title: 'Facebook Page',
          subtitle: 'Brand’s official page link',
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
            // Checkbox + text
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
                        const TextSpan(text: 'You accept the '),
                        TextSpan(
                          text: 'user license agreement',
                          style: TextStyle(
                            color: AppPalette.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: ' &\n'),
                        TextSpan(
                          text: 'Terms and condition',
                          style: TextStyle(
                            color: AppPalette.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: ' of our app.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: onDecline,
                    btnText: 'Decline',
                    textColor: AppPalette.black,
                    btnColor: AppPalette.white,
                    borderColor: AppPalette.border1,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    onTap: onAccept,
                    btnText: 'Accept',
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
        gradient: LinearGradient(
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
                      'Payment Milestones',
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
                  'Progress',
                  style: TextStyle(fontSize: 10.sp, color: AppPalette.primary),
                ),
                const Spacer(),
                Text(
                  '$paidCount Of $totalCount Paid',
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
              _TotalEarningsCard(totalEarnings: totalEarnings, status: status),
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
  final String totalEarnings;
  final CampaignStatus status;

  const _TotalEarningsCard({required this.totalEarnings, required this.status});

  @override
  Widget build(BuildContext context) {
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
                  'Total Campaign Earnings',
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
                      gradient: LinearGradient(
                        colors: [AppPalette.white, AppPalette.thirdColor],
                      ),
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      border: Border.all(
                        color: AppPalette.secondary,
                        width: kBorderWidth0_5,
                      ),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.secondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 56.w,
            height: 56.w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [AppPalette.thirdColor, AppPalette.white],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '৳',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF315719),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
