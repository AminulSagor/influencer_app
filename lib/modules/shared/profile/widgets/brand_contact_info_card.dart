import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';

class BrandContactInfoCard extends StatelessWidget {
  final String email;
  final String phone;
  final String website;

  const BrandContactInfoCard({
    super.key,
    required this.email,
    required this.phone,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          _BrandInfoRow(
            icon: Icons.mail_outline_rounded,
            titleKey: 'brand_email',
            value: email,
          ),
          12.h.verticalSpace,
          _BrandInfoRow(
            icon: Icons.phone_outlined,
            titleKey: 'brand_contact',
            value: phone,
          ),
          12.h.verticalSpace,
          _BrandInfoRow(
            icon: Icons.language_rounded,
            titleKey: 'brand_website',
            value: website,
          ),
        ],
      ),
    );
  }
}

class _BrandInfoRow extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String value;

  const _BrandInfoRow({
    required this.icon,
    required this.titleKey,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.trim().isEmpty ? '-' : value.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppPalette.defaultFill,
            border: Border.all(
              color: AppPalette.border1,
              width: kBorderWidth0_5,
            ),
          ),
          child: Icon(icon, size: 18.sp, color: AppPalette.subtext),
        ),
        14.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label (uses FittedBox + ellipsis)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  titleKey.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w300,
                    color: AppPalette.secondary,
                  ),
                ),
              ),
              3.h.verticalSpace,
              // value (ellipsis for responsiveness)
              Text(
                safeValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppPalette.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
