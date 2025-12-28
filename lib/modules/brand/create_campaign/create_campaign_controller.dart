// lib/modules/brand/create_campaign/create_campaign_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/routes/app_routes.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/models/job_item.dart';

class AdAgencyUiModel {
  final String name;
  final String subtitle;
  const AdAgencyUiModel({required this.name, required this.subtitle});
}

class CreateCampaignController extends GetxController {
  /// ---------------- STEP 1 ----------------
  final campaignNameCtrl = TextEditingController();
  final campaignName = ''.obs;
  final selectedType = Rxn<CampaignType>();

  /// ---------------- STEP 2 (Influencer Promotion) ----------------
  final selectedProductType = RxnString();
  final selectedNiches = <String>[].obs;

  final preferredInputCtrl = TextEditingController();
  final notPreferredInputCtrl = TextEditingController();

  final preferredInfluencers = <String>[].obs;
  final notPreferredInfluencers = <String>[].obs;

  /// ---------------- STEP 2 (Paid Ad) ----------------
  final selectedPaidAdNiche = RxnString();
  final selectedAgencyName = RxnString();

  final recommendedAgencies = <AdAgencyUiModel>[
    const AdAgencyUiModel(name: 'Trendy Ad', subtitle: 'Boosting Page'),
    const AdAgencyUiModel(name: 'GrowUp Media', subtitle: 'Ad Solutions'),
    const AdAgencyUiModel(name: 'Spark Ads', subtitle: 'Boosting Page'),
  ].obs;

  final otherAgencies = <AdAgencyUiModel>[
    const AdAgencyUiModel(name: 'Trendy Ad', subtitle: 'Boosting Page'),
    const AdAgencyUiModel(name: 'Prime Agency', subtitle: 'Boosting Page'),
  ].obs;

  /// ---------------- STEP 3 (Both types) ----------------
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

  /// ---------------- STEP 4 (Both types) ----------------
  static const double _vatPercentConst = 0.15;
  static const int _minBudget = 25000;

  final budgetTextCtrl = TextEditingController();
  final baseBudget = 0.0.obs;

  final budgetSuggestions = const [30000, 50000, 80000, 100000];

  final milestonesExpanded = true.obs;
  final milestones = <Milestone>[].obs;

  final isAddingMilestone = false.obs;

  final milestoneTitleCtrl = TextEditingController();
  final milestoneDeliverableCtrl = TextEditingController();

  final selectedMilestonePlatform = RxnString();
  final selectedMilestoneDay = RxnInt();

  final reachCtrl = TextEditingController();
  final viewsCtrl = TextEditingController();
  final likesCtrl = TextEditingController();
  final commentsCtrl = TextEditingController();

  final platformOptions = const ['Facebook', 'Instagram', 'YouTube', 'TikTok'];

  double get vatPercent => _vatPercentConst;
  int get minBudget => _minBudget;

  double get vatAmount => baseBudget.value * vatPercent;
  double get totalBudgetIncTax => baseBudget.value + vatAmount;

  /// ---------------- STEP 5 ----------------
  final contentAssets = <JobAsset>[].obs;

  // influencerPromotion
  final needToSendSample = false.obs;
  final sampleGuidelinesConfirmed = false.obs;

  // paidAd
  final brandAssets = <BrandAsset>[].obs;

  // dialogs/controllers
  final _assetTitleCtrl = TextEditingController();

  final _brandTitleCtrl = TextEditingController();
  final _brandValueCtrl = TextEditingController();

  /// ---------------- Steps ----------------
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

    // Store VAT percent as 15 (not 0.15) because BrandCampaignDetailsController expects %.
    final vatPercentAs100 = vatPercent * 100;

