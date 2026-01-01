import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/models/job_item.dart';
import '../../../../core/services/account_type_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../milestone_details_controller.dart';

class SubmissionCard extends StatelessWidget {
  final int index;
  final SubmissionUiModel submission;
  final VoidCallback onPickFiles;
  final Function(int proofIndex) onRemoveProof;
  final VoidCallback onEditDeclined;
  final AccountTypeService accountTypeService;

  const SubmissionCard({
    super.key,
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
