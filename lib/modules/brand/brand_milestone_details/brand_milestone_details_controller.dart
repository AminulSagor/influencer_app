import 'package:get/get.dart';
import '../../../core/models/job_item.dart';

class BrandMilestoneDetailsController extends GetxController {
  late final JobItem job;
  late final Milestone milestone;

  final selectedSubmissionIndex = 0.obs;
  final submissionStatus = SubmissionStatus.inReview.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      job = (args['job'] as JobItem);
      milestone = (args['milestone'] as Milestone);
    } else {
      // minimal fallback (won't crash)
      job = const JobItem(
        title: 'Campaign',
        clientName: 'Client',
        dateLabel: '—',
        budget: 0,
        sharePercent: 0,
        campaignType: CampaignType.influencerPromotion,
      );
      milestone = const Milestone(stepLabel: '1', title: 'Milestone');
    }

    if (milestone.submissions.isNotEmpty) {
      submissionStatus.value = milestone.submissions.first.status;
    }
  }

  Submission get currentSubmission {
    if (milestone.submissions.isEmpty) {
      return const Submission(
        index: 1,
        description: '',
        amount: 0,
        liveLink: '',
        metricLabel: '',
        metricValue: '',
        proofPaths: [],
        status: SubmissionStatus.inReview,
      );
    }
    final i = selectedSubmissionIndex.value.clamp(
      0,
      milestone.submissions.length - 1,
    );
    return milestone.submissions[i];
  }

  List<String> get requirements {
    final r = milestone.contentRequirements;
    if (r != null && r.isNotEmpty) return r;

    // fallback: try from subtitle "A + B"
    final sub = (milestone.subtitle ?? '').trim();
    if (sub.contains('+')) {
      return sub
          .split('+')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (sub.isNotEmpty) return [sub];

    return const [];
  }

  PromotionTarget get targets => milestone.targets ?? const PromotionTarget();

  PromotionTarget get achieved =>
      currentSubmission.achieved ?? const PromotionTarget();

  String get submittedDateLabel =>
      (currentSubmission.submittedDateLabel ?? '').trim().isNotEmpty
      ? currentSubmission.submittedDateLabel!.trim()
      : job.dateLabel;

  void reportAdmin() {
    Get.snackbar('Report', 'Reported to admin.');
  }

  void approve() {
    submissionStatus.value = SubmissionStatus.approved;
    Get.snackbar('Approved', 'Submission approved.');
  }

  void decline() {
    submissionStatus.value = SubmissionStatus.declined;
    Get.snackbar('Declined', 'Submission declined.');
  }
}
