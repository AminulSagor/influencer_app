import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return Obx(() {
      final pageIndex = controller.verificationPageIndex.value;

      return PopScope(
        canPop: pageIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && pageIndex == 1) {
            controller.showProfilePage();
          }
        },
        child: Scaffold(
          backgroundColor: AppPalette.background,
          body: SafeArea(
            child: IndexedStack(
              index: pageIndex,
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      ProfileHeaderCard(
                        controller: controller,
                        onStatusTap: controller.showVerificationPage,
                      ),
                      SizedBox(height: 12.h),
                      if (!isBrand)
                        _ProfileCompletionCard(controller: controller),
                      SizedBox(height: 16.h),
                      if (isBrand) ...[
                        Obx(
                          () => BrandContactInfoCard(
                            email: controller.userEmail.value,
                            phone: controller.userPhone.value,
                            website: controller.brandWebsite.value,
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 17.w,
                          vertical: 20.h,
                        ),
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
                                  isExpanded:
                                      controller.serviceFeeExpanded.value,
                                  onToggle: controller.toggleServiceFee,
                                  child:
                                      controller.profileStatus.value ==
                                          ProfileStatus.unverified
                                      ? _ServiceFeeSection(
                                          controller: controller,
                                        )
                                      : _VerifiedServiceFeeSection(
                                          controller: controller,
                                        ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Obx(
                                () => ExpandableSectionCard(
                                  title: 'Dollar Rate',
                                  isExpanded:
                                      controller.dollarRateExpanded.value,
                                  onToggle: controller.toggleDollarRate,
                                  child: _DollarRateSection(
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
                                  child: _SocialLinksSection(
                                    controller: controller,
                                  ),
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
                                child: ProfileSettingsSection(
                                  controller: controller,
                                ),
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
                                isExpanded:
                                    controller.verificationExpanded.value,
                                onToggle: controller.toggleVerification,
                                child:
                                    controller.profileStatus.value ==
                                        ProfileStatus.unverified
                                    ? VerificationSection(
                                        controller: controller,
                                      )
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
                                  child: PayoutSettingsSection(
                                    controller: controller,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      if (isInfluencer || isAdAgency)
                        Obx(
                          () => CustomButton(
                            onTap: controller.isSavingProfile.value
                                ? null
                                : controller.onSaveVerificationMethods,
                            btnText: 'Save Update',
                            height: 56.h,
                            width: double.infinity,
                            textColor: AppPalette.white,
                            isLoading: controller.isSavingProfile.value,
                          ),
                        ),
                    ],
                  ),
                ),
                _VerificationFlowPage(controller: controller),
              ],
            ),
          ),
        ),
      );
    });
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
    return CustomTextFormField(
      hintText: 'Write a short bio that describes you & your content.',
      controller: controller.bioController,
      maxLines: 4,
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
          child: Obx(
            () => CustomButton(
              onTap: controller.isSavingServiceFee.value
                  ? null
                  : controller.saveAgencyServiceFee,
              btnText: 'Save',
              textColor: AppPalette.white,
              width: double.infinity,
              isLoading: controller.isSavingServiceFee.value,
            ),
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

class _DollarRateSection extends StatelessWidget {
  final ProfileController controller;

  const _DollarRateSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Enter dollar rate per campaign spend',
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
              initialValue: controller.dollarRateText.value,
              hintText: 'eg: 124.57',
              onChanged: (value) => controller.dollarRateText.value = value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
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
          child: Obx(
            () => CustomButton(
              onTap: controller.isSavingDollarRate.value
                  ? null
                  : controller.saveAgencyDollarRate,
              btnText: 'Save',
              textColor: AppPalette.white,
              width: double.infinity,
              isLoading: controller.isSavingDollarRate.value,
            ),
          ),
        ),
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
                    color: AppPalette.black,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.link, size: 21.w, color: AppPalette.subtext),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomTextFormField(
                      hintText: '@instragram',
                      initialValue: controller.socialHandleValue(
                        account.platform,
                        account.handle,
                      ),
                      onChanged: (value) =>
                          controller.setSocialHandle(account.platform, value),
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
            onTap: controller.showAddSocialDialog,
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
          ...controller.niches.map((n) {
            final isVerified = controller.isNicheVerified(n);
            return Chip(
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
                    isVerified ? Icons.check_circle : Icons.access_time_filled,
                    size: 12.sp,
                    color: isVerified
                        ? AppPalette.primary
                        : AppPalette.complemetary,
                  ),
                ],
              ),
              backgroundColor: AppPalette.thirdColor,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            );
          }),
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: CustomButton.dotted(
              borderRadius: 99.r,
              onTap: controller.showAddNicheDialog,
              btnText: '+ Add Another Niche',
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

class _VerificationFlowPage extends StatefulWidget {
  final ProfileController controller;

  const _VerificationFlowPage({required this.controller});

  @override
  State<_VerificationFlowPage> createState() => _VerificationFlowPageState();
}

class _VerificationFlowPageState extends State<_VerificationFlowPage> {
  final ScrollController _scrollController = ScrollController();
  int _lastFlowIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetScrollToTopIfNeeded(int flowIndex) {
    if (_lastFlowIndex == flowIndex) return;
    _lastFlowIndex = flowIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  double _overallProgress() {
    if (widget.controller.verificationInprogressItems.isEmpty) return 0.0;
    final weightedCompleted = widget.controller.verificationInprogressItems
        .fold(0.0, (sum, item) {
          switch (item.state) {
            case VerificationState.verified:
              return sum + 1.0;
            case VerificationState.underReview:
              return sum + 0.5;
            case VerificationState.unverified:
              return sum;
          }
        });
    return weightedCompleted /
        widget.controller.verificationInprogressItems.length;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final flowIndex = widget.controller.verificationFlowIndex.value;
      _resetScrollToTopIfNeeded(flowIndex);

      return PopScope(
        canPop: flowIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && flowIndex > 0) {
            widget.controller.showVerificationList();
          }
        },
        child: flowIndex == 2
            ? _EmailVerifiedSuccess(controller: widget.controller) // STATIC
            : SingleChildScrollView(
                key: ValueKey('verification-flow-$flowIndex'),
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (flowIndex == 0) ...[
                      SizedBox(height: 10.h),
                      ProfileHeaderCard(
                        controller: widget.controller,
                        onStatusTap: widget.controller.showProfilePage,
                      ),
                      SizedBox(height: 16.h),
                    ] else
                      SizedBox(height: 10.h),

                    IndexedStack(
                      index: flowIndex,
                      children: [
                        _VerificationProgressList(
                          controller: widget.controller,
                          overallProgress: _overallProgress(),
                        ),
                        _EmailVerificationStep(controller: widget.controller),
                        const SizedBox(), // placeholder for index 2
                      ],
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

class _VerificationProgressList extends StatelessWidget {
  final ProfileController controller;
  final double overallProgress;

  const _VerificationProgressList({
    required this.controller,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isBrand = accountTypeService.isBrand;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isBrand) ...[
            Obx(
              () => BrandContactInfoCard(
                email: controller.userEmail.value,
                phone: controller.userPhone.value,
                website: controller.brandWebsite.value,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                    Icon(
                      Icons.check_circle,
                      color: AppPalette.primary,
                      size: 23.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Verification Progress',
                      style: TextStyle(
                        color: AppPalette.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 9.h,
                    backgroundColor: AppPalette.secondary.withAlpha(120),
                    color: AppPalette.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ...controller.verificationInprogressItems.map(
            (item) => _VerificationItemCard(
              title: item.title,
              status: controller.verificationLabel(item.state),
              statusColor: controller.verificationColor(item.state),
              onTap: item.title == 'Email'
                  ? controller.startEmailVerification
                  : null,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppPalette.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppPalette.secondary.withOpacity(0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: AppPalette.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info, color: AppPalette.white, size: 14.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification In Progress',
                        style: TextStyle(
                          color: AppPalette.secondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'We’ll notify you once all items are verified',
                        style: TextStyle(
                          color: AppPalette.secondary,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
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

class _VerificationItemCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const _VerificationItemCard({
    required this.title,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5.w,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppPalette.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppPalette.subtext,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailVerificationStep extends StatefulWidget {
  final ProfileController controller;

  const _EmailVerificationStep({required this.controller});

  @override
  State<_EmailVerificationStep> createState() => _EmailVerificationStepState();
}

class _EmailVerificationStepState extends State<_EmailVerificationStep> {
  final _controllers = List.generate(
    4,
    (_) => TextEditingController(),
    growable: false,
  );
  final _focusNodes = List.generate(4, (_) => FocusNode(), growable: false);

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleChanged(int index, String value) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  bool _isOtpComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  Widget _buildOtpBox(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 74.w,
      height: 80.h,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        autofocus: false,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: AppPalette.primary,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: const Color(0xFFCDD5DF), width: 2.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppPalette.primary, width: 2.w),
          ),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _handleChanged(index, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: widget.controller.showVerificationList,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: AppPalette.primary,
              ),
            ),
          ),
          SizedBox(height: 80.h),
          Text(
            'Verify Your Email',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Text(
              'We send a code to \n ${widget.controller.userEmail.value}',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            height: 80.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => _buildOtpBox(index)),
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: Obx(() {
              final isLoading =
                  widget.controller.isResendingEmailOtp.value ||
                  widget.controller.isRequestingEmailOtp.value;
              return GestureDetector(
                onTap: isLoading ? null : widget.controller.resendEmailOtp,
                child: Text(
                  isLoading
                      ? 'Resending...'
                      : 'Didn’t receive the code? Resend',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 40.h),
          Obx(() {
            final isVerifying = widget.controller.isVerifyingEmailOtp.value;
            return CustomButton(
              onTap: isVerifying
                  ? null
                  : () {
                      final code = _controllers.map((c) => c.text).join();
                      widget.controller.verifyEmailOtp(code);
                    },
              btnText: isVerifying ? 'Verifying...' : 'Continue',
              width: double.infinity,
              height: 56.h,
              isDisabled: !_isOtpComplete() || isVerifying,
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmailVerifiedSuccess extends StatelessWidget {
  final ProfileController controller;

  const _EmailVerifiedSuccess({required this.controller});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // This is the same padding you use in _VerificationFlowPage
    const horizontalPadding = 20.0;
    const verticalPaddingTop = 12.0;
    const verticalPaddingBottom = 24.0;

    return SizedBox(
      height:
          h -
          topInset -
          bottomInset -
          verticalPaddingTop -
          verticalPaddingBottom,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppPalette.primary,
                    size: 30.sp,
                  ),
                  Text(
                    ' All set!',
                    style: TextStyle(
                      color: AppPalette.primary,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Your email is verified now!',
                style: TextStyle(color: AppPalette.black, fontSize: 15.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                onTap: () {
                  controller.resetVerificationFlow();
                  controller.showProfilePage();
                },
                btnText: 'Go to Profile',
                btnColor: AppPalette.primary,
                textColor: AppPalette.white,
                height: 52.h,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
