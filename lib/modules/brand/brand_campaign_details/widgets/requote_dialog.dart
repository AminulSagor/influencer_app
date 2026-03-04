import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
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

class RequoteDialog {
  static Future<void> show({
    required int initialBaseBudget,
    required ParseAmount parseAmount,
    required FmtAmount fmt,
    required TrOr trOr,
    required SubmitRequote onSubmit,
  }) {
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
                  onChanged: (v) => recalcFrom(parseAmount(v)),
                  textStyle: AppTheme.textStyle.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.secondary,
                  ),
                  textAlign: TextAlign.center,
                  borderColor: AppPalette.secondary,
                ),
                // TextField(
                //   controller: budgetCtrl,
                //   keyboardType: TextInputType.number,
                //   onChanged: (v) => recalcFrom(parseAmount(v)),
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.symmetric(
                //       horizontal: 16.w,
                //       vertical: 14.h,
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(14.r),
                //       borderSide: const BorderSide(color: borderGreen),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(14.r),
                //       borderSide: const BorderSide(color: primary, width: 1.4),
                //     ),
                //   ),
                //   style: TextStyle(
                //     fontSize: 18.sp,
                //     fontWeight: FontWeight.w900,
                //     color: primary.withOpacity(.75),
                //   ),
                //   textAlign: TextAlign.center,
                // ),
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
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppPalette.thirdColor, AppPalette.white],
                      ),
                    ),
                    child: Column(
                      children: [
                        _kv(
                          left: trOr(
                            'brand_campaign_requote_base',
                            'Base Campaign Budget',
                          ),
                          right: fmt(budgetRx.value),
                        ),
                        8.h.verticalSpace,
                        _kv(
                          left: trOr(
                            'brand_campaign_requote_vat',
                            'VAT/Tax (15%)',
                          ),
                          right: fmt(vatRx.value),
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
                        ),
                      ],
                    ),
                  );
                }),
                30.h.verticalSpace,
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

  static Widget _kv({required String left, required String right}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w300,
              color: AppPalette.black,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.secondary,
          ),
        ),
      ],
    );
  }
}
