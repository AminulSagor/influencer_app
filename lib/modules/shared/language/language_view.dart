// language_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/widgets/custom_button.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.h.verticalSpace,
                    // Back Arrow
                    GestureDetector(
                      onTap: () => Get.back(id: 1),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppPalette.primary, // Assuming Green
                        size: 24.sp,
                      ),
                    ),
                    25.h.verticalSpace,
                    // Main Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 24.h,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header inside Card
                          Row(
                            children: [
                              Image.asset('assets/icons/language2.png'),
                              10.w.horizontalSpace,
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'select_language_header'.tr,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppPalette.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          20.h.verticalSpace,

                          // English Button (Filled Green)
                          Obx(() {
                            final isSelected =
                                controller.currentLocale.value
                                    .toLanguageTag() ==
                                'en-US';
                            return CustomButton(
                              onTap: controller.changeToEnglish,
                              width: double.infinity,
                              btnText: 'english'.tr,
                              btnColor: isSelected
                                  ? AppPalette.secondary
                                  : AppPalette.white,
                              borderRadius: kBorderRadius,
                              height: 50.h,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppPalette.primary,
                              ),
                            );
                          }),

                          15.h.verticalSpace,

                          // Bangla Button (Outlined/White)
                          Obx(() {
                            final isSelected =
                                controller.currentLocale.value
                                    .toLanguageTag() ==
                                'bn-BD';
                            return CustomButton(
                              onTap: controller.changeToBangla,
                              width: double.infinity,
                              btnText: 'bangla'.tr,
                              btnColor: isSelected
                                  ? AppPalette.secondary
                                  : AppPalette.white,
                              borderRadius: kBorderRadius,
                              height: 50.h,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppPalette.primary,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
