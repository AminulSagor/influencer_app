import 'package:get/get.dart';
import 'package:influencer_app/core/models/job_item.dart';

class HomeController extends GetxController {
  final lifetimeEarnings = 200000.obs;
  final pendingEarnings = 18000.obs;

  final activeJobs = 20.obs;
  final newOffers = 11.obs;

  final jobsInProgress = <JobItem>[].obs;

  final topClientName = 'TechGuru'.obs;
  final topClientJobsCompleted = 12.obs;
  final totalJobsCompleted = 40.obs;
  final totalJobsDeclined = 4.obs;
  final totalEarningsK = 200.obs;
  final mostUsedPlatform = 'Tiktok'.obs;

  @override
  void onInit() {
    super.onInit();
    jobsInProgress.assignAll([
      JobItem(
        title: 'Summer Fashion Campaign',
        subTitle: 'Influencer Promotion',
        campaignType: CampaignType.influencerPromotion,
        clientName: 'StyleCo',
        dueInDays: 3,
        dateLabel: 'Dec 15, 2025',
        budget: 11000,
        progressPercent: 75,
        sharePercent: 10,
      ),
      JobItem(
        title: 'Tech Product Launch',
        subTitle: 'Influencer Promotion',
        campaignType: CampaignType.influencerPromotion,
        clientName: 'TechGuru',
        dueInDays: 4,
        dateLabel: 'Dec 28, 2025',
        budget: 18000,
        progressPercent: 40,
        sharePercent: 15,
      ),
      JobItem(
        title: 'Fitness Brand Partnership',
        subTitle: 'Influencer Promotion',
        campaignType: CampaignType.influencerPromotion,
        clientName: 'FitLife',
        dueInDays: 1, // tomorrow
        dateLabel: 'Dec 26, 2025',
        budget: 32000,
        progressPercent: 90,
        sharePercent: 10,
      ),
    ]);
  }
}
