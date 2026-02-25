import 'package:flutter/material.dart';
import 'package:influencer_app/core/services/api_client.dart';
import '../models/explore_item.dart';

class ExploreService {
  static const int _defaultLimit = 10;

  final ApiClient _api;
  ExploreService(this._api);

  Future<ExplorePagedResponse> fetch({
    required ExploreType type,
    required String query,
    required int page,
  }) async {
    final endpoint = type == ExploreType.influencer
        ? '/client/influencers'
        : '/client/agencies';

    final res = await _api.dio.get(
      endpoint,
      queryParameters: {
        'page': page,
        'limit': _defaultLimit,
        if (query.trim().isNotEmpty) 'search': query.trim(),
      },
    );

    return _parse(res.data, type, page: page, limit: _defaultLimit);
  }

  ExplorePagedResponse _parse(
    dynamic data,
    ExploreType type, {
    required int page,
    required int limit,
  }) {
    if (data is Map<String, dynamic>) {
      final list = data['data'];
      final meta = data['meta'];
      final total = meta is Map<String, dynamic>
          ? _toInt(meta['total'])
          : (list is List ? list.length : 0);
      final totalPages = meta is Map<String, dynamic>
          ? _toInt(meta['totalPages'])
          : (total / limit).ceil().clamp(1, 999);

      if (list is List) {
        final items = list
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .map((e) => _mapItem(e, type))
            .toList();
        return ExplorePagedResponse(
          items: items,
          totalResults: total,
          totalPages: totalPages,
        );
      }
    }
    return const ExplorePagedResponse(
      items: [],
      totalResults: 0,
      totalPages: 1,
    );
  }

  ExploreItem _mapItem(Map<String, dynamic> data, ExploreType type) {
    if (type == ExploreType.influencer) {
      final name = _asString(data['name']);
      final niches = _stringList(data['niches']);
      final subtitle = _buildSubtitle(base: 'Influencer', extras: niches);
      final icons = _iconsFromPlatforms(data['platforms']);

      return ExploreItem(
        id: _asString(data['id']),
        type: type,
        name: name.isNotEmpty ? name : 'Influencer',
        subtitle: subtitle,
        rating: _toDouble(data['rating']),
        icons: icons,
        imageUrl: _asString(data['avatar']).trim().isEmpty
            ? null
            : _asString(data['avatar']).trim(),
      );
    }

    // Agency
    final agencyName = _asString(data['agencyName']);
    final ownerName = _asString(data['fullName']).trim().isNotEmpty
        ? _asString(data['fullName'])
        : _joinName(data['firstName'], data['lastName']);
    final niches = _agencyVisibleNiches(data['niches']);
    final subtitle = _buildSubtitle(
      base: 'Ad Agency',
      extras: [if (ownerName.isNotEmpty) ownerName, ...niches],
    );
    final icons = _iconsFromSocialLinks(data['socialLinks']);

    return ExploreItem(
      id: _asString(data['id']),
      type: type,
      name: agencyName.isNotEmpty ? agencyName : 'Ad Agency',
      subtitle: subtitle,
      rating: _toDouble(data['averageRating']),
      icons: icons,
      imageUrl: _asString(data['logo']).trim().isEmpty
          ? null
          : _asString(data['logo']).trim(),
    );
  }

  List<IconData> _iconsFromPlatforms(dynamic platforms) {
    if (platforms is List) {
      final mapped = platforms
          .map((e) => _platformToIcon(_asString(e)))
          .whereType<IconData>()
          .toList();
      if (mapped.isNotEmpty) return mapped;
    }
    return const [
      Icons.facebook_rounded,
      Icons.camera_alt_rounded,
      Icons.play_circle_fill_rounded,
      Icons.music_note_rounded,
    ];
  }

  List<IconData> _iconsFromSocialLinks(dynamic links) {
    if (links is List) {
      final mapped = links
          .map((e) {
            if (e is Map) {
              return _platformToIcon(_asString(e['platform']));
            }
            return _platformToIcon(_asString(e));
          })
          .whereType<IconData>()
          .toList();
      if (mapped.isNotEmpty) return mapped;
    }
    return const [
      Icons.facebook_rounded,
      Icons.camera_alt_rounded,
      Icons.public_rounded,
    ];
  }

  IconData? _platformToIcon(String platform) {
    final p = platform.trim().toLowerCase();
    if (p.contains('facebook')) return Icons.facebook_rounded;
    if (p.contains('instagram')) return Icons.camera_alt_rounded;
    if (p.contains('youtube')) return Icons.play_circle_fill_rounded;
    if (p.contains('tiktok')) return Icons.music_note_rounded;
    if (p.contains('linkedin')) return Icons.business_center_rounded;
    if (p.contains('website') || p.contains('web') || p.contains('url')) {
      return Icons.public_rounded;
    }
    return null;
  }

  String _buildSubtitle({required String base, required List<String> extras}) {
    final filtered = extras.where((e) => e.trim().isNotEmpty).toList();
    if (filtered.isEmpty) return base;
    return '$base • ${filtered.join(', ')}';
  }

  String _asString(dynamic v) => v == null ? '' : v.toString();

  String _joinName(dynamic first, dynamic last) {
    final f = _asString(first).trim();
    final l = _asString(last).trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  List<String> _stringList(dynamic v) {
    if (v is List) {
      return v.map((e) => _asString(e)).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  List<String> _agencyVisibleNiches(dynamic v) {
    if (v is! List) return const [];

    final names = <String>[];
    for (final item in v) {
      if (item is String) {
        final name = item.trim();
        if (name.isNotEmpty) names.add(name);
        continue;
      }

      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final status = _asString(map['status']).trim().toLowerCase();
        if (status == 'pending') continue;

        final name = _asString(map['name']).trim().isNotEmpty
            ? _asString(map['name']).trim()
            : _asString(map['niche']).trim();
        if (name.isNotEmpty) names.add(name);
      }
    }

    return names;
  }
}
