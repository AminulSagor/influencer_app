// lib/modules/ad_agency/milestone_details/milestone_details_controller.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/firebase_messaging_service.dart';
import '../../../core/utils/metric_number_util.dart';
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
  final String milestoneId;
  final String authorId;
  final String content;
  final DateTime date;

  SubmissionReportHistoryItem({
    required this.id,
    required this.milestoneId,
    required this.authorId,
    required this.content,
    required this.date,
  });
}

class SubmissionUiModel {
  final int index;
  String? serverId;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final RxList<TextEditingController> linkControllers = <TextEditingController>[
    TextEditingController(),
  ].obs;

  final TextEditingController metricLabelController = TextEditingController(
    text: 'Reach',
  );
  final TextEditingController metricValueController = TextEditingController();
  final TextEditingController reachController = TextEditingController();
  final TextEditingController viewsController = TextEditingController();
  final TextEditingController likesController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  final RxnString rejectionReason = RxnString();

  final RxnInt achievedReach = RxnInt();
  final RxnInt achievedViews = RxnInt();
  final RxnInt achievedLikes = RxnInt();
  final RxnInt achievedComments = RxnInt();

  final RxList<PlatformFile> proofs = <PlatformFile>[].obs;
  final RxList<String> serverProofUrls = <String>[].obs;
  final RxBool isExpanded = true.obs;

  final Rx<SubmissionStatus> status = SubmissionStatus.inReview.obs;
  final RxBool isSubmitted = false.obs;
  final RxBool declinedEditEnabled = false.obs;

  SubmissionUiModel({required this.index});

  bool get isEditable {
    if (!isSubmitted.value) return true;
    if (status.value == SubmissionStatus.approved) return false;
    if (status.value == SubmissionStatus.declined) {
      return declinedEditEnabled.value;
    }
    return true;
  }

