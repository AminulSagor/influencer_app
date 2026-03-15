import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

class LogoutDialog {
  static Future<bool> show() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        backgroundColor: AppPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius.r),
        ),
        actions: [
          CustomButton(
            onTap: () => Get.back(result: false),
            btnText: 'Cancel',
            btnColor: AppPalette.defaultFill,
            textColor: AppPalette.black,
          ),
          CustomButton(
            onTap: () => Get.back(result: true),
            btnText: 'Logout',
            btnColor: AppPalette.reportFlaggedActive,
            textColor: AppPalette.white,
          ),
        ],
      ),
      barrierDismissible: true,
    );

    return result == true;
  }
}
