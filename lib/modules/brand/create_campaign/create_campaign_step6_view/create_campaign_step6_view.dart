import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step5_view/widgets/draft_button.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step6_view/widgets/accordion_card.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step6_view/widgets/campaign_brief_block.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step6_view/widgets/milestones_block.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step6_view/widgets/terms_block.dart';

import '../../../../core/models/job_item.dart';
import '../create_campaign_controller/create_campaign_controller.dart' hide CampaignType;
import 'widgets/brand_assets_block.dart';
import 'widgets/content_assets_block.dart';
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

                        DraftButton(onTap: c.saveAsDraft),
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
                      icon: AppAssets.termsCondition,
                      title: 'create_campaign_step6_campaign_brief'.tr,
                      initiallyExpanded: true,
                      child: CampaignBriefBlock(controller: c),
                    ),

                    14.h.verticalSpace,

                    // Campaign Milestones
                    AccordionCard(
                      icon: AppAssets.mission,
                      title: 'create_campaign_step6_campaign_milestones'.tr,
                      initiallyExpanded: false,
                      child: MilestonesBlock(controller: c),
                    ),

                    14.h.verticalSpace,

                    // Content Assets
                    AccordionCard(
                      icon: AppAssets.download,
                      title: 'create_campaign_step6_content_assets'.tr,
                      initiallyExpanded: false,
                      child: ContentAssetsBlock(controller: c),
                    ),

                    14.h.verticalSpace,

                    // Terms & Conditions
                    AccordionCard(
                      icon: AppAssets.termsCondition,
                      title: 'create_campaign_step6_terms_conditions'.tr,
                      initiallyExpanded: false,
                      child: TermsBlock(controller: c),
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
                            icon: AppAssets.download,
                            title: 'create_campaign_step6_brand_assets'.tr,
                            initiallyExpanded: false,
                            child: BrandAssetsBlock(controller: c),
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
                        child: Text('create_campaign_step6_get_quote'.tr, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10, color: AppPalette.white),),
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
