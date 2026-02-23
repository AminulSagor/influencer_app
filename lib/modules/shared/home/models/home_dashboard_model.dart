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
