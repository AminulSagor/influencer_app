import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
  }) {
    const primary = Color(0xFF2F4F1F);
    const cardGreen = Color(0xFF5E7D3A);
    const warnBg = Color(0xFFFFE6CF);
    const warnBorder = Color(0xFFEF9F59);

    final due = totalDue > 0 ? totalDue : 18000;
    final minPay = (due * 0.5).round();

    final amountRx = due.obs;
    final amountCtrl = TextEditingController(text: fmt(due));
    final methodRx = 'card'.obs;

    void setAmount(int v) {
      amountRx.value = v;
      amountCtrl.text = fmt(v);
    }

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trOr('brand_campaign_fund_title', 'Fund Your Campaign'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.85),
                  ),
                ),
                12.h.verticalSpace,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: cardGreen,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            color: Colors.white.withOpacity(.9),
                            size: 18.sp,
                          ),
                          10.w.horizontalSpace,
                          Expanded(
                            child: Text(
                              campaignTitle.isEmpty
                                  ? 'Summer Fashion Campaign'
                                  : campaignTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.95),
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.h.verticalSpace,
                      Text(
                        trOr('brand_campaign_fund_total_due', 'Total Due'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(.85),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      6.h.verticalSpace,
                      Text(
                        fmt(due),
                        style: TextStyle(
                          color: const Color(0xFFE9F3D8),
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                12.h.verticalSpace,
                if (paidAmount <= 0)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: warnBg,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: warnBorder),
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
                            color: warnBorder,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        8.h.verticalSpace,
                        Text(
                          fmt(minPay),
                          style: TextStyle(
                            color: warnBorder,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                12.h.verticalSpace,
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amountRx.value = parseAmount(v),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: primary.withOpacity(.7)),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
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
                18.h.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    trOr('brand_campaign_fund_method', 'Payment Method'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: primary.withOpacity(.85),
                    ),
                  ),
                ),
                10.h.verticalSpace,
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: methodRx.value,
                    items: [
                      DropdownMenuItem(
                        value: 'card',
                        child: Text(
                          trOr(
                            'brand_campaign_fund_card',
                            'Credit / Debit Card',
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'bkash',
                        child: Text(trOr('brand_campaign_fund_bkash', 'bKash')),
                      ),
                    ],
                    onChanged: (v) => methodRx.value = v ?? 'card',
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: primary.withOpacity(.7)),
                      ),
                    ),
                  );
                }),
                14.h.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: Obx(() {
                    final amt = amountRx.value;
                    final canPay = amt >= minPay && amt <= due;

                    return ElevatedButton(
                      onPressed: canPay
                          ? () async {
                              await onPay(amount: amt);
                            }
                          : () {
                              Get.snackbar(
                                trOr('common_error', 'Error'),
                                trOr(
                                  'brand_campaign_payment_invalid',
                                  'Amount must be between minimum and total due.',
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canPay
                            ? primary.withOpacity(.18)
                            : Colors.black12,
                        foregroundColor: canPay
                            ? Colors.black87
                            : Colors.black38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        trOr('brand_campaign_pay_now', 'Pay Now'),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static Widget _pillBtn({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
