// lib/modules/ad_agency/milestone_details/milestone_details_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../core/models/job_item.dart';
import 'milestone_details_controller.dart';
import 'widgets/brand_submission_card.dart';
import 'widgets/milestone_header_card.dart';
import 'widgets/status_summary_card.dart';
import 'widgets/submission_card.dart';

class MilestoneDetailsView extends GetView<MilestoneDetailsController> {
  const MilestoneDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final job = controller.job;
    final accountTypeService = Get.find<AccountTypeService>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          controller.closePage();
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.background,
        bottomNavigationBar: accountTypeService.isBrand
            ? Obx(() {
                final isPaidAd = job.campaignType == CampaignType.paidAd;
                final selected = controller.selectedBrandSubmission;

                if (selected == null) return const SizedBox.shrink();

                final hasSubmissionId = (selected.serverId ?? '')
                    .trim()
                    .isNotEmpty;

                // hide if already completed (optional)
                if (selected.status.value == BrandSubmissionStatus.completed) {
                  return const SizedBox.shrink();
                }

                return _AcceptDeclineSection(
                  isPaidAd: isPaidAd,
                  onAccept: hasSubmissionId
                      ? controller.approveSelectedBrandSubmission
                      : null,
                  onDecline: hasSubmissionId
                      ? () => _showDeclineSheet(
                          context: context,
                          onSubmit: (reason) {
                            controller.declineSelectedBrandSubmission(reason);
                          },
                        )
                      : null,
                );
              })
            : null,

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.h.verticalSpace,
              // HEADER CARD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(
                  () => MilestoneHeaderCard(
                    job: job,
                    milestone: controller.currentMilestone,
                    isExpanded: controller.headerExpanded.value,
                    onToggle: controller.toggleHeader,
                    onBack: controller.closePage,
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              if (accountTypeService.isBrand) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(() {
                    final selected = controller.selectedBrandSubmission;
                    final hasSubmission = (selected?.serverId ?? '')
                        .trim()
                        .isNotEmpty;

                    // ✅ If no submission exists on this milestone, hide report admin UI entirely
                    if (!hasSubmission) {
                      return const SizedBox.shrink();
                    }

                    final reported = controller.hasReportedToAdmin.value;
                    final hasFetchedSubmissionReports =
                        controller.selectedSubmissionReports.isNotEmpty;
                    final againAt = controller.reportAgainAt.value;
                    final againText = againAt == null
                        ? ''
                        : '${'report_again_on'.tr} ${controller.formatReportDateTime(againAt)}';

                    return Column(
                      children: [
                        if (!reported)
                          CustomButton(
                            onTap: () => _showWriteReportDialog(
                              context: context,
                              onSubmit: (reason) =>
                                  controller.submitAdminReport(reason),
                            ),
                            btnText: 'report_admin_btn'.tr,
                            width: double.infinity,
                            gradient: LinearGradient(
                              colors: [
                                AppPalette.secondary,
                                AppPalette.primary,
                              ],
                            ),
                            textStyle: AppTheme.textStyle.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppPalette.white,
                            ),
                            height: 50.h,
                          )
                        else ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppPalette.secondary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'reported_to_admin_title'.tr,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                if (againText.isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    againText,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        // ✅ show only if API has reports for selected submission
                        if (hasFetchedSubmissionReports) ...[
                          SizedBox(height: 12.h),
                          CustomButton(
                            onTap: () =>
                                _showSubmittedReportsDialog(context: context),
                            btnText: 'view_submitted_report'.tr,
                            width: double.infinity,
                            height: 50.h,
                            btnColor: AppPalette.white,
                            textStyle: AppTheme.textStyle.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: AppPalette.primary,
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
                SizedBox(height: 14.h),
              ],
              SizedBox(height: 14.h),

              // STATUS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(
                  () => StatusSummaryCard(
                    statusText: controller.statusChipText,
                    statusColor: controller.statusChipColor,
                    statusBgColor: controller.statusBgColor,
                    statusChipTextColor: controller.statusChipTextColor,
                    statusTextColor: controller.statusTextColor,
                    dateLabel: controller.job.dateLabel,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // PARTIAL PAYMENT PROGRESS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(
                  () =>
                      controller.showPaymentProgress &&
                          accountTypeService.isAdAgency
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                          child: _PaymentProgressSection(
                            leftLabel: controller.progressLeftLabel,
                            rightLabel: controller.progressRightLabel,
                            progress: controller.paymentProgressValue,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              SizedBox(height: 12.h),

              if (accountTypeService.isBrand) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(() {
                    final isPaidAd = job.campaignType == CampaignType.paidAd;
                    final brandSubmissions = controller.brandSubmissions;
                    if (controller.isBrandSubmissionsLoading.value) {
                      return Column(
                        children: const [
                          _BrandSubmissionSkeleton(),
                          SizedBox(height: 12),
                          _BrandSubmissionSkeleton(),
                        ],
                      );
                    }
                    if (brandSubmissions.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        decoration: BoxDecoration(
                          color: AppPalette.defaultFill,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppPalette.border1,
                            width: kBorderWidth0_5,
                          ),
                        ),
                        child: Text(
                          controller.trOr(
                            'brand_campaign_details_no_submissions',
                            'No submissions yet',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.greyText,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final s in brandSubmissions) ...[
                          BrandSubmissionCard(
                            submission: s,
                            isPaidAd: isPaidAd,
                            isSelected: controller.isBrandSubmissionSelected(
                              s.index,
                            ),
                            onSelect: () =>
                                controller.selectBrandSubmission(s.index),
                            onToggle: isPaidAd
                                ? () => controller
                                      .toggleBrandSubmissionExpanded(s.index)
                                : null,
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ],
                    );
                  }),
                ),
                SizedBox(height: 10.h),
              ],

              // SUBMISSIONS
              if (!accountTypeService.isBrand)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(
                    () => Column(
                      children: [
                        for (int i = 0; i < controller.submissions.length; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: SubmissionCard(
                              index: i,
                              submission: controller.submissions[i],
                              onPickFiles: () => controller.pickProofFor(i),
                              onRemoveProof: (pi) =>
                                  controller.removeProof(i, pi),
                              onEditDeclined: () =>
                                  controller.enableEditForDeclined(
                                    controller.submissions[i],
                                  ),
                              accountTypeService: accountTypeService,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              if (!accountTypeService.isBrand) ...[
                if (!accountTypeService.isInfluencer) ...[
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _AddAnotherSubmissionButton(
                      onTap: controller.addSubmission,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                Obx(
                  () => _MilestoneBottomSection(
                    confirmOwnership: controller.confirmOwnership.value,
                    acceptLicense: controller.acceptLicense.value,
                    onToggleOwnership: controller.toggleOwnership,
                    onToggleLicense: controller.toggleLicense,
                    onSubmit: controller.submitForReview,
                    // ✅ add this param
                    submitText: controller.submitButtonText,
                  ),
                ),
              ],

              // if (accountTypeService.isBrand) ...[
              //   Obx(() {
              //     controller.selectedBrandSubmission?.status.value;
              //     final isPaidAd = job.campaignType == CampaignType.paidAd;
              //     return _AcceptDeclineSection(
              //       isPaidAd: isPaidAd,
              //       onAccept: controller.approveSelectedBrandSubmission,
              //       onDecline: () => _showDeclineSheet(
              //         context: context,
              //         onSubmit: (reason) {
              //           controller.declineSelectedBrandSubmission(reason);
              //         },
              //       ),
              //     );
              //   }),
              // ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AcceptDeclineSection extends StatelessWidget {
  final bool isPaidAd;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _AcceptDeclineSection({
    required this.isPaidAd,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final declineText = isPaidAd
        ? 'brand_decline_selected'.tr
        : 'common_decline'.tr;

    final approveText = isPaidAd
        ? 'brand_approve_selected'.tr
        : 'common_accept'.tr;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                onTap: onDecline,
                btnText: declineText,
                btnColor: AppPalette.defaultFill,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomButton(
                onTap: onAccept,
                btnText: approveText,
                textColor: AppPalette.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeclineSheet({
  required BuildContext context,
  required void Function(String reason) onSubmit,
}) {
  final tc = TextEditingController();

  Get.bottomSheet(
    SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppPalette.reportFlaggedActive,
                    ),
                    child: Icon(Icons.close, size: 18.sp, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'brand_decline_reason_title'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.reportFlaggedActive,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            CustomTextFormField(
              controller: tc,
              maxLines: 5,
              hintText: 'brand_decline_reason_hint'.tr,
              borderColor: AppPalette.error,
            ),
            SizedBox(height: 14.h),

            CustomButton(
              onTap: () {
                onSubmit(tc.text);
                Get.back();
              },
              btnText: 'brand_decline_submit'.tr,
              width: double.infinity,
              btnColor: AppPalette.error,
              textColor: AppPalette.white,
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
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
  final String submitText;

  const _MilestoneBottomSection({
    required this.confirmOwnership,
    required this.acceptLicense,
    required this.onToggleOwnership,
    required this.onToggleLicense,
    required this.onSubmit,
    required this.submitText,
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
                submitText,
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

class _BrandSubmissionSkeleton extends StatelessWidget {
  const _BrandSubmissionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonLine(width: 160.w, height: 12.h),
          SizedBox(height: 12.h),
          _skeletonLine(width: double.infinity, height: 10.h),
          SizedBox(height: 6.h),
          _skeletonLine(width: 220.w, height: 10.h),
          SizedBox(height: 16.h),
          _skeletonLine(width: 120.w, height: 10.h),
          SizedBox(height: 10.h),
          Row(
            children: [
              _skeletonBox(size: 56.w),
              SizedBox(width: 12.w),
              Expanded(child: _skeletonLine(height: 10.h)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _skeletonLine({double? width, double height = 10}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppPalette.border1.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }

  static Widget _skeletonBox({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppPalette.border1.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

void _showWriteReportDialog({
  required BuildContext context,
  required void Function(String reason) onSubmit,
}) {
  final tc = TextEditingController();

  Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: AppPalette.secondary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'write_report_title'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.secondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppPalette.secondary.withOpacity(0.6),
                ),
              ),
              child: CustomTextFormField(
                controller: tc,
                maxLines: 6,
                hintText: 'write_report_hint'.tr,
              ),
            ),

            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: () {
                  onSubmit(tc.text);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'submit_report_btn'.tr, // "Submit Report"
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

void _showSubmittedReportsDialog({required BuildContext context}) {
  final c = Get.find<MilestoneDetailsController>();

  Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Container(
        height: 520.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: AppPalette.secondary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'submitted_report_title'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.secondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: Obx(() {
                final isLoading = c.isSelectedSubmissionReportsLoading.value;
                final list = c.selectedSubmissionReports;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'no_reports_yet'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) {
                    final item = list[i];
                    final idx = i + 1;

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppPalette.thirdColor,
                            borderRadius: BorderRadius.circular(
                              kBorderRadius.r,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Report $idx',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.primary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                c.formatReportDateTime(item.createdAt),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppPalette.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              kBorderRadius.r,
                            ),
                            border: Border.all(color: AppPalette.secondary),
                          ),
                          child: Text(
                            item.content,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppPalette.black,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
