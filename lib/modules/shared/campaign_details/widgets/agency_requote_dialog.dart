import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

class AgencyRequoteInput {
  final int serviceFeePercent;
  final double dollarRate;

  const AgencyRequoteInput({
    required this.serviceFeePercent,
    required this.dollarRate,
  });
}

class AgencyRequoteDialog extends StatefulWidget {
  final int initialServiceFeePercent;
  final double initialDollarRate;

  // base budget = campaign spent (as in screenshot: 100,000)
  final double baseBudget;

  // for overview calc
  final double vatPercent;
  final double platformFeePercent;

  const AgencyRequoteDialog({
    super.key,
    required this.initialServiceFeePercent,
    required this.initialDollarRate,
    required this.baseBudget,
    required this.vatPercent,
    required this.platformFeePercent,
  });

  @override
  State<AgencyRequoteDialog> createState() => _AgencyRequoteDialogState();
}

class _AgencyRequoteDialogState extends State<AgencyRequoteDialog> {
  late final TextEditingController _percentC;
  late final TextEditingController _dollarC;

  final _serviceFeePercentRx = 0.obs;
  final _dollarRateRx = 0.0.obs;

  @override
  void initState() {
    super.initState();

    _serviceFeePercentRx.value = widget.initialServiceFeePercent;
    _dollarRateRx.value = widget.initialDollarRate;

    _percentC = TextEditingController(
      text: widget.initialServiceFeePercent.toString(),
    );
    _dollarC = TextEditingController(
      text: widget.initialDollarRate.toStringAsFixed(2),
    );

    _percentC.addListener(() {
      final v = int.tryParse(_percentC.text.trim()) ?? 0;
      _serviceFeePercentRx.value = v;
    });

    _dollarC.addListener(() {
      final raw = _dollarC.text.trim().replaceAll(',', '');
      final v = double.tryParse(raw) ?? 0;
      _dollarRateRx.value = v;
    });
  }

  @override
  void dispose() {
    _percentC.dispose();
    _dollarC.dispose();
    super.dispose();
  }

  double get _base => widget.baseBudget <= 0 ? 0 : widget.baseBudget;

  double _pctOf(double amount, double pct) => (amount * (pct / 100.0));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top title
            Row(
              children: [
                Text(
                  'Requote',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.secondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 22.sp),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            _label('Requote your charge in percentage'),
            SizedBox(height: 8.h),

            _inputBox(
              controller: _percentC,
              suffix: '%',
              keyboard: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),

            SizedBox(height: 14.h),

            _label('Write Dollar Rate'),
            SizedBox(height: 8.h),
            _inputBox(
              controller: _dollarC,
              prefix: '৳ ',
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                LengthLimitingTextInputFormatter(10),
              ],
            ),

            SizedBox(height: 14.h),

            _label('New Requote Overview'),
            SizedBox(height: 8.h),

            Obx(() {
              final feePct = _serviceFeePercentRx.value.toDouble();
              final dollarRate = _dollarRateRx.value;

              final vatAmt = _pctOf(_base, widget.vatPercent);
              final totalPayable = _base + vatAmt;

              final yourProfit = _pctOf(_base, feePct);
              final platformCharge = _pctOf(_base, widget.platformFeePercent);
              final actualProfit = (yourProfit - platformCharge);
              final actualProfitSafe = actualProfit < 0 ? 0.0 : actualProfit;

              final spentUsd = (dollarRate > 0) ? (_base / dollarRate) : null;

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
                    _ovRow(
                      'Total Payable By Client',
                      formatCurrencyByLocale(totalPayable),
                    ),
                    SizedBox(height: 4.h),
                    _ovRow('Your Profit', formatCurrencyByLocale(yourProfit)),
                    SizedBox(height: 4.h),
                    _ovRow(
                      'Platform Charge',
                      '-${formatCurrencyByLocale(platformCharge)}',
                    ),
                    SizedBox(height: 4.h),
                    _ovRow(
                      'Actual Profit',
                      formatCurrencyByLocale(actualProfitSafe),
                    ),

                    SizedBox(height: 12.h),

                    _ovRow(
                      'Total Campaign Spent',
                      formatCurrencyByLocale(_base),
                    ),
                    SizedBox(height: 4.h),
                    _ovRow(
                      dollarRate > 0
                          ? 'Campaign Spent In Dollar (${dollarRate.toStringAsFixed(2)} BDT/\$ )'
                          : 'Campaign Spent In Dollar',
                      spentUsd == null
                          ? '—'
                          : '\$${spentUsd.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 16.h),

            CustomButton(
              onTap: () {
                final fee = int.tryParse(_percentC.text.trim()) ?? 0;
                final dollar =
                    double.tryParse(_dollarC.text.trim().replaceAll(',', '')) ??
                    0;

                if (fee <= 0 || fee > 100) {
                  Get.snackbar('Error', 'Enter a valid percentage (1-100).');
                  return;
                }
                if (dollar <= 0) {
                  Get.snackbar('Error', 'Enter a valid dollar rate.');
                  return;
                }

                Get.back(
                  result: AgencyRequoteInput(
                    serviceFeePercent: fee,
                    dollarRate: dollar,
                  ),
                );
              },
              btnText: 'Requote To Client',
              btnColor: const Color(0xFF7C9A57),
              textColor: Colors.white,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppPalette.black,
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    required TextInputType keyboard,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.secondary, width: kBorderWidth0_5),
      ),
      child: Row(
        children: [
          if (prefix != null) ...[
            Text(
              prefix,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.secondary,
              ),
            ),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              inputFormatters: inputFormatters,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.secondary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (suffix != null) ...[
            Text(
              suffix,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ovRow(String label, String value, {bool isBold = false}) {
    final labelStyle = TextStyle(
      fontSize: 10.sp,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w300,
      color: AppPalette.primary,
    );
    final valueStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
      color: const Color(0xFF5C7F2C),
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
      ],
    );
  }
}
