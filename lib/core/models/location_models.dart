class LocationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const LocationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory LocationMeta.fromJson(Map<String, dynamic> json) {
    return LocationMeta(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class ZillaModel {
  final String id;
  final String name;
  final String? bnName;

  const ZillaModel({required this.id, required this.name, this.bnName});

  factory ZillaModel.fromJson(Map<String, dynamic> json) {
    return ZillaModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bnName: json['bnName']?.toString(),
    );
  }

  String get displayName => name;
}

class ThanaModel {
  final String id;
  final String name;
  final String? bnName;
  final String zillaId;

  const ThanaModel({
    required this.id,
    required this.name,
    this.bnName,
    required this.zillaId,
  });

  factory ThanaModel.fromJson(Map<String, dynamic> json) {
    return ThanaModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bnName: json['bnName']?.toString(),
      zillaId: json['zillaId']?.toString() ?? '',
    );
  }

  String get displayName => name;
}
