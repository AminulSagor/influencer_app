/// Influencer Profile Model
///
/// API Endpoint: GET /influencer/profile
/// Returns the complete profile data for the logged-in influencer.

class InfluencerProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profileImage;
  final List<InfluencerAddress> addresses;
  final List<InfluencerNiche>? niches;
  final List<InfluencerSkill>? skills;
  final String? website;
  final List<InfluencerSocialLink>? socialLinks;
  final String? nidNumber;
  final String? nidFrontImg;
  final String? nidBackImg;
  final NidVerificationStatus? nidVerification;
  final String? profileImg;
  final bool isOnboardingComplete;
  final InfluencerPayouts? payouts;
  final double averageRating;
  final int totalReviews;
  final bool isVerified;
  final bool? isPhoneVerified;
  final bool? isEmailVerified;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  InfluencerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profileImage,
    this.addresses = const [],
    this.niches,
    this.skills,
    this.website,
    this.socialLinks,
    this.nidNumber,
    this.nidFrontImg,
    this.nidBackImg,
    this.nidVerification,
    this.profileImg,
    required this.isOnboardingComplete,
    required this.isVerified,
    this.payouts,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isPhoneVerified,
    this.isEmailVerified,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  String? get displayImage => profileImage ?? profileImg;

  bool get hasNidSubmitted =>
      nidNumber != null || nidFrontImg != null || nidBackImg != null;

  InfluencerAddress? get primaryAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }

  InfluencerProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? bio,
    String? profileImage,
    List<InfluencerAddress>? addresses,
    List<InfluencerNiche>? niches,
    List<InfluencerSkill>? skills,
    String? website,
    List<InfluencerSocialLink>? socialLinks,
    String? nidNumber,
    String? nidFrontImg,
    String? nidBackImg,
    NidVerificationStatus? nidVerification,
    String? profileImg,
    bool? isOnboardingComplete,
    InfluencerPayouts? payouts,
    double? averageRating,
    int? totalReviews,
    bool? isVerified,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InfluencerProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      addresses: addresses ?? this.addresses,
      niches: niches ?? this.niches,
      skills: skills ?? this.skills,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
      nidNumber: nidNumber ?? this.nidNumber,
      nidFrontImg: nidFrontImg ?? this.nidFrontImg,
      nidBackImg: nidBackImg ?? this.nidBackImg,
      nidVerification: nidVerification ?? this.nidVerification,
      profileImg: profileImg ?? this.profileImg,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      payouts: payouts ?? this.payouts,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory InfluencerProfile.fromJson(Map<String, dynamic> source) {
    // Handle potential data wrapping from API
    final json = (source['data'] is Map<String, dynamic>)
        ? source['data'] as Map<String, dynamic>
        : source;

    return InfluencerProfile(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      profileImage: (json['profileImage'] ?? json['profileImg'] ?? '')
          .toString(),
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map(
                (e) => InfluencerAddress.fromJson(
                  e is Map ? Map<String, dynamic>.from(e) : {},
                ),
              )
              .toList() ??
          [],
      niches: (json['niches'] as List<dynamic>?)
          ?.map((e) => InfluencerNiche.fromJson(e))
          .toList(),
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => InfluencerSkill.fromJson(e))
          .toList(),
      website: (json['website'] ?? '').toString(),
      socialLinks: (json['socialLinks'] as List<dynamic>?)
          ?.map(
            (e) => InfluencerSocialLink.fromJson(
              e is Map ? Map<String, dynamic>.from(e) : {},
            ),
          )
          .toList(),
      nidNumber: (json['nidNumber'] ?? '').toString(),
      nidFrontImg: (json['nidFrontImg'] ?? json['nidFrontImage'] ?? '')
          .toString(),
      nidBackImg: (json['nidBackImg'] ?? json['nidBackImage'] ?? '').toString(),
      nidVerification: json['nidVerification'] != null
          ? NidVerificationStatus.fromJson(json['nidVerification'])
          : null,
      profileImg: (json['profileImg'] ?? json['profileImage'] ?? '').toString(),
      isOnboardingComplete: _parseBool(
        json['isOnboardingComplete'] ?? json['isVerified'] ?? false,
      ),
      isVerified: _parseBool(json['isVerified'] ?? false),
      payouts: json['payouts'] != null
          ? InfluencerPayouts.fromJson(
              Map<String, dynamic>.from(json['payouts'] as Map),
            )
          : null,
      averageRating: _parseDouble(json['averageRating']),
      totalReviews: _parseInt(json['totalReviews']),
      isPhoneVerified: _parseBoolOrNull(json['isPhoneVerified']),
      isEmailVerified: _parseBoolOrNull(json['isEmailVerified']),
      userId: (json['userId'] ?? json['uid'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profileImage': profileImage,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'niches': niches?.map((e) => e.toJson()).toList(),
      'skills': skills?.map((e) => e.toJson()).toList(),
      'website': website,
      'socialLinks': socialLinks?.map((e) => e.toJson()).toList(),
      'nidNumber': nidNumber,
      'nidFrontImg': nidFrontImg,
      'nidBackImg': nidBackImg,
      'nidVerification': nidVerification?.toJson(),
      'profileImg': profileImg,
      'isOnboardingComplete': isOnboardingComplete,
      'isVerified': isVerified,
      'payouts': payouts?.toJson(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static bool? _parseBoolOrNull(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final str = value.toString();
    if (str.isEmpty) return DateTime.now();
    return DateTime.tryParse(str) ?? DateTime.now();
  }
}

/// Address model for influencer
class InfluencerAddress {
  final String? addressName;
  final String? thana;
  final String? zilla;
  final String? country;
  final String? fullAddress;
  final bool isDefault;

  InfluencerAddress({
    this.addressName,
    this.thana,
    this.zilla,
    this.country,
    this.fullAddress,
    this.isDefault = false,
  });

  /// Get formatted address string
  String get formattedAddress {
    final parts = <String>[];
    if (fullAddress != null && fullAddress!.isNotEmpty) {
      parts.add(fullAddress!);
    }
    if (thana != null && thana!.isNotEmpty) {
      parts.add(thana!);
    }
    if (zilla != null && zilla!.isNotEmpty) {
      parts.add(zilla!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  factory InfluencerAddress.fromJson(Map<String, dynamic> json) {
    return InfluencerAddress(
      addressName: (json['addressName'] ?? '').toString(),
      thana: (json['thana'] ?? '').toString(),
      zilla: (json['zilla'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      fullAddress: (json['fullAddress'] ?? '').toString(),
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressName': addressName,
      'thana': thana,
      'zilla': zilla,
      'country': country,
      'fullAddress': fullAddress,
      'isDefault': isDefault,
    };
  }
}

/// Social link model for influencer profile
class InfluencerSocialLink {
  final String platform;
  final String url;
  final String? website;
  final String status; // 'verified', 'unverified', 'pending', 'rejected'

  InfluencerSocialLink({
    required this.platform,
    required this.url,
    this.website,
    this.status = 'unverified',
  });

  bool get isVerified => (status == 'verified' || status == 'approved');
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory InfluencerSocialLink.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['verificationStatus'] ?? '')
        .toString()
        .toLowerCase()
        .trim();

    return InfluencerSocialLink(
      platform: json['platform'] ?? '',
      url:
          (json['profileUrl'] ?? json['url'] ?? json['link'])?.toString() ?? '',
      website: json['website']?.toString(),
      status: rawStatus.isEmpty
          ? ((json['isVerified'] == true) ? 'verified' : 'unverified')
          : rawStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
      if (website != null) 'website': website,
      'status': status,
    };
  }
}

/// Niche model - can be string or object with verification status
class InfluencerNiche {
  final String name;
  final String? status; // 'approved', 'pending', 'rejected'

  InfluencerNiche({required this.name, this.status});

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory InfluencerNiche.fromJson(dynamic json) {
    if (json is String) {
      return InfluencerNiche(name: json);
    }
    if (json is Map<String, dynamic>) {
      final rawStatus = (json['status'] ?? json['verificationStatus'])
          ?.toString();
      return InfluencerNiche(
        name: json['name'] ?? json['niche'] ?? '',
        status: _normalizeVerificationStatus(rawStatus),
      );
    }
    return InfluencerNiche(name: json.toString());
  }

  Map<String, dynamic> toJson() {
    return {'name': name, if (status != null) 'status': status};
  }

  static String? _normalizeVerificationStatus(dynamic rawStatus) {
    final value = rawStatus?.toString().trim().toLowerCase();
    if (value == null || value.isEmpty) return null;
    if (value == 'active') return 'approved';
    if (value == 'in_review' ||
        value == 'under_review' ||
        value == 'reviewing') {
      return 'pending';
    }
    return value;
  }
}

/// Skill model - can be string or object with verification status
class InfluencerSkill {
  final String name;
  final String? status; // 'approved', 'pending', 'rejected'

  InfluencerSkill({required this.name, this.status});

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory InfluencerSkill.fromJson(dynamic json) {
    if (json is String) {
      return InfluencerSkill(name: json);
    }
    if (json is Map<String, dynamic>) {
      final rawStatus = (json['status'] ?? json['verificationStatus'])
          ?.toString();
      return InfluencerSkill(
        name: json['name'] ?? json['skill'] ?? '',
        status: _normalizeVerificationStatus(rawStatus),
      );
    }
    return InfluencerSkill(name: json.toString());
  }

  Map<String, dynamic> toJson() {
    return {'name': name, if (status != null) 'status': status};
  }

  static String? _normalizeVerificationStatus(dynamic rawStatus) {
    final value = rawStatus?.toString().trim().toLowerCase();
    if (value == null || value.isEmpty) return null;
    if (value == 'active') return 'approved';
    if (value == 'in_review' ||
        value == 'under_review' ||
        value == 'reviewing') {
      return 'pending';
    }
    return value;
  }
}

/// NID verification status
class NidVerificationStatus {
  final String? status; // 'approved', 'pending', 'rejected'
  final String? rejectionReason;
  final DateTime? verifiedAt;

  NidVerificationStatus({this.status, this.rejectionReason, this.verifiedAt});

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory NidVerificationStatus.fromJson(dynamic json) {
    // Handle if it's a list (from response) - take first item or extract status
    if (json is List) {
      // It appears to be address verification data in the response
      // This might be used differently - return null status
      return NidVerificationStatus();
    }
    if (json is Map<String, dynamic>) {
      final rawStatus = (json['status'] ?? json['nidStatus'])
          ?.toString()
          .toLowerCase()
          .trim();
      final normalizedStatus = rawStatus == 'active' ? 'approved' : rawStatus;

      return NidVerificationStatus(
        status: normalizedStatus,
        rejectionReason: (json['rejectionReason'] ?? json['nidRejectReason'])
            ?.toString(),
        verifiedAt: json['verifiedAt'] != null
            ? DateTime.tryParse(json['verifiedAt'] ?? '')
            : null,
      );
    }
    return NidVerificationStatus();
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'rejectionReason': rejectionReason,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }
}

/// Payout methods container
class InfluencerPayouts {
  final List<BankPayout> bankAccounts;
  final List<MobilePayout> mobileAccounts;

  InfluencerPayouts({
    this.bankAccounts = const [],
    this.mobileAccounts = const [],
  });

  bool get isEmpty => bankAccounts.isEmpty && mobileAccounts.isEmpty;
  bool get isNotEmpty => !isEmpty;

  factory InfluencerPayouts.fromJson(Map<String, dynamic> json) {
    return InfluencerPayouts(
      bankAccounts:
          (json['bank'] as List<dynamic>?)
              ?.map((e) => BankPayout.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mobileAccounts:
          (json['mobileBanking'] as List<dynamic>?)
              ?.map((e) => MobilePayout.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank': bankAccounts.map((e) => e.toJson()).toList(),
      'mobileBanking': mobileAccounts.map((e) => e.toJson()).toList(),
    };
  }
}

/// Bank payout method
class BankPayout {
  final String? id;
  final String bankName;
  final String bankAccHolderName;
  final String bankAccNo;
  final String? bankBranchName;
  final String? bankRoutingNo;
  final String? status; // 'approved', 'pending', 'rejected'
  final bool isDefault;

  BankPayout({
    this.id,
    required this.bankName,
    required this.bankAccHolderName,
    required this.bankAccNo,
    this.bankBranchName,
    this.bankRoutingNo,
    this.status,
    this.isDefault = false,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory BankPayout.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['accStatus'])
        ?.toString()
        .toLowerCase()
        .trim();
    final normalizedStatus = rawStatus == 'active' ? 'approved' : rawStatus;

    return BankPayout(
      id: json['id'] ?? '',
      bankName: json['bankName'] ?? '',
      bankAccHolderName: json['bankAccHolderName'] ?? '',
      bankAccNo: json['bankAccNo'] ?? '',
      bankBranchName: json['bankBranchName'] ?? '',
      bankRoutingNo: json['bankRoutingNo'] ?? '',
      status: normalizedStatus,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bankName': bankName,
      'bankAccHolderName': bankAccHolderName,
      'bankAccNo': bankAccNo,
      'bankBranchName': bankBranchName,
      'bankRoutingNo': bankRoutingNo,
      'status': status,
      'isDefault': isDefault,
    };
  }
}

/// Mobile banking payout method
class MobilePayout {
  final String? id;
  final String accountType; // 'Bkash', 'Nagad', 'Rocket', etc.
  final String accountHolderName;
  final String accountNo;
  final String? status; // 'approved', 'pending', 'rejected'
  final bool isDefault;

  MobilePayout({
    this.id,
    required this.accountType,
    required this.accountHolderName,
    required this.accountNo,
    this.status,
    this.isDefault = false,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory MobilePayout.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['accStatus'])
        ?.toString()
        .toLowerCase()
        .trim();
    final normalizedStatus = rawStatus == 'active' ? 'approved' : rawStatus;

    return MobilePayout(
      id: json['id'] ?? '',
      accountType: json['accountType'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      accountNo: json['accountNo'] ?? '',
      status: normalizedStatus,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'accountType': accountType,
      'accountHolderName': accountHolderName,
      'accountNo': accountNo,
      'status': status,
      'isDefault': isDefault,
    };
  }
}
