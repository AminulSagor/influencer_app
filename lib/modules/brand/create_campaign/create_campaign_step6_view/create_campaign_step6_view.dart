import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step6_view/widgets/accordion_card.dart';

import '../../../../core/models/job_item.dart';
import '../create_campaign_controller/create_campaign_controller.dart' hide CampaignType;
import 'widgets/green_campaign_details_card.dart';

class CreateCampaignStep6View extends GetView<CreateCampaignController> {
  const CreateCampaignStep6View({super.key});

  static const _bg = Color(0xFFF6F7F7);
  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    18.h.verticalSpace,

                    // top header
                    Obx(() {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.stepText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            c.progressPercentText,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      );
                    }),

                    10.h.verticalSpace,

                    Obx(() {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(99.r),
                        child: LinearProgressIndicator(
                          value: c.progress,
                          minHeight: 10.h,
                          backgroundColor: const Color(0xFFD7E0CC),
                          valueColor: const AlwaysStoppedAnimation(AppPalette.primary),
                        ),
                      );
                    }),

                    18.h.verticalSpace,

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'create_campaign_step6_title'.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.primary,
                            ),
                          ),
                        ),
                        10.w.horizontalSpace,
                        _DraftButton(onTap: c.saveAsDraft),
                      ],
                    ),

                    6.h.verticalSpace,

                    Text(
                      'create_campaign_step6_subtitle'.tr,
                      style: TextStyle(fontSize: 10.sp, color: AppPalette.black,fontWeight: FontWeight.w300,),
                    ),

                    16.h.verticalSpace,

                    // green campaign details card (matching your screenshots)
                    GreenCampaignDetailsCard(controller: c),

                    13.h.verticalSpace,

                    // Campaign Brief
                    AccordionCard(
                      icon: Icons.description_outlined,
                      title: 'create_campaign_step6_campaign_brief'.tr,
                      initiallyExpanded: true,
                      child: _CampaignBriefBlock(controller: c),
                    ),

                    14.h.verticalSpace,

                    // Campaign Milestones
                    AccordionCard(
                      icon: Icons.flag_outlined,
                      title: 'create_campaign_step6_campaign_milestones'.tr,
                      initiallyExpanded: false,
                      child: _MilestonesBlock(controller: c),
                    ),

                    14.h.verticalSpace,

                    // Content Assets
                    AccordionCard(
                      icon: Icons.download_outlined,
                      title: 'create_campaign_step6_content_assets'.tr,
                      initiallyExpanded: false,
                      child: _ContentAssetsBlock(controller: c),
                    ),

                    14.h.verticalSpace,

                    // Terms & Conditions
                    AccordionCard(
                      icon: Icons.list_alt_outlined,
                      title: 'create_campaign_step6_terms_conditions'.tr,
                      initiallyExpanded: false,
                      child: _TermsBlock(controller: c),
                    ),

                    // Paid Ad -> Brand assets
                    Obx(() {
                      final isPaid =
                          c.selectedType.value == CampaignType.paidAd;
                      if (!isPaid) return const SizedBox.shrink();

                      return Column(
                        children: [
                          14.h.verticalSpace,
                          AccordionCard(
                            icon: Icons.download_outlined,
                            title: 'create_campaign_step6_brand_assets'.tr,
                            initiallyExpanded: false,
                            child: _BrandAssetsBlock(controller: c),
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
                    child: OutlinedButton(
                      onPressed: c.onPrevious,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('common_previous'.tr),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: c.canGoNext
                          ? c.submitAndShowPlacementConfirmedPopup
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        backgroundColor: _primary.withOpacity(
                          c.canGoNext ? 0.75 : 0.35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('create_campaign_step6_get_quote'.tr),
                      ),
                    ),
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

class _DraftButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DraftButton({required this.onTap});

  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _primary.withOpacity(.7),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          'create_campaign_save_draft'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CampaignBriefBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const _CampaignBriefBlock({required this.controller});

  static const _primary = Color(0xFF2F4F1F);

  List<String> _bulletFromMilestones(CreateCampaignController c) {
    if (c.milestones.isEmpty) return [];
    return c.milestones
        .map(
          (m) => m.subtitle?.trim().isNotEmpty == true
              ? '${m.title} • ${m.subtitle}'
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

    Widget titleRow(IconData icon, String title) {
      return Row(
        children: [
          Icon(icon, size: 18.sp, color: _primary),
          8.w.horizontalSpace,
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w800,
                color: _primary,
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
          fontSize: 12.5.sp,
          color: Colors.black54,
          height: 1.35,
        ),
      );
    }

    Widget bullet(List<String> lines) {
      if (lines.isEmpty) {
        return Text(
          '-',
          style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
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
                  style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
                ),
                Expanded(
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: Colors.black54,
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
          Icons.track_changes_outlined,
          'create_campaign_step6_campaign_goals'.tr,
        ),
        6.h.verticalSpace,
        para(goals),
        12.h.verticalSpace,

        titleRow(
          Icons.local_offer_outlined,
          'create_campaign_step6_product_service'.tr,
        ),
        6.h.verticalSpace,
        para(product),
        12.h.verticalSpace,

        titleRow(
          Icons.list_alt_outlined,
          'create_campaign_step6_content_requirements'.tr,
        ),
        6.h.verticalSpace,
        bullet(reqs),
        12.h.verticalSpace,

        Text(
          'create_campaign_step6_dos_donts'.tr,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: _primary,
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
    final bg = positive ? const Color(0xFFE8F6EA) : const Color(0xFFFFE7E7);
    final border = positive ? const Color(0xFFBFE6C6) : const Color(0xFFF2B9B9);
    final icon = positive ? Icons.check_circle_outline : Icons.cancel_outlined;
    final accent = positive ? const Color(0xFF1C7C3E) : const Color(0xFFCC2B2B);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: border),
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          8.h.verticalSpace,
          if (lines.isEmpty)
            Text(
              '-',
              style: TextStyle(
                fontSize: 12.5.sp,
                color: accent.withOpacity(.8),
              ),
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
                        fontSize: 12.5.sp,
                        color: accent.withOpacity(.85),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 12.5.sp,
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

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);

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
              color: const Color(0xFFF7FAF3),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _softBorder),
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
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      6.h.verticalSpace,
                      Row(
                        children: [
                          Text(
                            '৳',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: _primary,
                            ),
                          ),
                          6.w.horizontalSpace,
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                c.totalBudgetText,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: _primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.h.verticalSpace,
                      Text(
                        'create_campaign_step6_budget_including_vat'.trParams({
                          'vat': '${(c.vatPercent * 100).round()}%',
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                10.w.horizontalSpace,
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: _softBorder),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '৳',
                    style: TextStyle(
                      color: _primary.withOpacity(.8),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                child: _MilestoneTile(m: m),
              ),
            ),
        ],
      );
    });
  }
}

class _MilestoneTile extends StatelessWidget {
  final Milestone m;
  const _MilestoneTile({required this.m});

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: _primary.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                m.stepLabel,
                style: TextStyle(
                  color: _primary.withOpacity(.85),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
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
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: _primary.withOpacity(.85),
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  m.subtitle ?? m.deliverable ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          if ((m.dayLabel ?? '').isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _primary.withOpacity(.07),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _softBorder),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  m.dayLabel!,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: _primary.withOpacity(.75),
                  ),
                ),
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

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

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
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _softBg,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _softBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    c.iconForAsset(a.kind),
                    color: _primary.withOpacity(.75),
                    size: 24.sp,
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w800,
                            color: _primary.withOpacity(.80),
                          ),
                        ),
                        2.h.verticalSpace,
                        Text(
                          a.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: _primary.withOpacity(.55),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  10.w.horizontalSpace,
                  Icon(
                    Icons.file_download_outlined,
                    color: _primary.withOpacity(.55),
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _TermsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const _TermsBlock({required this.controller});

  static const _primary = Color(0xFF2F4F1F);

  Widget _item({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primary, size: 18.sp),
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
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              6.h.verticalSpace,
              Text(
                value.trim().isEmpty ? '-' : value.trim(),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: Colors.black54,
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
          icon: Icons.analytics_outlined,
          title: 'create_campaign_step6_reporting_requirements'.tr,
          value: c.reportingRequirements.value,
        ),
        12.h.verticalSpace,
        _item(
          icon: Icons.copyright_outlined,
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

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

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
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _softBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: _softBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(.18),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.facebook,
                        size: 18.sp,
                        color: _primary.withOpacity(.75),
                      ),
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
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: _primary.withOpacity(.80),
                            ),
                          ),
                          2.h.verticalSpace,
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: _primary.withOpacity(.55),
                              fontWeight: FontWeight.w700,
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
                        color: _primary.withOpacity(.55),
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
