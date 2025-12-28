import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/language_switcher.dart';

import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top row with Skip
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
              child: Row(
                children: [
                  Expanded(child: LanguageSwitcher()),
                  80.w.horizontalSpace,
                  GestureDetector(
                    onTap: controller.skip,
                    child: Text(
                      'btn_skip'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _OnboardingPage(model: page);
                },
              ),
            ),

            // Page indicator
            Obx(
              () => _PageIndicator(
                pageCount: controller.pages.length,
                currentIndex: controller.currentPage.value,
              ),
            ),

            SizedBox(height: 32.h),

            // Description
            Obx(() {
              final page = controller.pages[controller.currentPage.value];
              return _DescriptionText(text: page.description.tr);
            }),

            SizedBox(height: 35.h),

            // Bottom button
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: CustomButton(
                  onTap: controller.next,
                  btnText: controller.isLastPage
                      ? 'btn_get_started'.tr
                      : 'btn_next'.tr,
                  height: 46.h,
                  width: double.infinity,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: .w600,
                    color: AppPalette.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageModel model;

  const _OnboardingPage({required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                model.title.tr,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ),
          ),
        ),

        // Image / placeholder
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.asset(model.imageAsset ?? '', fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final String text;

  const _DescriptionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: .w500,
          color: AppPalette.primary,
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentIndex;

  const _PageIndicator({required this.pageCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final bool isActive = index == currentIndex;

          final double width = isActive ? 72.w : 9.w;
          final double height = isActive ? 9.h : 9.h;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isActive ? AppPalette.primary : AppPalette.secondary,
              borderRadius: BorderRadius.circular(999.r),
            ),
          );
        }),
      ),
    );
  }
}