  List<String> get liveLinks => linkControllers
      .map((e) => e.text.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  void setLiveLinks(List<String> links) {
    for (final c in linkControllers) {
      c.dispose();
    }
    linkControllers.clear();

    final cleaned = links
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    if (cleaned.isEmpty) {
      linkControllers.add(TextEditingController());
      return;
    }

    for (final link in cleaned) {
      linkControllers.add(TextEditingController(text: link));
    }
  }

  void addLiveLinkField([String initialValue = '']) {
    linkControllers.add(TextEditingController(text: initialValue));
  }

  void removeLiveLinkField(int index) {
    if (index < 0 || index >= linkControllers.length) return;

    final controller = linkControllers[index];
    linkControllers.removeAt(index);
    controller.dispose();

    if (linkControllers.isEmpty) {
      linkControllers.add(TextEditingController());
    }
  }

  void dispose() {
    descriptionController.dispose();
    amountController.dispose();

    for (final c in linkControllers) {
      c.dispose();
    }
    linkControllers.clear();

    metricLabelController.dispose();
    metricValueController.dispose();
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
  final RxSet<int> selectedBrandSubmissionIndexes = <int>{}.obs;

  // Reports
  final RxList<SubmissionReportHistoryItem> selectedSubmissionReports =
      <SubmissionReportHistoryItem>[].obs;
  final RxBool isSelectedSubmissionReportsLoading = false.obs;
  final RxnString selectedSubmissionReportMilestoneId = RxnString();

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

  final RxBool isRefreshing = false.obs;
  final RxBool isInitialLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isApproving = false.obs;
  final RxBool isDeclining = false.obs;
  final RxBool isReporting = false.obs;

  double get combinedPaidAdCompletedPercent {
    if (job.campaignType != CampaignType.paidAd) return 0;

    return brandSubmissions
        .where((s) => s.status.value == BrandSubmissionStatus.completed)
        .fold<double>(0, (sum, s) => sum + s.avgPercent);
  }

  bool get canShowBonusSection {
    if (!_accountTypeService.isBrand) return false;
    // if (currentMilestone.status != MilestoneStatus.approved) return false;

    // ✅ Paid ad: multiple completed submissions can together exceed 100%

    if (job.campaignType == CampaignType.paidAd) {
      return combinedPaidAdCompletedPercent > 100;
    }

    // ✅ Influencer promotion / single-submission style: keep old metric-based logic
    int totalReach = 0;
    int totalViews = 0;
    int totalLikes = 0;
    int totalComments = 0;

    int expectedReach = 0;
    int expectedViews = 0;
    int expectedLikes = 0;
    int expectedComments = 0;

    for (final submission in brandSubmissions) {
      if (submission.status.value != BrandSubmissionStatus.completed) continue;

      for (final metric in submission.metrics) {
        switch (metric.labelKey) {
          case 'brand_metric_reach':
            totalReach += metric.achievedValue;
            expectedReach = metric.expectedValue;
            break;
          case 'brand_metric_views':
            totalViews += metric.achievedValue;
            expectedViews = metric.expectedValue;
            break;
          case 'brand_metric_likes':
            totalLikes += metric.achievedValue;
            expectedLikes = metric.expectedValue;
            break;
          case 'brand_metric_comments':
            totalComments += metric.achievedValue;
            expectedComments = metric.expectedValue;
            break;
        }
      }
    }

    final reachExceeded = expectedReach > 0 && totalReach > expectedReach;
    final viewsExceeded = expectedViews > 0 && totalViews > expectedViews;
    final likesExceeded = expectedLikes > 0 && totalLikes > expectedLikes;
    final commentsExceeded =
        expectedComments > 0 && totalComments > expectedComments;

    return reachExceeded || viewsExceeded || likesExceeded || commentsExceeded;
  }

  BrandSubmissionUiModel? get bonusTargetSubmission {
    for (final s in brandSubmissions) {
      if (s.status.value == BrandSubmissionStatus.completed) {
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

  final RxInt agencyPaidAmountTotal = 0.obs;

  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

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

    _listenCampaignNotifications();

    // ✅ ALWAYS FETCH FROM SERVER FOR ALL USERS
    _loadMilestoneDetailsByRole(showInitialLoader: true);
  }

  void toggleHeader() => headerExpanded.toggle();

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    bonusAmountController.dispose();
    for (final s in submissions) {
      s.dispose();
    }
    super.onClose();
  }

  void _listenCampaignNotifications() {
    _notificationSubscription?.cancel();

    _notificationSubscription = FirebaseMessagingService.notificationStream
        .listen((data) async {
          final notificationCampaignId =
              data['campaignId']?.toString().trim() ?? '';
          final notificationMilestoneId =
              data['milestoneId']?.toString().trim() ?? '';

          final currentCampaignId = (job.id ?? '').trim();
          final currentMilestoneId = (milestone.id ?? '').trim();

          final bool campaignMatched =
              notificationCampaignId.isNotEmpty &&
              currentCampaignId.isNotEmpty &&
              notificationCampaignId == currentCampaignId;

          final bool milestoneMatched =
              notificationMilestoneId.isNotEmpty &&
              currentMilestoneId.isNotEmpty &&
              notificationMilestoneId == currentMilestoneId;

          if (!campaignMatched && !milestoneMatched) {
            return;
          }

          dev.log(
            'Matched notification. Refreshing milestone details page.',
            name: 'MilestoneDetailsController',
            error: {
              'currentCampaignId': currentCampaignId,
              'currentMilestoneId': currentMilestoneId,
              'notificationCampaignId': notificationCampaignId,
              'notificationMilestoneId': notificationMilestoneId,
            },
          );

          await refreshMilestoneDetails();
        });
  }

  Future<void> _loadMilestoneDetailsByRole({
    bool isRefresh = false,
    bool showInitialLoader = false,
  }) async {
    final milestoneId = milestone.id?.trim();
    if (milestoneId == null || milestoneId.isEmpty) return;

    if (showInitialLoader) {
      isInitialLoading.value = true;
    }
    if (isRefresh) {
      isRefreshing.value = true;
    }

    try {
      if (_accountTypeService.isInfluencer) {
        await _loadInfluencerMilestoneDetails();
      } else {
        await _loadBrandMilestoneDetails(
          isPaidAd: job.campaignType == CampaignType.paidAd,
        );
      }
    } finally {
      if (showInitialLoader) {
        isInitialLoading.value = false;
      }
      if (isRefresh) {
        isRefreshing.value = false;
      }
    }
  }

  Future<void> refreshMilestoneDetails() async {
    await _loadMilestoneDetailsByRole(isRefresh: true);
  }

  void addLiveLinkField(int submissionIndex) {
    if (submissionIndex < 0 || submissionIndex >= submissions.length) return;
    submissions[submissionIndex].addLiveLinkField();
    submissions.refresh();
  }

  void removeLiveLinkField(int submissionIndex, int linkIndex) {
    if (submissionIndex < 0 || submissionIndex >= submissions.length) return;
    submissions[submissionIndex].removeLiveLinkField(linkIndex);
    submissions.refresh();
  }

  void _applyAgencyMetricFromMilestone(SubmissionUiModel ui) {
    final targets = currentMilestone.targets;

    final availableTargetLabels = <String>[
      if ((targets?.reach ?? 0) > 0) 'Reach',
      if ((targets?.views ?? 0) > 0) 'Views',
      if ((targets?.likes ?? 0) > 0) 'Likes',
      if ((targets?.comments ?? 0) > 0) 'Comments',
    ];

    final metricMap = <String, int?>{
      'Reach': ui.achievedReach.value,
      'Views': ui.achievedViews.value,
      'Likes': ui.achievedLikes.value,
      'Comments': ui.achievedComments.value,
    };

    for (final label in availableTargetLabels) {
      final value = metricMap[label] ?? 0;
      if (value > 0) {
        ui.metricLabelController.text = label;
        ui.metricValueController.text = MetricNumberUtil.format(value);
        return;
      }
    }

    if (availableTargetLabels.isNotEmpty) {
      ui.metricLabelController.text = availableTargetLabels.first;
    } else {
      ui.metricLabelController.text = 'Reach';
    }

    ui.metricValueController.text = '';
  }

  bool get shouldShowSubmitSection {
    return !_accountTypeService.isBrand &&
        currentMilestone.status != MilestoneStatus.approved &&
        currentMilestone.status != MilestoneStatus.paid &&
        currentMilestone.status != MilestoneStatus.partialPaid;
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
            milestoneId: e['milestoneId']?.toString() ?? '',
            authorId: e['authorId']?.toString() ?? '',
            content: e['content']?.toString().trim() ?? '',
            date: _safeParseDateTime(e['date']?.toString()),
          ),
        )
        .where((e) => e.content.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _loadSelectedSubmissionReportsForBrand() async {
    if (!_accountTypeService.isBrand) return;

    final milestoneId = (milestone.id ?? '').trim();

    if (milestoneId.isEmpty) {
      selectedSubmissionReportMilestoneId.value = null;
      selectedSubmissionReports.clear();
      return;
    }

    isSelectedSubmissionReportsLoading.value = true;
    selectedSubmissionReportMilestoneId.value = milestoneId;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchSubmissionReport(milestoneId: milestoneId),
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

    final milestoneId = milestone.id?.trim() ?? '';
    if (milestoneId.isEmpty) {
      Get.snackbar('Missing data', 'Milestone id not found.');
      return;
    }

    isReporting.value = true;
    try {
      final result = await ApiErrorHandler.call(() {
        if (job.campaignType == CampaignType.paidAd) {
          return _campaignService.reportAgencyMilestone(
            milestoneId: milestoneId,
            report: r,
          );
        }

        return _campaignService.reportInfluencerMilestone(
          milestoneId: milestoneId,
          report: r,
        );
      });

      if (!result.isSuccess) return;

      hasReportedToAdmin.value = true;
      reportAgainAt.value = DateTime.now().add(const Duration(days: 1));

      await _loadSelectedSubmissionReportsForBrand();
    } finally {
      isReporting.value = false;
    }
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
  }

  Future<void> _loadBrandMilestoneDetails({required bool isPaidAd}) async {
    isBrandSubmissionsLoading.value = true;
    brandSubmissions.clear();
    submissions.clear();
    agencyPaidAmountTotal.value = 0;

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

    final rawAmount = raw['amount'];

    // ✅ UPDATE MILESTONE
    _setMilestone(
      milestone.copyWith(
        id: raw['id']?.toString() ?? milestone.id,
        title: raw['contentTitle']?.toString() ?? milestone.title,
        platform: raw['platform']?.toString(),
        deliverable:
            '${raw['platform']?.toString()} - ${raw['contentQuantity']?.toString()}',
        dayIndex: _intFrom(raw['deliveryDays']),
        amountLabel: formatCurrencyByLocale(
          (rawAmount is String ? double.tryParse(rawAmount) : rawAmount) as num,
        ),
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
              expanded: true,
            ),
          )
          .toList();

      brandSubmissions.assignAll(mapped);

      if (mapped.isEmpty) {
        selectedBrandSubmissionIndex.value = null;
        selectedBrandSubmissionIndexes.clear();
        selectedSubmissionReports.clear();
        selectedSubmissionReportMilestoneId.value = null;
      } else if (isPaidAd) {
        selectedBrandSubmissionIndex.value = null;
        selectedBrandSubmissionIndexes.clear();
      } else {
        selectedBrandSubmissionIndex.value = mapped.first.index;
      }

      await _loadSelectedSubmissionReportsForBrand();
    } else {
      // ✅ Agency loads into SubmissionUiModel (multiple allowed)
      int idx = 1;
      int paidAmountSum = 0;

      for (final s in submissionsRaw.whereType<Map>()) {
        final ui = SubmissionUiModel(index: idx);
        ui.serverId = s['id']?.toString();
        ui.descriptionController.text =
            s['submissionDescription']?.toString() ?? '';
        ui.amountController.text = s['requestedAmount']?.toString() ?? '';
        ui.setLiveLinks(
          _stringList(s['submissionLiveLinks'] ?? s['liveLinks']),
        );
        ui.status.value = _parseSubmissionStatus(s['status']?.toString());
        ui.rejectionReason.value = s['rejectionReason']?.toString();

        ui.achievedReach.value = _intFrom(s['achievedReach']);
        ui.achievedViews.value = _intFrom(s['achievedViews']);
        ui.achievedLikes.value = _intFrom(s['achievedLikes']);
        ui.achievedComments.value = _intFrom(s['achievedComments']);

        _applyAgencyMetricFromMilestone(ui);

        ui.declinedEditEnabled.value = false;
        ui.isSubmitted.value = true;
        ui.serverProofUrls.assignAll(
          _stringList(
            s['proofAttachments'] ??
                s['attachments'] ??
                s['submissionAttachments'],
          ),
        );
        ui.isExpanded.value = true;

        paidAmountSum += _intSmart(s['paidAmount']) ?? 0;

        submissions.add(ui);
        idx++;
      }

      agencyPaidAmountTotal.value = paidAmountSum;

      if (submissions.isEmpty) {
        final ui = SubmissionUiModel(index: 1);
        _applyAgencyMetricFromMilestone(ui);
        submissions.add(ui);
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

      metrics.add(
        BrandSubmissionMetric(
          labelKey: labelKey,
          leftValue: _compactNumber(achieved),
          rightValue: _compactNumber(expected),
          progress: rawProgress.clamp(0.0, 1.0).toDouble(),
          targetKey: 'Target $pct%',
          achievedValue: achieved,
          expectedValue: expected,
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
    return MetricNumberUtil.format(value);
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
  bool get showPaymentProgress =>
      _accountTypeService.isAdAgency &&
      _parseAmount(currentMilestone.amountLabel) > 0;

  int _parseAmount(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 0;

    final normalized = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    if (normalized.isEmpty) return 0;

    final value = double.tryParse(normalized);
    if (value == null) return 0;

    return value.round();
  }

  int get milestoneAmountTotal => _parseAmount(currentMilestone.amountLabel);

  double get paymentProgressValue {
    final total = milestoneAmountTotal;
    if (total <= 0) return 0;

    return (agencyPaidAmountTotal.value / total).clamp(0.0, 1.0);
  }

  String get progressLeftLabel =>
      formatCurrencyByLocale(agencyPaidAmountTotal.value);

  String get progressRightLabel => currentMilestone.amountLabel;

  // ---------- actions ----------

  void toggleOwnership() => confirmOwnership.toggle();
  void toggleLicense() => acceptLicense.toggle();

  void addSubmission() {
    final ui = SubmissionUiModel(index: submissions.length + 1);

    if (_accountTypeService.isAdAgency) {
      _applyAgencyMetricFromMilestone(ui);
    }

    submissions.add(ui);
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
    return MetricNumberUtil.parseToInt(raw);
  }

  Map<String, dynamic> _buildAgencySubmitPayload({
    required SubmissionUiModel ui,
    required List<String> proofUrls,
  }) {
    final requestedAmount =
        double.tryParse(ui.amountController.text.trim()) ?? 0.0;

    final targetAmount =
        MetricNumberUtil.parseToInt(ui.metricValueController.text.trim()) ?? 0;

    final thePayload = {
      'description': ui.descriptionController.text.trim(),
      'liveLinks': ui.liveLinks,
      'proofAttachments': proofUrls,
      if (requestedAmount > 0) 'requestPaymentAmount': requestedAmount,
      "targetTitle": ui.metricLabelController.text.trim(),
      "targetAmount": targetAmount,
    };
    dev.log('THE PAYLOAD: $thePayload');
    return thePayload;
  }

  /// Only ONE metric for agency results endpoint (based on label/value).
  Map<String, dynamic> _buildAgencyAchievedMetricsPayload(
    SubmissionUiModel ui,
  ) {
    final label = ui.metricLabelController.text.trim().toLowerCase();
    final value = _metricInt(ui.metricValueController.text.trim());

    if (value == null || value <= 0) return {};

    ui.metricValueController.text = MetricNumberUtil.format(value);

    if (label.contains('view')) return {'achievedViews': value};
    if (label.contains('like')) return {'achievedLikes': value};
    if (label.contains('comment')) return {'achievedComments': value};

    return {'achievedReach': value};
  }

  Map<String, dynamic> _buildInfluencerSubmitPayload({
    required SubmissionUiModel ui,
    required List<String> proofUrls,
  }) {
    final achievedReach = _metricInt(ui.reachController.text.trim());
    final achievedViews = _metricInt(ui.viewsController.text.trim());
    final achievedLikes = _metricInt(ui.likesController.text.trim());
    final achievedComments = _metricInt(ui.commentsController.text.trim());

    return {
      'description': ui.descriptionController.text.trim(),
      'liveLinks': ui.liveLinks,
      'proofAttachments': proofUrls,
      if (achievedReach != null) 'achievedReach': achievedReach,
      if (achievedViews != null) 'achievedViews': achievedViews,
      if (achievedLikes != null) 'achievedLikes': achievedLikes,
      if (achievedComments != null) 'achievedComments': achievedComments,
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
  }

  Future<void> _submitInfluencerOnly(String milestoneId) async {
    if (submissions.isEmpty) return;

    final ui = submissions.first;

    if (ui.status.value == SubmissionStatus.approved) {
      Get.snackbar('Nothing to submit', 'Submission already approved.');
      return;
    }

    final proofUrls = await _uploadProofAttachments(ui.proofs);

    final payload = _buildInfluencerSubmitPayload(ui: ui, proofUrls: proofUrls);

    final hasServerId = (ui.serverId ?? '').trim().isNotEmpty;
    final shouldResubmit =
        hasServerId &&
        (ui.status.value == SubmissionStatus.inReview ||
            ui.status.value == SubmissionStatus.declined);

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

    _markNeedsParentRefresh();
    await _loadInfluencerMilestoneDetails();

    Get.snackbar('Submitted', 'Milestone sent for admin review');
  }

  /// Called from "Submit For Admin Review" button.
  void submitForReview() async {
    if (!confirmOwnership.value || !acceptLicense.value) {
      Get.snackbar(
        'Action required',
        'Please confirm ownership and accept the terms.',
      );
      return;
    }

    if (currentMilestone.status == MilestoneStatus.approved ||
        currentMilestone.status == MilestoneStatus.paid ||
        currentMilestone.status == MilestoneStatus.partialPaid) {
      return;
    }

    final milestoneId = milestone.id?.trim() ?? '';
    if (milestoneId.isEmpty) {
      Get.snackbar('Error', 'Missing milestone id.');
      return;
    }

    isSubmitting.value = true;
    try {
      if (_accountTypeService.isAdAgency) {
        await _submitAgencyDraftSubmissions(milestoneId);
        return;
      }

      if (_accountTypeService.isInfluencer) {
        await _submitInfluencerOnly(milestoneId);
        return;
      }
    } finally {
      isSubmitting.value = false;
    }
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
    ui.setLiveLinks(_stringList(s['submissionLiveLinks'] ?? s['liveLinks']));

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
    ui.reachController.text = aReach != null
        ? MetricNumberUtil.format(aReach)
        : '';
    ui.viewsController.text = aViews != null
        ? MetricNumberUtil.format(aViews)
        : '';
    ui.likesController.text = aLikes != null
        ? MetricNumberUtil.format(aLikes)
        : '';
    ui.commentsController.text = aComments != null
        ? MetricNumberUtil.format(aComments)
        : '';

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

    final hasServerId = (ui.serverId ?? '').trim().isNotEmpty;
    final shouldResubmit =
        hasServerId &&
        (ui.status.value == SubmissionStatus.inReview ||
            ui.status.value == SubmissionStatus.declined);

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

  BrandSubmissionUiModel? get selectedBrandSubmission {
    if (job.campaignType == CampaignType.paidAd) {
      for (final s in brandSubmissions) {
        if (selectedBrandSubmissionIndexes.contains(s.index)) {
          return s;
        }
      }
    }

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

  List<BrandSubmissionUiModel> get selectedBrandSubmissions {
    if (job.campaignType != CampaignType.paidAd) {
      final item = selectedBrandSubmission;
      return item == null ? const [] : [item];
    }

    return brandSubmissions
        .where((s) => selectedBrandSubmissionIndexes.contains(s.index))
        .toList(growable: false);
  }

  List<String> get selectedBrandSubmissionIds {
    return selectedBrandSubmissions
        .map((e) => (e.serverId ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  bool get isSelectedBrandSubmissionFinalized {
    final isPaidAd = job.campaignType == CampaignType.paidAd;

    if (isPaidAd) {
      final selected = selectedBrandSubmissions;
      if (selected.isEmpty) return false;

      return selected.every(
        (e) =>
            e.status.value == BrandSubmissionStatus.completed ||
            e.status.value == BrandSubmissionStatus.declined,
      );
    }

    final selected = selectedBrandSubmission;
    if (selected == null) return false;

    return selected.status.value == BrandSubmissionStatus.completed ||
        selected.status.value == BrandSubmissionStatus.declined;
  }

  bool shouldShowSelectionForBrandSubmission(
    BrandSubmissionUiModel submission,
  ) {
    if (job.campaignType != CampaignType.paidAd) return false;

    return submission.status.value != BrandSubmissionStatus.completed &&
        submission.status.value != BrandSubmissionStatus.declined;
  }

  bool isBrandSubmissionSelected(int index) {
    if (job.campaignType == CampaignType.paidAd) {
      return selectedBrandSubmissionIndexes.contains(index);
    }
    return selectedBrandSubmissionIndex.value == index;
  }

  void selectBrandSubmission(int index) {
    final target = brandSubmissions.firstWhereOrNull((s) => s.index == index);
    if (target == null) return;

    final isFinalized =
        target.status.value == BrandSubmissionStatus.completed ||
        target.status.value == BrandSubmissionStatus.declined;

    if (job.campaignType == CampaignType.paidAd) {
      if (isFinalized) return;

      if (selectedBrandSubmissionIndexes.contains(index)) {
        selectedBrandSubmissionIndexes.remove(index);
      } else {
        selectedBrandSubmissionIndexes.add(index);
      }

      target.isExpanded.value = true;
      _loadSelectedSubmissionReportsForBrand();
      return;
    }

    if (isFinalized) return;

    selectedBrandSubmissionIndex.value = index;
    _loadSelectedSubmissionReportsForBrand();
  }

  void toggleBrandSubmissionExpanded(int index) {
    if (job.campaignType != CampaignType.paidAd) return;

    for (final s in brandSubmissions) {
      if (s.index == index) {
        s.isExpanded.value = !s.isExpanded.value;
        break;
      }
    }

    _loadSelectedSubmissionReportsForBrand();
  }

  Future<void> approveSelectedBrandSubmission() async {
    final isPaidAd = job.campaignType == CampaignType.paidAd;

    isApproving.value = true;
    try {
      if (isPaidAd) {
        final ok = await _reviewClientSubmission(
          approve: true,
          milestoneId: milestone.id?.trim(),
          submissionIds: selectedBrandSubmissionIds,
        );

        if (!ok) return;

        _markNeedsParentRefresh();
        selectedBrandSubmissionIndexes.clear();
        await _loadBrandMilestoneDetails(isPaidAd: true);
        return;
      }

      final target = selectedBrandSubmission;
      if (target == null) {
        Get.snackbar('No submission', 'Please select a submission first.');
        return;
      }

      final ok = await _reviewClientSubmission(
        approve: true,
        submissionId: target.serverId,
      );

      if (!ok) return;

      _markNeedsParentRefresh();
      await _loadBrandMilestoneDetails(isPaidAd: false);
    } finally {
      isApproving.value = false;
    }
  }

  Future<void> declineSelectedBrandSubmission(String reason) async {
    final r = reason.trim();
    if (r.isEmpty) {
      Get.snackbar('Required', 'Please write a reason.');
      return;
    }

    final isPaidAd = job.campaignType == CampaignType.paidAd;

    isDeclining.value = true;
    try {
      if (isPaidAd) {
        final ok = await _reviewClientSubmission(
          approve: false,
          milestoneId: milestone.id?.trim(),
          submissionIds: selectedBrandSubmissionIds,
          reason: r,
        );

        if (!ok) return;

        _markNeedsParentRefresh();
        selectedBrandSubmissionIndexes.clear();
        await _loadBrandMilestoneDetails(isPaidAd: true);
        return;
      }

      final target = selectedBrandSubmission;
      if (target == null) {
        Get.snackbar('No submission', 'Please select a submission first.');
        return;
      }

      final ok = await _reviewClientSubmission(
        approve: false,
        submissionId: target.serverId,
        reason: r,
      );

      if (!ok) return;

      _markNeedsParentRefresh();
      await _loadBrandMilestoneDetails(isPaidAd: false);
    } finally {
      isDeclining.value = false;
    }
  }

  Future<bool> _reviewClientSubmission({
    required bool approve,
    String? submissionId,
    String? milestoneId,
    List<String> submissionIds = const [],
    String? reason,
  }) async {
    final action = approve ? 'approve' : 'decline';

    if (job.campaignType == CampaignType.paidAd) {
      final cleanMilestoneId = milestoneId?.trim() ?? '';
      final cleanSubmissionIds = submissionIds
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      if (cleanMilestoneId.isEmpty) {
        Get.snackbar('Missing data', 'Milestone id not found.');
        return false;
      }

      if (cleanSubmissionIds.isEmpty) {
        Get.snackbar('No submission', 'Please select at least one submission.');
        return false;
      }

      final result = await ApiErrorHandler.call(
        () => _campaignService.reviewAgencyMilestoneSubmissions(
          milestoneId: cleanMilestoneId,
          submissionIds: cleanSubmissionIds,
          action: action,
          reason: approve ? null : (reason ?? 'Declined by client.'),
        ),
      );

      return result.isSuccess;
    }

    final cleanSubmissionId = submissionId?.trim() ?? '';
    if (cleanSubmissionId.isEmpty) {
      Get.snackbar('Missing data', 'Submission id not found.');
      return false;
    }

    final result = await ApiErrorHandler.call(
      () => _campaignService.reviewInfluencerSubmission(
        submissionId: cleanSubmissionId,
        action: action,
        reason: approve ? null : (reason ?? 'Declined by client.'),
      ),
    );

    return result.isSuccess;
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

        dev.log('BONUS PAID : Agency - $amount $milestoneId');

        return await _campaignService.payAgencyBonus(
          milestoneId: milestoneId,
          amount: amount,
        );
      } else {
        final milestoneId = milestone.id?.trim() ?? '';
        if (milestoneId.isEmpty) {
          throw Exception('Milestone id not found.');
        }

        dev.log('BONUS PAID : Influencer - $amount $milestoneId');
        return await _campaignService.payInfluencerBonus(
          milestoneId: milestoneId,
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

  Future<void> openLink(String rawUrl) async {
    String url = rawUrl.trim();
    if (url.isEmpty) return;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Error', 'Invalid link');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar('Error', 'Could not open link');
    }
  }

  Future<void> copyLinkText(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: value));
    Get.snackbar('Copied', 'Link copied to clipboard');
  }
}
