import '../../../core/services/api_client.dart';

class PagedResult<T> {
  final List<T> items;
  final int total;

  const PagedResult({required this.items, required this.total});
}

class InfluencerDashboardService {
  final ApiClient _api;
  InfluencerDashboardService(this._api);

  Future<Map<String, dynamic>> fetchSummary() async {
    final res = await _api.dio.get('/campaign/influencer/dashboard/summary');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<Map<String, dynamic>> fetchEarningsOverview({
    String range = '7d',
  }) async {
    final res = await _api.dio.get(
      '/campaign/influencer/dashboard/earnings-overview',
      queryParameters: {'range': range},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<Map<String, dynamic>> fetchLifetimeSummary() async {
    final res = await _api.dio.get('/influencer/dashboard/lifetime-summary');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<PagedResult<Map<String, dynamic>>> fetchActionRequired({
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _api.dio.get(
      '/influencer/dashboard/actions',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parsePaged(res.data);
  }

  Future<PagedResult<Map<String, dynamic>>> fetchUpcomingDeadlines({
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _api.dio.get(
      '/influencer/dashboard/deadlines',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parsePaged(res.data);
  }

  Future<PagedResult<Map<String, dynamic>>> fetchWorkInProgress({
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _api.dio.get(
      '/influencer/dashboard/work-in-progress',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parsePaged(res.data);
  }

  PagedResult<Map<String, dynamic>> _parsePaged(dynamic data) {
    if (data is Map<String, dynamic>) {
      final list = data['data'];
      final meta = data['meta'];
      final total = meta is Map<String, dynamic>
          ? (meta['total'] is int ? meta['total'] as int : 0)
          : 0;
      if (list is List) {
        return PagedResult(
          items: list
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList(),
          total: total,
        );
      }
    }
    return const PagedResult(items: [], total: 0);
  }
}
