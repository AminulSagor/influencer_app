import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

import '../../../core/models/job_item.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import 'create_campaign_controller.dart';
import 'widgets/top_progress_section.dart';

class CreateCampaignStep6View extends GetView<CreateCampaignController> {
  const CreateCampaignStep6View({super.key});

  static const _bg = AppPalette.background;
  static const _primary = AppPalette.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
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
                      'create_campaign_step6_title'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                    6.h.verticalSpace,
                    Text(
                      'create_campaign_step6_subtitle'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppPalette.black,
                      ),
                    ),

                    16.h.verticalSpace,

                    _CampaignOverviewCard(controller: controller),

                    14.h.verticalSpace,

                    // Campaign Brief
                    _AccordionCard(
                      iconPath: 'assets/icons/terms_condition.png',
                      title: 'create_campaign_step6_campaign_brief'.tr,
                      initiallyExpanded: true,
                      child: _CampaignBriefBlock(controller: controller),
                    ),

                    14.h.verticalSpace,

                    // Campaign Milestones
                    _AccordionCard(
                      iconPath: 'assets/icons/mission.png',
                      title: 'create_campaign_step6_campaign_milestones'.tr,
                      initiallyExpanded: true,
                      child: _MilestonesBlock(controller: controller),
                    ),

                    14.h.verticalSpace,

                    // Content Assets
                    _AccordionCard(
                      iconPath: 'assets/icons/download.png',
                      title: 'create_campaign_step6_content_assets'.tr,
                      initiallyExpanded: true,
                      child: _ContentAssetsBlock(controller: controller),
                    ),

                    14.h.verticalSpace,

                    // Terms & Conditions
                    _AccordionCard(
                      iconPath: 'assets/icons/terms_condition.png',
                      title: 'create_campaign_step6_terms_conditions'.tr,
                      initiallyExpanded: true,
                      child: _TermsBlock(controller: controller),
                    ),

                    // Paid Ad -> Brand assets
                    Obx(() {
                      final isPaid =
                          controller.selectedType.value == CampaignType.paidAd;
                      if (!isPaid) return const SizedBox.shrink();

                      return Column(
                        children: [
                          14.h.verticalSpace,
                          _AccordionCard(
                            iconPath: 'assets/icons/download.png',
                            title: 'create_campaign_step6_brand_assets'.tr,
                            initiallyExpanded: true,
                            child: _BrandAssetsBlock(controller: controller),
                          ),
                        ],
                      );
                    }),

                    110.h.verticalSpace,
                  ],
                ),
              ),
            ),

            // bottom bar
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 18.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
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
                  Obx(() {
                    final disabled = !controller.canGoNext;
                    return Expanded(
                      child: CustomButton(
                        btnText: 'create_campaign_step6_get_quote'.tr,
                        btnColor: disabled
                            ? AppPalette.defaultFill
                            : AppPalette.secondary,
                        textColor: disabled
                            ? AppPalette.greyText
                            : AppPalette.white,
                        borderColor: Colors.transparent,
                        showBorder: false,
                        isDisabled: disabled,
                        onTap: controller.submitAndShowPlacementConfirmedPopup,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignOverviewCard extends StatelessWidget {
  final CreateCampaignController controller;
  const _CampaignOverviewCard({required this.controller});

  List<String> _platformIconPathsFromMilestones(CreateCampaignController c) {
    final keys = c.milestones
        .map((m) => (m.platform ?? '').trim().toLowerCase())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (keys.isEmpty) {
      return <String>[
        'assets/icons/instagram.png',
        'assets/icons/youTube.png',
        'assets/icons/tikTok.png',
      ];
    }

    return keys
        .map(_platformAssetPath)
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  String _platformAssetPath(String platformKey) {
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

    // fallback
    return 'assets/icons/instagram.png';
  }

  String safeTitle() {
    final t = controller.campaignName.value.trim();
    if (t.isNotEmpty) return t;
    return controller.campaignNameCtrl.text.trim().isNotEmpty
        ? controller.campaignNameCtrl.text.trim()
        : 'create_campaign_step6_campaign_title_fallback'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // label
          Text(
            'campaign_details_title'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
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
                      safeTitle(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      controller.totalBudgetText,
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

          SizedBox(height: 8.h),
          Divider(color: AppPalette.thirdColor.withAlpha(150), height: 1),
          SizedBox(height: 12.h),

          // Platforms row
          Obx(() {
            final iconPaths = _platformIconPathsFromMilestones(controller);

            return Row(
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
                ...iconPaths.map(
                  (path) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Image.asset(
                      path,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.cover,
                      color: AppPalette.thirdColor,
                    ),
                  ),
                ),
              ],
            );
          }),

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 22.sp,
                      color: AppPalette.thirdColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      controller.deadlineLabelForStep6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
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

class _AccordionCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final bool initiallyExpanded;
  final Widget child;

  const _AccordionCard({
    required this.iconPath,
    required this.title,
    required this.initiallyExpanded,
    required this.child,
  });

  static const _primary = AppPalette.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
          iconColor: _primary,
          collapsedIconColor: _primary,
          title: Row(
            children: [
              Image.asset(iconPath, color: _primary, width: 23.w),
              10.w.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _CampaignBriefBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const _CampaignBriefBlock({required this.controller});

  List<String> _bulletFromMilestones(CreateCampaignController c) {
    if (c.milestones.isEmpty) return [];
    return c.milestones
        .map(
          (m) => m.subtitle?.trim().isNotEmpty == true
              ? '${m.platform} • ${m.subtitle}'
              : m.title,
        )
        .toList();
  }

  List<String> _splitLines(String s) {
    final raw = s
        .split(RegExp(r'[\n•\-]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return raw.isEmpty ? [] : raw;
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    final goals = c.campaignGoals.value.trim();
    final product = c.productServiceDetails.value.trim();

    // optional (from your step3 controllers)
    final dos = _splitLines(c.dosCtrl.text);
    final donts = _splitLines(c.dontsCtrl.text);

    final reqs = _bulletFromMilestones(c);

    Widget titleRow(String iconPath, String title) {
      return Row(
        children: [
          Image.asset(
            iconPath,
            width: 20.w,
            height: 20.w,
            color: AppPalette.primary,
          ),
          6.w.horizontalSpace,
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
      );
    }

    Widget para(String text) {
      return Text(
        text.isEmpty ? '-' : text,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppPalette.subtext,
          height: 1.35,
        ),
      );
    }

    Widget bullet(List<String> lines) {
      if (lines.isEmpty) {
        return Text(
          '-',
          style: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((e) {
          return Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
                ),
                Expanded(
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.subtext,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleRow(
          'assets/icons/goal.png',
          'create_campaign_step6_campaign_goals'.tr,
        ),
        6.h.verticalSpace,
        para(goals),
        12.h.verticalSpace,

        titleRow(
          'assets/icons/goal.png',
          'create_campaign_step6_product_service'.tr,
        ),
        6.h.verticalSpace,
        para(product),
        12.h.verticalSpace,

        titleRow(
          'assets/icons/requirement.png',
          'create_campaign_step6_content_requirements'.tr,
        ),
        6.h.verticalSpace,
        bullet(reqs),
        12.h.verticalSpace,

        Text(
          'create_campaign_step6_dos_donts'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,

        _DoDontBox(
          title: 'create_campaign_step6_dos'.tr,
          lines: dos,
          positive: true,
        ),
        10.h.verticalSpace,
        _DoDontBox(
          title: 'create_campaign_step6_donts'.tr,
          lines: donts,
          positive: false,
        ),
      ],
    );
  }
}

class _DoDontBox extends StatelessWidget {
  final String title;
  final List<String> lines;
  final bool positive;

  const _DoDontBox({
    required this.title,
    required this.lines,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final bg = positive ? AppPalette.color1fill : AppPalette.color2fill;
    final border = positive ? AppPalette.color1stroke : AppPalette.color2stroke;
    final icon = positive ? Icons.check_circle_outline : Icons.cancel_outlined;
    final accent = positive ? AppPalette.color1text : AppPalette.color2text;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: border, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18.sp),
              8.w.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          8.h.verticalSpace,
          if (lines.isEmpty)
            Text(
              '-',
              style: TextStyle(fontSize: 10.sp, color: accent.withOpacity(.8)),
            )
          else
            ...lines.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: accent.withOpacity(.85),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: accent.withOpacity(.85),
                          height: 1.35,
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

class _MilestonesBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const _MilestonesBlock({required this.controller});

  static const _primary = AppPalette.primary;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final ms = c.milestones.toList(growable: false);

      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
              gradient: LinearGradient(
                colors: [AppPalette.thirdColor, AppPalette.white],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'create_campaign_step6_total_budget'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      6.h.verticalSpace,
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          c.totalBudgetText,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ),
                      4.h.verticalSpace,
                      Text(
                        'create_campaign_step6_budget_including_vat'.trParams({
                          'vat': '${(c.vatPercent * 100).round()}%',
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppPalette.black,
                        ),
                      ),
                    ],
                  ),
                ),
                10.w.horizontalSpace,
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppPalette.secondary,
                      width: kBorderWidth0_5,
                    ),
                    gradient: LinearGradient(
                      colors: [AppPalette.thirdColor, AppPalette.white],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Center(
                    child: Text(
                      '৳',
                      style: TextStyle(
                        color: AppPalette.secondary,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.h.verticalSpace,
          Divider(color: AppPalette.secondary.withAlpha(128), height: 1),
          12.h.verticalSpace,

          if (ms.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '-',
                style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
              ),
            )
          else
            ...ms.map(
              (m) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _MilestoneCard(milestone: m),
              ),
            ),
        ],
      );
    });
  }
}

class _MilestoneCard extends StatelessWidget {
  final Milestone milestone;

  const _MilestoneCard({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.secondary, width: kBorderWidth0_5),
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
              milestone.stepLabel,
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
                  milestone.title,
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
                  milestone.subtitle ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: AppPalette.greyText),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          Text(
            milestone.dayLabel ?? '-',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final CreateCampaignController controller;
  final JobAsset jobAsset;

  const _AssetTile({required this.controller, required this.jobAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [AppPalette.white, AppPalette.white, AppPalette.thirdColor],
        ),
      ),
      child: Row(
        children: [
          Icon(
            controller.iconForAsset(jobAsset.kind),
            color: AppPalette.secondary,
            size: 26.sp,
          ),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobAsset.title,
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
                  jobAsset.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.secondary.withAlpha(153),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          InkWell(
            onTap: () {},
            child: Image.asset(
              'assets/icons/download.png',
              width: 23.w,
              color: AppPalette.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentAssetsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const _ContentAssetsBlock({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final list = c.contentAssets.toList(growable: false);

      if (list.isEmpty) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '-',
            style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
          ),
        );
      }

      return Column(
        children: list.map((a) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _AssetTile(controller: c, jobAsset: a),
          );
        }).toList(),
      );
    });
  }
}

class _TermsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const _TermsBlock({required this.controller});

  static const _primary = AppPalette.primary;

  Widget _item({
    required String iconPath,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(iconPath, width: 20.w, color: _primary),
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
                  fontWeight: FontWeight.w500,
                  color: _primary,
                ),
              ),
              6.h.verticalSpace,
              Text(
                value.trim().isEmpty ? '-' : value.trim(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.subtext,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Column(
      children: [
        _item(
          iconPath: 'assets/icons/presentation.png',
          title: 'create_campaign_step6_reporting_requirements'.tr,
          value: c.reportingRequirements.value,
        ),
        12.h.verticalSpace,
        _item(
          iconPath: 'assets/icons/copyright.png',
          title: 'create_campaign_step6_usage_rights'.tr,
          value: c.usageRights.value,
        ),
      ],
    );
  }
}

class _BrandAssetsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const _BrandAssetsBlock({required this.controller});

  static const _secondary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final list = c.brandAssets.toList(growable: false);

      if (list.isEmpty) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '-',
            style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
          ),
        );
      }

      return Column(
        children: List.generate(list.length, (i) {
          final b = list[i];
          final subtitle = (b.value ?? '').trim().isNotEmpty
              ? b.value!.trim()
              : 'create_campaign_brand_asset_value_hint'.tr;

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () => c.openEditBrandAssetDialog(i),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadius.r),
                  border: Border.all(
                    color: AppPalette.border1,
                    width: kBorderWidth0_5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      AppPalette.white,
                      AppPalette.white,
                      AppPalette.thirdColor,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: _secondary.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.link, size: 18.sp, color: _secondary),
                    ),
                    12.w.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: _secondary,
                            ),
                          ),
                          2.h.verticalSpace,
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _secondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.w.horizontalSpace,
                    InkWell(
                      onTap: () {
                        if (i >= 0 && i < c.brandAssets.length) {
                          c.brandAssets.removeAt(i);
                        }
                      },
                      child: Icon(
                        Icons.close,
                        color: _secondary.withOpacity(.55),
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}
