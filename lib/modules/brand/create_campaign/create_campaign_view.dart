import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/job_item.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import 'create_campaign_controller/create_campaign_controller.dart';

class CreateCampaignView extends GetView<CreateCampaignController> {
  const CreateCampaignView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.background,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// progress depends on Rx -> wrap in Obx
                    Obx(() => _progressSection()),

                    14.h.verticalSpace,

                    Text(
                      'create_campaign_get_started_title'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),

                    5.h.verticalSpace,

                    Text(
                      'create_campaign_get_started_subtitle'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color: AppPalette.black,
                      ),
                    ),

                    20.h.verticalSpace,

                    CustomTextFormField(
                      title: 'create_campaign_name_label'.tr,
                      titleTextStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                      hintText: 'create_campaign_name_hint'.tr,
                      textStyle: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.greyText,
                      ),
                      controller: controller.campaignNameCtrl,
                      textInputAction: TextInputAction.next,
                      onChanged: controller.onCampaignNameChanged,
                    ),

                    17.h.verticalSpace,

                    Text(
                      'create_campaign_type_label'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),

                    11.h.verticalSpace,

                    /// both cards depend on selectedType Rx -> wrap once
                    Obx(() {
                      final selected = controller.selectedType.value;
                      return Column(
                        children: [
                          _typeCard(
                            isSelected: selected == CampaignType.paidAd,
                            type: CampaignType.paidAd,
                            title: 'create_campaign_type_paid_title'.tr,
                            subtitle: 'create_campaign_type_paid_sub'.tr,
                          ),
                          12.h.verticalSpace,
                          _typeCard(
                            isSelected:
                                selected == CampaignType.influencerPromotion,
                            type: CampaignType.influencerPromotion,
                            title: 'create_campaign_type_influencer_title'.tr,
                            subtitle: 'create_campaign_type_influencer_sub'.tr,
                          ),
                        ],
                      );
                    }),

                    24.h.verticalSpace,
                  ],
                ),
              ),
            ),
          ),

          /// bottom buttons depend on Rx (campaignName + selectedType) -> Obx
          Obx(() => _bottomButtons()),
        ],
      ),
    );
  }

  Widget _progressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  controller.stepText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.black,
                  ),
                ),
              ),
            ),
            Text(
              controller.progressPercentText,
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
        10.h.verticalSpace,
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: controller.progress,
            minHeight: 10.h,
            backgroundColor: AppPalette.defaultFill,
            color: AppPalette.primary,
          ),
        ),
      ],
    );
  }

  Widget _typeCard({
    required bool isSelected,
    required CampaignType type,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.selectType(type),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(
            color: isSelected ? AppPalette.primary : AppPalette.border1,
            width: kBorderWidth0_5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: AppPalette.defaultFill,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            12.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                  3.h.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.greyText,
                    ),
                  ),
                ],
              ),
            ),
            12.w.horizontalSpace,
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppPalette.primary : AppPalette.border1,
                  width: 1.2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppPalette.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButtons() {
    final disabled = !controller.canGoNext;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        border: Border(
          top: BorderSide(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              btnText: 'common_previous'.tr,
              btnColor: AppPalette.white,
              borderColor: AppPalette.border1,
              textColor: AppPalette.black,
              onTap: controller.onPrevious,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: CustomButton(
              btnText: 'common_next'.tr,
              btnColor: disabled
                  ? AppPalette.defaultFill
                  : AppPalette.secondary,
              textColor: disabled ? AppPalette.greyText : AppPalette.white,
              borderColor: Colors.transparent,
              showBorder: false,
              isDisabled: disabled,
              onTap: controller.onNext,
            ),
          ),
        ],
      ),
    );
  }
}
