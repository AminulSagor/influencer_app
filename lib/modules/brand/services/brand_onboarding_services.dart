import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/onboarding_models.dart';
import 'package:flutter/foundation.dart';

/// Brand/Client onboarding APIs
/// - PATCH /client/profile/onboarding
/// - PATCH /client/profile
/// - PATCH /client/profile/nid
/// - PATCH /client/profile/trade-license
class BrandOnboardingService {
  final ApiClient _api;
  BrandOnboardingService(this._api);

  /// PATCH /client/profile/onboarding
  /// Sends full onboarding payload.
  ///
  /// We return Map<String, dynamic> because Postman export doesn’t show the exact response wrapper.
  /// You can later swap this to `BrandProfile` if your backend returns the full profile.
  Future<Map<String, dynamic>> submitOnboarding(
    BrandOnboardingRequest body,
  ) async {
    final res = await _api.dio.patch(
      '/client/profile/onboarding',
      data: body.toJson(),
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'client/profile/onboarding response is not a valid Map',
      );
    }
    return (res.data as Map).cast<String, dynamic>();
  }

  /// PATCH /client/profile/address
  Future<Map<String, dynamic>> updateAddress({
    required String addressName,
    required String thana,
    required String zilla,
    required String fullAddress,
  }) async {
    final res = await _api.dio.patch(
      '/client/profile/address',
      data: {
        'addressName': addressName,
        'thana': thana,
        'zilla': zilla,
        'fullAddress': fullAddress,
      },
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'client/profile/address response is not a valid Map',
      );
    }
    return (res.data as Map).cast<String, dynamic>();
  }

  /// PATCH /client/profile
  /// Basic info update (brandName, firstName, lastName).
  Future<Map<String, dynamic>> updateBasicInfo({
    required String brandName,
    required String firstName,
    required String lastName,
  }) async {
    final payload = {
      'brandName': brandName,
      'firstName': firstName,
      'lastName': lastName,
    };

    debugPrint('📤 PATCH /client/profile payload => $payload');
    final res = await _api.dio.patch('/client/profile', data: payload);

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'client/profile response is not a valid Map',
      );
    }
    return (res.data as Map).cast<String, dynamic>();
  }

  /// PATCH /client/profile/nid
  /// If you decide to enable NID later.
  Future<Map<String, dynamic>> updateNid({
    required String nidNumber,
    required String nidFrontImg,
    required String nidBackImg,
  }) async {
    final res = await _api.dio.patch(
      '/client/profile/nid',
      data: {
        'nidNumber': nidNumber,
        'nidFrontImg': nidFrontImg,
        'nidBackImg': nidBackImg,
      },
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'client/profile/nid response is not a valid Map',
      );
    }
    return (res.data as Map).cast<String, dynamic>();
  }

  /// PATCH /client/profile/trade-license
  /// If you decide to enable trade license later.
  Future<Map<String, dynamic>> updateTradeLicense({
    required String tradeLicenseNumber,
    required String tradeLicenseImg,
  }) async {
    final res = await _api.dio.patch(
      '/client/profile/trade-license',
      data: {
        'tradeLicenseNumber': tradeLicenseNumber,
        'tradeLicenseImg': tradeLicenseImg,
      },
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'client/profile/trade-license response is not a valid Map',
      );
    }
    return (res.data as Map).cast<String, dynamic>();
  }
}
