/// Payload for: PATCH /agency/profile/onboarding
///
/// Based on the provided Postman collection:
/// {
///   "thana": "...",
///   "zilla": "...",
///   "fullAddress": "...",
///   "country": "...",
///   "niches": [...],
///   "website": "...",
///   "socialLinks": [{"platform":"Facebook","url":"https://..."}],
///   "nidNumber": "...",
///   "nidFrontImg": "...",
///   "nidBackImg": "...",
///   "tradeLicenseNumber": "...",
///   "tradeLicenseImage": "...",
///   "tinNumber": "...",
///   "tinImage": "...",
///   "binNumber": "..."
/// }
class AgencyOnboardingModel {
  String? thana;
  String? zilla;
  String? fullAddress;
  String? country;
  String? website;
  List<String> niches = [];

  /// backend expects: [{platform, url}]
  List<AgencySocialLink> socialLinks = [];

  // NID verification
  String? nidNumber;
  String? nidFrontImg;
  String? nidBackImg;

  // Trade License verification
  String? tradeLicenseNumber;
  String? tradeLicenseImage;

  // TIN verification
  String? tinNumber;
  String? tinImage;

  // BIN verification
  String? binNumber;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (thana != null) json["thana"] = thana;
    if (zilla != null) json["zilla"] = zilla;
    if (fullAddress != null) json["fullAddress"] = fullAddress;
    if (country != null) json["country"] = country;
    if (website != null) json["website"] = website;
    if (niches.isNotEmpty) json["niches"] = niches;
    json["socialLinks"] = socialLinks.map((e) => e.toJson()).toList();

    // Verification fields
    if (nidNumber != null) json["nidNumber"] = nidNumber;
    if (nidFrontImg != null) json["nidFrontImg"] = nidFrontImg;
    if (nidBackImg != null) json["nidBackImg"] = nidBackImg;
    if (tradeLicenseNumber != null)
      json["tradeLicenseNumber"] = tradeLicenseNumber;
    if (tradeLicenseImage != null)
      json["tradeLicenseImage"] = tradeLicenseImage;
    if (tinNumber != null) json["tinNumber"] = tinNumber;
    if (tinImage != null) json["tinImage"] = tinImage;
    if (binNumber != null) json["binNumber"] = binNumber;

    return json;
  }
}

class AgencySocialLink {
  final String platform;
  final String url;

  AgencySocialLink({required this.platform, required this.url});

  Map<String, dynamic> toJson() => {"platform": platform, "url": url};
}
