import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

enum ProfileStatus { unverified, verified }

enum VerificationState { unverified, underReview, verified }

class SocialAccount {
  final String platform; // e.g. "Instagram"
  final String iconPath;
  final String handle; // e.g. "@growbig"
  final bool isVerified;

  const SocialAccount({
    required this.platform,
    required this.handle,
    this.isVerified = false,
    required this.iconPath,
  });
}

class ProfileField {
  final String label;
  final String hintText;
  final String value;
  final bool isRequired;

  const ProfileField({
    required this.label,
    required this.value,
    this.isRequired = false,
    required this.hintText,
  });
}

class VerificationInprogressItem {
  final String title;
  final VerificationState state;

  const VerificationInprogressItem({required this.title, required this.state});
}

class PayoutMethod {
  final String? bankName;
  final String? accountName;
  final String? accountNo;
  final String? routingNumber;

  final String? bKashNo;
  final String? bKashName;
  final String? bKashAccountType;
  final bool isApproved;

  final bool isBank;

  const PayoutMethod.bank({
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.routingNumber,
    this.isApproved = false,
  }) : bKashNo = '',
       bKashName = '',
       bKashAccountType = '',
       isBank = true;

  const PayoutMethod.bKash({
    required this.bKashNo,
    required this.bKashName,
    required this.bKashAccountType,
    this.isApproved = false,
  }) : bankName = '',
       accountName = '',
       accountNo = '',
       routingNumber = '',
       isBank = false;
}

class ProfileController extends GetxController {
  // ---------------------------------------------------------------------------
  // BASIC PROFILE STATE
  // ---------------------------------------------------------------------------

  final profileStatus = ProfileStatus.verified.obs;

  final profileName = 'Grow Big'.obs;
  final profileLocation = 'Dhaka, Bangladesh'.obs;
  final profileRating = 4.5.obs;
  final profileRatingCount = 32.obs;

  // Between 0.0 – 1.0
  final profileCompletion = 0.35.obs;

  // Text values
  final bioText = ''.obs;
  final serviceFeeText = '15'.obs; // "15%" when filled

  // ---------------------------------------------------------------------------
  // EXPANSION STATE
  // ---------------------------------------------------------------------------

  final bioExpanded = true.obs;
  final serviceFeeExpanded = true.obs;
  final socialExpanded = true.obs;
  final nicheExpanded = true.obs;
  final settingsExpanded = true.obs;
  final verificationExpanded = true.obs;
  final payoutExpanded = true.obs;

  // ---------------------------------------------------------------------------
  // SECTION DATA
  // ---------------------------------------------------------------------------

