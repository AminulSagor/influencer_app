// lib/modules/ad_agency/milestone_details/milestone_details_controller.dart
import 'dart:developer' as dev;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:path/path.dart' as path;

import '../../ad_agency/services/upload_service.dart';
import '../../../core/models/job_item.dart';
import '../../../core/services/account_type_service.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/campaign_service.dart';
import '../../../core/theme/app_palette.dart';
import 'widgets/bonus_payment_dialog.dart';
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

class SubmissionReportHistoryItem {
  final String id;
  final String content;
  final String authorRole;
  final String actionTaken;
  final DateTime createdAt;

  SubmissionReportHistoryItem({
    required this.id,
    required this.content,
    required this.authorRole,
    required this.actionTaken,
    required this.createdAt,
  });
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
  final TextEditingController reachController = TextEditingController();
  final TextEditingController viewsController = TextEditingController();
  final TextEditingController likesController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  // NEW: server decline reason
  final RxnString rejectionReason = RxnString();

  // NEW: achieved metrics from API (optional)
  final RxnInt achievedReach = RxnInt();
  final RxnInt achievedViews = RxnInt();
  final RxnInt achievedLikes = RxnInt();
  final RxnInt achievedComments = RxnInt();

  // files + state
  final RxList<PlatformFile> proofs = <PlatformFile>[].obs;
  final RxList<String> serverProofUrls = <String>[].obs;
  final RxBool isExpanded = true.obs;

  final Rx<SubmissionStatus> status = SubmissionStatus.inReview.obs;

  // "Submitted" means it exists on server (or locked)
  final RxBool isSubmitted = false.obs;

  // NEW: only used for declined -> unlock after edit icon pressed
  final RxBool declinedEditEnabled = false.obs;

  SubmissionUiModel({required this.index});

  bool get isEditable {
    if (!isSubmitted.value) return true; // Draft
    if (status.value == SubmissionStatus.approved) return false;
    if (status.value == SubmissionStatus.declined) {
      return declinedEditEnabled.value;
    }

    // ✅ Requirement: influencer + agency can edit while in_review
    return true;
  }

  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    linkController.dispose();

    metricLabelController.dispose();
    metricValueController.dispose();

    // NEW
    reachController.dispose();
    viewsController.dispose();
    likesController.dispose();
    commentsController.dispose();
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

  // Reports
  final RxList<SubmissionReportHistoryItem> selectedSubmissionReports =
      <SubmissionReportHistoryItem>[].obs;
  final RxBool isSelectedSubmissionReportsLoading = false.obs;
  final RxnString selectedSubmissionReportSubmissionId = RxnString();

  // bottom checkboxes
  final RxBool confirmOwnership = false.obs;
  final RxBool acceptLicense = false.obs;
  final ApiClient _apiClient = Get.find<ApiClient>();
  final CampaignService _campaignService = Get.find<CampaignService>();
  final UploadService _uploadService = Get.find<UploadService>();
  bool _needsParentRefresh = false;

  final AccountTypeService _accountTypeService = Get.find<AccountTypeService>();

  bool get hasDeclinedEditMode => submissions.any(
    (s) =>
        s.status.value == SubmissionStatus.declined &&
        s.declinedEditEnabled.value == true,
  );

  String get submitButtonText =>
      hasDeclinedEditMode ? 'Resubmit' : 'Submit For Admin Review';

  final RxBool isBonusPaymentLoading = false.obs;
  final TextEditingController bonusAmountController = TextEditingController();
  final RxString selectedBonusPaymentMethod = 'Credit / Debit Card'.obs;

  bool get canShowBonusSection {
    if (!_accountTypeService.isBrand) return false;
    if (currentMilestone.status != MilestoneStatus.approved) return false;

    return brandSubmissions.any(
      (s) =>
          s.status.value == BrandSubmissionStatus.completed &&
          s.hasBonusEligibleMetric,
    );
  }

