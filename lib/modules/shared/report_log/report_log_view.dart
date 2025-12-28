// report_log_view.dart
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
    Get.put(ReportLogController()); // Inject Controller

    return Scaffold(
      backgroundColor: Colors.white, // Or AppPalette.scaffoldBackground
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            20.h.verticalSpace,
            // 1. Top Filters Row
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterCard(
                    count: controller.flaggedCount,
                    label: 'flagged'.tr,
                    color: const Color(0xFFD32F2F), // Red
                    bgColor: const Color(0xFFFFEBEE), // Light Red
                    status: ReportStatus.flagged,
                  ),
                  _buildFilterCard(
                    count: controller.pendingCount,
                    label: 'pending'.tr,
                    color: const Color(0xFFF57C00), // Orange
                    bgColor: const Color(0xFFFFF3E0), // Light Orange
                    status: ReportStatus.pending,
                  ),
                  _buildFilterCard(
                    count: controller.resolvedCount,
                    label: 'resolved'.tr,
                    color: const Color(0xFF388E3C), // Green
                    bgColor: const Color(0xFFE8F5E9), // Light Green
                    status: ReportStatus.resolved,
                  ),
                ],
              ),
            ),

            20.h.verticalSpace,

            // 2. Search Bar
            CustomTextFormField(
              hintText: 'search_hint'.tr,
              fillColor: const Color(
                0xFFF4F6F0,
              ), // Light greenish beige from image
              onChanged: controller.onSearchChanged,
              suffixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade700,
                size: 24.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 14.h,
              ),
              textStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),

            20.h.verticalSpace,

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
    bool isSelected = controller.selectedFilter.value == status;

    return GestureDetector(
      onTap: () => controller.toggleFilter(status),
      child: Container(
        width: 105.w, // Approx width to fit 3 in row
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
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
                count.toString(),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            4.h.verticalSpace,
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
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
        themeColor = const Color(0xFFD32F2F); // Red
        bgTint = const Color(0xFFFFEBEE);
        btnText = 'flagged'.tr;
        btnIcon = Icons.flag;
        break;
      case ReportStatus.pending:
        themeColor = const Color(0xFFF57C00); // Orange
        bgTint = const Color(0xFFFFF3E0);
        btnText = 'pending'.tr;
        btnIcon = Icons.access_time_filled;
        break;
      case ReportStatus.resolved:
        themeColor = const Color(0xFF388E3C); // Green
        bgTint = const Color(0xFFE8F5E9);
        btnText = 'resolved'.tr;
        btnIcon = Icons.check_circle;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgTint.withOpacity(0.5), // Very light background tint
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
              color: Colors.black87, // Dark Green in your theme usually
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
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),

          12.h.verticalSpace,

          // Message Box (White)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              report.message.tr, // Using .tr assuming the message is a key
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
            ),
          ),

          12.h.verticalSpace,

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        color: AppPalette.secondary,
                      ), // Brown/Orange in img
                      4.w.horizontalSpace,
                      Text(
                        report.companyName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppPalette.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  4.h.verticalSpace,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.sp,
                        color: AppPalette.secondary,
                      ),
                      4.w.horizontalSpace,
                      Text(
                        report.date, // e.g., Dec 15, 2025
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppPalette.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right Side: Status Button
              // Using CustomButton here, adapted to look like a Chip/Capsule
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
                          fontSize: 11.sp,
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
