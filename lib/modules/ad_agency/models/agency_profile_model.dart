class AgencyProfile {
  final String id;
  final String? agencyName;
  final String? firstName;
  final String? lastName;

  final String? secondaryPhone;
  final String? logo;
  final String? agencyBio;
  final dynamic serviceFee;

  final String? website;

  final AgencyAddress? address;

  final List<AgencyNicheStatus> niches;
  final List<AgencySocialLinkStatus> socialLinks;

  final String? nidNumber;
  final String? nidFrontImg;
  final String? nidBackImg;
  final VerificationBlock? nidVerification;

  final String? tradeLicenseNumber;
  final String? tradeLicenseImage;
  final VerificationBlock? tradeLicenseVerification;

  final String? tinNumber;
  final String? tinImage;
  final VerificationBlock? tinVerification;

  final String? binNumber;
  final VerificationBlock? binVerification;

  final bool isOnboardingComplete;

  final dynamic payouts;

  final String? averageRating;
  final int totalReviews;

  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgencyProfile({
    required this.id,
    required this.niches,
    required this.socialLinks,
    required this.isOnboardingComplete,
    required this.totalReviews,
    this.agencyName,
    this.firstName,
    this.lastName,
    this.secondaryPhone,
    this.logo,
    this.agencyBio,
    this.serviceFee,
    this.website,
    this.address,
    this.nidNumber,
    this.nidFrontImg,
    this.nidBackImg,
    this.nidVerification,
    this.tradeLicenseNumber,
    this.tradeLicenseImage,
    this.tradeLicenseVerification,
    this.tinNumber,
    this.tinImage,
    this.tinVerification,
    this.binNumber,
    this.binVerification,
    this.payouts,
    this.averageRating,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory AgencyProfile.fromJson(Map<String, dynamic> json) => AgencyProfile(
    id: json["id"]?.toString() ?? "",
    agencyName: json["agencyName"]?.toString(),
    firstName: json["firstName"]?.toString(),
    lastName: json["lastName"]?.toString(),
    secondaryPhone: json["secondaryPhone"]?.toString(),
    logo: json["logo"]?.toString(),
    agencyBio: json["agencyBio"]?.toString(),
    serviceFee: json["serviceFee"],
    website: json["website"]?.toString(),
    address: json["address"] is Map
        ? AgencyAddress.fromJson(json["address"])
        : null,
    niches: (json["niches"] is List)
        ? (json["niches"] as List)
              .whereType<Map>()
              .map((e) => AgencyNicheStatus.fromJson(e.cast<String, dynamic>()))
              .toList()
        : const [],
    socialLinks: (json["socialLinks"] is List)
        ? (json["socialLinks"] as List)
              .whereType<Map>()
              .map(
                (e) =>
                    AgencySocialLinkStatus.fromJson(e.cast<String, dynamic>()),
              )
              .toList()
        : const [],
    nidNumber: json["nidNumber"]?.toString(),
    nidFrontImg: json["nidFrontImg"]?.toString(),
    nidBackImg: json["nidBackImg"]?.toString(),
    nidVerification: json["nidVerification"] is Map
        ? VerificationBlock.fromJson(json["nidVerification"])
        : null,
    tradeLicenseNumber: json["tradeLicenseNumber"]?.toString(),
    tradeLicenseImage: json["tradeLicenseImage"]?.toString(),
    tradeLicenseVerification: json["tradeLicenseVerification"] is Map
        ? VerificationBlock.fromJson(json["tradeLicenseVerification"])
        : null,
    tinNumber: json["tinNumber"]?.toString(),
    tinImage: json["tinImage"]?.toString(),
    tinVerification: json["tinVerification"] is Map
        ? VerificationBlock.fromJson(json["tinVerification"])
        : null,
    binNumber: json["binNumber"]?.toString(),
    binVerification: json["binVerification"] is Map
        ? VerificationBlock.fromJson(json["binVerification"])
        : null,
    isOnboardingComplete: json["isOnboardingComplete"] == true,
    payouts: json["payouts"],
    averageRating: json["averageRating"]?.toString(),
    totalReviews: (json["totalReviews"] is int) ? json["totalReviews"] : 0,
    userId: json["userId"]?.toString(),
    createdAt: DateTime.tryParse(json["createdAt"]?.toString() ?? ""),
    updatedAt: DateTime.tryParse(json["updatedAt"]?.toString() ?? ""),
  );
}

class AgencyAddress {
  final String? country;
  final String? thana;
  final String? zilla;
  final String? fullAddress;

  AgencyAddress({this.country, this.thana, this.zilla, this.fullAddress});

  factory AgencyAddress.fromJson(Map<String, dynamic> json) => AgencyAddress(
    country: json["country"]?.toString(),
    thana: json["thana"]?.toString(),
    zilla: json["zilla"]?.toString(),
    fullAddress: json["fullAddress"]?.toString(),
  );
}

class AgencyNicheStatus {
  final String niche;
  final String status;

  AgencyNicheStatus({required this.niche, required this.status});

  factory AgencyNicheStatus.fromJson(Map<String, dynamic> json) =>
      AgencyNicheStatus(
        niche: json["niche"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "pending",
      );
}

class AgencySocialLinkStatus {
  final String platform;
  final String url;
  final String status;

  AgencySocialLinkStatus({
    required this.platform,
    required this.url,
    required this.status,
  });

  factory AgencySocialLinkStatus.fromJson(Map<String, dynamic> json) =>
      AgencySocialLinkStatus(
        platform: json["platform"]?.toString() ?? "",
        url: json["url"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "pending",
      );
}

class VerificationBlock {
  final String status;
  final String rejectReason;

  VerificationBlock({required this.status, required this.rejectReason});

  factory VerificationBlock.fromJson(Map<String, dynamic> json) =>
      VerificationBlock(
        status: (json.values.isNotEmpty)
            ? (json.values.first?.toString() ?? "pending")
            : "pending",
        rejectReason: (json.entries.length >= 2)
            ? (json.entries.elementAt(1).value?.toString() ?? "")
            : "",
      );
}
