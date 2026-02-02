import '../../../core/services/api_client.dart';

class PagedResult<T> {
  final List<T> items;
  final int total;

  const PagedResult({required this.items, required this.total});
}

class AgencyDashboardService {
  final ApiClient _api;
  AgencyDashboardService(this._api);

  Future<Map<String, dynamic>> fetchSummary() async {
    final res = await _api.dio.get('/agency/dashboard/summary');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<Map<String, dynamic>> fetchEarningsOverview({
    String range = '30d',
  }) async {
    final res = await _api.dio.get(
      '/agency/dashboard/earnings',
      queryParameters: {'range': range},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<PagedResult<Map<String, dynamic>>> fetchActionRequired({
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _api.dio.get(
      '/agency/dashboard/actions',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parsePaged(res.data);
  }

  Future<PagedResult<Map<String, dynamic>>> fetchUpcomingDeadlines({
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _api.dio.get(
      '/agency/dashboard/deadlines',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parsePaged(res.data);
  }

  Future<PagedResult<Map<String, dynamic>>> fetchWorkInProgress({
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _api.dio.get(
      '/agency/dashboard/work-in-progress',
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
