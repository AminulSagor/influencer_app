import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import 'models/report_model.dart';
import 'report_log_controller.dart';

class ReportLogView extends GetView<ReportLogController> {
  const ReportLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            20.h.verticalSpace,
            // 1. Top Filters Row
            Obx(() {
              final isBrand = controller.isBrand;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isBrand)
                    _buildFilterCard(
                      count: controller.flaggedCount,
                      label: 'flagged'.tr,
                      color: AppPalette.reportFlaggedActive,
                      bgColor: AppPalette.reportFlaggedInactive,
                      status: ReportStatus.flagged,
                    ),

                  _buildFilterCard(
                    count: controller.pendingCount,
                    label: 'pending'.tr,
                    color: AppPalette.reportPendingActive,
                    bgColor: AppPalette.reportPendingInactive,
                    status: ReportStatus.pending,
                  ),

                  _buildFilterCard(
                    count: controller.resolvedCount,
                    label: 'resolved'.tr,
                    color: AppPalette.reportResolvedActive,
                    bgColor: AppPalette.reportResolvedInactive,
                    status: ReportStatus.resolved,
                  ),
                ],
              );
            }),

            14.h.verticalSpace,

            // 2. Search Bar
            CustomTextFormField(
              hintText: 'search_hint'.tr,
              fillColor: AppPalette.thirdColor,
              onChanged: controller.onSearchChanged,
              borderColor: AppPalette.secondary,
              borderRadius: 999.r,
              suffixIcon: Icon(
                Icons.search,
                color: AppPalette.defaultStroke,
                size: 24.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 17.h,
              ),
              textStyle: TextStyle(fontSize: 14.sp, color: AppPalette.greyText),
            ),

            14.h.verticalSpace,

            // 3. List of Reports
            Expanded(
              child: Obx(() {
                if (controller.displayedReports.isEmpty) {
                  return Center(
                    child: Text(
                      "No reports found",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: controller.displayedReports.length,
                  padding: EdgeInsets.only(bottom: 20.h),
                  separatorBuilder: (c, i) => 15.h.verticalSpace,
                  itemBuilder: (context, index) {
                    return _buildReportCard(controller.displayedReports[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildFilterCard({
    required int count,
    required String label,
    required Color color,
    required Color bgColor,
    required ReportStatus status,
  }) {
    final isSelected = controller.selectedFilter.value == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.toggleFilter(status),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? color : bgColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? color : AppPalette.border1,
              width: 1,
            ),
            boxShadow: isSelected
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              FittedBox(
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppPalette.white : color,
                  ),
                ),
              ),
              4.h.verticalSpace,
              FittedBox(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? AppPalette.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    // Define colors based on status
    Color themeColor;
    Color bgTint;
    String btnText;
    IconData? btnIcon;

    switch (report.status) {
      case ReportStatus.flagged:
        themeColor = AppPalette.reportFlaggedActive;
        bgTint = AppPalette.reportFlaggedInactive;
        btnText = 'flagged'.tr;
        btnIcon = Icons.flag;
        break;
      case ReportStatus.pending:
        themeColor = AppPalette.reportPendingActive;
        bgTint = AppPalette.reportPendingInactive;
        btnText = 'pending'.tr;
        btnIcon = Icons.access_time_filled;
        break;
      case ReportStatus.resolved:
        themeColor = AppPalette.reportResolvedActive; // Green
        bgTint = AppPalette.reportResolvedInactive;
        btnText = 'resolved'.tr;
        btnIcon = Icons.check_circle;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgTint, // Very light background tint
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Campaign Name
          Text(
            report.campaignName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppPalette.primary,
            ),
          ),
          4.h.verticalSpace,

          // Milestone & Time
          Text(
            '${'milestone'.tr} ${report.milestone}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: themeColor,
            ),
          ),
          2.h.verticalSpace,
          Text(
            '${report.timeAgo} ${'hours_ago'.tr}',
            style: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
          ),

          12.h.verticalSpace,

          // Message Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppPalette.border1),
            ),
            child: Text(
              report.message.tr,
              style: TextStyle(fontSize: 12.sp, color: AppPalette.greyText),
            ),
          ),

          12.h.verticalSpace,

          // Footer Row
          Row(
            children: [
              // Left Side: Company & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 12.sp,
                        color: AppPalette.complemetary,
                      ), // Brown/Orange in img
                      4.w.horizontalSpace,
                      Text(
                        report.companyName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppPalette.complemetary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  4.h.verticalSpace,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 12.sp,
                        color: AppPalette.complemetary,
                      ),
                      4.w.horizontalSpace,
                      Text(
                        report.date, // e.g., Dec 15, 2025
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppPalette.complemetary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right Side: Status Button
              // Using CustomButton here, adapted to look like a Chip/Capsule
              Spacer(),
              SizedBox(
                height: 30.h,
                child: ElevatedButton(
                  onPressed: () {}, // Action if needed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(btnIcon, color: Colors.white, size: 14.sp),
                      5.w.horizontalSpace,
                      Text(
                        btnText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Small Arrow next to button
              Icon(Icons.chevron_right, size: 18.sp, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }
}
