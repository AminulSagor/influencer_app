import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/services/token_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_profile_service.dart';
import 'package:influencer_app/modules/ad_agency/services/upload_service.dart';
import 'package:influencer_app/modules/influencer/models/influencer_profile_model.dart';
import 'package:influencer_app/modules/influencer/services/influencer_profile_service.dart';
import 'package:influencer_app/modules/brand/services/brand_onboarding_services.dart';
import 'package:influencer_app/routes/app_routes.dart';

import 'models/brand_asset.dart';
import 'models/user_location.dart';

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
  final bool isReadOnly;

  const ProfileField({
    required this.label,
    required this.value,
    this.isRequired = false,
    this.isReadOnly = false,
    required this.hintText,
  });
}

class VerificationInprogressItem {
  final String title;
  final VerificationState state;

  const VerificationInprogressItem({required this.title, required this.state});
}

class PayoutMethod {
  final String? payoutId;
  final String payoutType;
  final String? bankName;
  final String? accountName;
  final String? accountNo;
  final String? branchName;
  final String? routingNumber;

  final String? bKashNo;
  final String? bKashName;
  final String? bKashAccountType;
  final bool isApproved;

  final bool isBank;

  const PayoutMethod.bank({
    this.payoutId,
    this.payoutType = 'bank',
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.branchName,
    required this.routingNumber,
    this.isApproved = false,
  }) : bKashNo = '',
       bKashName = '',
       bKashAccountType = '',
       isBank = true;

  const PayoutMethod.bKash({
    this.payoutId,
    this.payoutType = 'mobileBanking',
    required this.bKashNo,
    required this.bKashName,
    required this.bKashAccountType,
    this.isApproved = false,
  }) : bankName = '',
       accountName = '',
       accountNo = '',
       branchName = '',
       routingNumber = '',
       isBank = false;
}

class ProfileController extends GetxController {
  final accountTypeService = Get.find<AccountTypeService>();
  final appUserSession = Get.find<AppUserSessionController>();
  final TokenService _tokenService = Get.find<TokenService>();
  // ---------------------------------------------------------------------------
  // BASIC PROFILE STATE
  // ---------------------------------------------------------------------------

  final profileStatus = ProfileStatus.verified.obs;
  final RxnBool _jwtAdminVerified = RxnBool();

  final profileName = ''.obs;
  final profileLocation = 'Dhaka, Bangladesh'.obs;
  final brandName = ''.obs;
  final profileRating = 4.5.obs;
  final profileRatingCount = 32.obs;

  // Between 0.0 – 1.0
  final profileCompletion = 0.35.obs;

  // Text values
  final bioText = ''.obs;
  final serviceFeeText = ''.obs; // "15%" when filled
  final bioController = TextEditingController();

  // Profile image
  final Rx<File?> profileImageFile = Rx<File?>(null);
  final profileImageUrl = ''.obs;

  // From token / profile
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final brandWebsite = ''.obs;

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
  // VERIFICATION FLOW STATE
  // ---------------------------------------------------------------------------

  /// 0 = Profile page, 1 = Verification progress flow
  final verificationPageIndex = 0.obs;

  /// 0 = Progress list, 1 = Email verification, 2 = Email verified success
  final verificationFlowIndex = 0.obs;

  final AuthService _authService = Get.find<AuthService>();
  final RxBool isRequestingEmailOtp = false.obs;
  final RxBool isResendingEmailOtp = false.obs;
  final RxBool isVerifyingEmailOtp = false.obs;

  // ---------------------------------------------------------------------------
  // SECTION DATA
  // ---------------------------------------------------------------------------

  final socialAccounts = <SocialAccount>[].obs;
  final niches = <String>[].obs;
  final RxMap<String, String> nicheStatuses = <String, String>{}.obs;
  final profileFields = <ProfileField>[].obs;
  final verificationInprogressItems = <VerificationInprogressItem>[].obs;
  final payoutMethods = <PayoutMethod>[].obs;

  final RxnString newSocialPlatform = RxnString();
  final TextEditingController newSocialHandleController =
      TextEditingController();
  final TextEditingController newNicheController = TextEditingController();

  final List<String> socialPlatformOptions = const [
    'Instagram',
    'YouTube',
    'TikTok',
    'Facebook',
    'X',
  ];

  // Editable field buffers
  final RxMap<String, String> profileFieldValues = <String, String>{}.obs;
  final RxMap<String, String> socialHandleEdits = <String, String>{}.obs;

  final isSavingProfile = false.obs;

  /// Loading state for profile fetch
  final isLoadingProfile = false.obs;

  /// Current influencer profile (null for brand/agency)
  final Rxn<InfluencerProfile> influencerProfile = Rxn<InfluencerProfile>();

  @override
  void onInit() {
    super.onInit();
    bioController.addListener(_syncBioFromController);
    brandWebsiteController.addListener(_syncBrandWebsiteFromController);
    _setupVerificationMediaUploadWorkers();
    _hydrateOrFetchProfileData();
  }

  Future<void> _hydrateOrFetchProfileData() async {
    isLoadingProfile.value = true;

    await _loadUserFromToken();

    if (appUserSession.isLoaded.value) {
      if (appUserSession.userEmail.value.trim().isNotEmpty) {
        userEmail.value = appUserSession.userEmail.value.trim();
      }
      if (appUserSession.userPhone.value.trim().isNotEmpty) {
        userPhone.value = appUserSession.userPhone.value.trim();
      }

      if (accountTypeService.isInfluencer &&
          appUserSession.influencerProfile.value != null) {
        final profile = appUserSession.influencerProfile.value!;
        influencerProfile.value = profile;
        _populateFromInfluencerProfile(profile);
        isLoadingProfile.value = false;
        return;
      }

      if (accountTypeService.isAdAgency &&
          appUserSession.agencyProfileJson.value != null) {
        _populateFromAgencyJson(appUserSession.agencyProfileJson.value!);
        isLoadingProfile.value = false;
        return;
      }

      if (accountTypeService.isBrand &&
          appUserSession.brandProfileJson.value != null) {
        _populateFromBrandJson(appUserSession.brandProfileJson.value!);
        isLoadingProfile.value = false;
        return;
      }
    }

    await _fetchProfileData();
  }

  /// Fetches profile data from API based on account type
  Future<void> _fetchProfileData() async {
    isLoadingProfile.value = true;

    await _loadUserFromToken();

    if (accountTypeService.isInfluencer) {
      await _fetchInfluencerProfile();
    } else if (accountTypeService.isAdAgency) {
      await _fetchAgencyProfile();
    } else if (accountTypeService.isBrand) {
      await _fetchBrandProfile();
    } else {
      _applyEmptyProfileState();
    }

    isLoadingProfile.value = false;
  }

  // Future<void> _fetchProfileData() async {
  //   try {
  //     await _fetchProfileData();
  //   } catch (e) {
  //     debugPrint('Failed to refresh profile after update: $e');
  //   }
  // }

  /// Fetches influencer profile from API and populates UI fields
  Future<void> _fetchInfluencerProfile() async {
    final service = Get.find<InfluencerProfileService>();
    final result = await service.getProfile();

    if (result.isSuccess && result.data != null) {
      final profile = result.data!;
      influencerProfile.value = profile;

      debugPrint('📋 INFLUENCER PROFILE LOADED:');
      debugPrint('  Name: ${profile.fullName}');
      debugPrint('  isVerified: ${profile.isOnboardingComplete}');

      _populateFromInfluencerProfile(profile);
    } else {
      debugPrint('❌ Failed to load profile: ${result.error}');
      _applyEmptyProfileState();
    }
  }

  /// Populates controller fields from InfluencerProfile data
  void _populateFromInfluencerProfile(InfluencerProfile profile) {
    // Basic info
    profileName.value = profile.fullName.isNotEmpty
        ? profile.fullName
        : 'Influencer';
    _setProfileStatusFromVerification(
      profileIsVerified: profile.isOnboardingComplete,
    );
    _setBioText(profile.bio ?? '');
    profileImageUrl.value = profile.displayImage ?? '';
    profileImageFile.value = null;
    profileRating.value = profile.averageRating;
    profileRatingCount.value = profile.totalReviews;

    if (profile.addresses.isNotEmpty) {
      final primary = profile.primaryAddress ?? profile.addresses.first;
      final locationParts = <String>[
        primary.thana?.trim() ?? '',
        primary.zilla?.trim() ?? '',
        primary.country?.trim() ?? '',
      ].where((part) => part.isNotEmpty).toList(growable: false);
      profileLocation.value = locationParts.isEmpty
          ? 'Dhaka, Bangladesh'
          : locationParts.join(', ');
    } else {
      profileLocation.value = 'Dhaka, Bangladesh';
    }

    appUserSession.influencerProfile.value = profile;
    appUserSession.displayName.value = profileName.value;
    appUserSession.profileImageUrl.value = profileImageUrl.value;

    _hydrateVerificationInputsFromJson(profile.toJson());

    // Calculate profile completion
    int completed = 0;
    int total = 7;
    if (profile.fullName.isNotEmpty) completed++;
    if (profile.bio != null && profile.bio!.isNotEmpty) completed++;
    if (profile.addresses.isNotEmpty) completed++;
    if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty)
      completed++;
    if (profile.niches != null && profile.niches!.isNotEmpty) completed++;
    if (profile.skills != null && profile.skills!.isNotEmpty) completed++;
    if (profile.payouts != null) completed++;
    profileCompletion.value = completed / total;

