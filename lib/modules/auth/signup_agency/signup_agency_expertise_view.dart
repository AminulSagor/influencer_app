import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_agency_controller.dart';

class SignupAgencyExpertiseView extends GetView<SignupAgencyController> {
  const SignupAgencyExpertiseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: controller.expertiseFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(onBack: controller.goBack),
                SizedBox(height: 32.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Define Your Expertise',
                    style: TextStyle(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                Text(
                  'Showcase Your Experience',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
                SizedBox(height: 10.h),

                Text(
                  'Tell us which industries you specialize in so we can match you with the most relevant campaign briefs.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppPalette.primary.withOpacity(0.9),
                  ),
                ),

                SizedBox(height: 28.h),

                const _InfoRow(
                  icon: Icons.filter_alt_rounded,
                  text:
                      'We use these preferences to filter out irrelevant briefs, saving you time.',
                ),

                SizedBox(height: 32.h),

                // Section title
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 26.sp,
                      color: AppPalette.primary,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Select Industries',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Platform blocks
                Obx(
                  () => Column(
                    children: [
                      for (int i = 0; i < controller.platforms.length; i++)
                        _PlatformBlock(
                          index: i,
                          entry: controller.platforms[i],
                          controller: controller,
                          canRemove: controller.platforms.length > 1,
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Add another platform
                GestureDetector(
                  onTap: controller.addPlatform,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: const Color(0xFFD4E0C2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20.sp, color: AppPalette.primary),
                        SizedBox(width: 8.w),
                        Text(
                          'Add Another Platform',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                CustomButton(
                  onTap: controller.onExpertiseContinue,
                  btnText: 'Continue',
                  height: 56.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable pieces
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(999.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: AppPalette.primary,
            ),
          ),
        ),
        const Spacer(),
        const _SignupProgressBar(totalSteps: 8, currentStep: 3),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3D9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, color: AppPalette.primary, size: 26.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppPalette.primary,
      ),
    );
  }
}

class _PlatformBlock extends StatelessWidget {
  final int index;
  final AgencyPlatformEntry entry;
  final SignupAgencyController controller;
  final bool canRemove;

  const _PlatformBlock({
    required this.index,
    required this.entry,
    required this.controller,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index > 0)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Platform ${index + 1}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                  if (canRemove)
                    GestureDetector(
                      onTap: () => controller.removePlatform(index),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20.sp,
                        color: Colors.redAccent,
                      ),
                    ),
                ],
              ),
            ),

          // Platform dropdown
          const _FieldLabel('Select Platforms *'),
          SizedBox(height: 6.h),
          Obx(
            () => DropdownButtonFormField<String>(
              value: entry.selectedPlatform.value,
              items: controller.platformOptions
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: p,
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => entry.selectedPlatform.value = value,
              decoration: InputDecoration(
                hintText: 'Select Platform',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.r),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ),
          ),

          SizedBox(height: 18.h),

          // Niches -> opens dialog
          const _FieldLabel('Select Niches *'),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () => controller.openNicheDialog(entry),
            child: AbsorbPointer(
              child: TextFormField(
                controller: entry.nicheSummaryController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search & Select Niches',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  suffixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),

          SizedBox(height: 18.h),

          // Worked niches as chips
          const _FieldLabel('Worked Niches *'),
          SizedBox(height: 6.h),
          Obx(
            () => Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: Color(0xFFD1D5DB)),
              ),
              child: entry.workedNiches.isEmpty
                  ? Text(
                      'No niches selected yet',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    )
                  : Wrap(
                      spacing: 10.w,
                      runSpacing: 8.h,
                      children: entry.workedNiches
                          .map(
                            (niche) => _NicheChip(
                              label: niche,
                              onRemove: () =>
                                  controller.removeWorkedNiche(entry, niche),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NicheChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _NicheChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8D9),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppPalette.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14.sp, color: AppPalette.primary),
          ),
        ],
      ),
    );
  }
}

/// Simple progress bar for the agency signup flow
class _SignupProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const _SignupProgressBar({
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(totalSteps, (index) {
          final bool isMainBar = index == 2; // step 3 highlighted bar
          final bool isActive = index <= currentStep;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: isMainBar ? 70.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: isActive
                  ? AppPalette.primary
                  : AppPalette.primary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(999.r),
            ),
          );
        }),
      ),
    );
  }
}
