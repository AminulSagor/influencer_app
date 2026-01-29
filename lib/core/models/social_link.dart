class SocialLink {
  final String? website;
  final String platform;
  final String profileUrl;
  Map<String, dynamic> toJson() {
    return {"website": website, "platform": platform, "profileUrl": profileUrl};
  }

  SocialLink({this.website, required this.platform, required this.profileUrl});
}
