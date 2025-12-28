// lib/modules/ad_agency/milestone_details/milestone_details_controller.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/job_item.dart';
import '../../../core/theme/app_palette.dart';

/// Local status used for the big status card
enum MilestoneLocalStatus {
  toDo,
  inReview,
  paid,
  approved,
  partialPaid,
  declined,
}

class SubmissionUiModel {
  final int index;

  // form controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController metricLabelController = TextEditingController(
    text: 'Reach',
  );
  final TextEditingController metricValueController = TextEditingController();

  // files + state
  final RxList<PlatformFile> proofs = <PlatformFile>[].obs;
  final RxBool isExpanded = true.obs;

  final Rx<SubmissionStatus> status = SubmissionStatus.inReview.obs;
  final RxBool isSubmitted =
      false.obs; // when true and not declined -> lock fields until edit again

  SubmissionUiModel({required this.index});

  bool get isEditable =>
      !isSubmitted.value || status.value == SubmissionStatus.declined;

  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    linkController.dispose();
    metricLabelController.dispose();
    metricValueController.dispose();
  }
}

class MilestoneDetailsController extends GetxController {
  MilestoneDetailsController(this.arguments);

  final dynamic arguments;

  late final JobItem job;
  // not final because we reassign updated copy
  late Milestone milestone;

  final RxBool headerExpanded = true.obs;

  // status for big status card
  final Rx<MilestoneLocalStatus> milestoneStatus =
      MilestoneLocalStatus.toDo.obs;

  // submissions (UI wrappers)
  final RxList<SubmissionUiModel> submissions = <SubmissionUiModel>[].obs;

  // bottom checkboxes
  final RxBool confirmOwnership = false.obs;
  final RxBool acceptLicense = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (arguments is Map) {
      final map = arguments as Map;
      milestone = map['milestone'] as Milestone;
      job = map['job'] as JobItem;
    } else {
      throw 'MilestoneDetails requires Milestone and JobItem in Get.arguments';
    }

    // build UI submissions from model if already exist
    if (milestone.submissions.isNotEmpty) {
      for (final submission in milestone.submissions) {
        final ui = SubmissionUiModel(index: submission.index);
        ui.descriptionController.text = submission.description;
        ui.amountController.text = submission.amount.toString();
        ui.linkController.text = submission.liveLink;
        ui.metricLabelController.text = submission.metricLabel;
        ui.metricValueController.text = submission.metricValue;
        ui.status.value = submission.status;
        ui.isSubmitted.value = true;
        ui.isExpanded.value = false;
        // proofs will be hydrated later if you store paths/urls
        submissions.add(ui);
      }
    } else {
      submissions.add(SubmissionUiModel(index: 1));
    }

