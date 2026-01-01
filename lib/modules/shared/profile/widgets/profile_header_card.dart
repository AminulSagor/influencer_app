import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../profile_controller.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileHeaderCard({super.key, required this.controller});

  String _iconForPlatform(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('insta')) return 'assets/icons/instagram.png';
    if (p.contains('youtube')) return 'assets/icons/youTube.png';
    if (p.contains('tiktok')) return 'assets/icons/tikTok.png';
    return 'assets/icons/tikTok.png';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          gradient: const LinearGradient(
            colors: [AppPalette.gradient1, AppPalette.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 38.r,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 32.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 6.h),

                    _StatusChip(label: controller.profileStatusLabel),
                    SizedBox(height: 10.h),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.profileName.value,
                          style: TextStyle(
                            color: AppPalette.thirdColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Image.asset(
                          'assets/icons/unverified_account.png',
                          width: 16.w,
                          height: 16.w,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    if (controller.accountTypeService.isBrand) ...[
                      Text(
                        controller.brandName.value,
                        style: TextStyle(
                          color: AppPalette.white,
                          fontSize: 10.sp,
                        ),
                      ),
                      10.h.verticalSpace,
                      CustomButton(
                        onTap: () {},
                        btnText: 'Log Out',
                        btnColor: AppPalette.thirdColor,
                        textColor: AppPalette.black,
                        height: 28.h,
                        width: 164.w,
                      ),
                    ],
                    // Location text
                    if (!controller.accountTypeService.isBrand)
                      Text(
                        controller.profileLocation.value,
                        style: TextStyle(
                          color: AppPalette.secondary,
                          fontSize: 10.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!controller.accountTypeService.isBrand) ...[
              35.w.horizontalSpace,
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Take first 3 socials and render like the design
                      ...controller.socialAccounts
                          .take(3)
                          .map(
                            (social) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    _iconForPlatform(social.platform),
                                    width: 20.w,
                                    height: 20.w,
                                  ),

                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      social.handle,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppPalette.thirdColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      16.h.verticalSpace,
                      CustomButton(
                        onTap: () {},
                        btnText: 'Log Out',
                        btnColor: AppPalette.thirdColor,
                        textColor: AppPalette.black,
                        height: 28.h,
                        width: 164.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppPalette.thirdColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppPalette.black,
          fontSize: 8.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