  BrandSubmissionUiModel? get bonusTargetSubmission {
    for (final s in brandSubmissions) {
      if (s.status.value == BrandSubmissionStatus.completed &&
          s.hasBonusEligibleMetric) {
        return s;
      }
    }
    return null;
  }

  String get bonusReceiverName {
    if (job.campaignType == CampaignType.paidAd) {
      return job.clientName.trim().isNotEmpty == true
          ? job.clientName.trim()
          : 'Agency';
    }

    return job.clientName.trim().isNotEmpty == true
        ? job.clientName.trim()
        : 'Influencer';
  }

  @override
  void onInit() {
    super.onInit();

    if (arguments is Map) {
      final map = arguments as Map;
      milestone = map['milestone'] as Milestone;
      milestoneRx.value = milestone;
      job = map['job'] as JobItem;
    } else {
      Get.snackbar('ERROR', 'Fail to get milestone details');
    }

    _syncLocalStatusFromModel();

    // ✅ ALWAYS FETCH FROM SERVER FOR ALL USERS
    _loadMilestoneDetailsByRole();
  }

  void toggleHeader() => headerExpanded.toggle();

  @override
  void onClose() {
    bonusAmountController.dispose();
    for (final s in submissions) {
      s.dispose();
    }
    super.onClose();
  }

  Future<void> _loadMilestoneDetailsByRole() async {
    final milestoneId = milestone.id?.trim();
    if (milestoneId == null || milestoneId.isEmpty) return;

    if (_accountTypeService.isInfluencer) {
      await _loadInfluencerMilestoneDetails();
    } else {
      // Brand + AdAgency both use same endpoint
      await _loadBrandMilestoneDetails(
        isPaidAd: job.campaignType == CampaignType.paidAd,
      );
    }
  }

  // --- Report Admin state ---
  final RxBool hasReportedToAdmin = false.obs;
  final Rxn<DateTime> reportAgainAt = Rxn<DateTime>();

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

