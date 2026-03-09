import 'dart:async';
import 'dart:developer' as dev;

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
import 'widgets/agency_requote_dialog.dart';

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

  final withdrawPaidCount = 0.obs;
  final withdrawApprovedAmount = 0.0.obs;
  final withdrawAvailableAmount = 0.0.obs;
  final isWithdrawalLoading = false.obs;

  final influencerJobCampaignId = RxnString();

  final isCampaignRated = false.obs;
  final campaignRating = 0.0.obs;

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

  // ---------------- Requote countdown (Agency only) ----------------
  Timer? _requoteTimer;
  DateTime? _requoteDeadlineUtc; // updatedAt + 12h (UTC)

  final requoteRemaining = Duration.zero.obs;
  final isRequoteExpired = true.obs;

  String get requoteCountdownText {
    final d = requoteRemaining.value;
    final hours = d.inHours.clamp(0, 999);
    final mins = (d.inMinutes % 60).clamp(0, 59);
    final h = hours.toString().padLeft(2, '0');
    final m = mins.toString().padLeft(2, '0');
    return '$h H : $m M';
  }

  String get requoteDeadlineText {
    final dl = _requoteDeadlineUtc?.toLocal();
    if (dl == null) return '';
    return _formatDeadline(dl);
  }

  Future<void> refreshCampaignDetails() async {
    await _loadCampaignDetails();
  }

  void _startAgencyRequoteCountdownFromRemainingMinutes(int remainingMinutes) {
    final safeMinutes = remainingMinutes < 0 ? 0 : remainingMinutes;

    _requoteDeadlineUtc = DateTime.now().toUtc().add(
      Duration(minutes: safeMinutes),
    );

    _requoteTimer?.cancel();

    _tickRequote();

    _requoteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _tickRequote();
    });
  }

  void _tickRequote() {
    final deadline = _requoteDeadlineUtc;
    if (deadline == null) {
      requoteRemaining.value = Duration.zero;
      isRequoteExpired.value = true;
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final diff = deadline.difference(nowUtc);

    if (diff <= Duration.zero) {
      requoteRemaining.value = Duration.zero;
      isRequoteExpired.value = true;
      _requoteTimer?.cancel();
      _requoteTimer = null;
      return;
    }

    requoteRemaining.value = diff;
    isRequoteExpired.value = false;
  }

  String _formatDeadline(DateTime dt) {
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
    final m = months[dt.month - 1];
    final hour12 = (dt.hour % 12 == 0) ? 12 : (dt.hour % 12);
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m ${dt.day}, ${dt.year}, $hour12:$min$ampm';
  }

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
    if (isRequoteExpired.value) {
      Get.snackbar('Error', 'Requote time expired.');
      return;
    }

    if (!accountTypeService.isAdAgency) return;

    final campaignId = job.id?.trim();
    if (campaignId == null || campaignId.isEmpty) {
      Get.snackbar('Error', 'Missing campaign id.');
      return;
    }

    // ----- Open dialog & get user input -----
    final baseBudget = (job.baseBudget ?? job.totalCampaignSpent ?? job.budget)
        .toDouble();

    final initialPercent = (job.sharePercent > 0 ? job.sharePercent : 0);

    final initialDollar = _proposedDollarRate ?? (job.dollarRate ?? 122.37);

    final vatPercent = (job.vatPercent ?? 15).toDouble();
    final platformFeePercent = (job.platformFeePercent ?? 2).toDouble();

    final input = await Get.dialog<AgencyRequoteInput>(
      AgencyRequoteDialog(
        initialServiceFeePercent: initialPercent,
        initialDollarRate: initialDollar,
        baseBudget: baseBudget,
        vatPercent: vatPercent,
        platformFeePercent: platformFeePercent,
      ),
      barrierDismissible: true,
    );

    if (input == null) return;

    // store latest
    _proposedServiceFeePercent = input.serviceFeePercent;
    _proposedDollarRate = input.dollarRate;

    if (isRequoteLoading.value) return;
    isRequoteLoading.value = true;

    final Map<String, dynamic> payload = {
      'proposedServiceFeePercent': input.serviceFeePercent,
      'proposedDollarRate': input.dollarRate,
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

  Future<void> onWithdrawalRequest() async {
    if (!accountTypeService.isInfluencer) return;

    final campaignId = influencerJobCampaignId.value?.trim();
    if (campaignId == null || campaignId.isEmpty) {
      Get.snackbar('common_error'.tr, 'campaign_missing_id'.tr);
      return;
    }

    final amount = withdrawAvailableAmount.value;
    if (amount <= 0) {
      Get.snackbar('common_error'.tr, 'campaign_no_withdrawable_amount'.tr);
      return;
    }

    if (isWithdrawalLoading.value) return;
    isWithdrawalLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.requestInfluencerWithdrawal(
        campaignId: campaignId,
        amount: amount,
      ),
    );

    if (result.isSuccess) {
      // Refresh server values (paid/approved/available)
      await _loadInfluencerWithdrawableBalance(campaignId);

      Get.dialog(
        _WithdrawalSuccessDialog(
          title: job.title,
          amount: formatCurrencyByLocale(amount), // ✅ requested amount shown
        ),
        barrierDismissible: true,
      );
    }

    isWithdrawalLoading.value = false;
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
        isCampaignRated.value = false;
        campaignRating.value = 0.0;
        await _loadInfluencerJobDetails(id);
        if (influencerJobCampaignId.value != null) {
          await _loadInfluencerWithdrawableBalance(
            influencerJobCampaignId.value!,
          );
        }
      } else if (accountTypeService.isAdAgency) {
        await _loadAgencyCampaignDetails(id);
      }
    });

    if (!result.isSuccess && kDebugMode) {
      print('Failed to load campaign details for $id');
    }

    isPageRefreshing.value = false;
  }

  // ✅ NEW: extract `{success, data:{...}}` safely (also supports raw map without data)
  Map<String, dynamic> _extractDataMap(dynamic response) {
    if (response is! Map) return <String, dynamic>{};
    final map = Map<String, dynamic>.from(response as Map);
    final data = map['data'];
    if (data is Map) return Map<String, dynamic>.from(data as Map);
    return map;
  }

  // ✅ UPDATED: now handles your actual milestones response:
  // { success:true, data:{ jobId, campaignId, milestones:[...] } }
  List<dynamic> _extractMilestonesList(dynamic response) {
    // shapes:
    // 1) [ {...}, {...} ]
    // 2) { data: [ {...} ] }
    // 3) { data: { milestones: [ {...} ] } }
    // 4) { milestones: [ {...} ] }
    // 5) { success:true, data:{ milestones:[...] } }  ✅ covered by (3)

    if (response is List) return response;

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);

      final direct = map['milestones'];
      if (direct is List) return direct;

      final data = map['data'];
      if (data is List) return data;

      if (data is Map) {
        final dm = Map<String, dynamic>.from(data);
        final m = dm['milestones'];
        if (m is List) return m;
      }
    }

    return const [];
  }

  DateTime? _safeParseDate(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso.trim());
  }

  String _buildDueLabelFromDate(DateTime deadline) {
    final now = DateTime.now();
    final d1 = DateTime(now.year, now.month, now.day);
    final d2 = DateTime(deadline.year, deadline.month, deadline.day);
    final days = d2.difference(d1).inDays;
    if (days <= 0) return '0 days';
    return '$days days';
  }

  String _formatDateLabel(DateTime date) {
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
    final m = months[date.month - 1];
    return '$m ${date.day}, ${date.year}';
  }

  Future<void> _loadInfluencerWithdrawableBalance(String campaignId) async {
    final res = await _campaignService.fetchInfluencerWithdrawableBalance(
      campaignId: campaignId,
    );

    final data = _extractDataMap(res);
    final financials = data['financials'] is Map
        ? Map<String, dynamic>.from(data['financials'] as Map)
        : <String, dynamic>{};

    withdrawPaidCount.value = _toInt(financials['totalPaid']) ?? 0;
    withdrawApprovedAmount.value = _toDouble(financials['totalApproved']);
    withdrawAvailableAmount.value = _toDouble(
      financials['availableToWithdraw'],
    );
  }

  Milestone _mapInfluencerMilestone(Map<String, dynamic> json) {
    // backend uses 0-based order
    final order = _toInt(json['order']) ?? 0;

    final deliveryDays = _toInt(json['deliveryDays']);
    final dayLabel = deliveryDays == null ? null : 'Day $deliveryDays';

    final title = (json['contentTitle']?.toString().trim().isNotEmpty ?? false)
        ? json['contentTitle'].toString().trim()
        : 'Milestone';

    dev.log('$json', name: 'MilestoneMap:');

    return Milestone(
      id: json['id']?.toString(),
      stepLabel: '${order + 1}', // ✅ from backend order
      title: title,
      subtitle: json['contentQuantity']?.toString().trim().isEmpty == true
          ? null
          : json['contentQuantity']?.toString().trim(),
      amountLabel: _amountLabelFrom(json['amount']),
      dayIndex: deliveryDays,
      dayLabel: dayLabel,
      platform: json['platform']?.toString().trim(),
      deliverable: json['contentQuantity']?.toString().trim(),
      promotionGoal: json['promotionGoal']?.toString().trim(),
      targets: PromotionTarget(
        reach: _toInt(json['expectedReach']),
        views: _toInt(json['expectedViews']),
        likes: _toInt(json['expectedLikes']),
        comments: _toInt(json['expectedComments']),
      ),
      status: _parseMilestoneStatus(json['status']?.toString()),
      submissions:
          const [], // campaign.milestones has `submissions: []` but you can map later if needed
    );
  }

  Future<void> _loadInfluencerJobDetails(String jobId) async {
    // 1) Job details (this API returns: {success, data:{...job..., campaign:{...}}})
    final detailsRes = await _campaignService.fetchInfluencerJobDetails(
      jobId: jobId,
    );
    final root = _extractDataMap(detailsRes);

    final campaignRaw = root['campaign'];
    final campaign = (campaignRaw is Map)
        ? Map<String, dynamic>.from(campaignRaw as Map)
        : <String, dynamic>{};

    influencerJobCampaignId.value = campaign['id'];

    // 2) Milestones:
    // Prefer campaign.milestones (it already exists in your response)
    final campaignMilestonesRaw = root['milestones'];
    List<dynamic> milestoneList = (campaignMilestonesRaw is List)
        ? campaignMilestonesRaw
        : const [];

    // Fallback to separate endpoint if campaign.milestones missing/empty
    if (milestoneList.isEmpty) {
      final milestonesRes = await _campaignService.fetchInfluencerJobMilestones(
        jobId: jobId,
      );
      milestoneList = _extractMilestonesList(milestonesRes);
    }

    final mappedMilestones = milestoneList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(_mapInfluencerMilestone)
        .toList(growable: false);

    // 3) Dates
    // ✅ startingDate + duration => dueLabel countdown
    // ✅ dateLabel should show formatted startingDate (NOT endDate)
    final startIso = campaign['startingDate']?.toString().trim();
    final durationDays = _toInt(campaign['duration']) ?? 0;

    final startDate = _safeParseDate(startIso);
    final endDate = (startDate != null && durationDays > 0)
        ? startDate.add(Duration(days: durationDays))
        : null;

    final dueLabel = endDate != null
        ? _buildDueLabelFromDate(endDate)
        : job.dueLabel;
    final dateLabel = startDate != null
        ? _formatDateLabel(startDate)
        : job.dateLabel;

    // 4) Core fields mapping (IMPORTANT)
    final title =
        (campaign['campaignName']?.toString().trim().isNotEmpty ?? false)
        ? campaign['campaignName'].toString().trim()
        : job.title;

    final clientName = _clientNameFrom(campaign); // campaign.client.brandName ✅

    final budget = _budgetFromInfluencer(
      root,
    ); // uses root.offeredAmount/totalAmount ✅

    final sharePercent = (_toDouble(
      root['percentage'],
    )).round(); // "10.00" => 10 ✅

    final campaignTypeRaw = campaign['campaignType']
        ?.toString()
        .trim()
        .toLowerCase();
    final CampaignType mappedType = campaignTypeRaw == 'influencer_promotion'
        ? CampaignType.influencerPromotion
        : CampaignType.paidAd;

    // 5) Build updated JobItem (keeps existing optional fields)
    final updated = JobItem(
      id: root['id']?.toString() ?? job.id,
      title: title,
      subTitle: job.subTitle,
      clientName: clientName,
      campaignType: mappedType,
      dateLabel: dateLabel,
      budget: budget,
      sharePercent: sharePercent > 0 ? sharePercent : job.sharePercent,
      progressPercent: job.progressPercent,
      dueInDays: job.dueInDays,
      dueLabel: dueLabel,
      rating: _toDouble(root['rating']).round(), // "0.0" => 0
      profitLabel: job.profitLabel,
      vatLabel: job.vatLabel,
      totalCostLabel: job.totalCostLabel,
      totalEarningsLabel: job.totalEarningsLabel,

      // influencer specific
      needToSendSample: campaign['needSampleProduct'] == true,
      sampleGuidelinesConfirmed: job.sampleGuidelinesConfirmed,

      milestones: mappedMilestones,

      // brief
      dosText: campaign['dos']?.toString(),
      dontsText: campaign['donts']?.toString(),

      // keep existing quote fields etc.
      baseBudget: job.baseBudget,
      vatPercent: job.vatPercent,
      vatAmount: job.vatAmount,
      netPayableBudget: job.netPayableBudget,
      contentAssets: job.contentAssets,
      brandAssets: job.brandAssets,
      platformFeePercent: job.platformFeePercent,
      platformFeeAmount: job.platformFeeAmount,
      estimatedProfitAmount: job.estimatedProfitAmount,
      actualProfitAmount: job.actualProfitAmount,
      totalCampaignSpent: job.totalCampaignSpent,
      dollarRate: job.dollarRate,
      campaignSpentUsd: job.campaignSpentUsd,
      timeLeftToRequoteMinutes: job.timeLeftToRequoteMinutes,
    );

    // 6) Status flags (influencer job status is in root.status)
    final statusRaw = root['status']?.toString();
    _serverStatus = (statusRaw ?? '').trim().toLowerCase();
    _isNewOffer = _isNewOfferFromStatus(statusRaw, fallback: _isNewOffer);

    // 7) Assets + brief MUST come from campaign (not root)
    _applyInfluencerCampaignTextAndAssets(
      root: root,
      campaign: campaign,
      mappedMilestones: mappedMilestones,
    );

    jobRx.value = updated;
    milestones.assignAll(mappedMilestones);
    _recalculateStatus();
  }

  Future<void> _loadAgencyCampaignDetails(String campaignId) async {
    final res = await _campaignService.fetchAgencyCampaignDetails(
      campaignId: campaignId,
    );
    final raw = _extractDataMap(res);

    isCampaignRated.value = raw['isRated'] == true;
    campaignRating.value = _toDouble(raw['rating']);

    // ✅ Agency requote timer based on updatedAt (Agency only)
    final timeLeftToRequoteMinutes =
        _toInt(raw['timeLeftToRequoteMinutes']) ?? 0;

    if (accountTypeService.isAdAgency && timeLeftToRequoteMinutes > 0) {
      _startAgencyRequoteCountdownFromRemainingMinutes(
        timeLeftToRequoteMinutes,
      );
    } else if (accountTypeService.isAdAgency) {
      _requoteDeadlineUtc = null;
      requoteRemaining.value = Duration.zero;
      isRequoteExpired.value = true;
      _requoteTimer?.cancel();
      _requoteTimer = null;
    }

    final milestoneList = (raw['milestones'] as List?) ?? const [];
    final mappedMilestones = milestoneList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
        .asMap()
        .entries
        .map(
          (entry) => _mapMilestone(entry.value, entry.key),
        ) // keep existing agency mapper
        .toList(growable: false);

    final budgetBreakdown = raw['budgetBreakdown'] as Map<String, dynamic>?;

    final baseBudget = _toDouble(budgetBreakdown?['baseBudget']);
    final vatAmount = _toDouble(budgetBreakdown?['vat']);
    final totalBudget = _toDouble(budgetBreakdown?['totalBudget']);
    final platformFeeAmount = _toDouble(budgetBreakdown?['adminPlatformFee']);
    final estimatedProfitAmount = _toDouble(
      budgetBreakdown?['estimatedAgencyProfit'],
    );
    final netAvailableForAgency = _toDouble(
      budgetBreakdown?['netAvailableForAgency'],
    );

    final agencyProfitPercentage =
        ((estimatedProfitAmount + platformFeeAmount) / baseBudget) * 100;

    // VAT % derived from base+vat (fallback to 15 if not derivable)
    final double vatPercent = (baseBudget > 0 && vatAmount > 0)
        ? ((vatAmount / baseBudget) * 100)
        : 15;

    // Platform fee % derived from base+fee (fallback to 2 if not derivable)
    final double platformFeePercent = (baseBudget > 0 && platformFeeAmount > 0)
        ? ((platformFeeAmount / baseBudget) * 100)
        : 2;

    // ✅ Server gives "actual profit" already (profit after platform fee)
    final actualProfitAmount = estimatedProfitAmount > 0
        ? estimatedProfitAmount
        : 0;

    // ✅ "Your Profit" (before fee) = actual profit + platform fee
    final yourProfitBeforeFee =
        (actualProfitAmount) + (platformFeeAmount > 0 ? platformFeeAmount : 0);

    // Dollar conversion (optional; backend currently doesn't send it in your response)
    final dollarRate = _toDouble(
      raw['proposedDollarRate'] ?? 122.37,
    ); // if exists
    final totalCampaignSpent = totalBudget > 0
        ? totalBudget
        : null; // best available from API now
    final campaignSpentUsd = (totalCampaignSpent != null && dollarRate > 0)
        ? (totalCampaignSpent / dollarRate)
        : null;

    final serviceFeeRaw =
        raw['proposedServiceFeePercent'] ??
        budgetBreakdown?['proposedServiceFeePercent'];
    _proposedServiceFeePercent = _toDouble(serviceFeeRaw).round();
    _proposedDollarRate = dollarRate > 0 ? dollarRate : null;

    final updated = _copyJob(
      job,
      title: (raw['campaignName'] as String?)?.trim(),
      clientName: _clientNameFrom(raw),
      dueLabel: _buildDueLabel(raw['duration']?.toString()),

      // main visible numbers
      budget: totalBudget > 0 ? totalBudget : job.budget,
      sharePercent: agencyProfitPercentage.toInt(),

      // existing labels (keep)
      vatLabel: vatAmount > 0 ? formatCurrencyByLocale(vatAmount) : null,
      totalCostLabel: totalBudget > 0
          ? formatCurrencyByLocale(totalBudget)
          : null,
      profitLabel: estimatedProfitAmount > 0
          ? formatCurrencyByLocale(estimatedProfitAmount)
          : null,
      totalEarningsLabel: netAvailableForAgency > 0
          ? formatCurrencyByLocale(netAvailableForAgency)
          : null,

      milestones: mappedMilestones,
    );

    // ✅ Create a JobItem with new optional fields filled
    final updatedWithQuote = JobItem(
      id: updated.id,
      title: updated.title,
      subTitle: updated.subTitle,
      clientName: updated.clientName,
      campaignType: updated.campaignType,
      dateLabel: updated.dateLabel,
      budget: updated.budget,
      sharePercent: updated.sharePercent,
      progressPercent: updated.progressPercent,
      dueInDays: updated.dueInDays,
      dueLabel: updated.dueLabel,
      rating: campaignRating.value.round(),
      profitLabel: updated.profitLabel,
      vatLabel: updated.vatLabel,
      totalCostLabel: updated.totalCostLabel,
      totalEarningsLabel: updated.totalEarningsLabel,
      baseBudget: baseBudget > 0 ? baseBudget : null,
      vatPercent: vatPercent,
      vatAmount: vatAmount > 0 ? vatAmount : null,
      netPayableBudget: totalBudget > 0 ? totalBudget : null,
      contentAssets: updated.contentAssets,
      brandAssets: updated.brandAssets,
      needToSendSample: updated.needToSendSample,
      sampleGuidelinesConfirmed: updated.sampleGuidelinesConfirmed,
      milestones: updated.milestones,
      dosText: updated.dosText,
      dontsText: updated.dontsText,

      // ✅ NEW
      platformFeePercent: platformFeePercent,
      platformFeeAmount: platformFeeAmount > 0 ? platformFeeAmount : null,
      // ✅ Your profit (before fee)
      estimatedProfitAmount: yourProfitBeforeFee > 0
          ? yourProfitBeforeFee.toDouble()
          : null,

      // ✅ Actual profit (after fee) from server
      actualProfitAmount: actualProfitAmount > 0
          ? actualProfitAmount.toDouble()
          : null,
      totalCampaignSpent: totalCampaignSpent,
      dollarRate: dollarRate > 0 ? dollarRate : null,
      campaignSpentUsd: campaignSpentUsd,
    );

    jobRx.value = updatedWithQuote;
    final statusRaw = raw['status']?.toString();
    _serverStatus = (statusRaw ?? '').trim().toLowerCase();
    _isNewOffer = _isNewOfferFromStatus(statusRaw, fallback: _isNewOffer);

    _applyCampaignTextAndAssets(raw);
    _derivePlatformsFromMilestones(mappedMilestones);
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
      if (_serverStatus.contains('agency_accepted')) {
        campaignStatus.value = CampaignStatus.accepted;
        return;
      }
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

  void _applyInfluencerCampaignTextAndAssets({
    required Map<String, dynamic> root,
    required Map<String, dynamic> campaign,
    required List<Milestone> mappedMilestones,
  }) {
    // --- Brief / text fields come from nested campaign ---
    campaignGoalsText.value =
        (campaign['campaignGoals'] ?? campaign['productServiceDetails'] ?? '')
            .toString()
            .trim();

    // ✅ Influencer content requirements should come from influencer response milestones
    // Format: "platform - contentQuantity"
    contentRequirements.assignAll(
      _contentRequirementLinesFromInfluencerMilestones(root['milestones']),
    );

    dosLines.assignAll(_splitLines(campaign['dos']?.toString()));
    dontsLines.assignAll(_splitLines(campaign['donts']?.toString()));
    reportingRequirementLines.assignAll(
      _splitLines(campaign['reportingRequirements']?.toString()),
    );
    usageRightLines.assignAll(_splitLines(campaign['usageRights']?.toString()));

    // --- Assets come from campaign.assets ---
    final assets = (campaign['assets'] as List?) ?? const [];
    final mappedContent = <JobAsset>[];
    final mappedBrand = <BrandAsset>[];

    for (final item in assets) {
      if (item is! Map) continue;

      final e = Map<String, dynamic>.from(item);
      final category = e['category']?.toString().toLowerCase().trim();
      final fileName = e['fileName']?.toString().trim();
      final description = e['description']?.toString().trim();
      final fileUrl = e['fileUrl']?.toString().trim();
      final mime = e['mimeType']?.toString().trim();
      final fileSize = _toInt(e['fileSize']) ?? 0;

      final displayTitle = (description != null && description.isNotEmpty)
          ? description
          : (fileName != null && fileName.isNotEmpty)
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

    // platform chips from already mapped milestones (safer than raw)
    _derivePlatformsFromMilestones(mappedMilestones);
  }

  List<String> _contentRequirementLinesFromInfluencerMilestones(
    dynamic rawMilestones,
  ) {
    final list = (rawMilestones as List?) ?? const [];

    final lines = <String>[];

    for (final item in list) {
      if (item is! Map) continue;
      final e = Map<String, dynamic>.from(item);

      final platform = e['platform']?.toString().trim() ?? '';
      final quantity = e['contentQuantity']?.toString().trim() ?? '';

      if (platform.isEmpty && quantity.isEmpty) continue;
      if (platform.isNotEmpty && quantity.isNotEmpty) {
        lines.add('$platform - $quantity');
      } else {
        lines.add(platform.isNotEmpty ? platform : quantity);
      }
    }

    // de-duplicate while preserving order
    return lines.toSet().toList(growable: false);
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
      final description = e['description']?.toString().trim();
      final fileUrl = e['fileUrl']?.toString().trim();
      final mime = e['mimeType']?.toString().trim();
      final fileSize = _toInt(e['fileSize']) ?? 0;

      final displayTitle = (description != null && description.isNotEmpty)
          ? description
          : (e['fileName']?.toString().trim().isNotEmpty == true
                ? e['fileName'].toString().trim()
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
        .map(
          (e) =>
              '${e['platform']?.toString().trim()} - ${e['contentQuantity']?.toString().trim()}',
        )
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
  bool get showAgreementBar =>
      campaignStatus.value == CampaignStatus.newOffer &&
      !(accountTypeService.isAdAgency && _serverStatus == 'agency_negotiating');
  bool get showAgencyNegotiatingCard =>
      accountTypeService.isAdAgency && _serverStatus == 'agency_negotiating';

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

  // ✅ Keep this for agency milestones (they may include platform/reach/views)
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
      subtitle: json['contentQuantity']?.toString(),
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

  // ✅ UPDATED: null/empty -> todo
  MilestoneStatus _parseMilestoneStatus(String? raw) {
    final v = (raw ?? '').trim().toLowerCase();
    if (v.isEmpty) return MilestoneStatus.todo;

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

  @override
  void onClose() {
    _requoteTimer?.cancel();
    _requoteTimer = null;
    super.onClose();
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
