import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';

import 'notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.circular(kBorderRadius),
                border: Border.all(
                  color: AppPalette.border1,
                  width: kBorderWidth0_5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  12.h.verticalSpace,
                  _TopBar(controller: controller),
                  12.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'notifications_new'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  Divider(color: AppPalette.border1, thickness: kBorderWeight1),
                  Obx(
                    () => _NotificationGroupCard(
                      items: controller.newItems.value,
                      showNewDot: true,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: AppPalette.border1, thickness: kBorderWeight1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'notifications_earlier'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  Divider(color: AppPalette.border1, thickness: kBorderWeight1),
                  Obx(
                    () => _NotificationGroupCard(
                      items: controller.earlierItems.value,
                      showNewDot: false,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final NotificationsController controller;

  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.back(id: 1),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: AppPalette.primary,
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
          Text(
            'notifications_title'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.markAllAsRead,
            child: Text(
              'notifications_mark_all_read'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card that holds a group of notifications (e.g. "New" or "Earlier")
class _NotificationGroupCard extends StatelessWidget {
  final List<NotificationItem> items;
  final bool showNewDot;

  const _NotificationGroupCard({required this.items, required this.showNewDot});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'notifications_empty'.tr,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
      );
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return _NotificationRow(item: item, showNewDot: showNewDot);
      }),
    );
  }
}

/// Single notification row
class _NotificationRow extends StatelessWidget {
  final NotificationItem item;
  final bool showNewDot;

  const _NotificationRow({required this.item, required this.showNewDot});

  Color _accentColor() {
    switch (item.type) {
      case NotificationType.positive:
        return AppPalette.primary;
      case NotificationType.negative:
        return AppPalette.error;
      case NotificationType.neutral:
        return AppPalette.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final isNegative = item.type == NotificationType.negative;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon circle
          Container(
            width: 36.w,
            height: 36.w,
            padding: EdgeInsets.all(8.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isNegative
                  ? AppPalette.errorGradient
                  : AppPalette.thirdColor,
              border: Border.all(color: accent, width: kBorderWidth0_5),
              gradient: LinearGradient(
                begin: isNegative ? Alignment.topRight : Alignment.bottomLeft,
                end: isNegative ? Alignment.bottomLeft : Alignment.topRight,
                colors: [
                  isNegative ? AppPalette.errorGradient : AppPalette.thirdColor,
                  AppPalette.white,
                ],
              ),
            ),
            child: Image.asset(item.iconPath, fit: BoxFit.cover, color: accent),
          ),
          SizedBox(width: 12.w),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: accent,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.timeLabel,
                  style: TextStyle(fontSize: 10.sp, color: AppPalette.subtext),
                ),
              ],
            ),
          ),

          // New green dot + chevron
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showNewDot)
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(right: 8.w, top: 4.h),
                  decoration: const BoxDecoration(
                    color: AppPalette.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16.sp,
                color: AppPalette.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
