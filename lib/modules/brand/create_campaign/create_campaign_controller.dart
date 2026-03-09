import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';
import 'package:influencer_app/routes/app_routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../core/models/job_item.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/campaign_service.dart';
import '../../ad_agency/services/upload_service.dart';

part 'widgets/create_campaign_sheets.dart';
part 'widgets/create_campaign_dialogs.dart';

class AdAgencyUiModel {
  final String id;
  final String name;
  final String logo;
  final String subtitle;
  const AdAgencyUiModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.logo,
  });
}

class InfluencerUiModel {
  final String id;
  final String name;
  final String? avatar;
  final double? rating;

  const InfluencerUiModel({
    required this.id,
    required this.name,
    this.avatar,
    this.rating,
  });
}

class CreateCampaignController extends GetxController {
  dynamic arguments;
  CreateCampaignController(this.arguments);

  final CampaignService _campaignService = Get.find<CampaignService>();
  final UploadService _uploadService = Get.find<UploadService>();

  final isSavingStep = false.obs;
  final campaignId = RxnString();

  final campaignNameCtrl = TextEditingController();
  final campaignName = ''.obs;
  final selectedType = Rxn<CampaignType>();

  final selectedProductType = RxnString();
  final selectedInfluencerNiche = RxnString();

  final preferredInputCtrl = TextEditingController();
  final notPreferredInputCtrl = TextEditingController();

  final preferredInfluencers = <String>[].obs;
  final notPreferredInfluencers = <String>[].obs;

  final selectedPaidAdNiche = RxnString();

  // ── Multi-select agencies ──
  final selectedAgencyIds = <String>[].obs;

  final agencyQuery = ''.obs;
  final agencySearchCtrl = TextEditingController();

  // ── Recommended agencies (fetched WITH niche) ──
  final recommendedAgencyScroll = ScrollController();
  int _recAgencyPage = 1;
  bool _isRecAgencyLoading = false;
  bool _hasMoreRecAgencies = true;
  final recommendedAgencies = <AdAgencyUiModel>[].obs;

  // ── Other agencies (fetched WITHOUT niche) ──
  final step2Scroll = ScrollController();
  int _otherAgencyPage = 1;
  final isOtherAgencyLoading = false.obs;
  bool _hasMoreOtherAgencies = true;
  final otherAgencies = <AdAgencyUiModel>[].obs;

  final productTypeOptions = <String>[].obs;
  final nicheOptions = <String>[].obs;

  final influencers = <InfluencerUiModel>[].obs;
  final isLoadingLookups = false.obs;

  final campaignGoalsCtrl = TextEditingController();
  final productServiceCtrl = TextEditingController();
  final dosCtrl = TextEditingController();
  final dontsCtrl = TextEditingController();
  final dosText = ''.obs;
  final dontsText = ''.obs;
  final dosLines = <String>[].obs;
  final dontsLines = <String>[].obs;

  final reportingReqCtrl = TextEditingController();
  final usageRightsCtrl = TextEditingController();

  final startDate = Rxn<DateTime>();
  final durationCtrl = TextEditingController();

  final campaignGoals = ''.obs;
  final productServiceDetails = ''.obs;
  final reportingRequirements = ''.obs;
  final usageRights = ''.obs;
  final duration = ''.obs;

  static const double _vatPercentConst = 0.15;
  static const int _minBudget = 25000;

  final budgetTextCtrl = TextEditingController();
  final baseBudget = 0.0.obs;

  final budgetSuggestions = const [30000, 50000, 80000, 100000];

  final milestonesExpanded = true.obs;
  final milestones = <Milestone>[].obs;

  final isAddingMilestone = false.obs;

  final editingMilestoneIndex = RxnInt();

  final milestoneTitleCtrl = TextEditingController();
  final milestoneDeliverableCtrl = TextEditingController();

  final milestoneMetricTitleCtrl = TextEditingController();
  final milestoneMetricAmountCtrl = TextEditingController();

  final selectedMilestonePlatform = RxnString();
  final selectedMilestoneDay = RxnInt();

  final reachCtrl = TextEditingController();
  final viewsCtrl = TextEditingController();
  final likesCtrl = TextEditingController();
  final commentsCtrl = TextEditingController();
  final promoGoalCtrl = TextEditingController();

  final platformOptions = const ['Facebook', 'Instagram', 'YouTube', 'TikTok'];

  double get vatPercent => _vatPercentConst;
  int get minBudget => _minBudget;

  double get vatAmount => baseBudget.value * vatPercent;
  double get totalBudgetIncTax => baseBudget.value + vatAmount;

  final contentAssets = <JobAsset>[].obs;

  final needToSendSample = false.obs;
  final sampleGuidelinesConfirmed = false.obs;

  final brandAssets = <BrandAsset>[].obs;

  final assetTitleCtrl = TextEditingController();
  final brandTitleCtrl = TextEditingController();
  final brandValueCtrl = TextEditingController();

  final currentStep = 1.obs;
  int get totalSteps => 6;

  double get progress => currentStep.value / totalSteps;
  String get progressPercentText => '${(progress * 100).round()}%';

  String get stepText =>
      '${'create_campaign_step'.tr} ${currentStep.value} ${'create_campaign_of'.tr} $totalSteps';

  final createdJobItem = Rxn<JobItem>();

