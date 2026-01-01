class UserLocation {
  final String name; // e.g. House
  final String thana;
  final String zilla;
  final String fullAddress;

  const UserLocation({
    required this.name,
    required this.thana,
    required this.zilla,
    required this.fullAddress,
  });

  String get subtitle => fullAddress;
}
