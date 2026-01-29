/// Brand/Client onboarding payload for:
/// PATCH /client/profile/onboarding
///
/// Fields based on Postman collection:
/// thana, zila, fullAddress, website, socialLinks, nidNumber, nidFrontImg,
/// nidBackImg, tradeLicenseNumber, tradeLicenseImg
class BrandOnboardingRequest {
  final String? thana;
  final String? zila;
  final String? fullAddress;
  final String? website;
  final List<BrandSocialLink> socialLinks;

  // (optional) you said we may skip file uploads, but keeping as nullable is safe
  final String? nidNumber;
  final String? nidFrontImg;
  final String? nidBackImg;

  final String? tradeLicenseNumber;
  final String? tradeLicenseImg;

  const BrandOnboardingRequest({
    this.thana,
    this.zila,
    this.fullAddress,
    this.website,
    this.socialLinks = const [],
    this.nidNumber,
    this.nidFrontImg,
    this.nidBackImg,
    this.tradeLicenseNumber,
    this.tradeLicenseImg,
  });

  Map<String, dynamic> toJson() => {
    if (thana != null) 'thana': thana,
    if (zila != null) 'zila': zila,
    if (fullAddress != null) 'fullAddress': fullAddress,
    if (website != null) 'website': website,
    'socialLinks': socialLinks.map((e) => e.toJson()).toList(),
    if (nidNumber != null) 'nidNumber': nidNumber,
    if (nidFrontImg != null) 'nidFrontImg': nidFrontImg,
    if (nidBackImg != null) 'nidBackImg': nidBackImg,
    if (tradeLicenseNumber != null) 'tradeLicenseNumber': tradeLicenseNumber,
    if (tradeLicenseImg != null) 'tradeLicenseImg': tradeLicenseImg,
  };
}

/// Brand social links are inconsistent across modules in your API:
/// Some places use "url", some use "profileUrl".
/// This model supports BOTH when parsing, and writes BOTH safely (choose one).
class BrandSocialLink {
  final String platform;
  final String link; // normalized value

  /// Optional status if backend sends it later (like influencer social links do)
  final String? status;

  const BrandSocialLink({
    required this.platform,
    required this.link,
    this.status,
  });

  factory BrandSocialLink.fromJson(Map<String, dynamic> json) {
    final rawLink = (json['profileUrl'] ?? json['url'] ?? json['link'])
        ?.toString();
    return BrandSocialLink(
      platform: (json['platform'] ?? '').toString(),
      link: rawLink ?? '',
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    // If your backend expects profileUrl for client, keep this:
    'profileUrl': link,
    // If it expects url instead, swap to 'url': link
    // 'url': link,
    if (status != null) 'status': status,
  };
}

/// Defensive "Brand profile" (client profile) model.
/// Use it for:
/// - GET /client/profile (when you implement it)
/// - or any onboarding endpoint that returns the updated profile.
///
/// Kept flexible: many fields are optional + parsing is safe.
class BrandProfile {
  final String? id;
  final String? brandName;
  final String? firstName;
  final String? lastName;

  final String? profile; // bio/about
  final String? profileImg;

  final String? zila;
  final String?
  thana; // optional (even if not present in client onboarding sample)
  final String? fullAddress;

  final String? website;
  final List<BrandSocialLink> socialLinks;

  final String? nidNumber;
  final String? nidFrontImg;
  final String? nidBackImg;

  final String? tradeLicenseNumber;
  final String? tradeLicenseImg;

  final bool? isOnboardingComplete;

  // ratings often come as string/number, so keep as String? or parse to double safely
  final String? averageRating;
  final int? totalReviews;

  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BrandProfile({
    this.id,
    this.brandName,
    this.firstName,
    this.lastName,
    this.profile,
    this.profileImg,
    this.zila,
    this.thana,
    this.fullAddress,
    this.website,
    this.socialLinks = const [],
    this.nidNumber,
    this.nidFrontImg,
    this.nidBackImg,
    this.tradeLicenseNumber,
    this.tradeLicenseImg,
    this.isOnboardingComplete,
    this.averageRating,
    this.totalReviews,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    final socialRaw = json['socialLinks'];
    final socials = (socialRaw is List)
        ? socialRaw
              .whereType<Map>()
              .map(
                (m) => BrandSocialLink.fromJson(Map<String, dynamic>.from(m)),
              )
              .toList()
        : <BrandSocialLink>[];

    return BrandProfile(
      id: (json['id'] ?? json['_id'])?.toString(),
      brandName: json['brandName']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      profile: json['profile']?.toString(),
      profileImg: (json['profileImg'] ?? json['profileImage'])?.toString(),
      zila: (json['zila'] ?? json['zilla'])?.toString(),
      thana: json['thana']?.toString(),
      fullAddress: json['fullAddress']?.toString(),
      website: json['website']?.toString(),
      socialLinks: socials,
      nidNumber: json['nidNumber']?.toString(),
      nidFrontImg: json['nidFrontImg']?.toString(),
      nidBackImg: json['nidBackImg']?.toString(),
      tradeLicenseNumber: json['tradeLicenseNumber']?.toString(),
      tradeLicenseImg: (json['tradeLicenseImg'] ?? json['tradeLicenseImage'])
          ?.toString(),
      isOnboardingComplete: json['isOnboardingComplete'] is bool
          ? json['isOnboardingComplete'] as bool
          : null,
      averageRating: json['averageRating']?.toString(),
      totalReviews: json['totalReviews'] is int
          ? json['totalReviews'] as int
          : int.tryParse((json['totalReviews'] ?? '').toString()),
      userId: json['userId']?.toString(),
      createdAt: parseDt(json['createdAt']),
      updatedAt: parseDt(json['updatedAt']),
    );
  }
}
