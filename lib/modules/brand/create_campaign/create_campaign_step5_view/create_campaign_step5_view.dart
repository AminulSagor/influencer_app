import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step5_view/widgets/dashed_button.dart';

import '../../../../core/models/job_item.dart';
import '../create_campaign_controller/create_campaign_controller.dart';
import 'widgets/asset_tile.dart';
import 'widgets/brand_asset_tile.dart';
import 'widgets/draft_button.dart';
import 'widgets/section_card.dart';

class CreateCampaignStep5View extends GetView<CreateCampaignController> {
  const CreateCampaignStep5View({super.key});

  static const _bg = Color(0xFFF6F7F7);
  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);

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

                    // top header (same style as your earlier steps)
                    Obx(() {
                      return Row(
                        children: [

                          Expanded(
                            child: Text(
                              c.stepText,
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
                          valueColor: const AlwaysStoppedAnimation(_primary),
                        ),
                      );
                    }),

                    18.h.verticalSpace,

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: Text(
                            'create_campaign_step5_title'.tr,
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
                      'create_campaign_step5_subtitle'.tr,
                      style: TextStyle(fontSize: 10.sp,fontWeight: FontWeight.w300, color: AppPalette.black),
                    ),

                    35.h.verticalSpace,

                    SectionCard(
                      title: 'create_campaign_content_assets'.tr,
                      icon: AppAssets.download,
                      child: Obx(() {
                        return Column(
                          children: [
                            ...List.generate(c.contentAssets.length, (i) {
                              final a = c.contentAssets[i];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: AssetTile(
                                  icon: c.iconForAsset(a.kind),
                                  title: a.title,
                                  subtitle: a.meta,
                                  onRemove: () => c.removeContentAsset(i),
                                ),
                              );
                            }),
                            DashedButton(
                              text: 'create_campaign_upload_another_asset'.tr,
                              // icon: Icons.upload_outlined,
                              onTap: c.openAddContentAssetDialog,
                            ),
                          ],
                        );
                      }),
                    ),

                    14.h.verticalSpace,

                    // influencerPromotion -> sample section
                    Obx(() {
                      final isInfluencer = c.selectedType.value ==
                          CampaignType.influencerPromotion;
                      if (!isInfluencer) return const SizedBox.shrink();

                      return SectionCard(
                        title: 'create_campaign_need_sample_title'.tr,
                        icon: AppAssets.product,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'create_campaign_need_sample_label'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.secondary,
                              ),
                            ),
                            Obx(() {
                              return Switch(
                                value: c.needToSendSample.value,
                                activeColor: Colors.white,
                                activeTrackColor: AppPalette.primary.withOpacity(.65),
                                onChanged: c.toggleNeedSample,
                              );
                            }),
                          ],
                        ),
                      );
                    }),

                    // paidAd -> brand assets section
                    Obx(() {
                      final isPaid =
                          c.selectedType.value == CampaignType.paidAd;
                      if (!isPaid) return const SizedBox.shrink();

                      return Column(
                        children: [
                          14.h.verticalSpace,
                          SectionCard(
                            title: 'create_campaign_brand_assets'.tr,
                            icon: AppAssets.download,
                            child: Obx(() {
                              return Column(
                                children: [
                                  ...List.generate(c.brandAssets.length, (i) {
                                    final b = c.brandAssets[i];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: BrandAssetTile(
                                        title: b.title,
                                        subtitle: b.value?.isNotEmpty == true ? b.value!
                                            : 'create_campaign_brand_asset_value_hint'.tr,
                                        onTap: () => c.openEditBrandAssetDialog(i),
                                      ),
                                    );
                                  }),
                                  DashedButton(
                                    text: 'create_campaign_add_brand_asset'.tr,
                                    // icon: Icons.add,
                                    onTap: c.openAddBrandAssetDialog,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      );
                    }),

                    110.h.verticalSpace, // space for bottom bar
                  ],
                ),
              ),
            ),

            // bottom bar
            Obx(() {
              final isInfluencer =
                  c.selectedType.value == CampaignType.influencerPromotion;

              return Container(
                padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isInfluencer)
                      Obx(() {
                        final enabled = c.needToSendSample.value;
                        return Row(
                          children: [
                            Checkbox(
                              value: c.sampleGuidelinesConfirmed.value,
                              onChanged: enabled
                                  ? (v) => c.sampleGuidelinesConfirmed.value =
                                        v ?? false
                                  : null,
                            ),
                            Expanded(
                              child: Row(
                                spacing : 2,
                                children: [
                                  Text(
                                    'create_campaign_confirm_sample_guidelines'.tr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      color: AppPalette.black
                                    ),
                                  ),

                                  Text(
                                    'create_campaign_confirm_sample_guidelines1'.tr,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppPalette.secondary
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),

                    10.h.verticalSpace,

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: c.onPrevious,
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 46.h),
                              side: BorderSide(color: Colors.black12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text('common_previous'.tr),
                          ),
                        ),

                        12.w.horizontalSpace,

                        Expanded(
                          child: Obx(() {
                            final ok = c.canGoNext;
                            return ElevatedButton(
                              onPressed: ok ? c.onNext : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 46.h),
                                backgroundColor: _primary.withOpacity(
                                  ok ? 0.75 : 0.35,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text('common_next'.tr,style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppPalette.white),),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}