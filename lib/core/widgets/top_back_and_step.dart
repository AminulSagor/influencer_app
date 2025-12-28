import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';

import '../theme/app_palette.dart';

class TopBackAndStep extends StatelessWidget {
  final int currentStep;
  final int? totalSteps;
  final VoidCallback? onGoBack;
  const TopBackAndStep({
    super.key,
    required this.currentStep,
    this.totalSteps,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final accountTypeService = Get.find<AccountTypeService>();
    final isAdAgency = accountTypeService.isAdAgency;
    final isBrand = accountTypeService.isBrand;

    final steps = isBrand
        ? 9
        : isAdAgency
        ? 10
        : 7;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: 30.sp),
          color: AppPalette.primary,
          padding: EdgeInsets.zero,
          onPressed: onGoBack ?? Get.back,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(totalSteps ?? steps, (index) {
            final isActive = index == currentStep - 1;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: isActive ? 72.w : 9.w,
              height: 9.h,
              decoration: BoxDecoration(
                color: isActive ? AppPalette.primary : AppPalette.secondary,
                borderRadius: BorderRadius.circular(999.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}
