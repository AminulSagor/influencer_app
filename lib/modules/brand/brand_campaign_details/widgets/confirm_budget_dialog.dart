import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
    const primary = Color(0xFF2F4F1F);
    const borderGreen = Color(0xFFBFD7A5);
    const softFill = Color(0xFFF7FAF3);

    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trOr('brand_campaign_confirm_title', 'Confirm Budget ?'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: primary.withOpacity(.75),
                ),
              ),
              12.h.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: softFill,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderGreen),
                ),
                child: Column(
                  children: [
                    _kv(
                      left: 'Base Campaign Budget',
                      right: fmt(baseBudget),
                      color: primary,
                    ),
                    10.h.verticalSpace,
                    _kv(
                      left: 'VAT/Tax (15%)',
                      right: fmt(vatAmount),
                      color: primary,
                    ),
                  ],
                ),
              ),
              14.h.verticalSpace,
              Text(
                'Total Campaign Cost',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              6.h.verticalSpace,
              Text(
                fmt(totalCost),
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w900,
                  color: primary.withOpacity(.75),
                ),
              ),
              18.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        onRequote();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        trOr('brand_campaign_details_requote', 'Requote'),
                      ),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await onConfirm();
                        if (ok) Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        backgroundColor: primary.withOpacity(.65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        trOr('brand_campaign_confirm_btn', 'Confirm'),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
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

  static Widget _kv({
    required String left,
    required String right,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(.75),
          ),
        ),
      ],
    );
  }
}
