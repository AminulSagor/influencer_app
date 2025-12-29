import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_controller/create_campaign_controller.dart';

import 'do_dont_box.dart';

class CampaignBriefBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const CampaignBriefBlock({super.key, required this.controller});

  static const _primary = Color(0xFF2F4F1F);

  List<String> _bulletFromMilestones(CreateCampaignController c) {
    if (c.milestones.isEmpty) return [];
    return c.milestones.map(
          (m) => m.subtitle?.trim().isNotEmpty == true ? '${m.title} • ${m.subtitle}'
          : m.title,
    ).toList();
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

    Widget titleRow(String icon, String title) {
      return Row(
        children: [

          Image.asset(icon, height: 20, width: 20),

          9.w.horizontalSpace,

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
          color: Colors.black54,
          fontWeight: FontWeight.w400
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
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
                Expanded(
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 12.sp,
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
          AppAssets.campaignGoals,
          'create_campaign_step6_campaign_goals'.tr,
        ),
        6.h.verticalSpace,
        para(goals),
        12.h.verticalSpace,

        titleRow(
          AppAssets.campaignGoals,
          'create_campaign_step6_product_service'.tr,
        ),
        6.h.verticalSpace,
        para(product),
        12.h.verticalSpace,

        titleRow(
          AppAssets.requirement,
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

        DoDontBox(
          title: 'create_campaign_step6_dos'.tr,
          lines: dos,
          positive: true,
        ),

        10.h.verticalSpace,

        DoDontBox(
          title: 'create_campaign_step6_donts'.tr,
          lines: donts,
          positive: false,
        ),
      ],
    );
  }
}