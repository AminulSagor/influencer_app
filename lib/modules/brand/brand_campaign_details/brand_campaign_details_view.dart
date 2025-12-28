import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

                // ✅ PaidAd gets tab layout like screenshot
                Obx(() {
                  controller.campaignType.value;
                  final isPaidAd = controller.isPaidAd;
                  if (!isPaidAd) {
                    return Column(
                      children: [
                        _CampaignProgressCard(),
                        12.h.verticalSpace,
                        _QuoteDetailsCard(),
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
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PaidAdTabPills(),
                      12.h.verticalSpace,

                      Obx(() {
                        final tab = controller.paidAdTabIndex.value;

                        // 0 = Agency bids (screenshot 2)
                        if (tab == 0) return _AgencyBidsTab();

                        // 1 = Campaign details (screenshot 1)
                        return Column(
                          children: [
                            _CampaignProgressCard(),
                            12.h.verticalSpace,
                            _QuoteDetailsCard(),
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
                            12.h.verticalSpace,
                            _BrandAssetsCard(),
                          ],
                        );
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
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14.r),
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
    final green = AppPalette.primary;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: green.withOpacity(.85),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(Icons.campaign_outlined, color: Colors.white, size: 20.sp),
              10.w.horizontalSpace,
              Expanded(
                child: Text(
                  'brand_campaign_details_campaign_details'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
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
              Expanded(
                child: Obx(() {
                  return Text(
                    controller.campaignTitle.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }),
              ),
              10.w.horizontalSpace,
              Obx(() {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    controller.budgetText.value,
                    style: TextStyle(
                      color: const Color(0xFFDCE8CB),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              }),
            ],
          ),
          10.h.verticalSpace,

          // ✅ PaidAd: Targeting row | other: Influencers row
          Obx(() {
            controller.campaignType.value;
            final isPaidAd = controller.isPaidAd;
            if (isPaidAd) {
              return Row(
                children: [
                  Text(
                    'brand_campaign_details_targeting'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  10.w.horizontalSpace,
                  _Chip(
                    text: controller.targetingText.value.trim().isEmpty
                        ? 'Crowd'
                        : controller.targetingText.value,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Text(
                  'brand_campaign_details_influencers'.tr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
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
          Divider(color: Colors.white.withOpacity(.25), height: 1),
          10.h.verticalSpace,

          // Platforms
          Row(
            children: [
              Text(
                'brand_campaign_details_platforms'.tr,
                style: TextStyle(
                  color: Colors.white.withOpacity(.85),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              10.w.horizontalSpace,
              Obx(() {
                return Row(
                  children: controller.platforms
                      .map(
                        (ic) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _MiniPlatform(icon: ic),
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
                color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(.25)),
              ),
              child: Column(
                children: [
                  Text(
                    'brand_campaign_details_deadline'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  6.h.verticalSpace,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${controller.daysRemaining.value} ${'brand_campaign_details_days_remaining'.tr}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  4.h.verticalSpace,
                  Text(
                    controller.deadlineDateText.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: Colors.white.withOpacity(.22)),
                ),
                child: Text(
                  controller.budgetStatusText.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.92),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withOpacity(.22)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniPlatform extends StatelessWidget {
  final IconData icon;
  const _MiniPlatform({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: Colors.white.withOpacity(.22)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16.sp, color: Colors.white),
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
            icon: Icons.timelapse_rounded,
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
                _ProgressRow(
                  icon: Icons.task_alt_rounded,
                  title: 'brand_campaign_details_completed'.tr,
                  subtitle: 'brand_campaign_details_completed_sub'.tr,
                  active: isActive(CampaignProgressStep.completed),
                ),
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
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
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
                  icon: Icons.receipt_long_rounded,
                  title: 'brand_campaign_details_quote_details'.tr,
                ),
              ),
              Icon(
                Icons.currency_exchange_rounded,
                size: 18.sp,
                color: AppPalette.secondary,
              ),
            ],
          ),
          12.h.verticalSpace,
          Obx(() {
            return Column(
              children: [
                _KVRow(
                  k: 'brand_campaign_details_base_campaign_budget'.tr,
                  v: '৳${controller.baseBudget.value}',
                ),
                6.h.verticalSpace,
                _KVRow(
                  k: 'brand_campaign_details_vat_tax'.tr,
                  v: '৳${controller.vatAmount.value}',
                ),
                10.h.verticalSpace,
                Divider(color: AppPalette.border1, height: 1),
                10.h.verticalSpace,
                _KVRow(
                  k: 'brand_campaign_details_total_campaign_cost'.tr,
                  v: '৳${controller.totalCost}',
                  strong: true,
                ),
              ],
            );
          }),
          12.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  btnText: 'brand_campaign_details_requote'.tr,
                  btnColor: AppPalette.white,
                  borderColor: AppPalette.border1,
                  textColor: AppPalette.black,
                  onTap: controller.onRequestQuote,
                ),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: CustomButton(
                  btnText: 'brand_campaign_details_accept_quote'.tr,
                  btnColor: AppPalette.primary,
                  borderColor: Colors.transparent,
                  showBorder: false,
                  textColor: AppPalette.white,
                  onTap: controller.onAcceptQuote,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String k;
  final String v;
  final bool strong;
  const _KVRow({required this.k, required this.v, this.strong = false});

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
              fontSize: strong ? 12.5.sp : 12.sp,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ),
        10.w.horizontalSpace,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            v,
            style: TextStyle(
              fontSize: strong ? 14.sp : 12.5.sp,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
              color: AppPalette.secondary,
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
                    icon: Icons.flag_rounded,
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
            if (!controller.milestonesExpanded.value)
              return const SizedBox.shrink();

            final list = controller.milestones.toList(growable: false);

            final completedCount = list
                .where((m) => m.isApproved || m.isPaid)
                .length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DropdownPill(text: controller.milestoneStatusLabel.value),
                10.h.verticalSpace,
                Row(
                  children: [
                    Text(
                      'brand_campaign_details_progress'.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.greyText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$completedCount ${'brand_campaign_details_of'.tr} ${list.length} ${'brand_campaign_details_completed_small'.tr}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.greyText,
                      ),
                    ),
                  ],
                ),
                10.h.verticalSpace,
                ...list.map((m) => _MilestoneTile(m: m)).toList(),
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
        borderRadius: BorderRadius.circular(10.r),
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
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
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

class _MilestoneTile extends StatelessWidget {
  final Milestone m;
  const _MilestoneTile({required this.m});

  String _statusText(MilestoneStatus s) {
    switch (s) {
      case MilestoneStatus.todo:
        return 'brand_campaign_details_pending'.tr;
      case MilestoneStatus.inReview:
        return 'brand_campaign_details_in_review'.tr;
      case MilestoneStatus.paid:
      case MilestoneStatus.approved:
      case MilestoneStatus.partialPaid:
        return 'brand_campaign_details_completed'.tr;
      case MilestoneStatus.declined:
        return 'brand_campaign_details_declined'.tr;
    }
  }

  ({
    Color bg,
    Color border,
    Color pillBg,
    Color pillBorder,
    Color pillText,
    Color titleColor,
  })
  _style(MilestoneStatus s) {
    switch (s) {
      case MilestoneStatus.approved:
      case MilestoneStatus.paid:
      case MilestoneStatus.partialPaid:
        return (
          bg: const Color(0xFFEFF8E8),
          border: const Color(0xFFBFD7A5),
          pillBg: const Color(0xFFBFD7A5),
          pillBorder: const Color(0xFFBFD7A5),
          pillText: AppPalette.primary,
          titleColor: AppPalette.primary,
        );

      case MilestoneStatus.inReview:
        return (
          bg: const Color(0xFFFFF4E6),
          border: const Color(0xFFF3C68C),
          pillBg: const Color(0xFFFFE7C6),
          pillBorder: const Color(0xFFF3C68C),
          pillText: const Color(0xFFB36B00),
          titleColor: const Color(0xFFB36B00),
        );

      case MilestoneStatus.declined:
        return (
          bg: const Color(0xFFFFEBEB),
          border: const Color(0xFFFFB9B9),
          pillBg: const Color(0xFFFFD6D6),
          pillBorder: const Color(0xFFFFB9B9),
          pillText: const Color(0xFFB32020),
          titleColor: const Color(0xFFB32020),
        );

      case MilestoneStatus.todo:
        return (
          bg: AppPalette.white,
          border: AppPalette.border1,
          pillBg: AppPalette.defaultFill,
          pillBorder: AppPalette.border1,
          pillText: AppPalette.greyText,
          titleColor: AppPalette.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText(m.status);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _style(m.status).bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: AppPalette.defaultFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              m.stepLabel,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppPalette.greyText,
              ),
            ),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.primary,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  m.subtitle ?? '',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusPill(text: statusText),
              6.h.verticalSpace,
              Text(
                m.dayLabel ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppPalette.defaultFill,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: AppPalette.greyText,
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
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 24.sp,
                      color: filled ? AppPalette.secondary : AppPalette.border1,
                    ),
                  ),
                );
              }),
            );
          }),
          10.h.verticalSpace,
          Text(
            'brand_campaign_details_provide_rating'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.greyText,
            ),
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
                    icon: Icons.article_rounded,
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
                  icon: Icons.gps_fixed_rounded,
                  title: 'brand_campaign_details_campaign_goals'.tr,
                  text: controller.campaignGoals.value,
                ),
                12.h.verticalSpace,
                _BriefBlock(
                  icon: Icons.emoji_objects_rounded,
                  title: 'brand_campaign_details_product_service'.tr,
                  text: controller.productServiceDetails.value,
                ),
                12.h.verticalSpace,
                _BulletBlock(
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'brand_campaign_details_content_requirements'.tr,
                  bullets: controller.contentRequirements.toList(
                    growable: false,
                  ),
                ),
                12.h.verticalSpace,
                Text(
                  'brand_campaign_details_dos_donts'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
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
  final IconData icon;
  final String title;
  final String text;
  const _BriefBlock({
    required this.icon,
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
    );
  }
}

class _BulletBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> bullets;
  const _BulletBlock({
    required this.icon,
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
                      fontSize: 11.5.sp,
                      height: 1.35,
                      color: AppPalette.greyText,
                      fontWeight: FontWeight.w600,
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
    final tint = isDo ? const Color(0xFFE9FFF0) : const Color(0xFFFFECEC);
    final border = isDo ? const Color(0xFFB6F0C6) : const Color(0xFFFFB9B9);
    final titleColor = isDo ? const Color(0xFF1B7F3A) : const Color(0xFFB32020);
    final icon = isDo
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14.r),
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
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: titleColor.withOpacity(.9),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        height: 1.35,
                        color: titleColor.withOpacity(.85),
                        fontWeight: FontWeight.w700,
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
                    icon: Icons.folder_open_rounded,
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
            if (!controller.assetsExpanded.value)
              return const SizedBox.shrink();
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
                    icon: Icons.gavel_rounded,
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
            icon: Icons.inventory_2_outlined,
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
  final IconData icon;
  final String title;
  const _CardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppPalette.primary),
        10.w.horizontalSpace,
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w900,
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
            text: 'এজেন্সির দরপত্র',
            active: selected == 0,
            onTap: () => controller.setPaidAdTab(0),
          ),
          10.w.horizontalSpace,
          pill(
            text: 'ক্যাম্পেইনের বিবরণ',
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
                  'এজেন্সির দরপত্র (${controller.agencyOffers.length})',
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
                      'Low To High',
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
                  final fee = (total * (o.agencyFeePercent / 100)).round();
                  final excl = (total - fee).clamp(0, total);
                  final usd = _fxRate <= 0 ? 0 : (excl / _fxRate);

                  return _AgencyOfferCard(
                    name: o.name,
                    agencyFeePercent: o.agencyFeePercent,
                    fxRate: _fxRate,
                    agencyFeeBdt: fee,
                    budgetExclAgencyBdt: excl,
                    usdValue: usd.toDouble(),
                    onAcceptAndPay: controller.onAcceptQuote, // keep your flow
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
                      'Of 30',
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
                        'পরবর্তী',
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
                    'ডলার রেট',
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
                  'এজেন্সি ফি (%)',
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
                _miniRow('এজেন্সি ফি (৳)', _bdt(agencyFeeBdt)),
                6.h.verticalSpace,
                _miniRow('এজেন্সি ফি ছাড়া বাজেট', _bdt(budgetExclAgencyBdt)),
                6.h.verticalSpace,
                _miniRow('ডলার রেট (৳/\$)', fxRate.toStringAsFixed(2)),
                6.h.verticalSpace,
                _miniRow('ডলার (\$)', usdValue.toStringAsFixed(2)),
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
                'দরপত্র গ্রহণ ও পেমেন্ট করুন',
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