    // Social accounts
    if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) {
      socialAccounts.assignAll(
        profile.socialLinks!
            .map(
              (link) => SocialAccount(
                platform: _capitalizeFirst(link.platform),
                iconPath: _getIconPathForPlatform(link.platform),
                handle: link.url,
                isVerified: link.isVerified,
              ),
            )
            .toList(),
      );
    } else {
      socialAccounts.clear();
    }
    _syncSocialHandleDefaults();

    // Niches
    if (profile.niches != null && profile.niches!.isNotEmpty) {
      final names = <String>[];
      final statuses = <String, String>{};
      for (final niche in profile.niches!) {
        final name = niche.name.trim();
        if (name.isEmpty) continue;
        names.add(name);
        statuses[name.toLowerCase()] = (niche.status ?? 'pending')
            .toLowerCase()
            .trim();
      }
      niches.assignAll(names);
      nicheStatuses.assignAll(statuses);
    } else {
      niches.clear();
      nicheStatuses.clear();
    }

    // Skills
    if (profile.skills != null && profile.skills!.isNotEmpty) {
      skills.assignAll(profile.skills!.map((s) => s.name).toList());
    } else {
      skills.clear();
    }

    // Locations/Addresses
    if (profile.addresses.isNotEmpty) {
      locations.assignAll(
        profile.addresses
            .map(
              (addr) => UserLocation(
                name: addr.addressName ?? '',
                thana: addr.thana ?? '',
                zilla: addr.zilla ?? '',
                country: addr.country ?? '',
                fullAddress: addr.fullAddress ?? '',
              ),
            )
            .toList(),
      );
    } else {
      locations.clear();
    }

    // Payout methods
    if (profile.payouts != null) {
      final List<PayoutMethod> methods = [];

      for (final bank in profile.payouts!.bankAccounts) {
        methods.add(
          PayoutMethod.bank(
            payoutId: bank.id,
            bankName: bank.bankName,
            accountName: bank.bankAccHolderName,
            accountNo: bank.bankAccNo,
            branchName: bank.bankBranchName ?? '',
            routingNumber: bank.bankRoutingNo ?? '',
            isApproved: bank.isApproved,
          ),
        );
      }

      for (final mobile in profile.payouts!.mobileAccounts) {
        methods.add(
          PayoutMethod.bKash(
            payoutId: mobile.id,
            bKashNo: mobile.accountNo,
            bKashName: mobile.accountHolderName,
            bKashAccountType: mobile.accountType,
            isApproved: mobile.isApproved,
          ),
        );
      }

      payoutMethods.assignAll(methods);
    } else {
      payoutMethods.clear();
    }

    // Verification status
    verificationInprogressItems.assignAll([
      VerificationInprogressItem(
        title: 'Social Profile Verification',
        state:
            (profile.socialLinks != null &&
                profile.socialLinks!.any((s) => s.isVerified))
            ? VerificationState.verified
            : (profile.socialLinks != null && profile.socialLinks!.isNotEmpty)
            ? VerificationState.underReview
            : VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Payment Setup',
        state: profile.payouts != null
            ? VerificationState.verified
            : VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'NID',
        state: _getNidVerificationState(profile),
      ),
      VerificationInprogressItem(
        title: 'Email',
        state: VerificationState.verified, // Email is verified during signup
      ),
    ]);

    // Profile fields
    final nidStatusValue = profile.nidVerification?.status?.trim();
    final nidStatusLabel = (nidStatusValue != null && nidStatusValue.isNotEmpty)
        ? _capitalizeFirst(nidStatusValue)
        : (profile.hasNidSubmitted ? 'Pending' : 'Not Submitted');

    profileFields.assignAll([
      ProfileField(
        label: 'First Name',
        hintText: 'Enter First Name',
        value: profile.firstName,
        isRequired: true,
      ),
      ProfileField(
        label: 'Last Name',
        hintText: 'Enter Last Name',
        value: profile.lastName,
        isRequired: true,
      ),
      ProfileField(
        label: 'Email Address',
        hintText: 'Enter Email Address',
        value: userEmail.value, // Email is on User model / token
        isRequired: true,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Website',
        hintText: 'Enter Website URL',
        value: profile.website ?? '',
        isRequired: false,
      ),
      ProfileField(
        label: 'NID Number',
        hintText: 'NID Number',
        value: profile.nidNumber ?? '',
        isReadOnly: true,
      ),
      ProfileField(
        label: 'NID Status',
        hintText: 'NID Status',
        value: nidStatusLabel,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Onboarding Complete',
        hintText: 'Onboarding Complete',
        value: profile.isOnboardingComplete ? 'Yes' : 'No',
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Profile Rating',
        hintText: 'Profile Rating',
        value: profile.averageRating.toStringAsFixed(1),
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Total Reviews',
        hintText: 'Total Reviews',
        value: profile.totalReviews.toString(),
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Profile ID',
        hintText: 'Profile ID',
        value: profile.id,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'User ID',
        hintText: 'User ID',
        value: profile.userId,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Created At',
        hintText: 'Created At',
        value: _formatDateTime(profile.createdAt),
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Updated At',
        hintText: 'Updated At',
        value: _formatDateTime(profile.updatedAt),
        isReadOnly: true,
      ),
    ]);
    _syncProfileFieldDefaults();
  }

  void _syncProfileFieldDefaults() {
    final updated = <String, String>{};
    for (final field in profileFields) {
      updated[field.label] = field.value;
    }
    profileFieldValues.assignAll(updated);
  }

  void _syncSocialHandleDefaults() {
    final updated = <String, String>{};
    for (final social in socialAccounts) {
      updated[social.platform.toLowerCase()] = social.handle;
    }
    socialHandleEdits.assignAll(updated);
  }

  String nicheStatusValue(String nicheName) {
    return nicheStatuses[nicheName.toLowerCase()] ?? 'pending';
  }

  bool isNicheVerified(String nicheName) {
    final status = nicheStatusValue(nicheName).toLowerCase();
    return status == 'approved' || status == 'verified';
  }

  /// Adds an empty social account entry so the UI can render an input field.
  void addSocialAccount({String platform = 'Instagram', String handle = ''}) {
    socialAccounts.add(
      SocialAccount(
        platform: _capitalizeFirst(platform),
        iconPath: _getIconPathForPlatform(platform),
        handle: handle,
        isVerified: false,
      ),
    );
    _syncSocialHandleDefaults();
  }

  UserLocation? _primaryLocationForOnboarding() {
    if (locations.isNotEmpty) return locations.first;
    final addr = influencerProfile.value?.primaryAddress;
    if (addr == null) return null;
    return UserLocation(
      name: addr.addressName ?? '',
      thana: addr.thana ?? '',
      zilla: addr.zilla ?? '',
      country: addr.country ?? '',
      fullAddress: addr.fullAddress ?? '',
    );
  }

  String _formatDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  bool _hasValidOnboardingAddress(UserLocation? location) {
    if (location == null) return false;
    return location.thana.trim().isNotEmpty &&
        location.zilla.trim().isNotEmpty &&
        location.fullAddress.trim().isNotEmpty;
  }

  String profileFieldValue(String label, String fallback) {
    return profileFieldValues[label] ?? fallback;
  }

  void setProfileFieldValue(String label, String value) {
    profileFieldValues[label] = value;
  }

  String socialHandleValue(String platform, String fallback) {
    final key = platform.toLowerCase();
    return socialHandleEdits[key] ?? fallback;
  }

  void setSocialHandle(String platform, String value) {
    socialHandleEdits[platform.toLowerCase()] = value;
  }

  void showAddSocialDialog() {
    newSocialPlatform.value = null;
    newSocialHandleController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Social Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: newSocialPlatform.value,
                decoration: const InputDecoration(hintText: 'Select platform'),
                items: socialPlatformOptions
                    .map(
                      (platform) => DropdownMenuItem<String>(
                        value: platform,
                        child: Text(platform),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => newSocialPlatform.value = value,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newSocialHandleController,
              decoration: const InputDecoration(
                hintText: '@username or profile URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final platform = newSocialPlatform.value?.trim() ?? '';
              final handle = newSocialHandleController.text.trim();
              if (platform.isEmpty || handle.isEmpty) return;

              addOrUpdateSocialAccount(platform: platform, handle: handle);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addOrUpdateSocialAccount({
    required String platform,
    required String handle,
  }) {
    final normalizedPlatform = _capitalizeFirst(platform.trim());
    final normalizedHandle = handle.trim();
    if (normalizedPlatform.isEmpty || normalizedHandle.isEmpty) return;

    final key = normalizedPlatform.toLowerCase();
    final existingIndex = socialAccounts.indexWhere(
      (item) => item.platform.toLowerCase() == key,
    );

    if (existingIndex >= 0) {
      final existing = socialAccounts[existingIndex];
      socialAccounts[existingIndex] = SocialAccount(
        platform: normalizedPlatform,
        iconPath: _getIconPathForPlatform(normalizedPlatform),
        handle: normalizedHandle,
        isVerified: existing.isVerified,
      );
    } else {
      socialAccounts.add(
        SocialAccount(
          platform: normalizedPlatform,
          iconPath: _getIconPathForPlatform(normalizedPlatform),
          handle: normalizedHandle,
          isVerified: false,
        ),
      );
    }

    setSocialHandle(normalizedPlatform, normalizedHandle);
  }

  void showAddNicheDialog() {
    newNicheController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Niche'),
        content: TextField(
          controller: newNicheController,
          decoration: const InputDecoration(hintText: 'Enter niche'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final niche = newNicheController.text.trim();
              if (niche.isEmpty) return;
              addNiche(niche);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addNiche(String niche) {
    final value = niche.trim();
    if (value.isEmpty) return;

    final alreadyExists = niches.any(
      (item) => item.toLowerCase() == value.toLowerCase(),
    );
    if (alreadyExists) return;

    niches.add(value);
    nicheStatuses[value.toLowerCase()] = 'pending';
  }

  /// Get NID verification state from profile
  VerificationState _getNidVerificationState(InfluencerProfile profile) {
    if (profile.nidVerification == null) {
      return profile.hasNidSubmitted
          ? VerificationState.underReview
          : VerificationState.unverified;
    }
    final status = profile.nidVerification!.status;
    if (status == 'approved' || status == 'verified')
      return VerificationState.verified;
    if (status == 'pending') return VerificationState.underReview;
    return VerificationState.unverified;
  }

  /// Helper to get icon path for social platform
  String _getIconPathForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return 'assets/icons/Instagram_outline.png';
      case 'youtube':
        return 'assets/icons/youtube_outline.png';
      case 'tiktok':
        return 'assets/icons/tiktok_outline.png';
      case 'facebook':
        return 'assets/icons/facebook.png';
      case 'twitter':
      case 'x':
        return 'assets/icons/instagram.png'; // fallback - no x icon available
      default:
        return 'assets/icons/instagram.png'; // fallback
    }
  }

  /// Capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _syncBrandWebsiteFromController() {
    brandWebsite.value = brandWebsiteController.text.trim();
  }

  void _setBrandWebsite(String? website) {
    final value = website?.trim() ?? '';
    brandWebsite.value = value;
    if (brandWebsiteController.text.trim() != value) {
      brandWebsiteController.text = value;
    }
  }

  Future<void> _loadUserFromToken() async {
    final token = await _tokenService.getAccessToken();
    if (token == null || token.trim().isEmpty) return;

    final payload = _decodeJwtPayload(token);
    if (payload == null) return;

    final email = _stringOrNull(payload['email']);
    final phone = _stringOrNull(payload['phone']);

    if (email != null) userEmail.value = email;
    if (phone != null) userPhone.value = phone;

    final jwtVerified = _toBool(payload['isVerified']);
    if (jwtVerified != null) {
      _jwtAdminVerified.value = jwtVerified;
      profileStatus.value = jwtVerified
          ? ProfileStatus.verified
          : ProfileStatus.unverified;
    }
  }

  void _setProfileStatusFromVerification({dynamic profileIsVerified}) {
    final jwtVerified = _jwtAdminVerified.value;
    final apiVerified = _toBool(profileIsVerified);
    final isVerified = jwtVerified ?? apiVerified ?? false;
    profileStatus.value = isVerified
        ? ProfileStatus.verified
        : ProfileStatus.unverified;
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalized);
      final payloadString = utf8.decode(payloadBytes);
      final payloadJson = jsonDecode(payloadString);
      if (payloadJson is Map<String, dynamic>) return payloadJson;
      return null;
    } catch (_) {
      return null;
    }
  }

  void _applyContactFromJson(Map<String, dynamic> json) {
    final email =
        _stringOrNull(json['email']) ??
        _stringOrNull((json['user'] as Map?)?['email']);
    final phone =
        _stringOrNull(json['phone']) ??
        _stringOrNull((json['user'] as Map?)?['phone']);

    if (email != null) userEmail.value = email;
    if (phone != null) userPhone.value = phone;

    if (email != null) appUserSession.userEmail.value = email;
    if (phone != null) appUserSession.userPhone.value = phone;
  }

  String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  BrandHandlePlatform? _brandPlatformFromString(dynamic platform) {
    final value = platform?.toString().toLowerCase().trim();
    switch (value) {
      case 'facebook':
        return BrandHandlePlatform.facebook;
      case 'instagram':
        return BrandHandlePlatform.instagram;
      case 'tiktok':
        return BrandHandlePlatform.tiktok;
      case 'youtube':
        return BrandHandlePlatform.youtube;
      case 'x':
      case 'twitter':
        return BrandHandlePlatform.x;
      case 'linkedin':
        return BrandHandlePlatform.linkedin;
      case 'website':
        return BrandHandlePlatform.website;
      default:
        return null;
    }
  }

  void _replaceBrandAssets(List<BrandAssetItem> items) {
    for (final item in brandAssets) {
      item.controller.dispose();
    }
    brandAssets.assignAll(items);
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
    }
  }

  void _setBioText(String value) {
    bioText.value = value;
    _setControllerText(bioController, value);
  }

  void _syncBioFromController() {
    final value = bioController.text;
    if (bioText.value != value) {
      bioText.value = value;
    }
  }

  void _hydrateVerificationInputsFromJson(Map<String, dynamic> json) {
    _setControllerText(
      nidNumberController,
      _stringOrNull(json['nidNumber']) ?? '',
    );
    _setControllerText(
      tradeNumberController,
      _stringOrNull(json['tradeLicenseNumber']) ?? '',
    );
    _setControllerText(
      tinNumberController,
      _stringOrNull(json['tinNumber']) ?? '',
    );
    _setControllerText(
      binNumberController,
      _stringOrNull(json['binNumber']) ?? '',
    );

    nidFrontUploadedUrl.value =
        _stringOrNull(json['nidFrontImg']) ??
        _stringOrNull(json['nidFrontImage']);
    nidBackUploadedUrl.value =
        _stringOrNull(json['nidBackImg']) ??
        _stringOrNull(json['nidBackImage']);
    tradeLicenseUploadedUrl.value =
        _stringOrNull(json['tradeLicenseImage']) ??
        _stringOrNull(json['tradeLicenseImg']);
    tinUploadedUrl.value = _stringOrNull(json['tinImage']);
  }

  /// Fetches agency profile from API and populates UI fields
  Future<void> _fetchAgencyProfile() async {
    final service = Get.find<AgencyProfileService>();
    final result = await ApiErrorHandler.call(
      () => service.fetchProfile(),
      showError: false,
    );

    if (!result.isSuccess || result.data == null) {
      debugPrint('❌ Failed to load agency profile: ${result.error}');
      _applyEmptyProfileState();
      return;
    }

    final json = result.data!;
    debugPrint('📋 AGENCY PROFILE LOADED:');
    debugPrint('  Name: ${json['agencyName']}');
    debugPrint('  isOnboardingComplete: ${json['isOnboardingComplete']}');

    _populateFromAgencyJson(json);
  }

  /// Fetches brand profile from API and populates UI fields
  Future<void> _fetchBrandProfile() async {
    final service = Get.find<BrandOnboardingService>();
    final result = await ApiErrorHandler.call(
      () => service.fetchProfile(),
      showError: false,
    );

    if (!result.isSuccess || result.data == null) {
      debugPrint('❌ Failed to load brand profile: ${result.error}');
      _applyEmptyProfileState();
      return;
    }

    final json = result.data!;
    debugPrint('📋 BRAND PROFILE LOADED:');
    debugPrint('  Name: ${json['firstName']} ${json['lastName']}');
    debugPrint('  isOnboardingComplete: ${json['isOnboardingComplete']}');

    _populateFromBrandJson(json);
  }

  /// Populates controller fields from Agency profile JSON
  void _populateFromAgencyJson(Map<String, dynamic> json) {
    _applyContactFromJson(json);

    // Basic info
    final agencyName = json['agencyName'] as String? ?? '';
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    profileName.value = agencyName.isNotEmpty
        ? agencyName
        : '$firstName $lastName'.trim();
    _setProfileStatusFromVerification(profileIsVerified: json['isVerified']);
    _setBioText(json['agencyBio'] as String? ?? '');
    serviceFeeText.value = json['serviceFee']?.toString() ?? '';
    profileImageUrl.value =
        _stringOrNull(json['profileImg']) ??
        _stringOrNull(json['profileImage']) ??
        _stringOrNull(json['logo']) ??
        '';
    profileImageFile.value = null;

    appUserSession.agencyProfileJson.value = Map<String, dynamic>.from(json);
    appUserSession.displayName.value = profileName.value;
    appUserSession.profileImageUrl.value = profileImageUrl.value;

    // Rating
    final rating = json['averageRating'];
    if (rating is String) {
      profileRating.value = double.tryParse(rating) ?? 0.0;
    } else if (rating is num) {
      profileRating.value = rating.toDouble();
    }
    profileRatingCount.value = json['totalReviews'] as int? ?? 0;

    // Calculate profile completion
    int completed = 0;
    int total = 8;
    if (agencyName.isNotEmpty) completed++;
    if ((json['agencyBio'] as String?)?.isNotEmpty == true) completed++;
    if (json['address'] != null) completed++;
    if (json['socialLinks'] != null) completed++;
    if (json['nidNumber'] != null) completed++;
    if (json['tradeLicenseNumber'] != null) completed++;
    if (json['tinNumber'] != null) completed++;
    if (json['payouts'] != null) completed++;
    profileCompletion.value = completed / total;

    // Social accounts
    final socialLinks = json['socialLinks'] as List?;
    if (socialLinks != null && socialLinks.isNotEmpty) {
      socialAccounts.assignAll(
        socialLinks.map((link) {
          final linkMap = link as Map<String, dynamic>;
          return SocialAccount(
            platform: _capitalizeFirst(linkMap['platform'] as String? ?? ''),
            iconPath: _getIconPathForPlatform(
              linkMap['platform'] as String? ?? '',
            ),
            handle: linkMap['url'] as String? ?? '',
            isVerified: linkMap['status'] == 'verified',
          );
        }).toList(),
      );
    } else {
      socialAccounts.clear();
    }
    _syncSocialHandleDefaults();

    // Niches
    final niches_ = json['niches'] as List?;
    if (niches_ != null && niches_.isNotEmpty) {
      final names = <String>[];
      final statuses = <String, String>{};

      for (final item in niches_) {
        if (item is String) {
          final name = item.trim();
          if (name.isEmpty) continue;
          names.add(name);
          statuses[name.toLowerCase()] = 'pending';
          continue;
        }

        if (item is Map) {
          final map = Map<String, dynamic>.from(item as Map);
          final name = (map['name'] ?? map['niche'] ?? '').toString().trim();
          if (name.isEmpty) continue;
          final status = (map['status'] ?? 'pending').toString().trim();
          names.add(name);
          statuses[name.toLowerCase()] = status.toLowerCase();
        }
      }

      niches.assignAll(names);
      nicheStatuses.assignAll(statuses);
    } else {
      niches.clear();
      nicheStatuses.clear();
    }

    // Locations/Addresses
    final address = json['address'];
    if (address != null) {
      if (address is Map<String, dynamic>) {
        locations.assignAll([
          UserLocation(
            name: address['addressName'] as String? ?? 'Office',
            thana: address['thana'] as String? ?? '',
            zilla: address['zilla'] as String? ?? '',
            fullAddress: address['fullAddress'] as String? ?? '',
          ),
        ]);
      } else if (address is List && address.isNotEmpty) {
        locations.assignAll(
          address.map((addr) {
            final addrMap = addr as Map<String, dynamic>;
            return UserLocation(
              name: addrMap['addressName'] as String? ?? 'Office',
              thana: addrMap['thana'] as String? ?? '',
              zilla: addrMap['zilla'] as String? ?? '',
              fullAddress: addrMap['fullAddress'] as String? ?? '',
            );
          }).toList(),
        );
      }
    } else {
      locations.clear();
    }

    // Payout methods
    final payouts = json['payouts'] as Map<String, dynamic>?;
    if (payouts != null) {
      final List<PayoutMethod> methods = [];

      final banks = payouts['bank'] as List?;
      if (banks != null) {
        for (final bank in banks) {
          final bankMap = bank as Map<String, dynamic>;
          methods.add(
            PayoutMethod.bank(
              payoutId: bankMap['id']?.toString(),
              bankName: bankMap['bankName'] as String? ?? '',
              accountName: bankMap['bankAccHolderName'] as String? ?? '',
              accountNo: bankMap['bankAccNo'] as String? ?? '',
              branchName: bankMap['bankBranchName'] as String? ?? '',
              routingNumber: bankMap['bankRoutingNo'] as String? ?? '',
              isApproved: bankMap['status'] == 'approved',
            ),
          );
        }
      }

      final mobile = payouts['mobileBanking'] as List?;
      if (mobile != null) {
        for (final m in mobile) {
          final mobileMap = m as Map<String, dynamic>;
          methods.add(
            PayoutMethod.bKash(
              payoutId: mobileMap['id']?.toString(),
              bKashNo: mobileMap['accountNo'] as String? ?? '',
              bKashName: mobileMap['accountHolderName'] as String? ?? '',
              bKashAccountType:
                  mobileMap['accountType'] as String? ?? 'Personal',
              isApproved: mobileMap['status'] == 'approved',
            ),
          );
        }
      }

      payoutMethods.assignAll(methods);
    } else {
      payoutMethods.clear();
    }

    // Verification status items
    verificationInprogressItems.assignAll([
      VerificationInprogressItem(
        title: 'Social Profile Verification',
        state:
            (socialLinks != null &&
                socialLinks.any((s) => (s as Map)['status'] == 'verified'))
            ? VerificationState.verified
            : (socialLinks != null && socialLinks.isNotEmpty)
            ? VerificationState.underReview
            : VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Payment Setup',
        state: json['payouts'] != null
            ? VerificationState.verified
            : VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'NID',
        state: _getVerificationStateFromJson(
          json['nidVerification'],
          json['nidNumber'],
        ),
      ),
      VerificationInprogressItem(
        title: 'Trade License',
        state: _getVerificationStateFromJson(
          json['tradeLicenseVerification'],
          json['tradeLicenseNumber'],
        ),
      ),
      VerificationInprogressItem(
        title: 'TIN',
        state: _getVerificationStateFromJson(
          json['tinVerification'],
          json['tinNumber'],
        ),
      ),
      VerificationInprogressItem(
        title: 'BIN',
        state: _getVerificationStateFromJson(
          json['binVerification'],
          json['binNumber'],
        ),
      ),
    ]);

    // Profile fields
    profileFields.assignAll([
      ProfileField(
        label: 'Agency Name',
        hintText: 'Enter Agency Name',
        value: agencyName,
        isRequired: true,
      ),
      ProfileField(
        label: 'First Name',
        hintText: 'Enter First Name',
        value: firstName,
        isRequired: true,
      ),
      ProfileField(
        label: 'Last Name',
        hintText: 'Enter Last Name',
        value: lastName,
        isRequired: true,
      ),
      if (userEmail.value.isNotEmpty)
        ProfileField(
          label: 'Email Address',
          hintText: 'Enter Email Address',
          value: userEmail.value,
          isRequired: true,
        ),
      ProfileField(
        label: 'Website',
        hintText: 'Enter Website URL',
        value: json['website'] as String? ?? '',
        isRequired: false,
      ),
    ]);
    _hydrateVerificationInputsFromJson(json);
    _syncProfileFieldDefaults();
  }

  /// Populates controller fields from Brand profile JSON
  void _populateFromBrandJson(Map<String, dynamic> json) {
    _applyContactFromJson(json);
    // Brand uses similar structure - reuse agency logic with slight modifications

    final companyName =
        _stringOrNull(json['brandName']) ??
        _stringOrNull(json['companyName']) ??
        '';
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    profileName.value = companyName.isNotEmpty
        ? companyName
        : '$firstName $lastName'.trim();
    brandName.value = companyName;
    _setProfileStatusFromVerification(profileIsVerified: json['isVerified']);
    _setBioText(json['bio'] as String? ?? '');
    _setBrandWebsite(_stringOrNull(json['website']));
    profileImageUrl.value =
        _stringOrNull(json['profileImg']) ??
        _stringOrNull(json['profileImage']) ??
        _stringOrNull(json['logo']) ??
        '';
    profileImageFile.value = null;

    appUserSession.brandProfileJson.value = Map<String, dynamic>.from(json);
    appUserSession.displayName.value = profileName.value;
    appUserSession.profileImageUrl.value = profileImageUrl.value;

    // Rating
    final rating = json['averageRating'];
    if (rating is String) {
      profileRating.value = double.tryParse(rating) ?? 0.0;
    } else if (rating is num) {
      profileRating.value = rating.toDouble();
    }
    profileRatingCount.value = json['totalReviews'] as int? ?? 0;

    // Calculate profile completion
    int completed = 0;
    int total = 7;
    if (companyName.isNotEmpty || firstName.isNotEmpty) completed++;
    if ((json['bio'] as String?)?.isNotEmpty == true) completed++;
    if (json['address'] != null || json['addresses'] != null) completed++;
    if (json['socialLinks'] != null) completed++;
    if (json['tradeLicenseNumber'] != null) completed++;
    if (json['tinNumber'] != null) completed++;
    if (json['payouts'] != null) completed++;
    profileCompletion.value = completed / total;

    // Social accounts
    final socialLinks = json['socialLinks'] as List?;
    if (socialLinks != null && socialLinks.isNotEmpty) {
      socialAccounts.assignAll(
        socialLinks.map((link) {
          final linkMap = link as Map<String, dynamic>;
          return SocialAccount(
            platform: _capitalizeFirst(linkMap['platform'] as String? ?? ''),
            iconPath: _getIconPathForPlatform(
              linkMap['platform'] as String? ?? '',
            ),
            handle:
                (linkMap['profileUrl'] ?? linkMap['url'] ?? linkMap['link'])
                    ?.toString() ??
                '',
            isVerified: linkMap['status'] == 'verified',
          );
        }).toList(),
      );

      final brandItems = <BrandAssetItem>[];
      for (final link in socialLinks) {
        if (link is! Map<String, dynamic>) continue;
        final platform = _brandPlatformFromString(link['platform']);
        if (platform == null || platform == BrandHandlePlatform.website) {
          continue;
        }
        final linkValue =
            (link['profileUrl'] ?? link['url'] ?? link['link'])?.toString() ??
            '';
        if (linkValue.trim().isEmpty) continue;
        brandItems.add(
          BrandAssetItem(
            platform: platform,
            controller: TextEditingController(text: linkValue),
          ),
        );
      }
      _replaceBrandAssets(brandItems);
    } else {
      socialAccounts.clear();
      _replaceBrandAssets(const []);
    }
    _syncSocialHandleDefaults();

    // Locations/Addresses
    final addresses =
        json['addresses'] as List? ??
        (json['address'] != null ? [json['address']] : null);
    if (addresses != null && addresses.isNotEmpty) {
      locations.assignAll(
        addresses.map((addr) {
          final addrMap = addr as Map<String, dynamic>;
          return UserLocation(
            name: addrMap['addressName'] as String? ?? 'Office',
            thana: addrMap['thana'] as String? ?? '',
            zilla: addrMap['zilla'] as String? ?? '',
            fullAddress: addrMap['fullAddress'] as String? ?? '',
          );
        }).toList(),
      );
    } else {
      locations.clear();
    }

    // Payout methods (same as agency)
    final payouts = json['payouts'] as Map<String, dynamic>?;
    if (payouts != null) {
      final List<PayoutMethod> methods = [];

      final banks = payouts['bank'] as List?;
      if (banks != null) {
        for (final bank in banks) {
          final bankMap = bank as Map<String, dynamic>;
          methods.add(
            PayoutMethod.bank(
              payoutId: bankMap['id']?.toString(),
              bankName: bankMap['bankName'] as String? ?? '',
              accountName: bankMap['bankAccHolderName'] as String? ?? '',
              accountNo: bankMap['bankAccNo'] as String? ?? '',
              branchName: bankMap['bankBranchName'] as String? ?? '',
              routingNumber: bankMap['bankRoutingNo'] as String? ?? '',
              isApproved: bankMap['status'] == 'approved',
            ),
          );
        }
      }

      final mobile = payouts['mobileBanking'] as List?;
      if (mobile != null) {
        for (final m in mobile) {
          final mobileMap = m as Map<String, dynamic>;
          methods.add(
            PayoutMethod.bKash(
              payoutId: mobileMap['id']?.toString(),
              bKashNo: mobileMap['accountNo'] as String? ?? '',
              bKashName: mobileMap['accountHolderName'] as String? ?? '',
              bKashAccountType:
                  mobileMap['accountType'] as String? ?? 'Personal',
              isApproved: mobileMap['status'] == 'approved',
            ),
          );
        }
      }

      payoutMethods.assignAll(methods);
    } else {
      payoutMethods.clear();
    }

    // Verification status items
    verificationInprogressItems.assignAll([
      VerificationInprogressItem(
        title: 'Social Profile Verification',
        state:
            (socialLinks != null &&
                socialLinks.any((s) => (s as Map)['status'] == 'verified'))
            ? VerificationState.verified
            : (socialLinks != null && socialLinks.isNotEmpty)
            ? VerificationState.underReview
            : VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Payment Setup',
        state: json['payouts'] != null
            ? VerificationState.verified
            : VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'Trade License',
        state: _getVerificationStateFromJson(
          json['tradeLicenseVerification'],
          json['tradeLicenseNumber'],
        ),
      ),
      VerificationInprogressItem(
        title: 'TIN',
        state: _getVerificationStateFromJson(
          json['tinVerification'],
          json['tinNumber'],
        ),
      ),
      VerificationInprogressItem(
        title: 'BIN',
        state: _getVerificationStateFromJson(
          json['binVerification'],
          json['binNumber'],
        ),
      ),
    ]);

    // Profile fields
    profileFields.assignAll([
      ProfileField(
        label: 'Company Name',
        hintText: 'Enter Company Name',
        value: companyName,
        isRequired: true,
      ),
      ProfileField(
        label: 'First Name',
        hintText: 'Enter First Name',
        value: firstName,
        isRequired: true,
      ),
      ProfileField(
        label: 'Last Name',
        hintText: 'Enter Last Name',
        value: lastName,
        isRequired: true,
      ),
      if (userEmail.value.isNotEmpty)
        ProfileField(
          label: 'Email Address',
          hintText: 'Enter Email Address',
          value: userEmail.value,
          isRequired: true,
        ),
      ProfileField(
        label: 'Website',
        hintText: 'Enter Website URL',
        value: json['website'] as String? ?? '',
        isRequired: false,
      ),
    ]);
    _hydrateVerificationInputsFromJson(json);
    _syncProfileFieldDefaults();
  }

  /// Helper to get verification state from JSON verification object
  VerificationState _getVerificationStateFromJson(
    dynamic verification,
    dynamic documentNumber,
  ) {
    if (verification != null && verification is Map) {
      final status = verification['status'] as String?;
      if (status == 'approved' || status == 'verified')
        return VerificationState.verified;
      if (status == 'pending') return VerificationState.underReview;
      if (status == 'rejected') return VerificationState.unverified;
    }
    // If no verification object but document exists, assume under review
    if (documentNumber != null && documentNumber.toString().isNotEmpty) {
      return VerificationState.underReview;
    }
    return VerificationState.unverified;
  }

  @override
  void onClose() {
    _nidFrontUploadWorker?.dispose();
    _nidBackUploadWorker?.dispose();
    _tradeUploadWorker?.dispose();
    _tinUploadWorker?.dispose();

    nidNumberController.dispose();
    tradeNumberController.dispose();
    tinNumberController.dispose();
    binNumberController.dispose();
    bankNameController.dispose();
    accountHolderNameController.dispose();
    bankAccountNumberController.dispose();
    bankBranchNameController.dispose();
    routingNumberController.dispose();
    bKashNoController.dispose();
    bKashHolderNameController.dispose();
    bKashAccountTypeController.dispose();

    bioController.removeListener(_syncBioFromController);
    bioController.dispose();

    brandWebsiteController.removeListener(_syncBrandWebsiteFromController);
    brandWebsiteController.dispose();
    brandNewLinkController.dispose();
    for (final item in brandAssets) {
      item.controller.dispose();
    }
    newSkillController.dispose();
    newSocialHandleController.dispose();
    newNicheController.dispose();

    locationNameController.dispose();
    locationFullAddressController.dispose();

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

  Worker? _nidFrontUploadWorker;
  Worker? _nidBackUploadWorker;
  Worker? _tradeUploadWorker;
  Worker? _tinUploadWorker;

  final RxnString nidFrontUploadedUrl = RxnString();
  final RxnString nidBackUploadedUrl = RxnString();
  final RxnString tradeLicenseUploadedUrl = RxnString();
  final RxnString tinUploadedUrl = RxnString();

  final RxBool isUploadingNidFront = false.obs;
  final RxBool isUploadingNidBack = false.obs;
  final RxBool isUploadingTradeLicense = false.obs;
  final RxBool isUploadingTin = false.obs;

  bool get isUploadingVerificationMedia =>
      isUploadingNidFront.value ||
      isUploadingNidBack.value ||
      isUploadingTradeLicense.value ||
      isUploadingTin.value;

  String? _validateVerificationInputs() {
    return null;
  }

  void _setupVerificationMediaUploadWorkers() {
    _nidFrontUploadWorker = ever<File?>(nidFrontPic, (file) {
      unawaited(
        _handleVerificationMediaSelection(
          file: file,
          assignUrl: (value) => nidFrontUploadedUrl.value = value,
          uploadingFlag: isUploadingNidFront,
        ),
      );
    });

    _nidBackUploadWorker = ever<File?>(nidBackPic, (file) {
      unawaited(
        _handleVerificationMediaSelection(
          file: file,
          assignUrl: (value) => nidBackUploadedUrl.value = value,
          uploadingFlag: isUploadingNidBack,
        ),
      );
    });

    _tradeUploadWorker = ever<File?>(tradeLicensePic, (file) {
      unawaited(
        _handleVerificationMediaSelection(
          file: file,
          assignUrl: (value) => tradeLicenseUploadedUrl.value = value,
          uploadingFlag: isUploadingTradeLicense,
        ),
      );
    });

    _tinUploadWorker = ever<File?>(tinCertificatePic, (file) {
      unawaited(
        _handleVerificationMediaSelection(
          file: file,
          assignUrl: (value) => tinUploadedUrl.value = value,
          uploadingFlag: isUploadingTin,
        ),
      );
    });
  }

  String _verificationUploadModule() {
    if (accountTypeService.isInfluencer) return 'influencer-kyc';
    if (accountTypeService.isAdAgency) return 'agency-kyc';
    if (accountTypeService.isBrand) return 'brand-kyc';
    return 'kyc';
  }

  Future<void> _handleVerificationMediaSelection({
    required File? file,
    required void Function(String?) assignUrl,
    required RxBool uploadingFlag,
  }) async {
    if (file == null) {
      assignUrl(null);
      return;
    }

    uploadingFlag.value = true;
    try {
      final url = await _uploadFile(
        file: file,
        module: _verificationUploadModule(),
      );
      assignUrl(url);
    } catch (e) {
      assignUrl(null);
      debugPrint('Verification media upload failed: $e');
      Get.snackbar('Error', 'Failed to upload selected file. Please retry.');
    } finally {
      uploadingFlag.value = false;
    }
  }

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

          return null;
        }
        return selectedFile;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Failed to pick image: $e");
      // Get.snackbar("Error", "Failed to pick image: $e");
      return null;
    }
  }

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

  Future<String> _uploadFile({
    required File file,
    required String module,
  }) async {
    final uploadService = Get.find<UploadService>();
    final fileName = path.basename(file.path);
    final extension = path.extension(fileName).replaceFirst('.', '');
    final normalizedExtension = extension.isEmpty
        ? 'jpg'
        : extension.toLowerCase();
    final contentType = _getContentType(normalizedExtension);

    final signedUrl = await uploadService.createSignedUrl(
      fileName: fileName,
      fileType: contentType,
      module: module,
    );

    await uploadService.uploadFileToSignedUrl(
      uploadUrl: signedUrl.uploadUrl,
      file: file,
      contentType: contentType,
    );

    return signedUrl.fileUrl;
  }

  Future<void> changeProfilePhoto() async {
    final picked = await pickImage();
    if (picked == null) return;
    profileImageFile.value = picked;

    try {
      final module = accountTypeService.isInfluencer
          ? 'influencer-profile'
          : accountTypeService.isAdAgency
          ? 'agency-profile'
          : 'brand-profile';
      final url = await _uploadFile(file: picked, module: module);
      if (url.isEmpty) return;
      profileImageUrl.value = url;

      if (accountTypeService.isInfluencer) {
        final service = Get.find<InfluencerProfileService>();
        final result = await service.updateBasicInfo(
          profileImage: url,
          bio: bioText.value,
        );
        if (result.isSuccess && result.data != null) {
          await _fetchProfileData();
          return;
        }
      } else if (accountTypeService.isAdAgency) {
        final service = Get.find<AgencyProfileService>();
        final result = await ApiErrorHandler.call(
          () => service.updateBasicInfo(logo: url),
        );
        if (!result.isSuccess) return;
        await _fetchProfileData();
        return;
      } else if (accountTypeService.isBrand) {
        final service = Get.find<BrandOnboardingService>();
        final result = await ApiErrorHandler.call(
          () => service.updateProfileImage(profileImg: url),
        );
        if (!result.isSuccess) return;
        await _fetchProfileData();
        return;
      }
    } catch (e) {
      debugPrint('Failed to update profile photo: $e');
    }
  }

  Future<void> removeProfilePhoto() async {
    profileImageFile.value = null;
    profileImageUrl.value = '';

    try {
      if (accountTypeService.isInfluencer) {
        final service = Get.find<InfluencerProfileService>();
        await service.removeProfileImage();
      }
    } catch (e) {
      debugPrint('Failed to remove profile photo: $e');
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
  final TextEditingController bankBranchNameController =
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
    bankBranchNameController.clear();
    routingNumberController.clear();
    bKashNoController.clear();
    bKashHolderNameController.clear();
    bKashAccountTypeController.clear();
  }

  // Example method to simulate form submission
  Future<void> submitNewPayoutForm() async {
    if (isSavingProfile.value) return;
    isSavingProfile.value = true;

    try {
      if (accountTypeService.isInfluencer) {
        final service = Get.find<InfluencerProfileService>();

        if (selectedAccountType.value == 'Bank') {
          final bankName = bankNameController.text.trim();
          final holder = accountHolderNameController.text.trim();
          final accountNo = bankAccountNumberController.text.trim();
          final branchName = bankBranchNameController.text.trim();
          final routing = routingNumberController.text.trim();

          if (bankName.isEmpty ||
              holder.isEmpty ||
              accountNo.isEmpty ||
              branchName.isEmpty ||
              routing.isEmpty) {
            Get.snackbar('Error', 'Please fill all bank payout fields');
            return;
          }

          final result = await service.addBankPayout(
            bankName: bankName,
            accountHolderName: holder,
            accountNo: accountNo,
            branchName: branchName,
            routingNo: routing,
          );

          if (!result.isSuccess) {
            Get.snackbar('Error', result.error ?? 'Failed to add payout');
            return;
          }
        } else if (selectedAccountType.value == 'bKash') {
          final accountNo = bKashNoController.text.trim();
          final holder = bKashHolderNameController.text.trim();
          final accountType = bKashAccountTypeController.text.trim();

          if (accountNo.isEmpty || holder.isEmpty) {
            Get.snackbar('Error', 'Please fill all mobile payout fields');
            return;
          }

          final result = await service.addMobilePayout(
            accountType: accountType.isEmpty ? 'Bkash' : accountType,
            accountHolderName: holder,
            accountNo: accountNo,
          );

          if (!result.isSuccess) {
            Get.snackbar('Error', result.error ?? 'Failed to add payout');
            return;
          }
        }
      } else {
        if (accountTypeService.isAdAgency) {
          final agencyService = Get.find<AgencyProfileService>();

          if (selectedAccountType.value == 'Bank') {
            final bankName = bankNameController.text.trim();
            final holder = accountHolderNameController.text.trim();
            final accountNo = bankAccountNumberController.text.trim();
            final branchName = bankBranchNameController.text.trim();
            final routing = routingNumberController.text.trim();

            if (bankName.isEmpty ||
                holder.isEmpty ||
                accountNo.isEmpty ||
                branchName.isEmpty ||
                routing.isEmpty) {
              Get.snackbar('Error', 'Please fill all bank payout fields');
              return;
            }

            final result = await ApiErrorHandler.call(
              () => agencyService.addBankPayout(
                bankName: bankName,
                accountHolderName: holder,
                accountNo: accountNo,
                branchName: branchName,
                routingNo: routing,
              ),
            );
            if (!result.isSuccess) return;
          } else if (selectedAccountType.value == 'bKash') {
            final accountNo = bKashNoController.text.trim();
            final holder = bKashHolderNameController.text.trim();
            final accountType = bKashAccountTypeController.text.trim();

            if (accountNo.isEmpty || holder.isEmpty) {
              Get.snackbar('Error', 'Please fill all mobile payout fields');
              return;
            }

            final result = await ApiErrorHandler.call(
              () => agencyService.addMobilePayout(
                accountType: accountType.isEmpty ? 'Bkash' : accountType,
                accountHolderName: holder,
                accountNo: accountNo,
              ),
            );
            if (!result.isSuccess) return;
          }
        }
      }

      await _fetchProfileData();

      showNewPayoutAccountForm.value = false;
      _clearAllFields();
    } finally {
      isSavingProfile.value = false;
    }
  }

  Future<void> removePayoutMethod(PayoutMethod payout) async {
    if (isSavingProfile.value) return;

    if (!accountTypeService.isInfluencer) {
      if (accountTypeService.isAdAgency) {
        final payoutId = payout.payoutId?.trim();
        if (payoutId != null && payoutId.isNotEmpty) {
          final agencyService = Get.find<AgencyProfileService>();
          final result = await ApiErrorHandler.call(
            () => agencyService.removePayout(
              type: payout.isBank ? 'bank' : 'mobileBanking',
              id: payoutId,
            ),
          );
          if (!result.isSuccess) return;
        }
      }

      payoutMethods.remove(payout);
      return;
    }

    final payoutId = payout.payoutId?.trim();
    if (payoutId == null || payoutId.isEmpty) {
      Get.snackbar('Error', 'Unable to remove payout: missing payout id');
      return;
    }

    isSavingProfile.value = true;
    try {
      final service = Get.find<InfluencerProfileService>();
      final result = await service.removePayout(
        type: payout.payoutType,
        id: payoutId,
      );

      if (result.isSuccess) {
        payoutMethods.removeWhere((item) => item.payoutId == payoutId);
      } else {
        Get.snackbar('Error', result.error ?? 'Failed to remove payout');
      }
    } finally {
      isSavingProfile.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE (API fallback)
  // ---------------------------------------------------------------------------

  void _applyEmptyProfileState() {
    final isBrand = accountTypeService.isBrand;
    final isAdAgency = accountTypeService.isAdAgency;
    final isInfluencer = accountTypeService.isInfluencer;

    profileStatus.value = ProfileStatus.unverified;
    profileCompletion.value = 0.35;
    _setBioText('');
    serviceFeeText.value = '';
    profileImageUrl.value = '';
    profileImageFile.value = null;

    socialAccounts.clear();
    _syncSocialHandleDefaults();
    niches.clear();
    nicheStatuses.clear();

    profileFields.assignAll([
      if (isAdAgency)
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
      if (isBrand)
        ProfileField(
          label: 'Company Name',
          hintText: 'Enter Company Name',
          value: '',
          isRequired: true,
        ),
      if (!isInfluencer)
        ProfileField(
          label: 'Full Address',
          hintText: 'Enter Full Address',
          value: '',
          isRequired: true,
        ),
      ProfileField(
        label: 'Email Address',
        hintText: 'Enter Email Address',
        value: userEmail.value,
        isRequired: true,
      ),
      ProfileField(
        label: 'Phone Number',
        hintText: 'Enter Phone Number',
        value: userPhone.value,
        isRequired: true,
      ),
      ProfileField(
        label: 'Secondary Phone Number (Optional)',
        hintText: 'Enter Secondary Phone Number',
        value: '',
        isRequired: false,
      ),
    ]);
    _syncProfileFieldDefaults();

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

    payoutMethods.clear();

    _setControllerText(nidNumberController, '');
    _setControllerText(tradeNumberController, '');
    _setControllerText(tinNumberController, '');
    _setControllerText(binNumberController, '');
    nidFrontPic.value = null;
    nidBackPic.value = null;
    tradeLicensePic.value = null;
    tinCertificatePic.value = null;
    nidFrontUploadedUrl.value = null;
    nidBackUploadedUrl.value = null;
    tradeLicenseUploadedUrl.value = null;
    tinUploadedUrl.value = null;

    brandWebsiteController.clear();
    _replaceBrandAssets([]);

    if (isInfluencer) {
      skills.clear();
    } else {
      skills.clear();
    }

    if (isInfluencer) {
      locations.clear();
    } else {
      locations.clear();
    }
  }

  void _setVerifiedProfileState() {
    profileStatus.value = ProfileStatus.verified;
  }

  // You can expose this to switch state from outside if needed.
  void setProfileStatus(ProfileStatus status) {
    if (status == ProfileStatus.verified) {
      _setVerifiedProfileState();
    } else {
      _applyEmptyProfileState();
    }
  }

  // -------------------- BRAND ASSETS (Brand only) --------------------
  final brandWebsiteController = TextEditingController();

  final Rx<BrandHandlePlatform?> selectedBrandPlatform =
      Rx<BrandHandlePlatform?>(BrandHandlePlatform.instagram);

  final brandNewLinkController = TextEditingController();

  final brandAssets = <BrandAssetItem>[].obs;

  List<BrandHandlePlatform> get brandPlatforms => const [
    BrandHandlePlatform.facebook,
    BrandHandlePlatform.instagram,
    BrandHandlePlatform.tiktok,
    BrandHandlePlatform.youtube,
    BrandHandlePlatform.linkedin,
    BrandHandlePlatform.x,
  ];

  void addBrandAsset() {
    final p = selectedBrandPlatform.value;
    final link = brandNewLinkController.text.trim();

    if (p == null || link.isEmpty) return;

    brandAssets.add(
      BrandAssetItem(
        platform: p,
        controller: TextEditingController(text: link),
      ),
    );

    brandNewLinkController.clear();
  }

  void removeBrandAsset(int index) {
    if (index < 0 || index >= brandAssets.length) return;
    brandAssets[index].controller.dispose();
    brandAssets.removeAt(index);
  }

  Future<void> saveBrandAssets() async {
    final website = brandWebsiteController.text.trim();
    final handles = brandAssets
        .map(
          (e) => {'platform': e.platform.name, 'url': e.controller.text.trim()},
        )
        .toList();

    if (!accountTypeService.isBrand) return;

    final service = Get.find<BrandOnboardingService>();
    final result = await ApiErrorHandler.call(
      () => service.updateSocialLinks(website: website, socialLinks: handles),
    );

    if (!result.isSuccess) {
      return;
    }

    await _fetchProfileData();

    Get.snackbar(
      'success_title'.tr,
      'brand_assets_saved'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // -------------------- SKILLS (Influencer only) --------------------
  final skillsExpanded = true.obs;
  final skills = <String>[].obs;

  final TextEditingController newSkillController = TextEditingController();

  void toggleSkills() => skillsExpanded.toggle();

  void showAddSkillDialog() {
    newSkillController.clear();

    Get.dialog(
      AlertDialog(
        title: Text('skills_add_dialog_title'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // uses your CustomTextFormField style if you want:
            // CustomTextFormField(hintText: 'skills_add_hint'.tr, controller: newSkillController),
            TextField(
              controller: newSkillController,
              decoration: InputDecoration(hintText: 'skills_add_hint'.tr),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('skills_cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              final v = newSkillController.text.trim();
              if (v.isEmpty) return;

              if (!skills.contains(v)) {
                skills.add(v);
              }
              Get.back();
            },
            child: Text('skills_add_btn'.tr),
          ),
        ],
      ),
    );
  }

  // -------------------- LOCATIONS (Influencer only) --------------------
  final locationsExpanded = true.obs;
  final locations = <UserLocation>[].obs;

  final RxBool showNewLocationForm = false.obs;
  final RxnInt editingLocationIndex = RxnInt();

  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController locationFullAddressController =
      TextEditingController();

  final selectedLocationThana = Rx<String?>(null);
  final selectedLocationZilla = Rx<String?>(null);

  void toggleLocations() => locationsExpanded.toggle();

  void setLocationThana(String? v) => selectedLocationThana.value = v;
  void setLocationZilla(String? v) => selectedLocationZilla.value = v;

  void startAddLocation() {
    editingLocationIndex.value = null;
    locationNameController.clear();
    locationFullAddressController.clear();
    selectedLocationThana.value = null;
    selectedLocationZilla.value = null;
    showNewLocationForm.value = true;
    locationsExpanded.value = true;
  }

  void startEditLocation(int index) {
    if (index < 0 || index >= locations.length) return;
    final loc = locations[index];

    editingLocationIndex.value = index;
    locationNameController.text = loc.name;
    locationFullAddressController.text = loc.fullAddress;
    selectedLocationThana.value = loc.thana;
    selectedLocationZilla.value = loc.zilla;

    showNewLocationForm.value = true;
    locationsExpanded.value = true;
  }

  void cancelLocationForm() {
    showNewLocationForm.value = false;
    editingLocationIndex.value = null;
  }

  Future<void> saveLocationForm() async {
    final name = locationNameController.text.trim();
    final thana = selectedLocationThana.value?.trim() ?? '';
    final zilla = selectedLocationZilla.value?.trim() ?? '';
    final full = locationFullAddressController.text.trim();

    if (name.isEmpty || thana.isEmpty || zilla.isEmpty || full.isEmpty) {
      // keep it simple ("required")
      Get.snackbar(
        'error'.tr,
        'locations_required_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newLoc = UserLocation(
      name: name,
      thana: thana,
      zilla: zilla,
      fullAddress: full,
    );

    if (accountTypeService.isInfluencer) {
      final service = Get.find<InfluencerProfileService>();

      final result = await service.addAddress(
        addressName: name,
        thana: thana,
        zilla: zilla,
        fullAddress: full,
      );

      if (result.isSuccess && result.data != null) {
        influencerProfile.value = result.data;
        _populateFromInfluencerProfile(result.data!);
      } else {
        Get.snackbar('Error', result.error ?? 'Failed to save location');
        return;
      }
    } else {
      if (accountTypeService.isBrand) {
        final brandService = Get.find<BrandOnboardingService>();
        final result = await ApiErrorHandler.call(
          () => brandService.updateAddress(
            addressName: name,
            thana: thana,
            zilla: zilla,
            fullAddress: full,
          ),
        );
        if (!result.isSuccess) return;
      } else if (accountTypeService.isAdAgency) {
        final agencyService = Get.find<AgencyProfileService>();
        final result = await ApiErrorHandler.call(
          () => agencyService.updateAddress(
            addressName: name,
            thana: thana,
            zilla: zilla,
            fullAddress: full,
          ),
        );
        if (!result.isSuccess) return;
      }

      final editIndex = editingLocationIndex.value;
      if (editIndex != null && editIndex >= 0 && editIndex < locations.length) {
        locations[editIndex] = newLoc;
      } else {
        locations.add(newLoc);
      }
    }

    cancelLocationForm();
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

  void showProfilePage() {
    verificationPageIndex.value = 0;
    verificationFlowIndex.value = 0;
  }

  void showVerificationPage() => verificationPageIndex.value = 1;

  void showVerificationList() => verificationFlowIndex.value = 0;

  void showEmailVerification() => verificationFlowIndex.value = 1;

  void showEmailSuccess() => verificationFlowIndex.value = 2;

  void resetVerificationFlow() => verificationFlowIndex.value = 0;

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (confirmed != true) return;

    try {
      await _authService.logout();
      accountTypeService.setRole(null);

      appUserSession.userEmail.value = '';
      appUserSession.userPhone.value = '';
      appUserSession.displayName.value = '';
      appUserSession.profileImageUrl.value = '';
      appUserSession.influencerProfile.value = null;
      appUserSession.agencyProfileJson.value = null;
      appUserSession.brandProfileJson.value = null;
      appUserSession.newNotifications.clear();
      appUserSession.earlierNotifications.clear();
      appUserSession.isLoaded.value = false;
      appUserSession.notificationsLoaded.value = false;

      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      Get.snackbar('Error', 'Logout failed');
    }
  }

  String get _emailRoleSegment {
    if (accountTypeService.isInfluencer) return 'influencer';
    if (accountTypeService.isAdAgency) return 'agency';
    if (accountTypeService.isBrand) return 'client';
    return 'client';
  }

  Future<void> startEmailVerification() async {
    if (isRequestingEmailOtp.value) return;

    final email = userEmail.value.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email not found');
      return;
    }

    isRequestingEmailOtp.value = true;
    final result = await ApiErrorHandler.call(
      () => _authService.requestEmailOtp(role: _emailRoleSegment),
    );
    isRequestingEmailOtp.value = false;

    if (result.isSuccess && result.data != null) {
      Get.snackbar('Success', result.data!.message);
      showEmailVerification();
    }
  }

  Future<void> resendEmailOtp() async {
    if (isResendingEmailOtp.value) return;

    final email = userEmail.value.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email not found');
      return;
    }

    isResendingEmailOtp.value = true;
    final result = await ApiErrorHandler.call(
      () => _authService.requestEmailOtp(role: _emailRoleSegment),
    );
    isResendingEmailOtp.value = false;

    if (result.isSuccess && result.data != null) {
      Get.snackbar('Success', result.data!.message);
    }
  }

  Future<void> verifyEmailOtp(String code) async {
    if (isVerifyingEmailOtp.value) return;

    final email = userEmail.value.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email not found');
      return;
    }

    final otp = code.trim();
    if (otp.length != 4) {
      Get.snackbar('Error', 'OTP must be 4 digits');
      return;
    }

    isVerifyingEmailOtp.value = true;
    final result = await ApiErrorHandler.call(
      () => _authService.verifyEmailOtp(
        role: _emailRoleSegment,
        email: email,
        code: otp,
      ),
    );
    isVerifyingEmailOtp.value = false;

    if (result.isSuccess && result.data != null) {
      Get.snackbar('Success', result.data!.message);
      markEmailVerified();
      showEmailSuccess();
    }
  }

  void markEmailVerified() {
    final items = verificationInprogressItems;
    final updated = items
        .map(
          (item) => item.title == 'Email'
              ? VerificationInprogressItem(
                  title: item.title,
                  state: VerificationState.verified,
                )
              : item,
        )
        .toList();

    final hasEmail = items.any((item) => item.title == 'Email');
    if (!hasEmail) {
      updated.add(
        const VerificationInprogressItem(
          title: 'Email',
          state: VerificationState.verified,
        ),
      );
    }

    verificationInprogressItems.assignAll(updated);
  }

  // Expansion togglers
  void toggleBio() => bioExpanded.toggle();
  void toggleServiceFee() => serviceFeeExpanded.toggle();
  void toggleSocial() => socialExpanded.toggle();
  void toggleNiche() => nicheExpanded.toggle();
  void toggleSettings() => settingsExpanded.toggle();
  void toggleVerification() => verificationExpanded.toggle();
  void togglePayout() => payoutExpanded.toggle();

  // Placeholder: save verification methods changes
  Future<void> onSaveVerificationMethods() async {
    if (isSavingProfile.value) return;
    if (isUploadingVerificationMedia) {
      Get.snackbar(
        'Error',
        'Please wait for media upload to complete.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final validationMessage = _validateVerificationInputs();
    if (validationMessage != null) {
      Get.snackbar(
        'Error',
        validationMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSavingProfile.value = true;

    try {
      if (accountTypeService.isInfluencer) {
        final service = Get.find<InfluencerProfileService>();

        final firstNameValue =
            (profileFieldValues['First Name'] ?? '').trim().isNotEmpty
            ? (profileFieldValues['First Name'] ?? '').trim()
            : null;
        final lastNameValue =
            (profileFieldValues['Last Name'] ?? '').trim().isNotEmpty
            ? (profileFieldValues['Last Name'] ?? '').trim()
            : null;
        final websiteValue =
            (profileFieldValues['Website'] ?? '').trim().isNotEmpty
            ? (profileFieldValues['Website'] ?? '').trim()
            : null;

        await service.updateBasicInfo(
          firstName: firstNameValue,
          lastName: lastNameValue,
          bio: bioText.value,
          website: websiteValue,
        );

        await service.updateNiches(niches.toList(growable: false));

        if (skills.isNotEmpty) {
          await service.updateSkills(skills.toList());
        }

        if (socialAccounts.isNotEmpty) {
          final existing = influencerProfile.value?.socialLinks ?? [];
          final existingByPlatform = <String, InfluencerSocialLink>{
            for (final link in existing) link.platform.toLowerCase(): link,
          };

          final updatedLinks = socialAccounts
              .map((social) {
                final key = social.platform.toLowerCase();
                final previous = existingByPlatform[key];
                final url = socialHandleValue(
                  social.platform,
                  social.handle,
                ).trim();
                return InfluencerSocialLink(
                  platform: key,
                  url: url,
                  status: previous?.status ?? 'unverified',
                );
              })
              .where((link) => link.url.trim().isNotEmpty)
              .toList(growable: false);

          if (updatedLinks.isNotEmpty) {
            await service.updateSocialLinks(updatedLinks);
          }
        }

        final nidNumber = nidNumberController.text.trim();
        String? frontUrl = nidFrontUploadedUrl.value;
        String? backUrl = nidBackUploadedUrl.value;
        if ((frontUrl == null || frontUrl.isEmpty) &&
            nidFrontPic.value != null) {
          frontUrl = await _uploadFile(
            file: nidFrontPic.value!,
            module: _verificationUploadModule(),
          );
          nidFrontUploadedUrl.value = frontUrl;
        }
        if ((backUrl == null || backUrl.isEmpty) && nidBackPic.value != null) {
          backUrl = await _uploadFile(
            file: nidBackPic.value!,
            module: _verificationUploadModule(),
          );
          nidBackUploadedUrl.value = backUrl;
        }

        if (nidNumber.isNotEmpty &&
            frontUrl != null &&
            frontUrl.isNotEmpty &&
            backUrl != null &&
            backUrl.isNotEmpty) {
          await service.submitNidVerification(
            nidNumber: nidNumber,
            nidFrontImg: frontUrl,
            nidBackImg: backUrl,
          );
        }
      } else if (accountTypeService.isBrand) {
        final brandService = Get.find<BrandOnboardingService>();

        final brandNameValue =
            profileFieldValues['Company Name'] ?? brandName.value;
        final firstNameValue = profileFieldValues['First Name'] ?? '';
        final lastNameValue = profileFieldValues['Last Name'] ?? '';

        if (brandNameValue.isNotEmpty ||
            firstNameValue.isNotEmpty ||
            lastNameValue.isNotEmpty) {
          final basicInfoResult = await ApiErrorHandler.call(
            () => brandService.updateBasicInfo(
              brandName: brandNameValue,
              firstName: firstNameValue,
              lastName: lastNameValue,
            ),
          );
          if (!basicInfoResult.isSuccess) return;
        }

        final nidNumber = nidNumberController.text.trim();
        String? frontUrl = nidFrontUploadedUrl.value;
        String? backUrl = nidBackUploadedUrl.value;
        if ((frontUrl == null || frontUrl.isEmpty) &&
            nidFrontPic.value != null) {
          frontUrl = await _uploadFile(
            file: nidFrontPic.value!,
            module: _verificationUploadModule(),
          );
          nidFrontUploadedUrl.value = frontUrl;
        }
        if ((backUrl == null || backUrl.isEmpty) && nidBackPic.value != null) {
          backUrl = await _uploadFile(
            file: nidBackPic.value!,
            module: _verificationUploadModule(),
          );
          nidBackUploadedUrl.value = backUrl;
        }

        if (nidNumber.isNotEmpty &&
            frontUrl != null &&
            frontUrl.isNotEmpty &&
            backUrl != null &&
            backUrl.isNotEmpty) {
          final nidResult = await ApiErrorHandler.call(
            () => brandService.updateNid(
              nidNumber: nidNumber,
              nidFrontImg: frontUrl ?? '',
              nidBackImg: backUrl ?? '',
            ),
          );
          if (!nidResult.isSuccess) return;
        }

        final tradeNumber = tradeNumberController.text.trim();
        String? tradeUrl = tradeLicenseUploadedUrl.value;
        if ((tradeUrl == null || tradeUrl.isEmpty) &&
            tradeLicensePic.value != null) {
          tradeUrl = await _uploadFile(
            file: tradeLicensePic.value!,
            module: _verificationUploadModule(),
          );
          tradeLicenseUploadedUrl.value = tradeUrl;
        }

        if (tradeNumber.isNotEmpty && tradeUrl != null && tradeUrl.isNotEmpty) {
          final tradeResult = await ApiErrorHandler.call(
            () => brandService.updateTradeLicense(
              tradeLicenseNumber: tradeNumber,
              tradeLicenseImg: tradeUrl ?? '',
            ),
          );
          if (!tradeResult.isSuccess) return;
        }
      } else if (accountTypeService.isAdAgency) {
        final agencyService = Get.find<AgencyProfileService>();

        final agencyNameValue =
            profileFieldValues['Agency Name'] ?? profileName.value;
        final firstNameValue = profileFieldValues['First Name'] ?? '';
        final lastNameValue = profileFieldValues['Last Name'] ?? '';
        final websiteValue =
            (profileFieldValues['Website'] ?? '').trim().isNotEmpty
            ? (profileFieldValues['Website'] ?? '').trim()
            : null;

        if (agencyNameValue.isNotEmpty ||
            firstNameValue.isNotEmpty ||
            lastNameValue.isNotEmpty) {
          await ApiErrorHandler.call(
            () => agencyService.updateBasicInfo(
              agencyName: agencyNameValue,
              firstName: firstNameValue,
              lastName: lastNameValue,
              agencyBio: bioText.value.trim(),
            ),
          );
        }

        if (locations.isNotEmpty) {
          final location = locations.first;
          if (location.thana.trim().isNotEmpty &&
              location.zilla.trim().isNotEmpty &&
              location.fullAddress.trim().isNotEmpty) {
            final addressResult = await ApiErrorHandler.call(
              () => agencyService.updateAddress(
                addressName: location.name.trim().isEmpty
                    ? 'Office'
                    : location.name.trim(),
                thana: location.thana.trim(),
                zilla: location.zilla.trim(),
                fullAddress: location.fullAddress.trim(),
              ),
            );
            if (!addressResult.isSuccess) return;
          }
        }

        await ApiErrorHandler.call(
          () => agencyService.updateNiches(niches.toList(growable: false)),
        );

        final socialPayload = socialAccounts
            .map(
              (account) => <String, dynamic>{
                'platform': account.platform.toLowerCase().trim(),
                'url': socialHandleValue(
                  account.platform,
                  account.handle,
                ).trim(),
              },
            )
            .where((item) => (item['url'] as String).isNotEmpty)
            .toList(growable: false);
        if (socialPayload.isNotEmpty ||
            (websiteValue != null && websiteValue.isNotEmpty)) {
          final socialResult = await ApiErrorHandler.call(
            () => agencyService.updateSocials(
              website: websiteValue,
              socialLinks: socialPayload,
            ),
          );
          if (!socialResult.isSuccess) return;
        }

        final serviceFeeValue = serviceFeeText.value.trim();
        if (serviceFeeValue.isNotEmpty) {
          final serviceFeeResult = await ApiErrorHandler.call(
            () => agencyService.updateServiceFee(serviceFeeValue),
          );
          if (!serviceFeeResult.isSuccess) return;
        }

        final nidNumber = nidNumberController.text.trim();
        String? frontUrl = nidFrontUploadedUrl.value;
        String? backUrl = nidBackUploadedUrl.value;
        if ((frontUrl == null || frontUrl.isEmpty) &&
            nidFrontPic.value != null) {
          frontUrl = await _uploadFile(
            file: nidFrontPic.value!,
            module: _verificationUploadModule(),
          );
          nidFrontUploadedUrl.value = frontUrl;
        }
        if ((backUrl == null || backUrl.isEmpty) && nidBackPic.value != null) {
          backUrl = await _uploadFile(
            file: nidBackPic.value!,
            module: _verificationUploadModule(),
          );
          nidBackUploadedUrl.value = backUrl;
        }

        if (nidNumber.isNotEmpty &&
            frontUrl != null &&
            frontUrl.isNotEmpty &&
            backUrl != null &&
            backUrl.isNotEmpty) {
          final nidResult = await ApiErrorHandler.call(
            () => agencyService.updateNid(
              nidNumber: nidNumber,
              nidFrontImg: frontUrl ?? '',
              nidBackImg: backUrl ?? '',
            ),
          );
          if (!nidResult.isSuccess) return;
        }

        final tradeNumber = tradeNumberController.text.trim();
        String? tradeUrl = tradeLicenseUploadedUrl.value;
        if ((tradeUrl == null || tradeUrl.isEmpty) &&
            tradeLicensePic.value != null) {
          tradeUrl = await _uploadFile(
            file: tradeLicensePic.value!,
            module: _verificationUploadModule(),
          );
          tradeLicenseUploadedUrl.value = tradeUrl;
        }

        if (tradeNumber.isNotEmpty && tradeUrl != null && tradeUrl.isNotEmpty) {
          final tradeResult = await ApiErrorHandler.call(
            () => agencyService.updateTradeLicense(
              tradeLicenseNumber: tradeNumber,
              tradeLicenseImg: tradeUrl ?? '',
            ),
          );
          if (!tradeResult.isSuccess) return;
        }

        final tinNumber = tinNumberController.text.trim();
        String? tinUrl = tinUploadedUrl.value;
        if ((tinUrl == null || tinUrl.isEmpty) &&
            tinCertificatePic.value != null) {
          tinUrl = await _uploadFile(
            file: tinCertificatePic.value!,
            module: _verificationUploadModule(),
          );
          tinUploadedUrl.value = tinUrl;
        }

        if (tinNumber.isNotEmpty && tinUrl != null && tinUrl.isNotEmpty) {
          final tinResult = await ApiErrorHandler.call(
            () => agencyService.updateTin(
              tinNumber: tinNumber,
              tinImage: tinUrl ?? '',
            ),
          );
          if (!tinResult.isSuccess) return;
        }

        final binNumber = binNumberController.text.trim();
        if (binNumber.isNotEmpty) {
          final binResult = await ApiErrorHandler.call(
            () => agencyService.updateBin(binNumber: binNumber),
          );
          if (!binResult.isSuccess) return;
        }
      }

      await _fetchProfileData();
      Get.snackbar(
        'success_title'.tr,
        'profile_update_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Save update failed: $e');
    } finally {
      isSavingProfile.value = false;
    }
  }
}