  JobItem buildFinalJobItem() {
    final type = selectedType.value;
    if (type == null) {
      throw Exception('CampaignType is required but not selected.');
    }

    final title = campaignName.value.trim().isNotEmpty
        ? campaignName.value.trim()
        : campaignNameCtrl.text.trim();

    final vatPercentAs100 = vatPercent * 100;

    return JobItem(
      title: title.isNotEmpty ? title : 'Untitled Campaign',
      clientName: 'Brand',
      campaignType: type,
      dateLabel: deadlineLabelForStep6,
      budget: totalBudgetIncTax,
      sharePercent: 0,
      dueInDays: _durationDays,
      baseBudget: baseBudget.value,
      vatPercent: vatPercentAs100,
      vatAmount: vatAmount,
      netPayableBudget: totalBudgetIncTax,
      contentAssets: contentAssets.toList(growable: false),
      brandAssets: brandAssets.toList(growable: false),
      needToSendSample: needToSendSample.value,
      sampleGuidelinesConfirmed: sampleGuidelinesConfirmed.value,
      milestones: milestones.toList(growable: false),
      dosText: dosText.value.trim().isNotEmpty ? dosText.value : dosCtrl.text,
      dontsText: dontsText.value.trim().isNotEmpty
          ? dontsText.value
          : dontsCtrl.text,
      subTitle: null,
    );
  }

  bool get canGoNext {
    final step = currentStep.value;

    if (step == 1) {
      return campaignName.value.trim().isNotEmpty && selectedType.value != null;
    }

    if (step == 2) {
      final type = selectedType.value;
      if (type == CampaignType.influencerPromotion) {
        return selectedProductType.value != null &&
            (selectedInfluencerNiche.value != null &&
                selectedInfluencerNiche.value!.trim().isNotEmpty);
      }
      if (type == CampaignType.paidAd) {
        return selectedPaidAdNiche.value != null &&
            selectedAgencyIds.isNotEmpty;
      }
    }

    if (step == 3) {
      return campaignGoals.value.trim().isNotEmpty &&
          productServiceDetails.value.trim().isNotEmpty &&
          reportingRequirements.value.trim().isNotEmpty &&
          usageRights.value.trim().isNotEmpty &&
          startDate.value != null &&
          duration.value.trim().isNotEmpty;
    }

    if (step == 4) {
      return baseBudget.value >= minBudget && milestones.isNotEmpty;
    }

    if (step == 5) {
      if (selectedType.value == CampaignType.influencerPromotion) {
        if (needToSendSample.value) return sampleGuidelinesConfirmed.value;
      }
      return true;
    }

    return true;
  }

  @override
  void onInit() {
    super.onInit();

    // listeners (keep your existing ones)
    recommendedAgencyScroll.addListener(_onRecommendedAgencyScroll);
    step2Scroll.addListener(_onStep2PageScroll);

    // load lookups first (types/niches/agencies/influencers)
    _boot();
  }

  Future<void> _boot() async {
    final passedId = _readCampaignIdFromArgs(arguments);

    await _loadStep2Lookups();

    if (passedId != null && passedId.trim().isNotEmpty) {
      campaignId.value = passedId;
      currentStep.value = 2;

      await _prefillFromCampaignDetails(passedId);
    }
  }

  Future<void> _prefillFromCampaignDetails(String id) async {
    await ApiErrorHandler.call(() async {
      final payload = await _campaignService.fetchClientCampaignDetails(
        campaignId: id,
      );

      // payload shape is: { id, campaignName, campaignType, campaignNiche, ... }
      // and has nested client, paymentInfo, etc.

      final name = payload['campaignName']?.toString() ?? '';
      final typeRaw = payload['campaignType']?.toString() ?? '';
      final niche = payload['campaignNiche']?.toString();
      final productType = payload['productType']?.toString();

      // ---- Step 1 fields (optional but good to set) ----
      campaignNameCtrl.text = name;
      campaignName.value = name;

      final type = _parseCampaignTypeFromApi(typeRaw);
      selectedType.value = type;

      // ---- Step 2 fields ----
      if (type == CampaignType.influencerPromotion) {
        selectedProductType.value =
            (productType != null && productType.trim().isNotEmpty)
            ? productType
            : null;

        selectedInfluencerNiche.value =
            (niche != null && niche.trim().isNotEmpty) ? niche : null;

        // preferred / not preferred ids (API currently returns arrays)
        preferredInfluencers
          ..clear()
          ..addAll(_stringList(payload['preferredInfluencers']));
        notPreferredInfluencers
          ..clear()
          ..addAll(_stringList(payload['notPreferableInfluencers']));

        // OPTIONAL: if those arrays are not ids but objects later, you can map them here.
      } else {
        // paid_ad flow
        selectedPaidAdNiche.value = (niche != null && niche.trim().isNotEmpty)
            ? niche
            : null;

        // Your API shows `selectedAgencyId` (single) currently.
        // Your UI uses multi-select `selectedAgencyIds`.
        selectedAgencyIds.clear();
        final selectedAgencyId = payload['selectedAgencyId']?.toString();
        if (selectedAgencyId != null && selectedAgencyId.trim().isNotEmpty) {
          selectedAgencyIds.add(selectedAgencyId);
        }

        // reload recommended agencies based on niche (if any)
        if (selectedPaidAdNiche.value != null) {
          await _loadRecommendedAgencyPage(reset: true);
        }
      }

      // If backend gives currentStep, keep local step aligned
      // final step = payload['currentStep'];
      // final stepInt = (step is num)
      //     ? step.toInt()
      //     : int.tryParse(step?.toString() ?? '');
      // if (stepInt != null && stepInt >= 1 && stepInt <= totalSteps) {
      //   currentStep.value = stepInt;
      // } else {
      //   currentStep.value = 2;
      // }

      return true;
    }, showError: false);
  }

