// lib/modules/ad_agency/milestone_details/milestone_details_controller.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../../ad_agency/services/upload_service.dart';
import '../../../core/models/job_item.dart';
import '../../../core/services/account_type_service.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/campaign_service.dart';
import '../../../core/theme/app_palette.dart';
import 'widgets/brand_submission_card.dart';

/// Local status used for the big status card
enum MilestoneLocalStatus {
  toDo,
  inReview,
  paid,
  approved,
  partialPaid,
  declined,
  completed,
}

class AdminReportModel {
  final String reason;
  final DateTime createdAt;

  AdminReportModel({required this.reason, required this.createdAt});
}

class SubmissionUiModel {
  final int index;
  String? serverId;

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
  final Rxn<Milestone> milestoneRx = Rxn<Milestone>();

  final RxBool headerExpanded = true.obs;

  // status for big status card
  final Rx<MilestoneLocalStatus> milestoneStatus =
      MilestoneLocalStatus.toDo.obs;

  // submissions (UI wrappers)
  final RxList<SubmissionUiModel> submissions = <SubmissionUiModel>[].obs;
  final RxList<BrandSubmissionUiModel> brandSubmissions =
      <BrandSubmissionUiModel>[].obs;
  final RxBool isBrandSubmissionsLoading = false.obs;
  final RxnInt selectedBrandSubmissionIndex = RxnInt();

  // bottom checkboxes
  final RxBool confirmOwnership = false.obs;
  final RxBool acceptLicense = false.obs;
  final ApiClient _apiClient = Get.find<ApiClient>();
  final CampaignService _campaignService = Get.find<CampaignService>();
  final UploadService _uploadService = Get.find<UploadService>();
  bool _needsParentRefresh = false;
  bool _didProbeCampaignSubmissionDetails = false;

