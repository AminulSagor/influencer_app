import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/models/job_item.dart';
import '../../../core/services/campaign_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../create_campaign/create_campaign_controller.dart';
import '../../../core/services/api_error_handler.dart';

enum CampaignProgressStep { submitted, quoted, paid, promoting, completed }

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
  final int agencyFeePercent; // e.g. 10
  final int totalPayableExcludingFee;
  final double dollarRate;

  const PaidAdAgencyOffer({
    required this.agencyId,
    required this.name,
    this.agencyFeePercent = 10,
    this.totalPayableExcludingFee = 0,
    this.dollarRate = 0,
  });
}

class BrandCampaignDetailsController extends GetxController {
  final CampaignService _campaignService = Get.find<CampaignService>();

  // ✅ PaidAd tabs (0 = Agency Bids, 1 = Campaign Details)
  final paidAdTabIndex = 1.obs;
  void setPaidAdTab(int i) => paidAdTabIndex.value = i.clamp(0, 1);

  // ✅ PaidAd: agency bids list (screenshot 2)
  final agencyOffers = <PaidAdAgencyOffer>[].obs;
  bool _agencyBidsChecked = false;

  /// Expect either:
  /// - Get.toNamed(..., arguments: jobItem)
  /// - Get.toNamed(..., arguments: {'job': jobItem, 'campaignType': 'paidAd', ...})
  /// Also supports no args -> uses CreateCampaignController (if registered).
  final dynamic arguments;
  BrandCampaignDetailsController(this.arguments);

  JobItem? job;

  // Type (PaidAd support)
  final campaignType = ''.obs; // e.g. "paidAd"
  bool get isPaidAd {
    // ✅ prefer JobItem enum
    final j = job;
    if (j != null) return j.campaignType == CampaignType.paidAd;

    // fallback if job is not available (keeps your old routing args support)
    final v = campaignType.value.trim().toLowerCase();
    return v == 'paidad' || v == 'paid_ad' || v == 'paid-ad';
  }

  // Top Card
  final campaignTitle = ''.obs;
  final budgetText = ''.obs;

  // PaidAd: targeting row (chip)
  final targetingText = ''.obs;

  // Optional: for other types
  final influencers = <String>[].obs;
  final platforms = <IconData>[].obs;

  final daysRemaining = 0.obs;
  final deadlineDateText = ''.obs;
  final budgetStatusText = 'brand_campaign_details_budget_pending'.tr.obs;
  final dueAmount = 0.obs;
  final paidAmount = 0.obs;
  final RxnString selectedInfluencerId = RxnString();

  // Progress (no field in JobItem yet, keep default)
  final progressStep = CampaignProgressStep.quoted.obs;

  // Quote
  final baseBudget = 0.obs;
  final vatAmount = 0.obs;
  int get totalCost => baseBudget.value + vatAmount.value;

  // Milestones
  final milestones = <Milestone>[].obs;
  final milestoneStatusLabel =
      'brand_campaign_details_campaign_not_started'.tr.obs;

  // Rating
  final rating = 0.obs;

  // Brief
  final campaignGoals = ''.obs;
  final productServiceDetails = ''.obs;

  final contentRequirements = <String>[].obs;
  final dosText = ''.obs;
  final dontsText = ''.obs;

  // Assets + Terms
  final contentAssets = <JobAsset>[].obs;
  final reportingRequirements = ''.obs;
  final usageRights = ''.obs;

  // ✅ Brand Assets (PaidAd screenshot)
  final brandAssets = <BrandAssetLink>[].obs;

  // Loading state
  final isLoading = false.obs;
  final loadError = RxnString();

  // Expandables
  final briefExpanded = true.obs;
  final assetsExpanded = true.obs;
  final termsExpanded = true.obs;
  final milestonesExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();

    _showDebugSnackbar(arguments);

    // 0) read campaignType/targeting from args if provided
    _readMetaArgs(arguments);

    // 1) Try to load from navigation args (JobItem or {job: JobItem})
    final argJob = _extractJob(arguments);
    if (argJob != null) {
      job = argJob;
      _loadFromJob(argJob);
      _applyFallbacks();
      _loadFromApiIfPossible();
      return;
    }

    // 2) If coming from CreateCampaign flow, use it (old behavior)
    if (Get.isRegistered<CreateCampaignController>()) {
      final c = Get.find<CreateCampaignController>();
      _loadFromCreateCampaign(c);
      _applyFallbacks();
      _loadFromApiIfPossible();
      return;
    }