  CampaignType _parseCampaignTypeFromApi(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'paid_ad' || v == 'paidad') return CampaignType.paidAd;
    return CampaignType.influencerPromotion;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  String? _readCampaignIdFromArgs(dynamic args) {
    if (args == null) return null;
    if (args is String) return args;

    if (args is Map) {
      final v = args['campaignId'] ?? args['id'];
      return v?.toString();
    }
    return null;
  }

  Future<void> _loadStep2Lookups() async {
    if (isLoadingLookups.value) return;
    isLoadingLookups.value = true;

    await ApiErrorHandler.call(() async {
      final types = await _campaignService.fetchProductTypes();
      if (types.isNotEmpty) {
        productTypeOptions
          ..clear()
          ..addAll(types);
      }

      final niches = await _campaignService.fetchNiches();
      if (niches.isNotEmpty) {
        nicheOptions
          ..clear()
          ..addAll(niches);
      }

      // Load other agencies (no niche filter) on init
      await _loadOtherAgencyPage(reset: true);

      return true;
    }, showError: false);

    isLoadingLookups.value = false;
  }

  // ── Recommended agencies (WITH niche) ──

  Future<void> _loadRecommendedAgencyPage({required bool reset}) async {
    final niche = selectedPaidAdNiche.value;
    if (niche == null || niche.trim().isEmpty) return;

    if (_isRecAgencyLoading) return;

    if (reset) {
      _recAgencyPage = 1;
      _hasMoreRecAgencies = true;
      recommendedAgencies.clear();
    }

    if (!_hasMoreRecAgencies) return;

    _isRecAgencyLoading = true;

    try {
      final agencies = await _campaignService.fetchAgencies(
        page: _recAgencyPage,
        limit: 10,
        niche: niche,
      );

      if (agencies.isNotEmpty) {
        final models = agencies
            .map(
              (a) => AdAgencyUiModel(
                id: a.id,
                name: a.name,
                logo: a.logo,
                subtitle: a.subtitle ?? 'Ad Agency',
              ),
            )
            .toList(growable: false);

        recommendedAgencies.addAll(models);
        _recAgencyPage += 1;
      } else {
        _hasMoreRecAgencies = false;
      }
    } finally {
      _isRecAgencyLoading = false;
    }
  }

  void _onRecommendedAgencyScroll() {
    if (!recommendedAgencyScroll.hasClients) return;

    final position = recommendedAgencyScroll.position;
    const threshold = 160.0;
    final isNearEnd = position.pixels >= (position.maxScrollExtent - threshold);

    if (isNearEnd) {
      _loadRecommendedAgencyPage(reset: false);
    }
  }

  // ── Other agencies (WITHOUT niche) ──

  void _onStep2PageScroll() {
    if (!step2Scroll.hasClients) return;

    if (currentStep.value != 2) return;
    if (selectedType.value != CampaignType.paidAd) return;

    final position = step2Scroll.position;

    const threshold = 280.0;
    final isNearBottom =
        position.pixels >= (position.maxScrollExtent - threshold);

    if (isNearBottom) {
      _loadOtherAgencyPage(reset: false);
    }
  }

  Future<void> _loadOtherAgencyPage({required bool reset}) async {
    if (isOtherAgencyLoading.value) return;

    if (reset) {
      _otherAgencyPage = 1;
      _hasMoreOtherAgencies = true;
      otherAgencies.clear();
    }

    if (!_hasMoreOtherAgencies) return;

    isOtherAgencyLoading.value = true;

    try {
      final agencies = await _campaignService.fetchAgencies(
        page: _otherAgencyPage,
        limit: 10,
      );

      if (agencies.isNotEmpty) {
        final models = agencies
            .map(
              (a) => AdAgencyUiModel(
                id: a.id,
                name: a.name,
                logo: a.logo,
                subtitle: a.subtitle ?? 'Ad Agency',
              ),
            )
            .toList(growable: false);

        otherAgencies.addAll(models);
        _otherAgencyPage += 1;
      } else {
        _hasMoreOtherAgencies = false;
      }
    } finally {
      isOtherAgencyLoading.value = false;
    }
  }

  // ── Niche changed → reload recommended agencies ──

  void onPaidAdNicheChanged(String? niche) {
    selectedPaidAdNiche.value = niche;
    if (niche != null && niche.trim().isNotEmpty) {
      _loadRecommendedAgencyPage(reset: true);
    } else {
      recommendedAgencies.clear();
    }
  }

  void onCampaignNameChanged(String v) => campaignName.value = v;

  void selectType(CampaignType type) {
    selectedType.value = type;
    _resetStep2ForType(type);
    needToSendSample.value = false;
    sampleGuidelinesConfirmed.value = false;

    if (currentStep.value > totalSteps) currentStep.value = totalSteps;
  }

  void _resetStep2ForType(CampaignType type) {
    selectedProductType.value = null;
    selectedInfluencerNiche.value = null;

    preferredInputCtrl.clear();
    notPreferredInputCtrl.clear();
    preferredInfluencers.clear();
    notPreferredInfluencers.clear();

    selectedPaidAdNiche.value = null;
    selectedAgencyIds.clear();
    recommendedAgencies.clear();
    agencySearchCtrl.clear();
    agencyQuery.value = '';
  }

