// lib/modules/ad_agency/milestone_details/milestone_details_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';

import '../../../core/models/job_item.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'milestone_details_controller.dart';

class MilestoneDetailsView extends GetView<MilestoneDetailsController> {
  const MilestoneDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final job = controller.job;
    final milestone = controller.milestone;
    final accountTypeService = Get.find<AccountTypeService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CARD
            Obx(
              () => _MilestoneHeaderCard(
                job: job,
                milestone: milestone,
                isExpanded: controller.headerExpanded.value,
                onToggle: controller.toggleHeader,
              ),
            ),
            SizedBox(height: 20.h),

            // STATUS
            Obx(
              () => _StatusSummaryCard(
                statusText: controller.statusChipText,
                statusColor: controller.statusChipColor,
                statusBgColor: controller.statusBgColor,
                statusChipTextColor: controller.statusChipTextColor,
                statusTextColor: controller.statusTextColor,
                dateLabel: controller.job.dateLabel,
              ),
            ),
            SizedBox(height: 16.h),

            // PARTIAL PAYMENT PROGRESS
            Obx(
              () =>
                  controller.showPaymentProgress &&
                      accountTypeService.isAdAgency
                  ? _PaymentProgressSection(
                      leftLabel: controller.progressLeftLabel,
                      rightLabel: controller.progressRightLabel,
                      progress: controller.paymentProgressValue,
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(height: 12.h),

            // SUBMISSIONS
            Obx(
              () => Column(
                children: [
                  for (int i = 0; i < controller.submissions.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _SubmissionCard(
                        index: i,
                        submission: controller.submissions[i],
                        onPickFiles: () => controller.pickProofFor(i),
                        onRemoveProof: (pi) => controller.removeProof(i, pi),
                        onEditDeclined: () => controller.enableEditForDeclined(
                          controller.submissions[i],
                        ),
                        accountTypeService: accountTypeService,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            _AddAnotherSubmissionButton(onTap: controller.addSubmission),
            SizedBox(height: 24.h),

            // BOTTOM AGREEMENT + SUBMIT
            Obx(
              () => _MilestoneBottomSection(
                confirmOwnership: controller.confirmOwnership.value,
                acceptLicense: controller.acceptLicense.value,
                onToggleOwnership: controller.toggleOwnership,
                onToggleLicense: controller.toggleLicense,
                onSubmit: controller.submitForReview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER CARD   (Milestone Details gradient card)
// ---------------------------------------------------------------------------

class _MilestoneHeaderCard extends StatelessWidget {
  final JobItem job;
  final Milestone milestone;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MilestoneHeaderCard({
    required this.job,
    required this.milestone,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isAgency = Get.find<AccountTypeService>().isAdAgency;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        gradient: const LinearGradient(
          colors: [AppPalette.gradient1, AppPalette.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back,
                  size: 16.sp,
                  color: AppPalette.thirdColor,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Milestone Details',
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 32.sp,
                  color: AppPalette.thirdColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/mission.png',
                width: 29.w,
                height: 29.w,
                fit: BoxFit.cover,
                color: AppPalette.thirdColor,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For Milestone ${milestone.stepLabel}',
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    milestone.title,
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // COLLAPSED: stop here
          if (isExpanded) ...[
            SizedBox(height: 16.h),

            // CAMPAIGN NAME
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/online_ads.png',
                  width: 29.w,
                  height: 29.w,
                  fit: BoxFit.cover,
                  color: AppPalette.thirdColor,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campaign',
                      style: TextStyle(
                        color: AppPalette.thirdColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      job.title,
                      style: TextStyle(
                        color: AppPalette.thirdColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: AppPalette.border1, height: 1),
            SizedBox(height: 12.h),

            // CONTENT REQUIREMENTS
            _HeaderSectionTitle(
              iconPath: 'assets/icons/requirement.png',
              title: 'Content Requirements',
              subTitle:
                  '• ${milestone.subtitle ?? 'Final Report + 2 Instagram Stories'}',
            ),
            SizedBox(height: 14.h),
            Divider(color: AppPalette.border1, height: 1),
            SizedBox(height: 14.h),

            // PROMOTION TARGET or Milestone Target
            _HeaderSectionTitle(
              iconPath: 'assets/icons/goal.png',
              title: isAgency ? 'Promotion Target' : 'Milestone Target',
            ),
            SizedBox(height: 6.h),
            if (isAgency) ...[
              Text(
                'Facebook',
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              _TargetCard(title: 'Reach', value: '300K'),

              SizedBox(height: 18.h),

              // PROMOTION GOAL
              _HeaderSectionTitle(
                iconPath:
                    'assets/icons/goal.png', // or Icons.adjust_rounded etc.
                title: 'Promotion Goal',
                subTitle: 'Gain Page Like As Much As Possible',
              ),
            ],
            if (!isAgency)
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: .center,
                  spacing: 16.w,
                  runSpacing: 10.h,
                  children: [
                    _TargetCard(
                      title: 'Reach',
                      value: '300K',
                      width: 115.w,
                      trailingIcon: Icons.remove_red_eye_rounded,
                    ),
                    _TargetCard(
                      title: 'Views',
                      value: '300K',
                      width: 115.w,
                      trailingIcon: Icons.play_arrow_rounded,
                    ),
                    _TargetCard(
                      title: 'Reaction',
                      value: '300K',
                      width: 115.w,
                      trailingIcon: Icons.favorite_rounded,
                    ),
                    _TargetCard(
                      title: 'Comment',
                      value: '300K',
                      width: 115.w,
                      trailingIcon: Icons.chat_bubble_rounded,
                    ),
                  ],
                ),
              ),
            SizedBox(height: 25.h),
            Row(
              children: [
                Spacer(),
                Text(
                  'Client: ${job.clientName}',
                  style: TextStyle(
                    color: AppPalette.thirdColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Divider(color: Colors.white.withOpacity(0.4), height: 1),
            SizedBox(height: 12.h),

            // CLIENT + PAYOUT
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payout On Approval',
                    style: TextStyle(
                      color: AppPalette.thirdColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  milestone.amountLabel,
                  style: TextStyle(
                    color: AppPalette.thirdColor,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? trailingIcon;
  final double? width;

  const _TargetCard({
    required this.title,
    required this.value,
    this.trailingIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.thirdColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 15.sp, color: AppPalette.thirdColor),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSectionTitle extends StatelessWidget {
  final String iconPath;
  final String title;
  final String? subTitle;

  const _HeaderSectionTitle({
    required this.iconPath,
    required this.title,
    this.subTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 29.w,
          height: 29.w,
          fit: BoxFit.cover,
          color: AppPalette.thirdColor,
          filterQuality: FilterQuality.high,
        ),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppPalette.thirdColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subTitle!.isNotEmpty) ...[
              3.h.verticalSpace,

              Text(
                subTitle!,
                style: TextStyle(
                  color: AppPalette.thirdColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// STATUS SUMMARY CARD
// ---------------------------------------------------------------------------

class _StatusSummaryCard extends StatelessWidget {
  final String statusText;
  final Color statusColor;
  final Color statusTextColor;
  final Color statusChipTextColor;
  final Color statusBgColor;
  final String dateLabel;

  const _StatusSummaryCard({
    required this.statusText,
    required this.statusColor,
    required this.statusTextColor,
    required this.dateLabel,
    required this.statusChipTextColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppPalette.white, statusBgColor]),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: statusTextColor, width: kBorderWidth0_5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Status',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: statusTextColor,
            ),
          ),
          SizedBox(height: 10.h),

          // Center pill with current status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: statusChipTextColor,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Date row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_filled,
                size: 12.sp,
                color: statusTextColor,
              ),
              SizedBox(width: 6.w),
              Text(
                dateLabel,
                style: TextStyle(fontSize: 12.sp, color: statusTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUBMISSION CARD
// ---------------------------------------------------------------------------

class _SubmissionCard extends StatelessWidget {
  final int index;
  final SubmissionUiModel submission;
  final VoidCallback onPickFiles;
  final Function(int proofIndex) onRemoveProof;
  final VoidCallback onEditDeclined;
  final AccountTypeService accountTypeService;

  const _SubmissionCard({
    required this.index,
    required this.submission,
    required this.onPickFiles,
    required this.onRemoveProof,
    required this.onEditDeclined,
    required this.accountTypeService,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // chip style
      String chipText;
      Color chipBg;
      Color chipTextColor;

      if (!submission.isSubmitted.value) {
        chipText = 'Draft';
        chipBg = AppPalette.neutralGrey;
        chipTextColor = AppPalette.white;
      } else {
        switch (submission.status.value) {
          case SubmissionStatus.inReview:
            chipText = 'In Review';
            chipBg = AppPalette.complemetaryFill;
            chipTextColor = AppPalette.complemetary;
            break;
          case SubmissionStatus.approved:
            chipText = 'Approved';
            chipBg = AppPalette.secondary;
            chipTextColor = AppPalette.white;
            break;
          case SubmissionStatus.declined:
            chipText = 'Declined';
            chipBg = AppPalette.color2text;
            chipTextColor = AppPalette.white;
            break;
        }
      }

      final isEditable = submission.isEditable;

      final textStyle = TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400);

      final isAdAgency = accountTypeService.isAdAgency;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Column(
          children: [
            // header row
            InkWell(
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              onTap: () => submission.isExpanded.toggle(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
                child: Row(
                  children: [
                    Text(
                      isAdAgency
                          ? 'Submission ${submission.index}'
                          : 'Your Submission',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.black,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isAdAgency)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          chipText,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: chipTextColor,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      submission.amountController.text.isEmpty
                          ? ''
                          : submission.amountController.text,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF315719),
                      ),
                    ),
                    if (submission.isSubmitted.value &&
                        submission.status.value ==
                            SubmissionStatus.declined) ...[
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: onEditDeclined,
                        child: Icon(
                          Icons.edit_square,
                          size: 18.sp,
                          color: AppPalette.secondary,
                        ),
                      ),
                    ],
                    SizedBox(width: 6.w),
                    Icon(
                      submission.isExpanded.value
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: Colors.grey[800],
                    ),
                  ],
                ),
              ),
            ),

            // body
            if (submission.isExpanded.value)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _IconTitle(
                      iconPath: 'assets/icons/about_me.png',
                      title: 'Description / Update (Optional)',
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      hintText: 'Write description...',
                      textStyle: textStyle,
                      controller: submission.descriptionController,
                      enabled: isEditable,
                      maxLines: 4,
                    ),
                    SizedBox(height: 16.h),

                    if (isAdAgency) ...[
                      _IconTitle(
                        iconPath: 'assets/icons/online_payment.png',
                        title: 'Request Payment Amount',
                      ),
                      SizedBox(height: 6.h),
                      CustomTextField(
                        hintText: '৳3,000',
                        textStyle: textStyle.copyWith(fontSize: 14.sp),
                        controller: submission.amountController,
                        enabled: isEditable,
                        textAlign: TextAlign.center,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        border: Border.all(
                          color: AppPalette.border1,
                          width: kBorderWidth0_5,
                        ),
                      ),
                      child: Column(
                        children: [
                          _IconTitle(
                            iconPath: 'assets/icons/webpage_click.png',
                            title: 'Add Live Links',
                            trailing: GestureDetector(
                              onTap: isEditable
                                  ? () {
                                      submission.linkController.clear();
                                    }
                                  : null,
                              child: Image.asset(
                                'assets/icons/trash_can.png',
                                width: 20.w,
                                height: 20.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          CustomTextField(
                            hintText: 'https://instagram.com/...',
                            textStyle: textStyle,
                            controller: submission.linkController,
                            enabled: isEditable,
                          ),
                          SizedBox(height: 16.h),

                          _IconTitle(
                            iconPath: 'assets/icons/increase.png',
                            title: 'Performance Metrics',
                          ),
                          SizedBox(height: 8.h),
                          if (isAdAgency)
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CustomTextField(
                                    hintText: 'Reach',
                                    textStyle: textStyle,
                                    controller:
                                        submission.metricLabelController,
                                    enabled: isEditable,
                                    fillColor: AppPalette.gradient3,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  flex: 3,
                                  child: CustomTextField(
                                    hintText: '2.5M',
                                    textStyle: textStyle,
                                    controller:
                                        submission.metricValueController,
                                    enabled: isEditable,
                                  ),
                                ),
                              ],
                            ),

                          if (!isAdAgency) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        hintText: 'Reach',
                                        textStyle: textStyle,
                                        controller:
                                            submission.metricLabelController,
                                        enabled: isEditable,
                                        fillColor: AppPalette.gradient3,
                                      ),
                                      SizedBox(width: 10.w),
                                      CustomTextField(
                                        hintText: '2.5M',
                                        textStyle: textStyle,
                                        controller:
                                            submission.metricValueController,
                                        enabled: isEditable,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        hintText: 'Reach',
                                        textStyle: textStyle,
                                        controller:
                                            submission.metricLabelController,
                                        enabled: isEditable,
                                        fillColor: AppPalette.gradient3,
                                      ),
                                      SizedBox(width: 10.w),
                                      CustomTextField(
                                        hintText: '2.5M',
                                        textStyle: textStyle,
                                        controller:
                                            submission.metricValueController,
                                        enabled: isEditable,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 16.h),

                          _IconTitle(
                            iconPath:
                                'assets/icons/checked_identification_documents.png',
                            title: 'Attach Proof (Screenshots, Videos)',
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: isEditable ? onPickFiles : null,
                            child: Container(
                              height: 140.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppPalette.defaultFill,
                                borderRadius: BorderRadius.circular(
                                  kBorderRadius.r,
                                ),
                                border: Border.all(
                                  color: AppPalette.border1,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_upload_outlined,
                                    size: 26.sp,
                                    color: isEditable
                                        ? Colors.grey[700]
                                        : Colors.grey[400],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Tap to Upload Files',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppPalette.greyText,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Screenshots, Videos or other proof',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppPalette.greyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          Obx(
                            () => Wrap(
                              spacing: 6.w,
                              runSpacing: 4.h,
                              children: [
                                for (
                                  int i = 0;
                                  i < submission.proofs.length;
                                  i++
                                )
                                  Chip(
                                    label: Text(
                                      submission.proofs[i].name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onDeleted: isEditable
                                        ? () => onRemoveProof(i)
                                        : null,
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12.h),
                          if (isEditable)
                            _AddAnotherProofButton(onTap: onPickFiles),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _IconTitle extends StatelessWidget {
  final String iconPath;
  final String title;
  final Widget? trailing;
  const _IconTitle({
    required this.iconPath,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(iconPath, width: 20.w, height: 20.w, fit: BoxFit.cover),
        4.w.horizontalSpace,
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.black,
          ),
        ),
        if (trailing != null) ...[Spacer(), trailing!],
      ],
    );
  }
}

class _AddAnotherProofButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAnotherProofButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius.r),
          ),
        ),
        child: Text(
          '+ Add Another Proof',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF315719),
          ),
        ),
      ),
    );
  }
}

class _AddAnotherSubmissionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAnotherSubmissionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 95,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius.r),
          ),
        ),
        child: Text(
          '+ Add Another Submission',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF315719),
          ),
        ),
      ),
    );
  }
}

class _MilestoneBottomSection extends StatelessWidget {
  final bool confirmOwnership;
  final bool acceptLicense;
  final VoidCallback onToggleOwnership;
  final VoidCallback onToggleLicense;
  final VoidCallback onSubmit;

  const _MilestoneBottomSection({
    required this.confirmOwnership,
    required this.acceptLicense,
    required this.onToggleOwnership,
    required this.onToggleLicense,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BottomCheckboxRow(
            value: confirmOwnership,
            onTap: onToggleOwnership,
            text: 'Confirm you own all the submitted assets & links',
          ),
          SizedBox(height: 6.h),
          _BottomCheckboxRow(
            value: acceptLicense,
            onTap: onToggleLicense,
            richText: const TextSpan(
              text: 'You accept the ',
              children: [
                TextSpan(
                  text: 'user license agreement',
                  style: TextStyle(
                    color: Color(0xFF315719),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' & '),
                TextSpan(
                  text: 'Terms and condition',
                  style: TextStyle(
                    color: Color(0xFF315719),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' of our app.'),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7BB23B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Submit For Admin Review',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCheckboxRow extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final String? text;
  final TextSpan? richText;

  const _BottomCheckboxRow({
    required this.value,
    required this.onTap,
    this.text,
    this.richText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF7BB23B) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: value
                ? Icon(Icons.check, size: 15.sp, color: Colors.white)
                : null,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: richText != null
              ? RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    children: [richText!],
                  ),
                )
              : Text(
                  text ?? '',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
        ),
      ],
    );
  }
}

class _PaymentProgressSection extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final double progress;

  const _PaymentProgressSection({
    required this.leftLabel,
    required this.rightLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partial Payment Progress',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              leftLabel,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
            const Spacer(),
            Text(
              rightLabel,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8.h,
            backgroundColor: AppPalette.secondary.withAlpha(120),
            color: AppPalette.secondary,
          ),
        ),
      ],
    );
  }
}
