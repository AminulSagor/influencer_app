import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import 'create_campaign_controller.dart';
import 'widgets/top_progress_section.dart';

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
                    Obx(
                      () => TopProgressSection(
                        onPrevious: controller.onPrevious,
                        stepText: controller.stepText,
                        progressPercentText: controller.progressPercentText,
                        progress: controller.progress,
                      ),
                    ),

                    18.h.verticalSpace,

                    Text(
                      'create_campaign_step3_title'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    6.h.verticalSpace,
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

                    _SectionTitle(
                      iconPath: 'assets/icons/goal.png',
                      iconColor: AppPalette.primary,
                      title: 'create_campaign_goals_label'.tr,
                    ),
                    10.h.verticalSpace,
                    CustomTextFormField(
                      controller: controller.campaignGoalsCtrl,
                      hintText: 'create_campaign_goals_hint'.tr,
                      onChanged: controller.onCampaignGoalsChanged,
                      maxLines: 4,
                      fillColor: AppPalette.white,
                    ),

                    16.h.verticalSpace,

                    _SectionTitle(
                      iconPath: 'assets/icons/goal.png',
                      iconColor: AppPalette.primary,
                      title: 'create_campaign_product_service_label'.tr,
                    ),
                    10.h.verticalSpace,
                    CustomTextFormField(
                      controller: controller.productServiceCtrl,
                      hintText: 'create_campaign_product_service_hint'.tr,
                      onChanged: controller.onProductServiceChanged,
                      maxLines: 4,
                      fillColor: AppPalette.white,
                    ),

                    16.h.verticalSpace,

                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 17.sp,
                          color: AppPalette.primary,
                        ),
                        Icon(
                          Icons.cancel_outlined,
                          size: 17.sp,
                          color: AppPalette.color2text,
                        ),
                        10.w.horizontalSpace,
                        Expanded(
                          child: Text(
                            'create_campaign_dos_donts_label'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppPalette.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.h.verticalSpace,

                    _DosDontSection(controller: controller),

                    16.h.verticalSpace,

                    _TermsSection(controller: controller),

                    18.h.verticalSpace,

                    _SectionTitle(
                      title: 'create_campaign_start_date_label'.tr,
                      titleColor: AppPalette.complemetary,
                      icon: Image.asset(
                        'assets/icons/clock.png',
                        width: 12.w,
                        color: AppPalette.complemetary,
                      ),
                    ),
                    10.h.verticalSpace,
                    Obx(() {
                      final text = controller.startDateText;
                      final isPlaceholder = controller.startDate.value == null;
                      return _SelectLikeField(
                        text: text,
                        isPlaceholder: isPlaceholder,
                        trailing: Icons.calendar_month_rounded,
                        onTap: controller.pickStartDate,
                      );
                    }),

                    16.h.verticalSpace,

                    _SectionTitle(
                      title: 'create_campaign_duration_label'.tr,
                      titleColor: AppPalette.complemetary,
                      icon: Image.asset(
                        'assets/icons/clock.png',
                        width: 12.w,
                        color: AppPalette.complemetary,
                      ),
                    ),
                    10.h.verticalSpace,
                    CustomTextFormField(
                      controller: controller.durationCtrl,
                      hintText: 'create_campaign_duration_hint'.tr,
                      keyboardType: TextInputType.text,
                      onChanged: controller.onDurationChanged,
                      fillColor: AppPalette.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 17.w,
                        vertical: 11.h,
                      ),
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

class _SectionTitle extends StatelessWidget {
  final Widget? icon;
  final String? iconPath;
  final Color? iconColor;
  final String title;
  final Color? titleColor;

  const _SectionTitle({
    this.iconPath,
    required this.title,
    this.iconColor,
    this.icon,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (iconPath != null)
          Image.asset(
            iconPath!,
            width: 20.w,
            fit: BoxFit.cover,
            color: iconColor,
          ),

        if (icon != null) icon!,
        10.w.horizontalSpace,
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: titleColor ?? AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectLikeField extends StatelessWidget {
  final String text;
  final bool isPlaceholder;
  final IconData trailing;
  final VoidCallback onTap;

  const _SelectLikeField({
    required this.text,
    required this.isPlaceholder,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isPlaceholder ? AppPalette.subtext : AppPalette.black,
                ),
              ),
            ),
            Icon(trailing, size: 20.sp, color: AppPalette.complemetary),
          ],
        ),
      ),
    );
  }
}

class _DosDontSection extends StatelessWidget {
  final CreateCampaignController controller;
  const _DosDontSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.5.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          _GuidelineCard(
            title: 'create_campaign_dos_label'.tr,
            icon: Icons.check_circle_outline,
            tint: const Color(0xFFEFFAF3),
            border: const Color(0xFFBFE9CB),
            titleColor: const Color(0xFF1B7F3A),
            controller: controller.dosCtrl,
            onChanged: controller.onDosChanged,
            exampleHint: 'create_campaign_dos_hint'.tr,
          ),
          12.h.verticalSpace,
          _GuidelineCard(
            title: 'create_campaign_donts_label'.tr,
            icon: Icons.cancel_outlined,
            tint: const Color(0xFFFFF0F0),
            border: const Color(0xFFFFC5C5),
            titleColor: const Color(0xFFB32020),
            controller: controller.dontsCtrl,
            onChanged: controller.onDontsChanged,
            exampleHint: 'create_campaign_donts_hint'.tr,
          ),
        ],
      ),
    );
  }
}

class _GuidelineCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color tint;
  final Color border;
  final Color titleColor;

  final TextEditingController controller;
  final void Function(String) onChanged;
  final String exampleHint;

  const _GuidelineCard({
    required this.title,
    required this.icon,
    required this.tint,
    required this.border,
    required this.titleColor,
    required this.controller,
    required this.onChanged,
    required this.exampleHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header like screenshot (icon + title)
          Row(
            children: [
              Icon(icon, size: 18.sp, color: titleColor),
              3.w.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),

          8.h.verticalSpace,

          // Inner bordered field box
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(color: border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  onChanged: onChanged,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: titleColor.withOpacity(.78),
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: exampleHint,
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: titleColor.withOpacity(.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final CreateCampaignController controller;
  const _TermsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          iconPath: 'assets/icons/terms_condition.png',
          title: 'create_campaign_terms_label'.tr,
          iconColor: AppPalette.primary,
        ),
        10.h.verticalSpace,
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(kBorderRadius.r),
            border: Border.all(
              color: AppPalette.border1,
              width: kBorderWidth0_5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/presentation.png',
                    width: 16.w,
                    color: AppPalette.primary,
                  ),
                  10.w.horizontalSpace,
                  Text(
                    'create_campaign_reporting_requirements_label'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
              10.h.verticalSpace,
              CustomTextFormField(
                controller: controller.reportingReqCtrl,
                hintText: 'create_campaign_reporting_requirements_hint'.tr,
                onChanged: controller.onReportingReqChanged,
                maxLines: 4,
              ),
              14.h.verticalSpace,
              Row(
                children: [
                  Image.asset(
                    'assets/icons/copyright.png',
                    width: 16.sp,
                    color: AppPalette.primary,
                  ),
                  10.w.horizontalSpace,
                  Text(
                    'create_campaign_usage_rights_label'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
              10.h.verticalSpace,
              CustomTextFormField(
                controller: controller.usageRightsCtrl,
                hintText: 'create_campaign_usage_rights_hint'.tr,
                onChanged: controller.onUsageRightsChanged,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
