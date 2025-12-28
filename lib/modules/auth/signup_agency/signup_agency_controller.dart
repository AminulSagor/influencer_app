import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/models/social_link.dart';
import '../../../routes/app_routes.dart';
import 'widgets/experienced_niche_dialog.dart';

class SignupAgencyController extends GetxController {
  // ----------------- Step 1 (basic info) -----------------
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  void onContinue() {
    // if (formKey.currentState?.validate() != true) return;

    Get.toNamed(
      AppRoutes.verification,
      arguments: {
        'phone': phoneController.text.trim(),
        'accountType': AccountType.adAgency,
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
    Get.toNamed(AppRoutes.signupAgencyExpertise);
  }

  // ----------------- Step 3 (expertise / industries) -----------------
  final expertiseFormKey = GlobalKey<FormState>();

  // Dropdown options
  final List<String> platformOptions = const [
    'Facebook',
    'Instagram',
    'YouTube',
    'TikTok',
    'X (Twitter)',
    'Google Ads',
    'LinkedIn',
  ];

  /// Master list of niches – extend as you like
  final List<String> allNiches = const [
    'Public Speaking',
    'Voiceovers',
    'Podcasting',
    'Product Photography',
    'Conversion Optimization',
    'Technology',
    'Fashion',
    'Food & Beverage',
    'Travel',
    'Health & Fitness',
  ];

  // List of platform blocks shown in the UI
  final RxList<AgencyPlatformEntry> platforms = <AgencyPlatformEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    // start with one block
    platforms.add(AgencyPlatformEntry());
  }

  void addPlatform() {
    platforms.add(AgencyPlatformEntry());
  }

  void removePlatform(int index) {
    if (index < 0 || index >= platforms.length) return;
    final entry = platforms.removeAt(index);
    entry.dispose();
  }

  Future<void> openNicheDialog(AgencyPlatformEntry entry) async {
    final result = await Get.dialog<List<String>>(
      ExperiencedNicheDialog(
        initialSelected: entry.workedNiches.toList(),
        allNiches: allNiches,
      ),
    );

    if (result != null) {
      entry.workedNiches.assignAll(result);
      // Update the read-only summary field text
      entry.nicheSummaryController.text = result.isEmpty
          ? ''
          : result.join(', ');
    }
  }

  void removeWorkedNiche(AgencyPlatformEntry entry, String niche) {
    entry.workedNiches.remove(niche);
    entry.nicheSummaryController.text = entry.workedNiches.isEmpty
        ? ''
        : entry.workedNiches.join(', ');
  }

  void onExpertiseContinue() {
    // if (expertiseFormKey.currentState?.validate() != true) return;

    // TODO: send data to backend and navigate to next agency step / dashboard
    Get.toNamed(AppRoutes.signupAgencySocial);
  }

  // ----------------- Step 4 (social links) -----------------
  final socialFormKey = GlobalKey<FormState>();

  final websiteController = TextEditingController();
  final RxnString selectedPlatform = RxnString();
  final profileLinkController = TextEditingController();

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
    Get.toNamed(AppRoutes.signupAgencyKyc);
  }

  // ----------------- Step 5 (KYC / NID) -----------------
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
    Get.offAllNamed(AppRoutes.signupAgencyTradeLicense);
  }

  void onKycSubmit() {
    // if (nidFormKey.currentState?.validate() != true) return;
    Get.offAllNamed(AppRoutes.signupAgencyTradeLicense);
  }

  // ----------------- Step 6 (trade license / KYC) -----------------
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
    Get.toNamed(AppRoutes.signupAgencyTin);
  }

  void onTradeLicenseSkip() {
    Get.toNamed(AppRoutes.signupAgencyTin);
  }

  // ----------------- Step 7 (TIN / BIN) -----------------
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
    Get.toNamed(
      AppRoutes.signupSuccess,
      arguments: {'accountType': AccountType.adAgency},
    );
  }

  void onTinContinue() {
    // if (tinFormKey.currentState?.validate() != true) return;
    Get.toNamed(
      AppRoutes.signupSuccess,
      arguments: {'accountType': AccountType.adAgency},
    );
  }

  // ----------------- Navigation helpers -----------------
  void goBack() {
    Get.back();
  }

  void goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    // (kept simple as this controller may stay alive across steps)
    super.onClose();
  }
}

/// One block of "platform + niches + worked niches"
class AgencyPlatformEntry {
  final RxnString selectedPlatform = RxnString();

  /// What the user has selected for this platform
  final RxList<String> workedNiches = <String>[].obs;

  /// Read-only summary text shown in the "Select Niches" field
  final TextEditingController nicheSummaryController = TextEditingController();

  void dispose() {
    nicheSummaryController.dispose();
  }
}

class SignupAgencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupAgencyController>(() => SignupAgencyController());
  }
}
