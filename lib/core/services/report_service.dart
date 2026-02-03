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

class ReportService {
  final ApiClient _api;
  ReportService(this._api);

  Future<PagedResult<Map<String, dynamic>>> fetchInfluencerReportLogs({
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _api.dio.get(
      '/influencer/report-logs',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parsePaged(res.data, page: page, limit: limit);
  }

  Future<PagedResult<Map<String, dynamic>>> fetchClientReports({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final res = await _api.dio.get(
      '/client/reports',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _parsePaged(res.data, page: page, limit: limit);
  }

  Future<PagedResult<Map<String, dynamic>>> fetchAgencyReports({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final res = await _api.dio.get(
      '/agency/reports',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _parsePaged(res.data, page: page, limit: limit);
  }

  PagedResult<Map<String, dynamic>> _parsePaged(
    dynamic data, {
    required int page,
    required int limit,
  }) {
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
          page: page,
          limit: limit,
        );
      }
    }
    return PagedResult(items: const [], total: 0, page: page, limit: limit);
  }
}
