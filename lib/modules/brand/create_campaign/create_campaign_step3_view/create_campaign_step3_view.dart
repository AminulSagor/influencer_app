// lib/modules/brand/create_campaign/create_campaign_step3_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/app_assets.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step3_view/widgets/dos_dont_section.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step3_view/widgets/multiline_box.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step3_view/widgets/select_like_field.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step3_view/widgets/single_line_box.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step3_view/widgets/terms_section.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step3_view/widgets/title_header_icons.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../create_campaign_controller/create_campaign_controller.dart';

class CreateCampaignStep3View extends GetView<CreateCampaignController> {
  const CreateCampaignStep3View({super.key});

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
                    Obx(() => _progressSection()),

                    18.h.verticalSpace,

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'create_campaign_step3_title'.tr, // "Campaign Details"
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.primary,
                            ),
                          ),
                        ),
                        12.w.horizontalSpace,
                        CustomButton(
                          height: 34.h,
                          width: 132.w,
                          borderRadius: 999,
                          btnColor: AppPalette.secondary,
                          borderColor: Colors.transparent,
                          showBorder: false,
                          textColor: AppPalette.white,
                          btnText: 'create_campaign_save_draft'.tr,
                          onTap: controller.saveAsDraft,
                        ),
                      ],
                    ),

                    5.h.verticalSpace,

                    Text(
                      'create_campaign_step3_subtitle'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color: AppPalette.black,
                      ),
                    ),

                    18.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_goals_label'.tr,
                      icon: AppAssets.campaignGoals,
                      textColor: AppPalette.primary,
                    ),

                    6.h.verticalSpace,

                    MultilineBox(
                      controller: controller.campaignGoalsCtrl,
                      hint: 'create_campaign_goals_hint'.tr,
                      onChanged: controller.onCampaignGoalsChanged,
                    ),

                    14.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_product_service_label'.tr,
                      icon: AppAssets.campaignGoals,
                      textColor: AppPalette.primary,
                    ),

                    6.h.verticalSpace,

                    MultilineBox(
                      controller: controller.productServiceCtrl,
                      hint: 'create_campaign_product_service_hint'.tr,
                      onChanged: controller.onProductServiceChanged,
                    ),

                    15.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'campaign_dos_donts'.tr,
                      icon: AppAssets.checkMark,
                      extraIcon: AppAssets.cancelOutline,
                      textColor: AppPalette.primary,
                    ),

                    6.h.verticalSpace,

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kBorderRadius.r),
                        color: AppPalette.white,
                      ),
                      child: DosDontSection(controller: controller),
                    ),

                    17.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_terms_label'.tr,
                      icon: AppAssets.termsCondition,
                      textColor: AppPalette.primary,
                    ),

                    6.h.verticalSpace,

                    TermsSection(controller: controller),

                    21.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_start_date_label'.tr,
                      icon: AppAssets.clock,
                      textColor: AppPalette.complemetary,
                    ),

                    6.h.verticalSpace,

                    Obx(() {
                      final text = controller.startDateText;
                      final isPlaceholder = controller.startDate.value == null;
                      return SelectLikeField(
                        text: text,
                        isPlaceholder: isPlaceholder,
                        trailing: Icons.calendar_month_rounded,
                        onTap: controller.pickStartDate,
                      );
                    }),

                    18.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_duration_label'.tr,
                      icon: AppAssets.clock,
                      textColor: AppPalette.complemetary,
                    ),

                    6.h.verticalSpace,

                    SingleLineBox(
                      controller: controller.durationCtrl,
                      hint: 'create_campaign_duration_hint'.tr,
                      keyboardType: TextInputType.text,
                      onChanged: controller.onDurationChanged,
                    ),

                    24.h.verticalSpace,
                  ],
                ),
              ),
            ),
          ),

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