  void onPreferredTyping(String v) {
    // No API searching anymore.
    if (v.contains(',')) commitPreferredInput();
  }

  void onNotPreferredTyping(String v) {
    // No API searching anymore.
    if (v.contains(',')) commitNotPreferredInput();
  }

  void commitPreferredInput() {
    _commitFreeText(preferredInputCtrl, preferredInfluencers);
  }

  void commitNotPreferredInput() {
    _commitFreeText(notPreferredInputCtrl, notPreferredInfluencers);
  }

  void _commitFreeText(TextEditingController ctrl, RxList<String> target) {
    final raw = ctrl.text.trim();
    if (raw.isEmpty) return;

    // Accept comma or new line separated names/handles
    final parts = raw
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final p in parts) {
      if (!target.contains(p)) target.add(p);
    }

    ctrl.clear();
  }

  List<String> _cleanInfluencerStrings(Iterable<String> values) {
    final out = <String>[];
    for (final v in values) {
      final s = v.trim();
      if (s.isEmpty) continue;
      if (!out.contains(s)) out.add(s);
    }
    return out;
  }

  void onAgencyTyping(String v) {
    agencyQuery.value = v;
  }

  void removePreferred(String name) => preferredInfluencers.remove(name);

  void removeNotPreferred(String name) => notPreferredInfluencers.remove(name);

  void _commitCommaSeparated(
    TextEditingController ctrl,
    RxList<String> target,
    RxList<String> targetIds,
    VoidCallback onEmpty,
    VoidCallback onDone,
  ) {
    final raw = ctrl.text.trim();
    if (raw.isEmpty) {
      onEmpty();
      return;
    }

    final parts = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final p in parts) {
      if (!target.contains(p)) target.add(p);
      if (_looksLikeUuid(p) && !targetIds.contains(p)) targetIds.add(p);
    }
    ctrl.clear();
    onDone();
  }

  List<AdAgencyUiModel> filteredAgencies(String query) {
    final q = query.trim().toLowerCase();
    final list = <AdAgencyUiModel>[...recommendedAgencies, ...otherAgencies];
    if (q.isEmpty) return list;
    return list
        .where((e) => e.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  // ---------------- UI OPENERS (controller only calls) ----------------

  void openAddContentAssetDialog() {
    assetTitleCtrl.clear();

    CreateCampaignDialogs.openAddContentAsset(
      controller: this,
      onAdd: (asset) => contentAssets.add(asset),
      guessKind: _guessAssetKind,
      iconForKind: iconForAsset,
      extUpper: _extUpper,
      filenameNoExt: _filenameNoExt,
      formatBytes: _formatBytes,
    );
  }

  void openEditBrandAssetDialog(int index) {
    if (index < 0 || index >= brandAssets.length) return;

    final item = brandAssets[index];
    brandTitleCtrl.text = item.title;
    brandValueCtrl.text = item.value ?? '';

    CreateCampaignDialogs.openBrandAssetEditor(
      title: 'create_campaign_brand_assets'.tr,
      titleCtrl: brandTitleCtrl,
      valueCtrl: brandValueCtrl,
      onDone: () {
        final t = brandTitleCtrl.text.trim();
        final v = brandValueCtrl.text.trim();
        if (t.isEmpty) {
          Get.snackbar(
            'create_campaign_error_title'.tr,
            'create_campaign_brand_asset_error'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        brandAssets[index] = item.copyWith(title: t, value: v);
      },
    );
  }

  void openAddBrandAssetDialog() {
    brandTitleCtrl.clear();
    brandValueCtrl.clear();

    CreateCampaignDialogs.openBrandAssetEditor(
      title: 'create_campaign_add_brand_asset'.tr,
      titleCtrl: brandTitleCtrl,
      valueCtrl: brandValueCtrl,
      onDone: () {
        final t = brandTitleCtrl.text.trim();
        final v = brandValueCtrl.text.trim();
        if (t.isEmpty) {
          Get.snackbar(
            'create_campaign_error_title'.tr,
            'create_campaign_brand_asset_error'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        brandAssets.add(BrandAsset(title: t, value: v));
      },
    );
  }

  void openPlacementConfirmedDialog() {
    CreateCampaignDialogs.openPlacementConfirmed(controller: this);
  }

  // ------------------------------------------------------------------

  void selectAgencySuggestion(AdAgencyUiModel agency) {
    toggleAgencySelection(agency);
    agencyQuery.value = '';
    agencySearchCtrl.clear();
  }

  // ── Toggle multi-select agency ──
  void toggleAgencySelection(AdAgencyUiModel agency) {
    if (selectedAgencyIds.contains(agency.id)) {
      selectedAgencyIds.remove(agency.id);
    } else {
      selectedAgencyIds.add(agency.id);
    }
  }

  void onCampaignGoalsChanged(String v) => campaignGoals.value = v;
  void onProductServiceChanged(String v) => productServiceDetails.value = v;
  void onReportingReqChanged(String v) => reportingRequirements.value = v;
  void onUsageRightsChanged(String v) => usageRights.value = v;
  void onDurationChanged(String v) => duration.value = v;

  void onDosChanged(String v) {
    dosText.value = v;
    dosLines.assignAll(_toLines(v));
  }

  void onDontsChanged(String v) {
    dontsText.value = v;
    dontsLines.assignAll(_toLines(v));
  }

  List<String> _toLines(String raw) {
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.replaceFirst(RegExp(r'^[•\-\*]+\s*'), ''))
        .toList();
  }

  String get startDateText {
    final d = startDate.value;
    if (d == null) return 'create_campaign_start_date_hint'.tr;

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  DateTime? get computedEndDate {
    final s = startDate.value;
    if (s == null) return null;
    final days = _durationDays;
    return s.add(Duration(days: days));
  }

  String get deadlineLabelForStep6 {
    final d = computedEndDate;
    if (d == null) return startDateText;

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> pickStartDate() async {
    final ctx = Get.context;
    if (ctx == null) return;

    final now = DateTime.now();
    final initial = startDate.value ?? now;

    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) startDate.value = picked;
  }

  void setBudgetFromSuggestion(int amount) {
    baseBudget.value = amount.toDouble();
    budgetTextCtrl.text = formatCurrencyByLocale(amount);
  }

  void onBudgetTextChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(digits) ?? 0.0;
    baseBudget.value = parsed;

    if (digits.isEmpty) return;
    final formatted = formatCurrencyByLocale(int.parse(digits));
    if (budgetTextCtrl.text != formatted) {
      budgetTextCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void toggleMilestonesExpanded() {
    milestonesExpanded.value = !milestonesExpanded.value;
  }

  int get _durationDays {
    final d = duration.value.trim();
    final m = RegExp(r'(\d+)').firstMatch(d);
    final n = int.tryParse(m?.group(1) ?? '');
    return (n ?? 7).clamp(1, 365);
  }

  List<int> get milestoneDayOptions =>
      List<int>.generate(_durationDays, (i) => i + 1);

  void startAddMilestone() {
    if (isAddingMilestone.value) return;
    editingMilestoneIndex.value = null;
    isAddingMilestone.value = true;

    milestoneTitleCtrl.clear();
    milestoneDeliverableCtrl.clear();
    selectedMilestonePlatform.value = null;
    selectedMilestoneDay.value = null;
    reachCtrl.clear();
    viewsCtrl.clear();
    likesCtrl.clear();
    commentsCtrl.clear();
    milestoneMetricTitleCtrl.clear();
    milestoneMetricAmountCtrl.clear();
    promoGoalCtrl.clear();
  }

  void startEditMilestone(int index) {
    if (index < 0 || index >= milestones.length) return;
    if (isAddingMilestone.value) return;

    final m = milestones[index];
    editingMilestoneIndex.value = index;
    isAddingMilestone.value = true;

    milestoneTitleCtrl.text = m.title;
    milestoneDeliverableCtrl.text = m.deliverable ?? m.subtitle ?? '';
    selectedMilestonePlatform.value = m.platform;
    selectedMilestoneDay.value = m.dayIndex;

    reachCtrl.text = m.targets?.reach?.toString() ?? '';
    viewsCtrl.text = m.targets?.views?.toString() ?? '';
    likesCtrl.text = m.targets?.likes?.toString() ?? '';
    commentsCtrl.text = m.targets?.comments?.toString() ?? '';
    promoGoalCtrl.text = m.promotionGoal?.toString() ?? '';

    if (selectedType.value == CampaignType.paidAd) {
      final t = m.targets;
      String label = '';
      int? value;

      if ((t?.reach ?? 0) > 0) {
        label = 'Reach';
        value = t?.reach;
      } else if ((t?.views ?? 0) > 0) {
        label = 'Views';
        value = t?.views;
      } else if ((t?.likes ?? 0) > 0) {
        label = 'Likes';
        value = t?.likes;
      } else if ((t?.comments ?? 0) > 0) {
        label = 'Comments';
        value = t?.comments;
      }

      milestoneMetricTitleCtrl.text = label;
      milestoneMetricAmountCtrl.text = value?.toString() ?? '';
    } else {
      milestoneMetricTitleCtrl.clear();
      milestoneMetricAmountCtrl.clear();
    }
  }

  String _normalizeMetricKey(String raw) {
    final v = raw.trim().toLowerCase();

    if (v.contains('view')) return 'views';
    if (v.contains('like')) return 'likes';
    if (v.contains('comment')) return 'comments';
    if (v.contains('follow')) return 'reach';
    return 'reach';
  }

  /// Supports:
  /// 300k -> 300000
  /// 2.5M -> 2500000
  /// 120000 -> 120000
  int? _parseCompactMetricAmount(String raw) {
    final input = raw.trim().toLowerCase().replaceAll(',', '');
    if (input.isEmpty) return null;

    final match = RegExp(r'^(\d+(\.\d+)?)\s*([km]?)$').firstMatch(input);
    if (match == null) {
      final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isEmpty) return null;
      return int.tryParse(digits);
    }

    final numberPart = double.tryParse(match.group(1) ?? '');
    final suffix = match.group(3) ?? '';

    if (numberPart == null) return null;

    double value = numberPart;
    if (suffix == 'k') value *= 1000;
    if (suffix == 'm') value *= 1000000;

    return value.round();
  }

  PromotionTarget _buildStep4PromotionTarget() {
    // ✅ Paid Ad / Ad Agency => only one metric allowed
    if (selectedType.value == CampaignType.paidAd) {
      final key = _normalizeMetricKey(milestoneMetricTitleCtrl.text);
      final amount = _parseCompactMetricAmount(milestoneMetricAmountCtrl.text);

      return PromotionTarget(
        reach: key == 'reach' ? amount : null,
        views: key == 'views' ? amount : null,
        likes: key == 'likes' ? amount : null,
        comments: key == 'comments' ? amount : null,
      );
    }

    // ✅ Influencer flow => keep existing 4 metrics inputs
    int? toInt(TextEditingController c) {
      final v = c.text.trim();
      if (v.isEmpty) return null;
      return int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    return PromotionTarget(
      reach: toInt(reachCtrl),
      views: toInt(viewsCtrl),
      likes: toInt(likesCtrl),
      comments: toInt(commentsCtrl),
    );
  }

  void closeMilestoneEditor() {
    final editIndex = editingMilestoneIndex.value;
    if (editIndex != null && editIndex >= 0 && editIndex < milestones.length) {
      milestones.removeAt(editIndex);
    }
    editingMilestoneIndex.value = null;
    isAddingMilestone.value = false;
  }

  void saveMilestone() {
    final title = milestoneTitleCtrl.text.trim();
    final platform = selectedMilestonePlatform.value;
    final deliverable = milestoneDeliverableCtrl.text.trim();
    final day = selectedMilestoneDay.value;
    final promotionGoal = promoGoalCtrl.text.trim();

    if (title.isEmpty ||
        platform == null ||
        deliverable.isEmpty ||
        day == null) {
      Get.snackbar(
        'create_campaign_error_title'.tr,
        'create_campaign_step4_milestone_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedType.value == CampaignType.paidAd) {
      final metricTitle = milestoneMetricTitleCtrl.text.trim();
      final metricAmount = _parseCompactMetricAmount(
        milestoneMetricAmountCtrl.text,
      );

      if (metricTitle.isEmpty || metricAmount == null || metricAmount <= 0) {
        Get.snackbar(
          'create_campaign_error_title'.tr,
          'Please enter a valid promotion target title and amount.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final target = _buildStep4PromotionTarget();

    final editIndex = editingMilestoneIndex.value;

    if (editIndex != null && editIndex >= 0 && editIndex < milestones.length) {
      milestones[editIndex] = Milestone(
        stepLabel: '${editIndex + 1}',
        title: title,
        subtitle: deliverable,
        dayLabel: 'DAY $day',
        dayIndex: day,
        platform: platform,
        deliverable: deliverable,
        targets: target,
        promotionGoal: promotionGoal,
      );
    } else {
      final idx = milestones.length + 1;
      milestones.add(
        Milestone(
          stepLabel: '$idx',
          title: title,
          subtitle: deliverable,
          dayLabel: 'DAY $day',
          dayIndex: day,
          platform: platform,
          deliverable: deliverable,
          targets: target,
          promotionGoal: promotionGoal,
        ),
      );
    }

    editingMilestoneIndex.value = null;
    isAddingMilestone.value = false;
  }

  String get baseBudgetText => formatCurrencyByLocale(baseBudget.value);
  String get vatAmountText => formatCurrencyByLocale(vatAmount);
  String get totalBudgetText => formatCurrencyByLocale(totalBudgetIncTax);

  IconData iconForAsset(JobAssetKind kind) {
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

  void removeContentAsset(int index) {
    if (index < 0 || index >= contentAssets.length) return;
    contentAssets.removeAt(index);
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

  void toggleNeedSample(bool v) {
    needToSendSample.value = v;
    if (!v) sampleGuidelinesConfirmed.value = false;
  }

  void saveAsDraft() {
    Get.snackbar(
      'create_campaign_draft_title'.tr,
      'create_campaign_draft_msg'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _requireCampaignId() {
    final id = campaignId.value;
    if (id == null || id.trim().isEmpty) {
      throw Exception('Campaign id is not available.');
    }
    return id;
  }

  String _formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _safeText(RxString value, TextEditingController controller) {
    final v = value.value.trim();
    if (v.isNotEmpty) return v;
    return controller.text.trim();
  }

  Future<List<Map<String, dynamic>>> _buildAssetsForApi() async {
    final assets = <Map<String, dynamic>>[];

    for (final asset in contentAssets) {
      final mapped = await _mapContentAsset(asset);
      if (mapped != null) assets.add(mapped);
    }

    dev.log('Brand Assest: ${brandAssets.length}');

    for (final asset in brandAssets) {
      final mapped = _mapBrandAsset(asset);
      dev.log('Brand Assest: ${mapped}');
      if (mapped != null) assets.add(mapped);
    }

    return assets;
  }

  Future<Map<String, dynamic>?> _mapContentAsset(JobAsset asset) async {
    String? fileUrl;
    String fileName = asset.title.trim();
    int fileSize = 0;

    final pathOrUrl = asset.pathOrUrl?.trim();

    if (pathOrUrl != null && pathOrUrl.isNotEmpty) {
      if (_isHttpUrl(pathOrUrl)) {
        fileUrl = pathOrUrl;
        final uri = Uri.tryParse(pathOrUrl);
        final name = uri == null ? null : path.basename(uri.path);
        if (name != null && name.isNotEmpty) fileName = name;
      } else {
        final file = File(pathOrUrl);
        if (await file.exists()) {
          final name = path.basename(pathOrUrl);
          if (name.isNotEmpty) fileName = name;
          fileSize = await file.length();

          final contentType = _getContentType(pathOrUrl);
          final signed = await _uploadService.createSignedUrl(
            fileName: fileName,
            fileType: contentType,
            module: 'campaign-assets',
          );

          await _uploadService.uploadFileToSignedUrl(
            uploadUrl: signed.uploadUrl,
            file: file,
            contentType: contentType,
          );

          fileUrl = signed.fileUrl;
        }
      }
    }

    if (fileUrl == null || fileUrl.isEmpty) return null;

    final mimeType = _getContentType(fileName);

    return _removeNulls({
      'fileName': fileName,
      'fileUrl': fileUrl,
      'assetType': mimeType,
      'category': 'content',
      'fileSize': fileSize == 0 ? null : fileSize,
      'mimeType': mimeType,
      'description': asset.title,
    });
  }

  Map<String, dynamic>? _mapBrandAsset(BrandAsset asset) {
    final title = asset.title.trim();
    if (title.isEmpty) return null;

    final value = asset.value?.trim();
    final isUrl = value != null && _isHttpUrl(value);
    // if (!isUrl) return null;

    return _removeNulls({
      'fileName': title,
      'fileUrl': value,
      'assetType': 'brand_asset',
      'category': 'brand',
      'fileSize': null,
      'mimeType': 'text/plain',
      'description': null,
    });
  }

  bool _isHttpUrl(String value) {
    final v = value.toLowerCase();
    return v.startsWith('http://') || v.startsWith('https://');
  }

  String _getContentType(String filePathOrName) {
    final ext = path.extension(filePathOrName).replaceFirst('.', '');
    switch (ext.toLowerCase()) {
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

  Map<String, dynamic> _removeNulls(Map<String, dynamic> data) {
    data.removeWhere((key, value) => value == null);
    return data;
  }

  bool _looksLikeUuid(String value) {
    final v = value.trim();
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(v);
  }

  List<String> _filterUuidList(Iterable<String> values) {
    return values.where(_looksLikeUuid).map((e) => e.trim()).toList();
  }

  void onPrevious() {
    if (currentStep.value > 1) {
      currentStep.value--;
      Get.back(id: 1);
      return;
    }
    Get.back(id: 1);
  }

  Future<void> onNext() async {
    if (!canGoNext) {
      Get.snackbar(
        'create_campaign_error_title'.tr,
        currentStep.value == 2
            ? 'create_campaign_error_step2_msg'.tr
            : 'create_campaign_error_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isSavingStep.value) return;
    isSavingStep.value = true;

    final step = currentStep.value;

    final result = await ApiErrorHandler.call(() async {
      if (step == 1) {
        final type = selectedType.value;
        if (type == null) throw Exception('Campaign type is required');

        final title = _safeText(campaignName, campaignNameCtrl);
        final id = await _campaignService.createCampaign(
          campaignName: title.isNotEmpty ? title : 'Untitled Campaign',
          campaignType: type,
        );
        campaignId.value = id;
        return true;
      }

      final id = _requireCampaignId();

      if (step == 2) {
        final type = selectedType.value;
        if (type == CampaignType.influencerPromotion) {
          await _campaignService.updateStep2Influencer(
            campaignId: id,
            productType: selectedProductType.value ?? '',
            campaignNiche: selectedInfluencerNiche.value?.trim() ?? '',
            preferredInfluencers: _cleanInfluencerStrings(preferredInfluencers),
            notPreferableInfluencers: _cleanInfluencerStrings(
              notPreferredInfluencers,
            ),
          );
        } else {
          // ── Pass all selected agency IDs ──
          final agencyIds = _filterUuidList(selectedAgencyIds);
          await _campaignService.updateStep2PaidAd(
            campaignId: id,
            campaignNiche: selectedPaidAdNiche.value ?? '',
            agencyIds: agencyIds,
          );
        }
        return true;
      }

      if (step == 3) {
        final start = startDate.value;
        final startDateText = start == null ? '' : _formatApiDate(start);

        await _campaignService.updateStep3(
          campaignId: id,
          campaignGoals: _safeText(campaignGoals, campaignGoalsCtrl),
          productServiceDetails: _safeText(
            productServiceDetails,
            productServiceCtrl,
          ),
          reportingRequirements: _safeText(
            reportingRequirements,
            reportingReqCtrl,
          ),
          usageRights: _safeText(usageRights, usageRightsCtrl),
          dos: _safeText(dosText, dosCtrl),
          donts: _safeText(dontsText, dontsCtrl),
          startingDate: startDateText,
          duration: _durationDays,
        );
        return true;
      }

      if (step == 4) {
        final mappedMilestones = milestones
            .map((m) {
              final isPaidAd = selectedType.value == CampaignType.paidAd;

              final map = {
                'contentTitle': m.title,
                'platform': m.platform?.toLowerCase(),
                'contentQuantity': m.deliverable ?? m.subtitle,
                'deliveryDays': m.dayIndex,
                if (!isPaidAd || m.targets?.reach != null)
                  'expectedReach': m.targets?.reach,
                if (!isPaidAd || m.targets?.views != null)
                  'expectedViews': m.targets?.views,
                if (!isPaidAd || m.targets?.likes != null)
                  'expectedLikes': m.targets?.likes,
                if (!isPaidAd || m.targets?.comments != null)
                  'expectedComments': m.targets?.comments,
                'promotionGoal': m.promotionGoal,
              };
              return _removeNulls(map);
            })
            .where((m) => m.isNotEmpty)
            .toList(growable: false);

        await _campaignService.updateStep4(
          campaignId: id,
          baseBudget: baseBudget.value,
          milestones: mappedMilestones,
        );
        return true;
      }

      if (step == 5) {
        final assets = await _buildAssetsForApi();
        await _campaignService.updateStep5(
          campaignId: id,
          needSampleProduct: needToSendSample.value,
          assets: assets,
        );
        return true;
      }

      return true;
    }, errorTitle: 'create_campaign_error_title'.tr);

    isSavingStep.value = false;
    if (!result.isSuccess) return;

    if (step == 1) {
      currentStep.value = 2;
      Get.toNamed(AppRoutes.createCampaignStep2, id: 1);
      return;
    }

    if (step == 2) {
      currentStep.value = 3;
      Get.toNamed(AppRoutes.createCampaignStep3, id: 1);
      return;
    }

    if (step == 3) {
      currentStep.value = 4;
      Get.toNamed(AppRoutes.createCampaignStep4, id: 1);
      return;
    }

    if (step == 4) {
      currentStep.value = 5;
      Get.toNamed(AppRoutes.createCampaignStep5, id: 1);
      return;
    }

    if (step == 5) {
      currentStep.value = 6;
      Get.toNamed(AppRoutes.createCampaignStep6, id: 1);
      return;
    }

    if (step == 6) return;

    currentStep.value = (currentStep.value + 1).clamp(1, totalSteps);
  }

  @override
  void onClose() {
    campaignNameCtrl.dispose();
    preferredInputCtrl.dispose();
    notPreferredInputCtrl.dispose();
    agencySearchCtrl.dispose();
    recommendedAgencyScroll.dispose();
    step2Scroll.dispose();

    campaignGoalsCtrl.dispose();
    productServiceCtrl.dispose();
    dosCtrl.dispose();
    dontsCtrl.dispose();
    reportingReqCtrl.dispose();
    usageRightsCtrl.dispose();
    durationCtrl.dispose();

    budgetTextCtrl.dispose();
    milestoneTitleCtrl.dispose();
    milestoneDeliverableCtrl.dispose();
    reachCtrl.dispose();
    viewsCtrl.dispose();
    likesCtrl.dispose();
    commentsCtrl.dispose();
    promoGoalCtrl.dispose();

    assetTitleCtrl.dispose();
    brandTitleCtrl.dispose();
    brandValueCtrl.dispose();

    milestoneMetricTitleCtrl.dispose();
    milestoneMetricAmountCtrl.dispose();

    super.onClose();
  }

  Future<void> submitAndShowPlacementConfirmedPopup() async {
    if (isSavingStep.value) return;
    isSavingStep.value = true;

    final result = await ApiErrorHandler.call(() async {
      final id = _requireCampaignId();
      await _campaignService.placeCampaign(campaignId: id);
      return true;
    }, errorTitle: 'create_campaign_error_title'.tr);

    isSavingStep.value = false;
    if (!result.isSuccess) return;

    createdJobItem.value = buildFinalJobItem();
    openPlacementConfirmedDialog();
  }

  void finishFlowAndReset() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    final nav = Get.nestedKey(1)?.currentState;
    if (nav != null) {
      nav.popUntil((r) => r.isFirst);
    } else {
      Get.until((route) => route.isFirst);
    }

    resetAllToInitial();
  }

  void resetAllToInitial() {
    currentStep.value = 1;

    campaignId.value = null;

    campaignNameCtrl.clear();
    campaignName.value = '';
    selectedType.value = null;

    selectedProductType.value = null;
    selectedInfluencerNiche.value = null;

    preferredInputCtrl.clear();
    notPreferredInputCtrl.clear();
    preferredInfluencers.clear();
    notPreferredInfluencers.clear();

    selectedPaidAdNiche.value = null;
    selectedAgencyIds.clear();
    recommendedAgencies.clear();
    agencySearchCtrl.clear();
    agencyQuery.value = '';

    campaignGoalsCtrl.clear();
    productServiceCtrl.clear();
    dosCtrl.clear();
    dontsCtrl.clear();
    reportingReqCtrl.clear();
    usageRightsCtrl.clear();
    durationCtrl.clear();
    dosText.value = '';
    dontsText.value = '';
    dosLines.clear();
    dontsLines.clear();

    startDate.value = null;

    campaignGoals.value = '';
    productServiceDetails.value = '';
    reportingRequirements.value = '';
    usageRights.value = '';
    duration.value = '';

    budgetTextCtrl.clear();
    baseBudget.value = 0.0;

    milestonesExpanded.value = true;
    milestones.clear();

    editingMilestoneIndex.value = null;
    isAddingMilestone.value = false;
    milestoneTitleCtrl.clear();
    milestoneDeliverableCtrl.clear();
    selectedMilestonePlatform.value = null;
    selectedMilestoneDay.value = null;

    reachCtrl.clear();
    viewsCtrl.clear();
    likesCtrl.clear();
    commentsCtrl.clear();
    promoGoalCtrl.clear();

    needToSendSample.value = false;
    sampleGuidelinesConfirmed.value = false;

    contentAssets.clear();
    brandAssets.clear();
  }

  String localizeDigits(String input) {
    final lang = Get.locale?.languageCode.toLowerCase();
    if (lang != 'bn') return input;

    const map = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };

    final out = StringBuffer();
    for (final ch in input.split('')) {
      out.write(map[ch] ?? ch);
    }
    return out.toString();
  }

  String get localizedTotalBudgetText => localizeDigits(totalBudgetText);
}
