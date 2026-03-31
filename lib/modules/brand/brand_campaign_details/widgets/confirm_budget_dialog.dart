import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

typedef AcceptQuote = Future<bool> Function();
typedef FmtAmount = String Function(int amount);
typedef TrOr = String Function(String key, String fallback);

class ConfirmBudgetDialog {
  static Future<void> show({
    required int baseBudget,
    required int vatAmount,
    required int totalCost,
    required FmtAmount fmt,
    required TrOr trOr,
    required VoidCallback onRequote,
    required AcceptQuote onConfirm,
  }) {
    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kBorderRadius.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trOr('brand_campaign_confirm_title', 'Confirm Budget ?'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.secondary,
                ),
              ),
              12.h.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadius.r),
                  border: Border.all(
                    color: AppPalette.secondary,
                    width: kBorderWidth0_5.w,
                  ),
                  gradient: LinearGradient(
                    colors: [AppPalette.thirdColor, AppPalette.white],
                  ),
                ),
                child: Column(
                  children: [
                    _kv(left: 'Base Campaign Budget', right: fmt(baseBudget)),
                    10.h.verticalSpace,
                    _kv(left: 'VAT/Tax (15%)', right: fmt(vatAmount)),
                  ],
                ),
              ),
              14.h.verticalSpace,
              Text(
                'Total Campaign Cost',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              6.h.verticalSpace,
              Text(
                fmt(totalCost),
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.secondary,
                ),
              ),
              18.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        Get.back();
                        onRequote();
                      },
                      btnText: trOr(
                        'brand_campaign_details_requote',
                        'Requote',
                      ),
                      btnColor: AppPalette.defaultFill,
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: CustomButton(
                      onTap: () async {
                        Get.back(); // Dismiss current dialog first
                        await onConfirm();
                      },
                      btnText: trOr('brand_campaign_confirm_btn', 'Confirm'),
                      textColor: AppPalette.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static Widget _kv({required String left, required String right}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              color: AppPalette.black,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.secondary,
          ),
        ),
      ],
    );
  }
}
