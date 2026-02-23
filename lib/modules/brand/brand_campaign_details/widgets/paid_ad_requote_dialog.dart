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

class PaidAdRequoteDialog {
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
    const int minAgencyPercent = 5;
    const int maxAgencyPercent = 15;
    const double fxRate = 122.37;

    final startBudget = initialBaseBudget > 0 ? initialBaseBudget : 100000;

    final budgetRx = startBudget.obs;
    final vatRx = 0.obs;
    final totalRx = 0.obs;

    final minFeeRx = 0.obs;
    final maxFeeRx = 0.obs;

    final minExclRx = 0.obs;
    final maxExclRx = 0.obs;

    final minUsdRx = 0.0.obs;
    final maxUsdRx = 0.0.obs;

    final budgetCtrl = TextEditingController(text: fmt(startBudget));

    void recalc(int budget) {
      final b = budget.clamp(0, 999999999);
      final vat = (b * vatPercent / 100).round();
      final total = b + vat;

      final minFee = (total * (minAgencyPercent / 100)).round();
      final maxFee = (total * (maxAgencyPercent / 100)).round();

      final minExcl = (total - maxFee).clamp(0, total);
      final maxExcl = (total - minFee).clamp(0, total);

      budgetRx.value = b;
      vatRx.value = vat;
      totalRx.value = total;

      minFeeRx.value = minFee;
      maxFeeRx.value = maxFee;

      minExclRx.value = minExcl;
      maxExclRx.value = maxExcl;

      minUsdRx.value = fxRate <= 0 ? 0 : (minExcl / fxRate);
      maxUsdRx.value = fxRate <= 0 ? 0 : (maxExcl / fxRate);
    }

    recalc(startBudget);

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
                  textAlign: TextAlign.center,
                  onChanged: (v) => recalc(parseAmount(v)),
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
                          left: 'Base Campaign Budget',
                          right: fmt(budgetRx.value),
                          color: primary,
                        ),
                        8.h.verticalSpace,
                        _kv(
                          left: 'VAT/Tax (15%)',
                          right: fmt(vatRx.value),
                          color: primary,
                        ),
                        12.h.verticalSpace,
                        Divider(color: Colors.black12, height: 1),
                        12.h.verticalSpace,
                        _kv(
                          left: 'Total Campaign Cost',
                          right: fmt(totalRx.value),
                          color: primary,
                          strong: true,
                        ),
                      ],
                    ),
                  );
                }),
                12.h.verticalSpace,
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
                        _rangeKv(
                          left: 'Agency Fee (5 - 15%)',
                          right:
                              '${fmt(minFeeRx.value)} – ${fmt(maxFeeRx.value)}',
                          color: primary,
                        ),
                        10.h.verticalSpace,
                        _rangeKv(
                          left: 'Campaign Budget Excluding Agency Fee',
                          right:
                              '${fmt(minExclRx.value)} – ${fmt(maxExclRx.value)}',
                          color: primary,
                        ),
                        10.h.verticalSpace,
                        _rangeKv(
                          left: 'In Dollars (Based On Avg. 122.37 BDT/\$)',
                          right:
                              '\$${minUsdRx.value.toStringAsFixed(2)} – \$${maxUsdRx.value.toStringAsFixed(2)}',
                          color: primary,
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

  static Widget _rangeKv({
    required String left,
    required String right,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
        10.w.horizontalSpace,
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
