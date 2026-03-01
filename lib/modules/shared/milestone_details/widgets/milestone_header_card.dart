import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';

import '../../../../core/models/job_item.dart';
import '../../../../core/services/account_type_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';

class MilestoneHeaderCard extends StatelessWidget {
  final JobItem job;
  final Milestone milestone;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onBack;

  const MilestoneHeaderCard({
    super.key,
    required this.job,
    required this.milestone,
    required this.isExpanded,
    required this.onToggle,
    required this.onBack,
  });

  // String _platformLabel(String? rawPlatform) {
  //   final platform = (rawPlatform ?? '').trim();
  //   if (platform.isEmpty) return 'Platform';
  //   return platform
  //       .split(RegExp(r'[\s_-]+'))
  //       .map(
  //         (word) => word.isEmpty
  //             ? word
  //             : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
  //       )
  //       .join(' ');
  // }

  String _metricValue(int? value) {
    if (value == null || value <= 0) return '—';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isAgency = accountTypeService.isAdAgency;
    final isInfluencer = accountTypeService.isInfluencer;
    final isBrand = accountTypeService.isBrand;
    final isPaidAd = job.campaignType == CampaignType.paidAd;
    final targets = milestone.targets;
    final deliverableText = (milestone.deliverable?.trim().isNotEmpty ?? false)
        ? milestone.deliverable!.trim()
        : ((milestone.subtitle?.trim().isNotEmpty ?? false)
              ? milestone.subtitle!.trim()
              : '—');
    final promotionGoal = (milestone.promotionGoal ?? '').trim();
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        gradient: const LinearGradient(
          colors: [AppPalette.gradient1, AppPalette.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back,
                  size: 16.sp,
                  color: AppPalette.thirdColor,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Milestone Details',
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 32.sp,
                  color: AppPalette.thirdColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/mission.png',
                width: 29.w,
                height: 29.w,
                fit: BoxFit.cover,
                color: AppPalette.thirdColor,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For Milestone ${milestone.stepLabel}',
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    milestone.title,
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // COLLAPSED: stop here
          if (isExpanded) ...[
            SizedBox(height: 16.h),

            // CAMPAIGN NAME
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/online_ads.png',
                  width: 29.w,
                  height: 29.w,
                  fit: BoxFit.cover,
                  color: AppPalette.thirdColor,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campaign',
                      style: TextStyle(
                        color: AppPalette.thirdColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      job.title,
                      style: TextStyle(
                        color: AppPalette.thirdColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: AppPalette.border1, height: 1),
            SizedBox(height: 12.h),

            // CONTENT REQUIREMENTS
            _HeaderSectionTitle(
              iconPath: 'assets/icons/requirement.png',
              title: 'Content Requirements',
              subTitle: '• $deliverableText',
            ),
            SizedBox(height: 14.h),
            Divider(color: AppPalette.border1, height: 1),
            SizedBox(height: 14.h),

            // PROMOTION TARGET or Milestone Target
            _HeaderSectionTitle(
              iconPath: 'assets/icons/goal.png',
              title: isAgency ? 'Promotion Target' : 'Milestone Target',
            ),
            SizedBox(height: 6.h),
            if (isAgency || (isBrand && isPaidAd)) ...[
              Text(
                milestone.platform ??
                    'unknown', //_platformLabel(milestone.platform),
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              _TargetCard(title: 'Reach', value: _metricValue(targets?.reach)),
              if ((targets?.views ?? 0) > 0) ...[
                SizedBox(height: 8.h),
                _TargetCard(
                  title: 'Views',
                  value: _metricValue(targets?.views),
                ),
              ],
              if ((targets?.likes ?? 0) > 0) ...[
                SizedBox(height: 8.h),
                _TargetCard(
                  title: 'Reaction',
                  value: _metricValue(targets?.likes),
                ),
              ],
              if ((targets?.comments ?? 0) > 0) ...[
                SizedBox(height: 8.h),
                _TargetCard(
                  title: 'Comment',
                  value: _metricValue(targets?.comments),
                ),
              ],

              SizedBox(height: 18.h),
            ],
            if (isInfluencer || (isBrand && !isPaidAd))
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: .center,
                  spacing: 16.w,
                  runSpacing: 10.h,
                  children: [
                    _TargetCard(
                      title: 'Reach',
                      value: _metricValue(targets?.reach),
                      width: 115.w,
                      trailingIcon: Icons.remove_red_eye_rounded,
                    ),
                    _TargetCard(
                      title: 'Views',
                      value: _metricValue(targets?.views),
                      width: 115.w,
                      trailingIcon: Icons.play_arrow_rounded,
                    ),
                    _TargetCard(
                      title: 'Reaction',
                      value: _metricValue(targets?.likes),
                      width: 115.w,
                      trailingIcon: Icons.favorite_rounded,
                    ),
                    _TargetCard(
                      title: 'Comment',
                      value: _metricValue(targets?.comments),
                      width: 115.w,
                      trailingIcon: Icons.chat_bubble_rounded,
                    ),
                  ],
                ),
              ),
            if (promotionGoal.isNotEmpty) ...[
              _HeaderSectionTitle(
                iconPath: 'assets/icons/goal.png',
                title: 'Promotion Goal',
                subTitle: promotionGoal,
              ),

              SizedBox(height: 18.h),
            ],
            SizedBox(height: 20.h),
            Row(
              children: [
                Spacer(),
                Text(
                  '${(isInfluencer || (isBrand && !isPaidAd)) ? 'Influencer' : 'Agency'}: ${job.clientName}',
                  style: TextStyle(
                    color: AppPalette.thirdColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Divider(color: Colors.white.withOpacity(0.4), height: 1),
            SizedBox(height: 12.h),

            // CLIENT + PAYOUT
            Row(
              children: [
                Expanded(
                  child: Text(
                    isBrand ? '' : 'Payout On Approval',
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!isBrand)
                  Text(
                    formatCurrencyByLocale(
                      double.tryParse(milestone.amountLabel) ?? 0,
                    ),
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? trailingIcon;
  final double? width;

  const _TargetCard({
    required this.title,
    required this.value,
    this.trailingIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.thirdColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 15.sp, color: AppPalette.thirdColor),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSectionTitle extends StatelessWidget {
  final String iconPath;
  final String title;
  final String? subTitle;

  const _HeaderSectionTitle({
    required this.iconPath,
    required this.title,
    this.subTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 29.w,
          height: 29.w,
          fit: BoxFit.cover,
          color: AppPalette.thirdColor,
          filterQuality: FilterQuality.high,
        ),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppPalette.thirdColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subTitle!.isNotEmpty) ...[
              3.h.verticalSpace,

              Text(
                subTitle!,
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