  final AccountTypeService _accountTypeService = Get.find<AccountTypeService>();
  @override
  void onInit() {
    super.onInit();

    if (arguments is Map) {
      final map = arguments as Map;
      milestone = map['milestone'] as Milestone;
      milestoneRx.value = milestone;
      job = map['job'] as JobItem;
    } else {
      throw 'MilestoneDetails requires Milestone and JobItem in Get.arguments';
    }

    // build UI submissions from model if already exist
    if (milestone.submissions.isNotEmpty) {
      for (final submission in milestone.submissions) {
        final ui = SubmissionUiModel(index: submission.index);
        ui.serverId = submission.id;
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

    final isBrand = _accountTypeService.isBrand;
    final isPaidAd = job.campaignType == CampaignType.paidAd;

    if (isBrand) {
      _loadBrandMilestoneDetails(isPaidAd: isPaidAd);
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

  // --- Report Admin state ---
  final RxBool hasReportedToAdmin = false.obs;
  final Rxn<DateTime> reportAgainAt = Rxn<DateTime>();
  final RxList<AdminReportModel> submittedReports = <AdminReportModel>[].obs;

  // helper (no intl needed)
  String formatReportDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final mon = months[dt.month - 1];
    final year = dt.year;

    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$day $mon $year, $hour:$minute $ampm';
  }

  Future<void> submitAdminReport(String reason) async {
    final r = reason.trim();
    if (r.isEmpty) {
      Get.snackbar('Required', 'Please write your reason.');
      return;
    }

    final target = selectedBrandSubmission;
    final submissionId = target?.serverId?.trim();
    if (submissionId == null || submissionId.isEmpty) {
      Get.snackbar('Missing data', 'Submission id not found.');
      return;
    }

    final reportResult = await ApiErrorHandler.call(
      () => _campaignService.reportClientSubmission(
        submissionId: submissionId,
        report: r,
      ),
    );
    if (!reportResult.isSuccess) return;

    submittedReports.insert(
      0,
      AdminReportModel(reason: r, createdAt: DateTime.now()),
    );

    hasReportedToAdmin.value = true;
    // cooldown (you can change duration)
    reportAgainAt.value = DateTime.now().add(const Duration(days: 1));
  }

  String trOr(String key, String fallback) {
    final value = key.tr;
    return value == key ? fallback : value;
  }

  Milestone get currentMilestone => milestoneRx.value ?? milestone;

  void _setMilestone(Milestone value) {
    milestone = value;
    milestoneRx.value = value;
  }

  void _markNeedsParentRefresh() {
    _needsParentRefresh = true;
  }

  void closePage() {
    Get.back(result: {'refresh': _needsParentRefresh, 'milestone': milestone});
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

    if (_accountTypeService.isInfluencer) {
      _loadInfluencerMilestoneDetails();
    }
  }

  Future<void> _loadBrandMilestoneDetails({required bool isPaidAd}) async {
    isBrandSubmissionsLoading.value = true;
    brandSubmissions.clear();
    selectedBrandSubmissionIndex.value = null;
    final milestoneId = milestone.id?.trim();
    try {
      if (milestoneId == null || milestoneId.isEmpty) {
        brandSubmissions.clear();
        selectedBrandSubmissionIndex.value = null;
        return;
      }

      final milestoneDetails = await _fetchMilestoneDetails(milestoneId);
      if (milestoneDetails != null) {
        _setMilestone(
          milestone.copyWith(
            id: milestoneDetails['id']?.toString() ?? milestone.id,
            title:
                milestoneDetails['contentTitle']?.toString() ?? milestone.title,
            platform:
                milestoneDetails['platform']?.toString() ?? milestone.platform,
            deliverable:
                milestoneDetails['contentQuantity']?.toString() ??
                milestone.deliverable,
            dayIndex:
                _intFrom(milestoneDetails['deliveryDays']) ??
                milestone.dayIndex,
            amountLabel: _amountLabelFrom(milestoneDetails['amount']),
            targets: PromotionTarget(
              reach: _intFrom(milestoneDetails['expectedReach']),
              views: _intFrom(milestoneDetails['expectedViews']),
              likes: _intFrom(milestoneDetails['expectedLikes']),
              comments: _intFrom(milestoneDetails['expectedComments']),
            ),
            status: _parseMilestoneStatus(
              milestoneDetails['status']?.toString(),
            ),
          ),
        );
        milestoneStatus.value = _localStatusFromMilestone(milestone.status);
      }

      final submissionIds = await _fetchSubmissionIdsForMilestone(
        campaignId: job.id?.trim(),
        milestoneId: milestoneId,
        fallback: milestoneDetails,
      );

      if (submissionIds.isEmpty) {
        brandSubmissions.clear();
        selectedBrandSubmissionIndex.value = null;
        return;
      }

      final List<BrandSubmissionUiModel> next = [];
      int idx = 1;
      for (final id in submissionIds) {
        await _probeCampaignSubmissionDetails(id);
        final details = await _fetchClientSubmissionDetails(id);
        if (details == null) continue;

        next.add(
          _mapBrandSubmission(
            index: idx,
            submissionId: id,
            json: details,
            expanded: isPaidAd ? idx == 1 : true,
          ),
        );
        idx++;
      }

      if (next.isEmpty) {
        brandSubmissions.clear();
        selectedBrandSubmissionIndex.value = null;
      } else {
        brandSubmissions.assignAll(next);
        selectedBrandSubmissionIndex.value = next.first.index;
      }
    } finally {
      isBrandSubmissionsLoading.value = false;
    }
  }

  Future<void> _probeCampaignSubmissionDetails(String submissionId) async {
    if (_didProbeCampaignSubmissionDetails) return;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchCampaignSubmissionDetails(
        submissionId: submissionId,
      ),
      showError: false,
    );

    if (result.isSuccess) {
      debugPrint(
        '[API Probe] GET /campaign/submission/$submissionId => ${result.data}',
      );
      Get.snackbar('Submission details', 'Response captured in debug logs.');
      _didProbeCampaignSubmissionDetails = true;
      return;
    }

    Get.snackbar(
      'Submission details',
      result.error ?? 'Failed to capture response.',
    );
  }

  Future<Map<String, dynamic>?> _fetchMilestoneDetails(
    String milestoneId,
  ) async {
    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get('/campaign/milestone/$milestoneId');
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return null;
    final data = result.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    if (raw['id'] != null) return raw;
    if (raw['milestone'] is Map<String, dynamic>) {
      return raw['milestone'] as Map<String, dynamic>;
    }

    return null;
  }

  Future<List<String>> _fetchSubmissionIdsForMilestone({
    required String? campaignId,
    required String milestoneId,
    Map<String, dynamic>? fallback,
  }) async {
    final ids = <String>[];

    if (fallback != null && fallback['submissions'] is List) {
      for (final s in (fallback['submissions'] as List)) {
        if (s is Map && (s['id']?.toString() ?? '').trim().isNotEmpty) {
          ids.add(s['id'].toString());
        }
      }
    }

    if (ids.isNotEmpty || campaignId == null || campaignId.isEmpty) {
      return ids;
    }

    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get('/campaign/milestones/$campaignId');
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return ids;
    final data = result.data as Map<String, dynamic>;
    final list = data['data'] as List? ?? const [];

    for (final m in list) {
      if (m is! Map) continue;
      if ((m['id']?.toString() ?? '') != milestoneId) continue;
      final subs = m['submissions'] as List? ?? const [];
      for (final s in subs) {
        if (s is Map && (s['id']?.toString() ?? '').trim().isNotEmpty) {
          ids.add(s['id'].toString());
        }
      }
      break;
    }

    if (ids.isNotEmpty) return ids;

    final fallbackIds = await _fetchClientSubmissionIdsByMilestone(
      milestoneId: milestoneId,
    );
    ids.addAll(fallbackIds);

    return ids;
  }

  Future<List<String>> _fetchClientSubmissionIdsByMilestone({
    required String milestoneId,
  }) async {
    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get('/campaign/client/submissions');
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return const [];
    final data = result.data as Map<String, dynamic>;
    final list = data['data'] as List? ?? const [];

    final ids = <String>[];
    for (final item in list) {
      if (item is! Map) continue;
      final id = item['id']?.toString() ?? '';
      if (id.trim().isEmpty) continue;

      // Try direct milestoneId if present
      final mid = item['milestoneId']?.toString() ?? '';
      if (mid == milestoneId) {
        ids.add(id);
        continue;
      }

      // Fallback by title match (if milestoneId missing in list response)
      final title = item['milestoneTitle']?.toString().trim() ?? '';
      if (title.isNotEmpty && title == milestone.title) {
        ids.add(id);
      }
    }

    return ids;
  }

  Future<Map<String, dynamic>?> _fetchClientSubmissionDetails(
    String submissionId,
  ) async {
    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get(
        '/campaign/client/submissions/$submissionId',
      );
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return null;
    final data = result.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    return raw is Map<String, dynamic> ? raw : null;
  }

  BrandSubmissionUiModel _mapBrandSubmission({
    required int index,
    required String submissionId,
    required Map<String, dynamic> json,
    required bool expanded,
  }) {
    final description = _stringOrDash(json['description']);

    final liveLinks = json['liveLinks'] as List? ?? const [];
    final platformLink = liveLinks.isNotEmpty
        ? _stringOrDash(liveLinks.first)
        : _stringOrDash(json['platformLink']);

    final platformRaw = milestone.platform ?? json['platform'];
    final platformTitleKey = _titleCase(_stringOrDash(platformRaw));

    final metrics = <BrandSubmissionMetric>[];
    final targets = milestone.targets ?? const PromotionTarget();

    void addMetric({
      required String labelKey,
      required int achieved,
      required int expected,
    }) {
      if (expected <= 0) return;
      final progress = expected == 0 ? 0 : achieved / expected;
      final pct = (progress * 100).clamp(0, 999).toStringAsFixed(0);
      metrics.add(
        BrandSubmissionMetric(
          labelKey: labelKey,
          leftValue: _compactNumber(achieved),
          rightValue: _compactNumber(expected),
          progress: progress.clamp(0.0, 1.0).toDouble(),
          targetKey: 'Target $pct%',
        ),
      );
    }

    addMetric(
      labelKey: 'brand_metric_reach',
      achieved: _intFrom(json['achievedReach']) ?? 0,
      expected: targets.reach ?? 0,
    );
    addMetric(
      labelKey: 'brand_metric_views',
      achieved: _intFrom(json['achievedViews']) ?? 0,
      expected: targets.views ?? 0,
    );
    addMetric(
      labelKey: 'brand_metric_likes',
      achieved: _intFrom(json['achievedLikes']) ?? 0,
      expected: targets.likes ?? 0,
    );
    addMetric(
      labelKey: 'brand_metric_comments',
      achieved: _intFrom(json['achievedComments']) ?? 0,
      expected: targets.comments ?? 0,
    );

    double avgPercent = 0;
    if (metrics.isNotEmpty) {
      final sum = metrics.fold<double>(0, (s, m) => s + m.progress);
      avgPercent = (sum / metrics.length) * 100;
    }

    return BrandSubmissionUiModel(
      index: index,
      serverId: submissionId,
      requestedAmount: _intFrom(json['amount']) ?? 0,
      description: description,
      platformTitleKey: platformTitleKey,
      platformLink: platformLink,
      avgPercent: avgPercent,
      metrics: metrics,
      initialStatus: _mapBrandSubmissionStatus(json['status']?.toString()),
      expanded: expanded,
    );
  }

  BrandSubmissionStatus _mapBrandSubmissionStatus(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v.contains('declined') || v.contains('rejected')) {
      return BrandSubmissionStatus.declined;
    }
    if (v.contains('approved') || v.contains('completed')) {
      return BrandSubmissionStatus.completed;
    }
    return BrandSubmissionStatus.inReview;
  }

  String _stringOrDash(dynamic value) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? '—' : s;
  }

