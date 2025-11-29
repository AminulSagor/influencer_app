// campaign_details_controller.dart
import 'package:get/get.dart';
import '../../../core/models/job_item.dart';
import '../../../routes/app_routes.dart';

enum CampaignStatus {
  newOffer, // quote + accept bar visible
  accepted, // everything todo
  ongoing, // some milestones paid/partial
  ongoingDeclined, // at least one declined
  complete, // all paid or partialPaid
}

class CampaignDetailsController extends GetxController {
  final dynamic arguments;
  CampaignDetailsController(this.arguments);

  late final JobItem job;
  bool _isNewOffer = true; // comes from arguments

  final milestonesExpanded = true.obs;
  final briefExpanded = true.obs;
  final contentAssetsExpanded = true.obs;
  final termsExpanded = true.obs;
  final brandAssetsExpanded = true.obs;
  final agreeToTerms = false.obs;

  final campaignStatus = CampaignStatus.newOffer.obs;

  @override
  void onInit() {
    super.onInit();

    job = arguments;

    _recalculateStatus();
  }

  // ---------- toggles ----------
  void toggleMilestones() => milestonesExpanded.toggle();
  void toggleBrief() => briefExpanded.toggle();
  void toggleContentAssets() => contentAssetsExpanded.toggle();
  void toggleTerms() => termsExpanded.toggle();
  void toggleBrandAssets() => brandAssetsExpanded.toggle();
  void toggleAgree() => agreeToTerms.toggle();

  // ---------- accept / decline ----------
  void onAccept() {
    if (!agreeToTerms.value) {
      Get.snackbar('Agreement required', 'Please accept the terms to continue');
      return;
    }

    // Once accepted, it's no longer a "new offer"
    _isNewOffer = false;
    _recalculateStatus();

    // TODO: call API to mark as accepted
  }

  void onDecline() {
    // TODO: API call for decline if needed
    Get.back(id: 1);
  }

  void openMilestoneDetails(Milestone milestone) {
    Get.toNamed(
      AppRoutes.milestoneDetails,
      id: 1,
      arguments: {'job': job, 'milestone': milestone},
    );
  }

  // ---------- status helpers ----------

  void _recalculateStatus() {
    final milestones = job.milestones ?? const <Milestone>[];

    if (_isNewOffer) {
      campaignStatus.value = CampaignStatus.newOffer;
      return;
    }

    if (milestones.isEmpty) {
      campaignStatus.value = CampaignStatus.accepted;
      return;
    }

    final allTodo = milestones.every((m) => m.status == MilestoneStatus.todo);

    final allPaidOrPartial = milestones.every(
      (m) =>
          m.status == MilestoneStatus.paid ||
          m.status == MilestoneStatus.partialPaid,
    );

    final somePaidOrPartial = milestones.any(
      (m) =>
          m.status == MilestoneStatus.paid ||
          m.status == MilestoneStatus.partialPaid,
    );

    final anyDeclined = milestones.any(
      (m) => m.status == MilestoneStatus.declined,
    );

    if (allTodo) {
      campaignStatus.value = CampaignStatus.accepted;
    } else if (allPaidOrPartial) {
      campaignStatus.value = CampaignStatus.complete;
    } else if (anyDeclined) {
      campaignStatus.value = CampaignStatus.ongoingDeclined;
    } else if (somePaidOrPartial) {
      campaignStatus.value = CampaignStatus.ongoing;
    } else {
      campaignStatus.value = CampaignStatus.accepted;
    }
  }

  // used by the top card
  String get deadlineMainText {
    final raw = job.dueLabel ?? '';
    if (raw.toLowerCase().startsWith('due')) {
      return raw.replaceFirst(RegExp(r'(?i)due\s*:?'), '').trim() +
          ' Remaining';
    }
    return raw.isEmpty ? 'No Deadline' : raw;
  }

  bool get showQuoteCard => campaignStatus.value == CampaignStatus.newOffer;
  bool get showAgreementBar => campaignStatus.value == CampaignStatus.newOffer;
}