    return JobItem(
      title: title.isNotEmpty ? title : 'Untitled Campaign',
      clientName: 'Brand', // change if you have a real value
      campaignType: type, // ✅ stored here
      dateLabel: deadlineLabelForStep6,
      budget: totalBudgetIncTax, // total including VAT
      sharePercent: 0,

      dueInDays: _durationDays,

      // budget breakdown
      baseBudget: baseBudget.value,
      vatPercent: vatPercentAs100,
      vatAmount: vatAmount,
      netPayableBudget: totalBudgetIncTax,

      // step 5
      contentAssets: contentAssets.toList(growable: false),
      brandAssets: brandAssets.toList(growable: false),
      needToSendSample: needToSendSample.value,
      sampleGuidelinesConfirmed: sampleGuidelinesConfirmed.value,

      // step 4
      milestones: milestones.toList(growable: false),

      // brief
      dosText: dosText.value.trim().isNotEmpty ? dosText.value : dosCtrl.text,
      dontsText: dontsText.value.trim().isNotEmpty
          ? dontsText.value
          : dontsCtrl.text,
      subTitle: null,
    );
  }

  /// ---------------- Validation ----------------
  bool get canGoNext {
    final step = currentStep.value;

    if (step == 1) {
      return campaignName.value.trim().isNotEmpty && selectedType.value != null;
    }

    if (step == 2) {
      final type = selectedType.value;
      if (type == CampaignType.influencerPromotion) {
        return selectedProductType.value != null && selectedNiches.isNotEmpty;
      }
      if (type == CampaignType.paidAd) {
        return selectedPaidAdNiche.value != null &&
            selectedAgencyName.value != null;
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
      // influencerPromotion: if sample is needed => must confirm guidelines
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

    // demo prefill to match screenshots (only if empty)
    if (contentAssets.isEmpty) {
      contentAssets.addAll(const [
        JobAsset(
          title: 'Brand Logo Pack',
          meta: 'PNG, SVG – 2.4 MB',
          kind: JobAssetKind.image,
        ),
        JobAsset(
          title: 'Product Demo Video',
          meta: 'MP4 – 80 MB',
          kind: JobAssetKind.video,
        ),
        JobAsset(
          title: 'Brand Guidelines',
          meta: 'PDF – 750 KB',
          kind: JobAssetKind.document,
        ),
      ]);
    }

    if (brandAssets.isEmpty) {
      brandAssets.add(const BrandAsset(title: 'Facebook Page', value: ''));
    }
  }

  /// ---------------- Step 1 handlers ----------------
  void onCampaignNameChanged(String v) => campaignName.value = v;

  void selectType(CampaignType type) {
    selectedType.value = type;
    _resetStep2ForType(type);

    // Step5 toggles reset when type changes
    needToSendSample.value = false;
    sampleGuidelinesConfirmed.value = false;

    if (currentStep.value > totalSteps) currentStep.value = totalSteps;
  }

  void _resetStep2ForType(CampaignType type) {
    selectedProductType.value = null;
    selectedNiches.clear();
    preferredInputCtrl.clear();
    notPreferredInputCtrl.clear();
    preferredInfluencers.clear();
    notPreferredInfluencers.clear();

    selectedPaidAdNiche.value = null;
    selectedAgencyName.value = null;
  }

  /// ---------------- Step 2 options (demo) ----------------
  final productTypeOptions = const [
    'Electronics',
    'Fashion',
    'Beauty',
    'Food',
    'Other',
  ];
  final nicheOptions = const [
    'Lifestyle',
    'Tech',
    'Sports',
    'Education',
    'Travel',
    'Gaming',
  ];

  void openProductTypePicker() {
    Get.bottomSheet(
      _SimplePickerSheet(
        title: 'create_campaign_product_type_label'.tr,
        options: productTypeOptions,
        selected: selectedProductType.value,
        onSelect: (v) {
          selectedProductType.value = v;
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openNichePicker() {
    Get.bottomSheet(
      _MultiPickerSheet(
        title: 'create_campaign_niche_label'.tr,
        options: nicheOptions,
        selected: selectedNiches,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onPreferredTyping(String v) {
    if (v.contains(',')) commitPreferredInput();
  }

  void onNotPreferredTyping(String v) {
    if (v.contains(',')) commitNotPreferredInput();
  }

  void commitPreferredInput() =>
      _commitCommaSeparated(preferredInputCtrl, preferredInfluencers);
  void commitNotPreferredInput() =>
      _commitCommaSeparated(notPreferredInputCtrl, notPreferredInfluencers);

  void removePreferred(String name) => preferredInfluencers.remove(name);
  void removeNotPreferred(String name) => notPreferredInfluencers.remove(name);

  void _commitCommaSeparated(
    TextEditingController ctrl,
    RxList<String> target,
  ) {
    final raw = ctrl.text.trim();
    if (raw.isEmpty) return;

    final parts = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final p in parts) {
      if (!target.contains(p)) target.add(p);
    }
    ctrl.clear();
  }

  void openPaidAdNichePicker() {
    Get.bottomSheet(
      _SimplePickerSheet(
        title: 'create_campaign_niche_label'.tr,
        options: nicheOptions,
        selected: selectedPaidAdNiche.value,
        onSelect: (v) {
          selectedPaidAdNiche.value = v;
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void selectAgency(String name) => selectedAgencyName.value = name;

  /// ---------------- Step 3 handlers ----------------
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

  // ✅ NEW: end date computed from startDate + duration days
  DateTime? get computedEndDate {
    final s = startDate.value;
    if (s == null) return null;
    final days = _durationDays;
    return s.add(Duration(days: days));
  }

  // ✅ NEW: Step 6 deadline label (uses computed end date when possible)
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

  /// ---------------- Step 4 helpers ----------------
  void setBudgetFromSuggestion(int amount) {
    baseBudget.value = amount.toDouble();
    budgetTextCtrl.text = _formatCurrencyInt(amount);
  }

  void onBudgetTextChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(digits) ?? 0.0;
    baseBudget.value = parsed;

    if (digits.isEmpty) return;
    final formatted = _formatCurrencyInt(int.parse(digits));
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
    isAddingMilestone.value = true;

    milestoneTitleCtrl.clear();
    milestoneDeliverableCtrl.clear();
    selectedMilestonePlatform.value = null;
    selectedMilestoneDay.value = null;
    reachCtrl.clear();
    viewsCtrl.clear();
    likesCtrl.clear();
    commentsCtrl.clear();
  }

  void closeMilestoneEditor() {
    isAddingMilestone.value = false;
  }

  void openPlatformPicker() {
    Get.bottomSheet(
      _SimplePickerSheet(
        title: 'create_campaign_milestone_platform'.tr,
        options: platformOptions,
        selected: selectedMilestonePlatform.value,
        onSelect: (v) {
          selectedMilestonePlatform.value = v;
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openDayPicker() {
    final opts = milestoneDayOptions.map((d) => 'DAY $d').toList();
    final selected = selectedMilestoneDay.value == null
        ? null
        : 'DAY ${selectedMilestoneDay.value}';

    Get.bottomSheet(
      _SimplePickerSheet(
        title: 'create_campaign_milestone_day'.tr,
        options: opts,
        selected: selected,
        onSelect: (v) {
          final n = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
          selectedMilestoneDay.value = n;
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void saveMilestone() {
    final title = milestoneTitleCtrl.text.trim();
    final platform = selectedMilestonePlatform.value;
    final deliverable = milestoneDeliverableCtrl.text.trim();
    final day = selectedMilestoneDay.value;

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

    int? toInt(TextEditingController c) {
      final v = c.text.trim();
      if (v.isEmpty) return null;
      return int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    final target = PromotionTarget(
      reach: toInt(reachCtrl),
      views: toInt(viewsCtrl),
      likes: toInt(likesCtrl),
      comments: toInt(commentsCtrl),
    );

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
      ),
    );

    isAddingMilestone.value = false;
  }

  String _formatCurrencyInt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      b.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) b.write(',');
    }
    return b.toString();
  }

  String get baseBudgetText => _formatCurrencyInt(baseBudget.value.round());
  String get vatAmountText => _formatCurrencyInt(vatAmount.round());
  String get totalBudgetText => _formatCurrencyInt(totalBudgetIncTax.round());

  /// ---------------- Step 5 actions ----------------
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

  void openAddContentAssetDialog() {
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
          withData: false, // keep false for mobile; size is still available
        );

        if (result == null || result.files.isEmpty) return;

        final f = result.files.single;

        pickedName.value = f.name;
        pickedBytes.value = f.size;
        pickedPath.value = f.path; // may be null on web
        pickedKind.value = _guessAssetKind(f.name);
      } finally {
        isPicking.value = false;
      }
    }

    final primary = const Color(0xFF2F4F1F);
    final bg = const Color(0xFFF6F7F7);
    final softBorder = const Color(0xFFBFD7A5);

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
              // header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'create_campaign_upload_another_asset'.tr,
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

              // asset title (optional)
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
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: softBorder, width: 1.4),
                  ),
                ),
              ),
              12.h.verticalSpace,

              // pick file button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isPicking.value ? null : pickFile,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 46.h),
                      side: BorderSide(color: softBorder),
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

              // selected file preview
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
                        iconForAsset(pickedKind.value),
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

              // actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        side: BorderSide(color: Colors.black12),
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

                                // If user doesn't provide title, use filename without extension
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
    // 1024-based
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

  void openEditBrandAssetDialog(int index) {
    if (index < 0 || index >= brandAssets.length) return;

    final item = brandAssets[index];
    _brandTitleCtrl.text = item.title;
    _brandValueCtrl.text = item.value ?? '';

    Get.defaultDialog(
      title: 'create_campaign_brand_assets'.tr,
      content: Column(
        children: [
          TextField(
            controller: _brandTitleCtrl,
            decoration: InputDecoration(
              hintText: 'create_campaign_brand_asset_name_hint'.tr,
            ),
          ),
          10.h.verticalSpace,
          TextField(
            controller: _brandValueCtrl,
            decoration: InputDecoration(
              hintText: 'create_campaign_brand_asset_value_hint'.tr,
            ),
          ),
        ],
      ),
      textConfirm: 'common_done'.tr,
      textCancel: 'common_cancel'.tr,
      onConfirm: () {
        final t = _brandTitleCtrl.text.trim();
        final v = _brandValueCtrl.text.trim();
        if (t.isEmpty) {
          Get.snackbar(
            'create_campaign_error_title'.tr,
            'create_campaign_brand_asset_error'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        brandAssets[index] = item.copyWith(title: t, value: v);
        Get.back();
      },
    );
  }

  void openAddBrandAssetDialog() {
    _brandTitleCtrl.clear();
    _brandValueCtrl.clear();

    Get.defaultDialog(
      title: 'create_campaign_add_brand_asset'.tr,
      content: Column(
        children: [
          TextField(
            controller: _brandTitleCtrl,
            decoration: InputDecoration(
              hintText: 'create_campaign_brand_asset_name_hint'.tr,
            ),
          ),
          10.h.verticalSpace,
          TextField(
            controller: _brandValueCtrl,
            decoration: InputDecoration(
              hintText: 'create_campaign_brand_asset_value_hint'.tr,
            ),
          ),
        ],
      ),
      textConfirm: 'common_done'.tr,
      textCancel: 'common_cancel'.tr,
      onConfirm: () {
        final t = _brandTitleCtrl.text.trim();
        final v = _brandValueCtrl.text.trim();
        if (t.isEmpty) {
          Get.snackbar(
            'create_campaign_error_title'.tr,
            'create_campaign_brand_asset_error'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        brandAssets.add(BrandAsset(title: t, value: v));
        Get.back();
      },
    );
  }

  /// ---------------- Draft ----------------
  void saveAsDraft() {
    Get.snackbar(
      'create_campaign_draft_title'.tr,
      'create_campaign_draft_msg'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ---------------- Navigation ----------------
  void onPrevious() {
    if (currentStep.value > 1) {
      currentStep.value--;
      Get.back(id: 1);
      return;
    }
    Get.back(id: 1);
  }

  void onNext() {
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

    final step = currentStep.value;

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

    // ✅ UPDATED: go to Step 6 route
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

    _assetTitleCtrl.dispose();
    _brandTitleCtrl.dispose();
    _brandValueCtrl.dispose();

    super.onClose();
  }

  // ---------------- Step 6 submit + popup ----------------

  /// Call this from Step 6 "Get Quote" button
  void submitAndShowPlacementConfirmedPopup() {
    createdJobItem.value = buildFinalJobItem();
    _openPlacementConfirmedDialog();
  }

  void _openPlacementConfirmedDialog() {
    Get.dialog(
      _CampaignPlacementConfirmedDialog(controller: this),
      barrierDismissible: false,
    );
  }

  /// Close popup -> go back to Step 1 (pop nested nav) -> reset all fields
  void finishFlowAndReset() {
    // close dialog if open
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // pop all create-campaign steps (nested navigator id: 1)
    final nav = Get.nestedKey(1)?.currentState;
    if (nav != null) {
      nav.popUntil((r) => r.isFirst);
    } else {
      // fallback (if nested navigator not available)
      Get.until((route) => route.isFirst);
    }

    resetAllToInitial();
  }

  /// Reset controller values to the same "initial" state (including your demo prefills)
  void resetAllToInitial() {
    currentStep.value = 1;

    // STEP 1
    campaignNameCtrl.clear();
    campaignName.value = '';
    selectedType.value = null;

    // STEP 2 (Influencer Promotion)
    selectedProductType.value = null;
    selectedNiches.clear();

    preferredInputCtrl.clear();
    notPreferredInputCtrl.clear();
    preferredInfluencers.clear();
    notPreferredInfluencers.clear();

    // STEP 2 (Paid Ad)
    selectedPaidAdNiche.value = null;
    selectedAgencyName.value = null;

    // STEP 3
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

    // STEP 4
    budgetTextCtrl.clear();
    baseBudget.value = 0.0;

    milestonesExpanded.value = true;
    milestones.clear();

    isAddingMilestone.value = false;
    milestoneTitleCtrl.clear();
    milestoneDeliverableCtrl.clear();
    selectedMilestonePlatform.value = null;
    selectedMilestoneDay.value = null;

    reachCtrl.clear();
    viewsCtrl.clear();
    likesCtrl.clear();
    commentsCtrl.clear();

    // STEP 5
    needToSendSample.value = false;
    sampleGuidelinesConfirmed.value = false;

    contentAssets.clear();
    brandAssets.clear();

    // Re-add your demo prefills (same as onInit)
    contentAssets.addAll(const [
      JobAsset(
        title: 'Brand Logo Pack',
        meta: 'PNG, SVG – 2.4 MB',
        kind: JobAssetKind.image,
      ),
      JobAsset(
        title: 'Product Demo Video',
        meta: 'MP4 – 80 MB',
        kind: JobAssetKind.video,
      ),
      JobAsset(
        title: 'Brand Guidelines',
        meta: 'PDF – 750 KB',
        kind: JobAssetKind.document,
      ),
    ]);

    brandAssets.add(const BrandAsset(title: 'Facebook Page', value: ''));
  }

  // ---------------- Locale helpers (Bangla digits for ৳ amount) ----------------

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

/// ---------------- Bottom sheets ----------------

class _SimplePickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;

  const _SimplePickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            12.h.verticalSpace,
            ...options.map((e) {
              final active = e == selected;
              return ListTile(
                title: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: active ? Icon(Icons.check_circle, size: 20.sp) : null,
                onTap: () => onSelect(e),
              );
            }),
            8.h.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class _MultiPickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final RxList<String> selected;

  const _MultiPickerSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            12.h.verticalSpace,
            Obx(() {
              final list = selected.toList(growable: false);
              return Column(
                children: options.map((e) {
                  final active = list.contains(e);
                  return CheckboxListTile(
                    value: active,
                    title: Text(
                      e,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onChanged: (_) {
                      if (active) {
                        selected.remove(e);
                      } else {
                        selected.add(e);
                      }
                    },
                  );
                }).toList(),
              );
            }),
            8.h.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('common_done'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignPlacementConfirmedDialog extends StatelessWidget {
  final CreateCampaignController controller;
  const _CampaignPlacementConfirmedDialog({required this.controller});

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _bg = Color(0xFFF6F7F7);

  String _safeTitle() {
    final t = controller.campaignName.value.trim();
    if (t.isNotEmpty) return t;
    final t2 = controller.campaignNameCtrl.text.trim();
    if (t2.isNotEmpty) return t2;
    return 'create_campaign_step6_campaign_title_fallback'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final title = _safeTitle();
    final amount = controller.localizedTotalBudgetText;

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
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
              // top row (close)
              Row(
                children: [
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(999.r),
                    onTap: controller.finishFlowAndReset,
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(
                        Icons.close,
                        size: 22.sp,
                        color: _primary.withOpacity(.65),
                      ),
                    ),
                  ),
                ],
              ),

              6.h.verticalSpace,

              // check icon
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(.60),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.check, size: 44.sp, color: Colors.white),
              ),

              14.h.verticalSpace,

              Text(
                'create_campaign_step6_popup_title'
                    .tr, // "Campaign Placement Confirmed"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                ),
              ),

              8.h.verticalSpace,

              Text(
                'create_campaign_step6_popup_message'
                    .tr, // "We will review... 3–5 business days"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.35,
                  color: _primary.withOpacity(.85),
                  fontWeight: FontWeight.w500,
                ),
              ),

              16.h.verticalSpace,

              // green summary card (like screenshot)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(.70),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        10.w.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              6.h.verticalSpace,
                              Row(
                                children: [
                                  Text(
                                    '৳',
                                    style: TextStyle(
                                      color: const Color(0xFFDCE8CB),
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  6.w.horizontalSpace,
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        amount,
                                        style: TextStyle(
                                          color: const Color(0xFFDCE8CB),
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    10.h.verticalSpace,
                    Divider(color: Colors.white.withOpacity(.35), height: 1),
                    10.h.verticalSpace,

                    Row(
                      children: [
                        Text(
                          'common_platforms'.tr,
                          style: TextStyle(
                            color: const Color(0xFFDCE8CB),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        10.w.horizontalSpace,
                        _MiniPlatform(icon: Icons.camera_alt_outlined),
                        8.w.horizontalSpace,
                        _MiniPlatform(icon: Icons.play_circle_outline),
                        8.w.horizontalSpace,
                        _MiniPlatform(icon: Icons.music_note_outlined),
                      ],
                    ),
                  ],
                ),
              ),

              10.h.verticalSpace,

              // subtle bottom spacing
              Container(width: double.infinity, height: 1, color: _bg),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPlatform extends StatelessWidget {
  final IconData icon;
  const _MiniPlatform({required this.icon});

  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: Colors.white.withOpacity(.22)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16.sp, color: Colors.white),
    );
  }
}
