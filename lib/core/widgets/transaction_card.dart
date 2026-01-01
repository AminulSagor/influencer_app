import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/transaction_model.dart';
import '../theme/app_palette.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel item;

  const TransactionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isInbound = item.type == TransactionType.inbound;

    final bgColor = isInbound ? AppPalette.thirdColor : AppPalette.gradient2;
    final txtColor = isInbound ? AppPalette.primary : AppPalette.complemetary;
    final accentColor = isInbound
        ? AppPalette.secondary
        : AppPalette.complemetary;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.white, bgColor],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentColor, width: kBorderWidth0_5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.4)),
              gradient: LinearGradient(
                colors: [bgColor, AppPalette.white],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Icon(
              isInbound
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: accentColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.titleKey.trParams(item.titleParams),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: txtColor,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.greyText,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatCurrencyByLocale(item.amount),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: txtColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${item.detailsKey.tr} >',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: txtColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }
}
