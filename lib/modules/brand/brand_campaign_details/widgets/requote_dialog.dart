import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

typedef SubmitRequote =
    Future<void> Function({
      required int proposedBaseBudget,
      required int vatAmountValue,
      bool closeDialog,
    });

typedef ParseAmount = int Function(String input);
typedef FmtAmount = String Function(int amount);
typedef TrOr = String Function(String key, String fallback);

class RequoteDialog {
  static Future<void> show({
    required int initialBaseBudget,
    required ParseAmount parseAmount,
    required FmtAmount fmt,
    required TrOr trOr,
    required SubmitRequote onSubmit,
  }) {
    const primary = Color(0xFF2F4F1F);
    const borderGreen = Color(0xFFBFD7A5);
    const softFill = Color(0xFFF7FAF3);

    const int vatPercent = 15;

    final budget = initialBaseBudget <= 0 ? 100000 : initialBaseBudget;

    final budgetRx = budget.obs;
    final vatRx = (budget * vatPercent ~/ 100).obs;
    final totalRx = (budgetRx.value + vatRx.value).obs;

    final budgetCtrl = TextEditingController(text: fmt(budget));

    void recalcFrom(int b) {
      budgetRx.value = b;
      vatRx.value = (b * vatPercent / 100).round();
      totalRx.value = b + vatRx.value;
    }

    recalcFrom(budgetRx.value);

    return Get.dialog(
      Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 18.w),
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
                  trOr('brand_campaign_requote_title', 'Requote'),
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.75),
                  ),
                ),
                8.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_subtitle',
                    'Requote your campaign budget',
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                12.h.verticalSpace,
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => recalcFrom(parseAmount(v)),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: borderGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: primary, width: 1.4),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                14.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_overview',
                    'New Requote Overview',
                  ),
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                10.h.verticalSpace,
                Obx(() {
                  return Container(
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
                          left: trOr(
                            'brand_campaign_requote_base',
                            'Base Campaign Budget',
                          ),
                          right: fmt(budgetRx.value),
                          color: primary,
                        ),
                        8.h.verticalSpace,
                        _kv(
                          left: trOr(
                            'brand_campaign_requote_vat',
                            'VAT/Tax (15%)',
                          ),
                          right: fmt(vatRx.value),
                          color: primary,
                        ),
                        12.h.verticalSpace,
                        Divider(color: Colors.black12, height: 1),
                        12.h.verticalSpace,
                        _kv(
                          left: trOr(
                            'brand_campaign_requote_total',
                            'Total Campaign Cost',
                          ),
                          right: fmt(totalRx.value),
                          color: primary,
                          strong: true,
                        ),
                      ],
                    ),
                  );
                }),
                16.h.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      await onSubmit(
                        proposedBaseBudget: budgetRx.value,
                        vatAmountValue: vatRx.value,
                        closeDialog: true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary.withOpacity(.65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      trOr('brand_campaign_requote_submit', 'Requote To Admin'),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    bool strong = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: strong ? 14.sp : 13.sp,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(.75),
          ),
        ),
      ],
    );
  }
}
