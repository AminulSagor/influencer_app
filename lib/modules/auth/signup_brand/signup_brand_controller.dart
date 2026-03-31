// lib/modules/auth/signup_brand/signup_brand_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/modules/ad_agency/services/upload_service.dart';
import 'package:influencer_app/modules/brand/models/onboarding_models.dart';
import 'package:influencer_app/modules/brand/services/brand_onboarding_services.dart';
import '../../../core/enums/account_type.dart';
import '../../../core/models/location_models.dart';
import '../../../core/models/social_link.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/campaign_service.dart';
import '../../../core/services/token_service.dart';
import '../../../core/utils/bd_phone_input_formatter.dart';
import '../../../routes/app_routes.dart';
import 'package:path/path.dart' as path;

// Helper class to collect onboarding data across steps
class _MutableBrandOnboardingData {
  String? thana;
  String? zilla;
  String? fullAddress;
  String? website;
  List<BrandSocialLink> socialLinks = [];
  String? nidNumber;
  String? nidFrontImg;
  String? nidBackImg;
  String? tradeLicenseNumber;
  String? tradeLicenseImg;
  String? tinNumber;
  String? tinImage;
  String? binNumber;
}

class SignupBrandController extends GetxController {
  // ----------------- Step 1 (basic info) -----------------
  final formKey = GlobalKey<FormState>();

  final LocationService _locationService = Get.find<LocationService>();

  final brandNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = Get.find<AuthService>();
  final accountTypeService = Get.find<AccountTypeService>();
  final _onboardingService = Get.find<BrandOnboardingService>();
  final _uploadService = Get.find<UploadService>();
  final _campaignService = Get.find<CampaignService>();

  // Onboarding data collection (using mutable fields)
  final onboardingData = _MutableBrandOnboardingData();

  // Loading states
  final isUploadingNid = false.obs;
  final isUploadingTradeLicense = false.obs;
  final isUploadingTin = false.obs;
  final isFinishing = false.obs;

  // language toggle
  final isEnglish = true.obs;

  // add this field inside SignupBrandController
  bool _addressPageBootstrapped = false;

  final TokenService _tokenService = Get.find<TokenService>();

  Future<void> _registerFcmTokenIfNeeded() async {
    try {
      final savedToken = await _tokenService.getFcmToken();
      if (savedToken != null && savedToken.trim().isNotEmpty) {
        return;
      }

      final liveToken = await FirebaseMessagingService.getCurrentFcmToken();
      if (liveToken == null || liveToken.trim().isEmpty) {
        return;
      }

      await authService.registerDeviceFcmToken(token: liveToken.trim());
    } catch (_) {
      // do not block signup success navigation because of fcm registration failure
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (phoneController.text.trim().isEmpty) {
      phoneController.text = '+88 ';
    }
    _loadPlatforms();
  }

  Future<void> onAddressPageOpened() async {
    if (_addressPageBootstrapped) return;
    _addressPageBootstrapped = true;

    await loadZillas();
    await _loadPlatforms();
  }

  void setLanguage(String code) {
    if (code == 'en') {
      isEnglish.value = true;
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      isEnglish.value = false;
      Get.updateLocale(const Locale('bn', 'BD'));
    }
  }

  final isSubmitting = false.obs;

  void onContinue() async {
    if (isSubmitting.value) return;
    if (formKey.currentState?.validate() != true) return;
    isSubmitting.value = true;

    final phone = BdPhoneInputFormatter().toApiPhone(phoneController.text);

    final result = await ApiErrorHandler.call(
      () => authService.signup(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phone,
        password: passwordController.text.trim(),
        role: 'client',
      ),
    );

    isSubmitting.value = false;

    if (result.isSuccess) {
      accountTypeService.setRole(AccountType.brand);
      Get.toNamed(
        AppRoutes.verification,
        arguments: {
          'phone': result.data!.phone,
          'accountType': AccountType.brand,
        },
      );
    }
  }

  // ----------------- Step 2 (address) -----------------
  final addressFormKey = GlobalKey<FormState>();

  final RxnString selectedThana = RxnString();
  final RxnString selectedThanaId = RxnString();
  final RxnString selectedZilla = RxnString();
  final RxnString selectedZillaId = RxnString();
  final fullAddressController = TextEditingController();

  final RxList<ZillaModel> zillas = <ZillaModel>[].obs;
  final RxList<ThanaModel> thanas = <ThanaModel>[].obs;

  final isLoadingZillas = false.obs;
  final isLoadingThanas = false.obs;

  List<String> get zillaOptions =>
      zillas.map((e) => e.displayName).toList(growable: false);

  List<String> get thanaOptions =>
      thanas.map((e) => e.displayName).toList(growable: false);

  Future<void> loadZillas() async {
    if (isLoadingZillas.value) return;
    isLoadingZillas.value = true;

    final result = await ApiErrorHandler.call(
      () => _locationService.fetchAllZillas(),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      zillas.assignAll(result.data!);
    }

    isLoadingZillas.value = false;
  }

  Future<void> onZillaChanged(String? value) async {
    selectedZilla.value = value;
    selectedThana.value = null;
    selectedThanaId.value = null;
    thanas.clear();

    if (value == null || value.trim().isEmpty) {
      selectedZillaId.value = null;
      return;
    }

    final zilla = zillas.firstWhereOrNull((e) => e.displayName == value);
    selectedZillaId.value = zilla?.id;

    if (zilla != null) {
      await loadThanasByZilla(zilla.id);
    }
  }

  void onThanaChanged(String? value) {
    selectedThana.value = value;

    if (value == null || value.trim().isEmpty) {
      selectedThanaId.value = null;
      return;
    }

    final thana = thanas.firstWhereOrNull((e) => e.displayName == value);
    selectedThanaId.value = thana?.id;
  }

  Future<void> loadThanasByZilla(String zillaId) async {
    if (isLoadingThanas.value) return;
    isLoadingThanas.value = true;

    final result = await ApiErrorHandler.call(
      () => _locationService.fetchAllThanasByZilla(zillaId: zillaId),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      thanas.assignAll(result.data!);
    }

    isLoadingThanas.value = false;
  }

  void onAddressContinue() {
    if (addressFormKey.currentState?.validate() != true) return;

    onboardingData.thana = selectedThana.value?.trim();
    onboardingData.zilla = selectedZilla.value?.trim();
    onboardingData.fullAddress = fullAddressController.text.trim();

    Get.toNamed(AppRoutes.signupBrandSocial);
  }

  // ----------------- Step 3 (social links) -----------------
  final socialFormKey = GlobalKey<FormState>();

  final websiteController = TextEditingController();
  final RxnString selectedPlatform = RxnString();
  final profileLinkController = TextEditingController();

  final allowedPlatforms = <String>[].obs;
  final isLoadingPlatforms = false.obs;

  List<String> get platformOptions => allowedPlatforms.toList(growable: false);

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

    // Convert SocialLink to BrandSocialLink
    onboardingData.socialLinks = socialLinks
        .map(
          (link) =>
              BrandSocialLink(platform: link.platform, link: link.profileUrl),
        )
        .toList();

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

  Future<void> onKycSkip() async {
    if (isUploadingNid.value) return;
    Get.toNamed(AppRoutes.signupBrandTradeLicense);
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
          module: 'brand-kyc',
        );
        onboardingData.nidFrontImg = frontUrl;
      }

