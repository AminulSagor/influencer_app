import '../../../core/services/api_client.dart';

class AgencyProfileService {
  AgencyProfileService(this._api);

  final ApiClient _api;

  Future<void> updateAddress({
    required String addressName,
    required String thana,
    required String zilla,
    required String fullAddress,
  }) async {
    await _api.dio.patch(
      '/agency/profile/address',
      data: {
        'addressName': addressName,
        'thana': thana,
        'zilla': zilla,
        'fullAddress': fullAddress,
      },
    );
  }

  Future<void> updateSocials({
    String? website,
    required List<Map<String, dynamic>> socialLinks,
  }) async {
    await _api.dio.patch(
      '/agency/profile/socials',
      data: {
        if (website != null && website.trim().isNotEmpty) 'website': website,
        'socialLinks': socialLinks,
      },
    );
  }

  Future<void> updateServiceFee(String serviceFee) async {
    await _api.dio.patch(
      '/agency/profile/service-fee',
      data: {'serviceFee': serviceFee},
    );
  }

  Future<void> updateDollarRate(num dollarRate) async {
    await _api.dio.patch(
      '/agency/profile/dollar-rate',
      data: {'dollarRate': dollarRate},
    );
  }

  Future<Map<String, dynamic>> getServiceFee() async {
    final res = await _api.dio.get('/agency/profile/service-fee');
    if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
    if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    return const {};
  }

  Future<Map<String, dynamic>> getDollarRate() async {
    final res = await _api.dio.get('/agency/profile/dollar-rate');
    if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
    if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    return const {};
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

  Future<void> removePayout({required String type, required String id}) async {
    await _api.dio.delete(
      '/agency/profile/payouts',
      data: {'type': type, 'id': id},
    );
  }

  Future<void> updateNid({
    required String nidNumber,
    required String nidFrontImg,
    required String nidBackImg,
  }) async {
    await _api.dio.patch(
      '/agency/profile/verification/nid',
      data: {
        'nidNumber': nidNumber,
        'nidFrontImg': nidFrontImg,
        'nidBackImg': nidBackImg,
      },
    );
  }

  Future<void> updateTradeLicense({
    required String tradeLicenseNumber,
    required String tradeLicenseImg,
  }) async {
    await _api.dio.patch(
      '/agency/profile/verification/trade-license',
      data: {
        'tradeLicenseNumber': tradeLicenseNumber,
        'tradeLicenseImg': tradeLicenseImg,
      },
    );
  }

  Future<void> updateTin({
    required String tinNumber,
    required String tinImage,
  }) async {
    await _api.dio.patch(
      '/agency/profile/verification/tin',
      data: {'tinNumber': tinNumber, 'tinImage': tinImage},
    );
  }

  Future<void> updateBin({required String binNumber}) async {
    await _api.dio.patch(
      '/agency/profile/verification/bin',
      data: {'binNumber': binNumber},
    );
  }
}