  final socialAccounts = <SocialAccount>[].obs;
  final niches = <String>[].obs;
  final profileFields = <ProfileField>[].obs;
  final verificationInprogressItems = <VerificationInprogressItem>[].obs;
  final payoutMethods = <PayoutMethod>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockDataForUnverified(); // change this to _loadMockDataForVerified() to see the other state
  }

  @override
  void onClose() {
    nidNumberController.dispose();
    tradeNumberController.dispose();
    tinNumberController.dispose();
    binNumberController.dispose();
    bankNameController.dispose();
    accountHolderNameController.dispose();
    bankAccountNumberController.dispose();
    routingNumberController.dispose();
    bKashNoController.dispose();
    bKashHolderNameController.dispose();
    bKashAccountTypeController.dispose();
    super.onClose();
  }

  /// Dropdown options
  final thanaList = ['Rampura', 'Banani', 'Dhanmondi', 'Uttara', 'Mirpur'];

  final zillaList = ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi'];

  /// Selected values
  final selectedThana = Rx<String?>(null);
  final selectedZilla = Rx<String?>(null);

  void setThana(String? value) {
    selectedThana.value = value;
  }

  void setZilla(String? value) {
    selectedZilla.value = value;
  }

  // Verification Controllers
  final nidNumberController = TextEditingController();
  final Rx<File?> nidFrontPic = Rx<File?>(null);
  final Rx<File?> nidBackPic = Rx<File?>(null);
  final tradeNumberController = TextEditingController();
  final Rx<File?> tradeLicensePic = Rx<File?>(null);
  final tinNumberController = TextEditingController();
  final Rx<File?> tinCertificatePic = Rx<File?>(null);
  final binNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  static const int MAX_FILE_SIZE_BYTES = 2097152;

  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        File selectedFile = File(image.path);

        int fileSize = await selectedFile.length();
        double fileSizeMB = fileSize / 1048576;

        if (fileSize > MAX_FILE_SIZE_BYTES) {
          debugPrint(
            "The selected image is ${fileSizeMB.toStringAsFixed(2)}MB. Please select an image smaller than 2MB.",
          );
          // Get.snackbar(
          //   "⚠️ Image Too Large",
          //   "The selected image is ${fileSizeMB.toStringAsFixed(2)}MB. Please select an image smaller than 2MB.",
          //   snackPosition: SnackPosition.TOP,
          //   backgroundColor: Get.theme.colorScheme.error,
          //   colorText: Get.theme.colorScheme.onError,
          //   duration: const Duration(seconds: 4),
          // );
          return null;
        }
        return selectedFile;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Failed to pick image: $e");
      // Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  String maskString(String inputString) {
    if (inputString.isEmpty) {
      return '';
    }

    int length = inputString.length;

    if (length <= 3) {
      return inputString;
    }

    int charsToMask = length - 3;

    String maskedPart = List.filled(charsToMask, '*').join();
    String unmaskedPart = inputString.substring(length - 3);

    return maskedPart + unmaskedPart;
  }

  final RxString selectedAccountType = 'Bank'.obs;
  final RxBool showNewPayoutAccountForm = false.obs;

  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController bankAccountNumberController =
      TextEditingController();
  final TextEditingController routingNumberController = TextEditingController();

  final TextEditingController bKashNoController = TextEditingController();
  final TextEditingController bKashHolderNameController =
      TextEditingController();
  final TextEditingController bKashAccountTypeController =
      TextEditingController();

  final List<String> accountTypes = ['Bank', 'bKash'];

  void changeAccountType(String? newValue) {
    if (newValue != null && accountTypes.contains(newValue)) {
      selectedAccountType.value = newValue;
      _clearAllFields();
    }
  }

  void _clearAllFields() {
    bankNameController.clear();
    accountHolderNameController.clear();
    bankAccountNumberController.clear();
    routingNumberController.clear();
    bKashNoController.clear();
    bKashHolderNameController.clear();
    bKashAccountTypeController.clear();
  }

  // Example method to simulate form submission
  void submitNewPayoutForm() {
    if (selectedAccountType.value == 'Bank') {
      payoutMethods.add(
        PayoutMethod.bank(
          bankName: bankNameController.text.trim(),
          accountName: accountHolderNameController.text.trim(),
          accountNo: bankAccountNumberController.text.trim(),
          routingNumber: routingNumberController.text.trim(),
        ),
      );
    } else if (selectedAccountType.value == 'bKash') {
      payoutMethods.add(
        PayoutMethod.bKash(
          bKashNo: bKashNoController.text.trim(),
          bKashName: bKashHolderNameController.text.trim(),
          bKashAccountType: bKashAccountTypeController.text.trim(),
        ),
      );
    }
    showNewPayoutAccountForm.value = false;
  }

  // ---------------------------------------------------------------------------
  // MOCK DATA FOR TWO STATES
  // ---------------------------------------------------------------------------

  void _loadMockDataForUnverified() {
    profileStatus.value = ProfileStatus.unverified;
    profileCompletion.value = 0.35;
    bioText.value = '';
    serviceFeeText.value = '';

    socialAccounts.assignAll(const [
      SocialAccount(
        platform: 'Instagram',
        iconPath: 'assets/icons/Instagram_outline.png',
        handle: '@growbig',
        isVerified: false,
      ),
      SocialAccount(
        platform: 'YouTube',
        iconPath: 'assets/icons/youtube_outline.png',
        handle: 'gb_grow',
        isVerified: false,
      ),
      SocialAccount(
        platform: 'TikTok',
        iconPath: 'assets/icons/tiktok_outline.png',
        handle: '@grow_it',
        isVerified: false,
      ),
    ]);

    niches.assignAll(const ['Lifestyle', 'Fashion', 'Tech & Gadgets']);

    profileFields.assignAll(const [
      ProfileField(
        label: 'Agency Name',
        hintText: 'Enter Agency Name',
        value: '',
        isRequired: true,
      ),
      ProfileField(
        label: 'First Name',
        hintText: 'Enter First Name',
        value: '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Last Name',
        hintText: 'Enter Last Name',
        value: '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Full Address',
        hintText: 'Enter Full Address',
        value: '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Email Address',
        hintText: 'Enter Email Address',
        value: '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Phone Number',
        hintText: 'Enter Phone Number',
        value: '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Secondary Phone Number (Optional)',
        hintText: 'Enter Secondary Phone Number',
        value: '',
        isRequired: false,
      ),
    ]);

    verificationInprogressItems.assignAll(const [
      VerificationInprogressItem(
        title: 'Social Profile Verification',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Phone No. Verification',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Payment Setup',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'NID',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Trade License',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'TIN',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'BIN',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Email',
        state: VerificationState.unverified,
      ),
    ]);

    payoutMethods.assignAll(const [
      PayoutMethod.bank(
        bankName: 'DBBL',
        accountName: 'Bank Account No.1',
        accountNo: '123456987859',
        routingNumber: '123456',
        isApproved: true,
      ),
      PayoutMethod.bKash(
        bKashNo: '+8801234567890',
        bKashName: 'Hania Amir',
        bKashAccountType: 'Personal',
        isApproved: true,
      ),
      PayoutMethod.bank(
        bankName: 'DBBL',
        accountName: 'Bank Account No.1',
        accountNo: '123456987859',
        routingNumber: '123456',
        isApproved: false,
      ),
    ]);
  }

  void _loadMockDataForVerified() {
    profileStatus.value = ProfileStatus.verified;
    profileCompletion.value = 1.0;
    bioText.value =
        'I\'m a lifestyle & fashion influencer helping brands grow with authentic content across multiple social platforms.';
    serviceFeeText.value = '15%';

    socialAccounts.assignAll(const [
      SocialAccount(
        platform: 'Instagram',
        iconPath: 'assets/icons/Instagram_outline.png',
        handle: '@growbig',
        isVerified: false,
      ),
      SocialAccount(
        platform: 'YouTube',
        iconPath: 'assets/icons/youtube_outline.png',
        handle: 'gb_grow',
        isVerified: false,
      ),
      SocialAccount(
        platform: 'TikTok',
        iconPath: 'assets/icons/tiktok_outline.png',
        handle: '@grow_it',
        isVerified: false,
      ),
    ]);

    niches.assignAll(const [
      'Lifestyle',
      'Fashion',
      'Tech & Gadgets',
      'Fitness',
    ]);

    profileFields.assignAll(const [
      ProfileField(
        label: 'Agency Name',
        hintText: 'Enter Agency Name',
        value: 'Grow Big Media',
        isRequired: true,
      ),
      ProfileField(
        label: 'First Name',
        hintText: 'Enter First Name',
        value: 'Riaz Uddin',
        isRequired: true,
      ),
      ProfileField(
        label: 'Last Name',
        hintText: 'Enter Last Name',
        value: 'Emon',
        isRequired: true,
      ),
      ProfileField(
        label: 'Full Address',
        hintText: 'Enter Full Address',
        value: 'Dhanmondi, Dhaka, Bangladesh',
        isRequired: true,
      ),
      ProfileField(
        label: 'Email Address',
        hintText: 'Enter Email Address',
        value: 'hello@growbig.com',
        isRequired: true,
      ),
      ProfileField(
        label: 'Phone Number',
        hintText: 'Enter Phone Number',
        value: '+880 1700 000 000',
        isRequired: true,
      ),
      ProfileField(
        label: 'Secondary Phone Number (Optional)',
        hintText: 'Enter Secondary Phone Number',
        value: '',
        isRequired: false,
      ),
    ]);

    verificationInprogressItems.assignAll(const [
      VerificationInprogressItem(
        title: 'Social Profile Verification',
        state: VerificationState.verified,
      ),
      VerificationInprogressItem(
        title: 'Phone No. Verification',
        state: VerificationState.verified,
      ),
      VerificationInprogressItem(
        title: 'Payment Setup',
        state: VerificationState.underReview,
      ),
      VerificationInprogressItem(
        title: 'NID',
        state: VerificationState.underReview,
      ),
      VerificationInprogressItem(
        title: 'Trade License',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'TIN',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'BIN',
        state: VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Email',
        state: VerificationState.unverified,
      ),
    ]);

    payoutMethods.assignAll(const [
      PayoutMethod.bank(
        bankName: 'DBBL',
        accountName: 'Bank Account No.1',
        accountNo: '123456987859',
        routingNumber: '123456',
        isApproved: true,
      ),
      PayoutMethod.bKash(
        bKashNo: '+8801234567890',
        bKashName: 'Hania Amir',
        bKashAccountType: 'Personal',
        isApproved: true,
      ),
      PayoutMethod.bank(
        bankName: 'DBBL',
        accountName: 'Bank Account No.1',
        accountNo: '123456987859',
        routingNumber: '123456',
        isApproved: false,
      ),
    ]);
  }

  // You can expose this to switch state from outside if needed.
  void setProfileStatus(ProfileStatus status) {
    if (status == ProfileStatus.verified) {
      _loadMockDataForVerified();
    } else {
      _loadMockDataForUnverified();
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  bool get isVerified => profileStatus.value == ProfileStatus.verified;

  String get profileStatusLabel => isVerified ? 'Verified' : 'Unverified';

  String verificationLabel(VerificationState state) {
    switch (state) {
      case VerificationState.unverified:
        return 'Unverified';
      case VerificationState.underReview:
        return 'Under Review';
      case VerificationState.verified:
        return 'Verified';
    }
  }

  Color verificationColor(VerificationState state) {
    switch (state) {
      case VerificationState.unverified:
        return AppPalette.subtext; // grey
      case VerificationState.underReview:
        return AppPalette.complemetary; // orange
      case VerificationState.verified:
        return AppPalette.secondary; // green
    }
  }

  // Expansion togglers
  void toggleBio() => bioExpanded.toggle();
  void toggleServiceFee() => serviceFeeExpanded.toggle();
  void toggleSocial() => socialExpanded.toggle();
  void toggleNiche() => nicheExpanded.toggle();
  void toggleSettings() => settingsExpanded.toggle();
  void toggleVerification() => verificationExpanded.toggle();
  void togglePayout() => payoutExpanded.toggle();
}
