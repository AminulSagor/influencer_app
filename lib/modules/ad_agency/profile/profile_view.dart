import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_field.dart';

import '../../../core/widgets/custom_text_form_field.dart';
import 'profile_controller.dart';

const _kPrimaryGreen = Color(0xFF315719);
const _kAccentGreen = Color(0xFF7BB23B);

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              _ProfileHeaderCard(controller: controller),
              SizedBox(height: 12.h),
              _ProfileCompletionCard(controller: controller),
              SizedBox(height: 16.h),

              // BIO
              Container(
                padding: EdgeInsets.all(17.w),
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
                    Obx(
                      () => _ExpandableSectionCard(
                        title: 'Bio',
                        isExpanded: controller.bioExpanded.value,
                        onToggle: controller.toggleBio,
                        child: _BioSection(controller: controller),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // SERVICE FEE
                    Obx(
                      () => _ExpandableSectionCard(
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

                    // SOCIAL LINKS
                    Obx(
                      () => _ExpandableSectionCard(
                        title: 'Social Links',
                        isExpanded: controller.socialExpanded.value,
                        onToggle: controller.toggleSocial,
                        child: _SocialLinksSection(controller: controller),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // NICHE
                    Obx(
                      () => _ExpandableSectionCard(
                        title: 'Niche',
                        isExpanded: controller.nicheExpanded.value,
                        onToggle: controller.toggleNiche,
                        child: _NicheSection(controller: controller),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // PROFILE SETTINGS
                    Obx(
                      () => _ExpandableSectionCard(
                        title: 'Profile Settings',
                        isExpanded: controller.settingsExpanded.value,
                        onToggle: controller.toggleSettings,
                        child: _ProfileSettingsSection(controller: controller),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // VERIFICATION METHODS
                    Obx(
                      () => _ExpandableSectionCard(
                        title: 'Verification Methods',
                        titleColor: AppPalette.complemetary,
                        isExpanded: controller.verificationExpanded.value,
                        onToggle: controller.toggleVerification,
                        child:
                            controller.profileStatus.value ==
                                ProfileStatus.unverified
                            ? _VerificationSection(controller: controller)
                            : _VerificationInprogressSection(
                                controller: controller,
                              ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // PAYOUT SETTINGS
                    Obx(
                      () => _ExpandableSectionCard(
                        title: 'Payout Settings',
                        isExpanded: controller.payoutExpanded.value,
                        onToggle: controller.togglePayout,
                        child: _PayoutSettingsSection(controller: controller),
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

class _ProfileHeaderCard extends StatelessWidget {
  final ProfileController controller;

  const _ProfileHeaderCard({required this.controller});

  String _iconForPlatform(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('insta')) return 'assets/icons/instagram.png';
    if (p.contains('youtube')) return 'assets/icons/youTube.png';
    if (p.contains('tiktok')) return 'assets/icons/tikTok.png';
    return 'assets/icons/tikTok.png';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          gradient: const LinearGradient(
            colors: [AppPalette.gradient1, AppPalette.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 38.r,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 32.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 6.h),

                    _StatusChip(label: controller.profileStatusLabel),
                    SizedBox(height: 10.h),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.profileName.value,
                          style: TextStyle(
                            color: AppPalette.thirdColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Image.asset(
                          'assets/icons/unverified_account.png',
                          width: 16.w,
                          height: 16.w,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Location text
                    Text(
                      controller.profileLocation.value,
                      style: TextStyle(
                        color: AppPalette.secondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            35.w.horizontalSpace,
            Expanded(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Take first 3 socials and render like the design
                    ...controller.socialAccounts
                        .take(3)
                        .map(
                          (social) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  _iconForPlatform(social.platform),
                                  width: 20.w,
                                  height: 20.w,
                                ),

                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    social.handle,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppPalette.thirdColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    16.h.verticalSpace,
                    CustomButton(
                      onTap: () {},
                      btnText: 'Log Out',
                      btnColor: AppPalette.thirdColor,
                      textColor: AppPalette.black,
                      height: 28.h,
                      width: 164.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppPalette.thirdColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppPalette.black,
          fontSize: 8.sp,
          fontWeight: FontWeight.w400,
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

// ---------------------------------------------------------------------------
// REUSABLE EXPANDABLE CARD
// ---------------------------------------------------------------------------

class _ExpandableSectionCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandableSectionCard({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kBorderRadius.r),
              topRight: Radius.circular(kBorderRadius.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppPalette.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 28.sp,
                    color: AppPalette.black,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// INDIVIDUAL SECTIONS
// ---------------------------------------------------------------------------

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

class _ProfileSettingsSection extends StatelessWidget {
  final ProfileController controller;

  const _ProfileSettingsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  dashPattern: [5, 5],
                  radius: Radius.circular(999.r),
                  color: AppPalette.defaultStroke,
                  strokeWidth: 1,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    width: 74.w,
                    height: 74.w,
                    color: AppPalette.defaultFill,
                  ),
                ),
              ),
              20.w.horizontalSpace,
              Expanded(
                child: Column(
                  children: [
                    CustomButton(
                      onTap: () {},
                      btnText: 'Change Photo',
                      width: double.infinity,
                      textColor: AppPalette.white,
                    ),
                    10.h.verticalSpace,
                    CustomButton(
                      onTap: () {},
                      btnText: 'Remove',
                      width: double.infinity,
                      btnColor: AppPalette.defaultFill,
                      borderColor: AppPalette.defaultStroke,
                    ),
                  ],
                ),
              ),
            ],
          ),
          33.h.verticalSpace,
          ...controller.profileFields.map((field) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    field.label + (field.isRequired ? ' *' : ''),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: AppPalette.secondary,
                    ),
                  ),
                  5.h.verticalSpace,
                  CustomTextFormField(
                    hintText: field.hintText,
                    initialValue: field.value,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12.sp,
                      color: AppPalette.black,
                    ),
                    maxLines: field.label.contains('Full Address') ? 5 : 1,
                  ),
                  if (field.label.contains('Last')) ...[
                    12.h.verticalSpace,

                    /// ----- Thana -----
                    Text(
                      "Thana *",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppPalette.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    Obx(
                      () => _DropDownMenu(
                        hintText: "Select Thana",
                        value: controller.selectedThana.value,
                        options: controller.thanaList,
                        onChanged: controller.setThana,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// ----- Zilla -----
                    Text(
                      "Zilla *",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppPalette.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    Obx(
                      () => _DropDownMenu(
                        hintText: "Select Zilla",
                        value: controller.selectedZilla.value,
                        options: controller.zillaList,
                        onChanged: controller.setZilla,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _DropDownMenu extends GetView<ProfileController> {
  final String hintText;
  final String? value;
  final List<String> options;
  final Function(String?)? onChanged;
  const _DropDownMenu({
    required this.hintText,
    required this.options,
    this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      // height: 48.h,
      decoration: BoxDecoration(
        color: AppPalette.defaultFill,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hintText,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12.sp,
              color: AppPalette.black,
            ),
          ),
          isDense: true,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 24.sp),
          dropdownColor: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          items: options
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12.sp,
                      color: AppPalette.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _VerificationSection extends StatelessWidget {
  final ProfileController controller;

  const _VerificationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _TitleTextField(
            title: 'Your NID Number',
            textController: controller.nidNumberController,
          ),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Front Side of NID',
              onTap: () async {
                controller.nidFrontPic.value = await controller.pickImage();
              },
              image: controller.nidFrontPic.value,
            );
          }),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Back Side of NID',
              onTap: () async {
                controller.nidBackPic.value = await controller.pickImage();
              },
              image: controller.nidBackPic.value,
            );
          }),
          40.h.verticalSpace,
          _TitleTextField(
            title: 'Your Trade license Number',
            textController: controller.tradeNumberController,
          ),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Upload Trade License',
              onTap: () async {
                controller.tradeLicensePic.value = await controller.pickImage();
              },
              image: controller.tradeLicensePic.value,
            );
          }),
          40.h.verticalSpace,
          _TitleTextField(
            title: 'Your TIN Number',
            textController: controller.nidNumberController,
          ),
          12.h.verticalSpace,
          Obx(() {
            return _ImagePickerContainer(
              title: 'Upload TIN Certificate',
              onTap: () async {
                controller.nidBackPic.value = await controller.pickImage();
              },
              image: controller.nidBackPic.value,
            );
          }),
          40.h.verticalSpace,
          _TitleTextField(
            title: 'Your BIN Number',
            textController: controller.nidNumberController,
          ),
        ],
      ),
    );
  }
}

class _TitleTextField extends StatelessWidget {
  final String title;
  final TextEditingController textController;
  final TextStyle? titleTextStyle;
  final TextStyle? fieldTextStyle;
  const _TitleTextField({
    required this.title,
    required this.textController,
    this.titleTextStyle,
    this.fieldTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style:
              titleTextStyle ??
              TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: AppPalette.complemetary,
              ),
        ),
        5.h.verticalSpace,
        CustomTextFormField(
          hintText: 'Enter $title',
          controller: textController,
          textStyle:
              fieldTextStyle ??
              TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12.sp,
                color: AppPalette.black,
              ),
          maxLines: 1,
        ),
      ],
    );
  }
}

class _ImagePickerContainer extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final File? image;

  const _ImagePickerContainer({
    required this.onTap,
    this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            color: AppPalette.complemetary,
          ),
        ),
        10.h.verticalSpace,
        InkWell(
          radius: kBorderRadius.r,
          onTap: onTap,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: [5, 5],
              color: AppPalette.border1,
              radius: Radius.circular(kBorderRadius.r),
            ),
            child: Container(
              height: 114.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadius.r),
              ),
              child: image == null
                  ? Column(
                      mainAxisSize: .min,
                      mainAxisAlignment: .center,
                      children: [
                        Image.asset(
                          'assets/icons/upward_arrow.png',
                          width: 30.w,
                          fit: BoxFit.cover,
                        ),
                        15.h.verticalSpace,
                        Text(
                          'PNG, JPEG (Max 2MB)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppPalette.subtext,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      child: Image.file(image!, fit: BoxFit.cover),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerificationInprogressSection extends StatelessWidget {
  final ProfileController controller;

  const _VerificationInprogressSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.verificationInprogressItems.map((item) {
          final color = controller.verificationColor(item.state);
          final label = controller.verificationLabel(item.state);

          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppPalette.border1, width: 0.7),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.black.withAlpha(220),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: color,
                            fontWeight: .w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22.sp,
                  color: Colors.grey[500],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PayoutSettingsSection extends StatelessWidget {
  final ProfileController controller;

  const _PayoutSettingsSection({required this.controller});

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
                  child: _DropDownMenu(
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
              _TitleTextField(
                title: 'Bank Name',
                textController: controller.bankNameController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              _TitleTextField(
                title: 'Bank Account Holder Name',
                textController: controller.accountHolderNameController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              _TitleTextField(
                title: 'Bank Account No',
                textController: controller.bankAccountNumberController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              _TitleTextField(
                title: 'Routing Number',
                textController: controller.routingNumberController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
            ] else if (controller.selectedAccountType.value == 'bKash') ...[
              _TitleTextField(
                title: 'bKash No.',
                textController: controller.bKashNoController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              _TitleTextField(
                title: 'bKash Holder Name.',
                textController: controller.bKashHolderNameController,
                titleTextStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.secondary,
                ),
              ),
              10.h.verticalSpace,
              _TitleTextField(
                title: 'bKash Account Type',
                textController: controller.bKashAccountTypeController,
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
