import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_drop_down_menu.dart';

import '../../../core/widgets/custom_text_form_field.dart';
import 'profile_controller.dart';
import 'widgets/brand_assets_section.dart';
import 'widgets/brand_contact_info_card.dart';
import 'widgets/expandable_selection_card.dart';
import 'widgets/locations_section_card.dart';
import 'widgets/payout_settings_section.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_settings_section.dart';
import 'widgets/skills_section_card.dart';
import 'widgets/verification_inprogress_section.dart';
import 'widgets/verification_section.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isBrand = accountTypeService.isBrand;
    final isInfluencer = accountTypeService.isInfluencer;
    final isAdAgency = accountTypeService.isAdAgency;

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              ProfileHeaderCard(controller: controller),
              SizedBox(height: 12.h),
              if (!isBrand) _ProfileCompletionCard(controller: controller),
              SizedBox(height: 16.h),
              if (isBrand) ...[
                BrandContactInfoCard(
                  email:
                      'salman_khan@email.com', // replace with your real value
                  phone: '+8801234567890',
                  website: 'styleco.com',
                ),
                SizedBox(height: 16.h),
              ],

              Container(
                padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kBorderRadius.r),
                  border: Border.all(
                    color: AppPalette.border1,
                    width: kBorderWidth0_5,
                  ),
                ),
                child: Column(
                  children: [
                    // BIO
                    if (!isBrand) ...[
                      Obx(
                        () => ExpandableSectionCard(
                          title: 'Bio',
                          isExpanded: controller.bioExpanded.value,
                          onToggle: controller.toggleBio,
                          child: _BioSection(controller: controller),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // SKILLS (Influencer only) -> under Bio
                    if (isInfluencer) ...[
                      SkillsSectionCard(controller: controller),
                      SizedBox(height: 12.h),
                    ],

                    // SERVICE FEE
                    if (isAdAgency) ...[
                      Obx(
                        () => ExpandableSectionCard(
                          title: 'Service Fee',
                          isExpanded: controller.serviceFeeExpanded.value,
                          onToggle: controller.toggleServiceFee,
                          child:
                              controller.profileStatus.value ==
                                  ProfileStatus.unverified
                              ? _ServiceFeeSection(controller: controller)
                              : _VerifiedServiceFeeSection(
                                  controller: controller,
                                ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // SOCIAL LINKS
                    if (!isBrand) ...[
                      Obx(
                        () => ExpandableSectionCard(
                          title: 'Social Links',
                          isExpanded: controller.socialExpanded.value,
                          onToggle: controller.toggleSocial,
                          child: _SocialLinksSection(controller: controller),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // NICHE
                      Obx(
                        () => ExpandableSectionCard(
                          title: 'Niche',
                          isExpanded: controller.nicheExpanded.value,
                          onToggle: controller.toggleNiche,
                          child: _NicheSection(controller: controller),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // PROFILE SETTINGS
                    Obx(
                      () => ExpandableSectionCard(
                        title: 'Profile Settings',
                        isExpanded: controller.settingsExpanded.value,
                        onToggle: controller.toggleSettings,
                        child: ProfileSettingsSection(controller: controller),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    if (isBrand) ...[
                      const BrandAssetsSection(),
                      SizedBox(height: 12.h),
                    ],

                    // VERIFICATION METHODS
                    Obx(
                      () => ExpandableSectionCard(
                        title: 'Verification Methods',
                        titleColor: AppPalette.complemetary,
                        isExpanded: controller.verificationExpanded.value,
                        onToggle: controller.toggleVerification,
                        child:
                            controller.profileStatus.value ==
                                ProfileStatus.unverified
                            ? VerificationSection(controller: controller)
                            : VerificationInprogressSection(
                                controller: controller,
                              ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // LOCATIONS
                    if (isInfluencer) ...[
                      LocationsSectionCard(controller: controller),
                      SizedBox(height: 12.h),
                    ],

                    // PAYOUT SETTINGS
                    if (!isBrand)
                      Obx(
                        () => ExpandableSectionCard(
                          title: 'Payout Settings',
                          isExpanded: controller.payoutExpanded.value,
                          onToggle: controller.togglePayout,
                          child: PayoutSettingsSection(controller: controller),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final ProfileController controller;

  const _ProfileCompletionCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final percent = controller.profileCompletion.value.clamp(0.0, 1.0);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppPalette.primary,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Profile Completion',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6.h,
                backgroundColor: AppPalette.secondary.withAlpha(80),
                color: AppPalette.secondary,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BioSection extends StatelessWidget {
  final ProfileController controller;

  const _BioSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomTextFormField(
        hintText: 'Write a short bio that describes you & your content.',
        initialValue: controller.bioText.value,
        maxLines: 4,
        onChanged: (value) => controller.bioText.value = value,
      ),
    );
  }
}

class _ServiceFeeSection extends StatelessWidget {
  final ProfileController controller;

  const _ServiceFeeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Enter you Rate for each campaign spend',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.secondary,
          ),
        ),
        5.h.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Obx(
            () => CustomTextFormField(
              initialValue: controller.serviceFeeText.value,
              hintText: 'eg: 10%',
              onChanged: (value) => controller.serviceFeeText.value = value,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 62.w),
          child: CustomButton(
            onTap: () {},
            btnText: 'Save',
            textColor: AppPalette.white,
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}

class _VerifiedServiceFeeSection extends StatelessWidget {
  final ProfileController controller;

  const _VerifiedServiceFeeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'My Service fee',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.secondary,
          ),
        ),
        8.h.verticalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 42.w, vertical: 17.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            color: AppPalette.thirdColor,
          ),
          child: Text(
            controller.serviceFeeText.value,
            style: TextStyle(
              fontSize: 18.sp,
              color: AppPalette.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class _SocialLinksSection extends StatelessWidget {
  final ProfileController controller;

  const _SocialLinksSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          ...controller.socialAccounts.map((account) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Image.asset(
                    account.iconPath,
                    width: 21.w,
                    height: 21.w,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomTextFormField(
                      hintText: '@instragram',
                      initialValue: account.handle,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 4.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    account.isVerified
                        ? Icons.check_circle
                        : Icons.access_time_filled,
                    size: 16.sp,
                    color: account.isVerified
                        ? AppPalette.primary
                        : AppPalette.complemetary,
                  ),
                  SizedBox(width: 8.w),
                  Image.asset(
                    'assets/icons/edit.png',
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            );
          }).toList(),
          10.h.verticalSpace,
          CustomButton.dotted(
            borderRadius: 5.r,
            onTap: () {},
            btnText: '+ Add Another Social Link',
            btnColor: AppPalette.white,
            textColor: AppPalette.primary,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _NicheSection extends StatelessWidget {
  final ProfileController controller;

  const _NicheSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 5.w,
        children: [
          ...controller.niches.map(
            (n) => Chip(
              label: Row(
                mainAxisSize: .min,
                children: [
                  Text(
                    n,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.primary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  4.w.horizontalSpace,
                  Icon(
                    Icons.check_circle,
                    size: 12.sp,
                    color: AppPalette.primary,
                  ),
                ],
              ),
              backgroundColor: AppPalette.thirdColor,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: CustomButton.dotted(
              borderRadius: 99.r,
              onTap: () {},
              btnText: '+ Add Another Social Link',
              btnColor: AppPalette.white,
              textColor: AppPalette.primary,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
