import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/api_client.dart';
import 'package:influencer_app/core/services/token_service.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/modules/ad_agency/services/upload_service.dart';
import 'package:influencer_app/modules/influencer/models/influencer_profile_model.dart';
import 'package:influencer_app/modules/influencer/services/influencer_profile_service.dart';
import 'package:influencer_app/modules/brand/services/brand_onboarding_services.dart';

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
  final accountTypeService = Get.find<AccountTypeService>();
  // ---------------------------------------------------------------------------
  // BASIC PROFILE STATE
  // ---------------------------------------------------------------------------

  final profileStatus = ProfileStatus.verified.obs;

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
  // SECTION DATA
  // ---------------------------------------------------------------------------

  final socialAccounts = <SocialAccount>[].obs;
  final niches = <String>[].obs;
  final profileFields = <ProfileField>[].obs;
  final verificationInprogressItems = <VerificationInprogressItem>[].obs;
  final payoutMethods = <PayoutMethod>[].obs;

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
    brandWebsiteController.addListener(_syncBrandWebsiteFromController);
    _fetchProfileData();
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
      _loadMockDataForUnverified();
    }

    isLoadingProfile.value = false;
  }

  /// Fetches influencer profile from API and populates UI fields
  Future<void> _fetchInfluencerProfile() async {
    final apiClient = Get.find<ApiClient>();
    final service = InfluencerProfileService(apiClient);
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
      _loadMockDataForUnverified();
    }
  }

  /// Populates controller fields from InfluencerProfile data
  void _populateFromInfluencerProfile(InfluencerProfile profile) {
    // Basic info
    profileName.value = profile.fullName.isNotEmpty
        ? profile.fullName
        : 'Influencer';
    profileStatus.value = profile.isOnboardingComplete
        ? ProfileStatus.verified
        : ProfileStatus.unverified;
    bioText.value = profile.bio ?? '';
    profileImageUrl.value = profile.displayImage ?? '';
    profileImageFile.value = null;
    profileRating.value = profile.averageRating;
    profileRatingCount.value = profile.totalReviews;

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
      niches.assignAll(profile.niches!.map((n) => n.name).toList());
    } else {
      niches.clear();
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
            bankName: bank.bankName,
            accountName: bank.bankAccHolderName,
            accountNo: bank.bankAccNo,
            routingNumber: bank.bankRoutingNo ?? '',
            isApproved: bank.isApproved,
          ),
        );
      }

      for (final mobile in profile.payouts!.mobileAccounts) {
        methods.add(
          PayoutMethod.bKash(
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
      ),
      ProfileField(
        label: 'Website',
        hintText: 'Enter Website URL',
        value: profile.website ?? '',
        isRequired: false,
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

  UserLocation? _primaryLocationForOnboarding() {
    if (locations.isNotEmpty) return locations.first;
    final addr = influencerProfile.value?.primaryAddress;
    if (addr == null) return null;
    return UserLocation(
      name: addr.addressName ?? '',
      thana: addr.thana ?? '',
      zilla: addr.zilla ?? '',
      fullAddress: addr.fullAddress ?? '',
    );
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
    final token = await TokenService().getAccessToken();
    if (token == null || token.trim().isEmpty) return;

    final payload = _decodeJwtPayload(token);
    if (payload == null) return;

    final email = _stringOrNull(payload['email']);
    final phone = _stringOrNull(payload['phone']);

    if (email != null) userEmail.value = email;
    if (phone != null) userPhone.value = phone;
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

  /// Fetches agency profile from API and populates UI fields
  Future<void> _fetchAgencyProfile() async {
    final apiClient = Get.find<ApiClient>();
    try {
      final res = await apiClient.dio.get('/agency/profile');
      final json = res.data as Map<String, dynamic>;

      debugPrint('📋 AGENCY PROFILE LOADED:');
      debugPrint('  Name: ${json['agencyName']}');
      debugPrint('  isOnboardingComplete: ${json['isOnboardingComplete']}');

      _populateFromAgencyJson(json);
    } catch (e) {
      debugPrint('❌ Failed to load agency profile: $e');
      _loadMockDataForUnverified();
    }
  }

  /// Fetches brand profile from API and populates UI fields
  Future<void> _fetchBrandProfile() async {
    final apiClient = Get.find<ApiClient>();
    try {
      final res = await apiClient.dio.get('/client/profile');
      final json = res.data as Map<String, dynamic>;

      debugPrint('📋 BRAND PROFILE LOADED:');
      debugPrint('  Name: ${json['firstName']} ${json['lastName']}');
      debugPrint('  isOnboardingComplete: ${json['isOnboardingComplete']}');

      _populateFromBrandJson(json);
    } catch (e) {
      debugPrint('❌ Failed to load brand profile: $e');
      _loadMockDataForUnverified();
    }
  }

  /// Populates controller fields from Agency profile JSON
  void _populateFromAgencyJson(Map<String, dynamic> json) {
    _applyContactFromJson(json);
    final isComplete = json['isOnboardingComplete'] as bool? ?? false;

    // Basic info
    final agencyName = json['agencyName'] as String? ?? '';
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    profileName.value = agencyName.isNotEmpty
        ? agencyName
        : '$firstName $lastName'.trim();
    profileStatus.value = isComplete
        ? ProfileStatus.verified
        : ProfileStatus.unverified;
    bioText.value = json['agencyBio'] as String? ?? '';
    serviceFeeText.value = json['serviceFee']?.toString() ?? '';
    profileImageUrl.value = _stringOrNull(json['logo']) ?? '';
    profileImageFile.value = null;

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
      niches.assignAll(
        niches_.map((n) {
          if (n is String) return n;
          if (n is Map) return n['name'] as String? ?? '';
          return n.toString();
        }).toList(),
      );
    } else {
      niches.clear();
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
              bankName: bankMap['bankName'] as String? ?? '',
              accountName: bankMap['bankAccHolderName'] as String? ?? '',
              accountNo: bankMap['bankAccNo'] as String? ?? '',
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
    _syncProfileFieldDefaults();
  }

  /// Populates controller fields from Brand profile JSON
  void _populateFromBrandJson(Map<String, dynamic> json) {
    _applyContactFromJson(json);
    // Brand uses similar structure - reuse agency logic with slight modifications
    final isComplete = json['isOnboardingComplete'] as bool? ?? false;

    final companyName = json['companyName'] as String? ?? '';
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    profileName.value = companyName.isNotEmpty
        ? companyName
        : '$firstName $lastName'.trim();
    brandName.value = companyName;
    profileStatus.value = isComplete
        ? ProfileStatus.verified
        : ProfileStatus.unverified;
    bioText.value = json['bio'] as String? ?? '';
    _setBrandWebsite(_stringOrNull(json['website']));
    profileImageUrl.value = _stringOrNull(json['logo']) ?? '';
    profileImageFile.value = null;

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
              bankName: bankMap['bankName'] as String? ?? '',
              accountName: bankMap['bankAccHolderName'] as String? ?? '',
              accountNo: bankMap['bankAccNo'] as String? ?? '',
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

    brandWebsiteController.removeListener(_syncBrandWebsiteFromController);
    brandWebsiteController.dispose();
    brandNewLinkController.dispose();
    for (final item in brandAssets) {
      item.controller.dispose();
    }
    newSkillController.dispose();

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
    final apiClient = Get.find<ApiClient>();
    final uploadService = UploadService(apiClient);
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
      profileImageUrl.value = url;

      if (accountTypeService.isInfluencer) {
        final apiClient = Get.find<ApiClient>();
        final service = InfluencerProfileService(apiClient);
        await service.updateBasicInfo(profileImage: url, bio: bioText.value);
      } else if (accountTypeService.isAdAgency) {
        final apiClient = Get.find<ApiClient>();
        await apiClient.dio.patch(
          '/agency/profile/basic-info',
          data: {'logo': url},
        );
      } else if (accountTypeService.isBrand) {
        final apiClient = Get.find<ApiClient>();
        await apiClient.dio.patch('/client/profile', data: {'logo': url});
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
        final apiClient = Get.find<ApiClient>();
        final service = InfluencerProfileService(apiClient);
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
    final isBrand = accountTypeService.isBrand;
    final isAdAgency = accountTypeService.isAdAgency;
    final isInfluencer = accountTypeService.isInfluencer;

    profileStatus.value = ProfileStatus.unverified;
    profileCompletion.value = 0.35;
    bioText.value = '';
    serviceFeeText.value = '';
    profileImageUrl.value = '';
    profileImageFile.value = null;

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

    brandWebsiteController.text = 'styleco.com';
    brandAssets.assignAll([
      BrandAssetItem(
        platform: BrandHandlePlatform.facebook,
        controller: TextEditingController(text: 'fb.com/growbig'),
      ),
    ]);

    if (isInfluencer) {
      skills.assignAll(const [
        'Public Speaking',
        'Voiceovers',
        'Podcasting',
        'Product Photography',
        'Conversion Optimization',
      ]);
    } else {
      skills.clear();
    }

    if (isInfluencer) {
      locations.assignAll(const [
        UserLocation(
          name: 'House',
          thana: 'Banani',
          zilla: 'Dhaka',
          fullAddress: 'House 61, Road 8, Block F, Banani, Dhaka 1213',
        ),
      ]);
    } else {
      locations.clear();
    }
  }

  void _loadMockDataForVerified() {
    profileStatus.value = ProfileStatus.verified;
    profileCompletion.value = 1.0;
    bioText.value =
        'I\'m a lifestyle & fashion influencer helping brands grow with authentic content across multiple social platforms.';
    serviceFeeText.value = '15%';
    profileImageUrl.value = '';
    profileImageFile.value = null;

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
    _syncProfileFieldDefaults();

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

    if (accountTypeService.isInfluencer) {
      skills.assignAll(const [
        'Public Speaking',
        'Voiceovers',
        'Podcasting',
        'Product Photography',
        'Conversion Optimization',
      ]);
    } else {
      skills.clear();
    }

    if (accountTypeService.isInfluencer) {
      locations.assignAll(const [
        UserLocation(
          name: 'House',
          thana: 'Banani',
          zilla: 'Dhaka',
          fullAddress: 'House 61, Road 8, Block F, Banani, Dhaka 1213',
        ),
      ]);
    } else {
      locations.clear();
    }
  }

  // You can expose this to switch state from outside if needed.
  void setProfileStatus(ProfileStatus status) {
    if (status == ProfileStatus.verified) {
      _loadMockDataForVerified();
    } else {
      _loadMockDataForUnverified();
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
    // hook your API here
    // Example payload:
    final website = brandWebsiteController.text.trim();
    final handles = brandAssets
        .map(
          (e) => {
            'platform': e.platform.name,
            'link': e.controller.text.trim(),
          },
        )
        .toList();

    debugPrint('SAVE BRAND ASSETS => website: $website, handles: $handles');

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

  void saveLocationForm() {
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

    final editIndex = editingLocationIndex.value;
    if (editIndex != null && editIndex >= 0 && editIndex < locations.length) {
      locations[editIndex] = newLoc;
    } else {
      locations.add(newLoc);
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
    isSavingProfile.value = true;

    try {
      if (accountTypeService.isInfluencer) {
        final apiClient = Get.find<ApiClient>();
        final service = InfluencerProfileService(apiClient);

        await service.updateBasicInfo(bio: bioText.value);

        if (skills.isNotEmpty) {
          await service.updateSkills(skills.toList());
        }

        if (socialAccounts.isNotEmpty) {
          final existing = influencerProfile.value?.socialLinks ?? [];
          final updatedLinks = existing.isNotEmpty
              ? existing
                    .map(
                      (link) => InfluencerSocialLink(
                        platform: link.platform,
                        url:
                            socialHandleEdits[link.platform.toLowerCase()] ??
                            link.url,
                        status: link.status,
                      ),
                    )
                    .toList()
              : socialAccounts
                    .map(
                      (social) => InfluencerSocialLink(
                        platform: social.platform.toLowerCase(),
                        url:
                            socialHandleEdits[social.platform.toLowerCase()] ??
                            social.handle,
                      ),
                    )
                    .toList();

          final address = _primaryLocationForOnboarding();
          if (!_hasValidOnboardingAddress(address)) {
            Get.snackbar(
              'error'.tr,
              'locations_required_error'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
          await service.updateSocialLinks(
            updatedLinks,
            thana: address?.thana,
            zilla: address?.zilla,
            fullAddress: address?.fullAddress,
          );
        }

        final address = _primaryLocationForOnboarding();
        if (!_hasValidOnboardingAddress(address)) {
          Get.snackbar(
            'error'.tr,
            'locations_required_error'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        final nidNumber = nidNumberController.text.trim();
        if (nidNumber.isNotEmpty &&
            nidFrontPic.value != null &&
            nidBackPic.value != null) {
          final frontUrl = await _uploadFile(
            file: nidFrontPic.value!,
            module: 'influencer-kyc',
          );
          final backUrl = await _uploadFile(
            file: nidBackPic.value!,
            module: 'influencer-kyc',
          );
          await service.submitNidVerification(
            nidNumber: nidNumber,
            nidFrontImg: frontUrl,
            nidBackImg: backUrl,
            thana: address?.thana,
            zilla: address?.zilla,
            fullAddress: address?.fullAddress,
          );
        }
      } else if (accountTypeService.isBrand) {
        final apiClient = Get.find<ApiClient>();
        final brandService = BrandOnboardingService(apiClient);

        final brandNameValue =
            profileFieldValues['Company Name'] ?? brandName.value;
        final firstNameValue = profileFieldValues['First Name'] ?? '';
        final lastNameValue = profileFieldValues['Last Name'] ?? '';

        if (brandNameValue.isNotEmpty ||
            firstNameValue.isNotEmpty ||
            lastNameValue.isNotEmpty) {
          await brandService.updateBasicInfo(
            brandName: brandNameValue,
            firstName: firstNameValue,
            lastName: lastNameValue,
          );
        }

        final nidNumber = nidNumberController.text.trim();
        if (nidNumber.isNotEmpty &&
            nidFrontPic.value != null &&
            nidBackPic.value != null) {
          final frontUrl = await _uploadFile(
            file: nidFrontPic.value!,
            module: 'brand-kyc',
          );
          final backUrl = await _uploadFile(
            file: nidBackPic.value!,
            module: 'brand-kyc',
          );
          await brandService.updateNid(
            nidNumber: nidNumber,
            nidFrontImg: frontUrl,
            nidBackImg: backUrl,
          );
        }

        final tradeNumber = tradeNumberController.text.trim();
        if (tradeNumber.isNotEmpty && tradeLicensePic.value != null) {
          final tradeUrl = await _uploadFile(
            file: tradeLicensePic.value!,
            module: 'brand-kyc',
          );
          await brandService.updateTradeLicense(
            tradeLicenseNumber: tradeNumber,
            tradeLicenseImg: tradeUrl,
          );
        }
      } else if (accountTypeService.isAdAgency) {
        final apiClient = Get.find<ApiClient>();

        final agencyNameValue =
            profileFieldValues['Agency Name'] ?? profileName.value;
        final firstNameValue = profileFieldValues['First Name'] ?? '';
        final lastNameValue = profileFieldValues['Last Name'] ?? '';

        if (agencyNameValue.isNotEmpty ||
            firstNameValue.isNotEmpty ||
            lastNameValue.isNotEmpty) {
          await apiClient.dio.patch(
            '/agency/profile/basic-info',
            data: {
              'agencyName': agencyNameValue,
              'firstName': firstNameValue,
              'lastName': lastNameValue,
            },
          );
        }

        final nidNumber = nidNumberController.text.trim();
        if (nidNumber.isNotEmpty &&
            nidFrontPic.value != null &&
            nidBackPic.value != null) {
          final frontUrl = await _uploadFile(
            file: nidFrontPic.value!,
            module: 'agency-kyc',
          );
          final backUrl = await _uploadFile(
            file: nidBackPic.value!,
            module: 'agency-kyc',
          );
          await apiClient.dio.patch(
            '/agency/profile/nid',
            data: {
              'nidNumber': nidNumber,
              'nidFrontImg': frontUrl,
              'nidBackImg': backUrl,
            },
          );
        }

        final tradeNumber = tradeNumberController.text.trim();
        if (tradeNumber.isNotEmpty && tradeLicensePic.value != null) {
          final tradeUrl = await _uploadFile(
            file: tradeLicensePic.value!,
            module: 'agency-kyc',
          );
          await apiClient.dio.patch(
            '/agency/profile/trade-license',
            data: {
              'tradeLicenseNumber': tradeNumber,
              'tradeLicenseImg': tradeUrl,
            },
          );
        }

        final tinNumber = tinNumberController.text.trim();
        if (tinNumber.isNotEmpty && tinCertificatePic.value != null) {
          final tinUrl = await _uploadFile(
            file: tinCertificatePic.value!,
            module: 'agency-kyc',
          );
          await apiClient.dio.patch(
            '/agency/profile/tin',
            data: {'tinNumber': tinNumber, 'tinImage': tinUrl},
          );
        }

        final binNumber = binNumberController.text.trim();
        if (binNumber.isNotEmpty) {
          await apiClient.dio.patch(
            '/agency/profile/bin',
            data: {'binNumber': binNumber},
          );
        }
      }
    } catch (e) {
      debugPrint('Save update failed: $e');
    } finally {
      isSavingProfile.value = false;
    }
  }
}