    // 3) Last resort: keep API-driven/empty state
    _loadFromApiIfPossible();
  }

  Future<void> refreshAfterMilestoneUpdate() async {
    await _loadFromApiIfPossible();
  }

  void _showDebugSnackbar(dynamic args) {
    // Disable debug snackbar to avoid LateInitializationError with GetX overlay
    // Uncomment for debugging purposes only after the widget tree is fully built
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (args is Map) {
        final totalQuotations =
            (args['totalQuotationsReceived'] as num?)?.toInt() ??
            (args['totalQuotation'] as num?)?.toInt() ??
            0;
        final hasCampaign = _isNonEmpty(args['campaign'] ?? args['campaignData']);
        final hasClient = _isNonEmpty(args['client'] ?? args['clientData']);
        final hasBids = _isNonEmpty(args['bids'] ?? args['bid'] ?? args['quotations']);

        debugPrint('Brand campaign details debug: campaign=$hasCampaign, client=$hasClient, bids=$hasBids, totalQuotations=$totalQuotations');
      }
    });
    */
  }

  bool _isNonEmpty(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
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
      milestoneStatusLabel.value = trOr(
        'brand_campaign_details_in_review',
        'In Review',
      );
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

      final tg = args['targeting'];
      if (tg is String) targetingText.value = tg;
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

  String _safeGetCampaignType(JobItem j) {
    final dj = j as dynamic;
    try {
      final v = dj.campaignType;
      if (v is String) return v;
    } catch (_) {}
    try {
      final v = dj.type;
      if (v is String) return v;
    } catch (_) {}
    return '';
  }

  String _safeGetTargeting(JobItem j) {
    final dj = j as dynamic;
    try {
      final v = dj.targeting;
      if (v is String) return v;
    } catch (_) {}
    try {
      final v = dj.targetAudience;
      if (v is String) return v;
    } catch (_) {}
    return '';
  }

  List<BrandAssetLink> _safeGetBrandAssets(JobItem j) {
    // Optional: if your JobItem already has a structure, map it here.
    // Keeping dynamic + safe parsing so this file compiles even if fields don't exist.
    final dj = j as dynamic;
    try {
      final v = dj.brandAssets;
      if (v is List) {
        final out = <BrandAssetLink>[];
        for (final item in v) {
          if (item is Map) {
            final title = (item['title'] ?? '').toString();
            final subtitle = (item['subtitle'] ?? '').toString();
            final url = item['url']?.toString();
            final kind = (item['kind'] ?? 'facebook').toString().toLowerCase();
            final icon = (kind == 'facebook')
                ? Icons.facebook
                : Icons.link_rounded;

            if (title.trim().isNotEmpty) {
              out.add(
                BrandAssetLink(
                  title: title,
                  subtitle: subtitle.isEmpty ? 'Page Link' : subtitle,
                  icon: icon,
                  url: url,
                ),
              );
            }
          }
        }
        return out;
      }
    } catch (_) {}
    return const [];
  }

  // -------------------------
  // API loading
  // -------------------------

  Future<void> _loadFromApiIfPossible() async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) return;

    try {
      isLoading.value = true;
      loadError.value = null;

      final data = await _campaignService.fetchClientCampaignDetails(
        campaignId: campaignId,
      );
      _loadFromApiMap(data);

      final progress = await _campaignService.fetchCampaignProgress(
        campaignId: campaignId,
      );
      _loadCampaignProgress(progress);

      await _loadNegotiationContext(campaignId);

      final bids = await _campaignService.fetchClientAgencyBids(
        campaignId: campaignId,
      );
      _agencyBidsChecked = true;
      if (bids.isNotEmpty) {
        _loadAgencyBids(bids);
      }
    } catch (e) {
      loadError.value = e.toString();
    } finally {
      isLoading.value = false;
      _applyFallbacks();
    }
  }

  void _loadAgencyBids(List<Map<String, dynamic>> bids) {
    if (bids.isEmpty) return;

    final mapped = bids
        .map((b) {
          final agencyId = b['agencyId']?.toString().trim() ?? '';
          final name = b['agencyName']?.toString().trim();
          final percent = _parsePercent(b['proposedServiceFeePercent']);
          final totalExcl = _numToInt(
            b['totalpayableExcludingAgencyServiceFee'],
          );
          final fx = _numToDouble(b['dollarRate']);

          if (agencyId.isEmpty) return null;

          return PaidAdAgencyOffer(
            agencyId: agencyId,
            name: (name == null || name.isEmpty) ? 'Agency' : name,
            agencyFeePercent: percent <= 0 ? 10 : percent,
            totalPayableExcludingFee: totalExcl,
            dollarRate: fx,
          );
        })
        .whereType<PaidAdAgencyOffer>()
        .toList(growable: false);

    if (mapped.isNotEmpty) agencyOffers.assignAll(mapped);
  }

  void _loadFromApiMap(Map<String, dynamic> data) {
    // Type
    final ct = data['campaignType']?.toString() ?? '';
    if (ct.isNotEmpty) campaignType.value = ct;

    // Top
    final title = data['campaignName']?.toString().trim();
    if (title != null && title.isNotEmpty) campaignTitle.value = title;

    final totalBudget = _numToDouble(data['totalBudget']);
    if (totalBudget > 0) budgetText.value = formatCurrencyByLocale(totalBudget);

    // Rating
    rating.value = (_numToDouble(data['rating']).round()).clamp(0, 5);
    selectedInfluencerId.value = _extractInfluencerId(data);

    // Quote breakdown
    final base = _numToDouble(data['baseBudget']).round();
    final vat = _numToDouble(data['vatAmount']).round();
    if (base > 0) baseBudget.value = base;
    if (vat > 0) vatAmount.value = vat;

    // Budget status
    final dueAmount = _numToDouble(data['dueAmount']);
    final paid = _numToDouble(data['paidAmount']);
    this.dueAmount.value = dueAmount.round();
    paidAmount.value = paid.round();
    if (dueAmount <= 0) {
      budgetStatusText.value = trOr(
        'brand_campaign_details_budget_paid',
        'Paid',
      );
    } else {
      budgetStatusText.value = 'brand_campaign_details_budget_pending'.tr;
    }

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

  void _loadCampaignProgress(Map<String, dynamic> response) {
    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    final rawStatus =
        (data['status'] ?? data['campaignStatus'] ?? data['progress'])
            ?.toString()
            .toLowerCase()
            .trim();

    if (rawStatus == null || rawStatus.isEmpty) return;

    if (rawStatus.contains('complete') || rawStatus.contains('completed')) {
      progressStep.value = CampaignProgressStep.completed;
      return;
    }
    if (rawStatus.contains('promot')) {
      progressStep.value = CampaignProgressStep.promoting;
      return;
    }
    if (rawStatus.contains('paid') || rawStatus.contains('payment')) {
      progressStep.value = CampaignProgressStep.paid;
      return;
    }
    if (rawStatus.contains('quote') || rawStatus.contains('negotiat')) {
      progressStep.value = CampaignProgressStep.quoted;
      return;
    }

    progressStep.value = CampaignProgressStep.submitted;
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
      final fileUrl = item['fileUrl']?.toString().trim();
      final fileSize = _numToInt(item['fileSize']);
      final mime = item['mimeType']?.toString().trim() ?? '';
      final assetType = item['assetType']?.toString().trim();

      if (category == 'brand') {
        final icon = _iconForBrandAsset(fileName, fileUrl);
        brand.add(
          BrandAssetLink(
            assetId: item['id']?.toString(),
            title: fileName.isNotEmpty
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
            title: fileName.isNotEmpty ? fileName : 'Asset',
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

    final mapped = <Milestone>[];
    for (final raw in list) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);

      final title = item['contentTitle']?.toString().trim() ?? 'Milestone';
      final quantity = item['contentQuantity']?.toString().trim();
      final deliveryDays = (item['deliveryDays'] as num?)?.toInt();
      final order = (item['order'] as num?)?.toInt();
      final amount = _numToDouble(item['amount']).round();
      final platform = item['platform']?.toString();
      final status = _parseMilestoneStatus(item['status']?.toString());

      mapped.add(
        Milestone(
          stepLabel: ((order ?? mapped.length) + 1).toString(),
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

    if (mapped.isNotEmpty) milestones.assignAll(mapped);
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
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _numToDouble(dynamic value) {
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
    rating.value = (j.rating ?? 0).clamp(0, 5);

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

  void _applyFallbacks() {
    _recomputeMilestoneStatusLabel();
  }

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
    rating.value = next;

    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) return;
    if (next <= 0) return;

    if (isPaidAd) {
      ApiErrorHandler.call(
        () => _campaignService.rateAgency(campaignId: campaignId, rating: next),
        showError: false,
      );
      return;
    }

    final influencerId = selectedInfluencerId.value?.trim();
    if (influencerId == null || influencerId.isEmpty) {
      Get.snackbar(
        trOr('common_error', 'Error'),
        trOr('brand_campaign_missing_influencer', 'Missing influencer id.'),
      );
      return;
    }

    ApiErrorHandler.call(
      () => _campaignService.rateInfluencer(
        campaignId: campaignId,
        influencerId: influencerId,
        rating: next,
      ),
      showError: false,
    );
  }

  void onRequestQuote() {
    if (isPaidAd) {
      _openPaidAdRequoteDialog(); // new UI (your screenshots 1 & 2)
    } else {
      _openRequoteDialog(); // keep your previous one (already in file)
    }
  }

  Future<void> onAcceptQuote() async {
    final ok = await _acceptQuoteRequest();
    if (!ok) return;

    if (isPaidAd) {
      setPaidAdTab(0);
      // _openConfirmBudgetDialog(); // new UI (your screenshots 3 & 4)
    } else {
      _openFundCampaignDialog(); // keep your previous one
    }
  }

  Future<void> onAcceptAgencyOfferAndPay(PaidAdAgencyOffer offer) async {
    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      Get.snackbar(
        trOr('common_error', 'Error'),
        trOr('brand_campaign_missing_id', 'Missing campaign id.'),
      );
      return;
    }

    final accepted = await _acceptQuoteRequest();
    if (!accepted) return;

    try {
      isLoading.value = true;
      await _campaignService.selectAgencyForCampaign(
        campaignId: campaignId,
        agencyId: offer.agencyId,
      );
      await _loadFromApiIfPossible();
      _openFundCampaignDialog();
    } catch (e) {
      Get.snackbar(trOr('common_error', 'Error'), _errorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void onDownloadAsset(int index) {
    Get.snackbar(
      'brand_campaign_details_assets'.tr,
      'brand_campaign_details_download_msg'.tr,
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
      Get.snackbar(
        trOr('common_error', 'Error'),
        trOr('brand_campaign_missing_id', 'Missing campaign id.'),
      );
      return false;
    }

    try {
      isLoading.value = true;
      await _campaignService.acceptNegotiation(campaignId: campaignId);
      await _loadFromApiIfPossible();
      Get.snackbar(
        trOr('brand_campaign_details_accept_quote', 'Accept Quote'),
        trOr('brand_campaign_details_accept_quote_msg', 'Quote accepted.'),
      );
      return true;
    } catch (e) {
      Get.snackbar(trOr('common_error', 'Error'), _errorMessage(e));
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
      Get.snackbar(
        trOr('common_error', 'Error'),
        trOr('brand_campaign_requote_invalid', 'Please enter a valid budget.'),
      );
      return;
    }

    final campaignId = _extractCampaignId(arguments);
    if (campaignId == null || campaignId.trim().isEmpty) {
      Get.snackbar(
        trOr('common_error', 'Error'),
        trOr('brand_campaign_missing_id', 'Missing campaign id.'),
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

      Get.snackbar(
        trOr('brand_campaign_details_quote', 'Quote'),
        trOr('brand_campaign_requote_sent', 'Requote request sent to admin.'),
      );

      await _loadFromApiIfPossible();
    } catch (e) {
      Get.snackbar(trOr('common_error', 'Error'), _errorMessage(e));
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

  // ✅ same behavior as CreateCampaign Step 5 dialog (content assets)
  final TextEditingController _assetTitleCtrl = TextEditingController();

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
    _assetTitleCtrl.clear();

    final pickedName = RxnString();
    final pickedBytes = RxnInt();
    final pickedPath = RxnString();
    final pickedKind = JobAssetKind.other.obs;
    final isPicking = false.obs;

    Future<void> pickFile() async {
      try {
        isPicking.value = true;

        final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.any,
          withData: false,
        );

        if (result == null || result.files.isEmpty) return;

        final f = result.files.single;
        pickedName.value = f.name;
        pickedBytes.value = f.size;
        pickedPath.value = f.path;
        pickedKind.value = _guessAssetKind(f.name);
      } finally {
        isPicking.value = false;
      }
    }

    const primary = Color(0xFF2F4F1F);
    const bg = Color(0xFFF6F7F7);
    const softBorder = Color(0xFFBFD7A5);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'brand_campaign_details_upload_another_asset'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999.r),
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: primary.withOpacity(.6),
                      ),
                    ),
                  ),
                ],
              ),
              14.h.verticalSpace,
              TextField(
                controller: _assetTitleCtrl,
                decoration: InputDecoration(
                  hintText: 'create_campaign_asset_name_hint'.tr,
                  filled: true,
                  fillColor: bg,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: softBorder, width: 1.4),
                  ),
                ),
              ),
              12.h.verticalSpace,
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isPicking.value ? null : pickFile,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 46.h),
                      side: const BorderSide(color: softBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.upload_outlined,
                      color: primary.withOpacity(.7),
                    ),
                    label: Text(
                      isPicking.value
                          ? 'create_campaign_picking_file'.tr
                          : 'create_campaign_pick_file'.tr,
                      style: TextStyle(
                        color: primary.withOpacity(.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
              10.h.verticalSpace,
              Obx(() {
                final name = pickedName.value;
                final bytes = pickedBytes.value;

                if (name == null || bytes == null) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      'create_campaign_no_file_selected'.tr,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                final ext = _extUpper(name);
                final sizeText = _formatBytes(bytes);

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: softBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconForAsset(pickedKind.value),
                        color: primary.withOpacity(.7),
                      ),
                      10.w.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: primary.withOpacity(.8),
                              ),
                            ),
                            2.h.verticalSpace,
                            Text(
                              '$ext • $sizeText',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: primary.withOpacity(.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              14.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('common_cancel'.tr),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: Obx(() {
                      final canSave =
                          pickedName.value != null && pickedBytes.value != null;

                      return ElevatedButton(
                        onPressed: canSave
                            ? () {
                                final name = pickedName.value!;
                                final bytes = pickedBytes.value!;
                                final path = pickedPath.value;

                                final ext = _extUpper(name);
                                final meta = '$ext – ${_formatBytes(bytes)}';

                                final customTitle = _assetTitleCtrl.text.trim();
                                final fallbackTitle = _filenameNoExt(name);
                                final title = customTitle.isNotEmpty
                                    ? customTitle
                                    : fallbackTitle;

                                contentAssets.add(
                                  JobAsset(
                                    title: title,
                                    meta: meta,
                                    kind: pickedKind.value,
                                    pathOrUrl: path,
                                  ),
                                );

                                Get.back();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 46.h),
                          backgroundColor: primary.withOpacity(
                            canSave ? .75 : .35,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text('common_done'.tr),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ✅ very simple "add brand asset" dialog (link-based)
  void openUploadAnotherBrandAssetDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    const primary = Color(0xFF2F4F1F);
    const bg = Color(0xFFF6F7F7);
    const softBorder = Color(0xFFBFD7A5);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'brand_campaign_details_upload_another_brand_asset'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999.r),
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: primary.withOpacity(.6),
                      ),
                    ),
                  ),
                ],
              ),
              14.h.verticalSpace,
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: 'brand_campaign_details_brand_asset_title_hint'.tr,
                  filled: true,
                  fillColor: bg,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: softBorder, width: 1.4),
                  ),
                ),
              ),
              10.h.verticalSpace,
              TextField(
                controller: urlCtrl,
                decoration: InputDecoration(
                  hintText: 'brand_campaign_details_brand_asset_link_hint'.tr,
                  filled: true,
                  fillColor: bg,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: softBorder, width: 1.4),
                  ),
                ),
              ),
              14.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('common_cancel'.tr),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final t = titleCtrl.text.trim();
                        final u = urlCtrl.text.trim();
                        if (t.isEmpty) return;

                        brandAssets.add(
                          BrandAssetLink(
                            title: t,
                            subtitle: 'Page Link',
                            icon: Icons.link_rounded,
                            url: u.isEmpty ? null : u,
                          ),
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        backgroundColor: primary.withOpacity(.75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text('common_done'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
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
    const primary = Color(0xFF2F4F1F);
    const borderGreen = Color(0xFFBFD7A5);
    const softFill = Color(0xFFF7FAF3);

    const int vatPercent = 15;
    const int minAgencyPercent = 5;
    const int maxAgencyPercent = 15;
    const double fxRate = 122.37; // avg BDT/$

    final startBudget = baseBudget.value > 0 ? baseBudget.value : 100000;

    final budgetRx = startBudget.obs;
    final vatRx = 0.obs;
    final totalRx = 0.obs;

    final minFeeRx = 0.obs;
    final maxFeeRx = 0.obs;

    final minExclRx = 0.obs;
    final maxExclRx = 0.obs;

    final minUsdRx = 0.0.obs;
    final maxUsdRx = 0.0.obs;

    final budgetCtrl = TextEditingController(text: _fmt(startBudget));

    void recalc(int budget) {
      final b = budget.clamp(0, 999999999);
      final vat = (b * vatPercent / 100).round();
      final total = b + vat;

      final minFee = (total * (minAgencyPercent / 100)).round();
      final maxFee = (total * (maxAgencyPercent / 100)).round();

      final minExcl = (total - maxFee).clamp(0, total);
      final maxExcl = (total - minFee).clamp(0, total);

      budgetRx.value = b;
      vatRx.value = vat;
      totalRx.value = total;

      minFeeRx.value = minFee;
      maxFeeRx.value = maxFee;

      minExclRx.value = minExcl;
      maxExclRx.value = maxExcl;

      minUsdRx.value = fxRate <= 0 ? 0 : (minExcl / fxRate);
      maxUsdRx.value = fxRate <= 0 ? 0 : (maxExcl / fxRate);
    }

    recalc(startBudget);

    Get.dialog(
      Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trOr('brand_campaign_requote_title', 'Requote'),
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.75),
                  ),
                ),
                8.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_subtitle',
                    'Requote your campaign budget',
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                12.h.verticalSpace,

                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (v) => recalc(_parseAmount(v)),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: borderGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: primary, width: 1.4),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.75),
                  ),
                ),

                14.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_overview',
                    'New Requote Overview',
                  ),
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                10.h.verticalSpace,

                // Box 1: base/vat/total
                Obx(() {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: softFill,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderGreen),
                    ),
                    child: Column(
                      children: [
                        _kv(
                          left: 'Base Campaign Budget',
                          right: _fmt(budgetRx.value),
                          color: primary,
                        ),
                        8.h.verticalSpace,
                        _kv(
                          left: 'VAT/Tax (15%)',
                          right: _fmt(vatRx.value),
                          color: primary,
                        ),
                        12.h.verticalSpace,
                        Divider(color: Colors.black12, height: 1),
                        12.h.verticalSpace,
                        _kv(
                          left: 'Total Campaign Cost',
                          right: _fmt(totalRx.value),
                          color: primary,
                          strong: true,
                        ),
                      ],
                    ),
                  );
                }),

                12.h.verticalSpace,

                // Box 2: agency fee range + excl + usd
                Obx(() {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: softFill,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderGreen),
                    ),
                    child: Column(
                      children: [
                        _rangeKv(
                          left: 'Agency Fee (5 - 15%)',
                          right:
                              '${_fmt(minFeeRx.value)} – ${_fmt(maxFeeRx.value)}',
                          color: primary,
                        ),
                        10.h.verticalSpace,
                        _rangeKv(
                          left: 'Campaign Budget Excluding Agency Fee',
                          right:
                              '${_fmt(minExclRx.value)} – ${_fmt(maxExclRx.value)}',
                          color: primary,
                        ),
                        10.h.verticalSpace,
                        _rangeKv(
                          left: 'In Dollars (Based On Avg. 122.37 BDT/\$)',
                          right:
                              '\$${minUsdRx.value.toStringAsFixed(2)} – \$${maxUsdRx.value.toStringAsFixed(2)}',
                          color: primary,
                        ),
                      ],
                    ),
                  );
                }),

                16.h.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _submitRequote(
                        proposedBaseBudget: budgetRx.value,
                        vatAmountValue: vatRx.value,
                        closeDialog: true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary.withOpacity(.65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      trOr('brand_campaign_requote_submit', 'Requote To Admin'),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _rangeKv({
    required String left,
    required String right,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
        10.w.horizontalSpace,
        Text(
          right,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(.75),
          ),
        ),
      ],
    );
  }

  void _openRequoteDialog() {
    const primary = Color(0xFF2F4F1F);
    const borderGreen = Color(0xFFBFD7A5);
    const softFill = Color(0xFFF7FAF3);

    final vatPercent = 15;
    final budget = baseBudget.value <= 0 ? 100000 : baseBudget.value;

    final budgetRx = budget.obs;
    final vatRx = (budget * vatPercent ~/ 100).obs;
    final totalRx = (budgetRx.value + vatRx.value).obs;

    final budgetCtrl = TextEditingController(text: _fmt(budget));

    void recalcFrom(int b) {
      budgetRx.value = b;
      vatRx.value = (b * vatPercent / 100).round();
      totalRx.value = b + vatRx.value;
    }

    recalcFrom(budgetRx.value);

    Get.dialog(
      Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trOr('brand_campaign_requote_title', 'Requote'),
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.75),
                  ),
                ),
                8.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_subtitle',
                    'Requote your campaign budget',
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                12.h.verticalSpace,

                // Input
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final b = _parseAmount(v);
                    recalcFrom(b);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: borderGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: primary, width: 1.4),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.75),
                  ),
                  textAlign: TextAlign.center,
                ),

                14.h.verticalSpace,
                Text(
                  trOr(
                    'brand_campaign_requote_overview',
                    'New Requote Overview',
                  ),
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                10.h.verticalSpace,

                // Overview box
                Obx(() {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: softFill,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderGreen),
                    ),
                    child: Column(
                      children: [
                        _kv(
                          left: trOr(
                            'brand_campaign_requote_base',
                            'Base Campaign Budget',
                          ),
                          right: _fmt(budgetRx.value),
                          color: primary,
                        ),
                        8.h.verticalSpace,
                        _kv(
                          left: trOr(
                            'brand_campaign_requote_vat',
                            'VAT/Tax (15%)',
                          ),
                          right: _fmt(vatRx.value),
                          color: primary,
                        ),
                        12.h.verticalSpace,
                        Divider(color: Colors.black12, height: 1),
                        12.h.verticalSpace,
                        _kv(
                          left: trOr(
                            'brand_campaign_requote_total',
                            'Total Campaign Cost',
                          ),
                          right: _fmt(totalRx.value),
                          color: primary,
                          strong: true,
                        ),
                      ],
                    ),
                  );
                }),

                16.h.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _submitRequote(
                        proposedBaseBudget: budgetRx.value,
                        vatAmountValue: vatRx.value,
                        closeDialog: true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary.withOpacity(.65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      trOr('brand_campaign_requote_submit', 'Requote To Admin'),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _kv({
    required String left,
    required String right,
    required Color color,
    bool strong = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: strong ? 14.sp : 13.sp,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(.75),
          ),
        ),
      ],
    );
  }

  void _openConfirmBudgetDialog() {
    const primary = Color(0xFF2F4F1F);
    const borderGreen = Color(0xFFBFD7A5);
    const softFill = Color(0xFFF7FAF3);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trOr('brand_campaign_confirm_title', 'Confirm Budget ?'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: primary.withOpacity(.75),
                ),
              ),
              12.h.verticalSpace,

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: softFill,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderGreen),
                ),
                child: Column(
                  children: [
                    _kv(
                      left: 'Base Campaign Budget',
                      right: _fmt(baseBudget.value),
                      color: primary,
                    ),
                    10.h.verticalSpace,
                    _kv(
                      left: 'VAT/Tax (15%)',
                      right: _fmt(vatAmount.value),
                      color: primary,
                    ),
                  ],
                ),
              ),

              14.h.verticalSpace,
              Text(
                'Total Campaign Cost',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              6.h.verticalSpace,
              Text(
                _fmt(totalCost),
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w900,
                  color: primary.withOpacity(.75),
                ),
              ),

              18.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        _openPaidAdRequoteDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        trOr('brand_campaign_details_requote', 'Requote'),
                      ),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await _acceptQuoteRequest();
                        if (ok) {
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        backgroundColor: primary.withOpacity(.65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        trOr('brand_campaign_confirm_btn', 'Confirm'),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _openFundCampaignDialog() {
    const primary = Color(0xFF2F4F1F);
    const cardGreen = Color(0xFF5E7D3A);
    const warnBg = Color(0xFFFFE6CF);
    const warnBorder = Color(0xFFEF9F59);

    final totalDue = dueAmount.value > 0
        ? dueAmount.value
        : (totalCost <= 0 ? 18000 : totalCost);
    final minPay = (totalDue * 0.5).round();

    final amountRx = totalDue.obs;
    final amountCtrl = TextEditingController(text: _fmt(totalDue));
    final methodRx = 'card'.obs;

    void setAmount(int v) {
      amountRx.value = v;
      amountCtrl.text = _fmt(v);
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.black12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trOr('brand_campaign_fund_title', 'Fund Your Campaign'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: primary.withOpacity(.85),
                  ),
                ),
                12.h.verticalSpace,

                // Top green card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: cardGreen,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            color: Colors.white.withOpacity(.9),
                            size: 18.sp,
                          ),
                          10.w.horizontalSpace,
                          Expanded(
                            child: Text(
                              campaignTitle.value.isEmpty
                                  ? 'Summer Fashion Campaign'
                                  : campaignTitle.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.95),
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.h.verticalSpace,
                      Text(
                        trOr('brand_campaign_fund_total_due', 'Total Due'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(.85),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      6.h.verticalSpace,
                      Text(
                        _fmt(totalDue),
                        style: TextStyle(
                          color: const Color(0xFFE9F3D8),
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                12.h.verticalSpace,

                // Minimum warning
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: warnBg,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: warnBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        trOr(
                          'brand_campaign_fund_minimum_label',
                          'Minimum Fund Needed To Start The Campaign (50%)',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: warnBorder,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      8.h.verticalSpace,
                      Text(
                        _fmt(minPay),
                        style: TextStyle(
                          color: warnBorder,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                12.h.verticalSpace,

                // Amount input
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amountRx.value = _parseAmount(v),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: primary.withOpacity(.7)),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                ),

                10.h.verticalSpace,

                // Quick buttons
                Row(
                  children: [
                    Expanded(
                      child: _pillBtn(
                        text: trOr(
                          'brand_campaign_fund_full',
                          'Pay In Full (100%)',
                        ),
                        onTap: () => setAmount(totalDue),
                      ),
                    ),
                    10.w.horizontalSpace,
                    Expanded(
                      child: _pillBtn(
                        text: trOr(
                          'brand_campaign_fund_min',
                          'Pay Minimum (50%)',
                        ),
                        onTap: () => setAmount(minPay),
                      ),
                    ),
                  ],
                ),
                10.h.verticalSpace,
                _pillBtn(
                  text: trOr('brand_campaign_fund_75', 'Pay (75%)'),
                  onTap: () => setAmount((totalDue * 0.75).round()),
                ),

                18.h.verticalSpace,

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    trOr('brand_campaign_fund_method', 'Payment Method'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: primary.withOpacity(.85),
                    ),
                  ),
                ),
                10.h.verticalSpace,

                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: methodRx.value,
                    items: [
                      DropdownMenuItem(
                        value: 'card',
                        child: Text(
                          trOr(
                            'brand_campaign_fund_card',
                            'Credit / Debit Card',
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'bkash',
                        child: Text(trOr('brand_campaign_fund_bkash', 'bKash')),
                      ),
                    ],
                    onChanged: (v) => methodRx.value = v ?? 'card',
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: primary.withOpacity(.7)),
                      ),
                    ),
                  );
                }),

                14.h.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: Obx(() {
                    final amt = amountRx.value;
                    final canPay = amt >= minPay && amt <= totalDue;

                    return ElevatedButton(
                      onPressed: canPay
                          ? () async {
                              final campaignId = _extractCampaignId(arguments);
                              if (campaignId == null ||
                                  campaignId.trim().isEmpty) {
                                Get.snackbar(
                                  trOr('common_error', 'Error'),
                                  trOr(
                                    'brand_campaign_missing_id',
                                    'Missing campaign id.',
                                  ),
                                );
                                return;
                              }

                              final amount = amt;
                              final isDuePayment = paidAmount.value > 0;

                              try {
                                isLoading.value = true;
                                if (isDuePayment) {
                                  await _campaignService.payCampaignDue(
                                    campaignId: campaignId,
                                    amount: amount,
                                  );
                                } else {
                                  await _campaignService.payCampaignAmount(
                                    campaignId: campaignId,
                                    amount: amount,
                                  );
                                }

                                await _loadFromApiIfPossible();
                                Get.back();
                                Get.snackbar(
                                  trOr('brand_campaign_payment', 'Payment'),
                                  trOr(
                                    'brand_campaign_payment_success',
                                    'Payment initiated.',
                                  ),
                                );
                              } catch (e) {
                                Get.snackbar(
                                  trOr('common_error', 'Error'),
                                  _errorMessage(e),
                                );
                              } finally {
                                isLoading.value = false;
                              }
                            }
                          : () {
                              Get.snackbar(
                                trOr('common_error', 'Error'),
                                trOr(
                                  'brand_campaign_payment_invalid',
                                  'Amount must be between minimum and total due.',
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canPay
                            ? primary.withOpacity(.18)
                            : Colors.black12,
                        foregroundColor: canPay
                            ? Colors.black87
                            : Colors.black38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        trOr('brand_campaign_pay_now', 'Pay Now'),
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _pillBtn({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _loadNegotiationContext(String campaignId) async {
    final history = await _campaignService.fetchNegotiationHistory(
      campaignId: campaignId,
    );
    final data = history['data'] is Map
        ? Map<String, dynamic>.from(history['data'] as Map)
        : const <String, dynamic>{};
    final negotiations = (data['negotiations'] as List?) ?? const [];

    if (negotiations.isEmpty) return;

    final latest = negotiations.firstWhere((e) => e is Map, orElse: () => null);
    if (latest is! Map) return;

    final latestMap = Map<String, dynamic>.from(latest);
    final latestProposedBase = _numToInt(latestMap['proposedBaseBudget']);
    if (latestProposedBase > 0) {
      baseBudget.value = latestProposedBase;
      final vat =
          _numToInt(latestMap['proposedTotalBudget']) - latestProposedBase;
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
}
