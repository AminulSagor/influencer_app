import 'api_client.dart';

class PagedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;

  const PagedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class ClientAnalyticsResult {
  final PagedResult<Map<String, dynamic>> transactions;
  final String? topCampaignTitle;
  final String? topInfluencer;

  const ClientAnalyticsResult({
    required this.transactions,
    this.topCampaignTitle,
    this.topInfluencer,
  });
}

class AnalyticsService {
  final ApiClient _api;
  AnalyticsService(this._api);

  Future<ClientAnalyticsResult> fetchClientAnalytics({
    int page = 1,
    int limit = 10,
    String? search,
    String sortOrder = 'high_to_low',
  }) async {
    final res = await _api.dio.get(
      '/client/analytics',
      queryParameters: {
        'page': page,
        'limit': limit,
        'sortOrder': sortOrder,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _parseClientAnalytics(res.data, page: page, limit: limit);
  }

  ClientAnalyticsResult _parseClientAnalytics(
    dynamic data, {
    required int page,
    required int limit,
  }) {
    if (data is Map<String, dynamic>) {
      final rootData = data['data'];
      if (rootData is Map<String, dynamic>) {
        final highlights = rootData['highlights'];
        final transactions = rootData['transactions'];

        final topCampaignTitle = highlights is Map<String, dynamic>
            ? ((highlights['topCampaign'] is Map<String, dynamic>)
                  ? (highlights['topCampaign']['title']?.toString())
                  : null)
            : null;

        final topInfluencer = highlights is Map<String, dynamic>
            ? (highlights['topInfluencer']?.toString())
            : null;

        if (transactions is Map<String, dynamic>) {
          final txData = transactions['data'];
          final txMeta = transactions['meta'];

          final total = txMeta is Map<String, dynamic>
              ? int.tryParse('${txMeta['total']}') ?? 0
              : 0;
          final currentPage = txMeta is Map<String, dynamic>
              ? int.tryParse('${txMeta['page']}') ?? page
              : page;
          final currentLimit = txMeta is Map<String, dynamic>
              ? int.tryParse('${txMeta['limit']}') ?? limit
              : limit;

          if (txData is List) {
            return ClientAnalyticsResult(
              transactions: PagedResult(
                items: txData
                    .whereType<Map>()
                    .map((e) => e.cast<String, dynamic>())
                    .toList(),
                total: total,
                page: currentPage,
                limit: currentLimit,
              ),
              topCampaignTitle: topCampaignTitle,
              topInfluencer: topInfluencer,
            );
          }
        }
      }
    }
    return ClientAnalyticsResult(
      transactions: PagedResult(
        items: const [],
        total: 0,
        page: page,
        limit: limit,
      ),
    );
  }
}
