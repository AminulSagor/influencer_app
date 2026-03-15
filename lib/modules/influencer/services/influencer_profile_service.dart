import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';
import '../models/influencer_profile_model.dart';

class InfluencerProfileService {
  final ApiClient _api;
  InfluencerProfileService(this._api);

  Future<ApiResult<InfluencerProfile>> getProfile() async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.get('/influencer/profile');
      return InfluencerProfile.fromJson(res.data);
    });
  }

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

  Future<ApiResult<void>> removeProfileImage() async {
    return ApiErrorHandler.call(() async {
      await _api.dio.delete('/influencer/profile/profile-image');
    });
  }

  Future<ApiResult<InfluencerProfile>> updateNiches(List<String> niches) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.patch(
        '/influencer/profile/niches',
        data: {'niches': niches},
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  Future<ApiResult<void>> removeNiche(String nicheName) async {
    return ApiErrorHandler.call(() async {
      await _api.dio.delete('/influencer/profile/niche/$nicheName');
    });
  }

  Future<ApiResult<InfluencerProfile>> updateSkills(List<String> skills) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.patch(
        '/influencer/profile/skills',
        data: {'skills': skills},
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  Future<ApiResult<InfluencerProfile>> addAddress({
    required String addressName,
    required String thana,
    required String zilla,
    required String fullAddress,
    required bool isDefault,
  }) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.post(
        '/influencer/profile/address',
        data: {
          'addresses': [
            {
              'addressName': addressName,
              'thana': thana,
              'zilla': zilla,
              'fullAddress': fullAddress,
              'country': 'Bangladesh',
              'isDefault': isDefault,
            },
          ],
        },
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

  Future<ApiResult<InfluencerProfile>> updateAddress({
    required String currentAddressName,
    required String addressName,
    required String thana,
    required String zilla,
    required String fullAddress,
    required bool isDefault,
  }) async {
    return ApiErrorHandler.call(() async {
      final encodedName = Uri.encodeComponent(currentAddressName);

      final res = await _api.dio.patch(
        '/influencer/profile/address/$encodedName',
        data: {
          'addressName': addressName,
          'thana': thana,
          'zilla': zilla,
          'fullAddress': fullAddress,
          'country': 'Bangladesh',
          'isDefault': isDefault,
        },
      );

      return InfluencerProfile.fromJson(res.data);
    });
  }

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

  Future<ApiResult<InfluencerProfile>> addMobilePayout({
    required String accountType,
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

  Future<ApiResult<void>> removePayout({
    required String type,
    required String accountNo,
  }) async {
    final normalizedType = type.toLowerCase() == 'mobilebanking'
        ? 'mobile'
        : type.toLowerCase();

    return ApiErrorHandler.call(() async {
      await _api.dio.delete(
        '/influencer/profile/payouts',
        data: {'type': normalizedType, 'identifier': accountNo},
      );
    });
  }

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

  Future<ApiResult<InfluencerProfile>> updateWebsite(String? website) async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.patch(
        '/influencer/profile/basic-info',
        data: {'website': website},
      );
      return InfluencerProfile.fromJson(res.data);
    });
  }

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

  Future<ApiResult<List<InfluencerAddress>>> getInfluencerAddresses() async {
    return ApiErrorHandler.call(() async {
      final res = await _api.dio.get('/campaign/influencer/addresses');

      final List data = res.data['data'] ?? [];

      return data.map((e) => InfluencerAddress.fromJson(e)).toList();
    });
  }
}
