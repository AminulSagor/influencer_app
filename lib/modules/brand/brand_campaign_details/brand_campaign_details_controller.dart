import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/payment_webview_page.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/widgets/influencer_milestone_picker_sheet.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/job_item.dart';
import '../../../core/services/campaign_service.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../ad_agency/services/upload_service.dart';
import '../create_campaign/create_campaign_controller.dart';
import '../../../core/services/api_error_handler.dart';
import 'widgets/confirm_budget_dialog.dart';
import 'widgets/fund_campaign_dialog.dart';
import 'widgets/paid_ad_requote_dialog.dart';
import 'widgets/provide_rating_dialog.dart';
import 'widgets/requote_dialog.dart';
import 'widgets/upload_another_asset_dialog.dart';
import 'widgets/upload_another_brand_asset_dialog.dart';
import 'package:path/path.dart' as path;

class BrandAssetLink {
  final String? assetId;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? url;

  const BrandAssetLink({
    this.assetId,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.url,
  });
}

class PaidAdAgencyOffer {
  final String agencyId;
  final String name;
  final String logo;
  final int agencyFeePercent; // e.g. 10
  final int totalPayableExcludingFee;
  final double dollarRate;

  const PaidAdAgencyOffer({
    required this.agencyId,
    required this.name,
    required this.logo,
    this.agencyFeePercent = 10,
    this.totalPayableExcludingFee = 0,
    this.dollarRate = 0,
  });
}

class AssignedInfluencerUi {
  final String assignmentId;
  final String influencerId;
  final String name;
  final String? image;
  final String locationText;
  final String status;
  final double offeredAmount;

  /// Raw assignedWork list from API for this influencer
  final List<Map<String, dynamic>> assignedWork;

  const AssignedInfluencerUi({
    required this.assignmentId,
    required this.influencerId,
    required this.name,
    this.image,
    required this.locationText,
    required this.status,
    required this.offeredAmount,
    required this.assignedWork,
  });
}

class RateInfluencerItem {
  final String influencerId;
  final String name;
  final String? image;

  final RxInt rating;
  final RxBool isExpanded;
  final RxBool isAlreadyRated;
  final Rxn<DateTime> ratedAt;

  RateInfluencerItem({
    required this.influencerId,
    required this.name,
    this.image,
    int initialRating = 0,
    bool expanded = false,
    bool alreadyRated = false,
    DateTime? ratedAtValue,
  }) : rating = initialRating.obs,
       isExpanded = expanded.obs,
       isAlreadyRated = alreadyRated.obs,
       ratedAt = Rxn<DateTime>(ratedAtValue);
}

enum CampaignProgressStep { submitted, quoted, paid, promoting, completed }

class BrandCampaignDetailsController extends GetxController {
  final CampaignService _campaignService = Get.find<CampaignService>();

  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  final paidAdTabIndex = 1.obs;
  final RxBool isInitialLoading = false.obs;
  void setPaidAdTab(int i) => paidAdTabIndex.value = i.clamp(0, 1);

  final isSortLowToHigh = true.obs;

  final page = 1.obs;
  final totalPages = 1.obs;
  final agencyBidsLimit = 10.obs;
  final totalAgencyBids = 0.obs;

  final agencyOffers = <PaidAdAgencyOffer>[].obs;

  final dynamic arguments;
  BrandCampaignDetailsController(this.arguments);

  JobItem? job;

  final UploadService _uploadService = Get.find<UploadService>();

  final campaignType = ''.obs;

  bool get isPaidAd {
    final apiType = campaignType.value.trim().toLowerCase();
    if (apiType.isNotEmpty) {
      return apiType == 'paidad' ||
          apiType == 'paid_ad' ||
          apiType == 'paid-ad';
    }

    final j = job;
    if (j != null) {
      return j.campaignType == CampaignType.paidAd;
    }

    return false;
  }

  bool get isPendingAgency {
    return isPaidAd && campaignStatus.value.contains('pending_agency');
  }

  bool get isAgencyAccepet {
    return isPaidAd && campaignStatus.value.contains('agency_accepted');
  }

  final campaignTitle = ''.obs;
  final budgetText = ''.obs;
  final influencers = <String>[].obs;
  final platformKeys = <String>[].obs;
  final daysRemaining = 0.obs;
  final deadlineDateText = ''.obs;
  final campaignStatus = ''.obs;
  final budgetStatusText = 'brand_campaign_details_budget_pending'.tr.obs;
  final paymentStatus = ''.obs;
  final dueAmount = 0.obs;
  final paidAmount = 0.obs;
  final RxnString selectedInfluencerId = RxnString();
  final progressStep = CampaignProgressStep.submitted.obs;
  final baseBudget = 0.obs;
  final vatAmount = 0.obs;
  int get totalCost => baseBudget.value + vatAmount.value;
  final isYourTurn = false.obs;
  final showDueButton = false.obs;
  final milestones = <Milestone>[].obs;
  final milestoneStatusLabel =
      'brand_campaign_details_campaign_not_started'.tr.obs;
  final operationalProgressText = '0%'.obs;
  final masterMilestones = <Milestone>[].obs;
  final assignedInfluencers = <AssignedInfluencerUi>[].obs;
  final RxnString selectedAssignmentId = RxnString();
  final isRated = false.obs;
  final rating = 0.0.obs;
  final campaignGoals = ''.obs;
  final productServiceDetails = ''.obs;
  final contentRequirements = <String>[].obs;
  final dosText = ''.obs;
  final dontsText = ''.obs;
  final contentAssets = <JobAsset>[].obs;
  final reportingRequirements = ''.obs;
  final usageRights = ''.obs;
  final brandAssets = <BrandAssetLink>[].obs;
  final isLoading = false.obs;
  final loadError = RxnString();
  final briefExpanded = true.obs;
  final assetsExpanded = true.obs;
  final termsExpanded = true.obs;
  final milestonesExpanded = true.obs;
  final RxList<RateInfluencerItem> rateInfluencerItems =
      <RateInfluencerItem>[].obs;
  final RxInt agencyDialogRating = 0.obs;
  final RxBool isSubmittingRatings = false.obs;
  final dangerZoneExpanded = false.obs;
  final cancelReasonCtrl = TextEditingController();
  final isSubmittingCancellation = false.obs;
  final RxnString selectedAgencyOfferId = RxnString();

  final RxBool isOpeningPaymentFlow = false.obs;
  final RxBool isPayNowLoading = false.obs;
  final RxBool isAcceptQuoteLoading = false.obs;

  final RxnString payingAgencyOfferId = RxnString();

  final RxBool hasLoadedOnce = false.obs;

  final ScrollController pageScrollController = ScrollController();

  bool _isBlockingLoaderVisible = false;

  bool get areAllInfluencersAlreadyRated {
    if (rateInfluencerItems.isEmpty) return false;
    return rateInfluencerItems.every((e) => e.isAlreadyRated.value);
  }

  @override
  void onInit() {
    super.onInit();

    _readMetaArgs(arguments);

    final argJob = _extractJob(arguments);
    if (argJob != null) {
      job = argJob;
      _loadFromJob(argJob);
      _loadFromApiIfPossible();
    } else if (Get.isRegistered<CreateCampaignController>()) {
      final c = Get.find<CreateCampaignController>();
      _loadFromCreateCampaign(c);
      _loadFromApiIfPossible();
    } else {
      _loadFromApiIfPossible();
    }

    _listenCampaignNotifications();
  }

