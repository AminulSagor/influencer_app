import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';
import '../models/influencer_profile_model.dart';

class InfluencerProfileService {
  final ApiClient _api;
  InfluencerProfileService(this._api);

  /// Fetches the current influencer's profile
  Future<ApiResult<InfluencerProfile>> getProfile() async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.get('/influencer/profile');
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Updates basic profile info (firstName, lastName, bio, profileImage)
  Future<ApiResult<InfluencerProfile>> updateBasicInfo({
    String? firstName,
    String? lastName,
    String? bio,
    String? profileImage,
  }) async {
    return ApiErrorHandler.call(() async {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (bio != null) data['bio'] = bio;
      if (profileImage != null) data['profileImage'] = profileImage;

      final res = await _api.dio.patch(
        '/influencer/profile/basic-info',
        data: data,
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Removes the profile image
  Future<ApiResult<void>> removeProfileImage() async {
    return ApiErrorHandler.call(() async {
      await _api.dio.delete('/influencer/profile/profile-image');
    });
  }

  /// Updates influencer niches
  Future<ApiResult<InfluencerProfile>> updateNiches(List<String> niches) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.patch(
        '/influencer/profile/niches',
        data: {'niches': niches},
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Removes a specific niche
  Future<ApiResult<void>> removeNiche(String nicheName) async {
    return ApiErrorHandler.call(() async {
      await _api.dio.delete('/influencer/profile/niche/$nicheName');
    });
  }

  /// Updates influencer skills
  Future<ApiResult<InfluencerProfile>> updateSkills(List<String> skills) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.patch(
        '/influencer/profile/skills',
        data: {'skills': skills},
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Adds a new address
  Future<ApiResult<InfluencerProfile>> addAddress({
    required String addressName,
    required String thana,
    required String zilla,
    required String fullAddress,
  }) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.post(
        '/influencer/profile/address',
        data: {
          'addresses': {
            'addressName': addressName,
            'thana': thana,
            'zilla': zilla,
            'fullAddress': fullAddress,
          },
        },
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Adds a bank payout method
  Future<ApiResult<InfluencerProfile>> addBankPayout({
    required String bankName,
    required String accountHolderName,
    required String accountNo,
    required String branchName,
    required String routingNo,
  }) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.post(
        '/influencer/profile/payouts',
        data: {
          'bank': {
            'bankName': bankName,
            'bankAccHolderName': accountHolderName,
            'bankAccNo': accountNo,
            'bankBranchName': branchName,
            'bankRoutingNo': routingNo,
          },
        },
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Adds a mobile banking payout method
  Future<ApiResult<InfluencerProfile>> addMobilePayout({
    required String accountType, // e.g., "Bkash", "Nagad", "Rocket"
    required String accountHolderName,
    required String accountNo,
  }) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.post(
        '/influencer/profile/payouts',
        data: {
          'mobileBanking': {
            'accountType': accountType,
            'accountHolderName': accountHolderName,
            'accountNo': accountNo,
          },
        },
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Removes a payout method
  /// [type] can be "bank" or "mobileBanking"
  Future<ApiResult<void>> removePayout({
    required String type,
    required String id,
  }) async {
    return ApiErrorHandler.call(() async {
      await _api.dio.delete(
        '/influencer/profile/payouts',
        data: {'type': type, 'id': id},
      );
    });
  }

  /// Updates social links
  Future<ApiResult<InfluencerProfile>> updateSocialLinks(
    List<InfluencerSocialLink> socialLinks, {
    String? thana,
    String? zilla,
    String? fullAddress,
  }) async {
    return ApiErrorHandler.call(() async {
      final data = <String, dynamic>{
        'socialLinks': socialLinks.map((e) => e.toJson()).toList(),
      };
      _applyOnboardingAddress(
        data,
        thana: thana,
        zilla: zilla,
        fullAddress: fullAddress,
      );
      final res = await _api.dio.patch(
        '/influencer/profile/onboarding',
        data: data,
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Updates website URL
  Future<ApiResult<InfluencerProfile>> updateWebsite(
    String? website, {
    String? thana,
    String? zilla,
    String? fullAddress,
  }) async {
    return ApiErrorHandler.call(() async {
      final data = <String, dynamic>{'website': website};
      _applyOnboardingAddress(
        data,
        thana: thana,
        zilla: zilla,
        fullAddress: fullAddress,
      );
      final res = await _api.dio.patch(
        '/influencer/profile/onboarding',
        data: data,
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Submits NID verification documents
  Future<ApiResult<InfluencerProfile>> submitNidVerification({
    required String nidNumber,
    required String nidFrontImg,
    required String nidBackImg,
    String? thana,
    String? zilla,
    String? fullAddress,
  }) async {
    return ApiErrorHandler.call(() async {
      final data = {
        'nidNumber': nidNumber,
        'nidFrontImg': nidFrontImg,
        'nidBackImg': nidBackImg,
      };
      _applyOnboardingAddress(
        data,
        thana: thana,
        zilla: zilla,
        fullAddress: fullAddress,
      );
      final res = await _api.dio.patch(
        '/influencer/profile/onboarding',
        data: data,
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  void _applyOnboardingAddress(
    Map<String, dynamic> data, {
    String? thana,
    String? zilla,
    String? fullAddress,
  }) {
    final safeThana = thana?.trim();
    final safeZilla = zilla?.trim();
    final safeFullAddress = fullAddress?.trim();

    if ((safeThana ?? '').isEmpty ||
        (safeZilla ?? '').isEmpty ||
        (safeFullAddress ?? '').isEmpty) {
      return;
    }

    data['thana'] = safeThana;
    data['zilla'] = safeZilla;
    data['fullAddress'] = safeFullAddress;
  }
}