      if (nidBackPath.value != null) {
        final backUrl = await _uploadFile(
          filePath: nidBackPath.value!,
          module: 'brand-kyc',
        );
        onboardingData.nidBackImg = backUrl;
      }
      return true;
    });

    isUploadingNid.value = false;

    if (result.isSuccess) {
      Get.toNamed(AppRoutes.signupBrandTradeLicense);
    }
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
          module: 'brand-trade-license',
        );
        onboardingData.tradeLicenseImg = tradeLicenseUrl;
      }
      return true;
    });

    isUploadingTradeLicense.value = false;

    if (result.isSuccess) {
      Get.toNamed(AppRoutes.signupBrandTin);
    }
  }

  Future<void> onTradeLicenseSkip() async {
    if (isUploadingTradeLicense.value) return;
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

  Future<void> onTinSkip() async {
    if (isUploadingTin.value || isFinishing.value) return;
    await finishSignup();
  }

  Future<void> onTinContinue() async {
    if (tinFormKey.currentState?.validate() != true) return;
    if (isFinishing.value) return;

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
          module: 'brand-tin',
        );
        onboardingData.tinImage = tinUrl;
      }
      return true;
    });

    isUploadingTin.value = false;

    if (result.isSuccess) {
      finishSignup();
    }
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

  Future<void> _loadPlatforms() async {
    if (allowedPlatforms.isNotEmpty || isLoadingPlatforms.value) return;
    isLoadingPlatforms.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchPlatforms(),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      allowedPlatforms.assignAll(result.data!);
    }
    isLoadingPlatforms.value = false;
  }

  // ----------------- Final Submission -----------------

  /// Collect all data and submit brand onboarding
  Future<void> finishSignup() async {
    if (isFinishing.value) return;
    isFinishing.value = true;

    // Collect data before navigation (in case controllers get disposed)
    final brandName = brandNameController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    final result = await ApiErrorHandler.call(() async {
      await _onboardingService.updateBasicInfo(
        brandName: brandName,
        firstName: firstName,
        lastName: lastName,
      );

      final request = BrandOnboardingRequest(
        thana: onboardingData.thana,
        zilla: onboardingData.zilla,
        fullAddress: onboardingData.fullAddress,
        website: onboardingData.website,
        socialLinks: onboardingData.socialLinks,
        nidNumber: onboardingData.nidNumber,
        nidFrontImg: onboardingData.nidFrontImg,
        nidBackImg: onboardingData.nidBackImg,
        tradeLicenseNumber: onboardingData.tradeLicenseNumber,
        tradeLicenseImg: onboardingData.tradeLicenseImg,
        tinNumber: onboardingData.tinNumber,
        tinImage: onboardingData.tinImage,
        binNumber: onboardingData.binNumber,
      );

      await _onboardingService.submitOnboarding(request);
      await _registerFcmTokenIfNeeded();
      return true;
    });

    if (!isClosed) {
      isFinishing.value = false;
    }

    if (result.isSuccess) {
      Get.offAllNamed(
        AppRoutes.signupSuccess,
        arguments: {'accountType': AccountType.brand},
      );
    }
  }

  // ----------------- Common navigation -----------------
  void goToLogin() {
    Get.offAllNamed('/login');
  }

  void goBack() {
    Get.back();
  }

  // IMPORTANT: do NOT dispose the TextEditingControllers here
  // because this controller is shared across multiple steps and is permanent.
  // The controllers should remain alive for the entire signup flow.
  @override
  void onClose() {
    // Don't dispose controllers - they're needed across multiple steps
    // Since the controller is permanent, GetX won't automatically dispose it
    // Only call super.onClose() - GetX will handle cleanup if needed
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
