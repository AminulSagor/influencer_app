import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';

class QuoteCard extends StatelessWidget {
  final String base;
  final String vat;
  final String total;
  final int vatPercent;

  const QuoteCard({
    required this.base,
    required this.vat,
    required this.total,
    required this.vatPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: AppPalette.defaultFill.withAlpha(140),
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.primary.withAlpha(90), width: 1),
      ),
      child: Column(
        children: [

          _quoteRow('create_campaign_step4_base'.tr, '৳$base'),

          8.h.verticalSpace,

          _quoteRow(
            'create_campaign_step4_vat'.tr.replaceAll('{p}', '$vatPercent'),
            '৳$vat',
          ),
          10.h.verticalSpace,
          Divider(color: AppPalette.primary.withAlpha(90), height: 1),
          10.h.verticalSpace,
          _quoteRow('create_campaign_step4_total'.tr, '৳$total',),
        ],
      ),
    );
  }

  Widget _quoteRow(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w300,
              color: AppPalette.black,
            ),
          ),
        ),

        Text(
          right,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.secondary,
          ),
        ),
      ],
    );
  }
}