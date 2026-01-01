import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_drop_down_menu.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../profile_controller.dart';

class PayoutSettingsSection extends StatelessWidget {
  final ProfileController controller;

  const PayoutSettingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          ...controller.payoutMethods.map((payout) {
            final title = payout.isBank ? payout.accountName : payout.bKashNo;
            final subTitle = payout.isBank ? payout.bankName : 'Bkash';
            final account = payout.isBank
                ? 'Account No: ${controller.maskString(payout.accountNo ?? '')}'
                : payout.bKashName;
            final textColor = payout.isApproved
                ? AppPalette.primary
                : AppPalette.complemetary;

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: [0.5, 1],
                  colors: [
                    AppPalette.white,
                    payout.isApproved
                        ? AppPalette.thirdColor
                        : AppPalette.complemetaryFill,
                  ],
                ),
                borderRadius: BorderRadius.circular(kBorderRadius.r),
                border: Border.all(
                  color: payout.isApproved
                      ? AppPalette.secondary
                      : AppPalette.color4Stroke,
                ),
              ),
              child: Row(
                children: [
                  payout.isBank
                      ? Image.asset(
                          'assets/icons/bank.png',
                          width: 30.w,
                          fit: BoxFit.cover,
                          color: payout.isApproved
                              ? AppPalette.secondary
                              : AppPalette.complemetary,
                        )
                      : Image.asset(
                          'assets/icons/bkash.png',
                          width: 25.w,
                          fit: BoxFit.cover,
                        ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: FittedBox(
                      fit: .scaleDown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          Text(
                            subTitle ?? '',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppPalette.subtext,
                            ),
                          ),
                          Text(
                            account ?? '',
                            style: TextStyle(fontSize: 10.sp, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (payout.isApproved) ...[
                    8.w.horizontalSpace,
                    CustomButton(
                      onTap: () {},
                      btnText: 'Remove',
                      textColor: AppPalette.white,
                      height: 26.h,
                    ),
                  ],
                  if (!payout.isApproved) ...[
                    8.w.horizontalSpace,
                    CustomButton(
                      onTap: null,
                      btnText: 'In Review',
                      btnColor: AppPalette.complemetaryFill,
                      textColor: AppPalette.complemetary,
                      showBorder: false,
                      height: 26.h,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 12.h),
          if (controller.showNewPayoutAccountForm.value) _NewPaymentMethod(),
          15.h.verticalSpace,
          CustomButton.dotted(
            height: 47.h,
            width: double.infinity,
            onTap: () => controller.showNewPayoutAccountForm.value = true,
            btnText: '+ Add Another Payout Method',
            btnColor: AppPalette.white,
            textColor: AppPalette.primary,
          ),
        ],
      ),
    );
  }
}

class _NewPaymentMethod extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Obx(() {
        Widget leadingIcon;
        if (controller.selectedAccountType.value == 'Bank') {
          leadingIcon = Image.asset(
            'assets/icons/bank.png',
            width: 32.w,
            height: 32.w,
            fit: .cover,
          );
          ;
        } else {
          leadingIcon = Image.asset(
            'assets/icons/bkash.png',
            width: 34.w,
            height: 34.w,
            fit: .cover,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                leadingIcon,
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomDropDownMenu(
                    hintText: 'Select Method',
                    options: controller.accountTypes,
                    value: controller.selectedAccountType.value,
                    onChanged: controller.changeAccountType,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: controller.submitNewPayoutForm,
                  child: Icon(
                    Icons.check,
                    color: AppPalette.secondary,
                    size: 20.sp,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      controller.showNewPayoutAccountForm.value = false,
                  child: Icon(
                    Icons.close,
                    color: AppPalette.error,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            if (controller.selectedAccountType.value == 'Bank') ...[
              CustomTextFormField(
                title: 'Bank Name',
                controller: controller.bankNameController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              CustomTextFormField(
                title: 'Bank Account Holder Name',
                controller: controller.accountHolderNameController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              CustomTextFormField(
                title: 'Bank Account No',
                controller: controller.bankAccountNumberController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              CustomTextFormField(
                title: 'Routing Number',
                controller: controller.routingNumberController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
            ] else if (controller.selectedAccountType.value == 'bKash') ...[
              CustomTextFormField(
                title: 'bKash No.',
                controller: controller.bKashNoController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              CustomTextFormField(
                title: 'bKash Holder Name.',
                controller: controller.bKashHolderNameController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              CustomTextFormField(
                title: 'bKash Account Type',
                controller: controller.bKashAccountTypeController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
            ],
            20.h.verticalSpace,
          ],
        );
      }),
    );
  }
}
