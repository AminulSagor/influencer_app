// lib/modules/auth/signup_influencer/signup_influencer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/models/social_link.dart';

class SignupInfluencerController extends GetxController {
  // ----------------- Step 1 (basic info) -----------------
  final formKey = GlobalKey<FormState>();

  final brandNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  void onStep1Continue() {
    // if (formKey.currentState?.validate() != true) return;

    Get.toNamed(
      AppRoutes.verification,
      arguments: {
        'phone': phoneController.text,
        'accountType': AccountType.influencer,
      },
    );
  }

  // ----------------- Step 2 (address) -----------------
  final addressFormKey = GlobalKey<FormState>();

  final RxnString selectedThana = RxnString();
  final RxnString selectedZilla = RxnString();
  final fullAddressController = TextEditingController();

  final List<String> thanaOptions = const [
    'Dhanmondi',
    'Gulshan',
    'Banani',
    'Mirpur',
  ];

  final List<String> zillaOptions = const [
    'Dhaka',
    'Chattogram',
    'Barishal',
    'Sylhet',
  ];

  void onAddressContinue() {
    // if (addressFormKey.currentState?.validate() != true) return;
    Get.toNamed(AppRoutes.signupInfluencerSocial);
  }

  // ----------------- Step 3 (social links) -----------------
  final socialFormKey = GlobalKey<FormState>();

  final websiteController = TextEditingController();
  final RxnString selectedPlatform = RxnString();
  final profileLinkController = TextEditingController();

  final List<String> platformOptions = const [
    'Facebook',
    'Instagram',
    'YouTube',
    'TikTok',
    'X (Twitter)',
  ];

  final RxList<SocialLink> socialLinks = <SocialLink>[].obs;

  void addAnotherLink() {
    if ((selectedPlatform.value == null ||
            selectedPlatform.value!.trim().isEmpty) ||
        profileLinkController.text.trim().isEmpty) {
      return;
    }

    socialLinks.add(
      SocialLink(
        website: websiteController.text.trim().isEmpty
            ? null
            : websiteController.text.trim(),
        platform: selectedPlatform.value!,
        profileUrl: profileLinkController.text.trim(),
      ),
    );

    selectedPlatform.value = null;
    profileLinkController.clear();
  }

  void onSocialContinue() {
    // if (socialFormKey.currentState?.validate() != true) return;
    Get.toNamed(AppRoutes.signupInfluencerKyc);
  }

  // ----------------- Step 4 (KYC / NID) -----------------
  final nidFormKey = GlobalKey<FormState>();

  final nidNumberController = TextEditingController();
  final RxnString nidFrontPath = RxnString();
  final RxnString nidBackPath = RxnString();

  final ImagePicker _picker = ImagePicker();

  Future<void> pickNidFront() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
    );

    if (file != null) {
      nidFrontPath.value = file.path;
    }
  }

  Future<void> pickNidBack() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
    );

    if (file != null) {
      nidBackPath.value = file.path;
    }
  }

  void onKycSkip() {
    Get.toNamed(
      AppRoutes.signupSuccess,
      arguments: {'accountType': AccountType.influencer},
    );
  }

  void onKycSubmit() {
    // if (nidFormKey.currentState?.validate() != true) return;
    Get.toNamed(
      AppRoutes.signupSuccess,
      arguments: {'accountType': AccountType.influencer},
    );
  }

  // ----------------- Navigation helpers -----------------
  void goToLogin() {
    Get.offAllNamed('/login');
  }

  void goBack() {
    Get.back();
  }

  // ----------------- Lifecycle -----------------
  @override
  void onClose() {
    // step 1
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    // address
    fullAddressController.dispose();

    // social
    websiteController.dispose();
    profileLinkController.dispose();

    // kyc
    nidNumberController.dispose();

    super.onClose();
  }
}
