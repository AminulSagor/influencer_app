import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/campaign_service.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/job_item.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/label_localizers.dart';

enum CampaignStatus { newOffer, accepted, ongoing, ongoingDeclined, complete }

class CampaignDetailsController extends GetxController {
  final dynamic arguments;
  CampaignDetailsController(this.arguments);

  late JobItem _job;
  final Rxn<JobItem> jobRx = Rxn<JobItem>();
  JobItem get job => jobRx.value ?? _job;

  bool _isNewOffer = true;
  int? _proposedServiceFeePercent;
  double? _proposedDollarRate;

  final accountTypeService = Get.find<AccountTypeService>();
  final CampaignService _campaignService = Get.find<CampaignService>();

  final isPageRefreshing = false.obs;
  final isAcceptDeclineLoading = false.obs;
  final isRequoteLoading = false.obs;
  String _serverStatus = '';

  final milestonesExpanded = true.obs;
  final briefExpanded = true.obs;
  final contentAssetsExpanded = true.obs;
  final termsExpanded = true.obs;
  final brandAssetsExpanded = true.obs;
  final agreeToTerms = false.obs;

  final campaignStatus = CampaignStatus.newOffer.obs;
  final milestones = <Milestone>[].obs;
  final platformKeys = <String>[].obs;
  final campaignGoalsText = ''.obs;
  final contentRequirements = <String>[].obs;
  final dosLines = <String>[].obs;
  final dontsLines = <String>[].obs;
  final reportingRequirementLines = <String>[].obs;
  final usageRightLines = <String>[].obs;
  final contentAssetsUi = <JobAsset>[].obs;
  final brandAssetsUi = <BrandAsset>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (arguments is! JobItem) {
      throw 'CampaignDetails requires JobItem in Get.arguments';
    }

