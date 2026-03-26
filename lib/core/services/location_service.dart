import 'package:dio/dio.dart';

import '../models/location_models.dart';
import 'api_client.dart';

class LocationService {
  LocationService(this._api);

  final ApiClient _api;

  Future<List<ZillaModel>> fetchAllZillas({
    String? search,
    int limit = 100,
  }) async {
    final items = <ZillaModel>[];
    var page = 1;
    var totalPages = 1;

    do {
      final res = await _api.dio.get(
        '/admin/locations/zillas',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
      );

      final parsed = _parseListResponse<ZillaModel>(
        res.data,
        ZillaModel.fromJson,
        'zillas response',
      );

      items.addAll(parsed.items);
      totalPages = parsed.meta.totalPages;
      page++;
    } while (page <= totalPages);

    return items;
  }

  Future<List<ThanaModel>> fetchAllThanasByZilla({
    required String zillaId,
    String? search,
    int limit = 100,
  }) async {
    final items = <ThanaModel>[];
    var page = 1;
    var totalPages = 1;

    do {
      final res = await _api.dio.get(
        '/admin/locations/zillas/$zillaId/thanas',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
      );

      final parsed = _parseListResponse<ThanaModel>(
        res.data,
        ThanaModel.fromJson,
        'thanas response',
      );

      items.addAll(parsed.items);
      totalPages = parsed.meta.totalPages;
      page++;
    } while (page <= totalPages);

    return items;
  }

  _LocationListResult<T> _parseListResponse<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
    String context,
  ) {
    if (raw is! Map) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        message: '$context is not a valid map',
      );
    }

    final data = Map<String, dynamic>.from(raw);
    final list = (data['data'] as List?) ?? const [];
    final metaMap = data['meta'] is Map
        ? Map<String, dynamic>.from(data['meta'] as Map)
        : <String, dynamic>{};

    return _LocationListResult<T>(
      items: list
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      meta: LocationMeta.fromJson(metaMap),
    );
  }
}

class _LocationListResult<T> {
  final List<T> items;
  final LocationMeta meta;

  const _LocationListResult({required this.items, required this.meta});
}
