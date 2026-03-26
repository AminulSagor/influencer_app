import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../enums/account_type.dart';
import 'api_client.dart';
import 'api_error_handler.dart';
import 'account_type_service.dart';

/// Represents the onboarding/verification status for a user
class OnboardingStatus {
  /// Whether the user has completed the mandatory onboarding steps
  /// This is set by the backend based on required fields
  final bool isOnboardingComplete;

  /// Individual verification step statuses (for display in locked views)
  final bool hasAddress;
  final bool hasSocialLinks;
  final bool hasNidSubmitted;
  final String? nidStatus; // 'pending', 'approved', 'rejected'
  final bool hasPayoutSetup;
  final bool isEmailVerified;

  // Brand/Agency specific
  final bool hasTradeLicense;
  final String? tradeLicenseStatus;
  final bool hasTin;
  final String? tinStatus;
  final bool hasBin;
  final String? binStatus;

  // Profile completion (optional, not required for unlock)
  final bool hasProfileImage;
  final bool hasNiches;
  final bool hasSkills;
  final bool hasBio;

  const OnboardingStatus({
    required this.isOnboardingComplete,
    this.hasAddress = false,
    this.hasSocialLinks = false,
    this.hasNidSubmitted = false,
    this.nidStatus,
    this.hasPayoutSetup = false,
    this.isEmailVerified = false,
    this.hasTradeLicense = false,
    this.tradeLicenseStatus,
    this.hasTin = false,
    this.tinStatus,
    this.hasBin = false,
    this.binStatus,
    this.hasProfileImage = false,
    this.hasNiches = false,
    this.hasSkills = false,
    this.hasBio = false,
  });

  /// Quick check if dashboard should be locked
  bool get isDashboardLocked => !isOnboardingComplete;

  /// Calculate verification progress (0.0 - 1.0) for Influencer
  double get influencerVerificationProgress {
    int completed = 0;
    int total = 5; // address, social, NID, payout, email

    if (hasAddress) completed++;
    if (hasSocialLinks) completed++;
    if (hasNidSubmitted && nidStatus != 'rejected') completed++;
    if (hasPayoutSetup) completed++;
    if (isEmailVerified) completed++;

    return completed / total;
  }

  /// Calculate verification progress for Brand/Agency
  double get brandAgencyVerificationProgress {
    int completed = 0;
    int total = 8; // address, social, NID, trade, TIN, BIN, payout, email

    if (hasAddress) completed++;
    if (hasSocialLinks) completed++;
    if (hasNidSubmitted && nidStatus != 'rejected') completed++;
    if (hasTradeLicense && tradeLicenseStatus != 'rejected') completed++;
    if (hasTin && tinStatus != 'rejected') completed++;
    if (hasBin && binStatus != 'rejected') completed++;
    if (hasPayoutSetup) completed++;
    if (isEmailVerified) completed++;

    return completed / total;
  }

  /// Calculate profile completion progress (optional steps)
  double get profileProgress {
    int completed = 0;
    int total = 4; // image, niches, skills, bio

    if (hasProfileImage) completed++;
    if (hasNiches) completed++;
    if (hasSkills) completed++;
    if (hasBio) completed++;

    return completed / total;
  }

  factory OnboardingStatus.fromInfluencerJson(Map<String, dynamic> json) {
    final addresses = json['addresses'] as List?;
    final socialLinks = json['socialLinks'] as List?;
    final niches = json['niches'] as List?;
    final skills = json['skills'] as List?;
    final payouts = json['payouts'] as Map<String, dynamic>?;
    final nidVerification = json['nidVerification'] as Map<String, dynamic>?;

    bool hasPayout = false;
    if (payouts != null) {
      final banks = payouts['bank'] as List?;
      final mobile = payouts['mobileBanking'] as List?;
      hasPayout =
          (banks != null && banks.isNotEmpty) ||
          (mobile != null && mobile.isNotEmpty);
    }

    // Backend may use 'isOnboardingComplete' or 'isVerified' - check both
    final isComplete =
        json['isOnboardingComplete'] as bool? ??
        json['isVerified'] as bool? ??
        false;

    return OnboardingStatus(
      isOnboardingComplete: isComplete,
      hasAddress: addresses != null && addresses.isNotEmpty,
      hasSocialLinks: socialLinks != null && socialLinks.isNotEmpty,
      hasNidSubmitted:
          json['nidNumber'] != null && (json['nidNumber']).isNotEmpty,
      nidStatus: nidVerification?['status'],
      hasPayoutSetup: hasPayout,
      isEmailVerified: json['isEmailVerified'] ?? false,
      hasProfileImage:
          json['profileImage'] != null && (json['profileImage']).isNotEmpty,
      hasNiches: niches != null && niches.isNotEmpty,
      hasSkills: skills != null && skills.isNotEmpty,
      hasBio: json['bio'] != null && (json['bio']).isNotEmpty,
    );
  }

