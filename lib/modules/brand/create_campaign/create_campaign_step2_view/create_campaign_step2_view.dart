// lib/modules/brand/create_campaign/create_campaign_step2_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step2_view/widgets/input_names_widget.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step2_view/widgets/paidAd_step2.dart';
import 'package:influencer_app/modules/brand/create_campaign/create_campaign_step2_view/widgets/select_field.dart';

import '../../../../core/models/job_item.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../create_campaign_controller/create_campaign_controller.dart';
import 'widgets/empty_state.dart';

class CreateCampaignStep2View extends GetView<CreateCampaignController> {
  const CreateCampaignStep2View({super.key});

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
                    /// ✅ Progress reads Rx -> MUST be inside Obx
                    Obx(() => _progressSectionWithBack()),

                    18.h.verticalSpace,

                    /// Title + Save as draft (no Rx needed)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'create_campaign_step2_title'.tr,
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
                      'create_campaign_step2_subtitle'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color: AppPalette.black,
                      ),
                    ),

                    20.h.verticalSpace,

                    /// ✅ Body switches by type -> Obx required
                    Obx(() {
                      final type = controller.selectedType.value;

                      if (type == null) {
                        return EmptyState(onBack: controller.onPrevious);
                      }

                      if (type == CampaignType.influencerPromotion) {
                        return _InfluencerPromotionStep2(
                          controller: controller,
                        );
                      }

                      return PaidAdStep2(controller: controller);
                    }),

                    24.h.verticalSpace,

                  ],
                ),
              ),
            ),
          ),

          /// ✅ Bottom buttons depend on Rx -> Obx required
          Obx(() => _bottomButtons()),
        ],
      ),
    );
  }

  Widget _progressSectionWithBack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(999.r),
              onTap: controller.onPrevious,
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: AppPalette.black,
                ),
              ),
            ),
            6.w.horizontalSpace,
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

class _InfluencerPromotionStep2 extends StatelessWidget {
  final CreateCampaignController controller;

  const _InfluencerPromotionStep2({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Product type
        Text(
          'create_campaign_product_type_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,
        Obx(() {
          final value = controller.selectedProductType.value; // ✅ reads Rx
          return SelectField(
            text: value ?? 'create_campaign_product_type_hint'.tr,
            isPlaceholder: value == null,
            onTap: controller.openProductTypePicker,
          );
        }),

        18.h.verticalSpace,

        /// Niche (multi)
        Text(
          'create_campaign_niche_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
        10.h.verticalSpace,
        Obx(() {
          final selected = controller.selectedNiches.toList(); // ✅ IMPORTANT
          final text = selected.isEmpty
              ? 'create_campaign_niche_hint'.tr
              : selected.join(', ');
          return SelectField(
            text: text,
            isPlaceholder: selected.isEmpty,
            onTap: controller.openNichePicker,
          );
        }),

        18.h.verticalSpace,

        InputNamesWidget(
          title: 'create_campaign_preferred_influencers_label'.tr,
          subTitle: 'create_campaign_preferred_influencers_hint'.tr,
          textController: controller.influencersInputController,
          names: controller.preferredInputInfluencers,
          onSubmitted: controller.addPreferredInfluencers,
          onDeleted: controller.removePreferredInfluencer,
        ),

        18.h.verticalSpace,

        InputNamesWidget(
          title: 'create_campaign_not_preferred_influencers_label'.tr,
          subTitle: 'create_campaign_preferred_influencers_hint'.tr,
          textController: controller.influencersNotInputController,
          names: controller.preferredExcludedInfluencers,
          onSubmitted: controller.addExcludedInfluencers,
          onDeleted: controller.removeExcludedInfluencer,
        ),

        // /// Preferred influencers
        // Text(
        //   'create_campaign_preferred_influencers_label'.tr,
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        //   style: TextStyle(
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w600,
        //     color: AppPalette.primary,
        //   ),
        // ),
        // 10.h.verticalSpace,
        // CustomTextFormField(
        //   hintText: 'create_campaign_preferred_influencers_hint'.tr,
        //   controller: controller.preferredInputCtrl,
        //   textInputAction: TextInputAction.done,
        //   suffixIcon: IconButton(
        //     icon: Icon(
        //       Icons.add_circle_outline,
        //       size: 20.sp,
        //       color: AppPalette.primary,
        //     ),
        //     onPressed: controller.commitPreferredInput,
        //   ),
        //   onChanged: controller.onPreferredTyping,
        // ),
        // 12.h.verticalSpace,
        // Obx(() {
        //   final items = controller.preferredInfluencers.toList(); // ✅ IMPORTANT
        //   return _ChipBox(items: items, onRemove: controller.removePreferred);
        // }),
        //
        // 18.h.verticalSpace,

        /// Not preferred influencers
        // Text(
        //   'create_campaign_not_preferred_influencers_label'.tr,
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        //   style: TextStyle(
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w600,
        //     color: AppPalette.primary,
        //   ),
        // ),
        // 10.h.verticalSpace,
        // CustomTextFormField(
        //   hintText: 'create_campaign_not_preferred_influencers_hint'.tr,
        //   controller: controller.notPreferredInputCtrl,
        //   textInputAction: TextInputAction.done,
        //   suffixIcon: IconButton(
        //     icon: Icon(
        //       Icons.add_circle_outline,
        //       size: 20.sp,
        //       color: AppPalette.primary,
        //     ),
        //     onPressed: controller.commitNotPreferredInput,
        //   ),
        //   onChanged: controller.onNotPreferredTyping,
        // ),
        // 12.h.verticalSpace,
        // Obx(() {
        //   final items = controller.notPreferredInfluencers
        //       .toList(); // ✅ IMPORTANT
        //   return _ChipBox(
        //     items: items,
        //     onRemove: controller.removeNotPreferred,
        //   );
        // }),
      ],
    );
  }
}

