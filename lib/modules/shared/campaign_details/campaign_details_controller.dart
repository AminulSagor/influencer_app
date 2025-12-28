import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import '../../../core/models/job_item.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/label_localizers.dart';

enum CampaignStatus { newOffer, accepted, ongoing, ongoingDeclined, complete }

class CampaignDetailsController extends GetxController {
  final dynamic arguments;
  CampaignDetailsController(this.arguments);

  late final JobItem job;
  bool _isNewOffer = true;

  final accountTypeService = Get.find<AccountTypeService>();

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

  void toggleMilestones() => milestonesExpanded.toggle();
  void toggleBrief() => briefExpanded.toggle();
  void toggleContentAssets() => contentAssetsExpanded.toggle();
  void toggleTerms() => termsExpanded.toggle();
  void toggleBrandAssets() => brandAssetsExpanded.toggle();
  void toggleAgree() => agreeToTerms.toggle();

  void onAccept() {
    final isInfluencer = accountTypeService.isInfluencer;
    if (!agreeToTerms.value && !isInfluencer) {
      Get.snackbar(
        'campaign_agreement_required'.tr,
        'campaign_agreement_required_desc'.tr,
      );
      return;
    }
    _isNewOffer = false;
    _recalculateStatus();
  }

  void onDecline() => Get.back(id: 1);

  void openMilestoneDetails(Milestone milestone) {
    Get.toNamed(
      AppRoutes.milestoneDetails,
      id: 1,
      arguments: {'job': job, 'milestone': milestone},
    );
  }

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

  String get deadlineMainText => localizeDaysRemainingFromDue(job.dueLabel);

  bool get showQuoteCard => campaignStatus.value == CampaignStatus.newOffer;
  bool get showAgreementBar => campaignStatus.value == CampaignStatus.newOffer;
}