  factory OnboardingStatus.fromBrandJson(Map<String, dynamic> json) {
    final addresses = json['addresses'] as List?;
    final socialLinks = json['socialLinks'] as List?;
    final niches = json['niches'] as List?;
    final skills = json['skills'] as List?;
    final payouts = json['payouts'] as Map<String, dynamic>?;
    final nidVerification = json['nidVerification'] as Map<String, dynamic>?;
    final tradeLicenseVerification =
        json['tradeLicenseVerification'] as Map<String, dynamic>?;
    final tinVerification = json['tinVerification'] as Map<String, dynamic>?;
    final binVerification = json['binVerification'] as Map<String, dynamic>?;

    bool hasPayout = false;
    if (payouts != null) {
      final banks = payouts['bank'] as List?;
      final mobile = payouts['mobileBanking'] as List?;
      hasPayout =
          (banks != null && banks.isNotEmpty) ||
          (mobile != null && mobile.isNotEmpty);
    }

    // Backend may use 'isOnboardingComplete' or 'isVerified' - check both
    final isComplete =
        json['isOnboardingComplete'] as bool? ??
        json['isVerified'] as bool? ??
        false;

    return OnboardingStatus(
      isOnboardingComplete: isComplete,
      hasAddress: addresses != null && addresses.isNotEmpty,
      hasSocialLinks: socialLinks != null && socialLinks.isNotEmpty,
      hasNidSubmitted:
          json['nidNumber'] != null && (json['nidNumber']).isNotEmpty,
      nidStatus: nidVerification?['nidStatus'],
      hasPayoutSetup: hasPayout,
      isEmailVerified: json['isEmailVerified'] ?? false,
      hasTradeLicense:
          json['tradeLicenseNumber'] != null &&
          (json['tradeLicenseNumber']).isNotEmpty,
      tradeLicenseStatus: tradeLicenseVerification?['tradeLicenseStatus'],
      hasTin: json['tinNumber'] != null && (json['tinNumber']).isNotEmpty,
      tinStatus: tinVerification?['tinStatus'],
      hasBin: json['binNumber'] != null && (json['binNumber']).isNotEmpty,
      binStatus: binVerification?['binStatus'],
      hasProfileImage:
          json['profileImage'] != null && (json['profileImage']).isNotEmpty,
      hasNiches: niches != null && niches.isNotEmpty,
      hasSkills: skills != null && skills.isNotEmpty,
      hasBio: json['bio'] != null && (json['bio']).isNotEmpty,
    );
  }

  factory OnboardingStatus.fromAgencyJson(Map<String, dynamic> json) {
    // Agency uses the same structure as Brand
    return OnboardingStatus.fromBrandJson(json);
  }
}

/// Service to check and manage onboarding status
class OnboardingCheckService extends GetxService {
  late final ApiClient _api;

  /// Current onboarding status (reactive)
  final Rxn<OnboardingStatus> status = Rxn<OnboardingStatus>();

  /// Whether the status is being loaded
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  /// Quick check if dashboard is locked
  bool get isDashboardLocked => status.value?.isDashboardLocked ?? true;

  /// Check if onboarding is complete
  bool get isOnboardingComplete => status.value?.isOnboardingComplete ?? false;

  /// Fetches onboarding status from the API based on account type
  Future<bool> fetchOnboardingStatus() async {
    final accountType = Get.find<AccountTypeService>().currentType;
    if (accountType == null) return false;

    isLoading.value = true;

    String endpoint;
    switch (accountType) {
      case AccountType.influencer:
        endpoint = '/influencer/profile';
      case AccountType.brand:
        endpoint = '/client/profile';
      case AccountType.adAgency:
        endpoint = '/agency/profile';
    }

    final result = await ApiErrorHandler.call<Map<String, dynamic>>(
      () async {
        final res = await _api.dio.get(endpoint);
        return res.data as Map<String, dynamic>;
      },
      showError: false, // Don't show error snackbar for profile fetch
    );

    if (result.isSuccess && result.data != null) {
      final isComplete = result.data!['isOnboardingComplete'] as bool? ?? false;

      // Debug: Print profile response (for onboarding progress tracking only, not lock status)
      debugPrint('🔍 PROFILE API RESPONSE ($endpoint):');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('  isOnboardingComplete: $isComplete');
      debugPrint('  (Note: Lock status is based on JWT isVerified, not this)');
      debugPrint('═══════════════════════════════════════════════════════════');

      switch (accountType) {
        case AccountType.influencer:
          status.value = OnboardingStatus.fromInfluencerJson(result.data!);
        case AccountType.brand:
          status.value = OnboardingStatus.fromBrandJson(result.data!);
        case AccountType.adAgency:
          status.value = OnboardingStatus.fromAgencyJson(result.data!);
      }
    } else {
      // API failed - log error and explain why dashboard will be locked
      debugPrint('❌ PROFILE API FAILED:');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('  Endpoint: $endpoint');
      debugPrint('  Error: ${result.error}');
      debugPrint(
        '  ⚠️ Dashboard will be LOCKED because profile could not be fetched',
      );
      debugPrint('═══════════════════════════════════════════════════════════');
    }

    isLoading.value = false;
    return status.value?.isOnboardingComplete ?? false;
  }

  /// Clears the status (call on logout)
  void clear() {
    status.value = null;
  }
}
