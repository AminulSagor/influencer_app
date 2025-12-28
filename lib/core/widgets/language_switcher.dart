import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

import '../controllers/language_controller.dart';

class LanguageSwitcher extends GetView<LanguageController> {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppPalette.defaultStroke),
      ),
      child: Obx(() {
        final isEnglish = controller.currentLocale.value.languageCode == 'en';
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: controller.changeToEnglish,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isEnglish
                        ? AppPalette.secondary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'En',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: isEnglish ? AppPalette.white : AppPalette.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: controller.changeToBangla,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isEnglish
                        ? AppPalette.secondary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'বাং',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: !isEnglish ? AppPalette.white : AppPalette.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
