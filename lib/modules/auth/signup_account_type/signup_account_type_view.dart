import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/top_back_and_step.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_account_type_controller.dart';

class SignupAccountTypeView extends GetView<SignupAccountTypeController> {
  const SignupAccountTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Obx(() {
                  return TopBackAndStep(
                    currentStep: 1,
                    totalSteps: controller.totalSteps.value,
                  );
                }),

                SizedBox(height: 40.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'signup_title'.tr,
                    style: TextStyle(
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'signup_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w300,
                      color: AppPalette.primary,
                    ),
                  ),
                ),

                SizedBox(height: 38.h),

                // Account type cards
                Obx(
                  () => Column(
                    children: [
                      _AccountTypeCard(
                        isSelected:
                            controller.selectedType.value == AccountType.brand,
                        title: 'signup_brand_title'.tr,
                        subtitle: 'signup_brand_subtitle'.tr,
                        onTap: () => controller.selectType(AccountType.brand),
                        showCheck: true,
                      ),
                      SizedBox(height: 18.h),
                      _AccountTypeCard(
                        isSelected:
                            controller.selectedType.value ==
                            AccountType.influencer,
                        title: 'signup_influencer_title'.tr,
                        subtitle: 'signup_influencer_subtitle'.tr,
                        showCheck: true,
                        onTap: () =>
                            controller.selectType(AccountType.influencer),
                      ),
                      SizedBox(height: 18.h),
                      _AccountTypeCard(
                        isSelected:
                            controller.selectedType.value ==
                            AccountType.adAgency,
                        title: 'signup_agency_title'.tr,
                        subtitle: 'signup_agency_subtitle'.tr,
                        showCheck: true,
                        onTap: () =>
                            controller.selectType(AccountType.adAgency),
                      ),
                    ],
                  ),
                ),

                55.h.verticalSpace,

                // Continue button
                CustomButton(
                  onTap: controller.onContinue,
                  btnText: 'signup_continue'.tr,
                  height: 64.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showCheck;

  const _AccountTypeCard({
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected
        ? AppPalette.primary
        : AppPalette.defaultStroke;
    final Color bgColor = isSelected
        ? AppPalette.thirdColor
        : AppPalette.defaultFill;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadiusLarge.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(kBorderRadiusLarge.r),
          border: Border.all(color: borderColor, width: kBorderWeight1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Tick icon when selected (only per design on Influencer, but we
            // show for whichever is selected and allow design to match)
            if (isSelected && showCheck) ...[
              SizedBox(width: 12.w),
              Icon(Icons.check, size: 26.sp, color: AppPalette.primary),
            ],
          ],
        ),
      ),
    );
  }
}
