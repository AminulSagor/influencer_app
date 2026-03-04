import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../core/enums/account_type.dart';
import '../../../core/models/social_link.dart';
import '../../../core/services/campaign_service.dart';
import '../../../routes/app_routes.dart';
import 'widgets/experienced_niche_dialog.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/modules/ad_agency/models/agency_onboarding_model.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_onboarding_service.dart';
import 'package:influencer_app/modules/ad_agency/services/upload_service.dart';

class SignupAgencyController extends GetxController {
  // ----------------- Step 1 (basic info) -----------------
  final formKey = GlobalKey<FormState>();

  final agencyNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = Get.find<AuthService>();
  final accountTypeService = Get.find<AccountTypeService>();
  final AgencyOnboardingService _agencyOnboardingService =
      Get.find<AgencyOnboardingService>();
  final UploadService _uploadService = Get.find<UploadService>();
  final CampaignService _campaignService = Get.find<CampaignService>();

  final isSubmitting = false.obs;
  final isFinishing = false.obs;
  final isUploadingNid = false.obs;
  final isUploadingTradeLicense = false.obs;
  final isUploadingTin = false.obs;

  // Onboarding data collection
  final AgencyOnboardingModel onboardingData = AgencyOnboardingModel();

  void onContinue() async {
    if (isSubmitting.value) return;
    if (formKey.currentState?.validate() != true) return;
    isSubmitting.value = true;

    final result = await ApiErrorHandler.call(
      () => authService.signup(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        role: 'agency',
      ),
    );

    isSubmitting.value = false;

    if (result.isSuccess) {
      accountTypeService.setRole(AccountType.adAgency);
      Get.toNamed(
        AppRoutes.verification,
        arguments: {
          'phone': result.data!.phone,
          'accountType': AccountType.adAgency,
        },
      );
    }
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
    if (addressFormKey.currentState?.validate() != true) return;

    // Save address data to onboarding model
    onboardingData.thana = selectedThana.value?.trim();
    onboardingData.zilla = selectedZilla.value?.trim();
    onboardingData.fullAddress = fullAddressController.text.trim();
    onboardingData.country = 'Bangladesh';

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

  final RxList<String> allNiches = <String>[].obs;
  final isLoadingNiches = false.obs;

  // List of platform blocks shown in the UI
  final RxList<AgencyPlatformEntry> platforms = <AgencyPlatformEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    // start with one block
    platforms.add(AgencyPlatformEntry());
    _loadNiches();
  }

