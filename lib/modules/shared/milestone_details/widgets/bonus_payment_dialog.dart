import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../milestone_details_controller.dart';

class BonusPaymentDialog extends GetView<MilestoneDetailsController> {
  const BonusPaymentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF4F712D), Color(0xFF7DA058)],
          ),
        ),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: AppPalette.thirdColor,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'provide_bonus_amount_title'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.thirdColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${'bonus_to_label'.tr}: ${controller.bonusReceiverName}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                  color: AppPalette.thirdColor,
                ),
              ),
              SizedBox(height: 18.h),

              CustomTextFormField(
                controller: controller.bonusAmountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                hintText: '৳ 18,000',
                fillColor: AppPalette.white,
                textStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),

              SizedBox(height: 20.h),
              Text(
                'payment_method'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),

              CustomDropDownMenu(
                hintText: 'Select Method',
                options: ['Credit / Debit Card', 'Bkash'],
                value: controller.selectedBonusPaymentMethod.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.setBonusPaymentMethod(value);
                  }
                },
              ),

              SizedBox(height: 24.h),

              CustomButton(
                onTap: controller.isBonusPaymentLoading.value
                    ? null
                    : controller.payBonus,
                btnText: controller.isBonusPaymentLoading.value
                    ? 'Paying..'
                    : 'pay_now'.tr,
                isDisabled: controller.isBonusPaymentLoading.value,
                gradient: LinearGradient(
                  colors: [AppPalette.thirdColor, AppPalette.white],
                ),
                textColor: AppPalette.primary,
                width: double.infinity,
              ),
            ],
          );
        }),
      ),
    );
  }
}
