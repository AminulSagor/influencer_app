import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';

class BrandSubmissionMetric {
  final String labelKey; // translation key
  final String leftValue;
  final String rightValue;
  final double progress; // 0..1
  final String targetKey; // translation key

  BrandSubmissionMetric({
    required this.labelKey,
    required this.leftValue,
    required this.rightValue,
    required this.progress,
    required this.targetKey,
  });
}

enum BrandSubmissionStatus { inReview, completed, declined }

class BrandSubmissionUiModel {
  final int index;

  final String description;
  final String platformTitleKey;
  final String platformLink;
  final double avgPercent;
  final List<BrandSubmissionMetric> metrics;

  final RxBool isExpanded;

  final Rx<BrandSubmissionStatus> status;
  final RxnString declinedReason = RxnString();

  BrandSubmissionUiModel({
    required this.index,
    required this.description,
    required this.platformTitleKey,
    required this.platformLink,
    required this.avgPercent,
    required this.metrics,
    BrandSubmissionStatus initialStatus = BrandSubmissionStatus.inReview,
    bool expanded = true,
  }) : status = initialStatus.obs,
       isExpanded = expanded.obs;

  String get statusKey {
    switch (status.value) {
      case BrandSubmissionStatus.inReview:
        return 'brand_submission_in_review';
      case BrandSubmissionStatus.completed:
        return 'brand_submission_completed';
      case BrandSubmissionStatus.declined:
        return 'brand_submission_declined';
    }
  }
}

class BrandSubmissionCard extends StatelessWidget {
  final BrandSubmissionUiModel submission;
  final bool isPaidAd;
  final VoidCallback? onToggle;

  const BrandSubmissionCard({
    super.key,
    required this.submission,
    required this.isPaidAd,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = isPaidAd ? submission.isExpanded.value : true;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: isPaidAd
                ? AppPalette.secondary.withOpacity(0.65)
                : AppPalette.border1,
            width: kBorderWidth0_5,
          ),
        ),
        child: Column(
          children: [
            _HeaderRow(
              submission: submission,
              isPaidAd: isPaidAd,
              onToggle: isPaidAd ? onToggle : null,
            ),

            if (expanded)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    _IconTitle(
                      icon: Icons.group_outlined,
                      title: 'brand_submission_description'.tr,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      submission.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    _IconTitle(
                      icon: Icons.link_rounded,
                      title: submission.platformTitleKey.tr,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      submission.platformLink,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppPalette.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    _IconTitle(
                      icon: Icons.bar_chart_rounded,
                      title: 'brand_submission_performance_metrics'.tr,
                    ),
                    SizedBox(height: 10.h),
                    Center(child: _AvgRing(percent: submission.avgPercent)),
                    SizedBox(height: 12.h),

                    ...submission.metrics.map(
                      (m) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _MetricRow(metric: m),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    _IconTitle(
                      icon: Icons.attachment_rounded,
                      title: 'brand_submission_attached_proofs'.tr,
                    ),
                    SizedBox(height: 10.h),
                    _DashedBox(),
                    SizedBox(height: 10.h),
                    _DashedBox(),

                    // ✅ declined reason (like image #4)
                    if (submission.status.value ==
                            BrandSubmissionStatus.declined &&
                        (submission.declinedReason.value ?? '')
                            .trim()
                            .isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      Text(
                        'brand_declined_reason_label'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: const Color(0xFFD32F2F),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          submission.declinedReason.value ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final BrandSubmissionUiModel submission;
  final bool isPaidAd;
  final VoidCallback? onToggle;

  const _HeaderRow({
    required this.submission,
    required this.isPaidAd,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final title = isPaidAd
        ? 'brand_submission_title_with_index'.trParams({
            'i': '${submission.index}',
          })
        : 'brand_submission_details'.tr;

    Color pillBg;
    Color pillText;
    switch (submission.status.value) {
      case BrandSubmissionStatus.inReview:
        pillBg = const Color(0xFFFFF1D6);
        pillText = const Color(0xFFB87500);
        break;
      case BrandSubmissionStatus.completed:
        pillBg = const Color(0xFFE8F5E9);
        pillText = const Color(0xFF2E7D32);
        break;
      case BrandSubmissionStatus.declined:
        pillBg = const Color(0xFFFFEBEE);
        pillText = const Color(0xFFD32F2F);
        break;
    }

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.black,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Obx(() {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  submission.statusKey.tr,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: pillText,
                  ),
                ),
              );
            }),
            if (isPaidAd) ...[
              SizedBox(width: 8.w),
              Icon(
                submission.isExpanded.value
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 22.sp,
                color: Colors.grey[700],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _IconTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppPalette.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvgRing extends StatelessWidget {
  final double percent; // 0..100
  const _AvgRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    final p = (percent / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          'brand_submission_average_performance'.tr,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: 88.w,
          height: 88.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 88.w,
                height: 88.w,
                child: CircularProgressIndicator(
                  value: p,
                  strokeWidth: 10.w,
                  backgroundColor: const Color(0xFFDDE7CF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppPalette.secondary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final BrandSubmissionMetric metric;
  const _MetricRow({required this.metric});

  @override
  Widget build(BuildContext context) {
    final progress = metric.progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                metric.labelKey.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Text(
              metric.leftValue,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.secondary,
              ),
            ),
            const Spacer(),
            Text(
              metric.rightValue,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE07E2D),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7.h,
            backgroundColor: const Color(0xFFDDE7CF),
            color: AppPalette.secondary,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          metric.targetKey.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFFE07E2D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashedBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppPalette.border1,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}
