import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';

import '../../../core/theme/app_palette.dart';
import 'agency_home_locked_controller.dart';

class AgencyHomeLockedView extends GetView<AgencyHomeLockedController> {
  const AgencyHomeLockedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        top: false, // top bar already handled in BottomNavView
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeroCard(),
              SizedBox(height: 36.h),

              // Verification Progress
              Obx(
                () => _ExpandableSectionCard(
                  icon: Icons.verified_rounded,
                  title:
                      'Verification Progress', // 'home_locked_verification_title'.tr
                  progress: controller.verificationProgress.value,
                  isExpanded: controller.isVerificationExpanded.value,
                  onToggle: controller.toggleVerificationSection,
                  steps: controller.verificationSteps,
                ),
              ),
              SizedBox(height: 16.h),

              // Complete Your Profile (with help popups)
              Obx(
                () => _ExpandableSectionCard(
                  icon: Icons.check_circle_rounded,
                  title:
                      'Complete Your Profile', // 'home_locked_profile_title'.tr
                  progress: controller.profileProgress.value,
                  isExpanded: controller.isProfileExpanded.value,
                  onToggle: controller.toggleProfileSection,
                  steps: controller.profileSteps,
                ),
              ),
              SizedBox(height: 24.h),

              _NeedHelpSection(
                onGuideTap: controller.openVerificationGuide,
                onSupportTap: controller.contactSupport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top hero card
// ---------------------------------------------------------------------------

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        gradient: const LinearGradient(
          colors: [AppPalette.gradient1, AppPalette.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 21.sp),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'home_locked_hero_title'.tr,
              style: TextStyle(
                color: AppPalette.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'home_locked_hero_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppPalette.white, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double progress;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<ProgressStep> steps;

  const _ExpandableSectionCard({
    required this.icon,
    required this.title,
    required this.progress,
    required this.isExpanded,
    required this.onToggle,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          InkWell(
            borderRadius: BorderRadius.circular(kBorderRadius.r),
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(icon, color: AppPalette.primary, size: 23.sp),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 30.sp,
                        color: AppPalette.primary,
                      ),
                    ],
                  ),
                  14.h.verticalSpace,
                  // progress bar
                  Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppPalette.secondary.withAlpha(80),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0, 1),
                        child: Container(
                          height: 8.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppPalette.primary,
                                AppPalette.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // body
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
              child: Column(
                children: List.generate(
                  steps.length,
                  (index) => _TimelineItem(
                    step: steps[index],
                    isFirst: index == 0,
                    isLast: index == steps.length - 1,
                  ),
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline item
// ---------------------------------------------------------------------------

class _TimelineItem extends StatelessWidget {
  final ProgressStep step;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.isFirst,
    required this.isLast,
  });

  Color _statusColor() {
    switch (step.status) {
      case StepStatus.completed:
        return AppPalette.secondary;
      case StepStatus.inReview:
        return AppPalette.complemetary;
      case StepStatus.pending:
        return AppPalette.neutralGrey;
      case StepStatus.declined:
        return AppPalette.error;
    }
  }

  IconData _statusIcon() {
    switch (step.status) {
      case StepStatus.completed:
        return Icons.check_rounded;
      case StepStatus.inReview:
        return Icons.access_time_filled;
      case StepStatus.pending:
        return Icons.access_time_filled;
      case StepStatus.declined:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor();
    final bool hasHelp = step.helpText != null;

    return Row(
      crossAxisAlignment: isFirst
          ? .start
          : isLast
          ? .end
          : .center,
      children: [
        // left timeline
        SizedBox(
          width: 32.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFirst)
                Container(
                  width: 1.w,
                  height: 14.h,
                  color: const Color(0xFFE5E7EB),
                ),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(30),
                ),
                child: Icon(_statusIcon(), color: color, size: 18.sp),
              ),
              if (!isLast)
                Container(
                  width: 1.w,
                  height: 14.h,
                  color: const Color(0xFFE5E7EB),
                ),
            ],
          ),
        ),
        SizedBox(width: 8.w),

        // text + optional help icon
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        step.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppPalette.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      step.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppPalette.subtext,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasHelp) SizedBox(width: 8.w),
              if (hasHelp) _QuestionHelpButton(text: step.helpText!),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Question button with OverlayPortal popup
// ---------------------------------------------------------------------------

class _QuestionHelpButton extends StatefulWidget {
  final String text;

  const _QuestionHelpButton({required this.text});

  @override
  State<_QuestionHelpButton> createState() => _QuestionHelpButtonState();
}

class _QuestionHelpButtonState extends State<_QuestionHelpButton> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  void _toggle() {
    _controller.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          final size = MediaQuery.of(context).size;

          return Stack(
            children: [
              // tap anywhere to close
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _controller.hide,
                  child: Container(color: AppPalette.black.withAlpha(50)),
                ),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(-size.width * 0.80, -90.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size.width - 60.w),
                  child: _HelpBubble(text: widget.text),
                ),
              ),
            ],
          );
        },
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(999.r),
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: const BoxDecoration(
              color: AppPalette.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.question_mark_rounded,
              size: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speech-bubble style help popup (used by OverlayPortal)
// ---------------------------------------------------------------------------

class _HelpBubble extends StatelessWidget {
  final String text;

  const _HelpBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: AppPalette.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.question_mark_rounded,
                    size: 15.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.primary,
                      fontWeight: .w500,
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

// ---------------------------------------------------------------------------
// Need Help section
// ---------------------------------------------------------------------------

class _NeedHelpSection extends StatelessWidget {
  final VoidCallback onGuideTap;
  final VoidCallback onSupportTap;

  const _NeedHelpSection({
    required this.onGuideTap,
    required this.onSupportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_rounded, color: AppPalette.primary, size: 25.sp),
              SizedBox(width: 10.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'home_locked_need_help'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 26.h),
          _HelpTile(
            icon: Icons.info_rounded,
            title: 'home_locked_help_guide'.tr,
            onTap: onGuideTap,
          ),
          SizedBox(height: 14.h),
          _HelpTile(
            icon: Icons.headset_mic_rounded,
            title: 'home_locked_help_support'.tr,
            onTap: onSupportTap,
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppPalette.primary, size: 25.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 25.sp,
              color: AppPalette.subtext,
            ),
          ],
        ),
      ),
    );
  }
}