    _job = arguments as JobItem;
    milestones.assignAll(job.milestones ?? const <Milestone>[]);
    _recalculateStatus();
    _loadCampaignDetails();
  }

  void toggleMilestones() => milestonesExpanded.toggle();
  void toggleBrief() => briefExpanded.toggle();
  void toggleContentAssets() => contentAssetsExpanded.toggle();
  void toggleTerms() => termsExpanded.toggle();
  void toggleBrandAssets() => brandAssetsExpanded.toggle();
  void toggleAgree() => agreeToTerms.toggle();

  Future<void> onAccept() async {
    final isInfluencer = accountTypeService.isInfluencer;
    final isAdAgency = accountTypeService.isAdAgency;

    if (!agreeToTerms.value && !isInfluencer) {
      Get.snackbar(
        'campaign_agreement_required'.tr,
        'campaign_agreement_required_desc'.tr,
      );
      return;
    }

    if (isInfluencer && job.id != null && job.id!.isNotEmpty) {
      await _acceptInfluencerOffer(job.id!);
      return;
    }

    if (isAdAgency && job.id != null && job.id!.isNotEmpty) {
      await _acceptAgencyOffer(job.id!);
      return;
    }

    _isNewOffer = false;
    _recalculateStatus();
  }

  Future<void> onDecline() async {
    final isInfluencer = accountTypeService.isInfluencer;
    final isAdAgency = accountTypeService.isAdAgency;

    if (isInfluencer && job.id != null && job.id!.isNotEmpty) {
      await _declineInfluencerOffer(job.id!);
      return;
    }

    if (isAdAgency && job.id != null && job.id!.isNotEmpty) {
      await _declineAgencyOffer(job.id!);
      return;
    }

    Get.back(id: 1);
  }

  Future<void> _acceptInfluencerOffer(String jobId) async {
    if (isAcceptDeclineLoading.value) return;
    isAcceptDeclineLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.acceptInfluencerJobOffer(jobId: jobId),
    );

    if (result.isSuccess) {
      _isNewOffer = false;
      _recalculateStatus();
      await _loadCampaignDetails();
    }

    isAcceptDeclineLoading.value = false;
  }

  Future<void> _declineInfluencerOffer(String jobId) async {
    if (isAcceptDeclineLoading.value) return;
    isAcceptDeclineLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.declineInfluencerJobOffer(jobId: jobId),
    );

    if (result.isSuccess) {
      Get.back(id: 1);
    }

    isAcceptDeclineLoading.value = false;
  }

  Future<void> _acceptAgencyOffer(String campaignId) async {
    if (isAcceptDeclineLoading.value) return;
    isAcceptDeclineLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.acceptAgencyOffer(campaignId: campaignId),
    );

    if (result.isSuccess) {
      _isNewOffer = false;
      _recalculateStatus();
      await _loadCampaignDetails();
    }

    isAcceptDeclineLoading.value = false;
  }

  Future<void> _declineAgencyOffer(String campaignId) async {
    if (isAcceptDeclineLoading.value) return;
    isAcceptDeclineLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.declineAgencyOffer(campaignId: campaignId),
    );

    if (result.isSuccess) {
      Get.back(id: 1);
    }

    isAcceptDeclineLoading.value = false;
  }

  Future<void> requestRequote() async {
    if (!accountTypeService.isAdAgency) return;

    final campaignId = job.id?.trim();
    if (campaignId == null || campaignId.isEmpty) {
      Get.snackbar('Error', 'Missing campaign id.');
      return;
    }

    if (isRequoteLoading.value) return;
    isRequoteLoading.value = true;

    final Map<String, dynamic> payload = {
      'proposedServiceFeePercent':
          _proposedServiceFeePercent ??
          (job.sharePercent > 0 ? job.sharePercent : 14),
      if (_proposedDollarRate != null && _proposedDollarRate! > 0)
        'proposedDollarRate': _proposedDollarRate,
    };

    final result = await ApiErrorHandler.call(
      () => _campaignService.requestAgencyRequote(
        campaignId: campaignId,
        payload: payload,
      ),
    );

    if (result.isSuccess) {
      Get.snackbar(
        'campaign_request_requote'.tr,
        'brand_campaign_requote_sent'.tr,
      );
      await _loadCampaignDetails();
    }

    isRequoteLoading.value = false;
  }

  void onWithdrawalRequest() {
    Get.dialog(
      _WithdrawalSuccessDialog(
        title: job.title,
        amount: job.totalEarningsLabel ?? '৳0',
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _loadCampaignDetails() async {
    final id = job.id?.trim();
    if (id == null || id.isEmpty) return;
    if (!(accountTypeService.isInfluencer || accountTypeService.isAdAgency)) {
      return;
    }

    isPageRefreshing.value = true;

    final result = await ApiErrorHandler.call(() async {
      if (accountTypeService.isInfluencer) {
        await _loadInfluencerJobDetails(id);
      } else if (accountTypeService.isAdAgency) {
        await _loadAgencyCampaignDetails(id);
      }
    });

    if (!result.isSuccess && kDebugMode) {
      print('Failed to load campaign details for $id');
    }

    isPageRefreshing.value = false;
  }

  Future<void> _loadInfluencerJobDetails(String jobId) async {
    final detailsRes = await _campaignService.fetchInfluencerJobDetails(
      jobId: jobId,
    );
    final details = _extractDataMap(detailsRes);

    final milestonesRes = await _campaignService.fetchInfluencerJobMilestones(
      jobId: jobId,
    );
    final milestonePayload = _extractDataMap(milestonesRes);
    final milestoneList = (milestonePayload['milestones'] as List?) ?? const [];

    final mappedMilestones = milestoneList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
        .asMap()
        .entries
        .map((entry) => _mapMilestone(entry.value, entry.key))
        .toList(growable: false);

    final updated = _copyJob(
      job,
      title: (details['campaignName'] as String?)?.trim(),
      clientName: _clientNameFrom(details),
      budget: _budgetFromInfluencer(details),
      dueLabel: _buildDueLabel(details['deadline']?.toString()),
      milestones: mappedMilestones,
    );

    final statusRaw = details['status']?.toString();
    _serverStatus = (statusRaw ?? '').trim().toLowerCase();
    _isNewOffer = _isNewOfferFromStatus(statusRaw, fallback: _isNewOffer);

    _applyCampaignTextAndAssets(details);
    _derivePlatformsFromMilestones(mappedMilestones);

    jobRx.value = updated;
    milestones.assignAll(mappedMilestones);
    _recalculateStatus();
  }

  Future<void> _loadAgencyCampaignDetails(String campaignId) async {
    final res = await _campaignService.fetchAgencyCampaignDetails(
      campaignId: campaignId,
    );
    final raw = _extractDataMap(res);

    final milestoneList = (raw['milestones'] as List?) ?? const [];
    final mappedMilestones = milestoneList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
        .asMap()
        .entries
        .map((entry) => _mapMilestone(entry.value, entry.key))
        .toList(growable: false);

    final budgetBreakdown = raw['budgetBreakdown'] as Map<String, dynamic>?;
    final totalBudget = _toDouble(
      budgetBreakdown?['totalBudget'] ?? raw['totalBudget'],
    );
    final vatAmount = _toDouble(budgetBreakdown?['vat']);
    final estimatedProfit = _toDouble(
      budgetBreakdown?['estimatedAgencyProfit'],
    );
    final totalEarnings = _toDouble(
      budgetBreakdown?['netAvailableForAgency'] ??
          raw['availableBudgetForExecution'],
    );

    final serviceFeeRaw =
        raw['proposedServiceFeePercent'] ??
        budgetBreakdown?['proposedServiceFeePercent'];
    _proposedServiceFeePercent = _toDouble(serviceFeeRaw).round();
    _proposedDollarRate = _toDouble(raw['proposedDollarRate']);

    final updated = _copyJob(
      job,
      title: (raw['campaignName'] as String?)?.trim(),
      clientName: _clientNameFrom(raw),
      dueLabel: _buildDueLabel(raw['deadline']?.toString()),
      budget: totalBudget > 0 ? totalBudget : null,
      sharePercent: _proposedServiceFeePercent,
      vatLabel: vatAmount > 0 ? formatCurrencyByLocale(vatAmount) : null,
      totalCostLabel: totalBudget > 0
          ? formatCurrencyByLocale(totalBudget)
          : null,
      profitLabel: estimatedProfit > 0
          ? formatCurrencyByLocale(estimatedProfit)
          : null,
      totalEarningsLabel: totalEarnings > 0
          ? formatCurrencyByLocale(totalEarnings)
          : null,
      milestones: mappedMilestones,
    );

    final statusRaw = raw['status']?.toString();
    _serverStatus = (statusRaw ?? '').trim().toLowerCase();
    _isNewOffer = _isNewOfferFromStatus(statusRaw, fallback: _isNewOffer);

    _applyCampaignTextAndAssets(raw);
    _derivePlatformsFromMilestones(mappedMilestones);

    jobRx.value = updated;
    milestones.assignAll(mappedMilestones);
    _recalculateStatus();
  }

  Future<void> openMilestoneDetails(Milestone milestone) async {
    final result = await Get.toNamed(
      AppRoutes.milestoneDetails,
      id: 1,
      arguments: {'job': job, 'milestone': milestone},
    );

    if (result is! Map) return;
    if (result['refresh'] != true) return;

    final updatedMilestone = result['milestone'];
    if (updatedMilestone is! Milestone) return;

    final current = milestones.toList(growable: false);
    final idx = current.indexWhere((m) {
      final updatedId = updatedMilestone.id ?? '';
      final currentId = m.id ?? '';
      if (updatedId.isNotEmpty && currentId.isNotEmpty) {
        return updatedId == currentId;
      }
      return m.stepLabel == updatedMilestone.stepLabel;
    });

    if (idx >= 0) {
      current[idx] = updatedMilestone;
      milestones.assignAll(current);
      _recalculateStatus();
    }
  }

  void _recalculateStatus() {
    final list = milestones.toList(growable: false);

    if (_serverStatus.isNotEmpty) {
      if ({'completed', 'complete', 'closed'}.contains(_serverStatus)) {
        campaignStatus.value = CampaignStatus.complete;
        return;
      }
      if ({'declined', 'cancelled', 'rejected'}.contains(_serverStatus)) {
        campaignStatus.value = CampaignStatus.ongoingDeclined;
        return;
      }
    }

    if (_isNewOffer) {
      campaignStatus.value = CampaignStatus.newOffer;
      return;
    }

    if (list.isEmpty) {
      campaignStatus.value = CampaignStatus.accepted;
      return;
    }

    final allTodo = list.every((m) => m.status == MilestoneStatus.todo);
    final allPaidOrPartial = list.every(
      (m) =>
          m.status == MilestoneStatus.paid ||
          m.status == MilestoneStatus.partialPaid,
    );
    final somePaidOrPartial = list.any(
      (m) =>
          m.status == MilestoneStatus.paid ||
          m.status == MilestoneStatus.partialPaid,
    );
    final anyDeclined = list.any((m) => m.status == MilestoneStatus.declined);

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

  void _applyCampaignTextAndAssets(Map<String, dynamic> raw) {
    campaignGoalsText.value =
        (raw['campaignGoals'] ?? raw['productServiceDetails'] ?? '')
            .toString()
            .trim();

    contentRequirements.assignAll(_contentRequirementLines(raw));
    dosLines.assignAll(_splitLines(raw['dos']?.toString()));
    dontsLines.assignAll(_splitLines(raw['donts']?.toString()));
    reportingRequirementLines.assignAll(
      _splitLines(raw['reportingRequirements']?.toString()),
    );
    usageRightLines.assignAll(_splitLines(raw['usageRights']?.toString()));

    final assets = (raw['assets'] as List?) ?? const [];
    final mappedContent = <JobAsset>[];
    final mappedBrand = <BrandAsset>[];

    for (final item in assets) {
      if (item is! Map) continue;
      final e = Map<String, dynamic>.from(item);
      final category = e['category']?.toString().toLowerCase().trim();
      final fileName = e['fileName']?.toString().trim();
      final fileUrl = e['fileUrl']?.toString().trim();
      final mime = e['mimeType']?.toString().trim();
      final fileSize = _toInt(e['fileSize']) ?? 0;

      final displayTitle = (fileName != null && fileName.isNotEmpty)
          ? fileName
          : (e['assetType']?.toString().trim().isNotEmpty == true
                ? e['assetType'].toString().trim()
                : 'Asset');

      if (category == 'brand') {
        mappedBrand.add(
          BrandAsset(
            title: displayTitle,
            value: (fileUrl != null && fileUrl.isNotEmpty) ? fileUrl : null,
          ),
        );
      } else {
        mappedContent.add(
          JobAsset(
            title: displayTitle,
            meta: _assetMeta(mime: mime, fileSize: fileSize),
            kind: _assetKindFrom(mime: mime, name: fileName),
            pathOrUrl: (fileUrl != null && fileUrl.isNotEmpty) ? fileUrl : null,
          ),
        );
      }
    }

    contentAssetsUi.assignAll(mappedContent);
    brandAssetsUi.assignAll(mappedBrand);
  }

  void _derivePlatformsFromMilestones(List<Milestone> list) {
    final keys = list
        .map((m) => (m.platform ?? '').trim().toLowerCase())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList(growable: false);
    platformKeys.assignAll(keys);
  }

  List<String> _splitLines(String? text) {
    if (text == null || text.trim().isEmpty) return const [];
    return text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _contentRequirementLines(Map<String, dynamic> raw) {
    final milestones = (raw['milestones'] as List?) ?? const [];
    final lines = milestones
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => e['contentQuantity']?.toString().trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList(growable: false);
    return lines;
  }

  String _assetMeta({String? mime, required int fileSize}) {
    final parts = <String>[];
    if (mime != null && mime.trim().isNotEmpty) {
      parts.add(mime.trim().toUpperCase());
    }
    if (fileSize > 0) {
      parts.add(_formatBytes(fileSize));
    }
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  JobAssetKind _assetKindFrom({String? mime, String? name}) {
    final value = ((mime ?? '') + ' ' + (name ?? '')).toLowerCase();
    if (value.contains('image') ||
        value.endsWith('.png') ||
        value.endsWith('.jpg') ||
        value.endsWith('.jpeg') ||
        value.endsWith('.webp')) {
      return JobAssetKind.image;
    }
    if (value.contains('video') ||
        value.endsWith('.mp4') ||
        value.endsWith('.mov') ||
        value.endsWith('.webm')) {
      return JobAssetKind.video;
    }
    if (value.contains('pdf') ||
        value.contains('document') ||
        value.endsWith('.pdf') ||
        value.endsWith('.doc') ||
        value.endsWith('.docx')) {
      return JobAssetKind.document;
    }
    return JobAssetKind.other;
  }

  String _formatBytes(int bytes) {
    const k = 1024;
    if (bytes < k) return '$bytes B';

    final kb = bytes / k;
    if (kb < k) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';

    final mb = kb / k;
    if (mb < k) return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';

    final gb = mb / k;
    return '${gb.toStringAsFixed(gb < 10 ? 1 : 0)} GB';
  }

  String get deadlineMainText => localizeDaysRemainingFromDue(job.dueLabel);

  bool get showQuoteCard => campaignStatus.value == CampaignStatus.newOffer;
  bool get showAgreementBar => campaignStatus.value == CampaignStatus.newOffer;

  JobItem _copyJob(
    JobItem base, {
    String? title,
    String? clientName,
    String? dueLabel,
    double? budget,
    int? sharePercent,
    String? vatLabel,
    String? totalCostLabel,
    String? profitLabel,
    String? totalEarningsLabel,
    List<Milestone>? milestones,
  }) {
    return JobItem(
      id: base.id,
      title: title ?? base.title,
      subTitle: base.subTitle,
      clientName: (clientName ?? base.clientName).trim(),
      campaignType: base.campaignType,
      dateLabel: base.dateLabel,
      budget: budget ?? base.budget,
      sharePercent: sharePercent ?? base.sharePercent,
      progressPercent: base.progressPercent,
      dueInDays: base.dueInDays,
      dueLabel: dueLabel ?? base.dueLabel,
      rating: base.rating,
      profitLabel: profitLabel ?? base.profitLabel,
      vatLabel: vatLabel ?? base.vatLabel,
      totalCostLabel: totalCostLabel ?? base.totalCostLabel,
      totalEarningsLabel: totalEarningsLabel ?? base.totalEarningsLabel,
      baseBudget: base.baseBudget,
      vatPercent: base.vatPercent,
      vatAmount: base.vatAmount,
      netPayableBudget: base.netPayableBudget,
      contentAssets: base.contentAssets,
      brandAssets: base.brandAssets,
      needToSendSample: base.needToSendSample,
      sampleGuidelinesConfirmed: base.sampleGuidelinesConfirmed,
      milestones: milestones ?? base.milestones,
      dosText: base.dosText,
      dontsText: base.dontsText,
    );
  }

  Milestone _mapMilestone(Map<String, dynamic> json, int index) {
    final title =
        json['title']?.toString().trim() ??
        json['contentTitle']?.toString().trim() ??
        'Milestone';

    final dayIndex = _toInt(json['deliveryDays']);
    final dayLabel = dayIndex == null ? null : 'Day $dayIndex';

    return Milestone(
      id: json['id']?.toString(),
      stepLabel: '${index + 1}',
      title: title,
      amountLabel: _amountLabelFrom(json['amount']),
      dayIndex: dayIndex,
      dayLabel: dayLabel,
      deliverable: json['contentQuantity']?.toString(),
      platform: json['platform']?.toString(),
      targets: PromotionTarget(
        reach: _toInt(json['expectedReach']),
        views: _toInt(json['expectedViews']),
        likes: _toInt(json['expectedLikes']),
        comments: _toInt(json['expectedComments']),
      ),
      status: _parseMilestoneStatus(json['status']?.toString()),
    );
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
      case 'completed':
        return MilestoneStatus.approved;
      case 'partial_paid':
      case 'partialpaid':
        return MilestoneStatus.partialPaid;
      case 'declined':
        return MilestoneStatus.declined;
      case 'pending':
      case 'to_do':
      case 'todo':
      default:
        return MilestoneStatus.todo;
    }
  }

  String _amountLabelFrom(dynamic value) {
    final v = _toDouble(value);
    if (v > 0) return formatCurrencyByLocale(v);
    if (value is String && value.trim().isNotEmpty) return value;
    return '—';
  }

  Map<String, dynamic> _extractDataMap(dynamic response) {
    if (response is! Map) return <String, dynamic>{};
    final map = Map<String, dynamic>.from(response as Map);
    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data as Map);
    }
    return map;
  }

  String _clientNameFrom(Map<String, dynamic> raw) {
    final client = raw['client'];
    if (client is Map && client['brandName'] != null) {
      final name = client['brandName'].toString().trim();
      if (name.isNotEmpty) return name;
    }

    final brandName = raw['brandName']?.toString().trim();
    if (brandName != null && brandName.isNotEmpty) return brandName;

    final current = job.clientName.trim();
    if (current.isNotEmpty) return current;
    return '—';
  }

  double _budgetFromInfluencer(Map<String, dynamic> raw) {
    final offered = _toDouble(raw['offeredAmount']);
    final total = _toDouble(raw['totalAmount']);
    if (offered > 0) return offered;
    if (total > 0) return total;
    return job.budget;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
    }
    return 0;
  }

  String? _buildDueLabel(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return job.dueLabel;
    final deadline = DateTime.tryParse(isoDate);
    if (deadline == null) return job.dueLabel;

    final now = DateTime.now();
    final d1 = DateTime(now.year, now.month, now.day);
    final d2 = DateTime(deadline.year, deadline.month, deadline.day);
    final days = d2.difference(d1).inDays;

    if (days < 0) return '0 days';
    return '$days days';
  }

  bool _isNewOfferFromStatus(String? status, {required bool fallback}) {
    final s = (status ?? '').trim().toLowerCase();
    if (s.isEmpty) return fallback;

    const pendingStatuses = {
      'new_offer',
      'pending',
      'pending_agency',
      'pending_influencer',
      'invited',
      'offer_sent',
      'received',
      'negotiating',
      'quoted',
    };

    if (pendingStatuses.contains(s)) return true;

    const acceptedStatuses = {
      'active',
      'ongoing',
      'in_progress',
      'completed',
      'complete',
      'declined',
      'cancelled',
    };

    if (acceptedStatuses.contains(s)) return false;

    return fallback;
  }

  bool _isNonEmpty(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}

class _WithdrawalSuccessDialog extends StatelessWidget {
  final String title;
  final String amount;

  const _WithdrawalSuccessDialog({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.close,
                  size: 24.sp,
                  color: AppPalette.secondary,
                ),
              ),
            ),
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: AppPalette.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 45.sp, color: Colors.white),
            ),
            SizedBox(height: 24.h),
            Text(
              'campaign_withdraw_sent'.tr,
              textAlign: TextAlign.center,
              style: AppTheme.textStyle.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'campaign_withdraw_msg'.tr,
              textAlign: TextAlign.center,
              style: AppTheme.textStyle.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.primary,
              ),
            ),
            SizedBox(height: 26.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppPalette.primary, AppPalette.secondary],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'campaign_details_title'.tr,
                          style: AppTheme.textStyle.copyWith(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: AppTheme.textStyle.copyWith(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: Colors.white.withOpacity(0.5), height: 1),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'campaign_total_earnings'.tr,
                          style: AppTheme.textStyle.copyWith(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Text(
                        amount,
                        style: AppTheme.textStyle.copyWith(
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
