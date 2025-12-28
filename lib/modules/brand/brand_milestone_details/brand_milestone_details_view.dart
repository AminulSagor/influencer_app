import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/job_item.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import 'brand_milestone_details_controller.dart';

class BrandMilestoneDetailsView
    extends GetView<BrandMilestoneDetailsController> {
  const BrandMilestoneDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderCard(),
                      12.h.verticalSpace,
                      CustomButton(
                        btnText: 'Report Admin',
                        btnColor: AppPalette.primary,
                        borderColor: Colors.transparent,
                        showBorder: false,
                        textColor: AppPalette.white,
                        onTap: controller.reportAdmin,
                      ),
                      12.h.verticalSpace,
                      _StatusCard(),
                      12.h.verticalSpace,
                      _SubmissionCard(),
                      16.h.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
            _BottomActions(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.primary,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Text(
              'Milestone Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: child,
    );
  }
}

class _HeaderCard extends GetView<BrandMilestoneDetailsController> {
  @override
  Widget build(BuildContext context) {
    final m = controller.milestone;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.primary.withOpacity(.85),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For Milestone ${m.stepLabel}',
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          6.h.verticalSpace,
          Text(
            m.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          10.h.verticalSpace,
          Divider(color: Colors.white.withOpacity(.25), height: 1),
          10.h.verticalSpace,

          _miniRow('Campaign', controller.job.title),
          10.h.verticalSpace,
          _miniRow('Platform', (m.platform ?? '—')),
          10.h.verticalSpace,
          _miniRow('Influencer', (m.influencerName ?? '—')),
          10.h.verticalSpace,

          if (controller.requirements.isNotEmpty) ...[
            Divider(color: Colors.white.withOpacity(.25), height: 1),
            10.h.verticalSpace,
            Text(
              'Content Requirements',
              style: TextStyle(
                color: Colors.white.withOpacity(.92),
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            8.h.verticalSpace,
            ...controller.requirements.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    Text(
                      '•  ',
                      style: TextStyle(color: Colors.white.withOpacity(.9)),
                    ),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends GetView<BrandMilestoneDetailsController> {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Obx(() {
        final st = controller.submissionStatus.value;

        String label;
        if (st == SubmissionStatus.inReview) {
          label = 'In Review';
        } else if (st == SubmissionStatus.approved) {
          label = 'Approved';
        } else {
          label = 'Declined';
        }

        return Column(
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: AppPalette.greyText,
              ),
            ),
            8.h.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppPalette.border1.withOpacity(.35),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.primary,
                ),
              ),
            ),
            8.h.verticalSpace,
            Text(
              controller.submittedDateLabel,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.greyText,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SubmissionCard extends GetView<BrandMilestoneDetailsController> {
  @override
  Widget build(BuildContext context) {
    final s = controller.currentSubmission;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submission Details',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w900,
              color: AppPalette.primary,
            ),
          ),
          12.h.verticalSpace,

          _title('Description / Update'),
          6.h.verticalSpace,
          Text(
            s.description.trim().isNotEmpty ? s.description : '—',
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.35,
              color: AppPalette.greyText,
              fontWeight: FontWeight.w600,
            ),
          ),

          14.h.verticalSpace,
          _title('Platform Link'),
          6.h.verticalSpace,
          Text(
            s.liveLink.trim().isNotEmpty ? s.liveLink : '—',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: AppPalette.primary,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
            ),
          ),

          14.h.verticalSpace,
          _title('Metric'),
          6.h.verticalSpace,
          Text(
            (s.metricLabel.trim().isNotEmpty || s.metricValue.trim().isNotEmpty)
                ? '${s.metricLabel}: ${s.metricValue}'
                : '—',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: AppPalette.greyText,
              fontWeight: FontWeight.w700,
            ),
          ),

          14.h.verticalSpace,
          _title('Attached Proofs'),
          10.h.verticalSpace,
          if (s.proofPaths.isEmpty)
            _proofBox()
          else
            ...s.proofPaths.map(
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _proofBox(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _title(String t) {
    return Text(
      t,
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w900,
        color: AppPalette.primary,
      ),
    );
  }

  Widget _proofBox() {
    return Container(
      height: 78.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
    );
  }
}

class _BottomActions extends GetView<BrandMilestoneDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        border: Border(
          top: BorderSide(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              btnText: 'Decline',
              btnColor: AppPalette.white,
              borderColor: AppPalette.border1,
              textColor: AppPalette.black,
              onTap: controller.decline,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: CustomButton(
              btnText: 'Approve',
              btnColor: AppPalette.primary,
              borderColor: Colors.transparent,
              showBorder: false,
              textColor: AppPalette.white,
              onTap: controller.approve,
            ),
          ),
        ],
      ),
    );
  }
}
