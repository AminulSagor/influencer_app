class AgencyLookup {
  final String id;
  final String name;
  final String logo;
  final String? subtitle;

  const AgencyLookup({
    required this.id,
    required this.name,
    this.subtitle,
    required this.logo,
  });
}

class InfluencerLookup {
  final String id;
  final String name;
  final String? avatar;
  final double? rating;

  const InfluencerLookup({
    required this.id,
    required this.name,
    this.avatar,
    this.rating,
  });
}