  String _titleCase(String input) {
    final t = input.trim();
    if (t.isEmpty || t == '—') return t;
    return t
        .split(RegExp(r'\s+'))
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
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
      case MilestoneLocalStatus.completed:
        return 'Completed';
      default:
        return 'To Do';
    }
  }

  Color get statusChipColor {
    switch (milestoneStatus.value) {
      case MilestoneLocalStatus.completed:
        return AppPalette.secondary;
      case MilestoneLocalStatus.paid:
      case MilestoneLocalStatus.approved:
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
      case MilestoneLocalStatus.completed:
        return AppPalette.secondary;
      case MilestoneLocalStatus.paid:
      case MilestoneLocalStatus.approved:
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
      case MilestoneLocalStatus.completed:
        return AppPalette.thirdColor;
      case MilestoneLocalStatus.paid:
      case MilestoneLocalStatus.approved:
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

    final isInfluencer = _accountTypeService.isInfluencer;
    final isAdAgency = _accountTypeService.isAdAgency;

    if ((isInfluencer || isAdAgency) &&
        milestone.id != null &&
        milestone.id!.isNotEmpty) {
      _submitInfluencerMilestone(milestone.id!);
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

  Future<void> _loadInfluencerMilestoneDetails() async {
    final milestoneId = milestone.id;
    if (milestoneId == null || milestoneId.isEmpty) return;

    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get(
        '/campaign/influencer/milestone/$milestoneId',
      );
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return;

    final data = result.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    final milestoneJson = raw['milestone'] is Map<String, dynamic>
        ? raw['milestone'] as Map<String, dynamic>
        : raw;

    final statusRaw =
        raw['status']?.toString() ?? milestoneJson['status']?.toString();

    _setMilestone(
      milestone.copyWith(
        id: milestoneJson['id']?.toString() ?? milestone.id,
        title:
            milestoneJson['contentTitle']?.toString().trim() ?? milestone.title,
        platform: milestoneJson['platform']?.toString() ?? milestone.platform,
        deliverable:
            milestoneJson['contentQuantity']?.toString() ??
            milestone.deliverable,
        dayIndex: _intFrom(milestoneJson['deliveryDays']) ?? milestone.dayIndex,
        amountLabel: _amountLabelFrom(
          milestoneJson['amount'] ?? milestoneJson['paidAmount'],
        ),
        targets: PromotionTarget(
          reach: _intFrom(milestoneJson['expectedReach']),
          views: _intFrom(milestoneJson['expectedViews']),
          likes: _intFrom(milestoneJson['expectedLikes']),
          comments: _intFrom(milestoneJson['expectedComments']),
        ),
        status: _parseMilestoneStatus(statusRaw),
      ),
    );

    milestoneStatus.value = _localStatusFromMilestone(milestone.status);

    final submissionsRaw = (raw['submissions'] as List?) ?? const [];
    final mapped = submissionsRaw
        .whereType<Map>()
        .map((e) => _mapInfluencerSubmission(e.cast<String, dynamic>()))
        .toList();

    submissions.clear();
    if (mapped.isNotEmpty) {
      for (final s in mapped) {
        final ui = SubmissionUiModel(index: s.index);
        ui.serverId = s.id;
        ui.descriptionController.text = s.description;
        ui.amountController.text = s.amount.toString();
        ui.linkController.text = s.liveLink;
        ui.metricLabelController.text = s.metricLabel;
        ui.metricValueController.text = s.metricValue;
        ui.status.value = s.status;
        ui.isSubmitted.value = true;
        ui.isExpanded.value = false;
        submissions.add(ui);
      }
    } else {
      submissions.add(SubmissionUiModel(index: 1));
    }
  }

  Submission _mapInfluencerSubmission(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>?;
    final reach = _intFrom(metrics?['reach']);
    final views = _intFrom(metrics?['views']);
    final likes = _intFrom(metrics?['likes']);
    final comments = _intFrom(metrics?['comments']);

    final metric = _preferredMetricValue(
      reach: reach,
      views: views,
      likes: likes,
      comments: comments,
    );

    return Submission(
      id: json['id']?.toString(),
      index: (json['index'] as num?)?.toInt() ?? 1,
      description: json['description']?.toString() ?? '',
      amount: _intFrom(json['amount']) ?? 0,
      liveLink: _firstString(json['liveLinks']) ?? '',
      metricLabel: metric.label,
      metricValue: metric.value.toString(),
      proofPaths: _stringList(json['attachments']),
      status: _parseSubmissionStatus(json['status']?.toString()),
      achieved: PromotionTarget(
        reach: reach,
        views: views,
        likes: likes,
        comments: comments,
      ),
    );
  }

  Future<void> _submitInfluencerMilestone(String milestoneId) async {
    if (submissions.isEmpty) return;

    final ui = submissions.first;
    final link = ui.linkController.text.trim();
    final label = ui.metricLabelController.text.trim().toLowerCase();
    final value = _intFrom(ui.metricValueController.text) ?? 0;

    int views = 0;
    int reach = 0;
    int likes = 0;
    int comments = 0;

    if (label.contains('view')) {
      views = value;
    } else if (label.contains('like')) {
      likes = value;
    } else if (label.contains('comment')) {
      comments = value;
    } else {
      reach = value;
    }

    List<String> proofAttachmentUrls;
    try {
      proofAttachmentUrls = await _uploadProofAttachments(ui.proofs);
    } catch (e) {
      Get.snackbar('Upload failed', e.toString());
      return;
    }

    final payload = {
      'description': ui.descriptionController.text.trim(),
      'liveLinks': link.isEmpty ? [] : [link],
      'proofAttachments': proofAttachmentUrls,
      'achievedViews': views,
      'achievedReach': reach,
      'achievedLikes': likes,
      'achievedComments': comments,
    };

    final isAdAgency = _accountTypeService.isAdAgency;
    final requestedAmount = _intFrom(ui.amountController.text) ?? 0;

    final agencyPayload = {
      'description': ui.descriptionController.text.trim(),
      'liveLinks': link.isEmpty ? [] : [link],
      'proofAttachments': proofAttachmentUrls,
      if (requestedAmount > 0) 'requestPaymentAmount': requestedAmount,
    };

    final achievedMetrics = {
      if (views > 0) 'achievedViews': views,
      if (reach > 0) 'achievedReach': reach,
      if (likes > 0) 'achievedLikes': likes,
      if (comments > 0) 'achievedComments': comments,
    };

    final Future<dynamic> Function() apiCall;
    if (isAdAgency) {
      if (ui.serverId != null && ui.status.value == SubmissionStatus.declined) {
        apiCall = () => _campaignService.resubmitAgencyMilestoneWork(
          submissionId: ui.serverId!,
          payload: agencyPayload,
        );
      } else {
        apiCall = () => _campaignService.submitAgencyMilestoneWork(
          milestoneId: milestoneId,
          payload: agencyPayload,
        );
      }

      final result = await ApiErrorHandler.call(apiCall);
      if (!result.isSuccess) return;

      if (ui.serverId != null && achievedMetrics.isNotEmpty) {
        await ApiErrorHandler.call(
          () => _campaignService.updateAgencySubmissionResults(
            submissionId: ui.serverId!,
            payload: achievedMetrics,
          ),
          showError: false,
        );
      }
    } else {
      if (ui.serverId != null && ui.status.value == SubmissionStatus.declined) {
        apiCall = () => _apiClient.dio.patch(
          '/campaign/influencer/submission/${ui.serverId}/resubmit',
          data: payload,
        );
      } else {
        apiCall = () => _apiClient.dio.post(
          '/campaign/influencer/milestone/$milestoneId/submit',
          data: payload,
        );
      }

      final result = await ApiErrorHandler.call(apiCall);
      if (!result.isSuccess) return;
    }

    ui.status.value = SubmissionStatus.inReview;
    ui.isSubmitted.value = true;
    ui.isExpanded.value = false;
    _setMilestone(milestone.copyWith(status: MilestoneStatus.inReview));
    milestoneStatus.value = MilestoneLocalStatus.inReview;

    _markNeedsParentRefresh();
    if (_accountTypeService.isInfluencer) {
      await _loadInfluencerMilestoneDetails();
    }

    Get.snackbar('Submitted', 'Milestone sent for admin review');
  }

  Future<List<String>> _uploadProofAttachments(
    List<PlatformFile> proofs,
  ) async {
    final uploadedUrls = <String>[];

    for (final proof in proofs) {
      final filePath = proof.path?.trim() ?? '';
      if (filePath.isEmpty) {
        throw Exception('Could not access ${proof.name} for upload.');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: ${proof.name}');
      }

      final fileName = proof.name.trim().isNotEmpty
          ? proof.name.trim()
          : path.basename(filePath);
      final contentType = _proofContentType(fileName);

      final signedUrl = await _uploadService.createSignedUrl(
        fileName: fileName,
        fileType: contentType,
        module: 'milestone-proofs',
      );

      await _uploadService.uploadFileToSignedUrl(
        uploadUrl: signedUrl.uploadUrl,
        file: file,
        contentType: contentType,
      );

      uploadedUrls.add(signedUrl.fileUrl);
    }

    return uploadedUrls;
  }

  String _proofContentType(String fileName) {
    final extension = path
        .extension(fileName)
        .replaceFirst('.', '')
        .toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  MilestoneStatus _parseMilestoneStatus(String? raw) {
    final v = (raw ?? '').toLowerCase();
    switch (v) {
      case 'in_review':
      case 'inreview':
        return MilestoneStatus.inReview;
      case 'paid':
        return MilestoneStatus.paid;
      case 'approved':
        return MilestoneStatus.approved;
      case 'partial_paid':
      case 'partialpaid':
        return MilestoneStatus.partialPaid;
      case 'declined':
        return MilestoneStatus.declined;
      case 'completed':
        return MilestoneStatus.approved;
      case 'to_do':
      case 'todo':
      default:
        return MilestoneStatus.todo;
    }
  }

  SubmissionStatus _parseSubmissionStatus(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v.contains('declined')) return SubmissionStatus.declined;
    if (v.contains('approved')) return SubmissionStatus.approved;
    return SubmissionStatus.inReview;
  }

  MilestoneLocalStatus _localStatusFromMilestone(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.inReview:
        return MilestoneLocalStatus.inReview;
      case MilestoneStatus.paid:
        return MilestoneLocalStatus.paid;
      case MilestoneStatus.approved:
        return MilestoneLocalStatus.approved;
      case MilestoneStatus.partialPaid:
        return MilestoneLocalStatus.partialPaid;
      case MilestoneStatus.declined:
        return MilestoneLocalStatus.declined;
      case MilestoneStatus.todo:
      default:
        return MilestoneLocalStatus.toDo;
    }
  }

  String _amountLabelFrom(dynamic value) {
    final v = _intFrom(value);
    if (v != null) return '৳$v';
    if (value is String && value.trim().isNotEmpty) return value;
    return '—';
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  String? _firstString(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first?.toString();
    }
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  _MetricValue _preferredMetricValue({
    int? reach,
    int? views,
    int? likes,
    int? comments,
  }) {
    if (reach != null && reach > 0) return _MetricValue('Reach', reach);
    if (views != null && views > 0) return _MetricValue('Views', views);
    if (likes != null && likes > 0) return _MetricValue('Likes', likes);
    if (comments != null && comments > 0) {
      return _MetricValue('Comments', comments);
    }
    return const _MetricValue('Reach', 0);
  }

  BrandSubmissionUiModel? get selectedBrandSubmission {
    final selIndex = selectedBrandSubmissionIndex.value;
    if (selIndex != null) {
      for (final s in brandSubmissions) {
        if (s.index == selIndex) return s;
      }
    }
    for (final s in brandSubmissions) {
      if (s.isExpanded.value) return s;
    }
    return brandSubmissions.isNotEmpty ? brandSubmissions.first : null;
  }

  bool isBrandSubmissionSelected(int index) {
    return selectedBrandSubmissionIndex.value == index;
  }

  void selectBrandSubmission(int index) {
    selectedBrandSubmissionIndex.value = index;
    if (job.campaignType == CampaignType.paidAd) {
      for (final s in brandSubmissions) {
        s.isExpanded.value = s.index == index;
      }
    }
  }

  void toggleBrandSubmissionExpanded(int index) {
    if (job.campaignType != CampaignType.paidAd) return;

    for (final s in brandSubmissions) {
      if (s.index == index) {
        // toggle selected; but collapse others always
        final next = !s.isExpanded.value;
        s.isExpanded.value = next;
        if (next) selectedBrandSubmissionIndex.value = index;
      } else {
        s.isExpanded.value = false;
      }
    }
  }

  Future<void> approveSelectedBrandSubmission() async {
    final isPaidAd = job.campaignType == CampaignType.paidAd;
    final target = selectedBrandSubmission;

    if (target == null) {
      Get.snackbar('No submission', 'Please expand a submission first.');
      return;
    }

    await _approveBrandSubmission(target, isPaidAd);

    // status updates happen after API success
  }

  Future<void> declineSelectedBrandSubmission(String reason) async {
    final target = selectedBrandSubmission;

    if (target == null) {
      Get.snackbar('No submission', 'Please expand a submission first.');
      return;
    }

    final r = reason.trim();
    if (r.isEmpty) {
      Get.snackbar('Required', 'Please write a reason.');
      return;
    }

    await _declineBrandSubmission(target, r);
  }

  String? _submissionIdForIndex(int index) {
    for (final s in milestone.submissions) {
      if (s.index == index && (s.id ?? '').trim().isNotEmpty) {
        return s.id;
      }
    }
    return null;
  }

  Future<bool> _reviewClientSubmission({
    required String submissionId,
    required bool approve,
    String? reason,
  }) async {
    final result = await ApiErrorHandler.call(
      () => _campaignService.reviewClientSubmission(
        submissionId: submissionId,
        action: approve ? 'approve' : 'decline',
        report: approve ? 'Approved' : null,
        reason: approve ? null : (reason ?? 'Declined by client.'),
      ),
    );

    return result.isSuccess;
  }

  Future<void> _approveBrandSubmission(
    BrandSubmissionUiModel target,
    bool isPaidAd,
  ) async {
    final submissionId = (target.serverId ?? '').trim().isNotEmpty
        ? target.serverId!
        : null;

    if (submissionId == null) {
      debugPrint('Approve skipped: submissionId is null/empty.');
      Get.snackbar('Missing data', 'Submission id not found.');
      return;
    }

    final ok = await _reviewClientSubmission(
      submissionId: submissionId,
      approve: true,
    );

    if (!ok) return;

    final bonusDelta = target.requestedAmount - milestoneAmountTotal;
    final milestoneId = milestone.id?.trim() ?? '';
    if (job.campaignType == CampaignType.paidAd &&
        bonusDelta > 0 &&
        milestoneId.isNotEmpty) {
      await ApiErrorHandler.call(
        () => _campaignService.payClientMilestoneBonus(
          milestoneId: milestoneId,
          amount: bonusDelta,
        ),
        showError: false,
      );
    }

    _markNeedsParentRefresh();
    await _loadBrandMilestoneDetails(isPaidAd: isPaidAd);

    target.status.value = BrandSubmissionStatus.completed;
    target.declinedReason.value = null;

    if (isPaidAd) {
      final allDone = brandSubmissions.every(
        (s) => s.status.value == BrandSubmissionStatus.completed,
      );
      if (allDone) {
        _setMilestone(milestone.copyWith(status: MilestoneStatus.approved));
        milestoneStatus.value = MilestoneLocalStatus.completed;
      }
      return;
    }

    _setMilestone(milestone.copyWith(status: MilestoneStatus.approved));
    milestoneStatus.value = MilestoneLocalStatus.completed;
  }

  Future<void> _declineBrandSubmission(
    BrandSubmissionUiModel target,
    String reason,
  ) async {
    final submissionId = (target.serverId ?? '').trim().isNotEmpty
        ? target.serverId!
        : null;

    if (submissionId == null) {
      debugPrint('Decline skipped: submissionId is null/empty.');
      Get.snackbar('Missing data', 'Submission id not found.');
      return;
    }

    final ok = await _reviewClientSubmission(
      submissionId: submissionId,
      approve: false,
      reason: reason,
    );

    if (!ok) return;

    _markNeedsParentRefresh();
    await _loadBrandMilestoneDetails(
      isPaidAd: job.campaignType == CampaignType.paidAd,
    );

    target.status.value = BrandSubmissionStatus.declined;
    target.declinedReason.value = reason;
    _setMilestone(milestone.copyWith(status: MilestoneStatus.declined));
    milestoneStatus.value = MilestoneLocalStatus.declined;
  }
}

class _MetricValue {
  final String label;
  final int value;

  const _MetricValue(this.label, this.value);

  _MetricValue copyWith({String? label, int? value}) {
    return _MetricValue(label ?? this.label, value ?? this.value);
  }
}
