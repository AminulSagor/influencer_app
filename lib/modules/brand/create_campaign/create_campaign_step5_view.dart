import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/job_item.dart';
import 'create_campaign_controller.dart';

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
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: _primary,
                            ),
                          ),
                        ),
                        10.w.horizontalSpace,
                        _DraftButton(onTap: c.saveAsDraft),
                      ],
                    ),
                    6.h.verticalSpace,
                    Text(
                      'create_campaign_step5_subtitle'.tr,
                      style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                    ),

                    18.h.verticalSpace,

                    _SectionCard(
                      title: 'create_campaign_content_assets'.tr,
                      icon: Icons.download_outlined,
                      child: Obx(() {
                        return Column(
                          children: [
                            ...List.generate(c.contentAssets.length, (i) {
                              final a = c.contentAssets[i];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _AssetTile(
                                  icon: c.iconForAsset(a.kind),
                                  title: a.title,
                                  subtitle: a.meta,
                                  onRemove: () => c.removeContentAsset(i),
                                ),
                              );
                            }),
                            _DashedButton(
                              text: 'create_campaign_upload_another_asset'.tr,
                              icon: Icons.upload_outlined,
                              onTap: c.openAddContentAssetDialog,
                            ),
                          ],
                        );
                      }),
                    ),

                    14.h.verticalSpace,

                    // influencerPromotion -> sample section
                    Obx(() {
                      final isInfluencer =
                          c.selectedType.value ==
                          CampaignType.influencerPromotion;
                      if (!isInfluencer) return const SizedBox.shrink();

                      return _SectionCard(
                        title: 'create_campaign_need_sample_title'.tr,
                        icon: Icons.inventory_2_outlined,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'create_campaign_need_sample_label'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
                            Obx(() {
                              return Switch(
                                value: c.needToSendSample.value,
                                activeColor: Colors.white,
                                activeTrackColor: _primary.withOpacity(.65),
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
                          _SectionCard(
                            title: 'create_campaign_brand_assets'.tr,
                            icon: Icons.download_outlined,
                            child: Obx(() {
                              return Column(
                                children: [
                                  ...List.generate(c.brandAssets.length, (i) {
                                    final b = c.brandAssets[i];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: _BrandAssetTile(
                                        title: b.title,
                                        subtitle: b.value?.isNotEmpty == true
                                            ? b.value!
                                            : 'create_campaign_brand_asset_value_hint'
                                                  .tr,
                                        onTap: () =>
                                            c.openEditBrandAssetDialog(i),
                                      ),
                                    );
                                  }),
                                  _DashedButton(
                                    text: 'create_campaign_add_brand_asset'.tr,
                                    icon: Icons.add,
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
                              child: Text(
                                'create_campaign_confirm_sample_guidelines'.tr,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
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
                              child: Text('common_next'.tr),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
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
              Icon(icon, color: _primary, size: 22.sp),
              10.w.horizontalSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
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

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _softBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primary.withOpacity(.75), size: 26.sp),
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: _primary.withOpacity(.75),
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _primary.withOpacity(.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          InkWell(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              color: _primary.withOpacity(.55),
              size: 22.sp,
            ),
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

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary.withOpacity(.75),
                    ),
                  ),
                  2.h.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _primary.withOpacity(.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: _primary.withOpacity(.55)),
          ],
        ),
      ),
    );
  }
}

class _DashedButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _DashedButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  static const _softBorder = Color(0xFFBFD7A5);
  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _softBorder, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: _primary.withOpacity(.6)),
            10.w.horizontalSpace,
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _primary.withOpacity(.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
