import 'dart:developer' as dev;

import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';

import '../../../core/models/job_item.dart';
import '../../../routes/app_routes.dart';

class JobsController extends GetxController {
  final currentTabIndex = 0.obs;

  /// used by search bar
  final searchQuery = ''.obs;

  /// sort toggle (used by the "Low to High" chip)
  final isSortLowToHigh = true.obs;
  void toggleSort() => isSortLowToHigh.value = !isSortLowToHigh.value;

  /// Brand: Budgeting & Quoting chip filter
  /// 0 = All, 1 = Budget Pending, 2 = Quotation Received
  final brandBudgetChipIndex = 0.obs;
  void setBrandBudgetChip(int index) => brandBudgetChipIndex.value = index;

  final AccountTypeService _accountTypeService = Get.find<AccountTypeService>();
  bool get isBrand => _accountTypeService.isBrand;

  // ---------------- INFLUENCER / AGENCY LISTS ----------------

  final newOffers = <JobItem>[].obs;
  final activeJobs = <JobItem>[].obs;
  final completedJobs = <JobItem>[].obs;
  final pendingPayments = <JobItem>[].obs;
  final declinedJobs = <JobItem>[].obs;

  final isLoadingNewOffers = false.obs;
  final isLoadingActiveJobs = false.obs;
  final isLoadingCompletedJobs = false.obs;
  final isLoadingPendingPayments = false.obs;
  final isLoadingDeclinedJobs = false.obs;

  final hasMoreNewOffers = true.obs;
  final hasMoreActiveJobs = true.obs;
  final hasMoreCompletedJobs = true.obs;
  final hasMorePendingPayments = true.obs;
  final hasMoreDeclinedJobs = true.obs;

  int _newOffersPage = 1;
  int _activeJobsPage = 1;
  int _completedJobsPage = 1;
  int _pendingPaymentsPage = 1;
  int _declinedJobsPage = 1;

  // ---------------- BRAND LISTS ----------------

  final brandActive = <JobItem>[].obs; // tab 0
  final brandBudgeting = <JobItem>[].obs; // tab 1
  final brandCompleted = <JobItem>[].obs; // tab 2
  final brandDrafts = <JobItem>[].obs; // tab 3
  final brandCanceled = <JobItem>[].obs; // tab 4

  final isLoadingBrandActive = false.obs;
  final isLoadingBrandBudgeting = false.obs;
  final isLoadingBrandCompleted = false.obs;
  final isLoadingBrandDrafts = false.obs;
  final isLoadingBrandCanceled = false.obs;

  final hasMoreBrandActive = true.obs;
  final hasMoreBrandBudgeting = true.obs;
  final hasMoreBrandCompleted = true.obs;
  final hasMoreBrandDrafts = true.obs;
  final hasMoreBrandCanceled = true.obs;

  int _brandActivePage = 1;
  int _brandBudgetingPage = 1;
  int _brandCompletedPage = 1;
  int _brandDraftsPage = 1;
  int _brandCanceledPage = 1;

  static const int _pageSize = 10;
  static const int _totalPerTab = 30;

  @override
  void onInit() {
    super.onInit();
    _initLoad();
  }

  Future<void> _initLoad() async {
    if (isBrand) {
      await Future.wait([
        fetchBrandActive(reset: true),
        fetchBrandBudgeting(reset: true),
        fetchBrandCompleted(reset: true),
        fetchBrandDrafts(reset: true),
        fetchBrandCanceled(reset: true),
      ]);
    } else {
      await Future.wait([
        fetchNewOffers(reset: true),
        fetchActiveJobs(reset: true),
        fetchCompletedJobs(reset: true),
        fetchPendingPayments(reset: true),
        fetchDeclinedJobs(reset: true),
      ]);
    }
  }

  // -------- PUBLIC API --------

