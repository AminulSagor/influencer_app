import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../profile_controller.dart';

class VerificationInprogressSection extends StatelessWidget {
  final ProfileController controller;

  const VerificationInprogressSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.verificationInprogressItems.map((item) {
          final color = controller.verificationColor(item.state);
          final label = controller.verificationLabel(item.state);

          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppPalette.border1, width: 0.7),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.black.withAlpha(220),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: color,
                            fontWeight: .w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22.sp,
                  color: Colors.grey[500],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
