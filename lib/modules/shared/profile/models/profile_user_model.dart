import 'package:get/get.dart';
import 'package:influencer_app/modules/influencer/models/influencer_profile_model.dart';

import '../enums/profile_status.dart';
import 'payout_method.dart';
import 'profile_field.dart';
import 'social_account.dart';
import 'user_location.dart';
import 'verification_inprogress_item.dart';

class ProfileIdentityModel {
  final String displayName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String location;
  final bool isVerified;

  const ProfileIdentityModel({
    required this.displayName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.location,
    required this.isVerified,
  });

  factory ProfileIdentityModel.fromInfluencer(
    InfluencerProfile profile, {
    String fallbackEmail = '',
    String fallbackPhone = '',
  }) {
    final locationParts = <String>[
      profile.primaryAddress?.thana?.trim() ?? '',
      profile.primaryAddress?.zilla?.trim() ?? '',
      profile.primaryAddress?.country?.trim() ?? '',
    ].where((part) => part.isNotEmpty).toList(growable: false);

    return ProfileIdentityModel(
      displayName: profile.fullName.trim().isNotEmpty
          ? profile.fullName.trim()
          : 'Influencer',
      email: fallbackEmail.trim(),
      phone: fallbackPhone.trim(),
      avatarUrl: profile.displayImage?.trim() ?? '',
      location: locationParts.isEmpty
          ? 'Dhaka, Bangladesh'
          : locationParts.join(', '),
      isVerified: profile.isOnboardingComplete,
    );
  }

  factory ProfileIdentityModel.fromAgencyJson(
    Map<String, dynamic> json, {
    String fallbackEmail = '',
    String fallbackPhone = '',
  }) {
    final agencyName = (json['agencyName'] ?? '').toString().trim();
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();

    final displayName = agencyName.isNotEmpty
        ? agencyName
        : ('$firstName $lastName').trim();

    final avatarUrl = _firstNonEmpty([
      json['profileImg'],
      json['profileImage'],
      json['logo'],
    ]);

    final email = _firstNonEmpty([json['email'], (json['user'] as Map?)?['email']]);
    final phone = _firstNonEmpty([json['phone'], (json['user'] as Map?)?['phone']]);

    final address = json['address'];
    String location = 'Dhaka, Bangladesh';
    if (address is Map) {
      final fullAddress = (address['fullAddress'] ?? '').toString().trim();
      final thana = (address['thana'] ?? '').toString().trim();
      final zilla = (address['zilla'] ?? '').toString().trim();
      final country = (address['country'] ?? '').toString().trim();
      final parts = <String>[
        if (fullAddress.isNotEmpty) fullAddress,
        if (thana.isNotEmpty) thana,
        if (zilla.isNotEmpty) zilla,
        if (country.isNotEmpty) country,
      ];
      if (parts.isNotEmpty) location = parts.join(', ');
    }

    return ProfileIdentityModel(
      displayName: displayName,
      email: email.isNotEmpty ? email : fallbackEmail.trim(),
      phone: phone.isNotEmpty ? phone : fallbackPhone.trim(),
      avatarUrl: avatarUrl,
      location: location,
      isVerified: _toBool(json['isVerified']) ?? false,
    );
  }

  factory ProfileIdentityModel.fromBrandJson(
    Map<String, dynamic> json, {
    String fallbackEmail = '',
    String fallbackPhone = '',
  }) {
    final companyName = _firstNonEmpty([json['brandName'], json['companyName']]);
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();

    final displayName = companyName.isNotEmpty
        ? companyName
        : ('$firstName $lastName').trim();

    final avatarUrl = _firstNonEmpty([
      json['profileImg'],
      json['profileImage'],
      json['logo'],
    ]);

    final email = _firstNonEmpty([json['email'], (json['user'] as Map?)?['email']]);
    final phone = _firstNonEmpty([json['phone'], (json['user'] as Map?)?['phone']]);

    String location = 'Dhaka, Bangladesh';
    final addresses = json['addresses'] as List?;
    if (addresses != null && addresses.isNotEmpty && addresses.first is Map) {
      final addr = addresses.first as Map;
      final fullAddress = (addr['fullAddress'] ?? '').toString().trim();
      final thana = (addr['thana'] ?? '').toString().trim();
      final zilla = (addr['zilla'] ?? '').toString().trim();
      final parts = <String>[
        if (fullAddress.isNotEmpty) fullAddress,
        if (thana.isNotEmpty) thana,
        if (zilla.isNotEmpty) zilla,
      ];
      if (parts.isNotEmpty) location = parts.join(', ');
    } else {
      final fullAddress = (json['fullAddress'] ?? '').toString().trim();
      final thana = (json['thana'] ?? '').toString().trim();
      final zilla = (json['zilla'] ?? '').toString().trim();
      final parts = <String>[
        if (fullAddress.isNotEmpty) fullAddress,
        if (thana.isNotEmpty) thana,
        if (zilla.isNotEmpty) zilla,
      ];
      if (parts.isNotEmpty) location = parts.join(', ');
    }

    return ProfileIdentityModel(
      displayName: displayName,
      email: email.isNotEmpty ? email : fallbackEmail.trim(),
      phone: phone.isNotEmpty ? phone : fallbackPhone.trim(),
      avatarUrl: avatarUrl,
      location: location,
      isVerified: _toBool(json['isVerified']) ?? false,
    );
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}

class ProfileUserModel {
  final profileStatus = ProfileStatus.verified.obs;
  final profileName = ''.obs;
  final profileLocation = 'Dhaka, Bangladesh'.obs;
  final brandName = ''.obs;
  final profileRating = 4.5.obs;
  final profileRatingCount = 32.obs;
  final profileCompletion = 0.35.obs;

  final bioText = ''.obs;
  final serviceFeeText = ''.obs;
  final dollarRateText = ''.obs;
  final profileImageUrl = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final brandWebsite = ''.obs;

  final socialAccounts = <SocialAccount>[].obs;
  final niches = <String>[].obs;
  final nicheStatuses = <String, String>{}.obs;
  final profileFields = <ProfileField>[].obs;
  final verificationInprogressItems = <VerificationInprogressItem>[].obs;
  final payoutMethods = <PayoutMethod>[].obs;
  final skills = <String>[].obs;
  final locations = <UserLocation>[].obs;

  final influencerProfile = Rxn<InfluencerProfile>();
  final profileUser = Rxn<ProfileIdentityModel>();
}
