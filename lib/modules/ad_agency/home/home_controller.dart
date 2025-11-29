import 'package:get/get.dart';

class HomeJob {
  final String title;
  final String clientName;
  final String dueLabel;
  final String dueDate;
  final double budget;
  final int progressPercent;
  final int sharePercent;

  HomeJob({
    required this.title,
    required this.clientName,
    required this.dueLabel,
    required this.dueDate,
    required this.budget,
    required this.progressPercent,
    required this.sharePercent,
  });
}

class HomeController extends GetxController {
  final lifetimeEarnings = 200000.obs;
  final pendingEarnings = 18000.obs;

  final activeJobs = 20.obs;
  final newOffers = 11.obs;

  final jobsInProgress = <HomeJob>[].obs;

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
      HomeJob(
        title: 'Summer Fashion Campaign',
        clientName: 'StyleCo',
        dueLabel: 'Due: 3 Days',
        dueDate: 'Dec 28, 2025',
        budget: 111000,
        progressPercent: 75,
        sharePercent: 10,
      ),
      HomeJob(
        title: 'Tech Product Launch',
        clientName: 'TechGuru',
        dueLabel: 'Due: 4 Days',
        dueDate: 'Dec 28, 2025',
        budget: 111000,
        progressPercent: 40,
        sharePercent: 15,
      ),
      HomeJob(
        title: 'Fitness Brand Partnership',
        clientName: 'FitLife',
        dueLabel: 'Due: Tomorrow',
        dueDate: 'Dec 28, 2025',
        budget: 111000,
        progressPercent: 90,
        sharePercent: 10,
      ),
    ]);
  }
}
