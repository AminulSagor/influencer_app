import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/custom_button.dart';
import '../brand_campaign_details_controller.dart';

class ProvideRatingDialog extends GetView<BrandCampaignDetailsController> {
  final bool isPaidAd;

  const ProvideRatingDialog({super.key, required this.isPaidAd});

  static void show({required bool isPaidAd}) {
    Get.dialog(
      ProvideRatingDialog(isPaidAd: isPaidAd),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: isPaidAd
            ? const _AgencyRatingContent()
            : const _InfluencerRatingContent(),
      ),
    );
  }
}

class _InfluencerRatingContent extends GetView<BrandCampaignDetailsController> {
  const _InfluencerRatingContent();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.rateInfluencerItems.toList(growable: false);

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate The Influencers',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary,
            ),
          ),
          SizedBox(height: 16.h),

          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 360.h),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = items[index];

                return Obx(() {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF7E9F58), Color(0xFF4F712D)],
                      ),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              controller.toggleInfluencerRatingExpand(index),
                          child: Row(
                            children: [
                              _AvatarCircle(imageUrl: item.image),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (i) {
                                  final filled = i < item.rating.value;
                                  return Icon(
                                    Icons.star_rounded,
                                    size: 16.sp,
                                    color: filled
                                        ? const Color(0xFFF7C948)
                                        : Colors.white,
                                  );
                                }),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                item.isExpanded.value
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),

                        if (item.isExpanded.value) ...[
                          SizedBox(height: 18.h),
                          _StarPicker(
                            rating: item.rating.value,
                            onTap: (value) {
                              controller.setInfluencerDialogRating(
                                index: index,
                                rating: value,
                              );
                            },
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "You've Rated ${item.rating.value}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                });
              },
            ),
          ),

          SizedBox(height: 18.h),

          Obx(() {
            return CustomButton(
              onTap: controller.isSubmittingRatings.value
                  ? null
                  : controller.submitInfluencerRatings,
              btnText: controller.isSubmittingRatings.value
                  ? 'Submitting...'
                  : 'Submit Your Ratings',
              width: double.infinity,
              btnColor: AppPalette.secondary,
              textColor: AppPalette.white,
            );
          }),

          SizedBox(height: 8.h),
          Center(
            child: Text(
              "You Haven't Submitted Your Ratings Yet",
              style: TextStyle(fontSize: 11.sp, color: AppPalette.greyText),
            ),
          ),
        ],
      );
    });
  }
}

class _AgencyRatingContent extends GetView<BrandCampaignDetailsController> {
  const _AgencyRatingContent();

  @override
  Widget build(BuildContext context) {
    final agencyName = controller.job?.clientName?.trim().isNotEmpty == true
        ? controller.job!.clientName!
        : 'Agency';

    return Obx(() {
      final rating = controller.agencyDialogRating.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate This Agency',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary,
            ),
          ),
          SizedBox(height: 18.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF7E9F58), Color(0xFF4F712D)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const _AvatarCircle(),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        agencyName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _StarPicker(
                  rating: rating,
                  onTap: controller.setAgencyDialogRating,
                ),
                SizedBox(height: 12.h),
                Text(
                  "You've Rated $rating",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          Obx(() {
            return CustomButton(
              onTap: controller.isSubmittingRatings.value
                  ? null
                  : controller.submitAgencyRating,
              btnText: controller.isSubmittingRatings.value
                  ? 'Submitting...'
                  : 'Submit Your Ratings',
              width: double.infinity,
              btnColor: AppPalette.secondary,
              textColor: AppPalette.white,
            );
          }),

          SizedBox(height: 8.h),
          Center(
            child: Text(
              "You Haven't Submitted Your Ratings Yet",
              style: TextStyle(fontSize: 11.sp, color: AppPalette.greyText),
            ),
          ),
        ],
      );
    });
  }
}

class _StarPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onTap;

  const _StarPicker({required this.rating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4.w,
      children: List.generate(5, (i) {
        final index = i + 1;
        final filled = index <= rating;

        return InkWell(
          onTap: () => onTap(index),
          child: Icon(
            Icons.star_rounded,
            size: 34.sp,
            color: filled ? const Color(0xFFF7C948) : Colors.white,
          ),
        );
      }),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String? imageUrl;

  const _AvatarCircle({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE7E4C8),
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            )
          : const SizedBox.shrink(),
    );
  }
}
