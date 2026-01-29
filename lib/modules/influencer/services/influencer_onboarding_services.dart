import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../models/influencer_onboarding_model.dart';

class InfluencerOnboardingService {
  final ApiClient _api;
  InfluencerOnboardingService(this._api);

  Future<void> submitOnboarding(InfluencerOnboardingModel model) async {
    final res = await _api.dio.patch(
      '/influencer/profile/onboarding',
      data: model.toJson(),
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Invalid onboarding response',
      );
    }
  }
}
