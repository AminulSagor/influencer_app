class SocialAccount {
  final String platform;
  final String iconPath;
  final String handle;
  final bool isVerified;

  const SocialAccount({
    required this.platform,
    required this.handle,
    this.isVerified = false,
    required this.iconPath,
  });
}
