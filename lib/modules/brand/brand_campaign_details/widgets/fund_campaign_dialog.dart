import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../../core/utils/app_snackbar.dart';

typedef TrOr = String Function(String key, String fallback);
typedef FmtAmount = String Function(int amount);
typedef ParseAmount = int Function(String input);

typedef PayHandler = Future<void> Function({required int amount});

class FundCampaignDialog {
  static Future<void> show({
    required String campaignTitle,
    required int totalDue,
    required int paidAmount,
    required TrOr trOr,
    required FmtAmount fmt,
    required ParseAmount parseAmount,
    required PayHandler onPay,
    RxBool? isPaying,
  }) {
    final due = totalDue > 0 ? totalDue : 18000;
    final minPay = (due * 0.5).round();

    final amountRx = due.obs;
    final amountCtrl = TextEditingController(text: fmt(due));
    final methodRx = 'SSLCommerz'.obs;

    void setAmount(int v) {
      amountRx.value = v;
      amountCtrl.text = fmt(v);
    }

    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.black12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trOr('brand_campaign_fund_title', 'Fund Your Campaign'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
                10.h.verticalSpace,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 15.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kBorderRadius.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppPalette.secondary, AppPalette.gradient1],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/online_ads.png',
                            width: 30.w,
                            height: 30.w,
                            fit: BoxFit.cover,
                          ),
                          12.w.horizontalSpace,
                          Expanded(
                            child: Text(
                              campaignTitle.isEmpty
                                  ? 'Unknown Campaign'
                                  : campaignTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppPalette.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.h.verticalSpace,
                      Text(
                        trOr('brand_campaign_fund_total_due', 'Total Due'),
                        style: TextStyle(
                          color: AppPalette.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      2.h.verticalSpace,
                      Text(
                        fmt(due),
                        style: TextStyle(
                          color: AppPalette.thirdColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (paidAmount <= 0) ...[
                  15.h.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.complemetaryFill,
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      border: Border.all(
                        color: AppPalette.complemetary,
                        width: kBorderWidth0_5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          trOr(
                            'brand_campaign_fund_minimum_label',
                            'Minimum Fund Needed To Start The Campaign (50%)',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppPalette.complemetary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        8.h.verticalSpace,
                        Text(
                          fmt(minPay),
                          style: TextStyle(
                            color: AppPalette.complemetary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                15.h.verticalSpace,
                CustomTextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amountRx.value = parseAmount(v),
                  textAlign: TextAlign.center,
                  textStyle: AppTheme.textStyle.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.black,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                10.h.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: _pillBtn(
                        text: trOr(
                          'brand_campaign_fund_full',
                          'Pay In Full (100%)',
                        ),
                        onTap: () => setAmount(due),
                      ),
                    ),
                    10.w.horizontalSpace,
                    Expanded(
                      child: _pillBtn(
                        text: trOr(
                          'brand_campaign_fund_min',
                          'Pay Minimum (50%)',
                        ),
                        onTap: () => setAmount(minPay),
                      ),
                    ),
                  ],
                ),
                10.h.verticalSpace,
                _pillBtn(
                  text: trOr('brand_campaign_fund_75', 'Pay (75%)'),
                  onTap: () => setAmount((due * 0.75).round()),
                ),
                20.h.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    trOr('brand_campaign_fund_method', 'Payment Method'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                5.h.verticalSpace,
                Obx(() {
                  return CustomDropDownMenu(
                    hintText: 'SSLCommerz',
                    options: ['SSLCommerz'],
                    value: methodRx.value,
                    onChanged: (v) => methodRx.value = v ?? 'card',
                  );
                }),
                25.h.verticalSpace,
                Obx(() {
                  final amt = amountRx.value;
                  final canPay = amt >= minPay && amt <= due;
                  final loading = isPaying?.value ?? false;

                  return CustomButton(
                    onTap: (canPay && !loading)
                        ? () async {
                            await onPay(amount: amt);
                          }
                        : () {
                            if (!loading) {
                              AppSnackbar.showErrorSnackbar(
                                title: 'Error',
                                message:
                                    'Amount must be between minimum and total due.',
                              );
                            }
                          },
                    btnText: trOr('brand_campaign_pay_now', 'Pay Now'),
                    isLoading: loading,
                    isDisabled: !canPay || loading,
                    width: double.infinity,
                    btnColor: canPay ? AppPalette.secondary : AppPalette.fill2,
                    textColor: canPay ? AppPalette.white : AppPalette.greyText,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static Widget _pillBtn({required String text, required VoidCallback onTap}) {
    return CustomButton(
      onTap: onTap,
      btnText: text,
      borderRadius: 999.r,
      btnColor: AppPalette.defaultFill,
      borderColor: Colors.transparent,
      textStyle: AppTheme.textStyle.copyWith(
        fontSize: 10.sp,
        color: AppPalette.black,
      ),
    );
  }
}
