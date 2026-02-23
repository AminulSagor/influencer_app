import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:intl/intl.dart';

import '../theme/app_palette.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/label_localizers.dart';
import '../utils/number_formatter.dart';

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
    final isQuoted = type == 'quoted';

    final accountTypeService = Get.find<AccountTypeService>();
    final isAdAgency = accountTypeService.isAdAgency;

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
          // title + due/view
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
                      !isAdAgency
                          ? formatCurrencyByLocale(job.budget)
                          : '${formatNumberByLocale(job.sharePercent)}%',
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

              if ((!isAdAgency && isNew) || isComplete || isPending)
                GestureDetector(
                  onTap: onView,
                  child: Text(
                    '${'common_view'.tr} >',
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
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall.r),
                    border: Border.all(
                      color: AppPalette.complemetary,
                      width: kBorderWeight1,
                    ),
                  ),
                  child: Text(
                    localizeDueLabel(job.dueLabel),
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
              const Spacer(),
              if (isAdAgency)
                Text(
                  '${'common_budget'.tr}: ${formatCurrencyByLocale(job.budget)}',
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
            if (isAdAgency) ...[
              SizedBox(height: 10.h),
              _RequoteCountdown(
                initialMinutes: job.timeLeftToRequoteMinutes ?? 0,
              ),
            ],

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: onAccept,
                    btnText: isAdAgency ? 'Accept Quote' : 'common_accept'.tr,
                    textColor: AppPalette.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    onTap: isAdAgency ? onView : onDecline,
                    btnText: isAdAgency ? 'View Details' : 'common_decline'.tr,
                    btnColor: AppPalette.defaultFill,
                  ),
                ),
              ],
            ),

            if (isAdAgency) ...[
              SizedBox(height: 8.h),
              Text(
                _requoteHintText(job.timeLeftToRequoteMinutes),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppPalette.defaultStroke,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],

          if (isQuoted) ...[
            SizedBox(height: 12.h),
            CustomButton(
              onTap: onView,
              btnText: 'View Details',
              textColor: AppPalette.white,
            ),
          ],

          if (isActive) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: (job.progressPercent ?? 0) / 100,
              minHeight: 6.h,
              backgroundColor: AppPalette.secondary.withAlpha(77),
              color: AppPalette.secondary,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall.r),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  'home_progress_complete_line'.trParams({
                    'percent': formatNumberByLocale(job.progressPercent ?? 0),
                  }),
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
                    '${'common_view'.tr} >',
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

class _RequoteCountdown extends StatefulWidget {
  final int initialMinutes;
  const _RequoteCountdown({required this.initialMinutes});

  @override
  State<_RequoteCountdown> createState() => _RequoteCountdownState();
}

class _RequoteCountdownState extends State<_RequoteCountdown> {
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds =
        (widget.initialMinutes <= 0 ? 0 : widget.initialMinutes) * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  @override
  void didUpdateWidget(covariant _RequoteCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMinutes != widget.initialMinutes) {
      _remainingSeconds =
          (widget.initialMinutes <= 0 ? 0 : widget.initialMinutes) * 60;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatHHMM(int seconds) {
    final totalMinutes = seconds ~/ 60;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh H : $mm M';
  }

  @override
  Widget build(BuildContext context) {
    final text = _formatHHMM(_remainingSeconds);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.hourglass_bottom_rounded,
          size: 16.sp,
          color: AppPalette.complemetary,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppPalette.complemetary,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Left To Requote',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
      ],
    );
  }
}

String _formatDeadline(DateTime dt) {
  // Example: "12 Dec, 2025, 12:00pm"
  final raw = DateFormat('dd MMM, yyyy, h:mma').format(dt);
  return raw.replaceAll('AM', 'am').replaceAll('PM', 'pm');
}

String _requoteHintText(int? minutes) {
  final m = minutes ?? 0;
  if (m <= 0) return 'Requote window expired';
  final deadline = DateTime.now().add(Duration(minutes: m));
  return 'Request to requote within ${_formatDeadline(deadline)}';
}
