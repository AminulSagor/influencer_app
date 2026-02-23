import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

import '../../../core/models/job_item.dart';
import 'create_campaign_controller.dart';
import 'widgets/top_progress_section.dart';

class CreateCampaignStep5View extends GetView<CreateCampaignController> {
  const CreateCampaignStep5View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
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
                      'create_campaign_step5_title'.tr,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    6.h.verticalSpace,
                    Text(
                      'create_campaign_step5_subtitle'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppPalette.black,
                      ),
                    ),

                    18.h.verticalSpace,

                    _SectionCard(
                      title: 'create_campaign_content_assets'.tr,
                      iconPath: 'assets/icons/download.png',
                      child: Obx(() {
                        return Column(
                          children: [
                            ...List.generate(controller.contentAssets.length, (
                              i,
                            ) {
                              final a = controller.contentAssets[i];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _AssetTile(
                                  icon: controller.iconForAsset(a.kind),
                                  title: a.title,
                                  subtitle: a.meta,
                                  onRemove: () =>
                                      controller.removeContentAsset(i),
                                ),
                              );
                            }),
                            CustomButton.dotted(
                              onTap: controller.openAddContentAssetDialog,
                              btnText:
                                  'create_campaign_upload_another_asset'.tr,
                              leading: Transform.flip(
                                flipY: true,
                                child: Image.asset('assets/icons/download.png'),
                              ),
                              iconGap: 24.w,
                              btnColor: AppPalette.white,
                              textColor: AppPalette.secondary,
                              height: 50.h,
                              width: double.infinity,
                            ),
                          ],
                        );
                      }),
                    ),

                    14.h.verticalSpace,

                    // influencerPromotion -> sample section
                    Obx(() {
                      final isInfluencer =
                          controller.selectedType.value ==
                          CampaignType.influencerPromotion;
                      if (!isInfluencer) return const SizedBox.shrink();

                      return _SectionCard(
                        title: 'create_campaign_need_sample_title'.tr,
                        iconPath: 'assets/icons/product.png',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'create_campaign_need_sample_label'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.primary,
                              ),
                            ),
                            Obx(() {
                              return Switch(
                                value: controller.needToSendSample.value,
                                activeColor: Colors.white,
                                activeTrackColor: AppPalette.secondary,
                                onChanged: controller.toggleNeedSample,
                              );
                            }),
                          ],
                        ),
                      );
                    }),

                    // paidAd -> brand assets section
                    Obx(() {
                      final isPaid =
                          controller.selectedType.value == CampaignType.paidAd;
                      if (!isPaid) return const SizedBox.shrink();

                      return Column(
                        children: [
                          14.h.verticalSpace,
                          _SectionCard(
                            title: 'create_campaign_brand_assets'.tr,
                            iconPath: 'assets/icons/download.png',
                            child: Obx(() {
                              return Column(
                                children: [
                                  ...List.generate(
                                    controller.brandAssets.length,
                                    (i) {
                                      final b = controller.brandAssets[i];
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 12.h),
                                        child: _BrandAssetTile(
                                          title: b.title,
                                          subtitle: b.value?.isNotEmpty == true
                                              ? b.value!
                                              : 'create_campaign_brand_asset_value_hint'
                                                    .tr,
                                          onTap: () => controller
                                              .openEditBrandAssetDialog(i),
                                        ),
                                      );
                                    },
                                  ),
                                  CustomButton.dotted(
                                    onTap: controller.openAddBrandAssetDialog,
                                    btnText:
                                        'create_campaign_add_brand_asset'.tr,
                                    leading: Transform.flip(
                                      flipY: true,
                                      child: Image.asset(
                                        'assets/icons/download.png',
                                      ),
                                    ),
                                    iconGap: 24.w,
                                    btnColor: AppPalette.white,
                                    textColor: AppPalette.secondary,
                                    height: 50.h,
                                    width: double.infinity,
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
                  controller.selectedType.value ==
                  CampaignType.influencerPromotion;

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
                        final enabled = controller.needToSendSample.value;
                        return Row(
                          children: [
                            Checkbox(
                              value: controller.sampleGuidelinesConfirmed.value,
                              onChanged: enabled
                                  ? (v) =>
                                        controller
                                                .sampleGuidelinesConfirmed
                                                .value =
                                            v ?? false
                                  : null,
                            ),
                            Expanded(
                              child: Text(
                                'create_campaign_confirm_sample_guidelines'.tr,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: enabled
                                      ? Colors.black54
                                      : Colors.black26,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    10.h.verticalSpace,
                    Row(
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
                              btnText: 'common_next'.tr,
                              btnColor: disabled
                                  ? AppPalette.defaultFill
                                  : AppPalette.secondary,
                              textColor: disabled
                                  ? AppPalette.greyText
                                  : AppPalette.white,
                              borderColor: Colors.transparent,
                              showBorder: false,
                              isDisabled: disabled,
                              onTap: controller.onNext,
                            ),
                          );
                        }),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.iconPath,
    required this.child,
  });

  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(iconPath, width: 25.w),
              10.w.horizontalSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
          14.h.verticalSpace,
          child,
        ],
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  const _AssetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

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
          Icon(icon, color: AppPalette.secondary, size: 26.sp),
          12.w.horizontalSpace,
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
                    color: AppPalette.secondary,
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  subtitle,
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
            onTap: onRemove,
            child: Icon(Icons.close, color: AppPalette.secondary, size: 22.sp),
          ),
        ],
      ),
    );
  }
}

class _BrandAssetTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BrandAssetTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const _secondary = AppPalette.secondary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
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
                    title,
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
            Icon(Icons.keyboard_arrow_down, color: _secondary.withAlpha(140)),
          ],
        ),
      ),
    );
  }
}
