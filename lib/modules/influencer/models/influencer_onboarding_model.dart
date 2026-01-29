import '../../../core/models/social_link.dart';

class InfluencerOnboardingModel {
  String? fullAddress;
  String? thana;
  String? zilla;
  String? website;

  List<SocialLink> socialLinks = [];

  String? nidNumber;
  String? nidFrontImg;
  String? nidBackImg;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (fullAddress != null) json["fullAddress"] = fullAddress;
    if (thana != null) json["thana"] = thana;
    if (zilla != null) json["zilla"] = zilla;
    if (website != null) json["website"] = website;
    json["socialLinks"] = socialLinks.map((e) => e.toJson()).toList();
    if (nidNumber != null) json["nidNumber"] = nidNumber;
    if (nidFrontImg != null) json["nidFrontImg"] = nidFrontImg;
    if (nidBackImg != null) json["nidBackImg"] = nidBackImg;

    return json;
  }
}