  void _showBlockingLoader() {
    if (_isBlockingLoaderVisible) return;

    _isBlockingLoaderVisible = true;

    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _hideBlockingLoader() async {
    if (!_isBlockingLoaderVisible) return;

    if (Get.isDialogOpen == true) {
      Get.back();
      await Future.delayed(const Duration(milliseconds: 120));
    }

    _isBlockingLoaderVisible = false;
  }

  String _paymentMessageFromResponse(
    Map<String, dynamic> response,
    String fallback,
  ) {
    final msg = response['message']?.toString().trim();
    if (msg != null && msg.isNotEmpty) return msg;

    final data = response['data'];
    if (data is Map) {
      final nestedMsg = data['message']?.toString().trim();
      if (nestedMsg != null && nestedMsg.isNotEmpty) return nestedMsg;
    }

    return fallback;
  }

  String? _extractGatewayUrl(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      final url = data['gatewayUrl']?.toString().trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  String? _extractTranId(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      final tranId = data['tranId']?.toString().trim();
      if (tranId != null && tranId.isNotEmpty) return tranId;
    }
    return null;
  }

  Future<void> _openPaymentGateway({
    required String gatewayUrl,
    required String tranId,
    required String successMessage,
    required String failMessage,
  }) async {
    final result = await Get.to<bool>(
      () => PaymentWebViewPage(
        initialUrl: gatewayUrl,
        successUrl:
            'https://influencerbackend-production.up.railway.app/payments/sslcommerz/success',
        failUrl:
            'https://influencerbackend-production.up.railway.app/payments/sslcommerz/fail',
        initialTranId: tranId,
        checkPaymentStatus: (tranId) =>
            _campaignService.fetchPaymentStatus(tranId: tranId),
      ),
    );

    if (result == true) {
      await refreshCampaignDetails();
      AppSnackbar.showSuccessSnackbar(
        title: 'Success',
        message: successMessage,
      );
    } else if (result == false) {
      AppSnackbar.showErrorSnackbar(title: 'Error', message: failMessage);
    }
  }

  Future<void> payCampaignNow({required int amount}) async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    if (isPayNowLoading.value || isOpeningPaymentFlow.value) return;

    try {
      isPayNowLoading.value = true;
      isOpeningPaymentFlow.value = true;

      if (Get.isDialogOpen == true) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 120));
      }

      _showBlockingLoader();

      final response = await _campaignService.payCampaignAmount(
        campaignId: campaignId,
        amount: amount,
      );

      await _hideBlockingLoader();

      final gatewayUrl = _extractGatewayUrl(response);
      final tranId = _extractTranId(response);

      if (gatewayUrl == null) {
        AppSnackbar.showErrorSnackbar(
          title: 'Error',
          message: 'Payment URL not found.',
        );
        return;
      }

      if (tranId == null) {
        AppSnackbar.showErrorSnackbar(
          title: 'Error',
          message: 'Transaction id not found.',
        );
        return;
      }

      final message = _paymentMessageFromResponse(
        response,
        'Payment session created successfully.',
      );

      await _openPaymentGateway(
        gatewayUrl: gatewayUrl,
        tranId: tranId,
        successMessage: message,
        failMessage: 'Payment failed.',
      );
    } catch (e) {
      await _hideBlockingLoader();
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
    } finally {
      isPayNowLoading.value = false;
      isOpeningPaymentFlow.value = false;
    }
  }

  Future<void> payCampaignDueNow({required int amount}) async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    if (isPayNowLoading.value || isOpeningPaymentFlow.value) return;

    try {
      isPayNowLoading.value = true;
      isOpeningPaymentFlow.value = true;

      _showBlockingLoader();

      final response = await _campaignService.payCampaignDue(
        campaignId: campaignId,
        amount: amount,
      );

      _hideBlockingLoader();

      final gatewayUrl = _extractGatewayUrl(response);
      final tranId = _extractTranId(response);

      if (gatewayUrl == null) {
        AppSnackbar.showErrorSnackbar(
          title: 'Error',
          message: 'Payment URL not found.',
        );
        return;
      }

      if (tranId == null) {
        AppSnackbar.showErrorSnackbar(
          title: 'Error',
          message: 'Transaction id not found.',
        );
        return;
      }

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final message = _paymentMessageFromResponse(
        response,
        'Due payment session created successfully.',
      );

      await _openPaymentGateway(
        gatewayUrl: gatewayUrl,
        tranId: tranId,
        successMessage: message,
        failMessage: 'Due payment failed.',
      );
    } catch (e) {
      _hideBlockingLoader();
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
    } finally {
      isPayNowLoading.value = false;
      isOpeningPaymentFlow.value = false;
    }
  }

  void _listenCampaignNotifications() {
    _notificationSubscription?.cancel();

    _notificationSubscription = FirebaseMessagingService.notificationStream
        .listen((data) async {
          final notificationCampaignId =
              data['campaignId']?.toString().trim() ?? '';
          final notificationMilestoneId =
              data['milestoneId']?.toString().trim() ?? '';

          final currentCampaignId = _extractCampaignId(arguments)?.trim() ?? '';

          final currentMilestoneIds = <String>{
            ...milestones
                .map((e) => (e.id ?? '').trim())
                .where((e) => e.isNotEmpty),
            ...masterMilestones
                .map((e) => (e.id ?? '').trim())
                .where((e) => e.isNotEmpty),
          };

          final bool campaignMatched =
              notificationCampaignId.isNotEmpty &&
              currentCampaignId.isNotEmpty &&
              notificationCampaignId == currentCampaignId;

          final bool milestoneMatched =
              notificationMilestoneId.isNotEmpty &&
              currentMilestoneIds.contains(notificationMilestoneId);

          if (!campaignMatched && !milestoneMatched) {
            return;
          }

          dev.log(
            'Matched notification. Refreshing brand campaign details page.',
            name: 'BrandCampaignDetailsController',
            error: {
              'currentCampaignId': currentCampaignId,
              'notificationCampaignId': notificationCampaignId,
              'notificationMilestoneId': notificationMilestoneId,
            },
          );

          await refreshCampaignDetails();
        });
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    cancelReasonCtrl.dispose();
    pageScrollController.dispose();
    super.onClose();
  }

  Future<void> refreshCampaignDetails() async {
    if (isLoading.value) return;

    page.value = 1;
    loadError.value = null;

    await _loadFromApiIfPossible(isRefresh: true);
  }

  Future<void> refreshAfterMilestoneUpdate() async {
    await _loadFromApiIfPossible();
  }

  void toggleSort() {
    isSortLowToHigh.value = !isSortLowToHigh.value;

    /// TODO APPLY SORT
  }

  bool get showDangerZone {
    return progressStep.value == CampaignProgressStep.paid ||
        progressStep.value == CampaignProgressStep.promoting;
  }

  void toggleDangerZone() {
    dangerZoneExpanded.value = !dangerZoneExpanded.value;
  }

  //Agency quotations pagination
  Future<void> prevPage() async {
    if (!isPaidAd) return;
    if (isLoading.value) return;
    if (page.value <= 1) return;

    page.value--;

    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) return;

    await _loadAgencyBidsPage(campaignId);
  }

  Future<void> nextPage() async {
    if (!isPaidAd) return;
    if (isLoading.value) return;
    if (page.value >= totalPages.value) return;

    page.value++;

    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) return;

    await _loadAgencyBidsPage(campaignId);
  }

  Future<void> prepareInfluencerRatingsDialog() async {
    final items = assignedInfluencers
        .map(
          (e) => RateInfluencerItem(
            influencerId: e.influencerId,
            name: e.name,
            image: e.image,
          ),
        )
        .toList(growable: false);

    if (items.isNotEmpty) {
      items.first.isExpanded.value = false;
    }

    rateInfluencerItems.assignAll(items);

    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchCampaignRatings(campaignId: campaignId),
      showError: false,
    );

    if (!result.isSuccess || result.data == null) return;

    final ratingsResponse = result.data as CampaignRatingsResponse;
    final ratingMap = <String, CampaignInfluencerRatingItem>{
      for (final item in ratingsResponse.influencerRatings)
        item.influencerId: item,
    };

    for (final uiItem in rateInfluencerItems) {
      final existing = ratingMap[uiItem.influencerId];
      if (existing == null) continue;

      if (existing.isRated) {
        uiItem.rating.value = existing.rating.clamp(0, 5);
        uiItem.isAlreadyRated.value = true;
        uiItem.ratedAt.value = existing.ratedAt;
        uiItem.isExpanded.value = false;
      }
    }

    rateInfluencerItems.refresh();
  }

  void toggleInfluencerRatingExpand(int index) {
    for (int i = 0; i < rateInfluencerItems.length; i++) {
      rateInfluencerItems[i].isExpanded.value = i == index
          ? !rateInfluencerItems[i].isExpanded.value
          : false;
    }
  }

  void setInfluencerDialogRating({required int index, required int rating}) {
    if (index < 0 || index >= rateInfluencerItems.length) return;

    final item = rateInfluencerItems[index];
    if (item.isAlreadyRated.value) return;

    item.rating.value = rating.clamp(0, 5);
  }

  void setAgencyDialogRating(int value) {
    agencyDialogRating.value = value.clamp(0, 5);
  }

  void _derivePlatformsFromMilestones(List<Milestone> list) {
    final keys = list
        .map((m) => (m.platform ?? '').trim().toLowerCase())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList(growable: false);

    platformKeys.assignAll(keys);
  }

  // -------------------------
  // Args helpers
  // -------------------------

  void _recomputeMilestoneStatusLabel() {
    final list = milestones.toList(growable: false);
    if (list.isEmpty) {
      milestoneStatusLabel.value =
          'brand_campaign_details_campaign_not_started'.tr;
      return;
    }

    if (list.any((m) => m.status == MilestoneStatus.declined)) {
      milestoneStatusLabel.value = trOr(
        'brand_campaign_details_has_issues',
        'Has Issues',
      );
      return;
    }
    if (list.any((m) => m.status == MilestoneStatus.inReview)) {
      milestoneStatusLabel.value = trOr('ms_in_review', 'In Review');
      return;
    }
    if (list.every((m) => m.isApproved || m.isPaid)) {
      milestoneStatusLabel.value = trOr(
        'brand_campaign_details_completed',
        'Completed',
      );
      return;
    }

    milestoneStatusLabel.value = trOr(
      'brand_campaign_details_in_progress',
      'In Progress',
    );
  }

  void _readMetaArgs(dynamic args) {
    if (args is Map) {
      final ct = args['campaignType'];
      if (ct is String) campaignType.value = ct;
    }
  }

  JobItem? _extractJob(dynamic args) {
    if (args == null) return null;

    if (args is JobItem) return args;

    if (args is Map) {
      final v = args['job'];
      if (v is JobItem) return v;
    }

    return null;
  }

  String? _extractCampaignId(dynamic args) {
    if (args == null) return null;

    if (args is Map) {
      final v = args['campaignId'] ?? args['id'];
      if (v is String && v.trim().isNotEmpty) return v.trim();

      final jobArg = args['job'];
      if (jobArg is JobItem && jobArg.id?.isNotEmpty == true) {
        return jobArg.id;
      }
    }

    if (args is JobItem && args.id?.isNotEmpty == true) return args.id;
    if (job?.id?.isNotEmpty == true) return job?.id;
    return null;
  }

  // -------------------------
  // API loading
  // -------------------------

  Future<void> _loadFromApiIfPossible({bool isRefresh = false}) async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) return;

    final bool showInitialLoader = !hasLoadedOnce.value && !isRefresh;

    if (showInitialLoader) {
      isInitialLoading.value = true;
    }

    try {
      isLoading.value = true;
      loadError.value = null;

      final res = await _campaignService.fetchClientCampaignDetails(
        campaignId: campaignId,
      );

      final payload = (res['data'] is Map)
          ? Map<String, dynamic>.from(res['data'] as Map)
          : Map<String, dynamic>.from(res);

      _loadFromApiMap(payload);

      await _loadProgressByCampaignType(campaignId);
      await _loadNegotiationContext(campaignId);

      if (isPaidAd) {
        await _loadAgencyBidsPage(campaignId);
      } else {
        page.value = 1;
        totalPages.value = 1;
        totalAgencyBids.value = 0;
        agencyOffers.clear();
      }

      hasLoadedOnce.value = true;
    } catch (e) {
      loadError.value = e.toString();
    } finally {
      isLoading.value = false;
      if (showInitialLoader) {
        isInitialLoading.value = false;
      }
    }
  }

  Future<void> _loadAgencyBidsPage(String campaignId) async {
    if (!isPaidAd) {
      page.value = 1;
      totalPages.value = 1;
      totalAgencyBids.value = 0;
      agencyOffers.clear();
      return;
    }

    final response = await _campaignService.fetchClientAgencyBids(
      campaignId: campaignId,
      page: page.value,
      limit: agencyBidsLimit.value,
    );

    final bids = (response['data'] as List?) ?? const [];
    final pagination = response['pagination'] is Map
        ? Map<String, dynamic>.from(response['pagination'] as Map)
        : const <String, dynamic>{};

    totalAgencyBids.value = _numToInt(pagination['total']);
    totalPages.value = _numToInt(pagination['totalPages']) <= 0
        ? 1
        : _numToInt(pagination['totalPages']);

    final currentPage = _numToInt(pagination['page']);
    if (currentPage > 0) {
      page.value = currentPage;
    }

    final currentLimit = _numToInt(pagination['limit']);
    if (currentLimit > 0) {
      agencyBidsLimit.value = currentLimit;
    }

    agencyOffers.clear();

    final bidList = bids
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);

    if (bidList.isNotEmpty) {
      _loadAgencyBids(bidList);
    }
  }

  Future<void> _loadProgressByCampaignType(String campaignId) async {
    try {
      if (isPaidAd) {
        final progress = await _campaignService.fetchAgencyCampaignProgress(
          campaignId: campaignId,
        );
        _loadCampaignProgress(progress);
        return;
      }

      // influencer_promotion => progress is per selected influencer
      final influencerId = selectedInfluencerId.value?.trim();

      // If influencer not selected yet, try first assigned influencer
      if (influencerId == null || influencerId.isEmpty) {
        final firstInfluencerId = assignedInfluencers.isNotEmpty
            ? assignedInfluencers.first.influencerId.trim()
            : '';

        if (firstInfluencerId.isEmpty) {
          // no influencer yet, reset safe defaults
          operationalProgressText.value = '0%';
          return;
        }

        selectedInfluencerId.value = firstInfluencerId;
        final progress = await _campaignService.fetchInfluencerCampaignProgress(
          campaignId: campaignId,
          influencerId: firstInfluencerId,
        );
        _loadCampaignProgress(progress);
        return;
      }

      final progress = await _campaignService.fetchInfluencerCampaignProgress(
        campaignId: campaignId,
        influencerId: influencerId,
      );
      _loadCampaignProgress(progress);
    } catch (e) {
      debugPrint('[Progress API] failed: $e');
      // keep UI usable
      operationalProgressText.value = '0%';
    }
  }

  void _loadAgencyBids(List<Map<String, dynamic>> bids) {
    if (bids.isEmpty) return;

    final mapped = bids
        .map((b) {
          final agencyId = b['agencyId']?.toString().trim() ?? '';
          final name = b['agencyName']?.toString().trim();
          final logo = b['logo']?.toString().trim();
          final percent = _parsePercent(b['proposedServiceFeePercent']);
          final totalExcl = _numToInt(
            b['totalpayableExcludingAgencyServiceFee'],
          );
          final fx = _numToDouble(b['dollarRate']);

          if (agencyId.isEmpty) return null;

          return PaidAdAgencyOffer(
            agencyId: agencyId,
            name: (name == null || name.isEmpty) ? 'Agency' : name,
            logo: logo ?? '',
            agencyFeePercent: percent <= 0 ? 10 : percent,
            totalPayableExcludingFee: totalExcl,
            dollarRate: fx,
          );
        })
        .whereType<PaidAdAgencyOffer>()
        .toList(growable: false);

    if (mapped.isNotEmpty) agencyOffers.assignAll(mapped);
  }

  void _mapAssignedInfluencers(Map<String, dynamic> data) {
    final rawList = (data['assignedInfluencers'] as List?) ?? const [];

    final mapped = <AssignedInfluencerUi>[];
    final chipNames = <String>[];

    for (final raw in rawList) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);

      final assignmentId = (item['assignmentId'] ?? '').toString().trim();
      final influencerId = (item['influencerId'] ?? '').toString().trim();
      final name = (item['name'] ?? 'Influencer').toString().trim();
      final image = item['image']?.toString().trim();
      final location = (item['location'] ?? '').toString().trim();
      final country = (item['country'] ?? '').toString().trim();

      final locationText = [
        if (location.isNotEmpty) location,
        if (country.isNotEmpty && country.toLowerCase() != 'n/a') country,
      ].join(', ');

      final assignedWorkRaw = (item['assignedWork'] as List?) ?? const [];
      final assignedWork = assignedWorkRaw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);

      mapped.add(
        AssignedInfluencerUi(
          assignmentId: assignmentId,
          influencerId: influencerId,
          name: name.isEmpty ? 'Influencer' : name,
          image: (image != null && image.isNotEmpty) ? image : null,
          locationText: locationText.isEmpty ? '—' : locationText,
          status: (item['status'] ?? '').toString().trim(),
          offeredAmount: _numToDouble(item['offeredAmount']),
          assignedWork: assignedWork,
        ),
      );

      chipNames.add(name);
    }

    assignedInfluencers.assignAll(mapped);

    // keep old top card influencers chips (if you still use it)
    influencers.assignAll(chipNames);

    // auto select first influencer for influencer campaign only
    if (!isPaidAd && mapped.isNotEmpty) {
      final alreadySelected = selectedAssignmentId.value;
      final stillExists = mapped.any((e) => e.assignmentId == alreadySelected);

      if (!stillExists) {
        selectAssignedInfluencer(mapped.first);
      } else {
        final current = mapped.firstWhere(
          (e) => e.assignmentId == alreadySelected,
        );
        _applyInfluencerAssignedWorkToMilestones(current);
      }
    }
  }

  void selectAssignedInfluencer(AssignedInfluencerUi influencer) {
    if (isPaidAd) return; // ✅ only influencer promotion

    selectedAssignmentId.value = influencer.assignmentId;
    selectedInfluencerId.value = influencer.influencerId;
    _applyInfluencerAssignedWorkToMilestones(influencer);

    // ✅ refresh progress for selected influencer
    final campaignId = _extractCampaignId(arguments);
    if (campaignId != null && campaignId.trim().isNotEmpty) {
      _loadProgressByCampaignType(campaignId);
    }
  }

  void _applyInfluencerAssignedWorkToMilestones(
    AssignedInfluencerUi influencer,
  ) {
    final baseList = masterMilestones.toList(growable: false);

    // If no master milestones from campaign, fallback to assigned work direct map
    if (baseList.isEmpty) {
      final fallback = influencer.assignedWork
          .asMap()
          .entries
          .map((entry) {
            final w = entry.value;
            return Milestone(
              id: w['id']?.toString() ?? w['id']?.toString(),
              stepLabel: '${entry.key + 1}',
              title: (w['contentTitle'] ?? 'Milestone').toString(),
              subtitle: w['contentQuantity']?.toString(),
              dayLabel: w['deliveryDays'] != null
                  ? 'DAY ${w['deliveryDays']}'
                  : null,
              dayIndex: _numToInt(w['deliveryDays']),
              amountLabel: _numToDouble(w['amount']) > 0
                  ? _fmt(_numToDouble(w['amount']).round())
                  : '',
              platform: w['platform']?.toString(),
              deliverable: w['contentQuantity']?.toString(),
              status: _parseMilestoneStatus(w['status']?.toString()),
              submissions: const [],
            );
          })
          .toList(growable: false);

      milestones.assignAll(fallback);
      _derivePlatformsFromMilestones(fallback);
      _recomputeMilestoneStatusLabel();
      return;
    }

    final workByMasterId = <String, Map<String, dynamic>>{};
    for (final w in influencer.assignedWork) {
      final masterId = (w['id'] ?? '').toString().trim();
      if (masterId.isNotEmpty) {
        workByMasterId[masterId] = w;
      }
    }

    final merged = <Milestone>[];
    for (int i = 0; i < baseList.length; i++) {
      final base = baseList[i];
      final masterId = (base.id ?? '').trim();
      final w = masterId.isNotEmpty ? workByMasterId[masterId] : null;

      if (w == null) {
        // if this influencer doesn't have this work, you can skip or keep base
        // Keeping base is safer for visibility; if you want exact assigned list only, continue instead.
        merged.add(base);
        continue;
      }

      merged.add(
        Milestone(
          id: masterId.isNotEmpty ? masterId : (w['id']?.toString()),
          stepLabel: base.stepLabel,
          title: (w['contentTitle'] ?? base.title).toString(),
          subtitle:
              (w['contentQuantity']?.toString().trim().isNotEmpty ?? false)
              ? w['contentQuantity'].toString().trim()
              : base.subtitle,
          dayLabel: w['deliveryDays'] != null
              ? 'DAY ${w['deliveryDays']}'
              : base.dayLabel,
          dayIndex: _numToInt(w['deliveryDays']) == 0
              ? base.dayIndex
              : _numToInt(w['deliveryDays']),
          amountLabel: _numToDouble(w['amount']) > 0
              ? _fmt(_numToDouble(w['amount']).round())
              : (base.amountLabel),
          platform: (w['platform']?.toString().trim().isNotEmpty ?? false)
              ? w['platform'].toString()
              : base.platform,
          deliverable: w['contentQuantity']?.toString() ?? base.deliverable,
          targets: base.targets,
          status: _parseMilestoneStatus(w['status']?.toString()),
          submissions: const [],
        ),
      );
    }

    milestones.assignAll(merged);
    _derivePlatformsFromMilestones(merged);
    _recomputeMilestoneStatusLabel();
  }

  List<String> submissionIdsForSelectedInfluencerMilestone(
    String? masterMilestoneId,
  ) {
    if (isPaidAd) return const [];
    final targetMasterId = (masterMilestoneId ?? '').trim();
    if (targetMasterId.isEmpty) return const [];

    final selected = assignedInfluencers.firstWhereOrNull(
      (e) => e.assignmentId == selectedAssignmentId.value,
    );
    if (selected == null) return const [];

    final ids = <String>[];

    for (final work in selected.assignedWork) {
      final workMasterId = (work['id'] ?? '').toString().trim();
      if (workMasterId != targetMasterId) continue;

      final submissions = (work['submissions'] as List?) ?? const [];
      for (final s in submissions) {
        if (s is! Map) continue;
        final id = (s['id'] ?? '').toString().trim();
        if (id.isNotEmpty) ids.add(id);
      }
    }

    return ids;
  }

  void _loadFromApiMap(Map<String, dynamic> data) {
    influencers.clear();
    platformKeys.clear();
    contentAssets.clear();
    brandAssets.clear();
    contentRequirements.clear();
    assignedInfluencers.clear();
    milestones.clear();
    masterMilestones.clear();

    // Type
    final ct = data['campaignType']?.toString() ?? '';
    if (ct.isNotEmpty) campaignType.value = ct;

    // Top
    final title = data['campaignName']?.toString().trim();
    if (title != null && title.isNotEmpty) campaignTitle.value = title;

    campaignStatus.value = data['status'];

    selectedAgencyOfferId.value = data['agencyOfferId']?.toString().trim();

    final totalBudget = _numToDouble(data['totalBudget']);
    if (totalBudget > 0) budgetText.value = formatCurrencyByLocale(totalBudget);

    // Rating
    isRated.value = data['isRated'];
    rating.value = _numToDouble(data['rating']).clamp(0.0, 5.0);
    selectedInfluencerId.value = _extractInfluencerId(data);

    // Quote breakdown
    final base = _numToDouble(data['baseBudget']).round();
    final vat = _numToDouble(data['vatAmount']).round();
    if (base > 0) baseBudget.value = base;
    if (vat > 0) vatAmount.value = vat;

    // Budget status
    paymentStatus.value = data['paymentStatus'];
    dueAmount.value = _numToDouble(data['paymentInfo']['dueAmount']).round();
    final paid = _numToDouble(data['paymentInfo']['paidAmount']);
    this.dueAmount.value = dueAmount.round();
    paidAmount.value = paid.round();
    showDueButton.value = data['paymentInfo']['showPayDueButton'];

    // Brief
    campaignGoals.value = (data['campaignGoals'] ?? '').toString().trim();
    productServiceDetails.value = (data['productServiceDetails'] ?? '')
        .toString()
        .trim();
    reportingRequirements.value = (data['reportingRequirements'] ?? '')
        .toString()
        .trim();
    usageRights.value = (data['usageRights'] ?? '').toString().trim();
    dosText.value = (data['dos'] ?? '').toString().trim();
    dontsText.value = (data['donts'] ?? '').toString().trim();

    // Deadline
    final startingDate = data['startingDate']?.toString();
    final duration = (data['duration'] as num?)?.toInt();
    _applyDeadline(startingDate: startingDate, duration: duration);

    // Assets
    final assets = (data['assets'] as List?) ?? const [];
    _mapAssets(assets);

    // Milestones
    final ms = (data['milestones'] as List?) ?? const [];
    _mapMilestones(ms);
    _derivePlatformsFromMilestones(milestones);

    _mapAssignedInfluencers(data);

    _checkAndSetProgressStep();

    // Content requirements fallback from milestones
    if (contentRequirements.isEmpty && milestones.isNotEmpty) {
      contentRequirements.assignAll(
        milestones
            .map(
              (m) => m.subtitle?.trim().isNotEmpty == true
                  ? '${m.title} · ${m.subtitle}'
                  : m.title,
            )
            .toList(growable: false),
      );
    }
  }

  void _checkAndSetProgressStep() {
    if (campaignStatus.value.isNotEmpty) {
      dev.log('THE CAMP STATUS: ${campaignStatus.value}');

      if (isPaidAd && (isPendingAgency || !isAgencyAccepet)) {
        budgetStatusText.value =
            'brand_campaign_details_agency_confirmation_pending'.tr;
      }
      if (isPendingAgency) {
        budgetStatusText.value =
            'brand_campaign_details_agency_confirmation_pending'.tr;
        progressStep.value = CampaignProgressStep.quoted;
        return;
      }

      if (campaignStatus.value.contains('complete') ||
          campaignStatus.value.contains('completed')) {
        progressStep.value = CampaignProgressStep.completed;
        return;
      }
      if (campaignStatus.value.contains('promot') ||
          campaignStatus.value.contains('active') ||
          campaignStatus.value.contains('accept')) {
        progressStep.value = CampaignProgressStep.promoting;
        return;
      }
      if (paymentStatus.value.contains('partial') ||
          paymentStatus.value.contains('full')) {
        progressStep.value = CampaignProgressStep.paid;
        return;
      }
      if (campaignStatus.value.contains('negotiat') ||
          campaignStatus.value.contains('pending_influencer')) {
        progressStep.value = CampaignProgressStep.quoted;
        return;
      }

      progressStep.value = CampaignProgressStep.submitted;
    }
  }

  void _loadCampaignProgress(Map<String, dynamic> response) {
    final data = response['data'] is Map
        ? Map<String, dynamic>.from(response['data'] as Map)
        : Map<String, dynamic>.from(response);

    // ✅ New progress APIs (agency / influencer)
    final progressPercentage = _numToInt(data['progressPercentage']);
    if (progressPercentage >= 0) {
      operationalProgressText.value = '$progressPercentage%';
    }

    // ✅ Backward compatibility (if old API fields still appear somewhere)
    final op = (data['operationalProgress'] ?? '').toString().trim();
    if (op.isNotEmpty) {
      operationalProgressText.value = op;
    }
  }

  void _applyDeadline({String? startingDate, int? duration}) {
    final start = _tryParseDate(startingDate);
    if (start == null || duration == null) return;

    final deadline = start.add(Duration(days: duration));
    final label = DateFormat('MMM dd, yyyy').format(deadline);
    deadlineDateText.value = label;

    final today = DateTime.now();
    final startDay = DateTime(today.year, today.month, today.day);
    final endDay = DateTime(deadline.year, deadline.month, deadline.day);
    final diff = endDay.difference(startDay).inDays;
    daysRemaining.value = diff < 0 ? 0 : diff;
  }

  void _mapAssets(List<dynamic> assets) {
    final content = <JobAsset>[];
    final brand = <BrandAssetLink>[];

    for (final raw in assets) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final category = item['category']?.toString().toLowerCase();
      final fileName = item['fileName']?.toString().trim() ?? '';
      final description = item['description']?.toString().trim() ?? '';
      final fileUrl = item['fileUrl']?.toString().trim();
      final fileSize = _numToInt(item['fileSize']);
      final mime = item['mimeType']?.toString().trim() ?? '';
      final assetType = item['assetType']?.toString().trim();

      if (category == 'brand') {
        final icon = _iconForBrandAsset(fileName, fileUrl);
        brand.add(
          BrandAssetLink(
            assetId: item['id']?.toString(),
            title: description.isNotEmpty
                ? description
                : fileName.isNotEmpty
                ? fileName
                : (assetType ?? 'Brand Asset'),
            subtitle: assetType?.isNotEmpty == true ? assetType! : 'Page Link',
            icon: icon,
            url: fileUrl?.isNotEmpty == true ? fileUrl : null,
          ),
        );
        continue;
      }

      if (category == 'content' || category == null) {
        final meta = [
          if (fileSize > 0) _formatBytes(fileSize),
          if (mime.isNotEmpty) mime.toUpperCase(),
        ].where((e) => e.trim().isNotEmpty).join(' · ');

        content.add(
          JobAsset(
            title: description.isNotEmpty
                ? description
                : fileName.isNotEmpty
                ? fileName
                : 'Asset',
            meta: meta.isNotEmpty ? meta : '—',
            kind: _guessAssetKind(fileName),
            pathOrUrl: fileUrl?.isNotEmpty == true ? fileUrl : null,
          ),
        );
      }
    }

    if (content.isNotEmpty) contentAssets.assignAll(content);
    if (brand.isNotEmpty) brandAssets.assignAll(brand);
  }

  void _mapMilestones(List<dynamic> list) {
    if (list.isEmpty) return;

    final rawItems = list
        .whereType<Map>()
        .map((e) {
          return Map<String, dynamic>.from(e);
        })
        .toList(growable: false);

    final rawOrders = rawItems
        .map((item) => (item['order'] as num?)?.toInt())
        .whereType<int>()
        .toList(growable: false);

    // If backend sends 0 as first order => treat as 0-based.
    // Otherwise treat provided order as already 1-based.
    final bool isZeroBasedOrder = rawOrders.contains(0);

    final mapped = <Milestone>[];

    for (int i = 0; i < rawItems.length; i++) {
      final item = rawItems[i];

      final id = item['id']?.toString().trim();
      final title = item['contentTitle']?.toString().trim() ?? 'Milestone';
      final quantity = item['contentQuantity']?.toString().trim();
      final deliveryDays = (item['deliveryDays'] as num?)?.toInt();
      final order = (item['order'] as num?)?.toInt();
      final amount = _numToDouble(item['amount']).round();
      final platform = item['platform']?.toString();
      final status = _parseMilestoneStatus(item['status']?.toString());

      final int displayStep = order != null
          ? (isZeroBasedOrder ? order + 1 : order)
          : i + 1;

      mapped.add(
        Milestone(
          id: id,
          stepLabel: displayStep.toString(),
          title: title,
          subtitle: quantity?.isNotEmpty == true ? quantity : null,
          dayLabel: deliveryDays != null ? 'DAY $deliveryDays' : null,
          amountLabel: amount > 0 ? _fmt(amount) : '',
          platform: platform,
          deliverable: quantity,
          targets: PromotionTarget(
            reach: _numToInt(item['expectedReach']),
            views: _numToInt(item['expectedViews']),
            likes: _numToInt(item['expectedLikes']),
            comments: _numToInt(item['expectedComments']),
          ),
          status: status,
        ),
      );
    }

    if (mapped.isNotEmpty) {
      masterMilestones.assignAll(mapped);
      milestones.assignAll(mapped);
    }
  }

  MilestoneStatus _parseMilestoneStatus(String? raw) {
    final v = (raw ?? '').toLowerCase();
    switch (v) {
      case 'in_review':
        return MilestoneStatus.inReview;
      case 'paid':
        return MilestoneStatus.paid;
      case 'approved':
        return MilestoneStatus.approved;
      case 'partial_paid':
        return MilestoneStatus.partialPaid;
      case 'declined':
        return MilestoneStatus.declined;
      case 'completed':
        return MilestoneStatus.approved;
      case 'todo':
      case 'to_do':
      case 'pending':
      default:
        return MilestoneStatus.todo;
    }
  }

  int _parsePercent(dynamic raw) {
    final v = raw?.toString() ?? '';
    final match = RegExp(r'(\d{1,3})').firstMatch(v);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  int _numToInt(dynamic value) {
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return (double.tryParse(value) ?? 0.0).toInt();
    return 0;
  }

  double _numToDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  DateTime? _tryParseDate(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  IconData _iconForBrandAsset(String fileName, String? url) {
    final name = fileName.toLowerCase();
    final link = (url ?? '').toLowerCase();
    if (name.contains('facebook') || link.contains('facebook')) {
      return Icons.facebook;
    }
    if (name.contains('instagram') || link.contains('instagram')) {
      return Icons.camera_alt_outlined;
    }
    if (name.contains('youtube') || link.contains('youtube')) {
      return Icons.play_circle_outline;
    }
    if (name.contains('tiktok') || link.contains('tiktok')) {
      return Icons.music_note_outlined;
    }
    return Icons.link_rounded;
  }

  // -------------------------
  // Data loading
  // -------------------------

  void _loadFromJob(JobItem j) {
    // Type (if not set from args)
    campaignType.value = j.campaignType.name;

    // Top
    campaignTitle.value = j.title;
    budgetText.value = formatCurrencyByLocale(j.budget);

    // Deadline
    daysRemaining.value = j.dueInDays ?? 0;
    deadlineDateText.value = j.dateLabel;

    // Rating (if any)
    rating.value = _numToDouble(j.rating).clamp(0.0, 5.0);

    // Quote breakdown
    final b = (j.baseBudget ?? j.budget).round();
    final v =
        (j.vatAmount ??
                ((j.vatPercent != null) ? (b * (j.vatPercent! / 100.0)) : 0.0))
            .round();

    baseBudget.value = b;
    vatAmount.value = v;

    // Assets
    contentAssets.assignAll(j.contentAssets ?? const <JobAsset>[]);

    // Milestones
    milestones.assignAll(j.milestones ?? const <Milestone>[]);

    if (milestones.isNotEmpty) _derivePlatformsFromMilestones(milestones);

    // Brief text pieces
    dosText.value = (j.dosText ?? '').trim();
    dontsText.value = (j.dontsText ?? '').trim();

    // Optional subtitle -> can be used as goals/product if you want
    final sub = (j.subTitle ?? '').trim();
    if (sub.isNotEmpty) {
      campaignGoals.value = campaignGoals.value.trim().isEmpty
          ? sub
          : campaignGoals.value;
      productServiceDetails.value = productServiceDetails.value.trim().isEmpty
          ? sub
          : productServiceDetails.value;
    }

    // Brand Assets (if exists)
    final bas = j.brandAssets ?? const <BrandAsset>[];
    if (bas.isNotEmpty) {
      brandAssets.assignAll(
        bas.map((e) {
          final t = e.title.trim();
          final v = (e.value ?? '').trim();
          final lower = t.toLowerCase();
          final icon = lower.contains('facebook')
              ? Icons.facebook
              : Icons.link_rounded;

          return BrandAssetLink(
            title: t.isEmpty ? 'Link' : t,
            subtitle: 'Page Link',
            icon: icon,
            url: v.isEmpty ? null : v,
          );
        }).toList(),
      );
    }
  }

  void _loadFromCreateCampaign(CreateCampaignController c) {
    // Title
    final t = c.campaignName.value.trim().isNotEmpty
        ? c.campaignName.value.trim()
        : c.campaignNameCtrl.text.trim();
    campaignTitle.value = t.isNotEmpty ? t : 'Summer Fashion Campaign';

    // Brief
    campaignGoals.value = c.campaignGoals.value;
    productServiceDetails.value = c.productServiceDetails.value;

    dosText.value = c.dosText.value.trim().isNotEmpty
        ? c.dosText.value
        : c.dosCtrl.text;
    dontsText.value = c.dontsText.value.trim().isNotEmpty
        ? c.dontsText.value
        : c.dontsCtrl.text;

    // Terms
    reportingRequirements.value = c.reportingRequirements.value;
    usageRights.value = c.usageRights.value;

    // Assets + milestones
    contentAssets.assignAll(c.contentAssets);
    milestones.assignAll(c.milestones);

    // Quote
    if (budgetText.value.trim().isEmpty) budgetText.value = '৳11,000';
  }

  // void _applyFallbacks() {
  //   _recomputeMilestoneStatusLabel();
  // }

  // -------------------------
  // UI Actions
  // -------------------------

  void toggleBrief() => briefExpanded.value = !briefExpanded.value;
  void toggleAssets() => assetsExpanded.value = !assetsExpanded.value;
  void toggleTerms() => termsExpanded.value = !termsExpanded.value;
  void toggleMilestones() =>
      milestonesExpanded.value = !milestonesExpanded.value;

  void setRating(int v) {
    final next = v.clamp(0, 5);
    rating.value = next.toDouble();
  }

  Future<void> provideRating() async {
    if (Get.isDialogOpen == true) return;

    if (isPaidAd) {
      agencyDialogRating.value = rating.value.round().clamp(0, 5);
      await ProvideRatingDialog.show(isPaidAd: true);
    } else {
      await prepareInfluencerRatingsDialog();
      if (Get.isDialogOpen == true) return;
      await ProvideRatingDialog.show(isPaidAd: false);
    }
  }

  Future<void> submitAgencyRating() async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    final rate = agencyDialogRating.value;
    if (rate <= 0) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Please provide a rating.',
      );
      return;
    }

    isSubmittingRatings.value = true;

    final result = await ApiErrorHandler.call(
      () => _campaignService.rateAgency(campaignId: campaignId, rating: rate),
      showError: false,
    );

    isSubmittingRatings.value = false;

    if (!result.isSuccess) return;

    rating.value = rate.toDouble();
    Get.back();

    AppSnackbar.showSuccessSnackbar(
      title: 'Success',
      message: 'Rating submitted successfully.',
    );
  }

  Future<void> submitInfluencerRatings() async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    final ratedItems = rateInfluencerItems
        .where((e) => !e.isAlreadyRated.value && e.rating.value > 0)
        .toList(growable: false);

    if (ratedItems.isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: trOr('common_error', 'Error'),
        message: trOr(
          'brand_campaign_rating_required',
          'Please provide at least one rating.',
        ),
      );
      return;
    }

    isSubmittingRatings.value = true;

    for (final item in ratedItems) {
      final result = await ApiErrorHandler.call(
        () => _campaignService.rateInfluencer(
          campaignId: campaignId,
          influencerId: item.influencerId,
          rating: item.rating.value,
        ),
        showError: false,
      );

      if (!result.isSuccess) {
        isSubmittingRatings.value = false;
        return;
      }

      item.isAlreadyRated.value = true;
      item.ratedAt.value = DateTime.now();
    }

    isSubmittingRatings.value = false;
    Get.back();

    AppSnackbar.showSuccessSnackbar(
      title: 'Success',
      message: 'Ratings submitted successfully.',
    );
  }

  void onRequestQuote() {
    dev.log('Your turn: $isYourTurn');
    if (!isYourTurn.value) return;

    if (isPaidAd) {
      _openPaidAdRequoteDialog();
    } else {
      _openRequoteDialog();
    }
  }

  Future<void> onAcceptQuote() async {
    if (!isYourTurn.value || isAcceptQuoteLoading.value) return;

    try {
      isAcceptQuoteLoading.value = true;
      _showBlockingLoader();

      if (isPaidAd) {
        await _hideBlockingLoader();
        setPaidAdTab(0);
        _openConfirmBudgetDialog();
        return;
      }

      final ok = await _acceptQuoteRequest();

      await _hideBlockingLoader();

      if (!ok) return;

      openFundCampaignDialog();
    } catch (e) {
      await _hideBlockingLoader();
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
    } finally {
      isAcceptQuoteLoading.value = false;
    }
  }

  Future<void> onAcceptAgencyOfferAndPay(PaidAdAgencyOffer offer) async {
    if (isAcceptQuoteLoading.value) return;

    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    try {
      isAcceptQuoteLoading.value = true;
      payingAgencyOfferId.value = offer.agencyId;

      _showBlockingLoader();

      await _campaignService.selectAgencyForCampaign(
        campaignId: campaignId,
        agencyId: offer.agencyId,
      );

      selectedAgencyOfferId.value = offer.agencyId;

      await _loadFromApiIfPossible();

      await _hideBlockingLoader();

      openFundCampaignDialog();
    } catch (e) {
      await _hideBlockingLoader();
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
    } finally {
      isAcceptQuoteLoading.value = false;
      payingAgencyOfferId.value = null;
    }
  }

  void onDownloadAsset(int index) {
    AppSnackbar.showSuccessSnackbar(
      title: 'Success',
      message: 'Asset downloaded successfully.',
    );
  }

  Future<void> removeBrandAsset(int index) async {
    if (index < 0 || index >= brandAssets.length) return;
    final item = brandAssets[index];
    final assetId = item.assetId?.trim() ?? '';

    if (assetId.isNotEmpty) {
      final result = await ApiErrorHandler.call(
        () => _campaignService.deleteCampaignAsset(assetId: assetId),
      );
      if (!result.isSuccess) return;
    }

    brandAssets.removeAt(index);
  }

  String? _extractInfluencerId(Map<String, dynamic> data) {
    final direct = data['influencerId']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;

    final assigned = data['assignedInfluencerId']?.toString().trim();
    if (assigned != null && assigned.isNotEmpty) return assigned;

    final influencer = data['influencer'];
    if (influencer is Map) {
      final id = influencer['id']?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }

    return null;
  }

  Future<bool> _acceptQuoteRequest() async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return false;
    }

    try {
      isLoading.value = true;
      await _campaignService.acceptNegotiation(campaignId: campaignId);
      await _loadFromApiIfPossible();
      AppSnackbar.showSuccessSnackbar(
        title: 'Success',
        message: 'Quote accepted successfully.',
      );
      return true;
    } catch (e) {
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _submitRequote({
    required int proposedBaseBudget,
    required int vatAmountValue,
    bool closeDialog = true,
  }) async {
    if (proposedBaseBudget <= 0) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Please enter a valid budget.',
      );
      return;
    }

    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    try {
      isLoading.value = true;

      int nextVat = vatAmountValue;
      final preview = await _campaignService.fetchBudgetPreview(
        baseBudget: proposedBaseBudget,
        isAgencyCampaign: isPaidAd,
      );
      final previewData = preview['data'] is Map
          ? Map<String, dynamic>.from(preview['data'] as Map)
          : null;
      if (previewData != null) {
        nextVat = _numToInt(previewData['vatAmount']);
      }

      await _campaignService.sendNegotiationCounterOffer(
        campaignId: campaignId,
        proposedBaseBudget: proposedBaseBudget,
      );

      baseBudget.value = proposedBaseBudget;
      vatAmount.value = nextVat;

      if (closeDialog) Get.back();

      AppSnackbar.showSuccessSnackbar(
        title: 'Success',
        message: 'Requote request sent to admin.',
      );

      await _loadFromApiIfPossible();
    } catch (e) {
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'].toString().trim();
        if (msg.isNotEmpty) return msg;
      }
      final msg = e.message?.trim();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.toString();
  }

  List<String> _lines(String text) =>
      text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  List<String> get dosLines => _lines(dosText.value);
  List<String> get dontsLines => _lines(dontsText.value);

  IconData _iconForAsset(JobAssetKind kind) {
    switch (kind) {
      case JobAssetKind.image:
        return Icons.image_outlined;
      case JobAssetKind.video:
        return Icons.play_circle_outline;
      case JobAssetKind.document:
        return Icons.description_outlined;
      case JobAssetKind.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  JobAssetKind _guessAssetKind(String filename) {
    final e = filename.toLowerCase();
    if (e.endsWith('.png') ||
        e.endsWith('.jpg') ||
        e.endsWith('.jpeg') ||
        e.endsWith('.webp') ||
        e.endsWith('.gif')) {
      return JobAssetKind.image;
    }
    if (e.endsWith('.mp4') ||
        e.endsWith('.mov') ||
        e.endsWith('.mkv') ||
        e.endsWith('.avi') ||
        e.endsWith('.webm')) {
      return JobAssetKind.video;
    }
    if (e.endsWith('.pdf') ||
        e.endsWith('.doc') ||
        e.endsWith('.docx') ||
        e.endsWith('.ppt') ||
        e.endsWith('.pptx') ||
        e.endsWith('.xls') ||
        e.endsWith('.xlsx') ||
        e.endsWith('.txt')) {
      return JobAssetKind.document;
    }
    return JobAssetKind.other;
  }

  String _extUpper(String filename) {
    final i = filename.lastIndexOf('.');
    if (i == -1 || i == filename.length - 1) return 'FILE';
    return filename.substring(i + 1).toUpperCase();
  }

  String _filenameNoExt(String filename) {
    final i = filename.lastIndexOf('.');
    if (i == -1) return filename;
    return filename.substring(0, i);
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

  void openUploadAnotherAssetDialog() {
    UploadAnotherAssetDialog.show(
      contentAssets: contentAssets,
      guessAssetKind: _guessAssetKind,
      iconForAsset: _iconForAsset,
      formatBytes: _formatBytes,
      extUpper: _extUpper,
      filenameNoExt: _filenameNoExt,
      onSubmit:
          ({
            required String title,
            required String fileName,
            required int fileBytes,
            required String filePath,
            required JobAssetKind kind,
          }) {
            return uploadAnotherContentAsset(
              title: title,
              fileName: fileName,
              fileBytes: fileBytes,
              filePath: filePath,
              kind: kind,
            );
          },
    );
  }

  void openUploadAnotherBrandAssetDialog() {
    UploadAnotherBrandAssetDialog.show(
      brandAssets: brandAssets,
      onSubmit: ({required String title, required String url}) {
        return uploadAnotherBrandAsset(title: title, url: url);
      },
    );
  }

  String trOr(String key, String fallback) {
    final v = key.tr;
    return (v == key) ? fallback : v;
  }

  int _parseAmount(String input) {
    // supports both English + Bangla digits, strips everything except digits
    final map = {
      '০': '0',
      '১': '1',
      '২': '2',
      '৩': '3',
      '৪': '4',
      '৫': '5',
      '৬': '6',
      '৭': '7',
      '৮': '8',
      '৯': '9',
    };

    final normalized = input
        .split('')
        .map((c) => map[c] ?? c)
        .join()
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (normalized.isEmpty) return 0;
    return int.tryParse(normalized) ?? 0;
  }

  String _fmt(int amount) {
    // Uses your existing formatter (should auto-localize digits if configured)
    return formatCurrencyByLocale(amount);
  }

  //void _openPaidAdRequoteDialog() {}
  void _openPaidAdRequoteDialog() {
    PaidAdRequoteDialog.show(
      initialBaseBudget: baseBudget.value,
      parseAmount: _parseAmount,
      fmt: _fmt,
      trOr: trOr,
      onSubmit: _submitRequote,
    );
  }

  void _openRequoteDialog() {
    RequoteDialog.show(
      initialBaseBudget: baseBudget.value,
      parseAmount: _parseAmount,
      fmt: _fmt,
      trOr: trOr,
      onSubmit: _submitRequote,
    );
  }

  void _openConfirmBudgetDialog() {
    ConfirmBudgetDialog.show(
      baseBudget: baseBudget.value,
      vatAmount: vatAmount.value,
      totalCost: totalCost,
      fmt: _fmt,
      trOr: trOr,
      onRequote: _openPaidAdRequoteDialog,
      onConfirm: () async {
        final ok = await _acceptQuoteRequest();
        return ok;
      },
    );
  }

  int _parseCurrencyToInt(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  void openFundCampaignDialog() {
    final totalDue = dueAmount.value > 0 ? dueAmount.value : totalCost;
    final alreadyPaid = paidAmount.value;

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    FundCampaignDialog.show(
      campaignTitle: campaignTitle.value,
      totalDue: totalDue,
      paidAmount: alreadyPaid,
      trOr: trOr,
      fmt: (amount) => formatCurrencyByLocale(amount),
      parseAmount: _parseCurrencyToInt,
      onPay: ({required int amount}) async {
        if (showDueButton.value && dueAmount.value > 0) {
          await payCampaignDueNow(amount: amount);
        } else {
          await payCampaignNow(amount: amount);
        }
      },
      isPaying: isPayNowLoading,
    );
  }

  Future<void> _loadNegotiationContext(String campaignId) async {
    final history = await _campaignService.fetchNegotiationHistory(
      campaignId: campaignId,
    );

    final data = history['data'] is Map
        ? Map<String, dynamic>.from(history['data'] as Map)
        : const <String, dynamic>{};
    final campaignInfo = data['campaign'];

    isYourTurn.value = campaignInfo['yourTurn'];

    final negotiations = (data['negotiations'] as List?) ?? const [];

    if (negotiations.isEmpty) return;

    final latest = negotiations.last;
    if (latest is! Map) return;

    final latestMap = Map<String, dynamic>.from(latest);
    final latestProposedBase = _numToInt(latestMap['proposedBaseBudget']);
    final proposedTotalBudget = _numToInt(latestMap['proposedTotalBudget']);
    if (latestProposedBase > 0) {
      baseBudget.value = latestProposedBase;
      final vat = proposedTotalBudget - latestProposedBase;
      if (vat > 0) vatAmount.value = vat;
    }

    final isRead = latestMap['isRead'] == true;
    final negotiationId = latestMap['id']?.toString().trim() ?? '';
    if (!isRead && negotiationId.isNotEmpty) {
      await _campaignService.markNegotiationAsRead(
        negotiationId: negotiationId,
      );
    }
  }

  void openInfluencerMilestonePickerSheet() {
    if (isPaidAd) return;

    final list = assignedInfluencers.toList(growable: false);
    if (list.isEmpty) return;

    Get.bottomSheet(
      InfluencerMilestonePickerSheet(
        influencers: list,
        selectedAssignmentId: selectedAssignmentId.value,
        onSelect: (item) {
          selectAssignedInfluencer(item);
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> requestCancellation() async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    final reason = cancelReasonCtrl.text.trim();
    if (reason.isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Please write your cancellation reason.',
      );
      return;
    }

    final assignmentId = selectedAssignmentId.value?.trim() ?? '';
    final agencyOfferId = selectedAgencyOfferId.value?.trim() ?? '';

    if (!isPaidAd && assignmentId.isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'No influencer assignment selected.',
      );
      return;
    }

    if (isPaidAd && agencyOfferId.isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'No agency offer found for this campaign.',
      );
      return;
    }

    try {
      isSubmittingCancellation.value = true;

      await _campaignService.requestCampaignCancellation(
        campaignId: campaignId,
        isPaidAd: isPaidAd,
        reason: reason,
        assignmentId: isPaidAd ? null : assignmentId,
        agencyOfferId: isPaidAd ? agencyOfferId : null,
      );

      cancelReasonCtrl.clear();
      dangerZoneExpanded.value = false;

      AppSnackbar.showSuccessSnackbar(
        title: 'Success',
        message: 'Cancellation request submitted successfully.',
      );

      await _loadFromApiIfPossible();
    } catch (e) {
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
    } finally {
      isSubmittingCancellation.value = false;
    }
  }

  Future<void> openAssetLink(String? rawUrl) async {
    String raw = rawUrl?.trim() ?? '';
    if (raw.isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'No asset url found.',
      );
      return;
    }

    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'https://$raw';
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Invalid asset url.',
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);

    if (!opened) {
      final fallback = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!fallback) {
        AppSnackbar.showErrorSnackbar(
          title: 'Error',
          message: 'Could not open asset.',
        );
      }
    }
  }

  String _getContentType(String filePathOrName) {
    final ext = path
        .extension(filePathOrName)
        .replaceFirst('.', '')
        .toLowerCase();

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Map<String, dynamic> _removeNulls(Map<String, dynamic> data) {
    data.removeWhere((key, value) => value == null);
    return data;
  }

  String _safeAssetTitleFromFile(String fileName) {
    final name = path.basenameWithoutExtension(fileName).trim();
    return name.isEmpty ? 'Asset' : name;
  }

  Future<void> uploadAnotherContentAsset({
    required String title,
    required String fileName,
    required int fileBytes,
    required String filePath,
    required JobAssetKind kind,
  }) async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Selected file not found.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final mimeType = _getContentType(filePath);

      final signed = await _uploadService.createSignedUrl(
        fileName: fileName,
        fileType: mimeType,
        module: 'campaign-assets',
      );

      await _uploadService.uploadFileToSignedUrl(
        uploadUrl: signed.uploadUrl,
        file: file,
        contentType: mimeType,
      );

      final payload = _removeNulls({
        'fileName': fileName,
        'fileUrl': signed.fileUrl,
        'assetType': mimeType,
        'category': 'content',
        'fileSize': fileBytes,
        'mimeType': mimeType,
        'description': title,
      });

      await _campaignService.addCampaignAssets(
        campaignId: campaignId,
        assets: [payload],
      );

      contentAssets.add(
        JobAsset(
          title: title,
          meta: '${_extUpper(fileName)} • ${_formatBytes(fileBytes)}',
          kind: kind,
          pathOrUrl: signed.fileUrl,
        ),
      );

      AppSnackbar.showSuccessSnackbar(
        title: 'Success',
        message: 'Asset uploaded successfully.',
      );
    } catch (e) {
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadAnotherBrandAsset({
    required String title,
    required String url,
  }) async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Missing campaign id.',
      );
      return;
    }

    try {
      isLoading.value = true;

      String normalizedUrl = url.trim();
      if (!normalizedUrl.startsWith('http://') &&
          !normalizedUrl.startsWith('https://')) {
        normalizedUrl = 'https://$normalizedUrl';
      }

      final payload = _removeNulls({
        'fileName': title,
        'fileUrl': normalizedUrl,
        'assetType': 'brand_asset',
        'category': 'brand',
        'mimeType': 'text/plain',
        'description': title,
      });

      final res = await _campaignService.addCampaignAssets(
        campaignId: campaignId,
        assets: [payload],
      );

      String? assetId;
      final data = res['data'];
      if (data is Map &&
          data['assets'] is List &&
          (data['assets'] as List).isNotEmpty) {
        final first = (data['assets'] as List).first;
        if (first is Map) {
          assetId = first['id']?.toString();
        }
      }

      brandAssets.add(
        BrandAssetLink(
          assetId: assetId,
          title: title,
          subtitle: 'Page Link',
          icon: _iconForBrandAsset(title, normalizedUrl),
          url: normalizedUrl,
        ),
      );

      AppSnackbar.showSuccessSnackbar(
        title: 'Success',
        message: 'Brand asset uploaded successfully.',
      );
    } catch (e) {
      AppSnackbar.showErrorSnackbar(title: 'Error', message: e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
