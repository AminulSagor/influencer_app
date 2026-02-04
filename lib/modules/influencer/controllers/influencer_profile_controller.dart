import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../models/influencer_profile_model.dart';
import '../services/influencer_profile_service.dart';

/// Controller for managing influencer profile data and operations
class InfluencerProfileController extends GetxController {
  late final InfluencerProfileService _profileService;

  // Profile data
  final Rxn<InfluencerProfile> profile = Rxn<InfluencerProfile>();

  // Loading states
  final isLoading = false.obs;
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _profileService = InfluencerProfileService(Get.find<ApiClient>());
  }

  @override
  void onReady() {
    super.onReady();
    fetchProfile();
  }

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------

  bool get hasProfile => profile.value != null;
  String get fullName => profile.value?.fullName ?? '';
  String get displayImage => profile.value?.displayImage ?? '';
  bool get isOnboardingComplete => profile.value?.isOnboardingComplete ?? false;
  List<InfluencerNiche> get niches => profile.value?.niches ?? [];
  List<InfluencerSkill> get skills => profile.value?.skills ?? [];
  List<InfluencerSocialLink> get socialLinks =>
      profile.value?.socialLinks ?? [];
  List<InfluencerAddress> get addresses => profile.value?.addresses ?? [];
  InfluencerPayouts? get payouts => profile.value?.payouts;

  // Verification status
  bool get isNidPending => profile.value?.nidVerification?.status == 'pending';
  bool get isNidApproved =>
      profile.value?.nidVerification?.status == 'approved';
  bool get isNidRejected =>
      profile.value?.nidVerification?.status == 'rejected';

  // Profile completion checklist
  bool get hasProfileImage =>
      profile.value?.profileImage != null &&
      profile.value!.profileImage!.isNotEmpty;
  bool get hasNiches => niches.isNotEmpty;
  bool get hasSkills => skills.isNotEmpty;
  bool get hasBio =>
      profile.value?.bio != null && profile.value!.bio!.isNotEmpty;
  bool get hasSocialLinks => socialLinks.isNotEmpty;
  bool get hasPayoutSetup => payouts != null && payouts!.isNotEmpty;

  double get profileCompletionPercentage {
    int completed = 0;
    int total = 5;

    if (hasProfileImage) completed++;
    if (hasNiches) completed++;
    if (hasSkills) completed++;
    if (hasBio) completed++;
    if (hasSocialLinks) completed++;

    return completed / total;
  }

  // ---------------------------------------------------------------------------
  // API METHODS
  // ---------------------------------------------------------------------------

  /// Fetches the current influencer profile
  Future<void> fetchProfile() async {
    isLoading.value = true;

    final result = await _profileService.getProfile();

    if (result.isSuccess && result.data != null) {
      profile.value = result.data;
    }

    isLoading.value = false;
  }

  /// Updates basic info (name, bio, profile image)
  Future<bool> updateBasicInfo({
    String? firstName,
    String? lastName,
    String? bio,
    String? profileImage,
  }) async {
    isUpdating.value = true;

    final result = await _profileService.updateBasicInfo(
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      profileImage: profileImage,
    );

    if (result.isSuccess && result.data != null) {
      profile.value = result.data;
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Removes profile image
  Future<bool> removeProfileImage() async {
    isUpdating.value = true;

    final result = await _profileService.removeProfileImage();

    if (result.isSuccess) {
      // Refresh profile to get updated data
      await fetchProfile();
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Updates niches
  Future<bool> updateNiches(List<String> newNiches) async {
    isUpdating.value = true;

    final result = await _profileService.updateNiches(newNiches);

    if (result.isSuccess && result.data != null) {
      profile.value = result.data;
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Removes a specific niche
  Future<bool> removeNiche(String nicheName) async {
    isUpdating.value = true;

    final result = await _profileService.removeNiche(nicheName);

    if (result.isSuccess) {
      await fetchProfile();
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Updates skills
  Future<bool> updateSkills(List<String> newSkills) async {
    isUpdating.value = true;

    final result = await _profileService.updateSkills(newSkills);

    if (result.isSuccess && result.data != null) {
      profile.value = result.data;
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Adds a new address
  Future<bool> addAddress({
    required String addressName,
    required String thana,
    required String zilla,
    required String fullAddress,
  }) async {
    isUpdating.value = true;

    final result = await _profileService.addAddress(
      addressName: addressName,
      thana: thana,
      zilla: zilla,
      fullAddress: fullAddress,
    );

    if (result.isSuccess && result.data != null) {
      profile.value = result.data;
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Adds a bank payout method
  Future<bool> addBankPayout({
    required String bankName,
    required String accountHolderName,
    required String accountNo,
    required String branchName,
    required String routingNo,
  }) async {
    isUpdating.value = true;

    final result = await _profileService.addBankPayout(
      bankName: bankName,
      accountHolderName: accountHolderName,
      accountNo: accountNo,
      branchName: branchName,
      routingNo: routingNo,
    );

    if (result.isSuccess && result.data != null) {
      profile.value = result.data;
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Adds a mobile banking payout method
  Future<bool> addMobilePayout({
    required String accountType,
    required String accountHolderName,
    required String accountNo,
  }) async {
    isUpdating.value = true;

    final result = await _profileService.addMobilePayout(
      accountType: accountType,
      accountHolderName: accountHolderName,
      accountNo: accountNo,
    );

    if (result.isSuccess && result.data != null) {
      profile.value = result.data;
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Removes a payout method
  Future<bool> removePayout({required String type, required String id}) async {
    isUpdating.value = true;

    final result = await _profileService.removePayout(type: type, id: id);

    if (result.isSuccess) {
      await fetchProfile();
    }

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Updates social links
  Future<bool> updateSocialLinks(List<InfluencerSocialLink> links) async {
    isUpdating.value = true;

    final address = profile.value?.primaryAddress;

    final result = await _profileService.updateSocialLinks(
      links,
      thana: address?.thana,
      zilla: address?.zilla,
      fullAddress: address?.fullAddress,
    );

    if (result.isSuccess && result.data != null) profile.value = result.data;

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Updates website
  Future<bool> updateWebsite(String? website) async {
    isUpdating.value = true;

    final address = profile.value?.primaryAddress;

    final result = await _profileService.updateWebsite(
      website,
      thana: address?.thana,
      zilla: address?.zilla,
      fullAddress: address?.fullAddress,
    );

    if (result.isSuccess && result.data != null) profile.value = result.data;

    isUpdating.value = false;
    return result.isSuccess;
  }

  /// Submits NID verification documents
  Future<bool> submitNidVerification({
    required String nidNumber,
    required String nidFrontImg,
    required String nidBackImg,
  }) async {
    isUpdating.value = true;

    final address = profile.value?.primaryAddress;

    final result = await _profileService.submitNidVerification(
      nidNumber: nidNumber,
      nidFrontImg: nidFrontImg,
      nidBackImg: nidBackImg,
      thana: address?.thana,
      zilla: address?.zilla,
      fullAddress: address?.fullAddress,
    );

    if (result.isSuccess && result.data != null) profile.value = result.data;

    isUpdating.value = false;
    return result.isSuccess;
  }
}

/// Binding for InfluencerProfileController
class InfluencerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InfluencerProfileController>(
      () => InfluencerProfileController(),
    );
  }
}
