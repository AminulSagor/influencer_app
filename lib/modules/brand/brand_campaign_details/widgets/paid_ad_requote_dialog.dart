import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

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
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trOr('brand_campaign_requote_title', 'Requote'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.secondary,
                  ),
                ),
                8.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_subtitle',
                    'Requote your campaign budget',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.black,
                  ),
                ),
                12.h.verticalSpace,
                CustomTextFormField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (v) => recalc(parseAmount(v)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.secondary,
                  ),
                ),
                14.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_overview',
                    'New Requote Overview',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.black,
                  ),
                ),
                10.h.verticalSpace,
                Obx(() {
                  return Container(
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
                        _kv(
                          left: 'Base Campaign Budget',
                          right: fmt(budgetRx.value),
                          color: AppPalette.black,
                        ),
                        4.h.verticalSpace,
                        _kv(
                          left: 'VAT/Tax (15%)',
                          right: fmt(vatRx.value),
                          color: AppPalette.black,
                        ),
                        6.h.verticalSpace,
                        Divider(color: Colors.black12, height: 1),
                        6.h.verticalSpace,
                        _kv(
                          left: 'Total Campaign Cost',
                          right: fmt(totalRx.value),
                          color: AppPalette.black,
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
                        _kv(
                          left: 'Agency Fee (5 - 15%)',
                          right:
                              '${fmt(minFeeRx.value)} – ${fmt(maxFeeRx.value)}',
                          color: AppPalette.primary,
                        ),
                        10.h.verticalSpace,
                        _kv(
                          left: 'Campaign Budget Excluding Agency Fee',
                          right:
                              '${fmt(minExclRx.value)} – ${fmt(maxExclRx.value)}',
                          color: AppPalette.black,
                        ),
                        10.h.verticalSpace,
                        _kv(
                          left: 'In Dollars (Based On Avg. 122.37 BDT/\$)',
                          right:
                              '\$${minUsdRx.value.toStringAsFixed(2)} – \$${maxUsdRx.value.toStringAsFixed(2)}',
                          color: AppPalette.primary,
                        ),
                      ],
                    ),
                  );
                }),
                16.h.verticalSpace,
                CustomButton(
                  onTap: () async {
                    await onSubmit(
                      proposedBaseBudget: budgetRx.value,
                      vatAmountValue: vatRx.value,
                      closeDialog: true,
                    );
                  },
                  btnText: trOr(
                    'brand_campaign_requote_submit',
                    'Requote To Admin',
                  ),
                  textColor: AppPalette.white,
                  width: double.infinity,
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
              fontSize: 10.sp,
              fontWeight: strong ? FontWeight.w500 : FontWeight.w300,
              color: color,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: strong ? FontWeight.w600 : FontWeight.w500,
            color: AppPalette.secondary,
          ),
        ),
      ],
    );
  }
}
