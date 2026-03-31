import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/custom_button.dart';
import '../brand_campaign_details_controller.dart';

class ProvideRatingDialog extends GetView<BrandCampaignDetailsController> {
  final bool isPaidAd;

  const ProvideRatingDialog({super.key, required this.isPaidAd});

  static Future<void> show({required bool isPaidAd}) async {
    if (Get.isDialogOpen == true) return;

    await Get.dialog(
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

  String _formatRatedAt(DateTime? date) {
    if (date == null) return '';
    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.rateInfluencerItems.toList(growable: false);
      final allRated = controller.areAllInfluencersAlreadyRated;

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
                  final alreadyRated = item.isAlreadyRated.value;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppPalette.secondary, AppPalette.gradient1],
                      ),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: alreadyRated
                              ? null
                              : () => controller.toggleInfluencerRatingExpand(
                                  index,
                                ),
                          child: Row(
                            children: [
                              _AvatarCircle(imageUrl: item.image),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (alreadyRated) ...[
                                      SizedBox(height: 4.h),
                                      Text(
                                        item.ratedAt.value == null
                                            ? 'Rating already submitted'
                                            : 'Rated on ${_formatRatedAt(item.ratedAt.value)}',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppPalette.thirdColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (i) {
                                  final filled = i < item.rating.value;
                                  return Icon(
                                    Icons.star_rounded,
                                    size: 18.sp,
                                    color: filled
                                        ? AppPalette.starDark
                                        : AppPalette.white,
                                  );
                                }),
                              ),
                              if (!alreadyRated) ...[
                                SizedBox(width: 6.w),
                                Icon(
                                  item.isExpanded.value
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        ),

                        if (item.isExpanded.value && !alreadyRated) ...[
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
                              color: AppPalette.thirdColor,
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
            final loading = controller.isSubmittingRatings.value;
            return CustomButton(
              onTap: (loading || allRated)
                  ? null
                  : controller.submitInfluencerRatings,
              btnText: loading
                  ? 'Submitting...'
                  : allRated
                  ? 'Ratings Already Submitted'
                  : 'Submit Your Ratings',
              width: double.infinity,
              btnColor: (loading || allRated)
                  ? AppPalette.defaultFill
                  : AppPalette.secondary,
              textColor: (loading || allRated)
                  ? AppPalette.greyText
                  : AppPalette.white,
              isDisabled: loading || allRated,
            );
          }),

          SizedBox(height: 8.h),
          Center(
            child: Text(
              allRated
                  ? 'You have already submitted all influencer ratings'
                  : "You Haven't Submitted Your Ratings Yet",
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
    final agencyName = controller.job?.clientName.trim().isNotEmpty == true
        ? controller.job!.clientName
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
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
          SizedBox(height: 18.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppPalette.secondary, AppPalette.gradient1],
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
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.thirdColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _StarPicker(
                  rating: rating,
                  onTap: controller.isRated.value
                      ? null
                      : controller.setAgencyDialogRating,
                ),
                SizedBox(height: 12.h),
                Text(
                  "You've Rated $rating",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.thirdColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          Obx(() {
            final isDisabled = controller.isRated.value;
            return CustomButton(
              onTap: controller.isSubmittingRatings.value
                  ? null
                  : controller.submitAgencyRating,
              btnText: controller.isSubmittingRatings.value
                  ? 'Submitting...'
                  : 'Submit Your Ratings',
              isDisabled: isDisabled,
              width: double.infinity,
              btnColor: AppPalette.secondary,
              textColor: AppPalette.white,
            );
          }),

          SizedBox(height: 8.h),
          if (!controller.isRated.value)
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
  final ValueChanged<int>? onTap;

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
          onTap: onTap == null ? null : () => onTap!(index),
          child: Icon(
            Icons.star_rounded,
            size: 34.sp,
            color: filled ? AppPalette.starDark : AppPalette.white,
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
      width: 34.w,
      height: 34.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppPalette.thirdColor,
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
