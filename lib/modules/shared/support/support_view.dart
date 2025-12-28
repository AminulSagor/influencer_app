// lib/modules/ad_agency/support/support_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import 'support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        top: false, // top bar already provided by BottomNavView
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SupportHeader(onBack: controller.onBack),
              SizedBox(height: 20.h),
              _HelplineCard(controller: controller),
              SizedBox(height: 20.h),
              _EmailCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top row: back + title
// ---------------------------------------------------------------------------

class _SupportHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _SupportHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(999.r),
          onTap: onBack,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 24.sp,
              color: AppPalette.primary,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Icon(Icons.headset_mic_rounded, size: 26.sp, color: AppPalette.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'support_contact_title'.tr, // "Contact Support" / "সাপোর্ট টিম"
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpline card
// ---------------------------------------------------------------------------

class _HelplineCard extends StatelessWidget {
  final SupportController controller;

  const _HelplineCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3D9),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Icon(
                  Icons.call_rounded,
                  size: 22.sp,
                  color: AppPalette.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'support_helpline_section_title'.tr,
                    // "Helpline Numbers" / "হেল্পলাইন নম্বরসমূহ"
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...controller.helplines.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _HelplineTile(
                label: item.labelKey.tr, // "Help Line 1"
                phone: item.phone,
                timeText: controller.timeKey.tr,
                onTapCall: () => controller.callNumber(item.phone),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelplineTile extends StatelessWidget {
  final String label;
  final String phone;
  final String timeText;
  final VoidCallback onTapCall;

  const _HelplineTile({
    required this.label,
    required this.phone,
    required this.timeText,
    required this.onTapCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE28328),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  timeText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: onTapCall,
            borderRadius: BorderRadius.circular(999.r),
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(
                Icons.phone_in_talk_rounded,
                size: 26.sp,
                color: AppPalette.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Email card
// ---------------------------------------------------------------------------

class _EmailCard extends StatelessWidget {
  final SupportController controller;

  const _EmailCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3D9),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Icon(
                  Icons.email_rounded,
                  size: 22.sp,
                  color: AppPalette.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'support_email_section_title'.tr,
                    // "Email Us" / "ইমেইল করুন"
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...controller.emails.map(
            (email) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _EmailTile(
                email: email,
                onTap: () => controller.emailTo(email),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailTile extends StatelessWidget {
  final String email;
  final VoidCallback onTap;

  const _EmailTile({required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                email,
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
      ),
    );
  }
}
