import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

class DeleteCampaignDialog {
  static Future<bool> show() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text(
          'Are you sure you want to delete this draft campaign?',
        ),
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
            btnText: 'Delete',
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
