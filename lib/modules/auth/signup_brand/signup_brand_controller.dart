// lib/modules/auth/signup_brand/signup_brand_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/models/social_link.dart';
import '../../../routes/app_routes.dart';

class SignupBrandController extends GetxController {
  // ----------------- Step 1 (basic info) -----------------
  final formKey = GlobalKey<FormState>();

  final brandNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // language toggle
  final isEnglish = true.obs;

  void setLanguage(String code) {
    if (code == 'en') {
      isEnglish.value = true;
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      isEnglish.value = false;
      Get.updateLocale(const Locale('bn', 'BD'));
    }
  }

  void onContinue() {
    // if (formKey.currentState?.validate() != true) return;

    Get.toNamed(
      AppRoutes.verification,
      arguments: {
        'phone': phoneController.text.trim(),
        'accountType': AccountType.brand,
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
    Get.toNamed(AppRoutes.signupBrandSocial);
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
    Get.toNamed(AppRoutes.signupBrandKyc);
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
    Get.toNamed(AppRoutes.signupBrandTradeLicense);
  }

  void onKycSubmit() {
    // if (nidFormKey.currentState?.validate() != true) return;
    Get.toNamed(AppRoutes.signupBrandTradeLicense);
  }

  // ----------------- Step 5 (trade license / KYC) -----------------
  final tradeLicenseFormKey = GlobalKey<FormState>();

  final tradeLicenseNumberController = TextEditingController();
  final RxnString tradeLicenseFilePath = RxnString();

  Future<void> pickTradeLicense() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      tradeLicenseFilePath.value = file.path;
    }
  }

  void onTradeLicenseContinue() {
    // if (tradeLicenseFormKey.currentState?.validate() != true) return;
    Get.toNamed(AppRoutes.signupBrandTin);
  }

  void onTradeLicenseSkip() {
    Get.toNamed(AppRoutes.signupBrandTin);
  }

  // ----------------- Step 6 (TIN / BIN) -----------------
  final tinFormKey = GlobalKey<FormState>();

  final tinNumberController = TextEditingController();
  final RxnString tinCertificatePath = RxnString();
  final binNumberController = TextEditingController();

  Future<void> pickTinCertificate() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
    );

    if (file != null) {
      tinCertificatePath.value = file.path;
    }
  }

  void onTinSkip() {
    // go to success / dashboard
    Get.toNamed(
      AppRoutes.signupSuccess,
      arguments: {'accountType': AccountType.brand},
    );
  }

  void onTinContinue() {
    // if (tinFormKey.currentState?.validate() != true) return;
    // optionally ensure certificate selected
    Get.toNamed(
      AppRoutes.signupSuccess,
      arguments: {'accountType': AccountType.brand},
    );
  }

  // ----------------- Common navigation -----------------
  void goToLogin() {
    Get.offAllNamed('/login');
  }

  void goBack() {
    Get.back();
  }

  // IMPORTANT: do NOT dispose the TextEditingControllers here
  // because this controller is shared across multiple steps.
  @override
  void onClose() {
    // Leave controllers alive; Get will keep this instance for the flow.
    super.onClose();
  }
}

class SignupBrandBinding extends Bindings {
  @override
  void dependencies() {
    // keep controller alive across all brand signup steps
    Get.put<SignupBrandController>(SignupBrandController(), permanent: true);
  }
}
