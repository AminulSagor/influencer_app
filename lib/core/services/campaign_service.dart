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

  Future<List<String>> fetchSkills() async {
    final res = await _api.dio.get('$_campaignBase/get/skills');
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

  Future<Map<String, dynamic>> rejectNegotiation({
    required String campaignId,
    String? reason,
  }) async {
    final res = await _api.dio.post(
      '/campaign/negotiation/reject',
      data: {
        'campaignId': campaignId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return _expectMap(res.data, 'reject negotiation');
  }

  Future<Map<String, dynamic>> fetchNegotiationHistory({
    required String campaignId,
  }) async {
    final res = await _api.dio.get('/campaign/$campaignId/negotiations');
    return _expectMap(res.data, 'negotiation history');
  }

  Future<Map<String, dynamic>> markNegotiationAsRead({
    required String negotiationId,
  }) async {
    final res = await _api.dio.patch(
      '/campaign/negotiation/$negotiationId/read',
    );
    return _expectMap(res.data, 'mark negotiation read');
  }

  Future<Map<String, dynamic>> fetchBudgetPreview({
    required int baseBudget,
    bool isAgencyCampaign = false,
  }) async {
    final path = isAgencyCampaign
        ? '/campaign/budget/agency/preview'
        : '/campaign/budget/preview';
    final res = await _api.dio.get(
      path,
      queryParameters: {'baseBudget': baseBudget},
    );
    return _expectMap(res.data, 'budget preview');
  }

  Future<Map<String, dynamic>> selectAgencyForCampaign({
    required String campaignId,
    required String agencyId,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/select-agency',
      data: {'campaignId': campaignId, 'agencyId': agencyId},
    );
    return _expectMap(res.data, 'select agency');
  }

  Future<Map<String, dynamic>> payCampaignAmount({
    required String campaignId,
    required int amount,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/campaign/pay',
      data: {'campaignId': campaignId, 'amount': amount},
    );
    return _expectMap(res.data, 'pay campaign amount');
  }

  Future<Map<String, dynamic>> payCampaignDue({
    required String campaignId,
    required int amount,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/pay-due',
      data: {'campaignId': campaignId, 'amount': amount},
    );
    return _expectMap(res.data, 'pay campaign due');
  }

  Future<Map<String, dynamic>> rateAgency({
    required String campaignId,
    required int rating,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/campaign/$campaignId/rate',
      data: {'rating': rating},
    );
    return _expectMap(res.data, 'rate agency');
  }

  Future<Map<String, dynamic>> reviewClientSubmission({
    required String submissionId,
    required String action,
    String? report,
    String? reason,
  }) async {
    final normalizedAction = action.trim().toLowerCase();
    final payload = <String, dynamic>{'action': normalizedAction};

    final trimmedReport = report?.trim();
    if (trimmedReport != null && trimmedReport.isNotEmpty) {
      payload['report'] = trimmedReport;
    }

    final trimmedReason = reason?.trim();
    if (trimmedReason != null && trimmedReason.isNotEmpty) {
      payload['reason'] = trimmedReason;
    }

    final res = await _api.dio.post(
      '/campaign/client/submission/$submissionId/review',
      data: payload,
    );
    return _expectMap(res.data, 'review client submission');
  }

  Future<Map<String, dynamic>> reportClientSubmission({
    required String submissionId,
    required String report,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/submissions/$submissionId/report',
      data: {'report': report.trim()},
    );
    return _expectMap(res.data, 'report client submission');
  }

  Future<Map<String, dynamic>> payClientSubmissionBonus({
    required String submissionId,
    required int amount,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/submissions/$submissionId/bonus',
      data: {'amount': amount},
    );
    return _expectMap(res.data, 'pay client submission bonus');
  }

  Future<void> acceptInfluencerJobOffer({required String jobId}) async {
    await _api.dio.post('/campaign/influencer/job/$jobId/accept');
  }

  Future<void> declineInfluencerJobOffer({required String jobId}) async {
    await _api.dio.post('/campaign/influencer/job/$jobId/decline');
  }

  Future<void> acceptAgencyOffer({required String campaignId}) async {
    await _api.dio.post('/campaign/agency/$campaignId/accept');
  }

  Future<void> declineAgencyOffer({required String campaignId}) async {
    await _api.dio.post(
      '/campaign/agency/decline-offer',
      data: {'campaignId': campaignId},
    );
  }

  Future<void> requestAgencyRequote({
    required String campaignId,
    required Map<String, dynamic> payload,
  }) async {
    await _api.dio.post('/campaign/agency/$campaignId/requote', data: payload);
  }

  Future<dynamic> fetchInfluencerJobDetails({required String jobId}) async {
    final res = await _api.dio.get('/campaign/influencer/job/$jobId');
    return res.data;
  }

  Future<dynamic> fetchInfluencerJobMilestones({required String jobId}) async {
    final res = await _api.dio.get(
      '/campaign/influencer/job/$jobId/milestones',
    );
    return res.data;
  }

  Future<dynamic> fetchAgencyCampaignDetails({
    required String campaignId,
  }) async {
    final res = await _api.dio.get('/campaign/agency/$campaignId');
    return res.data;
  }

  Future<Map<String, dynamic>> submitAgencyMilestoneWork({
    required String milestoneId,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _api.dio.post(
      '/campaign/agency/milestone/$milestoneId/submit',
      data: payload,
    );
    return _expectMap(res.data, 'submit agency milestone');
  }

  Future<Map<String, dynamic>> resubmitAgencyMilestoneWork({
    required String submissionId,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _api.dio.post(
      '/campaign/agency/submission/$submissionId/resubmit',
      data: payload,
    );
    return _expectMap(res.data, 'resubmit agency milestone');
  }

  Future<Map<String, dynamic>> updateAgencySubmissionResults({
    required String submissionId,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _api.dio.patch(
      '/campaign/agency/submission/$submissionId/results',
      data: payload,
    );
    return _expectMap(res.data, 'update agency submission results');
  }

  Future<Map<String, dynamic>> fetchAgencyRequoteOverview({
    required String campaignId,
  }) async {
    final res = await _api.dio.get(
      '/campaign/agency/$campaignId/requote-overview',
    );
    return _expectMap(res.data, 'agency requote overview');
  }

  Future<Map<String, dynamic>> fetchAgencyMilestones({
    required String campaignId,
  }) async {
    final res = await _api.dio.get('/campaign/agency/milestones/$campaignId');
    return _expectMap(res.data, 'agency milestones');
  }

  Future<Map<String, dynamic>> fetchAgencyStats() async {
    final res = await _api.dio.get('/campaign/agency/stats');
    return _expectMap(res.data, 'agency stats');
  }

  Future<Map<String, dynamic>> fetchCampaignById({
    required String campaignId,
  }) async {
    final res = await _api.dio.get('/campaign/$campaignId');
    return _expectMap(res.data, 'campaign by id');
  }

  Future<void> deleteCampaignById({required String campaignId}) async {
    await _api.dio.delete('/campaign/$campaignId');
  }

  Future<void> deleteCampaignAsset({required String assetId}) async {
    await _api.dio.delete('/campaign/asset/$assetId');
  }

  Future<Map<String, dynamic>> fetchCampaignSubmissionDetails({
    required String submissionId,
  }) async {
    final res = await _api.dio.get('/campaign/submission/$submissionId');
    return _expectMap(res.data, 'campaign submission details');
  }

  Future<Map<String, dynamic>> fetchSubmissionReport({
    required String submissionId,
  }) async {
    final res = await _api.dio.get('/campaign/submission/$submissionId/report');
    return _expectMap(res.data, 'submission report');
  }

  Future<Map<String, dynamic>> fetchCampaignProgress({
    required String campaignId,
  }) async {
    final res = await _api.dio.post('/campaign/progress/$campaignId');
    return _expectMap(res.data, 'campaign progress');
  }

  Future<List<Map<String, dynamic>>> searchInfluencers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _api.dio.get(
      '/client/influencers',
      // '/client/search/influencers',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'limit': limit,
      },
    );
    final raw = res.data;
    final List<dynamic> list;

    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      final data = Map<String, dynamic>.from(raw);
      final nested = data['data'];
      if (nested is List) {
        list = nested;
      } else if (nested is Map && nested['influencers'] is List) {
        list = nested['influencers'] as List;
      } else if (data['influencers'] is List) {
        list = data['influencers'] as List;
      } else {
        list = const [];
      }
    } else {
      list = const [];
    }

    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> fetchClientInfluencersProgress({
    required String campaignId,
  }) async {
    final res = await _api.dio.get(
      '/campaign/client/$campaignId/influencers-progress',
    );
    return _expectMap(res.data, 'client influencers progress');
  }

  Future<Map<String, dynamic>> rateInfluencer({
    required String campaignId,
    required String influencerId,
    required int rating,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/$campaignId/influencers/$influencerId/rate',
      data: {'rating': rating},
    );
    return _expectMap(res.data, 'rate influencer');
  }

  Future<Map<String, dynamic>> payClientMilestoneBonus({
    required String milestoneId,
    required int amount,
  }) async {
    final res = await _api.dio.post(
      '/campaign/client/milestone/$milestoneId/bonus',
      data: {'amount': amount},
    );
    return _expectMap(res.data, 'pay client milestone bonus');
  }

  Future<Map<String, dynamic>> fetchInfluencerSubmissions({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _api.dio.get(
      '/campaign/influencer/submissions',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        'page': page,
        'limit': limit,
      },
    );
    return _expectMap(res.data, 'influencer submissions');
  }

  Future<Map<String, dynamic>> fetchInfluencerSubmissionDetails({
    required String submissionId,
  }) async {
    final res = await _api.dio.get(
      '/campaign/influencer/submissions/$submissionId',
    );
    return _expectMap(res.data, 'influencer submission details');
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
