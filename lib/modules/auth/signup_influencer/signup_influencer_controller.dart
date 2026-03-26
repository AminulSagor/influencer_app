import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influencer_app/core/utils/bd_phone_input_formatter.dart';
import 'package:path/path.dart' as path;

import '../../../core/enums/account_type.dart';
import '../../../core/models/location_models.dart';
import '../../../core/models/social_link.dart';
import '../../../core/services/account_type_service.dart';
import '../../../core/services/auth_services.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/location_service.dart';
import '../../../routes/app_routes.dart';

import '../../ad_agency/services/upload_service.dart';
import '../../influencer/models/influencer_onboarding_model.dart';
import '../../influencer/services/influencer_onboarding_services.dart';

class SignupInfluencerController extends GetxController {
  // ----------------- Services -----------------
  final AccountTypeService accountTypeService = Get.find<AccountTypeService>();
  final AuthService _authService = Get.find<AuthService>();
  final InfluencerOnboardingService _onboardingService =
      Get.find<InfluencerOnboardingService>();
  final UploadService _uploadService = Get.find<UploadService>();

  final isSubmitting = false.obs;
  final isUploadingNid = false.obs;

  final LocationService _locationService = Get.find<LocationService>();

  // ----------------- Aggregated Onboarding Data -----------------
  final InfluencerOnboardingModel onboardingData = InfluencerOnboardingModel();

  // ----------------- Step 1 (basic info) -----------------
  final formKey = GlobalKey<FormState>();

  final brandNameController =
      TextEditingController(); // (unused for influencer)
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController(); // ✅ required

  @override
  void onInit() {
    super.onInit();
    if (phoneController.text.trim().isEmpty) {
      phoneController.text = '+88 ';
    }
    loadZillas();
  }

  Future<void> onStep1Continue() async {
    if (isSubmitting.value) return;

    if (formKey.currentState?.validate() != true) return;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = BdPhoneInputFormatter().toApiPhone(phoneController.text);
    final password = passwordController.text;

    isSubmitting.value = true;

    final result = await ApiErrorHandler.call(
      () => _authService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        role: 'influencer',
      ),
    );

    isSubmitting.value = false;

    if (result.isSuccess) {
      accountTypeService.setRole(AccountType.influencer);
      Get.toNamed(
        AppRoutes.verification,
        arguments: {
          'phone': result.data!.phone,
          'accountType': AccountType.influencer,
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

    onboardingData.fullAddress = fullAddressController.text.trim();
    onboardingData.thana = selectedThana.value;
    onboardingData.zilla = selectedZilla.value;

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

    onboardingData.website = websiteController.text.trim().isEmpty
        ? null
        : websiteController.text.trim();

    // ✅ freeze snapshot
    onboardingData.socialLinks = List<SocialLink>.from(socialLinks);

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
    if (file != null) nidFrontPath.value = file.path;
  }

  Future<void> pickNidBack() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
    );
    if (file != null) nidBackPath.value = file.path;
  }

  Future<void> onKycSkip() async {
    if (isSubmitting.value || isUploadingNid.value) return;

    isSubmitting.value = true;

    final result = await ApiErrorHandler.call(
      () => _onboardingService.submitOnboarding(onboardingData),
    );

    isSubmitting.value = false;

    if (result.isSuccess) {
      Get.toNamed(
        AppRoutes.signupSuccess,
        arguments: {'accountType': AccountType.influencer},
      );
    }
  }

  Future<void> onKycSubmit() async {
    if (nidFormKey.currentState?.validate() != true) return;
    if (isSubmitting.value || isUploadingNid.value) return;

    // Save NID number
    onboardingData.nidNumber = nidNumberController.text.trim().isEmpty
        ? null
        : nidNumberController.text.trim();

    // Upload NID images if provided
    isUploadingNid.value = true;

    final uploadResult = await ApiErrorHandler.call(() async {
      if (nidFrontPath.value != null) {
        final frontUrl = await _uploadFile(
          filePath: nidFrontPath.value!,
          module: 'influencer-kyc',
        );
        onboardingData.nidFrontImg = frontUrl;
      }

      if (nidBackPath.value != null) {
        final backUrl = await _uploadFile(
          filePath: nidBackPath.value!,
          module: 'influencer-kyc',
        );
        onboardingData.nidBackImg = backUrl;
      }
      return true;
    });

    isUploadingNid.value = false;

    if (!uploadResult.isSuccess) return;

    // Submit onboarding data
    isSubmitting.value = true;

    final result = await ApiErrorHandler.call(
      () => _onboardingService.submitOnboarding(onboardingData),
    );

    isSubmitting.value = false;

    if (result.isSuccess) {
      Get.toNamed(
        AppRoutes.signupSuccess,
        arguments: {'accountType': AccountType.influencer},
      );
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

  // ----------------- Navigation helpers -----------------
  void goToLogin() => Get.offAllNamed(AppRoutes.login);
  void goBack() => Get.back();

  @override
  void onClose() {
    brandNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    fullAddressController.dispose();
    websiteController.dispose();
    profileLinkController.dispose();

    nidNumberController.dispose();
    super.onClose();
  }
}
