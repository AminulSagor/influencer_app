class InfluencerRowModel {
  final String name;
  final int campaignDone;

  InfluencerRowModel({required this.name, required this.campaignDone});
}

class PlatformStatModel {
  final String platformName;
  final int jobsCompleted;
  final String iconAsset;

  PlatformStatModel({
    required this.platformName,
    required this.jobsCompleted,
    required this.iconAsset,
  });
}