  void changeTab(int index) {
    currentTabIndex.value = index;

    if (isBrand) {
      switch (index) {
        case 0:
          if (brandActive.isEmpty) fetchBrandActive(reset: true);
          break;
        case 1:
          if (brandBudgeting.isEmpty) fetchBrandBudgeting(reset: true);
          break;
        case 2:
          if (brandCompleted.isEmpty) fetchBrandCompleted(reset: true);
          break;
        case 3:
          if (brandDrafts.isEmpty) fetchBrandDrafts(reset: true);
          break;
        case 4:
          if (brandCanceled.isEmpty) fetchBrandCanceled(reset: true);
          break;
      }
      return;
    }

    switch (index) {
      case 0:
        if (newOffers.isEmpty) fetchNewOffers(reset: true);
        break;
      case 1:
        if (activeJobs.isEmpty) fetchActiveJobs(reset: true);
        break;
      case 2:
        if (completedJobs.isEmpty) fetchCompletedJobs(reset: true);
        break;
      case 3:
        if (pendingPayments.isEmpty) fetchPendingPayments(reset: true);
        break;
      case 4:
        if (declinedJobs.isEmpty) fetchDeclinedJobs(reset: true);
        break;
    }
  }

  Future<void> loadMoreForTab(int index) async {
    if (isBrand) {
      switch (index) {
        case 0:
          await fetchBrandActive();
          break;
        case 1:
          await fetchBrandBudgeting();
          break;
        case 2:
          await fetchBrandCompleted();
          break;
        case 3:
          await fetchBrandDrafts();
          break;
        case 4:
          await fetchBrandCanceled();
          break;
      }
      return;
    }

    switch (index) {
      case 0:
        await fetchNewOffers();
        break;
      case 1:
        await fetchActiveJobs();
        break;
      case 2:
        await fetchCompletedJobs();
        break;
      case 3:
        await fetchPendingPayments();
        break;
      case 4:
        await fetchDeclinedJobs();
        break;
    }
  }

  int getCountForTab(int index) {
    if (isBrand) {
      switch (index) {
        case 0:
          return brandActive.length;
        case 1:
          return brandBudgeting.length;
        case 2:
          return brandCompleted.length;
        case 3:
          return brandDrafts.length;
        case 4:
          return brandCanceled.length;
        default:
          return 0;
      }
    }

    switch (index) {
      case 0:
        return newOffers.length;
      case 1:
        return activeJobs.length;
      case 2:
        return completedJobs.length;
      case 3:
        return pendingPayments.length;
      case 4:
        return declinedJobs.length;
      default:
        return 0;
    }
  }

