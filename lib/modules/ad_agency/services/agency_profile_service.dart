import '../../../core/services/api_client.dart';

class AgencyProfileService {
  AgencyProfileService(this._api);

  final ApiClient _api;

  Map<String, dynamic>? _mapFromResponseData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final res = await _api.dio.get('/agency/profile');
    return _mapFromResponseData(res.data) ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>?> updateBasicInfo({
    String? agencyName,
    String? firstName,
    String? lastName,
    String? agencyBio,
    String? logo,
  }) async {
    final payload = <String, dynamic>{
      if (agencyName != null) 'agencyName': agencyName,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (agencyBio != null) 'agencyBio': agencyBio,
      if (logo != null) 'logo': logo,
    };

    final res = await _api.dio.patch(
      '/agency/profile/basic-info',
      data: payload,
    );
    return _mapFromResponseData(res.data);
  }

  Future<Map<String, dynamic>?> updateNiches(List<String> niches) async {
    final res = await _api.dio.patch(
      '/agency/profile/niches',
      data: {'niches': niches},
    );
    return _mapFromResponseData(res.data);
  }

  Future<Map<String, dynamic>?> updateSkills(List<String> skills) async {
    final res = await _api.dio.patch(
      '/agency/profile/skills',
      data: {'skills': skills},
    );
    return _mapFromResponseData(res.data);
  }

  Future<void> removeLogo() async {
    await _api.dio.delete('/agency/profile/image');
  }

  Future<void> removeNiche({required String identifier}) async {
    await _api.dio.delete(
      '/agency/profile/niches',
      data: {'identifier': identifier},
    );
  }

  Future<Map<String, dynamic>?> updateAddress({
    required String addressName,
    required String thana,
    required String zilla,
    required String fullAddress,
  }) async {
    final res = await _api.dio.patch(
      '/agency/profile/address',
      data: {
        'address': {'thana': thana, 'zilla': zilla, 'fullAddress': fullAddress},
      },
    );
    return _mapFromResponseData(res.data);
  }

  Future<Map<String, dynamic>?> updateSocials({
    String? website,
    required List<Map<String, dynamic>> socialLinks,
  }) async {
    final res = await _api.dio.patch(
      '/agency/profile/socials',
      data: {
        if (website != null && website.trim().isNotEmpty) 'website': website,
        'socialLinks': socialLinks,
      },
    );
    return _mapFromResponseData(res.data);
  }

  Future<Map<String, dynamic>?> updateServiceFee(String serviceFee) async {
    final res = await _api.dio.patch(
      '/agency/profile/service-fee',
      data: {'serviceFee': serviceFee},
    );
    return _mapFromResponseData(res.data);
  }

  Future<void> updateDollarRate(num dollarRate) async {
    await _api.dio.patch(
      '/agency/profile/dollar-rate',
      data: {'dollarRate': dollarRate},
    );
  }

  Future<void> addBankPayout({
    required String bankName,
    required String accountHolderName,
    required String accountNo,
    required String branchName,
    required String routingNo,
  }) async {
    await _api.dio.post(
      '/agency/profile/payouts',
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
  }

  Future<void> addMobilePayout({
    required String accountType,
    required String accountHolderName,
    required String accountNo,
  }) async {
    await _api.dio.post(
      '/agency/profile/payouts',
      data: {
        'mobileBanking': {
          'accountType': accountType,
          'accountHolderName': accountHolderName,
          'accountNo': accountNo,
        },
      },
    );
  }

  Future<void> removePayout({
    required String type,
    required String accountNo,
  }) async {
    final normalizedType = type.toLowerCase() == 'mobilebanking'
        ? 'mobile'
        : type.toLowerCase();

    await _api.dio.delete(
      '/agency/profile/payouts',
      data: {'type': normalizedType, 'identifier': accountNo},
    );
  }

  Future<Map<String, dynamic>?> updateNid({
    required String nidNumber,
    required String nidFrontImg,
    required String nidBackImg,
  }) async {
    final res = await _api.dio.patch(
      '/agency/profile/verification/nid',
      data: {
        'nidNumber': nidNumber,
        'nidFrontImg': nidFrontImg,
        'nidBackImg': nidBackImg,
      },
    );
    return _mapFromResponseData(res.data);
  }

  Future<Map<String, dynamic>?> updateTradeLicense({
    required String tradeLicenseNumber,
    required String tradeLicenseImg,
  }) async {
    final res = await _api.dio.patch(
      '/agency/profile/verification/trade-license',
      data: {
        'tradeLicenseNumber': tradeLicenseNumber,
        'tradeLicenseImg': tradeLicenseImg,
      },
    );
    return _mapFromResponseData(res.data);
  }

  Future<Map<String, dynamic>?> updateTin({
    required String tinNumber,
    required String tinImage,
  }) async {
    final res = await _api.dio.patch(
      '/agency/profile/verification/tin',
      data: {'tinNumber': tinNumber, 'tinImage': tinImage},
    );
    return _mapFromResponseData(res.data);
  }

  Future<Map<String, dynamic>?> updateBin({required String binNumber}) async {
    final res = await _api.dio.patch(
      '/agency/profile/verification/bin',
      data: {'binNumber': binNumber},
    );
    return _mapFromResponseData(res.data);
  }
}
