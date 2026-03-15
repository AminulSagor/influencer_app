import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

Future<String?> showReasonBottomSheet({
  required String title,
  required String hintText,
  required String submitText,
}) async {
  final tc = TextEditingController();

  final result = await Get.bottomSheet<String>(
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
                  onTap: () => Get.back<String?>(),
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.reportFlaggedActive,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            CustomTextFormField(
              controller: tc,
              maxLines: 5,
              hintText: hintText,
              borderColor: AppPalette.error,
            ),
            SizedBox(height: 14.h),
            CustomButton(
              onTap: () {
                final reason = tc.text.trim();
                if (reason.isEmpty) {
                  Get.snackbar(
                    'shipping_error_title'.tr,
                    'jobs_decline_reason_required'.tr,
                  );
                  return;
                }
                Get.back(result: reason);
              },
              btnText: submitText,
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

  tc.dispose();
  return result;
}
