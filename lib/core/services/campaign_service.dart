import 'package:dio/dio.dart';
import '../models/job_item.dart';
import '../../modules/brand/create_campaign/models/lookup_models.dart';
import 'api_client.dart';

class CampaignService {
  CampaignService(this._api);

  final ApiClient _api;

  static const String _campaignBase = '/campaign';

  Future<List<String>> fetchNiches() async {
    final res = await _api.dio.get('$_campaignBase/get/niches');
    return _extractNameList(res.data);
  }

  Future<List<String>> fetchProductTypes() async {
    final res = await _api.dio.get('$_campaignBase/get/product-types');
    return _extractNameList(res.data);
  }

  Future<List<AgencyLookup>> fetchAgencies({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final res = await _api.dio.get(
      '/client/agencies',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final data = _expectMap(res.data, 'agencies response');
    final list = (data['data'] as List?) ?? const [];

    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (e) => AgencyLookup(
            id: e['id']?.toString() ?? '',
            name:
                e['agencyName']?.toString() ??
                e['fullName']?.toString() ??
                'Agency',
            subtitle:
                e['fullName']?.toString() ?? e['user']?['email']?.toString(),
          ),
        )
        .where((e) => e.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<InfluencerLookup>> fetchInfluencers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final res = await _api.dio.get(
      '/client/influencers',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final data = _expectMap(res.data, 'influencers response');
    final list = (data['data'] as List?) ?? const [];

    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (e) => InfluencerLookup(
            id: e['id']?.toString() ?? '',
            name: e['name']?.toString() ?? 'Influencer',
            avatar: e['avatar']?.toString(),
            rating: (e['rating'] as num?)?.toDouble(),
          ),
        )
        .where((e) => e.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<String> createCampaign({
    required String campaignName,
    required CampaignType campaignType,
  }) async {
    final res = await _api.dio.post(
      _campaignBase,
      data: {
        'campaignName': campaignName,
        'campaignType': _campaignTypeToApi(campaignType),
      },
    );

    final data = _expectMap(res.data, 'create campaign');
    final payload = _expectMap(data['data'], 'create campaign data');
    final id = payload['id']?.toString();
    if (id == null || id.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'create campaign response missing id',
      );
    }
    return id;
  }

  Future<void> updateStep2Influencer({
    required String campaignId,
    required String productType,
    required String campaignNiche,
    List<String> preferredInfluencerIds = const [],
    List<String> notPreferableInfluencerIds = const [],
  }) async {
    await _api.dio.patch(
      '$_campaignBase/$campaignId/step-2',
      data: {
        'productType': productType,
        'campaignNiche': campaignNiche,
        if (preferredInfluencerIds.isNotEmpty)
          'preferredInfluencerIds': preferredInfluencerIds,
        if (notPreferableInfluencerIds.isNotEmpty)
          'notPreferableInfluencerIds': notPreferableInfluencerIds,
      },
    );
  }

  Future<void> updateStep2PaidAd({
    required String campaignId,
    required String campaignNiche,
    List<String> agencyIds = const [],
  }) async {
    await _api.dio.patch(
      '$_campaignBase/$campaignId/step-2',
      data: {
        'campaignNiche': campaignNiche,
        if (agencyIds.isNotEmpty) 'agencyId': agencyIds,
      },
    );
  }

  Future<void> updateStep3({
    required String campaignId,
    required String campaignGoals,
    required String productServiceDetails,
    required String reportingRequirements,
    required String usageRights,
    required String dos,
    required String donts,
    required String startingDate,
    required int duration,
  }) async {
    await _api.dio.patch(
      '$_campaignBase/$campaignId/step-3',
      data: {
        'campaignGoals': campaignGoals,
        'productServiceDetails': productServiceDetails,
        'reportingRequirements': reportingRequirements,
        'usageRights': usageRights,
        'dos': dos,
        'donts': donts,
        'startingDate': startingDate,
        'duration': duration,
      },
    );
  }

  Future<void> updateStep4({
    required String campaignId,
    required double baseBudget,
    required List<Map<String, dynamic>> milestones,
  }) async {
    await _api.dio.patch(
      '$_campaignBase/$campaignId/step-4',
      data: {'baseBudget': baseBudget, 'milestones': milestones},
    );
  }

  Future<void> updateStep5({
    required String campaignId,
    required bool needSampleProduct,
    required List<Map<String, dynamic>> assets,
  }) async {
    await _api.dio.patch(
      '$_campaignBase/$campaignId/step-5',
      data: {'needSampleProduct': needSampleProduct, 'assets': assets},
    );
  }

  Future<void> placeCampaign({required String campaignId}) async {
    await _api.dio.post('$_campaignBase/$campaignId/place');
  }

  Future<Map<String, dynamic>> fetchClientCampaignDetails({
    required String campaignId,
  }) async {
    final res = await _api.dio.get('/campaign/client/details/$campaignId');
    final data = _expectMap(res.data, 'client campaign details');
    final payload = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : Map<String, dynamic>.from(data);
    return payload;
  }

  Future<List<Map<String, dynamic>>> fetchClientAgencyBids({
    required String campaignId,
  }) async {
    final res = await _api.dio.get('/campaign/client/bids/$campaignId');
    final data = _expectMap(res.data, 'client agency bids');
    final list = (data['data'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  Future<void> sendNegotiationCounterOffer({
    required String campaignId,
    required int proposedBaseBudget,
  }) async {
    await _api.dio.post(
      '/campaign/negotiation/counter-offer',
      data: {
        'campaignId': campaignId,
        'proposedBaseBudget': proposedBaseBudget,
      },
    );
  }

  Future<void> acceptNegotiation({required String campaignId}) async {
    await _api.dio.post(
      '/campaign/negotiation/accept',
      data: {'campaignId': campaignId},
    );
  }

  static String _campaignTypeToApi(CampaignType type) {
    switch (type) {
      case CampaignType.paidAd:
        return 'paid_ad';
      case CampaignType.influencerPromotion:
        return 'influencer_promotion';
    }
  }

  static Map<String, dynamic> _expectMap(dynamic data, String context) {
    if (data is Map) return Map<String, dynamic>.from(data as Map);
    throw DioException(
      requestOptions: RequestOptions(path: ''),
      message: '$context response is not a valid map',
    );
  }

  static List<String> _extractNameList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => e['name']?.toString())
          .whereType<String>()
          .toList(growable: false);
    }

    if (data is Map) {
      final list = (data['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((e) => e['name']?.toString())
          .whereType<String>()
          .toList(growable: false);
    }

    return const [];
  }
}
