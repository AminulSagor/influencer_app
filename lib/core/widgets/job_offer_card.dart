import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

import '../theme/app_palette.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

class JobOfferCard extends StatelessWidget {
  final JobItem job;
  final String type;
  final VoidCallback? onView;
  final VoidCallback? onDecline;
  final VoidCallback? onAccept;
  const JobOfferCard({
    super.key,
    required this.job,
    required this.type,
    this.onView,
    this.onDecline,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final isNew = type == 'new';
    final isActive = type == 'active';
    final isComplete = type == 'complete';
    final isPending = type == 'pending';
    final isDeclined = type == 'declined';
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + due
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDeclined
                            ? AppPalette.defaultStroke
                            : AppPalette.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${job.sharePercent}% ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: isDeclined
                            ? AppPalette.defaultStroke
                            : isPending
                            ? AppPalette.complemetary
                            : AppPalette.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isNew || isComplete || isPending)
                GestureDetector(
                  onTap: onView,
                  child: Text(
                    'View >',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              if (isActive)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.complemetaryFill,
                    borderRadius: BorderRadius.circular(kBorderRadius2.r),
                    border: Border.all(
                      color: AppPalette.complemetary,
                      width: kBorderWeight1,
                    ),
                  ),
                  child: Text(
                    job.dueLabel ?? '',
                    style: TextStyle(
                      color: AppPalette.complemetary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 15.sp,
                color: isDeclined
                    ? AppPalette.defaultStroke
                    : AppPalette.complemetary,
              ),
              SizedBox(width: 6.w),
              Text(
                job.clientName,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDeclined
                      ? AppPalette.defaultStroke
                      : AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (isComplete) ...[
                const Spacer(),
                _ratingStars(job.rating ?? 0),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 14.sp,
                color: isDeclined
                    ? AppPalette.defaultStroke
                    : AppPalette.complemetary,
              ),
              SizedBox(width: 6.w),
              Text(
                job.dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDeclined
                      ? AppPalette.defaultStroke
                      : AppPalette.complemetary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Spacer(),
              Text(
                'Budget: ${formatCurrencyByLocale(job.budget)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDeclined
                      ? AppPalette.defaultStroke
                      : AppPalette.secondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (isNew) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: onAccept,
                    btnText: 'Accept',
                    textColor: AppPalette.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    onTap: onDecline,
                    btnText: 'Decline',
                    btnColor: AppPalette.defaultFill,
                  ),
                ),
              ],
            ),
          ],
          if (isActive) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: (job.progressPercent ?? 0) / 100,
              minHeight: 6.h,
              backgroundColor: AppPalette.secondary.withAlpha(77),
              color: AppPalette.secondary,
              borderRadius: BorderRadius.circular(kBorderRadius2.r),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  '${job.progressPercent}% Complete',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.complemetary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onView,
                  child: Text(
                    'View >',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _ratingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(
          Icons.star_rounded,
          size: 14.sp,
          color: filled ? AppPalette.starDark : AppPalette.backgroundDark,
        );
      }),
    );
  }
}
