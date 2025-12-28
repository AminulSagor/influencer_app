import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import 'campaign_shipping_controller.dart';

class CampaignShippingView extends GetView<CampaignShippingController> {
  const CampaignShippingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_back, size: 25.sp, color: AppPalette.primary),
              SizedBox(height: 20.h),
              _ShippingSection(),
              SizedBox(height: 32.h),
              _TermsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- SHIPPING SECTION ----------------

class _ShippingSection extends GetView<CampaignShippingController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title row ...
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 25.sp,
                color: AppPalette.primary,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'shipping_where_to_send'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textStyle.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppPalette.primary,
                size: 26.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(
            () => Column(
              children: List.generate(controller.addresses.length, (index) {
                final address = controller.addresses[index];
                final bool selected = controller.selectedIndex.value == index;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _AddressCard(
                    labelKey: address.labelKey,
                    address: address.address,
                    isDefault: address.isDefault,
                    selected: selected,
                    onTap: () => controller.onAddressSelected(index),
                    onEditTap: () => controller.onEditPressed(index),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 8.h),
          CustomButton.dotted(
            height: 41.h,
            width: double.infinity,
            onTap: controller.onAddAnotherPressed,
            btnText: 'shipping_add_another'.tr,
            btnColor: AppPalette.white,
            textStyle: AppTheme.textStyle.copyWith(
              fontSize: 14.sp,
              fontWeight: .w500,
              color: AppPalette.secondary,
            ),
            borderColor: AppPalette.secondary,
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String labelKey;
  final String address;
  final bool isDefault;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const _AddressCard({
    required this.labelKey,
    required this.address,
    required this.isDefault,
    required this.selected,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? AppPalette.secondary
        : AppPalette.border1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 94.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: borderColor, width: kBorderWidth0_5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: .center,
          children: [
            // radio
            Container(
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppPalette.secondary : AppPalette.border1,
                  width: 2,
                ),
              ),
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: selected ? AppPalette.secondary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: .center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      labelKey.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.textStyle.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                  Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textStyle.copyWith(
                      fontSize: 10.sp,
                      color: AppPalette.subtext,
                    ),
                  ),
                  if (isDefault) ...[
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.secondary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'shipping_default'.tr,
                        style: AppTheme.textStyle.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppPalette.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onEditTap,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.edit_rounded,
                size: 18.sp,
                color: AppPalette.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ---------------- TERMS & ACTIONS SECTION ----------------

class _TermsSection extends GetView<CampaignShippingController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          // First checkbox
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: controller.hasReadTerms.value,
                  onChanged: controller.toggleReadTerms,
                  activeColor: AppPalette.secondary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                Expanded(
                  child: Text(
                    'shipping_confirm_read_terms'.tr,
                    style: AppTheme.textStyle.copyWith(
                      fontSize: 12.sp,
                      fontWeight: .w500,
                      color: AppPalette.subtext,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Second checkbox
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: controller.acceptsTerms.value,
                  onChanged: controller.toggleAcceptTerms,
                  activeColor: AppPalette.secondary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                Expanded(
                  child: Text(
                    'shipping_accept_license_terms'.tr,
                    style: AppTheme.textStyle.copyWith(
                      fontSize: 12.sp,
                      fontWeight: .w500,
                      color: AppPalette.subtext,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onTap: controller.onDeclinePressed,
                  btnText: 'shipping_decline'.tr,
                  btnColor: AppPalette.defaultFill,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  onTap: controller.onAcceptPressed,
                  btnText: 'shipping_accept'.tr,
                  textColor: AppPalette.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddressFormDialog extends StatelessWidget {
  final ShippingAddress? initial;

  const AddressFormDialog({super.key, this.initial});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressFormController>(
      init: AddressFormController(initial: initial),
      global: false,
      builder: (formCtrl) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
          backgroundColor: AppPalette.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius.r),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // --------- Top row: icon + title + set default + close ----------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: AppPalette.primary,
                      size: 25.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'shipping_address_form_title'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.textStyle.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20.sp,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),
                18.h.verticalSpace,
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    onTap: formCtrl.toggleDefault,
                    btnText: 'shipping_address_form_set_default'.tr,
                    borderRadius: 99.r,
                    btnColor: AppPalette.greyFill,
                    showBorder: false,
                    textStyle: AppTheme.textStyle.copyWith(
                      fontSize: 10.sp,
                      color: AppPalette.black,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // --------- Give a name ----------
                CustomTextFormField(
                  title: 'shipping_address_form_give_name_label'.tr,
                  hintText: 'shipping_address_form_give_name_hint'.tr,
                  controller: formCtrl.nameCtrl,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                ),
                SizedBox(height: 18.h),

                // --------- Thana ----------
                Obx(() {
                  return CustomDropDownMenu(
                    title: 'shipping_address_form_thana_label'.tr,
                    hintText: 'shipping_address_form_thana_hint'.tr,
                    options: formCtrl.thanaKeys,
                    value: formCtrl.selectedThanaKey.value,
                    onChanged: formCtrl.setThana,
                  );
                }),

                SizedBox(height: 18.h),

                // --------- Zilla ----------
                Obx(() {
                  return CustomDropDownMenu(
                    title: 'shipping_address_form_zilla_label'.tr,
                    hintText: 'shipping_address_form_zilla_hint'.tr,
                    options: formCtrl.zillaKeys,
                    value: formCtrl.selectedZillaKey.value,
                    onChanged: formCtrl.setZilla,
                  );
                }),
                SizedBox(height: 18.h),

                // --------- Full address ----------
                CustomTextFormField(
                  title: 'shipping_address_form_full_label'.tr,
                  hintText: 'shipping_address_form_full_hint'.tr,
                  controller: formCtrl.fullAddressCtrl,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 24.h),

                // --------- Save button ----------
                Center(
                  child: CustomButton(
                    onTap: formCtrl.save,
                    btnText: 'shipping_address_form_save'.tr,
                    textColor: AppPalette.white,
                    width: 168.w,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