  void openJobDetails(JobItem job) {
    dev.log('JOB TYPE: ${job.campaignType}');
    if (_accountTypeService.isBrand) {
      Get.toNamed(AppRoutes.brandCampaignDetails, id: 1, arguments: job);
    } else {
      Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: job);
    }
  }

  // -------- FILTER + SORT HELPERS --------

  List<JobItem> _filterList(List<JobItem> source) {
    final q = searchQuery.value.trim().toLowerCase();

    // IMPORTANT: never sort/mutate the RxList itself during build.
    final List<JobItem> base = List<JobItem>.from(source);

    Iterable<JobItem> filtered = base;

    if (q.isNotEmpty) {
      filtered = base.where((job) {
        final title = job.title.toLowerCase();
        final sub = (job.subTitle ?? '').toLowerCase();
        final client = job.clientName.toLowerCase();
        return title.contains(q) || sub.contains(q) || client.contains(q);
      });
    }

    final out = filtered.toList();

    out.sort(
      (a, b) => isSortLowToHigh.value
          ? a.budget.compareTo(b.budget)
          : b.budget.compareTo(a.budget),
    );

    return out;
  }

  // Influencer/Agency
  List<JobItem> get filteredNewOffers => _filterList(newOffers);
  List<JobItem> get filteredActiveJobs => _filterList(activeJobs);
  List<JobItem> get filteredCompletedJobs => _filterList(completedJobs);
  List<JobItem> get filteredPendingPayments => _filterList(pendingPayments);
  List<JobItem> get filteredDeclinedJobs => _filterList(declinedJobs);

  // Brand
  List<JobItem> get filteredBrandActive => _filterList(brandActive);
  List<JobItem> get filteredBrandCompleted => _filterList(brandCompleted);
  List<JobItem> get filteredBrandDrafts => _filterList(brandDrafts);
  List<JobItem> get filteredBrandCanceled => _filterList(brandCanceled);

  int get brandBudgetPendingCount => brandBudgeting
      .where((e) => (e.profitLabel ?? '') == 'Budget Pending')
      .length;

  int get brandQuotationReceivedCount => brandBudgeting
      .where((e) => (e.profitLabel ?? '') == 'Quotation Received')
      .length;

  List<JobItem> get filteredBrandBudgeting {
    final all = _filterList(brandBudgeting);
    switch (brandBudgetChipIndex.value) {
      case 1:
        return all
            .where((e) => (e.profitLabel ?? '') == 'Budget Pending')
            .toList();
      case 2:
        return all
            .where((e) => (e.profitLabel ?? '') == 'Quotation Received')
            .toList();
      default:
        return all;
    }
  }

  // -------- INFLUENCER/AGENCY FETCH (same as before) --------

  Future<void> fetchNewOffers({bool reset = false}) async {
    if (isLoadingNewOffers.value) return;
    if (!hasMoreNewOffers.value && !reset) return;

    isLoadingNewOffers.value = true;
    if (reset) {
      _newOffersPage = 1;
      hasMoreNewOffers.value = true;
      newOffers.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 0,
      page: _newOffersPage,
      pageSize: _pageSize,
      mode: _MockMode.influencer,
    );
    if (items.isEmpty) {
      hasMoreNewOffers.value = false;
    } else {
      newOffers.addAll(items);
      _newOffersPage++;
      if (items.length < _pageSize) hasMoreNewOffers.value = false;
    }
    isLoadingNewOffers.value = false;
  }

  Future<void> fetchActiveJobs({bool reset = false}) async {
    if (isLoadingActiveJobs.value) return;
    if (!hasMoreActiveJobs.value && !reset) return;

    isLoadingActiveJobs.value = true;
    if (reset) {
      _activeJobsPage = 1;
      hasMoreActiveJobs.value = true;
      activeJobs.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 1,
      page: _activeJobsPage,
      pageSize: _pageSize,
      mode: _MockMode.influencer,
    );
    if (items.isEmpty) {
      hasMoreActiveJobs.value = false;
    } else {
      activeJobs.addAll(items);
      _activeJobsPage++;
      if (items.length < _pageSize) hasMoreActiveJobs.value = false;
    }
    isLoadingActiveJobs.value = false;
  }

  Future<void> fetchCompletedJobs({bool reset = false}) async {
    if (isLoadingCompletedJobs.value) return;
    if (!hasMoreCompletedJobs.value && !reset) return;

    isLoadingCompletedJobs.value = true;
    if (reset) {
      _completedJobsPage = 1;
      hasMoreCompletedJobs.value = true;
      completedJobs.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 2,
      page: _completedJobsPage,
      pageSize: _pageSize,
      mode: _MockMode.influencer,
    );
    if (items.isEmpty) {
      hasMoreCompletedJobs.value = false;
    } else {
      completedJobs.addAll(items);
      _completedJobsPage++;
      if (items.length < _pageSize) hasMoreCompletedJobs.value = false;
    }
    isLoadingCompletedJobs.value = false;
  }

  Future<void> fetchPendingPayments({bool reset = false}) async {
    if (isLoadingPendingPayments.value) return;
    if (!hasMorePendingPayments.value && !reset) return;

    isLoadingPendingPayments.value = true;
    if (reset) {
      _pendingPaymentsPage = 1;
      hasMorePendingPayments.value = true;
      pendingPayments.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 3,
      page: _pendingPaymentsPage,
      pageSize: _pageSize,
      mode: _MockMode.influencer,
    );
    if (items.isEmpty) {
      hasMorePendingPayments.value = false;
    } else {
      pendingPayments.addAll(items);
      _pendingPaymentsPage++;
      if (items.length < _pageSize) hasMorePendingPayments.value = false;
    }
    isLoadingPendingPayments.value = false;
  }

  Future<void> fetchDeclinedJobs({bool reset = false}) async {
    if (isLoadingDeclinedJobs.value) return;
    if (!hasMoreDeclinedJobs.value && !reset) return;

    isLoadingDeclinedJobs.value = true;
    if (reset) {
      _declinedJobsPage = 1;
      hasMoreDeclinedJobs.value = true;
      declinedJobs.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 4,
      page: _declinedJobsPage,
      pageSize: _pageSize,
      mode: _MockMode.influencer,
    );
    if (items.isEmpty) {
      hasMoreDeclinedJobs.value = false;
    } else {
      declinedJobs.addAll(items);
      _declinedJobsPage++;
      if (items.length < _pageSize) hasMoreDeclinedJobs.value = false;
    }
    isLoadingDeclinedJobs.value = false;
  }

  // -------- BRAND FETCH --------

  Future<void> fetchBrandActive({bool reset = false}) async {
    if (isLoadingBrandActive.value) return;
    if (!hasMoreBrandActive.value && !reset) return;

    isLoadingBrandActive.value = true;
    if (reset) {
      _brandActivePage = 1;
      hasMoreBrandActive.value = true;
      brandActive.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 0,
      page: _brandActivePage,
      pageSize: _pageSize,
      mode: _MockMode.brand,
    );
    if (items.isEmpty) {
      hasMoreBrandActive.value = false;
    } else {
      brandActive.addAll(items);
      _brandActivePage++;
      if (items.length < _pageSize) hasMoreBrandActive.value = false;
    }
    isLoadingBrandActive.value = false;
  }

  Future<void> fetchBrandBudgeting({bool reset = false}) async {
    if (isLoadingBrandBudgeting.value) return;
    if (!hasMoreBrandBudgeting.value && !reset) return;

    isLoadingBrandBudgeting.value = true;
    if (reset) {
      _brandBudgetingPage = 1;
      hasMoreBrandBudgeting.value = true;
      brandBudgeting.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 1,
      page: _brandBudgetingPage,
      pageSize: _pageSize,
      mode: _MockMode.brand,
    );
    if (items.isEmpty) {
      hasMoreBrandBudgeting.value = false;
    } else {
      brandBudgeting.addAll(items);
      _brandBudgetingPage++;
      if (items.length < _pageSize) hasMoreBrandBudgeting.value = false;
    }
    isLoadingBrandBudgeting.value = false;
  }

  Future<void> fetchBrandCompleted({bool reset = false}) async {
    if (isLoadingBrandCompleted.value) return;
    if (!hasMoreBrandCompleted.value && !reset) return;

    isLoadingBrandCompleted.value = true;
    if (reset) {
      _brandCompletedPage = 1;
      hasMoreBrandCompleted.value = true;
      brandCompleted.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 2,
      page: _brandCompletedPage,
      pageSize: _pageSize,
      mode: _MockMode.brand,
    );
    if (items.isEmpty) {
      hasMoreBrandCompleted.value = false;
    } else {
      brandCompleted.addAll(items);
      _brandCompletedPage++;
      if (items.length < _pageSize) hasMoreBrandCompleted.value = false;
    }
    isLoadingBrandCompleted.value = false;
  }

  Future<void> fetchBrandDrafts({bool reset = false}) async {
    if (isLoadingBrandDrafts.value) return;
    if (!hasMoreBrandDrafts.value && !reset) return;

    isLoadingBrandDrafts.value = true;
    if (reset) {
      _brandDraftsPage = 1;
      hasMoreBrandDrafts.value = true;
      brandDrafts.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 3,
      page: _brandDraftsPage,
      pageSize: _pageSize,
      mode: _MockMode.brand,
    );
    if (items.isEmpty) {
      hasMoreBrandDrafts.value = false;
    } else {
      brandDrafts.addAll(items);
      _brandDraftsPage++;
      if (items.length < _pageSize) hasMoreBrandDrafts.value = false;
    }
    isLoadingBrandDrafts.value = false;
  }

  Future<void> fetchBrandCanceled({bool reset = false}) async {
    if (isLoadingBrandCanceled.value) return;
    if (!hasMoreBrandCanceled.value && !reset) return;

    isLoadingBrandCanceled.value = true;
    if (reset) {
      _brandCanceledPage = 1;
      hasMoreBrandCanceled.value = true;
      brandCanceled.clear();
    }

    final items = await _mockFetchJobs(
      tabIndex: 4,
      page: _brandCanceledPage,
      pageSize: _pageSize,
      mode: _MockMode.brand,
    );
    if (items.isEmpty) {
      hasMoreBrandCanceled.value = false;
    } else {
      brandCanceled.addAll(items);
      _brandCanceledPage++;
      if (items.length < _pageSize) hasMoreBrandCanceled.value = false;
    }
    isLoadingBrandCanceled.value = false;
  }

  // -------- MOCK API --------

  Future<List<JobItem>> _mockFetchJobs({
    required int tabIndex,
    required int page,
    required int pageSize,
    required _MockMode mode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));

    final start = (page - 1) * pageSize;
    if (start >= _totalPerTab) return [];

    final endExclusive = start + pageSize;
    final actualEnd = endExclusive > _totalPerTab ? _totalPerTab : endExclusive;
    final count = actualEnd - start;

    return List.generate(count, (i) {
      final globalIndex = start + i;
      return mode == _MockMode.brand
          ? _buildBrandMock(tabIndex: tabIndex, index: globalIndex)
          : _buildInfluencerMock(tabIndex: tabIndex, index: globalIndex);
    });
  }

  JobItem _buildBrandMock({required int tabIndex, required int index}) {
    final pattern = index % 3;

    // Brand tabs:
    // 0 Active, 1 Budgeting, 2 Completed, 3 Draft, 4 Canceled

    if (tabIndex == 1) {
      // Budgeting & Quoting: mix Budget Pending + Quotation Received
      if (pattern == 2) {
        return JobItem(
          title: 'Fitness Brand Partnership',
          subTitle: 'Paid Ad',
          campaignType: CampaignType.paidAd,
          clientName: 'GrowBig',
          dateLabel: 'Dec 15, 2025',
          budget: 32000,
          sharePercent: 0,
          profitLabel: 'Quotation Received',
          progressPercent: 12, // using as "received count"
          totalEarningsLabel: 'Revised: 0 Times',
        );
      }

      return JobItem(
        title: pattern == 0
            ? 'Summer Fashion Campaign'
            : 'Different Paid Ad Campaign',
        subTitle: pattern == 0 ? 'Influencer Promotion' : 'Paid Ad',
        campaignType: pattern == 0
            ? CampaignType.influencerPromotion
            : CampaignType.paidAd,
        clientName: pattern == 0 ? 'Hania Amir, +2' : 'Salman Khan, +1',
        dateLabel: 'Dec 15, 2025',
        budget: pattern == 0 ? 11000 : 18000,
        sharePercent: 0,
        profitLabel: 'Budget Pending',
        totalEarningsLabel: pattern == 0
            ? 'Revised: 0 Times'
            : 'Revised: 5 Times',
      );
    }

    // Active
    if (tabIndex == 0) {
      return JobItem(
        title: pattern == 0
            ? 'Summer Fashion Campaign'
            : pattern == 1
            ? 'Tech Product Launch'
            : 'Fitness Brand Partnership',
        subTitle: pattern == 2 ? 'Paid Ad' : 'Influencer Promotion',
        campaignType: pattern == 2
            ? CampaignType.paidAd
            : CampaignType.influencerPromotion,
        clientName: pattern == 0
            ? 'Hania Amir, +2'
            : pattern == 1
            ? 'Salman Khan, +1'
            : 'GrowBig',
        dateLabel: pattern == 0
            ? 'Dec 15, 2025'
            : pattern == 1
            ? 'Dec 28, 2025'
            : 'Dec 26, 2025',
        budget: pattern == 0
            ? 11000
            : pattern == 1
            ? 18000
            : 32000,
        sharePercent: 0,
        progressPercent: pattern == 0
            ? 75
            : pattern == 1
            ? 40
            : 90,
        dueLabel: pattern == 0
            ? 'Due: 3 Days'
            : pattern == 1
            ? 'Due: 4 Days'
            : 'Due: Tomorrow',
      );
    }

    // Completed (with rating)
    if (tabIndex == 2) {
      return JobItem(
        title: pattern == 0
            ? 'Summer Fashion Campaign'
            : pattern == 1
            ? 'Tech Product Launch'
            : 'Fitness Brand Partnership',
        subTitle: pattern == 2 ? 'Paid Ad' : 'Influencer Promotion',
        campaignType: pattern == 2
            ? CampaignType.paidAd
            : CampaignType.influencerPromotion,
        clientName: pattern == 0
            ? 'Hania Amir, +2'
            : pattern == 1
            ? 'Salman Khan, +1'
            : 'Hania Amir +1',
        dateLabel: pattern == 0
            ? 'Dec 15, 2025'
            : pattern == 1
            ? 'Dec 28, 2025'
            : 'Dec 26, 2025',
        budget: pattern == 0
            ? 11000
            : pattern == 1
            ? 18000
            : 32000,
        sharePercent: 0,
        rating: pattern == 0 ? 4 : (pattern == 1 ? 5 : 4),
      );
    }

    // Drafts
    if (tabIndex == 3) {
      return JobItem(
        title: pattern == 0
            ? 'Summer Fashion Campaign'
            : pattern == 1
            ? 'Tech Product Launch'
            : 'Fitness Brand Partnership',
        subTitle: pattern == 2 ? 'Paid Ad' : 'Influencer Promotion',
        campaignType: pattern == 2
            ? CampaignType.paidAd
            : CampaignType.influencerPromotion,
        clientName: '',
        dateLabel: pattern == 0
            ? 'Dec 15, 2025'
            : pattern == 1
            ? 'Dec 28, 2025'
            : 'Dec 26, 2025',
        budget: pattern == 0
            ? 11000
            : pattern == 1
            ? 18000
            : 32000,
        sharePercent: 0,
      );
    }

    // Canceled
    return JobItem(
      title: pattern == 0
          ? 'Summer Fashion Campaign'
          : pattern == 1
          ? 'Tech Product Launch'
          : 'Fitness Brand Partnership',
      subTitle: pattern == 2 ? 'Paid Ad' : 'Influencer Promotion',
      campaignType: pattern == 2
          ? CampaignType.paidAd
          : CampaignType.influencerPromotion,
      clientName: pattern == 0
          ? 'Hania Amir, +2'
          : pattern == 1
          ? 'Salman Khan, +1'
          : 'GrowBig',
      dateLabel: pattern == 0
          ? 'Dec 15, 2025'
          : pattern == 1
          ? 'Dec 28, 2025'
          : 'Dec 26, 2025',
      budget: pattern == 0
          ? 11000
          : pattern == 1
          ? 18000
          : 32000,
      sharePercent: 0,
    );
  }

  JobItem _buildInfluencerMock({required int tabIndex, required int index}) {
    final pattern = index % 3;
    final accountTypeService = Get.find<AccountTypeService>();
    final isInfluencer = accountTypeService.isInfluencer;

    List<Milestone> summerMilestones = [
      Milestone(
        stepLabel: '1',
        title: 'Initial Brand Awareness',
        subtitle: '2 Instagram Posts + 2 Stories',
        amountLabel: '৳3,000',
        dayLabel: 'DAY 1',
        status: MilestoneStatus.declined,
      ),
      Milestone(
        stepLabel: '2',
        title: 'Lead Generation',
        subtitle: '1 Sponsored Video (60 sec)',
        amountLabel: '৳5,000',
        dayLabel: 'DAY 2',
        status: isInfluencer ? MilestoneStatus.approved : MilestoneStatus.paid,
      ),
      Milestone(
        stepLabel: '3',
        title: 'Sales Conversion',
        subtitle: '1 Sponsored Video (60 sec)',
        amountLabel: '৳2,000',
        dayLabel: 'DAY 3',
        status: MilestoneStatus.inReview,
      ),
      Milestone(
        stepLabel: '4',
        title: 'Campaign Wrap Up',
        subtitle: 'Final Report',
        amountLabel: '৳1,000',
        dayLabel: 'DAY 4',
        status: MilestoneStatus.todo,
      ),
    ];

    const List<Milestone> techMilestones = [
      Milestone(
        stepLabel: '1',
        title: 'Teaser Content',
        subtitle: 'Short launch teaser',
        amountLabel: '৳4,000',
        dayLabel: 'DAY 1',
      ),
      Milestone(
        stepLabel: '2',
        title: 'Launch Live Stream',
        subtitle: 'Launch day live session',
        amountLabel: '৳6,000',
        dayLabel: 'DAY 3',
      ),
    ];

    const List<Milestone> fitnessMilestones = [
      Milestone(
        stepLabel: '1',
        title: 'Workout Reel',
        subtitle: 'Product in daily routine',
        amountLabel: '৳3,500',
        dayLabel: 'DAY 1',
      ),
      Milestone(
        stepLabel: '2',
        title: 'Story Series',
        subtitle: 'Before & after stories',
        amountLabel: '৳4,500',
        dayLabel: 'DAY 2',
      ),
    ];

    switch (tabIndex) {
      case 0:
        return pattern == 0
            ? JobItem(
                title: 'Summer Fashion Campaign',
                clientName: 'StyleCo',
                campaignType: CampaignType.paidAd,
                dateLabel: 'Dec 15, 2025',
                budget: 111000,
                sharePercent: 10,
                profitLabel: '৳16,500',
                totalCostLabel: '৳111,000',
                milestones: summerMilestones,
              )
            : pattern == 1
            ? JobItem(
                title: 'Tech Product Launch',
                clientName: 'TechGuru',
                campaignType: CampaignType.paidAd,
                dateLabel: 'Dec 28, 2025',
                budget: 111000,
                sharePercent: 15,
                profitLabel: '৳18,000',
                totalCostLabel: '৳111,000',
                milestones: techMilestones,
              )
            : JobItem(
                title: 'Fitness Brand Partnership',
                clientName: 'FitLife',
                campaignType: CampaignType.paidAd,
                dateLabel: 'Dec 26, 2025',
                budget: 111000,
                sharePercent: 5,
                profitLabel: '৳8,000',
                totalCostLabel: '৳111,000',
                milestones: fitnessMilestones,
              );

      case 1:
        return pattern == 0
            ? JobItem(
                title: 'Summer Fashion Campaign',
                clientName: 'StyleCo',
                dateLabel: 'Dec 15, 2025',
                campaignType: CampaignType.paidAd,
                budget: 111000,
                sharePercent: 10,
                progressPercent: 75,
                dueLabel: 'Due: 3 Days',
                profitLabel: '৳16,500',
                totalCostLabel: '৳111,000',
                milestones: summerMilestones,
              )
            : pattern == 1
            ? JobItem(
                title: 'Tech Product Launch',
                clientName: 'TechGuru',
                dateLabel: 'Dec 28, 2025',
                campaignType: CampaignType.paidAd,
                budget: 111000,
                sharePercent: 15,
                progressPercent: 40,
                dueLabel: 'Due: 4 Days',
                profitLabel: '৳18,000',
                totalCostLabel: '৳111,000',
                milestones: techMilestones,
              )
            : JobItem(
                title: 'Fitness Brand Partnership',
                clientName: 'FitLife',
                dateLabel: 'Dec 26, 2025',
                campaignType: CampaignType.paidAd,
                budget: 111000,
                sharePercent: 10,
                progressPercent: 90,
                dueLabel: 'Due: Tomorrow',
                profitLabel: '৳8,000',
                totalCostLabel: '৳111,000',
                milestones: fitnessMilestones,
              );

      case 2:
        return pattern == 0
            ? JobItem(
                title: 'Summer Fashion Campaign',
                clientName: 'StyleCo',
                dateLabel: 'Dec 15, 2025',
                campaignType: CampaignType.paidAd,
                budget: 111000,
                sharePercent: 10,
                rating: 4,
                profitLabel: '৳16,500',
                totalCostLabel: '৳111,000',
                milestones: summerMilestones,
              )
            : pattern == 1
            ? JobItem(
                title: 'Tech Product Launch',
                clientName: 'TechGuru',
                dateLabel: 'Dec 28, 2025',
                campaignType: CampaignType.paidAd,
                budget: 111000,
                sharePercent: 15,
                rating: 3,
                profitLabel: '৳18,000',
                totalCostLabel: '৳111,000',
                milestones: techMilestones,
              )
            : JobItem(
                title: 'Fitness Brand Partnership',
                clientName: 'FitLife',
                dateLabel: 'Dec 26, 2025',
                campaignType: CampaignType.paidAd,
                budget: 111000,
                sharePercent: 10,
                rating: 5,
                profitLabel: '৳8,000',
                totalCostLabel: '৳111,000',
                milestones: fitnessMilestones,
              );

      case 3:
      case 4:
      default:
        return JobItem(
          title: pattern == 0
              ? 'Summer Fashion Campaign'
              : pattern == 1
              ? 'Tech Product Launch'
              : 'Fitness Brand Partnership',
          clientName: pattern == 0
              ? 'StyleCo'
              : pattern == 1
              ? 'TechGuru'
              : 'FitLife',
          campaignType: CampaignType.paidAd,
          dateLabel: pattern == 0
              ? 'Dec 15, 2025'
              : pattern == 1
              ? 'Dec 28, 2025'
              : 'Dec 26, 2025',
          budget: 111000,
          sharePercent: 10,
          profitLabel: '৳16,500',
          totalCostLabel: '৳111,000',
          milestones: summerMilestones,
        );
    }
  }
}

enum _MockMode { influencer, brand }
