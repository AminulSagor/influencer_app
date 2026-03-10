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
import 'package:influencer_app/core/services/campaign_service.dart';
import 'package:influencer_app/core/services/token_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_profile_service.dart';
import 'package:influencer_app/modules/ad_agency/services/upload_service.dart';
import 'package:influencer_app/modules/influencer/models/influencer_profile_model.dart';
import 'package:influencer_app/modules/influencer/services/influencer_profile_service.dart';
import 'package:influencer_app/modules/brand/services/brand_onboarding_services.dart';
import 'package:influencer_app/routes/app_routes.dart';

import 'models/brand_asset.dart';
import 'models/payout_method.dart';
import 'models/profile_field.dart';
import 'models/profile_user_model.dart';
import 'models/social_account.dart';
import 'models/user_location.dart';
import 'models/verification_inprogress_item.dart';
import 'enums/profile_status.dart';
import 'enums/verification_state.dart';
import 'widgets/tag_selection_dialog.dart';

class ProfileController extends GetxController {
  final accountTypeService = Get.find<AccountTypeService>();
  final appUserSession = Get.find<AppUserSessionController>();
  final TokenService _tokenService = Get.find<TokenService>();
  final CampaignService _campaignService = Get.find<CampaignService>();
  final _apiData = ProfileUserModel();
  // ---------------------------------------------------------------------------
  // BASIC PROFILE STATE
  // ---------------------------------------------------------------------------

  Rx<ProfileStatus> get profileStatus => _apiData.profileStatus;
  RxString get profileName => _apiData.profileName;
  RxString get profileLocation => _apiData.profileLocation;
  RxString get brandName => _apiData.brandName;
  RxDouble get profileRating => _apiData.profileRating;
  RxInt get profileRatingCount => _apiData.profileRatingCount;
  RxDouble get profileCompletion => _apiData.profileCompletion;
  RxString get bioText => _apiData.bioText;
  RxString get serviceFeeText => _apiData.serviceFeeText;
  RxString get dollarRateText => _apiData.dollarRateText;
  RxString get profileImageUrl => _apiData.profileImageUrl;
  RxString get userEmail => _apiData.userEmail;
  RxString get userPhone => _apiData.userPhone;
  RxString get brandWebsite => _apiData.brandWebsite;
  final RxnBool _jwtAdminVerified = RxnBool();

  // Text values
  final bioController = TextEditingController();

  // Profile image
  final Rx<File?> profileImageFile = Rx<File?>(null);
  Rxn<ProfileIdentityModel> get profileUser => _apiData.profileUser;
  ProfileIdentityModel? get currentProfileUser => _apiData.profileUser.value;

  // ---------------------------------------------------------------------------
  // EXPANSION STATE
  // ---------------------------------------------------------------------------

  final bioExpanded = true.obs;
  final serviceFeeExpanded = true.obs;
  final dollarRateExpanded = true.obs;
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

  RxList<SocialAccount> get socialAccounts => _apiData.socialAccounts;
  RxList<String> get niches => _apiData.niches;
  RxMap<String, String> get nicheStatuses => _apiData.nicheStatuses;
  RxMap<String, String> get skillStatuses => _apiData.skillStatuses;
  RxList<ProfileField> get profileFields => _apiData.profileFields;
  RxList<VerificationInprogressItem> get verificationInprogressItems =>
      _apiData.verificationInprogressItems;
  RxList<PayoutMethod> get payoutMethods => _apiData.payoutMethods;
  RxList<String> get skills => _apiData.skills;
  RxList<UserLocation> get locations => _apiData.locations;

  final RxnString newSocialPlatform = RxnString();
  final TextEditingController newSocialHandleController =
      TextEditingController();

  final allowedNiches = <String>[].obs;
  final allowedSkills = <String>[].obs;
  final isLoadingAllowedNiches = false.obs;
  final isLoadingAllowedSkills = false.obs;

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
  final isSavingServiceFee = false.obs;
  final isSavingDollarRate = false.obs;
  final isSavingProfileSettings = false.obs;
  final isSavingBrandAssetsSection = false.obs;
  final isSavingVerificationSection = false.obs;

  /// Loading state for profile fetch
  final isLoadingProfile = false.obs;

  bool get isClientVerificationComplete {
    if (!accountTypeService.isBrand) return true;
    final requiredTitles = <String>{'NID', 'Trade License', 'TIN', 'BIN'};
    final requiredItems = verificationInprogressItems
        .where((item) => requiredTitles.contains(item.title))
        .toList(growable: false);

    if (requiredItems.length < requiredTitles.length) {
      return false;
    }

    return requiredItems.every(
      (item) => item.state == VerificationState.verified,
    );
  }

