import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final String? imageAsset;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    this.imageAsset,
  });
}

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;

  // You can later localize / pull from backend
  late final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: 'onb1_title',
      description: 'onb1_body',
      imageAsset: 'assets/images/onboarding1.png',
    ),
    OnboardingPageModel(
      title: 'onb2_title',
      description: 'onb2_body',
      imageAsset: 'assets/images/onboarding2.png',
    ),
    OnboardingPageModel(
      title: 'onb3_title',
      description: 'onb3_body',
      imageAsset: 'assets/images/onboarding3.png',
    ),
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (isLastPage) {
      _finish();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  void skip() {
    _finish();
  }

  void _finish() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
