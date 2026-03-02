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
    String? website,
  }) async {
    return ApiErrorHandler.call(() async {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (bio != null) data['bio'] = bio;
      if (profileImage != null && profileImage.isNotEmpty) {
        data['profileImg'] = profileImage;
      }
      if (website != null) data['website'] = website;

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
    List<InfluencerSocialLink> socialLinks,
  ) async {
    return ApiErrorHandler.call(() async {
      final data = <String, dynamic>{
        'socialLinks': socialLinks
            .map((e) => {'platform': e.platform, 'url': e.url})
            .toList(),
      };
      final res = await _api.dio.patch(
        '/influencer/profile/edit/social-links',
        data: data,
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Updates website URL
  Future<ApiResult<InfluencerProfile>> updateWebsite(String? website) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.patch(
        '/influencer/profile/basic-info',
        data: {'website': website},
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Submits NID verification documents
  Future<ApiResult<InfluencerProfile>> submitNidVerification({
    required String nidNumber,
    required String nidFrontImg,
    required String nidBackImg,
  }) async {
    return ApiErrorHandler.call(() async {
      final data = <String, dynamic>{
        'nidNumber': nidNumber,
        'nidFrontImg': nidFrontImg,
        'nidBackImg': nidBackImg,
      };
      final res = await _api.dio.patch(
        '/influencer/profile/edit/nid',
        data: data,
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  /// Updates payout methods (bank/mobile) in bulk
  Future<ApiResult<InfluencerProfile>> updatePayouts({
    List<Map<String, dynamic>>? bank,
    List<Map<String, dynamic>>? mobileBanking,
  }) async {
    return ApiErrorHandler.call(() async {
      final data = <String, dynamic>{};
      if (bank != null) data['bank'] = bank;
      if (mobileBanking != null) data['mobileBanking'] = mobileBanking;

      final res = await _api.dio.patch(
        '/influencer/profile/edit/payouts',
        data: data,
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }
}
