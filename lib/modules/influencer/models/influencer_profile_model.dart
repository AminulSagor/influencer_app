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
    this.payouts,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full name helper
  String get fullName => '$firstName $lastName'.trim();

  /// Get profile image URL (prefer profileImage, fallback to profileImg)
  String? get displayImage => profileImage ?? profileImg;

  /// Check if profile has verified NID
  bool get hasNidSubmitted =>
      nidNumber != null || nidFrontImg != null || nidBackImg != null;

  /// Get default/primary address
  InfluencerAddress? get primaryAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }

  factory InfluencerProfile.fromJson(Map<String, dynamic> json) {
    return InfluencerProfile(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      bio: json['bio'] as String?,
      profileImage: json['profileImage'] as String?,
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map(
                (e) => InfluencerAddress.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      niches: (json['niches'] as List<dynamic>?)
          ?.map((e) => InfluencerNiche.fromJson(e))
          .toList(),
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => InfluencerSkill.fromJson(e))
          .toList(),
      website: json['website'] as String?,
      socialLinks: (json['socialLinks'] as List<dynamic>?)
          ?.map((e) => InfluencerSocialLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      nidNumber: json['nidNumber'] as String?,
      nidFrontImg: json['nidFrontImg'] as String?,
      nidBackImg: json['nidBackImg'] as String?,
      nidVerification: json['nidVerification'] != null
          ? NidVerificationStatus.fromJson(json['nidVerification'])
          : null,
      profileImg: json['profileImg'] as String?,
      isOnboardingComplete:
          json['isOnboardingComplete'] as bool? ??
          json['isVerified'] as bool? ??
          false,
      payouts: json['payouts'] != null
          ? InfluencerPayouts.fromJson(json['payouts'] as Map<String, dynamic>)
          : null,
      averageRating: _parseDouble(json['averageRating']),
      totalReviews: json['totalReviews'] as int? ?? 0,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'payouts': payouts?.toJson(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
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
}

/// Address model for influencer
class InfluencerAddress {
  final String? addressName;
  final String? thana;
  final String? zilla;
  final String? fullAddress;
  final bool isDefault;

  InfluencerAddress({
    this.addressName,
    this.thana,
    this.zilla,
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
    return parts.join(', ');
  }

  factory InfluencerAddress.fromJson(Map<String, dynamic> json) {
    return InfluencerAddress(
      addressName: json['addressName'] as String?,
      thana: json['thana'] as String?,
      zilla: json['zilla'] as String?,
      fullAddress: json['fullAddress'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressName': addressName,
      'thana': thana,
      'zilla': zilla,
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

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory InfluencerSocialLink.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['verificationStatus'] ?? '')
        .toString()
        .toLowerCase()
        .trim();

    return InfluencerSocialLink(
      platform: json['platform'] as String? ?? '',
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
      return InfluencerNiche(
        name: json['name'] as String? ?? json['niche'] as String? ?? '',
        status: json['status'] as String?,
      );
    }
    return InfluencerNiche(name: json.toString());
  }

  Map<String, dynamic> toJson() {
    return {'name': name, if (status != null) 'status': status};
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
      return InfluencerSkill(
        name: json['name'] as String? ?? json['skill'] as String? ?? '',
        status: json['status'] as String?,
      );
    }
    return InfluencerSkill(name: json.toString());
  }

  Map<String, dynamic> toJson() {
    return {'name': name, if (status != null) 'status': status};
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
      return NidVerificationStatus(
        status: json['status'] as String?,
        rejectionReason: json['rejectionReason'] as String?,
        verifiedAt: json['verifiedAt'] != null
            ? DateTime.tryParse(json['verifiedAt'] as String)
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
    return BankPayout(
      id: json['id'] as String?,
      bankName: json['bankName'] as String? ?? '',
      bankAccHolderName: json['bankAccHolderName'] as String? ?? '',
      bankAccNo: json['bankAccNo'] as String? ?? '',
      bankBranchName: json['bankBranchName'] as String?,
      bankRoutingNo: json['bankRoutingNo'] as String?,
      status: json['status'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
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
    return MobilePayout(
      id: json['id'] as String?,
      accountType: json['accountType'] as String? ?? '',
      accountHolderName: json['accountHolderName'] as String? ?? '',
      accountNo: json['accountNo'] as String? ?? '',
      status: json['status'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
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
