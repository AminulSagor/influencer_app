import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../create_campaign_controller/create_campaign_controller.dart';
import 'guideline_card.dart';

class DosDontSection extends StatelessWidget {
  final CreateCampaignController controller;
  const DosDontSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GuidelineCard(
          title: 'create_campaign_dos_label'.tr,
          icon: AppAssets.checkMark,
          tint: const Color(0xFFEFFAF3),
          border: const Color(0xFFBFE9CB),
          titleColor: const Color(0xFF1B7F3A),
          controller: controller.dosCtrl,
          onChanged: controller.onDosChanged,
          exampleHint: 'create_campaign_dos_hint'.tr,
        ),

        12.h.verticalSpace,

        GuidelineCard(
          title: 'create_campaign_donts_label'.tr,
          icon: AppAssets.cancelOutline,
          tint: const Color(0xFFFFF0F0),
          border: const Color(0xFFFFC5C5),
          titleColor: const Color(0xFFB32020),
          controller: controller.dontsCtrl,
          onChanged: controller.onDontsChanged,
          exampleHint: 'create_campaign_donts_hint'.tr,
        ),
      ],
    );
  }
}
