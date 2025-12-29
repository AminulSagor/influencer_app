import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/models/job_item.dart';
import '../../../core/utils/currency_formatter.dart';
import '../create_campaign/create_campaign_controller/create_campaign_controller.dart';

enum CampaignProgressStep { submitted, quoted, paid, promoting, completed }

class BrandAssetLink {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? url;

  const BrandAssetLink({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.url,
  });
}

class PaidAdAgencyOffer {
  final String name;
  final int agencyFeePercent; // e.g. 10
  const PaidAdAgencyOffer({required this.name, this.agencyFeePercent = 10});
}

class BrandCampaignDetailsController extends GetxController {
  // ✅ PaidAd tabs (0 = Agency Bids, 1 = Campaign Details)
  final paidAdTabIndex = 1.obs;
  void setPaidAdTab(int i) => paidAdTabIndex.value = i.clamp(0, 1);

  // ✅ PaidAd: agency bids list (screenshot 2)
  final agencyOffers = <PaidAdAgencyOffer>[].obs;

  /// Expect either:
  /// - Get.toNamed(..., arguments: jobItem)
  /// - Get.toNamed(..., arguments: {'job': jobItem, 'campaignType': 'paidAd', ...})
  /// Also supports no args -> uses CreateCampaignController (if registered) -> demo fallbacks.
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

  // Expandables
  final briefExpanded = true.obs;
  final assetsExpanded = true.obs;
  final termsExpanded = true.obs;
  final milestonesExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();

    // 0) read campaignType/targeting from args if provided
    _readMetaArgs(arguments);

    // 1) Try to load from navigation args (JobItem or {job: JobItem})
    final argJob = _extractJob(arguments);
    if (argJob != null) {
      job = argJob;
      _loadFromJob(argJob);
      _applyFallbacks();
      return;
    }

    // 2) If coming from CreateCampaign flow, use it (old behavior)
    if (Get.isRegistered<CreateCampaignController>()) {
      final c = Get.find<CreateCampaignController>();
      _loadFromCreateCampaign(c);
      _applyFallbacks();
      return;
    }

