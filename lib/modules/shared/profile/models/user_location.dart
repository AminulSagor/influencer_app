class UserLocation {
  final String name; // e.g. House
  final String thana;
  final String zilla;
  final String country;
  final String fullAddress;

  const UserLocation({
    required this.name,
    required this.thana,
    required this.zilla,
    this.country = '',
    required this.fullAddress,
  });

  String get subtitle {
    final parts = <String>[];
    if (fullAddress.trim().isNotEmpty) parts.add(fullAddress.trim());
    if (thana.trim().isNotEmpty) parts.add(thana.trim());
    if (zilla.trim().isNotEmpty) parts.add(zilla.trim());
    if (country.trim().isNotEmpty) parts.add(country.trim());
    return parts.join(', ');
  }
}
