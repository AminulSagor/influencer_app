import 'package:influencer_app/core/models/job_item.dart';

enum HomeUserType { brand, influencer, agency, unknown }

class HomeDashboardModel {
  final HomeUserType userType;
  final int lifetimeEarnings;
  final int pendingEarnings;
  final int activeJobs;
  final int newOffers;
  final List<JobItem> jobsInProgress;
  final String topClientName;
  final int topClientJobsCompleted;
  final int totalJobsCompleted;
  final int totalJobsDeclined;
  final int totalEarningsK;
  final String mostUsedPlatform;

  const HomeDashboardModel({
    required this.userType,
    required this.lifetimeEarnings,
    required this.pendingEarnings,
    required this.activeJobs,
    required this.newOffers,
    required this.jobsInProgress,
    required this.topClientName,
    required this.topClientJobsCompleted,
    required this.totalJobsCompleted,
    required this.totalJobsDeclined,
    required this.totalEarningsK,
    required this.mostUsedPlatform,
  });

  factory HomeDashboardModel.empty({
    HomeUserType userType = HomeUserType.unknown,
  }) {
    return HomeDashboardModel(
      userType: userType,
      lifetimeEarnings: 0,
      pendingEarnings: 0,
      activeJobs: 0,
      newOffers: 0,
      jobsInProgress: const [],
      topClientName: '—',
      topClientJobsCompleted: 0,
      totalJobsCompleted: 0,
      totalJobsDeclined: 0,
      totalEarningsK: 0,
      mostUsedPlatform: '—',
    );
  }

  factory HomeDashboardModel.mockForUserType(HomeUserType userType) {
    final jobs = <JobItem>[
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
        dueInDays: 1,
        dateLabel: 'Dec 26, 2025',
        budget: 32000,
        progressPercent: 90,
        sharePercent: 10,
      ),
    ];

    switch (userType) {
      case HomeUserType.agency:
        return HomeDashboardModel(
          userType: userType,
          lifetimeEarnings: 280000,
          pendingEarnings: 25000,
          activeJobs: 18,
          newOffers: 6,
          jobsInProgress: jobs,
          topClientName: 'BrandNova',
          topClientJobsCompleted: 9,
          totalJobsCompleted: 36,
          totalJobsDeclined: 3,
          totalEarningsK: 280,
          mostUsedPlatform: 'Instagram',
        );
      case HomeUserType.influencer:
        return HomeDashboardModel(
          userType: userType,
          lifetimeEarnings: 200000,
          pendingEarnings: 18000,
          activeJobs: 20,
          newOffers: 11,
          jobsInProgress: jobs,
          topClientName: 'TechGuru',
          topClientJobsCompleted: 12,
          totalJobsCompleted: 40,
          totalJobsDeclined: 4,
          totalEarningsK: 200,
          mostUsedPlatform: 'Tiktok',
        );
      case HomeUserType.brand:
        return HomeDashboardModel.empty(userType: userType);
      case HomeUserType.unknown:
        return HomeDashboardModel.empty(userType: userType);
    }
  }

  HomeDashboardModel copyWith({
    HomeUserType? userType,
    int? lifetimeEarnings,
    int? pendingEarnings,
    int? activeJobs,
    int? newOffers,
    List<JobItem>? jobsInProgress,
    String? topClientName,
    int? topClientJobsCompleted,
    int? totalJobsCompleted,
    int? totalJobsDeclined,
    int? totalEarningsK,
    String? mostUsedPlatform,
  }) {
    return HomeDashboardModel(
      userType: userType ?? this.userType,
      lifetimeEarnings: lifetimeEarnings ?? this.lifetimeEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      activeJobs: activeJobs ?? this.activeJobs,
      newOffers: newOffers ?? this.newOffers,
      jobsInProgress: jobsInProgress ?? this.jobsInProgress,
      topClientName: topClientName ?? this.topClientName,
      topClientJobsCompleted:
          topClientJobsCompleted ?? this.topClientJobsCompleted,
      totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
      totalJobsDeclined: totalJobsDeclined ?? this.totalJobsDeclined,
      totalEarningsK: totalEarningsK ?? this.totalEarningsK,
      mostUsedPlatform: mostUsedPlatform ?? this.mostUsedPlatform,
    );
  }
}
