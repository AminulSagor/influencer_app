import 'package:dio/dio.dart';
import 'api_client.dart';

class NotificationDto {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String type; // ex: "verification"
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.type,
    required this.createdAt,
    required this.metadata,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['createdAt']?.toString();
    return NotificationDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true,
      type: json['type']?.toString() ?? '',
      createdAt: createdRaw == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(createdRaw),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }
}

class NotificationMeta {
  final int total;
  final int page;
  final int limit;
  final String? filter;

  const NotificationMeta({
    required this.total,
    required this.page,
    required this.limit,
    this.filter,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      filter: json['filter']?.toString(),
    );
  }
}

class NotificationsResponse {
  final List<NotificationDto> data;
  final NotificationMeta meta;

  const NotificationsResponse({required this.data, required this.meta});
}

class NotificationService {
  NotificationService(this._api);

  final ApiClient _api;

  static const String _defaultBase = '/notifications';

  /// Postman shows:
  /// GET /influencer/notifications?filter=new&page=1  (+ limit also supported in meta)
  /// :contentReference[oaicite:2]{index=2} :contentReference[oaicite:3]{index=3}
  Future<NotificationsResponse> fetchNotifications({
    String? basePath,
    String? filter,
    int page = 1,
    int limit = 10,
  }) async {
    final base = (basePath != null && basePath.trim().isNotEmpty)
        ? basePath.trim()
        : _defaultBase;
    final res = await _api.dio.get(
      base,
      queryParameters: <String, dynamic>{
        if (filter != null && filter.trim().isNotEmpty) 'filter': filter.trim(),
        'page': page,
        'limit': limit,
      },
    );

    final root = _expectMap(res.data, 'notifications response', base);
    final listRaw = (root['data'] as List?) ?? const [];
    final metaRaw = root['meta'];

    final data = listRaw
        .whereType<Map>()
        .map((e) => NotificationDto.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.id.isNotEmpty)
        .toList(growable: false);

    final meta = NotificationMeta.fromJson(
      _expectMap(metaRaw, 'notifications meta', base),
    );

    return NotificationsResponse(data: data, meta: meta);
  }

  Future<void> markAllAsRead({String? basePath}) async {
    final base = (basePath != null && basePath.trim().isNotEmpty)
        ? basePath.trim()
        : _defaultBase;
    await _api.dio.patch('$base/read-all', data: const {});
  }

  Future<void> markSingleAsRead({required String id, String? basePath}) async {
    final base = (basePath != null && basePath.trim().isNotEmpty)
        ? basePath.trim()
        : _defaultBase;
    await _api.dio.patch('$base/$id/read', data: const {});
  }

  Map<String, dynamic> _expectMap(dynamic v, String label, String base) {
    if (v is Map) return Map<String, dynamic>.from(v);
    throw DioException(
      requestOptions: RequestOptions(path: base),
      message: '$label is not a JSON object',
    );
  }
}
