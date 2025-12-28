// lib/modules/auth/signup_agency/signup_agency_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/custom_button.dart';
import 'signup_agency_controller.dart';

class SignupAgencyView extends GetView<SignupAgencyController> {
  const SignupAgencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: back + progress
                Row(
                  children: [
                    InkWell(
                      onTap: controller.goBack,
                      borderRadius: BorderRadius.circular(999.r),
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 22.sp,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const _SignupProgressBar(
                      totalSteps: 8, // adjust based on full flow
                      currentStep: 1,
                    ),
                  ],
                ),

                SizedBox(height: 40.h),

                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hello, Agency!',
                    style: TextStyle(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Subtitle
                Text(
                  "Let's Get You Set Up!",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary,
                  ),
                ),

                SizedBox(height: 32.h),

                // Section title
                Text(
                  'Profile Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primary,
                  ),
                ),

                SizedBox(height: 24.h),

                // First name
                const _FieldLabel(text: 'First Name *'),
                SizedBox(height: 6.h),
                _AgencyTextField(
                  controller: controller.firstNameController,
                  hintText: 'Enter Your First Name',
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),

                // Last name
                const _FieldLabel(text: 'Last Name *'),
                SizedBox(height: 6.h),
                _AgencyTextField(
                  controller: controller.lastNameController,
                  hintText: 'Enter Your Last Name',
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),

                // Email
                const _FieldLabel(text: 'Email Address *'),
                SizedBox(height: 6.h),
                _AgencyTextField(
                  controller: controller.emailController,
                  hintText: 'Ex: johndoe@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!GetUtils.isEmail(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),

                // Phone
                const _FieldLabel(text: 'Phone Number *'),
                SizedBox(height: 6.h),
                _AgencyTextField(
                  controller: controller.phoneController,
                  hintText: 'Ex: +8801234567890',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 40.h),

                // Continue button
                CustomButton(
                  onTap: controller.onContinue,
                  btnText: 'Continue',
                  width: double.infinity,
                  height: 56.h,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 24.h),

                // Already have an account? Login
                Center(
                  child: GestureDetector(
                    onTap: controller.goToLogin,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFD1D5DB),
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

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

class _AgencyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _AgencyTextField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: AppPalette.primary, width: 1.6),
        ),
      ),
    );
  }
}

/// Progress bar that matches the design (thick bar + dots)
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
          // first index as main bar, rest as dots
          final bool isMainBar = index == 1; // middle bar in screenshot
          final bool isActive = currentStep >= index + 1;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: isMainBar ? 90.w : 8.w,
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