  /// Current influencer profile (null for brand/agency)
  Rxn<InfluencerProfile> get influencerProfile => _apiData.influencerProfile;

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
    final wrappedResult = await ApiErrorHandler.call(
      () => service.getProfile(),
    );
    final result =
        wrappedResult.data ??
        ApiResult.failure(wrappedResult.error ?? 'unknown_error'.tr);

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
    final userModel = ProfileIdentityModel.fromInfluencer(
      profile,
      fallbackEmail: userEmail.value,
      fallbackPhone: userPhone.value,
    );
    _applyProfileUser(userModel);

    _setBioText(profile.bio ?? '');
    profileImageFile.value = null;
    profileRating.value = profile.averageRating;
    profileRatingCount.value = profile.totalReviews;

    appUserSession.influencerProfile.value = profile;

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
      final names = <String>[];
      final statuses = <String, String>{};
      for (final skill in profile.skills!) {
        final name = skill.name.trim();
        if (name.isEmpty) continue;
        names.add(name);
        statuses[name.toLowerCase()] = (skill.status ?? 'pending')
            .toLowerCase()
            .trim();
      }
      skills.assignAll(names);
      skillStatuses.assignAll(statuses);
    } else {
      skills.clear();
      skillStatuses.clear();
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
        title: 'Phone No. Verification',
        state: profile.isPhoneVerified == null
            ? (userPhone.value.trim().isNotEmpty
                  ? VerificationState.verified
                  : VerificationState.unverified)
            : (profile.isPhoneVerified == true
                  ? VerificationState.verified
                  : VerificationState.unverified),
      ),
      VerificationInprogressItem(
        title: 'Payment Setup',
        state: payoutMethods.isNotEmpty
            ? VerificationState.verified
            : VerificationState.unverified,
      ),
      VerificationInprogressItem(
        title: 'NID',
        state: _getNidVerificationState(profile),
      ),
      VerificationInprogressItem(
        title: 'Skills',
        state: _statusGroupVerificationState(skills, skillStatuses),
      ),
      VerificationInprogressItem(
        title: 'Niches',
        state: _statusGroupVerificationState(niches, nicheStatuses),
      ),
      VerificationInprogressItem(
        title: 'Email',
        state: profile.isEmailVerified == null
            ? VerificationState.verified
            : (profile.isEmailVerified == true
                  ? VerificationState.verified
                  : VerificationState.unverified),
      ),
    ]);

    // Profile fields
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
        label: 'Phone Number',
        hintText: 'Enter Phone Number',
        value: userPhone.value,
        isRequired: true,
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

  String skillStatusValue(String skillName) {
    return skillStatuses[skillName.toLowerCase()] ?? 'pending';
  }

  bool isSkillVerified(String skillName) {
    final status = skillStatusValue(skillName).toLowerCase();
    return status == 'approved' || status == 'verified';
  }

  VerificationState _statusGroupVerificationState(
    List<String> values,
    Map<String, String> statuses,
  ) {
    if (values.isEmpty) return VerificationState.unverified;

    var hasVerified = false;
    var hasUnderReview = false;
    var hasUnverified = false;

    for (final value in values) {
      final parsed =
          _parseVerificationState(statuses[value.toLowerCase()]) ??
          VerificationState.underReview;
      switch (parsed) {
        case VerificationState.verified:
          hasVerified = true;
          break;
        case VerificationState.underReview:
          hasUnderReview = true;
          break;
        case VerificationState.unverified:
          hasUnverified = true;
          break;
      }
    }

    if (hasVerified && !hasUnderReview && !hasUnverified) {
      return VerificationState.verified;
    }
    if (hasUnderReview || hasVerified) return VerificationState.underReview;
    return VerificationState.unverified;
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

  Future<void> showAddNicheDialog() async {
    await _ensureAllowedNichesLoaded();
    if (allowedNiches.isEmpty) {
      Get.snackbar(
        'Niches unavailable',
        'Could not load available niches right now.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final selected = await Get.dialog<List<String>>(
      TagSelectionDialog(
        title: 'Niche',
        searchHint: 'Search Niche',
        options: allowedNiches.toList(growable: false),
        initialSelected: niches.toList(growable: false),
      ),
      barrierDismissible: true,
    );

    if (selected == null) return;
    final nextStatuses = <String, String>{};
    for (final value in selected) {
      final key = value.toLowerCase();
      nextStatuses[key] = nicheStatuses[key] ?? 'pending';
    }

    niches.assignAll(selected);
    nicheStatuses.assignAll(nextStatuses);
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

  Future<void> _ensureAllowedNichesLoaded() async {
    if (allowedNiches.isNotEmpty || isLoadingAllowedNiches.value) return;
    isLoadingAllowedNiches.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchNiches(),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      final items = result.data!
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      allowedNiches.assignAll(items);
    }
    isLoadingAllowedNiches.value = false;
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
    final tokenResult = await ApiErrorHandler.call(
      () => _tokenService.getAccessToken(),
      showError: false,
    );
    final token = tokenResult.data;
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

  void _applyProfileUser(ProfileIdentityModel model) {
    _apiData.profileUser.value = model;

    profileName.value = model.displayName;
    userEmail.value = model.email;
    userPhone.value = model.phone;
    profileImageUrl.value = model.avatarUrl;
    profileLocation.value = model.location;
    _setProfileStatusFromVerification(profileIsVerified: model.isVerified);

    appUserSession.displayName.value = model.displayName;
    appUserSession.profileImageUrl.value = model.avatarUrl;
    if (model.email.trim().isNotEmpty) {
      appUserSession.userEmail.value = model.email.trim();
    }
    if (model.phone.trim().isNotEmpty) {
      appUserSession.userPhone.value = model.phone.trim();
    }
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
    final userModel = ProfileIdentityModel.fromAgencyJson(
      json,
      fallbackEmail: userEmail.value,
      fallbackPhone: userPhone.value,
    );
    _applyProfileUser(userModel);

    final agencyName = json['agencyName'] as String? ?? '';
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    _setBioText(json['agencyBio'] as String? ?? '');
    serviceFeeText.value = json['serviceFee']?.toString() ?? '';
    dollarRateText.value = json['dollarRate']?.toString() ?? '';
    profileImageFile.value = null;

    appUserSession.agencyProfileJson.value = Map<String, dynamic>.from(json);

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
    int total = 9;
    if (agencyName.isNotEmpty) completed++;
    if ((json['agencyBio'] as String?)?.isNotEmpty == true) completed++;
    if (json['address'] != null) completed++;
    if (json['socialLinks'] != null) completed++;
    if (json['skills'] != null) completed++;
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
          final map = Map<String, dynamic>.from(item);
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

    // Skills
    final skills_ = json['skills'] as List?;
    if (skills_ != null && skills_.isNotEmpty) {
      final names = <String>[];
      final statuses = <String, String>{};

      for (final item in skills_) {
        if (item is String) {
          final name = item.trim();
          if (name.isNotEmpty) {
            names.add(name);
            statuses[name.toLowerCase()] = 'pending';
          }
          continue;
        }

        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final name = (map['name'] ?? map['skill'] ?? '').toString().trim();
          if (name.isNotEmpty) {
            final status =
                (map['status'] ?? map['verificationStatus'] ?? 'pending')
                    .toString()
                    .trim()
                    .toLowerCase();
            names.add(name);
            statuses[name.toLowerCase()] = status;
          }
        }
      }

      skills.assignAll(names);
      skillStatuses.assignAll(statuses);
    } else {
      skills.clear();
      skillStatuses.clear();
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
        state: _getSocialVerificationState(socialLinks),
      ),
      VerificationInprogressItem(
        title: 'Phone No. Verification',
        state: _getPhoneVerificationState(json),
      ),
      VerificationInprogressItem(
        title: 'Payment Setup',
        state: payoutMethods.isNotEmpty
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
      VerificationInprogressItem(
        title: 'Email',
        state: _getEmailVerificationState(json),
      ),
    ]);

    final primaryLocation = locations.isNotEmpty ? locations.first : null;
    final secondaryPhone =
        _stringOrNull(json['secondaryPhone']) ??
        _stringOrNull(json['secondaryPhoneNumber']) ??
        '';
    final phoneValue =
        _stringOrNull(json['phone']) ??
        _stringOrNull((json['user'] as Map?)?['phone']) ??
        userPhone.value;

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
      ProfileField(
        label: 'Thana',
        hintText: 'Enter Thana',
        value: primaryLocation?.thana ?? '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Zilla',
        hintText: 'Enter Zilla',
        value: primaryLocation?.zilla ?? '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Full Address',
        hintText: 'Enter Full Address',
        value: primaryLocation?.fullAddress ?? '',
        isRequired: true,
      ),
      ProfileField(
        label: 'Email Address',
        hintText: 'Enter Email Address',
        value: userEmail.value,
        isRequired: true,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Phone Number',
        hintText: 'Enter Phone Number',
        value: phoneValue,
        isRequired: true,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Secondary Phone Number (Optional)',
        hintText: 'Enter Secondary Phone Number',
        value: secondaryPhone,
        isReadOnly: true,
      ),
    ]);
    _hydrateVerificationInputsFromJson(json);
    _syncProfileFieldDefaults();
  }

  /// Populates controller fields from Brand profile JSON
  void _populateFromBrandJson(Map<String, dynamic> json) {
    final userModel = ProfileIdentityModel.fromBrandJson(
      json,
      fallbackEmail: userEmail.value,
      fallbackPhone: userPhone.value,
    );
    _applyProfileUser(userModel);

    // Brand uses similar structure - reuse agency logic with slight modifications
    final companyName =
        _stringOrNull(json['brandName']) ??
        _stringOrNull(json['companyName']) ??
        '';
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    brandName.value = companyName;
    _setBioText(json['bio'] as String? ?? '');
    _setBrandWebsite(_stringOrNull(json['website']));
    profileImageFile.value = null;

    appUserSession.brandProfileJson.value = Map<String, dynamic>.from(json);

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
      final thana = _stringOrNull(json['thana']) ?? '';
      final zilla = _stringOrNull(json['zilla']) ?? '';
      final fullAddress = _stringOrNull(json['fullAddress']) ?? '';

      if (thana.isNotEmpty || zilla.isNotEmpty || fullAddress.isNotEmpty) {
        locations.assignAll([
          UserLocation(
            name: 'Office',
            thana: thana,
            zilla: zilla,
            fullAddress: fullAddress,
          ),
        ]);
      } else {
        locations.clear();
      }
    }

    final primaryLocation = locations.isNotEmpty ? locations.first : null;
    final secondaryPhone =
        _stringOrNull(json['secondaryPhone']) ??
        _stringOrNull(json['secondaryPhoneNumber']) ??
        '';
    final emailValue = _stringOrNull(json['email']) ?? userEmail.value;
    final phoneValue = _stringOrNull(json['phone']) ?? userPhone.value;

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

    // Brand/client verification list shown on the progress page.
    verificationInprogressItems.assignAll(
      _buildBrandVerificationItems(json, socialLinks: socialLinks),
    );

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
      ProfileField(
        label: 'Thana',
        hintText: 'Enter Thana',
        value: primaryLocation?.thana ?? (_stringOrNull(json['thana']) ?? ''),
        isRequired: true,
      ),
      ProfileField(
        label: 'Zilla',
        hintText: 'Enter Zilla',
        value: primaryLocation?.zilla ?? (_stringOrNull(json['zilla']) ?? ''),
        isRequired: true,
      ),
      ProfileField(
        label: 'Full Address',
        hintText: 'Enter Full Address',
        value:
            primaryLocation?.fullAddress ??
            (_stringOrNull(json['fullAddress']) ?? ''),
        isRequired: true,
      ),
      ProfileField(
        label: 'Email Address',
        hintText: 'Enter Email Address',
        value: emailValue,
        isRequired: true,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Phone Number',
        hintText: 'Enter Phone Number',
        value: phoneValue,
        isRequired: true,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Secondary Phone Number (Optional)',
        hintText: 'Enter Secondary Phone Number',
        value: secondaryPhone,
        isReadOnly: true,
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
      final status =
          _stringOrNull(verification['status']) ??
          _stringOrNull(verification['nidStatus']) ??
          _stringOrNull(verification['tradeLicenseStatus']) ??
          _stringOrNull(verification['tinStatus']) ??
          _stringOrNull(verification['binStatus']);

      final parsed = _parseVerificationState(status);
      if (parsed != null) return parsed;
    }
    // If no verification object but document exists, assume under review
    if (documentNumber != null && documentNumber.toString().isNotEmpty) {
      return VerificationState.underReview;
    }
    return VerificationState.unverified;
  }

  VerificationState? _parseVerificationState(dynamic value) {
    final normalizedStatus = value?.toString().trim().toLowerCase();
    if (normalizedStatus == null || normalizedStatus.isEmpty) return null;

    if (normalizedStatus == 'approved' || normalizedStatus == 'verified') {
      return VerificationState.verified;
    }
    if (normalizedStatus == 'pending' ||
        normalizedStatus == 'under_review' ||
        normalizedStatus == 'under review' ||
        normalizedStatus == 'in_review' ||
        normalizedStatus == 'in review' ||
        normalizedStatus == 'reviewing') {
      return VerificationState.underReview;
    }
    if (normalizedStatus == 'rejected' || normalizedStatus == 'unverified') {
      return VerificationState.unverified;
    }

    return null;
  }

  VerificationState _getSocialVerificationState(dynamic socialLinks) {
    if (socialLinks is! List || socialLinks.isEmpty) {
      return VerificationState.unverified;
    }

    final hasVerified = socialLinks.any((link) {
      if (link is! Map) return false;
      final parsed = _parseVerificationState(link['status']);
      return parsed == VerificationState.verified;
    });

    return hasVerified
        ? VerificationState.verified
        : VerificationState.underReview;
  }

  VerificationState _getPhoneVerificationState(Map<String, dynamic> json) {
    final user = json['user'] as Map?;
    final directVerified =
        _toBool(json['isPhoneVerified']) ??
        _toBool(json['phoneVerified']) ??
        _toBool(user?['isPhoneVerified']) ??
        _toBool(user?['phoneVerified']);

    if (directVerified != null) {
      return directVerified
          ? VerificationState.verified
          : VerificationState.unverified;
    }

    final fromStatus =
        _parseVerificationState(json['phoneStatus']) ??
        _parseVerificationState(user?['phoneStatus']);
    if (fromStatus != null) return fromStatus;

    final fromObject = _getVerificationStateFromJson(
      json['phoneVerification'],
      null,
    );
    if (fromObject != VerificationState.unverified) return fromObject;

    final phone = _stringOrNull(json['phone']) ?? _stringOrNull(user?['phone']);
    return phone != null
        ? VerificationState.verified
        : VerificationState.unverified;
  }

  VerificationState _getEmailVerificationState(Map<String, dynamic> json) {
    final user = json['user'] as Map?;
    final directVerified =
        _toBool(json['isEmailVerified']) ??
        _toBool(json['emailVerified']) ??
        _toBool(user?['isEmailVerified']) ??
        _toBool(user?['emailVerified']);

    if (directVerified != null) {
      return directVerified
          ? VerificationState.verified
          : VerificationState.unverified;
    }

    final fromStatus =
        _parseVerificationState(json['emailStatus']) ??
        _parseVerificationState(user?['emailStatus']);
    if (fromStatus != null) return fromStatus;

    final fromObject = _getVerificationStateFromJson(
      json['emailVerification'],
      null,
    );
    if (fromObject != VerificationState.unverified) return fromObject;

    return VerificationState.unverified;
  }

  List<VerificationInprogressItem> _buildBrandVerificationItems(
    Map<String, dynamic> json, {
    dynamic socialLinks,
  }) {
    final resolvedSocialLinks = socialLinks ?? json['socialLinks'];

    return [
      VerificationInprogressItem(
        title: 'Social Profile Verification',
        state: _getSocialVerificationState(resolvedSocialLinks),
      ),
      VerificationInprogressItem(
        title: 'Phone No. Verification',
        state: _getPhoneVerificationState(json),
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
      VerificationInprogressItem(
        title: 'Email',
        state: _getEmailVerificationState(json),
      ),
    ];
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
    newSocialHandleController.dispose();

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

    final signedUrlResult = await ApiErrorHandler.call(
      () => uploadService.createSignedUrl(
        fileName: fileName,
        fileType: contentType,
        module: module,
      ),
    );
    if (!signedUrlResult.isSuccess || signedUrlResult.data == null) {
      return '';
    }

    final signedUrl = signedUrlResult.data!;

    final uploadResult = await ApiErrorHandler.call(
      () => uploadService.uploadFileToSignedUrl(
        uploadUrl: signedUrl.uploadUrl,
        file: file,
        contentType: contentType,
      ),
    );
    if (!uploadResult.isSuccess) {
      return '';
    }

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
        final wrappedResult = await ApiErrorHandler.call(
          () => service.updateBasicInfo(profileImage: url, bio: bioText.value),
        );
        final result =
            wrappedResult.data ??
            ApiResult.failure(wrappedResult.error ?? 'unknown_error'.tr);
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
        final wrappedResult = await ApiErrorHandler.call(
          () => service.removeProfileImage(),
        );
        final result =
            wrappedResult.data ??
            ApiResult.failure(wrappedResult.error ?? 'unknown_error'.tr);
        if (!result.isSuccess) return;
        await _fetchProfileData();
        return;
      }

      if (accountTypeService.isAdAgency) {
        final service = Get.find<AgencyProfileService>();
        final result = await ApiErrorHandler.call(() => service.removeLogo());
        if (!result.isSuccess) return;
        await _fetchProfileData();
        return;
      }

      if (accountTypeService.isBrand) {
        final service = Get.find<BrandOnboardingService>();
        final result = await ApiErrorHandler.call(
          () => service.removeProfileImage(),
        );
        if (!result.isSuccess) return;
        await _fetchProfileData();
        return;
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

          final wrappedResult = await ApiErrorHandler.call(
            () => service.addBankPayout(
              bankName: bankName,
              accountHolderName: holder,
              accountNo: accountNo,
              branchName: branchName,
              routingNo: routing,
            ),
          );
          final result =
              wrappedResult.data ??
              ApiResult.failure(wrappedResult.error ?? 'unknown_error'.tr);

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

          final wrappedResult = await ApiErrorHandler.call(
            () => service.addMobilePayout(
              accountType: accountType.isEmpty ? 'Bkash' : accountType,
              accountHolderName: holder,
              accountNo: accountNo,
            ),
          );
          final result =
              wrappedResult.data ??
              ApiResult.failure(wrappedResult.error ?? 'unknown_error'.tr);

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

    final payoutAccountNo = (payout.isBank ? payout.accountNo : payout.bKashNo)
        ?.trim();

    if (!accountTypeService.isInfluencer) {
      if (accountTypeService.isAdAgency) {
        if (payoutAccountNo != null && payoutAccountNo.isNotEmpty) {
          final agencyService = Get.find<AgencyProfileService>();
          final result = await ApiErrorHandler.call(
            () => agencyService.removePayout(
              type: payout.isBank ? 'bank' : 'mobile',
              accountNo: payoutAccountNo,
            ),
          );
          if (!result.isSuccess) return;
          await _fetchProfileData();
        }
      }

      payoutMethods.remove(payout);
      return;
    }

    if (payoutAccountNo == null || payoutAccountNo.isEmpty) {
      Get.snackbar('Error', 'Unable to remove payout: missing account number');
      return;
    }

    isSavingProfile.value = true;
    try {
      final service = Get.find<InfluencerProfileService>();
      final wrappedResult = await ApiErrorHandler.call(
        () => service.removePayout(
          type: payout.payoutType,
          accountNo: payoutAccountNo,
        ),
      );
      final result =
          wrappedResult.data ??
          ApiResult.failure(wrappedResult.error ?? 'unknown_error'.tr);

      if (result.isSuccess) {
        payoutMethods.removeWhere(
          (item) =>
              item.payoutType == payout.payoutType &&
              ((item.isBank ? item.accountNo : item.bKashNo)?.trim() ==
                  payoutAccountNo),
        );
        await _fetchProfileData();
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
    _apiData.profileUser.value = null;
    profileCompletion.value = 0.35;
    _setBioText('');
    serviceFeeText.value = '';
    dollarRateText.value = '';
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
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Phone Number',
        hintText: 'Enter Phone Number',
        value: userPhone.value,
        isRequired: true,
        isReadOnly: true,
      ),
      ProfileField(
        label: 'Secondary Phone Number (Optional)',
        hintText: 'Enter Secondary Phone Number',
        value: '',
        isRequired: false,
        isReadOnly: true,
      ),
    ]);
    _syncProfileFieldDefaults();

    if (isBrand) {
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
    } else {
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
          title: 'Skills',
          state: VerificationState.unverified,
        ),
        VerificationInprogressItem(
          title: 'Niches',
          state: VerificationState.unverified,
        ),
        VerificationInprogressItem(
          title: 'Email',
          state: VerificationState.unverified,
        ),
      ]);
    }

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
      skillStatuses.clear();
    } else {
      skills.clear();
      skillStatuses.clear();
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
    if (isSavingBrandAssetsSection.value) return;
    final website = brandWebsiteController.text.trim();
    final handles = brandAssets
        .map(
          (e) => {'platform': e.platform.name, 'url': e.controller.text.trim()},
        )
        .toList();

    if (!accountTypeService.isBrand) return;

    isSavingBrandAssetsSection.value = true;
    try {
      final service = Get.find<BrandOnboardingService>();
      final result = await ApiErrorHandler.call(
        () => service.updateSocialLinks(website: website, socialLinks: handles),
      );

      if (!result.isSuccess) return;

      await _fetchProfileData();

      Get.snackbar(
        'success_title'.tr,
        'brand_assets_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingBrandAssetsSection.value = false;
    }
  }

  Future<void> saveClientProfileSettings() async {
    if (!accountTypeService.isBrand || isSavingProfileSettings.value) return;

    final companyName = (profileFieldValues['Company Name'] ?? '').trim();
    final firstName = (profileFieldValues['First Name'] ?? '').trim();
    final lastName = (profileFieldValues['Last Name'] ?? '').trim();
    final thana = (profileFieldValues['Thana'] ?? '').trim();
    final zilla = (profileFieldValues['Zilla'] ?? '').trim();
    final fullAddress = (profileFieldValues['Full Address'] ?? '').trim();

    if (companyName.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      Get.snackbar('Error', 'Company, first name and last name are required.');
      return;
    }

    if (thana.isEmpty || zilla.isEmpty || fullAddress.isEmpty) {
      Get.snackbar('Error', 'Thana, zilla and full address are required.');
      return;
    }

    isSavingProfileSettings.value = true;
    try {
      final brandService = Get.find<BrandOnboardingService>();

      final profileResult = await ApiErrorHandler.call(
        () => brandService.updateBasicInfo(
          brandName: companyName,
          firstName: firstName,
          lastName: lastName,
        ),
      );
      if (!profileResult.isSuccess) return;

      final addressResult = await ApiErrorHandler.call(
        () => brandService.updateAddress(
          addressName: 'Office',
          thana: thana,
          zilla: zilla,
          fullAddress: fullAddress,
        ),
      );
      if (!addressResult.isSuccess) return;

      await _fetchProfileData();
      Get.snackbar(
        'success_title'.tr,
        'profile_update_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingProfileSettings.value = false;
    }
  }

  Future<void> saveClientVerificationMethods() async {
    if (!accountTypeService.isBrand || isSavingVerificationSection.value) {
      return;
    }

    if (isUploadingVerificationMedia) {
      Get.snackbar(
        'Error',
        'Please wait for media upload to complete.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSavingVerificationSection.value = true;

    try {
      final brandService = Get.find<BrandOnboardingService>();
      var hasSubmittedAny = false;

      final nidNumber = nidNumberController.text.trim();
      final nidFrontUrl = nidFrontUploadedUrl.value?.trim() ?? '';
      final nidBackUrl = nidBackUploadedUrl.value?.trim() ?? '';
      if (nidNumber.isNotEmpty ||
          nidFrontUrl.isNotEmpty ||
          nidBackUrl.isNotEmpty) {
        if (nidNumber.isEmpty || nidFrontUrl.isEmpty || nidBackUrl.isEmpty) {
          Get.snackbar(
            'Error',
            'NID number, front image and back image are required together.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final nidResult = await ApiErrorHandler.call(
          () => brandService.updateNid(
            nidNumber: nidNumber,
            nidFrontImg: nidFrontUrl,
            nidBackImg: nidBackUrl,
          ),
        );
        if (!nidResult.isSuccess) return;
        hasSubmittedAny = true;
      }

      final tradeNumber = tradeNumberController.text.trim();
      final tradeUrl = tradeLicenseUploadedUrl.value?.trim() ?? '';
      if (tradeNumber.isNotEmpty || tradeUrl.isNotEmpty) {
        if (tradeNumber.isEmpty || tradeUrl.isEmpty) {
          Get.snackbar(
            'Error',
            'Trade license number and image are required together.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final tradeResult = await ApiErrorHandler.call(
          () => brandService.updateTradeLicense(
            tradeLicenseNumber: tradeNumber,
            tradeLicenseImg: tradeUrl,
          ),
        );
        if (!tradeResult.isSuccess) return;
        hasSubmittedAny = true;
      }

      final tinNumber = tinNumberController.text.trim();
      final tinUrl = tinUploadedUrl.value?.trim() ?? '';
      if (tinNumber.isNotEmpty || tinUrl.isNotEmpty) {
        if (tinNumber.isEmpty || tinUrl.isEmpty) {
          Get.snackbar(
            'Error',
            'TIN number and certificate image are required together.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final tinResult = await ApiErrorHandler.call(
          () => brandService.updateTin(tinNumber: tinNumber, tinImage: tinUrl),
        );
        if (!tinResult.isSuccess) return;
        hasSubmittedAny = true;
      }

      final binNumber = binNumberController.text.trim();
      if (binNumber.isNotEmpty) {
        final binResult = await ApiErrorHandler.call(
          () => brandService.updateBin(binNumber: binNumber),
        );
        if (!binResult.isSuccess) return;
        hasSubmittedAny = true;
      }

      if (!hasSubmittedAny) {
        Get.snackbar(
          'Info',
          'No verification changes to submit.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _fetchProfileData();
      Get.snackbar(
        'success_title'.tr,
        'profile_update_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingVerificationSection.value = false;
    }
  }

  // -------------------- SKILLS (Influencer only) --------------------
  final skillsExpanded = true.obs;

  void toggleSkills() => skillsExpanded.toggle();

  Future<void> showAddSkillDialog() async {
    await _ensureAllowedSkillsLoaded();
    if (allowedSkills.isEmpty) {
      Get.snackbar(
        'Skills unavailable',
        'Could not load available skills right now.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final selected = await Get.dialog<List<String>>(
      TagSelectionDialog(
        title: 'Skills',
        searchHint: 'Search Skills',
        options: allowedSkills.toList(growable: false),
        initialSelected: skills.toList(growable: false),
      ),
      barrierDismissible: true,
    );

    if (selected == null) return;
    final nextStatuses = <String, String>{};
    for (final skill in selected) {
      final key = skill.toLowerCase();
      nextStatuses[key] = skillStatuses[key] ?? 'pending';
    }
    skills.assignAll(selected);
    skillStatuses.assignAll(nextStatuses);
  }

  Future<void> _ensureAllowedSkillsLoaded() async {
    if (allowedSkills.isNotEmpty || isLoadingAllowedSkills.value) return;
    isLoadingAllowedSkills.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchSkills(),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      final items = result.data!
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      allowedSkills.assignAll(items);
    }
    isLoadingAllowedSkills.value = false;
  }

  // -------------------- LOCATIONS (Influencer only) --------------------
  final locationsExpanded = true.obs;

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

      final wrappedResult = await ApiErrorHandler.call(
        () => service.addAddress(
          addressName: name,
          thana: thana,
          zilla: zilla,
          fullAddress: full,
        ),
      );
      final result =
          wrappedResult.data ??
          ApiResult.failure(wrappedResult.error ?? 'unknown_error'.tr);

      if (result.isSuccess && result.data != null) {
        influencerProfile.value = result.data;
        _populateFromInfluencerProfile(result.data!);
        await _fetchProfileData();
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
      final logoutResult = await ApiErrorHandler.call(
        () => _authService.logout(),
      );
      if (!logoutResult.isSuccess) return;

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
  void toggleDollarRate() => dollarRateExpanded.toggle();
  void toggleSocial() => socialExpanded.toggle();
  void toggleNiche() => nicheExpanded.toggle();
  void toggleSettings() => settingsExpanded.toggle();
  void toggleVerification() => verificationExpanded.toggle();
  void togglePayout() => payoutExpanded.toggle();

  // Placeholder: save verification methods changes
  Future<void> saveAgencyServiceFee() async {
    if (!accountTypeService.isAdAgency || isSavingServiceFee.value) return;

    final value = serviceFeeText.value.trim();
    if (value.isEmpty) {
      Get.snackbar(
        'Error',
        'Service fee is required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSavingServiceFee.value = true;
    try {
      final agencyService = Get.find<AgencyProfileService>();
      final result = await ApiErrorHandler.call(
        () => agencyService.updateServiceFee(value),
      );
      if (!result.isSuccess) return;

      await _fetchProfileData();
      Get.snackbar(
        'success_title'.tr,
        'Service fee saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingServiceFee.value = false;
    }
  }

  Future<void> saveAgencyDollarRate() async {
    if (!accountTypeService.isAdAgency || isSavingDollarRate.value) return;

    final raw = dollarRateText.value.trim();
    if (raw.isEmpty) {
      Get.snackbar(
        'Error',
        'Dollar rate is required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final parsed = num.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      Get.snackbar(
        'Error',
        'Enter a valid dollar rate.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSavingDollarRate.value = true;
    try {
      final agencyService = Get.find<AgencyProfileService>();
      final result = await ApiErrorHandler.call(
        () => agencyService.updateDollarRate(parsed),
      );
      if (!result.isSuccess) return;

      await _fetchProfileData();
      Get.snackbar(
        'success_title'.tr,
        'Dollar rate saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingDollarRate.value = false;
    }
  }

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

        final basicInfoWrapped = await ApiErrorHandler.call(
          () => service.updateBasicInfo(
            firstName: firstNameValue,
            lastName: lastNameValue,
            bio: bioText.value,
            website: websiteValue,
          ),
        );
        final basicInfoResult =
            basicInfoWrapped.data ??
            ApiResult.failure(basicInfoWrapped.error ?? 'unknown_error'.tr);
        if (!basicInfoResult.isSuccess) return;

        final nichesWrapped = await ApiErrorHandler.call(
          () => service.updateNiches(niches.toList(growable: false)),
        );
        final nichesResult =
            nichesWrapped.data ??
            ApiResult.failure(nichesWrapped.error ?? 'unknown_error'.tr);
        if (!nichesResult.isSuccess) return;

        if (skills.isNotEmpty) {
          final skillsWrapped = await ApiErrorHandler.call(
            () => service.updateSkills(skills.toList()),
          );
          final skillsResult =
              skillsWrapped.data ??
              ApiResult.failure(skillsWrapped.error ?? 'unknown_error'.tr);
          if (!skillsResult.isSuccess) return;
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
            final socialWrapped = await ApiErrorHandler.call(
              () => service.updateSocialLinks(updatedLinks),
            );
            final socialResult =
                socialWrapped.data ??
                ApiResult.failure(socialWrapped.error ?? 'unknown_error'.tr);
            if (!socialResult.isSuccess) return;
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
          final nidWrapped = await ApiErrorHandler.call(
            () => service.submitNidVerification(
              nidNumber: nidNumber,
              nidFrontImg: frontUrl ?? '',
              nidBackImg: backUrl ?? '',
            ),
          );
          final nidResult =
              nidWrapped.data ??
              ApiResult.failure(nidWrapped.error ?? 'unknown_error'.tr);
          if (!nidResult.isSuccess) return;
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
            () => brandService.updateTin(
              tinNumber: tinNumber,
              tinImage: tinUrl ?? '',
            ),
          );
          if (!tinResult.isSuccess) return;
        }

        final binNumber = binNumberController.text.trim();
        if (binNumber.isNotEmpty) {
          final binResult = await ApiErrorHandler.call(
            () => brandService.updateBin(binNumber: binNumber),
          );
          if (!binResult.isSuccess) return;
        }
      } else if (accountTypeService.isAdAgency) {
        final agencyService = Get.find<AgencyProfileService>();

        final agencyNameValue =
            profileFieldValues['Agency Name'] ?? profileName.value;
        final firstNameValue = profileFieldValues['First Name'] ?? '';
        final lastNameValue = profileFieldValues['Last Name'] ?? '';
        final thanaValue = (profileFieldValues['Thana'] ?? '').trim();
        final zillaValue = (profileFieldValues['Zilla'] ?? '').trim();
        final fullAddressValue = (profileFieldValues['Full Address'] ?? '')
            .trim();

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

        if (thanaValue.isNotEmpty &&
            zillaValue.isNotEmpty &&
            fullAddressValue.isNotEmpty) {
          final addressResult = await ApiErrorHandler.call(
            () => agencyService.updateAddress(
              addressName: 'Office',
              thana: thanaValue,
              zilla: zillaValue,
              fullAddress: fullAddressValue,
            ),
          );
          if (!addressResult.isSuccess) return;
        }

        await ApiErrorHandler.call(
          () => agencyService.updateNiches(niches.toList(growable: false)),
        );

        if (skills.isNotEmpty) {
          final skillsResult = await ApiErrorHandler.call(
            () => agencyService.updateSkills(skills.toList(growable: false)),
          );
          if (!skillsResult.isSuccess) return;
        }

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
        if (socialPayload.isNotEmpty) {
          final socialResult = await ApiErrorHandler.call(
            () => agencyService.updateSocials(
              website: null,
              socialLinks: socialPayload,
            ),
          );
          if (!socialResult.isSuccess) return;
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