    _syncLocalStatusFromModel();
  }

  void toggleHeader() => headerExpanded.toggle();

  @override
  void onClose() {
    for (final s in submissions) {
      s.dispose();
    }
    super.onClose();
  }

  // ---------- helpers ----------

  void _syncLocalStatusFromModel() {
    switch (milestone.status) {
      case MilestoneStatus.todo:
        milestoneStatus.value = MilestoneLocalStatus.toDo;
        break;
      case MilestoneStatus.inReview:
        milestoneStatus.value = MilestoneLocalStatus.inReview;
        break;
      case MilestoneStatus.paid:
        milestoneStatus.value = MilestoneLocalStatus.paid;
        break;
      case MilestoneStatus.approved:
        milestoneStatus.value = MilestoneLocalStatus.approved;
        break;
      case MilestoneStatus.partialPaid:
        milestoneStatus.value = MilestoneLocalStatus.partialPaid;
        break;
      case MilestoneStatus.declined:
        milestoneStatus.value = MilestoneLocalStatus.declined;
        break;
    }
  }

  int get declinedSubmissionCount => submissions
      .where((s) => s.status.value == SubmissionStatus.declined)
      .length;

  // status text for big pill
  String get statusChipText {
    switch (milestoneStatus.value) {
      case MilestoneLocalStatus.toDo:
        return 'To Do';
      case MilestoneLocalStatus.inReview:
        return 'In Review';
      case MilestoneLocalStatus.approved:
        return 'Approved';
      case MilestoneLocalStatus.paid:
        return 'Paid';
      case MilestoneLocalStatus.partialPaid:
        return 'Partial Paid';
      case MilestoneLocalStatus.declined:
        return '$declinedSubmissionCount Declined';
    }
  }

  Color get statusChipColor {
    switch (milestoneStatus.value) {
      case MilestoneLocalStatus.paid:
        return AppPalette.secondary;
      case MilestoneLocalStatus.approved:
        return AppPalette.secondary;
      case MilestoneLocalStatus.partialPaid:
        return AppPalette.secondary;
      case MilestoneLocalStatus.inReview:
        return AppPalette.complemetaryFill;
      case MilestoneLocalStatus.declined:
        return AppPalette.requiredColor;
      case MilestoneLocalStatus.toDo:
        return AppPalette.neutralGrey;
    }
  }

  Color get statusTextColor {
    switch (milestoneStatus.value) {
      case MilestoneLocalStatus.paid:
        return AppPalette.secondary;
      case MilestoneLocalStatus.approved:
        return AppPalette.secondary;
      case MilestoneLocalStatus.partialPaid:
        return AppPalette.secondary;
      case MilestoneLocalStatus.inReview:
        return AppPalette.complemetary;
      case MilestoneLocalStatus.declined:
        return AppPalette.requiredColor;
      case MilestoneLocalStatus.toDo:
        return AppPalette.neutralGrey;
    }
  }

  Color get statusChipTextColor {
    switch (milestoneStatus.value) {
      case MilestoneLocalStatus.inReview:
        return AppPalette.complemetary;
      default:
        return Colors.white;
    }
  }

  Color get statusBgColor {
    switch (milestoneStatus.value) {
      case MilestoneLocalStatus.paid:
        return AppPalette.thirdColor;
      case MilestoneLocalStatus.approved:
        return AppPalette.thirdColor;
      case MilestoneLocalStatus.partialPaid:
        return AppPalette.thirdColor;
      case MilestoneLocalStatus.inReview:
        return AppPalette.gradient2;
      case MilestoneLocalStatus.declined:
        return AppPalette.errorGradient;
      case MilestoneLocalStatus.toDo:
        return AppPalette.gradient3;
    }
  }

  // payment progress: approved/requested amount vs milestone amount
  bool get showPaymentProgress => submissions.isNotEmpty;

  int _parseAmount(String raw) {
    // removes everything except digits
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }

  int get requestedAmount {
    int sum = 0;
    for (final s in submissions) {
      final v = _parseAmount(s.amountController.text);
      sum += v;
    }
    return sum;
  }

  int get approvedAmountFromModel => milestone.approvedAmount;

  int get milestoneAmountTotal => _parseAmount(milestone.amountLabel);

  double get paymentProgressValue {
    final total = milestoneAmountTotal;
    if (total == 0) return 0;
    // You can choose requestedAmount or approvedAmountFromModel based on flow
    return requestedAmount / total.clamp(1, total);
  }

  String get progressLeftLabel =>
      requestedAmount > 0 ? '৳$requestedAmount' : '৳0';

  String get progressRightLabel => milestone.amountLabel;

  // ---------- actions ----------

  void toggleOwnership() => confirmOwnership.toggle();
  void toggleLicense() => acceptLicense.toggle();

  void addSubmission() {
    submissions.add(SubmissionUiModel(index: submissions.length + 1));
  }

  Future<void> pickProofFor(int submissionIndex) async {
    final submission = submissions[submissionIndex];

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      submission.proofs.addAll(result.files);
    }
  }

  void removeProof(int submissionIndex, int proofIndex) {
    final submission = submissions[submissionIndex];
    if (proofIndex >= 0 && proofIndex < submission.proofs.length) {
      submission.proofs.removeAt(proofIndex);
    }
  }

  void enableEditForDeclined(SubmissionUiModel submission) {
    submission.isSubmitted.value = false;
  }

  /// Called from "Submit For Admin Review" button.
  void submitForReview() {
    if (!confirmOwnership.value || !acceptLicense.value) {
      Get.snackbar(
        'Action required',
        'Please confirm ownership and accept the terms.',
      );
      return;
    }

    // Lock UI submissions and set status to In Review
    for (final ui in submissions) {
      ui.status.value = SubmissionStatus.inReview;
      ui.isSubmitted.value = true;
      ui.isExpanded.value = false;
    }

    // Build domain submissions and update milestone via copyWith
    final domainSubmissions = submissions.map((ui) {
      return Submission(
        index: ui.index,
        description: ui.descriptionController.text.trim(),
        amount: _parseAmount(ui.amountController.text),
        liveLink: ui.linkController.text.trim(),
        metricLabel: ui.metricLabelController.text.trim(),
        metricValue: ui.metricValueController.text.trim(),
        proofPaths: ui.proofs
            .map((f) => f.path ?? f.name) // you can adjust this later
            .toList(),
        status: ui.status.value,
      );
    }).toList();

    milestone = milestone.copyWith(
      status: MilestoneStatus.inReview,
      submissions: domainSubmissions,
    );
    milestoneStatus.value = MilestoneLocalStatus.inReview;

    Get.snackbar('Submitted', 'Milestone sent for admin review');
    // If you want to refresh parent:
    // Get.back(result: milestone);
  }
}