    // 3) Last resort: demo defaults
    _loadDemo();
  }

  // -------------------------
  // Args helpers
  // -------------------------

  void _ensureDummyMilestonesIfEmpty() {
    if (milestones.isNotEmpty) return;

    milestones.assignAll(const [
      Milestone(
        stepLabel: '1',
        title: 'Initial Content Creation',
        subtitle: '2 Instagram Posts + 3 Stories',
        dayLabel: 'DAY 1',
        status: MilestoneStatus.approved, // ✅ Completed style
      ),
      Milestone(
        stepLabel: '2',
        title: 'YouTube Video Upload',
        subtitle: '1 Sponsored Video (60 Sec)',
        dayLabel: 'DAY 2',
        status: MilestoneStatus.paid, // ✅ Completed style
      ),
      Milestone(
        stepLabel: '3',
        title: 'TikTok Campaign',
        subtitle: '1 Sponsored Video (60 Sec)',
        dayLabel: 'DAY 3',
        status: MilestoneStatus.inReview, // 🟠 In Review
      ),
      Milestone(
        stepLabel: '4',
        title: 'Campaign Wrap Up',
        subtitle: 'Final Report + 2 Stories',
        dayLabel: 'DAY 4',
        status: MilestoneStatus.declined, // 🔴 Declined
      ),
    ]);
  }

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

  void _loadDemo() {
    campaignType.value = campaignType.value.trim().isEmpty
        ? 'paidAd'
        : campaignType.value;

    campaignTitle.value = 'Summer Fashion Campaign';
    budgetText.value = '৳5,000';

    targetingText.value = 'Crowd';

    influencers.assignAll(['Influencer A', 'Influencer B']);

    platforms.assignAll(const <IconData>[
      Icons.facebook,
      Icons.camera_alt_outlined,
      Icons.play_circle_outline,
      Icons.music_note_outlined,
    ]);

    daysRemaining.value = 8;
    deadlineDateText.value = 'Dec 15, 2025';

    baseBudget.value = 15000;
    vatAmount.value = 2000;

    contentRequirements.assignAll(const [
      'Minimum 2 Instagram Feed Posts',
      '3 Stories (8h Swipe Up Link)',
      '1 YouTube Short (30–60 Seconds)',
      '3 TikTok Video (Featuring Trending Sounds)',
    ]);

    dosText.value =
        'Show authentic usage, mention eco-friendly aspects\n'
        'Tag @StyleCo in all posts\n'
        'Show products in natural lighting\n'
        'Include discount code in captions';

    dontsText.value =
        'Avoid misleading claims\n'
        'Do not use competitor branding\n'
        'Don’t edit product colors unrealistically\n'
        'Don’t hide discount code';

    reportingRequirements.value =
        'Provide analytics screenshots 7 days post-publication (include reach, engagement, and click-through rates).';

    usageRights.value =
        'Brand retains rights to repost content on official channels with proper attribution.';

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

    if (milestones.isEmpty) {
      milestones.addAll(const [
        Milestone(
          stepLabel: '1',
          title: 'Initial Brand Awareness',
          subtitle: '2 Instagram Posts + 3 Stories',
          dayLabel: 'DAY 1',
          status: MilestoneStatus.todo,
        ),
        Milestone(
          stepLabel: '2',
          title: 'Lead Generation',
          subtitle: '1 Sponsored Video (60 sec)',
          dayLabel: 'DAY 2',
          status: MilestoneStatus.todo,
        ),
        Milestone(
          stepLabel: '3',
          title: 'Sales Conversion',
          subtitle: '1 Sponsored Video (60 sec)',
          dayLabel: 'DAY 3',
          status: MilestoneStatus.todo,
        ),
        Milestone(
          stepLabel: '4',
          title: 'Campaign Wrap Up',
          subtitle: 'Final Report + 2 Stories',
          dayLabel: 'DAY 4',
          status: MilestoneStatus.todo,
        ),
      ]);
    }

    if (brandAssets.isEmpty) {
      brandAssets.addAll(const [
        BrandAssetLink(
          title: 'Facebook Page',
          subtitle: 'Page Link',
          icon: Icons.facebook,
          url: 'https://facebook.com/',
        ),
      ]);
    }
  }

  void _applyFallbacks() {
    // If platforms/influencers are not provided anywhere, keep a safe default
    if (influencers.isEmpty) {
      influencers.assignAll(['Influencer A', 'Influencer B']);
    }
    if (platforms.isEmpty) {
      platforms.assignAll(const <IconData>[
        Icons.facebook,
        Icons.camera_alt_outlined,
        Icons.play_circle_outline,
        Icons.music_note_outlined,
      ]);
    }

    if (isPaidAd && targetingText.value.trim().isEmpty) {
      targetingText.value = 'Crowd';
    }

    if (campaignGoals.value.trim().isEmpty) {
      campaignGoals.value =
          'Promote our new summer skincare line to Gen Z and millennial audiences. Focus on natural ingredients and sustainable packaging.';
    }

    if (productServiceDetails.value.trim().isEmpty) {
      productServiceDetails.value =
          'Promote our new summer skincare line to Gen Z and millennial audiences. Focus on natural ingredients and sustainable packaging.';
    }

    if (contentRequirements.isEmpty) {
      contentRequirements.assignAll(const [
        'Minimum 2 Instagram Feed Posts',
        '3 Stories (8h Swipe Up Link)',
        '1 YouTube Short (30–60 Seconds)',
        '3 TikTok Video (Featuring Trending Sounds)',
      ]);
    }

    if (dosText.value.trim().isEmpty) {
      dosText.value =
          'Show authentic usage, mention eco-friendly aspects\n'
          'Tag @Brand in all posts\n'
          'Show products in natural lighting\n'
          'Include discount code in captions';
    }

    if (dontsText.value.trim().isEmpty) {
      dontsText.value =
          'Avoid misleading claims\n'
          'Do not use competitor branding\n'
          'Don’t edit product colors unrealistically\n'
          'Don’t hide discount code';
    }

    if (reportingRequirements.value.trim().isEmpty) {
      reportingRequirements.value =
          'Provide analytics screenshots 7 days post-publication (include reach, engagement, and click-through rates).';
    }

    if (usageRights.value.trim().isEmpty) {
      usageRights.value =
          'Brand retains rights to repost content on official channels with proper attribution.';
    }

    // Brand assets default for PaidAd (screenshot)
    if (isPaidAd && brandAssets.isEmpty) {
      brandAssets.add(
        const BrandAssetLink(
          title: 'Facebook Page',
          subtitle: 'Page Link',
          icon: Icons.facebook,
        ),
      );
    }

    if (isPaidAd && agencyOffers.isEmpty) {
      agencyOffers.assignAll(const [
        PaidAdAgencyOffer(name: 'Trendy Ad', agencyFeePercent: 10),
        PaidAdAgencyOffer(name: 'GrowBig', agencyFeePercent: 10),
        PaidAdAgencyOffer(name: 'Social Growth', agencyFeePercent: 10),
        PaidAdAgencyOffer(name: 'Social Growth', agencyFeePercent: 10),
      ]);
    }

    _ensureDummyMilestonesIfEmpty();
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

  void setRating(int v) => rating.value = v.clamp(0, 5);

  void onRequestQuote() {
    if (isPaidAd) {
      _openPaidAdRequoteDialog(); // new UI (your screenshots 1 & 2)
    } else {
      _openRequoteDialog(); // keep your previous one (already in file)
    }
  }

  void onAcceptQuote() {
    if (isPaidAd) {
      setPaidAdTab(0);
      // _openConfirmBudgetDialog(); // new UI (your screenshots 3 & 4)
    } else {
      _openFundCampaignDialog(); // keep your previous one
    }
  }

  void onDownloadAsset(int index) {
    Get.snackbar(
      'brand_campaign_details_assets'.tr,
      'brand_campaign_details_download_msg'.tr,
    );
  }

  void removeBrandAsset(int index) {
    if (index < 0 || index >= brandAssets.length) return;
    brandAssets.removeAt(index);
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
                trOr('brand_campaign_requote_overview', 'New Requote Overview'),
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
                  onPressed: () {
                    if (budgetRx.value <= 0) return;

                    baseBudget.value = budgetRx.value;
                    vatAmount.value = vatRx.value;

                    Get.back();
                    Get.snackbar(
                      trOr('brand_campaign_details_quote', 'Quote'),
                      trOr(
                        'brand_campaign_requote_sent',
                        'Requote request sent to admin.',
                      ),
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
                trOr('brand_campaign_requote_overview', 'New Requote Overview'),
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
                  onPressed: () {
                    if (budgetRx.value <= 0) {
                      Get.snackbar(
                        trOr('common_error', 'Error'),
                        trOr(
                          'brand_campaign_requote_invalid',
                          'Please enter a valid budget.',
                        ),
                      );
                      return;
                    }

                    // Update UI numbers immediately (so user sees new quote breakdown)
                    baseBudget.value = budgetRx.value;
                    vatAmount.value = vatRx.value;

                    Get.back();
                    Get.snackbar(
                      trOr('brand_campaign_details_quote'.tr, 'Quote'),
                      trOr(
                        'brand_campaign_requote_sent',
                        'Requote request sent to admin.',
                      ),
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
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          trOr('brand_campaign_confirmed', 'Confirmed'),
                          trOr(
                            'brand_campaign_confirmed_msg',
                            'Budget confirmed successfully.',
                          ),
                        );
                        // If needed: call your API here for "accept quote"
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

    final totalDue = totalCost <= 0 ? 18000 : totalCost;
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
                          ? () {
                              Get.back();
                              Get.snackbar(
                                trOr('brand_campaign_payment', 'Payment'),
                                trOr(
                                  'brand_campaign_payment_success',
                                  'Payment initiated.',
                                ),
                              );
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
}
