import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../models/agency_onboarding_model.dart';
import '../models/agency_profile_model.dart';

class AgencyOnboardingService {
  final ApiClient _api;
  AgencyOnboardingService(this._api);

  Future<AgencyProfile> submitOnboarding(AgencyOnboardingModel model) async {
    final res = await _api.dio.patch(
      '/agency/profile/onboarding',
      data: model.toJson(),
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Invalid agency onboarding response',
      );
    }

    return AgencyProfile.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// PATCH /agency/profile/niches
  /// Body: { "niches": ["Fashion", "Skincare"] }
  Future<void> updateNiches(List<String> niches) async {
    final res = await _api.dio.patch(
      '/agency/profile/niches',
      data: {"niches": niches},
    );

    // Some backends return the updated profile; some return a message.
    // We don't need the payload for the signup flow, so we just validate it didn't hard-fail.
    if (res.statusCode != null && (res.statusCode! < 200 || res.statusCode! >= 300)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Failed to update agency niches',
      );
    }
  }
}