  DateTime _safeParseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return DateTime.now();
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  List<SubmissionReportHistoryItem> _mapSubmissionReportResponse(dynamic raw) {
    if (raw is! Map) return const [];

    final data = raw['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (e) => SubmissionReportHistoryItem(
            id: e['id']?.toString() ?? '',
            content: e['content']?.toString().trim() ?? '',
            authorRole: e['authorRole']?.toString() ?? '',
            actionTaken: e['actionTaken']?.toString() ?? '',
            createdAt: _safeParseDateTime(e['createdAt']?.toString()),
          ),
        )
        .where((e) => e.content.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _loadSelectedSubmissionReportsForBrand() async {
    if (!_accountTypeService.isBrand) return;

    final target = selectedBrandSubmission;
    final submissionId = (target?.serverId ?? '').trim();

    // no submission selected / no server id
    if (submissionId.isEmpty) {
      selectedSubmissionReportSubmissionId.value = null;
      selectedSubmissionReports.clear();
      return;
    }

    // prevent duplicate reload if already loaded for same selection (optional)
    // if (selectedSubmissionReportSubmissionId.value == submissionId &&
    //     selectedSubmissionReports.isNotEmpty) return;

    isSelectedSubmissionReportsLoading.value = true;
    selectedSubmissionReportSubmissionId.value = submissionId;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchSubmissionReport(submissionId: submissionId),
      showError: false,
    );

    if (!result.isSuccess || result.data == null) {
      selectedSubmissionReports.clear();
      isSelectedSubmissionReportsLoading.value = false;
      return;
    }

    selectedSubmissionReports.assignAll(
      _mapSubmissionReportResponse(result.data),
    );

    isSelectedSubmissionReportsLoading.value = false;
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

    hasReportedToAdmin.value = true;
    reportAgainAt.value = DateTime.now().add(const Duration(days: 1));

    await _loadSelectedSubmissionReportsForBrand();
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
    Get.back(
      result: {'refresh': _needsParentRefresh, 'milestone': milestone},
      id: 1,
    );
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
    submissions.clear();

    final milestoneId = milestone.id?.trim();
    if (milestoneId == null || milestoneId.isEmpty) {
      isBrandSubmissionsLoading.value = false;
      return;
    }

    final raw = await _fetchMilestoneDetails(milestoneId);
    if (raw == null) {
      isBrandSubmissionsLoading.value = false;
      return;
    }

    // ✅ UPDATE MILESTONE
    _setMilestone(
      milestone.copyWith(
        id: raw['id']?.toString() ?? milestone.id,
        title: raw['contentTitle']?.toString() ?? milestone.title,
        platform: raw['platform']?.toString(),
        deliverable:
            '${raw['platform']?.toString()} - ${raw['contentQuantity']?.toString()}',
        dayIndex: _intFrom(raw['deliveryDays']),
        amountLabel: _amountLabelFrom(raw['amount']),
        promotionGoal: raw['promotionGoal']?.toString(),
        targets: PromotionTarget(
          reach: _intFrom(raw['expectedReach']),
          views: _intFrom(raw['expectedViews']),
          likes: _intFrom(raw['expectedLikes']),
          comments: _intFrom(raw['expectedComments']),
        ),
        status: _parseMilestoneStatus(raw['status']?.toString()),
      ),
    );

    milestoneStatus.value = _localStatusFromMilestone(currentMilestone.status);

    final submissionsRaw = (raw['submissions'] as List?) ?? const [];

    if (_accountTypeService.isBrand) {
      // ✅ Brand uses BrandSubmissionUiModel
      final mapped = submissionsRaw
          .whereType<Map>()
          .map(
            (e) => _mapBrandSubmission(
              index: submissionsRaw.indexOf(e) + 1,
              submissionId: e['id']?.toString() ?? '',
              json: e.cast<String, dynamic>(),
              expanded: isPaidAd,
            ),
          )
          .toList();

      brandSubmissions.assignAll(mapped);
      if (mapped.isNotEmpty) {
        selectedBrandSubmissionIndex.value = mapped.first.index;
      } else {
        selectedBrandSubmissionIndex.value = null;
        selectedSubmissionReports.clear();
        selectedSubmissionReportSubmissionId.value = null;
      }
      await _loadSelectedSubmissionReportsForBrand();
    } else {
      // ✅ Agency loads into SubmissionUiModel (multiple allowed)
      int idx = 1;
      for (final s in submissionsRaw.whereType<Map>()) {
        final ui = SubmissionUiModel(index: idx);
        ui.serverId = s['id']?.toString();
        ui.descriptionController.text =
            s['submissionDescription']?.toString() ?? '';
        ui.amountController.text = s['requestedAmount']?.toString() ?? '';
        ui.linkController.text = _firstString(s['submissionLiveLinks']) ?? '';
        ui.status.value = _parseSubmissionStatus(s['status']?.toString());
        ui.rejectionReason.value = s['rejectionReason']?.toString();

        ui.achievedReach.value = _intFrom(s['achievedReach']);
        ui.achievedViews.value = _intFrom(s['achievedViews']);
        ui.achievedLikes.value = _intFrom(s['achievedLikes']);
        ui.achievedComments.value = _intFrom(s['achievedComments']);

        // declined is locked until edit pressed
        ui.declinedEditEnabled.value = false;

        // submitted = true because it came from server
        ui.isSubmitted.value = true;
        ui.serverProofUrls.assignAll(
          _stringList(
            s['proofAttachments'] ??
                s['attachments'] ??
                s['submissionAttachments'],
          ),
        );
        ui.isSubmitted.value = true;
        ui.isExpanded.value = false;
        submissions.add(ui);
        idx++;
      }

      if (submissions.isEmpty) {
        submissions.add(SubmissionUiModel(index: 1));
      }
    }

    isBrandSubmissionsLoading.value = false;
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

  BrandSubmissionUiModel _mapBrandSubmission({
    required int index,
    required String submissionId,
    required Map<String, dynamic> json,
    required bool expanded,
  }) {
    final description = _stringOrDash(
      json['submissionDescription'] ?? json['description'],
    );

    final liveLinks =
        (json['submissionLiveLinks'] ?? json['liveLinks']) as List? ?? const [];

    final platformLink = liveLinks.isNotEmpty
        ? _stringOrDash(liveLinks.first)
        : _stringOrDash(json['platformLink']);
    final requested = _intFrom(json['requestedAmount'] ?? json['amount']) ?? 0;

    final platformRaw = milestone.platform ?? json['platform'];
    final platformTitleKey = _titleCase(_stringOrDash(platformRaw));

    final metrics = <BrandSubmissionMetric>[];
    final targets = milestone.targets ?? const PromotionTarget();

    bool hasBonusEligibleMetric = false;

    void addMetric({
      required String labelKey,
      required int achieved,
      required int expected,
    }) {
      if (expected <= 0) return;

      final rawProgress = achieved / expected;
      final pct = (rawProgress * 100).toStringAsFixed(0);

      if (rawProgress > 1.0) {
        hasBonusEligibleMetric = true;
      }

      metrics.add(
        BrandSubmissionMetric(
          labelKey: labelKey,
          leftValue: _compactNumber(achieved),
          rightValue: _compactNumber(expected),
          progress: rawProgress.clamp(0.0, 1.0).toDouble(),
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

    final proofUrls = _stringList(
      json['proofAttachments'] ??
          json['attachments'] ??
          json['submissionAttachments'],
    );

    return BrandSubmissionUiModel(
      index: index,
      serverId: submissionId,
      requestedAmount: requested,
      description: description,
      platformTitleKey: platformTitleKey,
      platformLink: platformLink,
      avgPercent: avgPercent,
      metrics: metrics,
      proofUrls: proofUrls,
      hasBonusEligibleMetric: hasBonusEligibleMetric,
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
      return '${(value / 1000000).toStringAsFixed(0)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
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
    final s = raw.trim();
    if (s.isEmpty) return 0;

    // keep digits, decimal point and minus (if ever needed)
    final normalized = s.replaceAll(RegExp(r'[^0-9.\-]'), '');

    if (normalized.isEmpty) return 0;

    final value = double.tryParse(normalized);
    if (value == null) return 0;

    return value.round(); // or .toInt() if you prefer floor
  }

  int get requestedAmount {
    int sum = 0;
    for (final s in submissions) {
      dev.log('The requested Amount: ${s.amountController.text}');
      final v = _parseAmount(s.amountController.text);
      sum += v;
      dev.log('The requested Amount sum: ${s.amountController.text}');
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
      requestedAmount > 0 ? formatCurrencyByLocale(requestedAmount) : '৳0';

  String get progressRightLabel =>
      formatCurrencyByLocale(_parseAmount(milestone.amountLabel));

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
    submission.declinedEditEnabled.value = true;
  }

  int? _metricInt(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  Map<String, dynamic> _buildSubmitPayload({
    required SubmissionUiModel ui,
    required List<String> proofUrls,
  }) {
    final link = ui.linkController.text.trim();
    final requestPaymentAmount =
        double.tryParse(ui.amountController.text.trim()) ?? 0.0;

    // default nulls
    int? achievedViews;
    int? achievedReach;
    int? achievedLikes;
    int? achievedComments;

    final isInfluencer = _accountTypeService.isInfluencer;

    if (isInfluencer) {
      // ✅ Influencer sends all 4 fields (null if empty)
      achievedReach = _metricInt(ui.reachController.text.trim());
      achievedViews = _metricInt(ui.viewsController.text.trim());
      achievedLikes = _metricInt(ui.likesController.text.trim());
      achievedComments = _metricInt(ui.commentsController.text.trim());
    } else {
      // ✅ Ad Agency uses (label + value) mapping
      final labelText = ui.metricLabelController.text.trim().toLowerCase();
      final metricValue = _metricInt(ui.metricValueController.text.trim());

      if (metricValue != null) {
        if (labelText.contains('view')) achievedViews = metricValue;
        if (labelText.contains('reach')) achievedReach = metricValue;
        if (labelText.contains('like')) achievedLikes = metricValue;
        if (labelText.contains('comment')) achievedComments = metricValue;
      }
    }

    return {
      'description': ui.descriptionController.text.trim(),
      'liveLinks': link.isEmpty ? [] : [link],
      'proofAttachments': proofUrls,

      // ✅ Always present
      'achievedViews': achievedViews,
      'achievedReach': achievedReach,
      'achievedLikes': achievedLikes,
      'achievedComments': achievedComments,

      // ✅ Always present
      'requestPaymentAmount': requestPaymentAmount,
    };
  }

  Map<String, dynamic> _buildAgencySubmitPayload({
    required SubmissionUiModel ui,
    required List<String> proofUrls,
  }) {
    final link = ui.linkController.text.trim();
    final requestedAmount =
        double.tryParse(ui.amountController.text.trim()) ?? 0.0;

    return {
      'description': ui.descriptionController.text.trim(),
      'liveLinks': link.isEmpty ? [] : [link],
      'proofAttachments': proofUrls,
      if (requestedAmount > 0) 'requestPaymentAmount': requestedAmount,
    };
  }

  /// Only ONE metric for agency results endpoint (based on label/value).
  Map<String, dynamic> _buildAgencyAchievedMetricsPayload(
    SubmissionUiModel ui,
  ) {
    final label = ui.metricLabelController.text.trim().toLowerCase();
    final value = _metricInt(ui.metricValueController.text.trim());

    if (value == null || value <= 0) return {};

    if (label.contains('view')) return {'achievedViews': value};
    if (label.contains('like')) return {'achievedLikes': value};
    if (label.contains('comment')) return {'achievedComments': value};

    // default -> reach
    return {'achievedReach': value};
  }

  Map<String, dynamic> _buildInfluencerSubmitPayload({
    required SubmissionUiModel ui,
    required List<String> proofUrls,
  }) {
    final link = ui.linkController.text.trim();

    return {
      'description': ui.descriptionController.text.trim(),
      'liveLinks': link.isEmpty ? [] : [link],
      'proofAttachments': proofUrls,

      // ✅ ALWAYS present for influencer (null allowed)
      'achievedReach': _metricInt(ui.reachController.text.trim()),
      'achievedViews': _metricInt(ui.viewsController.text.trim()),
      'achievedLikes': _metricInt(ui.likesController.text.trim()),
      'achievedComments': _metricInt(ui.commentsController.text.trim()),
    };
  }

  /// Extract submissionId from API response if possible (works with many shapes).
  String? _extractSubmissionId(dynamic res) {
    if (res == null) return null;

    // dio response.data
    if (res is Map) {
      // common: { data: { id: ... } }
      final data = res['data'];
      if (data is Map && (data['id']?.toString() ?? '').trim().isNotEmpty) {
        return data['id'].toString();
      }
      // sometimes: { id: ... }
      if ((res['id']?.toString() ?? '').trim().isNotEmpty) {
        return res['id'].toString();
      }
    }
    return null;
  }

  Future<void> _submitAgencyDraftSubmissions(String milestoneId) async {
    if (submissions.isEmpty) return;

    final drafts = submissions.where((u) {
      if (!u.isSubmitted.value) return true;

      if (u.status.value == SubmissionStatus.declined &&
          u.declinedEditEnabled.value) {
        return true;
      }

      // allow re-submit while in_review (you already marked editable)
      return (u.status.value == SubmissionStatus.inReview &&
          (u.serverId ?? '').trim().isNotEmpty);
    }).toList();

    if (drafts.isEmpty) {
      Get.snackbar('Nothing to submit', 'No new draft submissions found.');
      return;
    }

    for (final ui in drafts) {
      await _submitSingleSubmission(ui, milestoneId);
    }

    _markNeedsParentRefresh();
    await _loadBrandMilestoneDetails(
      isPaidAd: job.campaignType == CampaignType.paidAd,
    );

    Get.snackbar('Submitted', 'Draft submissions sent for admin review');
  }

  Future<void> _submitInfluencerOnly(String milestoneId) async {
    if (submissions.isEmpty) return;

    final ui = submissions.first;

    // Same gating you had (draft OR declined-edit). If you want also in_review edits,
    // remove this check.
    if (ui.isSubmitted.value && ui.status.value != SubmissionStatus.declined) {
      Get.snackbar('Nothing to submit', 'Already submitted.');
      return;
    }

    final proofUrls = await _uploadProofAttachments(ui.proofs);

    // ✅ Influencer payload: includes ALL metrics, excludes requestPaymentAmount
    final payload = _buildInfluencerSubmitPayload(ui: ui, proofUrls: proofUrls);

    final shouldResubmit = (ui.serverId ?? '').trim().isNotEmpty;

    final Future<dynamic> Function() apiCall = shouldResubmit
        ? () => _apiClient.dio.patch(
            '/campaign/influencer/submission/${ui.serverId!.trim()}/resubmit',
            data: payload,
          )
        : () => _apiClient.dio.post(
            '/campaign/influencer/milestone/$milestoneId/submit',
            data: payload,
          );

    final result = await ApiErrorHandler.call(apiCall);
    if (!result.isSuccess) return;

    ui.status.value = SubmissionStatus.inReview;
    ui.isSubmitted.value = true;
    ui.isExpanded.value = false;
    ui.declinedEditEnabled.value = false;
    ui.rejectionReason.value = null;

    _setMilestone(milestone.copyWith(status: MilestoneStatus.inReview));
    milestoneStatus.value = MilestoneLocalStatus.inReview;

    _markNeedsParentRefresh();
    await _loadInfluencerMilestoneDetails();

    Get.snackbar('Submitted', 'Milestone sent for admin review');
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

    final milestoneId = milestone.id?.trim() ?? '';
    if (milestoneId.isNotEmpty) {
      if (isAdAgency) {
        _submitAgencyDraftSubmissions(milestoneId);
        return;
      }
      if (isInfluencer) {
        _submitInfluencerOnly(milestoneId);
        return;
      }
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
    final milestoneId = milestone.id?.trim();
    if (milestoneId == null || milestoneId.isEmpty) return;

    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get(
        '/campaign/influencer/milestone/$milestoneId',
      );
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return;

    final Map<String, dynamic> root = (result.data is Map<String, dynamic>)
        ? result.data
        : <String, dynamic>{};

    final Map<String, dynamic> data = (root['data'] is Map<String, dynamic>)
        ? root['data']
        : <String, dynamic>{};

    // ✅ milestone JSON is nested
    final Map<String, dynamic> m = (data['milestone'] is Map<String, dynamic>)
        ? data['milestone']
        : <String, dynamic>{};

    dev.log('THE MILESTONE: ${formatCurrencyByLocale(m['amount'] as num)}');

    // ✅ top-level status (in_review / approved / declined etc)
    final String? overallStatusRaw = data['status']?.toString();

    // ✅ update milestone from "milestone" object
    _setMilestone(
      milestone.copyWith(
        id: m['id']?.toString() ?? milestone.id,
        title: m['contentTitle']?.toString() ?? milestone.title,
        platform: m['platform']?.toString(),
        deliverable:
            '${m['platform']?.toString()} - ${m['contentQuantity']?.toString()}',
        dayIndex: _intSmart(m['deliveryDays']),
        amountLabel: formatCurrencyByLocale(m['amount'] as num),
        promotionGoal:
            (m['promotionGoal']?.toString().trim().isNotEmpty ?? false)
            ? m['promotionGoal']?.toString()
            : milestone.promotionGoal,
        targets: PromotionTarget(
          reach: _intSmart(m['expectedReach']),
          views: _intSmart(m['expectedViews']),
          likes: _intSmart(m['expectedLikes']),
          comments: _intSmart(m['expectedComments']),
        ),
        // use overall status; fallback to milestone.status if missing
        status: _parseMilestoneStatus(
          overallStatusRaw ?? m['status']?.toString(),
        ),
      ),
    );

    milestoneStatus.value = _localStatusFromMilestone(currentMilestone.status);

    // ✅ pick latestSubmission first, fallback to submissions[0]
    final Map<String, dynamic>? latestRaw =
        (data['latestSubmission'] is Map<String, dynamic>)
        ? (data['latestSubmission'] as Map<String, dynamic>)
        : null;

    final Map<String, dynamic>? latest = latestRaw;

    final List submissionsList = (data['submissions'] as List?) ?? const [];

    final Map<String, dynamic>? firstFromList =
        submissionsList.isNotEmpty &&
            submissionsList.first is Map<String, dynamic>
        ? (submissionsList.first as Map<String, dynamic>)
        : null;

    final Map<String, dynamic>? s = latest ?? firstFromList;

    submissions.clear();

    if (s == null) {
      submissions.add(SubmissionUiModel(index: 1));
      return;
    }

    final ui = SubmissionUiModel(index: 1);

    ui.serverId = s['id']?.toString();

    ui.descriptionController.text =
        s['submissionDescription']?.toString() ?? '';
    ui.linkController.text = _firstString(s['submissionLiveLinks']) ?? '';

    // ✅ Influencer must NOT submit requested amount => keep empty
    ui.amountController.text = '';

    ui.status.value = _parseSubmissionStatus(s['status']?.toString());
    ui.rejectionReason.value = s['rejectionReason']?.toString();

    // ✅ achieved metrics
    final int? aReach = _intSmart(s['achievedReach']);
    final int? aViews = _intSmart(s['achievedViews']);
    final int? aLikes = _intSmart(s['achievedLikes']);
    final int? aComments = _intSmart(s['achievedComments']);

    ui.achievedReach.value = aReach;
    ui.achievedViews.value = aViews;
    ui.achievedLikes.value = aLikes;
    ui.achievedComments.value = aComments;

    // fill controllers (avoid "null")
    ui.reachController.text = aReach?.toString() ?? '';
    ui.viewsController.text = aViews?.toString() ?? '';
    ui.likesController.text = aLikes?.toString() ?? '';
    ui.commentsController.text = aComments?.toString() ?? '';

    // ✅ proofs (your server uses "submissionAttachments")
    ui.serverProofUrls.assignAll(
      _stringList(
        s['proofAttachments'] ??
            s['attachments'] ??
            s['submissionAttachments'] ??
            s['submissionLiveAttachments'],
      ),
    );

    ui.declinedEditEnabled.value = false;
    ui.isSubmitted.value = true;
    ui.isExpanded.value = false;

    submissions.add(ui);
  }

  /// Parses int from int/num/"50000"/"0.00"
  int? _intSmart(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString().trim();
    if (s.isEmpty) return null;

    // handle "0.00"
    final asDouble = double.tryParse(s);
    if (asDouble != null) return asDouble.toInt();

    // fallback: keep digits only
    final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
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

  Future<void> _submitSingleSubmission(
    SubmissionUiModel ui,
    String milestoneId,
  ) async {
    final proofUrls = await _uploadProofAttachments(ui.proofs);

    // 1) ✅ submit/resubmit WITHOUT metrics (but with requestPaymentAmount)
    final agencyPayload = _buildAgencySubmitPayload(
      ui: ui,
      proofUrls: proofUrls,
    );

    final shouldResubmit = (ui.serverId ?? '').trim().isNotEmpty;

    final result = await ApiErrorHandler.call(() async {
      final Map<String, dynamic> apiRes = shouldResubmit
          ? await _campaignService.resubmitAgencyMilestoneWork(
              submissionId: ui.serverId!.trim(),
              payload: agencyPayload,
            )
          : await _campaignService.submitAgencyMilestoneWork(
              milestoneId: milestoneId,
              payload: agencyPayload,
            );

      return apiRes;
    });

    if (!result.isSuccess) return;

    // If it was a NEW submit, try to capture serverId from response (best effort)
    if (!shouldResubmit) {
      final id = _extractSubmissionId(result.data);
      if ((id ?? '').trim().isNotEmpty) {
        ui.serverId = id!.trim();
      }
    }

    // 2) ✅ update results with ONLY ONE achieved metric payload
    final submissionId = (ui.serverId ?? '').trim();
    final achievedMetrics = _buildAgencyAchievedMetricsPayload(ui);

    if (submissionId.isNotEmpty && achievedMetrics.isNotEmpty) {
      await ApiErrorHandler.call(
        () => _campaignService.updateAgencySubmissionResults(
          submissionId: submissionId,
          payload: achievedMetrics,
        ),
        showError: false,
      );
    }

    // UI state
    ui.status.value = SubmissionStatus.inReview;
    ui.isSubmitted.value = true;
    ui.isExpanded.value = false;
    ui.declinedEditEnabled.value = false;
    ui.rejectionReason.value = null;
  }

  Future<void> _submitInfluencerMilestone(String milestoneId) async {
    if (submissions.isEmpty) return;

    for (final ui in submissions) {
      await _submitSingleSubmission(ui, milestoneId);
    }

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

    _loadSelectedSubmissionReportsForBrand();
  }

  void toggleBrandSubmissionExpanded(int index) {
    if (job.campaignType != CampaignType.paidAd) return;

    for (final s in brandSubmissions) {
      if (s.index == index) {
        final next = !s.isExpanded.value;
        s.isExpanded.value = next;
        if (next) {
          selectedBrandSubmissionIndex.value = index;
          _loadSelectedSubmissionReportsForBrand();
        }
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

  Future<bool> _reviewClientSubmission({
    required String submissionId,
    required bool approve,
    String? reason,
  }) async {
    final result = await ApiErrorHandler.call(
      () => _campaignService.reviewClientSubmission(
        submissionId: submissionId,
        action: approve ? 'approve' : 'decline',
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

  void openBonusDialog() {
    bonusAmountController.clear();
    selectedBonusPaymentMethod.value = 'Credit / Debit Card';

    Get.dialog(const BonusPaymentDialog());
  }

  void setBonusPaymentMethod(String value) {
    selectedBonusPaymentMethod.value = value;
  }

  Future<void> payBonus() async {
    final rawAmount = bonusAmountController.text.trim();
    final amount = _parseAmount(rawAmount);

    if (amount <= 0) {
      Get.snackbar('Required', 'Please enter a valid bonus amount.');
      return;
    }

    final target = bonusTargetSubmission;
    if (target == null) {
      Get.snackbar('Unavailable', 'No eligible submission found for bonus.');
      return;
    }

    isBonusPaymentLoading.value = true;

    final result = await ApiErrorHandler.call(() async {
      if (job.campaignType == CampaignType.paidAd) {
        final milestoneId = milestone.id?.trim() ?? '';
        if (milestoneId.isEmpty) {
          throw Exception('Milestone id not found.');
        }

        dev.log('BONUS PAID : Influencer - $amount $milestoneId');

        return await _campaignService.payClientMilestoneBonus(
          milestoneId: milestoneId,
          amount: amount,
        );
      } else {
        final submissionId = (target.serverId ?? '').trim();
        if (submissionId.isEmpty) {
          throw Exception('Submission id not found.');
        }

        dev.log('BONUS PAID : Influencer - $amount $submissionId');
        return await _campaignService.payClientSubmissionBonus(
          submissionId: submissionId,
          amount: amount,
        );
      }
    });

    isBonusPaymentLoading.value = false;

    if (!result.isSuccess) return;

    Get.back();
    Get.snackbar('Success', 'Bonus payment completed successfully.');

    _markNeedsParentRefresh();
    await _loadBrandMilestoneDetails(
      isPaidAd: job.campaignType == CampaignType.paidAd,
    );
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