  Future<void> _loadNiches() async {
    if (isLoadingNiches.value) return;
    isLoadingNiches.value = true;

    await ApiErrorHandler.call(() async {
      final niches = await _campaignService.fetchNiches();
      if (niches.isNotEmpty) {
        allNiches
          ..clear()
          ..addAll(niches);
      }
      return true;
    }, showError: false);

    isLoadingNiches.value = false;
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
    if (allNiches.isEmpty) {
      await _loadNiches();
    }
    if (allNiches.isEmpty) {
      Get.snackbar('Niches Unavailable', 'Please try again in a moment.');
      return;
    }
    final result = await Get.dialog<List<String>>(
      ExperiencedNicheDialog(
        initialSelected: entry.workedNiches.toList(),
        allNiches: allNiches.toList(growable: false),
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
    if (expertiseFormKey.currentState?.validate() != true) return;

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

  void removeLink(int index) {
    if (index >= 0 && index < socialLinks.length) {
      socialLinks.removeAt(index);
    }
  }

  void onSocialContinue() {
    if (socialFormKey.currentState?.validate() != true) return;

    if ((selectedPlatform.value?.trim().isNotEmpty ?? false) &&
        profileLinkController.text.trim().isNotEmpty) {
      socialLinks.add(
        SocialLink(
          website: websiteController.text.trim().isEmpty
              ? null
              : websiteController.text.trim(),
          platform: selectedPlatform.value!.trim(),
          profileUrl: profileLinkController.text.trim(),
        ),
      );
      selectedPlatform.value = null;
      profileLinkController.clear();
    }

    // Save social links and website to onboarding model
    onboardingData.website = websiteController.text.trim().isEmpty
        ? null
        : websiteController.text.trim();
    onboardingData.socialLinks = socialLinks
        .map((s) => AgencySocialLink(platform: s.platform, url: s.profileUrl))
        .toList();

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

  Future<void> onKycSkip() async {
    if (isUploadingNid.value) return;
    Get.toNamed(AppRoutes.signupAgencyTradeLicense);
  }

  Future<void> onKycSubmit() async {
    if (nidFormKey.currentState?.validate() != true) return;
    if (isUploadingNid.value) return;

    // Save NID number if provided
    final nidNumber = nidNumberController.text.trim();
    if (nidNumber.isNotEmpty) {
      onboardingData.nidNumber = nidNumber;
    }

    // Upload NID images if provided
    isUploadingNid.value = true;

    final result = await ApiErrorHandler.call(() async {
      if (nidFrontPath.value != null) {
        final frontUrl = await _uploadFile(
          filePath: nidFrontPath.value!,
          module: 'agency-kyc',
        );
        onboardingData.nidFrontImg = frontUrl;
      }

      if (nidBackPath.value != null) {
        final backUrl = await _uploadFile(
          filePath: nidBackPath.value!,
          module: 'agency-kyc',
        );
        onboardingData.nidBackImg = backUrl;
      }
      return true;
    });

    isUploadingNid.value = false;

    if (result.isSuccess) {
      Get.toNamed(AppRoutes.signupAgencyTradeLicense);
    }
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

  Future<void> onTradeLicenseContinue() async {
    if (tradeLicenseFormKey.currentState?.validate() != true) return;
    if (isUploadingTradeLicense.value) return;

    // Save trade license number if provided
    final tradeLicenseNumber = tradeLicenseNumberController.text.trim();
    if (tradeLicenseNumber.isNotEmpty) {
      onboardingData.tradeLicenseNumber = tradeLicenseNumber;
    }

    // Upload trade license image if provided
    isUploadingTradeLicense.value = true;

    final result = await ApiErrorHandler.call(() async {
      if (tradeLicenseFilePath.value != null) {
        final tradeLicenseUrl = await _uploadFile(
          filePath: tradeLicenseFilePath.value!,
          module: 'agency-trade-license',
        );
        onboardingData.tradeLicenseImage = tradeLicenseUrl;
      }
      return true;
    });

    isUploadingTradeLicense.value = false;

    if (result.isSuccess) {
      Get.toNamed(AppRoutes.signupAgencyTin);
    }
  }

  Future<void> onTradeLicenseSkip() async {
    if (isUploadingTradeLicense.value) return;
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

  Future<void> onTinSkip() async {
    if (isUploadingTin.value || isFinishing.value) return;
    await _finishAgencySignup();
  }

  Future<void> onTinContinue() async {
    if (tinFormKey.currentState?.validate() != true) return;
    if (isUploadingTin.value || isFinishing.value) return;

    // Save TIN number if provided
    final tinNumber = tinNumberController.text.trim();
    if (tinNumber.isNotEmpty) {
      onboardingData.tinNumber = tinNumber;
    }

    // Save BIN number if provided
    final binNumber = binNumberController.text.trim();
    if (binNumber.isNotEmpty) {
      onboardingData.binNumber = binNumber;
    }

    // Upload TIN certificate if provided
    isUploadingTin.value = true;

    final result = await ApiErrorHandler.call(() async {
      if (tinCertificatePath.value != null) {
        final tinUrl = await _uploadFile(
          filePath: tinCertificatePath.value!,
          module: 'agency-tin',
        );
        onboardingData.tinImage = tinUrl;
      }
      return true;
    });

    isUploadingTin.value = false;

    if (result.isSuccess) {
      _finishAgencySignup();
    }
  }

  Future<void> _finishAgencySignup() async {
    if (isFinishing.value) return;
    isFinishing.value = true;

    // Collect niches from expertise step
    final niches = _collectUniqueNiches();
    if (niches.isEmpty) {
      isFinishing.value = false;
      Get.snackbar(
        'Expertise Required',
        'Please select at least one niche before finishing.',
      );
      Get.toNamed(AppRoutes.signupAgencyExpertise);
      return;
    }
    onboardingData.niches = niches;

    final result = await ApiErrorHandler.call(() async {
      // Submit all onboarding data in one request
      await _agencyOnboardingService.submitOnboarding(onboardingData);
      await _agencyOnboardingService.updateNiches(niches);
      return true;
    });

    isFinishing.value = false;

    if (result.isSuccess) {
      Get.offAllNamed(
        AppRoutes.signupSuccess,
        arguments: {'accountType': AccountType.adAgency},
      );
    }
  }

  List<String> _collectUniqueNiches() {
    final set = <String>{};
    for (final entry in platforms) {
      for (final n in entry.workedNiches) {
        final v = n.trim();
        if (v.isNotEmpty) set.add(v);
      }
    }
    return set.toList();
  }

  // ----------------- File Upload Helper -----------------

  /// Upload a file and return the public URL
  Future<String> _uploadFile({
    required String filePath,
    required String module,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    // Get file info
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(fileName).replaceFirst('.', '');
    final contentType = _getContentType(fileExtension);

    // Step 1: Get signed URL
    final signedUrlResult = await _uploadService.createSignedUrl(
      fileName: fileName,
      fileType: contentType,
      module: module,
    );

    // Step 2: Upload to cloud storage
    await _uploadService.uploadFileToSignedUrl(
      uploadUrl: signedUrlResult.uploadUrl,
      file: file,
      contentType: contentType,
    );

    // Step 3: Return public URL
    return signedUrlResult.fileUrl;
  }

  /// Get content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'image/jpeg';
    }
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
    // Keep one controller instance across the entire multi-step flow.
    if (!Get.isRegistered<SignupAgencyController>()) {
      Get.put(SignupAgencyController(), permanent: true);
    }
  }
}
