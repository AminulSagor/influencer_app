// lib/modules/brand/create_campaign/create_campaign_step3_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/app_assets.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_button.dart';
import 'create_campaign_controller.dart';

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
                    ),

                    6.h.verticalSpace,

                    _MultilineBox(
                      controller: controller.campaignGoalsCtrl,
                      hint: 'create_campaign_goals_hint'.tr,
                      onChanged: controller.onCampaignGoalsChanged,
                    ),

                    14.h.verticalSpace,

                    TitleHeaderIcons(text: 'create_campaign_product_service_label'.tr, icon: AppAssets.campaignGoals),

                    6.h.verticalSpace,

                    _MultilineBox(
                      controller: controller.productServiceCtrl,
                      hint: 'create_campaign_product_service_hint'.tr,
                      onChanged: controller.onProductServiceChanged,
                    ),

                    15.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'campaign_dos_donts'.tr,
                      icon: AppAssets.checkMark,
                      extraIcon: AppAssets.cancelOutline,
                    ),

                    6.h.verticalSpace,

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kBorderRadius.r),
                        color: AppPalette.white,
                      ),
                      child: _DosDontSection(controller: controller),
                    ),

                    17.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_terms_label'.tr,
                      icon: AppAssets.termsCondition,
                    ),

                    6.h.verticalSpace,

                    _TermsSection(controller: controller),

                    21.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_start_date_label'.tr,
                      icon: AppAssets.clock,
                    ),

                    6.h.verticalSpace,

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

                    18.h.verticalSpace,

                    TitleHeaderIcons(
                      text: 'create_campaign_duration_label'.tr,
                      icon: AppAssets.clock,
                    ),

                    6.h.verticalSpace,

                    _SingleLineBox(
                      controller: controller.durationCtrl,
                      hint: 'create_campaign_duration_hint'.tr, // "5 Days"
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: iconColor ?? AppPalette.primary),
        10.w.horizontalSpace,
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MultilineBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final void Function(String) onChanged;

  const _MultilineBox({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 4,
        style: TextStyle(fontSize: 12.sp, color: AppPalette.greyText, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12.sp, color: AppPalette.subtext, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

class _SingleLineBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final void Function(String) onChanged;

  const _SingleLineBox({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 12.sp, color: AppPalette.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12.sp, color: AppPalette.subtext),
        ),
      ),
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
            Icon(trailing, size: 20.sp, color: AppPalette.black),
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
    return Column(
      children: [
        _GuidelineCard(
          title: 'create_campaign_dos_label'.tr,
          icon: AppAssets.checkMark,
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
          icon: AppAssets.cancelOutline,
          tint: const Color(0xFFFFF0F0),
          border: const Color(0xFFFFC5C5),
          titleColor: const Color(0xFFB32020),
          controller: controller.dontsCtrl,
          onChanged: controller.onDontsChanged,
          exampleHint: 'create_campaign_donts_hint'.tr,
        ),
      ],
    );
  }
}

class _GuidelineCard extends StatelessWidget {
  final String title;
  final String icon;
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
              Image.asset(icon, height: 18.sp,width: 18.sp, color: titleColor),
              // Icon(icon, size: 18.sp, color: titleColor),
              10.w.horizontalSpace,

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),

          12.h.verticalSpace,

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
                    hintText: exampleHint, // multi-line bullet hint
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 19, vertical: 22),
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
            spacing: 10,
            children: [
              
              Image.asset(AppAssets.presentation, height: 20, width: 20,color: AppPalette.primary),

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

          _MultilineBox(
            controller: controller.reportingReqCtrl,
            hint: 'create_campaign_reporting_requirements_hint'.tr,
            onChanged: controller.onReportingReqChanged,
          ),

          14.h.verticalSpace,

          Row(
            spacing: 10,
            children: [
              Image.asset(AppAssets.copyright, height: 20, width: 20,color: AppPalette.primary),

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

          6.h.verticalSpace,

          _MultilineBox(
            controller: controller.usageRightsCtrl,
            hint: 'create_campaign_usage_rights_hint'.tr,
            onChanged: controller.onUsageRightsChanged,
          ),
        ],
      ),
    );
  }
}

class TitleHeaderIcons extends StatelessWidget {
  final String text;
  final String icon;
  final String? extraIcon;

  const TitleHeaderIcons({
    super.key,
    required this.text,
    required this.icon,
    this.extraIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Image.asset(
          icon,
          height: 20,
          width: 20,
          color: AppPalette.primary,
        ),

        if (extraIcon != null && extraIcon!.isNotEmpty) ...[
          Image.asset(
            extraIcon!,
            height: 20,
            width: 20,
            color: AppPalette.primary,
          ),
        ],

        Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),
      ],
    );
  }
}