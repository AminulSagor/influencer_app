import '../../../core/services/api_client.dart';

class PagedResult<T> {
  final List<T> items;
  final int total;

  const PagedResult({required this.items, required this.total});
}

class BrandDashboardService {
  final ApiClient _api;
  BrandDashboardService(this._api);

  Future<PagedResult<Map<String, dynamic>>> fetchActiveJobs({
    int page = 1,
    int limit = 3,
  }) async {
    final res = await _api.dio.get(
      '/client/dashboard/active-jobs',
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = res.data;
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

  Future<List<Map<String, dynamic>>> fetchUpcomingDeadlines({
    int limit = 5,
  }) async {
    final res = await _api.dio.get(
      '/client/dashboard/upcoming-deadlines',
      queryParameters: {'limit': limit},
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    }
    return const [];
  }

  Future<Map<String, dynamic>> fetchActionRequired() async {
    final res = await _api.dio.get('/client/dashboard/action-required');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<Map<String, dynamic>> fetchLifetimeSummary() async {
    final res = await _api.dio.get('/client/lifetime-summary');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<Map<String, dynamic>> fetchNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _api.dio.get(
      '/client/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return const {};
  }
}
