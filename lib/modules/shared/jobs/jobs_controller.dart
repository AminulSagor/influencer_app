import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

import '../../../core/models/job_item.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_routes.dart';

class JobsController extends GetxController {
  final currentTabIndex = 0.obs;

  /// used by search bar
  final searchQuery = ''.obs;

  /// sort toggle (used by the "Low to High" chip)
  final isSortLowToHigh = true.obs;
  void toggleSort() {
    isSortLowToHigh.value = !isSortLowToHigh.value;

    // ✅ Agency: server-side sort too
    if (isAdAgency && !isBrand) {
      _refetchCurrentAgencyTab(reset: true);
    }
  }

  /// Brand: Budgeting & Quoting chip filter
  /// 0 = All, 1 = Budget Pending, 2 = Quotation Received
  final brandBudgetChipIndex = 0.obs;
  void setBrandBudgetChip(int index) => brandBudgetChipIndex.value = index;

  final AccountTypeService _accountTypeService = Get.find<AccountTypeService>();
  final ApiClient _apiClient = Get.find<ApiClient>();
  bool get isBrand => _accountTypeService.isBrand;
  bool get isAdAgency => _accountTypeService.isAdAgency;
  bool get isInfluencer => _accountTypeService.isInfluencer;

  // ---------------- INFLUENCER / AGENCY LISTS ----------------

  final newOffers = <JobItem>[].obs;
  final activeJobs = <JobItem>[].obs;
  final quotedJobs = <JobItem>[].obs;
  final completedJobs = <JobItem>[].obs;
  final pendingPayments = <JobItem>[].obs;
  final declinedJobs = <JobItem>[].obs;

  final isLoadingNewOffers = false.obs;
  final isLoadingActiveJobs = false.obs;
  final isLoadingQuotedJobs = false.obs;
  final isLoadingCompletedJobs = false.obs;
  final isLoadingPendingPayments = false.obs;
  final isLoadingDeclinedJobs = false.obs;

  final hasMoreNewOffers = true.obs;
  final hasMoreActiveJobs = true.obs;
  final hasMoreQuotedJobs = true.obs;
  final hasMoreCompletedJobs = true.obs;
  final hasMorePendingPayments = true.obs;
  final hasMoreDeclinedJobs = true.obs;

  int _newOffersPage = 1;
  int _activeJobsPage = 1;
  int _quotedJobsPage = 1;
  int _completedJobsPage = 1;
  int _pendingPaymentsPage = 1;
  int _declinedJobsPage = 1;

  final RxMap<String, int> influencerCounts = <String, int>{}.obs;

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

  final Map<int, ScrollController> _tabScrollControllers = {};

  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(searchQuery, (_) {
      if (isAdAgency && !isBrand) {
        _refetchCurrentAgencyTab(reset: true);
      }
      // ✅ influencer/brand: local filtering happens automatically via getters
    }, time: const Duration(milliseconds: 450));

    _initLoad();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();

    for (final controller in _tabScrollControllers.values) {
      controller.dispose();
    }
    _tabScrollControllers.clear();
    super.onClose();
  }

  ScrollController scrollControllerForTab(int index) {
    return _tabScrollControllers.putIfAbsent(index, () {
      final controller = ScrollController();
      controller.addListener(() {
        if (!controller.hasClients) return;

        final max = controller.position.maxScrollExtent;
        final pos = controller.position.pixels;

        if (max <= 0) return;

        if (pos >= max - 120) {
          if (_canLoadMoreForTab(index)) {
            loadMoreForTab(index);
          }
        }
      });
      return controller;
    });
  }

  bool _canLoadMoreForTab(int index) {
    if (isBrand) {
      switch (index) {
        case 0:
          return hasMoreBrandActive.value && !isLoadingBrandActive.value;
        case 1:
          return hasMoreBrandBudgeting.value && !isLoadingBrandBudgeting.value;
        case 2:
          return hasMoreBrandCompleted.value && !isLoadingBrandCompleted.value;
        case 3:
          return hasMoreBrandDrafts.value && !isLoadingBrandDrafts.value;
        case 4:
          return hasMoreBrandCanceled.value && !isLoadingBrandCanceled.value;
        default:
          return false;
      }
    }

    if (isAdAgency) {
      switch (index) {
        case 0:
          return hasMoreNewOffers.value && !isLoadingNewOffers.value;
        case 1:
          return hasMoreQuotedJobs.value && !isLoadingQuotedJobs.value;
        case 2:
          return hasMoreActiveJobs.value && !isLoadingActiveJobs.value;
        case 3:
          return hasMoreCompletedJobs.value && !isLoadingCompletedJobs.value;
        case 4:
          return hasMorePendingPayments.value &&
              !isLoadingPendingPayments.value;
        case 5:
          return hasMoreDeclinedJobs.value && !isLoadingDeclinedJobs.value;
        default:
          return false;
      }
    }

    switch (index) {
      case 0:
        return hasMoreNewOffers.value && !isLoadingNewOffers.value;
      case 1:
        return hasMoreActiveJobs.value && !isLoadingActiveJobs.value;
      case 2:
        return hasMoreCompletedJobs.value && !isLoadingCompletedJobs.value;
      case 3:
        return hasMorePendingPayments.value && !isLoadingPendingPayments.value;
      case 4:
        return hasMoreDeclinedJobs.value && !isLoadingDeclinedJobs.value;
      default:
        return false;
    }
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
      if (isInfluencer) {
        await fetchInfluencerCounts();
      }

      if (isAdAgency) {
        await Future.wait([
          fetchNewOffers(reset: true),
          fetchQuotedJobs(reset: true),
          fetchActiveJobs(reset: true),
          fetchCompletedJobs(reset: true),
          fetchPendingPayments(reset: true),
          fetchDeclinedJobs(reset: true),
        ]);
        return;
      }

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

  String _agencySortParam() {
    // low_to_high => low_budget, high_to_low => high_budget
    return isSortLowToHigh.value ? 'low_budget' : 'high_budget';
  }

  void _refetchCurrentAgencyTab({required bool reset}) {
    switch (currentTabIndex.value) {
      case 0:
        fetchNewOffers(reset: reset);
        break;
      case 1:
        fetchQuotedJobs(reset: reset);
        break;
      case 2:
        fetchActiveJobs(reset: reset);
        break;
      case 3:
        fetchCompletedJobs(reset: reset);
        break;
      case 4:
        fetchPendingPayments(reset: reset);
        break;
      case 5:
        fetchDeclinedJobs(reset: reset);
        break;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;

    // reset scroll position for that tab (prevents immediate loadMore)
    final c = _tabScrollControllers[index];
    if (c != null && c.hasClients) {
      c.jumpTo(0);
    }

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

    if (isAdAgency) {
      switch (index) {
        case 0:
          if (newOffers.isEmpty) fetchNewOffers(reset: true);
          break;
        case 1:
          if (quotedJobs.isEmpty) fetchQuotedJobs(reset: true);
          break;
        case 2:
          if (activeJobs.isEmpty) fetchActiveJobs(reset: true);
          break;
        case 3:
          if (completedJobs.isEmpty) fetchCompletedJobs(reset: true);
          break;
        case 4:
          if (pendingPayments.isEmpty) fetchPendingPayments(reset: true);
          break;
        case 5:
          if (declinedJobs.isEmpty) fetchDeclinedJobs(reset: true);
          break;
      }
      return;
    }

    // influencer (existing 5 tabs)
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

    if (isAdAgency) {
      switch (index) {
        case 0:
          await fetchNewOffers();
          break;
        case 1:
          await fetchQuotedJobs();
          break;
        case 2:
          await fetchActiveJobs();
          break;
        case 3:
          await fetchCompletedJobs();
          break;
        case 4:
          await fetchPendingPayments();
          break;
        case 5:
          await fetchDeclinedJobs();
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

    if (isAdAgency) {
      switch (index) {
        case 0:
          return newOffers.length;
        case 1:
          return quotedJobs.length;
        case 2:
          return activeJobs.length;
        case 3:
          return completedJobs.length;
        case 4:
          return pendingPayments.length;
        case 5:
          return declinedJobs.length;
        default:
          return 0;
      }
    }

    final hasCounts = influencerCounts.isNotEmpty;
    int byKey(String key, int fallback) {
      if (!hasCounts) return fallback;
      return influencerCounts[key] ?? fallback;
    }

    switch (index) {
      case 0:
        return byKey('new_offer', newOffers.length);
      case 1:
        return byKey('active', activeJobs.length);
      case 2:
        return byKey('completed', completedJobs.length);
      case 3:
        return byKey('pending', pendingPayments.length);
      case 4:
        return byKey('declined', declinedJobs.length);
      default:
        return 0;
    }
  }

  Future<void> fetchInfluencerCounts() async {
    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get('/campaign/influencer/jobs/counts');
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return;

    final data = result.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    final counts = <String, int>{
      'new_offer': _countFrom(raw, ['new_offer', 'newOffer']),
      'active': _countFrom(raw, ['active']),
      'completed': _countFrom(raw, ['completed']),
      'pending': _countFrom(raw, [
        'pending',
        'pending_payment',
        'pendingPayment',
      ]),
      'declined': _countFrom(raw, ['declined']),
    };

    influencerCounts.assignAll(counts);
  }

  int _countFrom(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  void openJobDetails(JobItem job) {
    dev.log('JOB TYPE: ${job.campaignType}');
    if (_accountTypeService.isBrand) {
      Get.toNamed(AppRoutes.brandCampaignDetails, id: 1, arguments: job);
      return;
    }

    _openInfluencerOrAgencyJobDetails(job);
  }

  Future<void> _openInfluencerOrAgencyJobDetails(JobItem job) async {
    final jobId = job.id;
    if (jobId == null || jobId.isEmpty) {
      Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: job);
      return;
    }

    if (_accountTypeService.isAdAgency) {
      Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: job);
      return;
    }

    final result = await ApiErrorHandler.call(
      () => _fetchInfluencerJobDetails(jobId),
      showError: false,
    );

    final resolved = result.isSuccess && result.data != null
        ? result.data!
        : job;

    Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: resolved);
  }

  // -------- FILTER + SORT HELPERS --------

  List<JobItem> _filterList(List<JobItem> source) {
    final q = searchQuery.value.trim().toLowerCase();
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

    // ✅ local sort for everyone (agency still also does server sort)
    out.sort(
      (a, b) => isSortLowToHigh.value
          ? a.budget.compareTo(b.budget)
          : b.budget.compareTo(a.budget),
    );

    return out;
  }

  // Influencer/Agency
  List<JobItem> get filteredNewOffers => _filterList(newOffers);
  List<JobItem> get filteredQuotedJobs => _filterList(quotedJobs);
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
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingNewOffers,
      hasMore: hasMoreNewOffers,
      target: newOffers,
      getPage: () => _newOffersPage,
      setPage: (v) => _newOffersPage = v,
      requestPage: (page) {
        if (isAdAgency) {
          return _fetchAgencyCampaigns(
            tab: _agencyTabParam(0),
            page: page,
            pageSize: _pageSize,
            search: searchQuery.value.trim(),
            sort: _agencySortParam(),
          );
        }
        return _fetchInfluencerJobs(
          status: _influencerTabParam(0),
          page: page,
          pageSize: _pageSize,
        );
      },
    );
  }

  Future<void> fetchQuotedJobs({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingQuotedJobs,
      hasMore: hasMoreQuotedJobs,
      target: quotedJobs,
      getPage: () => _quotedJobsPage,
      setPage: (v) => _quotedJobsPage = v,
      requestPage: (page) {
        return _fetchAgencyCampaigns(
          tab: 'quoted',
          page: page,
          pageSize: _pageSize,
          search: searchQuery.value.trim(),
          sort: _agencySortParam(),
        );
      },
    );
  }

  Future<void> fetchActiveJobs({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingActiveJobs,
      hasMore: hasMoreActiveJobs,
      target: activeJobs,
      getPage: () => _activeJobsPage,
      setPage: (v) => _activeJobsPage = v,
      requestPage: (page) {
        if (isAdAgency) {
          return _fetchAgencyCampaigns(
            tab: _agencyTabParam(2),
            page: page,
            pageSize: _pageSize,
            search: searchQuery.value.trim(),
            sort: _agencySortParam(),
          );
        }
        return _fetchInfluencerJobs(
          status: _influencerTabParam(1),
          page: page,
          pageSize: _pageSize,
        );
      },
    );
  }

  Future<void> fetchCompletedJobs({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingCompletedJobs,
      hasMore: hasMoreCompletedJobs,
      target: completedJobs,
      getPage: () => _completedJobsPage,
      setPage: (v) => _completedJobsPage = v,
      requestPage: (page) {
        if (isAdAgency) {
          return _fetchAgencyCampaigns(
            tab: _agencyTabParam(3),
            page: page,
            pageSize: _pageSize,
            search: searchQuery.value.trim(),
            sort: _agencySortParam(),
          );
        }
        return _fetchInfluencerJobs(
          status: _influencerTabParam(2),
          page: page,
          pageSize: _pageSize,
        );
      },
    );
  }

  Future<void> fetchPendingPayments({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingPendingPayments,
      hasMore: hasMorePendingPayments,
      target: pendingPayments,
      getPage: () => _pendingPaymentsPage,
      setPage: (v) => _pendingPaymentsPage = v,
      requestPage: (page) {
        if (isAdAgency) {
          return _fetchAgencyCampaigns(
            tab: _agencyTabParam(4),
            page: page,
            pageSize: _pageSize,
            search: searchQuery.value.trim(),
            sort: _agencySortParam(),
          );
        }
        return _fetchInfluencerJobs(
          status: _influencerTabParam(3),
          page: page,
          pageSize: _pageSize,
        );
      },
    );
  }

  Future<void> fetchDeclinedJobs({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingDeclinedJobs,
      hasMore: hasMoreDeclinedJobs,
      target: declinedJobs,
      getPage: () => _declinedJobsPage,
      setPage: (v) => _declinedJobsPage = v,
      requestPage: (page) {
        if (isAdAgency) {
          return _fetchAgencyCampaigns(
            tab: _agencyTabParam(5),
            page: page,
            pageSize: _pageSize,
            search: searchQuery.value.trim(),
            sort: _agencySortParam(),
          );
        }
        return _fetchInfluencerJobs(
          status: _influencerTabParam(4),
          page: page,
          pageSize: _pageSize,
        );
      },
    );
  }

  // -------- AGENCY ACTIONS --------

  Future<void> acceptAgencyOffer(JobItem job) async {
    final campaignId = job.id;
    if (campaignId == null || campaignId.isEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _apiClient.dio.post('/campaign/agency/$campaignId/accept'),
    );

    if (result.isSuccess) {
      newOffers.removeWhere((e) => e.id == campaignId);
      await fetchActiveJobs(reset: true);
    }
  }

  Future<void> declineAgencyOffer(JobItem job) async {
    final campaignId = job.id;
    if (campaignId == null || campaignId.isEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _apiClient.dio.post(
        '/campaign/agency/decline-offer',
        data: {'campaignId': campaignId},
      ),
    );

    if (result.isSuccess) {
      newOffers.removeWhere((e) => e.id == campaignId);
      await fetchDeclinedJobs(reset: true);
    }
  }

  // -------- BRAND FETCH --------

  Future<void> _fetchPagedJobs({
    required bool reset,
    required RxBool isLoading,
    required RxBool hasMore,
    required RxList<JobItem> target,
    required int Function() getPage,
    required void Function(int) setPage,
    required Future<_CampaignPage> Function(int page) requestPage,
  }) async {
    if (isLoading.value) return;
    if (!hasMore.value && !reset) return;

    isLoading.value = true;

    try {
      if (reset) {
        setPage(1);
        hasMore.value = true;
        target.clear();
      }

      final currentPage = getPage();

      final result = await ApiErrorHandler.call(
        () => requestPage(currentPage),
        showError: false,
      );

      if (!result.isSuccess || result.data == null) return;

      final page = result.data!;
      final items = page.items;

      if (items.isEmpty) {
        hasMore.value = false;
        return;
      }

      target.addAll(items);

      // ✅ Key fix: decide end by BOTH rules:
      // 1) API totalPages (if provided)
      // 2) items length < pageSize (most reliable)
      final nextPage = currentPage + 1;
      setPage(nextPage);

      final endBySize = items.length < _pageSize;
      final endByTotalPages = nextPage > page.totalPages;

      hasMore.value = !(endBySize || endByTotalPages);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBrandActive({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingBrandActive,
      hasMore: hasMoreBrandActive,
      target: brandActive,
      getPage: () => _brandActivePage,
      setPage: (v) => _brandActivePage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'active',
        page: page,
        pageSize: _pageSize,
      ),
    );
  }

  Future<void> fetchBrandBudgeting({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingBrandBudgeting,
      hasMore: hasMoreBrandBudgeting,
      target: brandBudgeting,
      getPage: () => _brandBudgetingPage,
      setPage: (v) => _brandBudgetingPage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'quoting',
        page: page,
        pageSize: _pageSize,
      ),
    );
  }

  Future<void> fetchBrandCompleted({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingBrandCompleted,
      hasMore: hasMoreBrandCompleted,
      target: brandCompleted,
      getPage: () => _brandCompletedPage,
      setPage: (v) => _brandCompletedPage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'completed',
        page: page,
        pageSize: _pageSize,
      ),
    );
  }

  Future<void> fetchBrandDrafts({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingBrandDrafts,
      hasMore: hasMoreBrandDrafts,
      target: brandDrafts,
      getPage: () => _brandDraftsPage,
      setPage: (v) => _brandDraftsPage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'draft',
        page: page,
        pageSize: _pageSize,
      ),
    );
  }

  Future<void> fetchBrandCanceled({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      isLoading: isLoadingBrandCanceled,
      hasMore: hasMoreBrandCanceled,
      target: brandCanceled,
      getPage: () => _brandCanceledPage,
      setPage: (v) => _brandCanceledPage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'cancelled',
        page: page,
        pageSize: _pageSize,
      ),
    );
  }

  // -------- BRAND API --------

  Future<_CampaignPage> _fetchBrandCampaigns({
    required String status,
    required int page,
    required int pageSize,
  }) async {
    final res = await _apiClient.dio.get(
      '/campaign/my-campaigns',
      queryParameters: {'status': status, 'page': page, 'limit': pageSize},
    );

    final data = res.data as Map<String, dynamic>;
    final list = (data['data'] as List?) ?? const [];
    final items = list
        .whereType<Map>()
        .map(
          (e) => _mapCampaignToJob(
            Map<String, dynamic>.from(e),
            statusHint: status,
          ),
        )
        .toList();

    final meta = data['meta'] as Map<String, dynamic>?;
    final totalPages = (meta?['total'] as num?)?.toInt() ?? 1;

    return _CampaignPage(items: items, totalPages: totalPages);
  }

  // -------- AGENCY API --------

  String _agencyTabParam(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'new_offer';
      case 1:
        return 'quoted';
      case 2:
        return 'active';
      case 3:
        return 'completed';
      case 4:
        return 'pending';
      case 5:
        return 'declined';
      default:
        return 'active';
    }
  }

  String _influencerTabParam(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'new_offer';
      case 1:
        return 'active';
      case 2:
        return 'completed';
      case 3:
        return 'pending';
      case 4:
        return 'declined';
      default:
        return 'active';
    }
  }

  Future<JobItem> _fetchInfluencerJobDetails(String jobId) async {
    final res = await _apiClient.dio.get('/campaign/influencer/job/$jobId');
    final data = res.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    final base = _mapInfluencerJobToJobItem(raw);
    final milestones = await _fetchInfluencerJobMilestones(jobId);
    return _copyJobWithMilestones(base, milestones);
  }

  Future<List<Milestone>> _fetchInfluencerJobMilestones(String jobId) async {
    final res = await _apiClient.dio.get(
      '/campaign/influencer/job/$jobId/milestones',
    );

    final data = res.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    final list = (raw['milestones'] as List?) ?? const [];

    return list
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList()
        .asMap()
        .entries
        .map((entry) => _mapInfluencerMilestone(entry.value, entry.key))
        .toList(growable: false);
  }

  Future<_CampaignPage> _fetchInfluencerJobs({
    required String status,
    required int page,
    required int pageSize,
  }) async {
    final res = await _apiClient.dio.get(
      '/campaign/influencer/jobs',
      queryParameters: {
        'page': page,
        'limit': pageSize,
        if (status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

    final data = res.data as Map<String, dynamic>;
    final list = (data['data'] as List?) ?? const [];
    final items = list
        .whereType<Map>()
        .map((e) => _mapInfluencerJobToJobItem(e.cast<String, dynamic>()))
        .toList();

    final meta = (data['pagination'] ?? data['meta']) as Map<String, dynamic>?;
    final totalPages = (meta?['total'] as num?)?.toInt() ?? 1;

    return _CampaignPage(items: items, totalPages: totalPages);
  }

  Future<_CampaignPage> _fetchAgencyCampaigns({
    required String tab,
    required int page,
    required int pageSize,

    // ✅ NEW
    String? search,
    String? sort,
  }) async {
    final res = await _apiClient.dio.get(
      '/campaign/agency/list',
      queryParameters: {
        'page': page,
        'limit': pageSize,
        if (tab.trim().isNotEmpty) 'tab': tab.trim(),

        // ✅ NEW
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
      },
    );

    final data = res.data as Map<String, dynamic>;
    final list = (data['data'] as List?) ?? const [];
    final items = list
        .whereType<Map>()
        .map((e) => _mapAgencyCampaignToJob(e.cast<String, dynamic>()))
        .toList();

    final meta = data['meta'] as Map<String, dynamic>?;
    final totalPages = (meta?['total'] as num?)?.toInt() ?? 1;

    return _CampaignPage(items: items, totalPages: totalPages);
  }

  JobItem _mapAgencyCampaignToJob(Map<String, dynamic> json) {
    final campaignId = json['id']?.toString();
    final campaignName = (json['campaignName'] as String?)?.trim();
    final status = json['status']?.toString();

    final client = json['client'] as Map<String, dynamic>?;
    final clientName = client?['brandName']?.toString().trim();

    final financials = json['financials'] as Map<String, dynamic>?;
    final totalBudget = _numToDouble(financials?['totalBudget']);
    final availableBudget = _numToDouble(
      financials?['availableBudgetForExecution'],
    );
    final serviceFee = _numToDouble(
      financials?['adminOfferedServiceFeePercent'] ??
          financials?['proposedServiceFeePercent'],
    );

    final schedule = json['schedule'] as Map<String, dynamic>?;
    final startingDate = schedule?['startingDate']?.toString();
    final deadline = schedule?['deadline']?.toString();

    final campaignTypeRaw = json['campaignType']?.toString();

    final budget = totalBudget > 0 ? totalBudget : availableBudget;

    final timeLeftToRequoteMinutes = _intFrom(json['timeLeftToRequoteMinutes']);

    return JobItem(
      id: campaignId,
      title: campaignName?.isNotEmpty == true
          ? campaignName!
          : 'Untitled Campaign',
      clientName: clientName?.isNotEmpty == true ? clientName! : '—',
      campaignType: _parseCampaignType(campaignTypeRaw),
      dateLabel: _formatDateLabel(startingDate ?? deadline),
      budget: budget,
      sharePercent: serviceFee.round(),
      dueLabel: _buildDueLabel(deadline),
      progressPercent: _progressFromStatus(status),
      timeLeftToRequoteMinutes: timeLeftToRequoteMinutes,
    );
  }

  int? _progressFromStatus(String? status) {
    final v = (status ?? '').toLowerCase();
    if (v == 'completed') return 100;
    if (v.contains('active')) return 50;
    return 0;
  }

  int? _progressFromInfluencerStatus(String? status) {
    final v = (status ?? '').toLowerCase();
    if (v.contains('complete')) return 100;
    if (v.contains('active')) return 50;
    return 0;
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

  String _amountLabelFrom(dynamic value) {
    final v = _numToDouble(value);
    if (v > 0) return formatCurrencyByLocale(v);
    if (value is String && value.trim().isNotEmpty) return value;
    return '—';
  }

  Milestone _mapInfluencerMilestone(Map<String, dynamic> json, int index) {
    final title =
        json['title']?.toString().trim() ??
        json['contentTitle']?.toString().trim() ??
        'Milestone';
    final amount = json['amount'];
    final expectedViews = _intFrom(json['expectedViews']);
    final expectedReach = _intFrom(json['expectedReach']);
    final expectedLikes = _intFrom(json['expectedLikes']);
    final expectedComments = _intFrom(json['expectedComments']);

    return Milestone(
      id: json['id']?.toString(),
      stepLabel: '${index + 1}',
      title: title,
      amountLabel: _amountLabelFrom(amount),
      dayIndex: _intFrom(json['deliveryDays']),
      deliverable: json['contentQuantity']?.toString(),
      platform: json['platform']?.toString(),
      targets: PromotionTarget(
        reach: expectedReach,
        views: expectedViews,
        likes: expectedLikes,
        comments: expectedComments,
      ),
      status: _parseMilestoneStatus(json['status']?.toString()),
    );
  }

  JobItem _copyJobWithMilestones(JobItem base, List<Milestone> milestones) {
    return JobItem(
      id: base.id,
      title: base.title,
      subTitle: base.subTitle,
      clientName: base.clientName,
      campaignType: base.campaignType,
      dateLabel: base.dateLabel,
      budget: base.budget,
      sharePercent: base.sharePercent,
      progressPercent: base.progressPercent,
      dueInDays: base.dueInDays,
      dueLabel: base.dueLabel,
      rating: base.rating,
      profitLabel: base.profitLabel,
      vatLabel: base.vatLabel,
      totalCostLabel: base.totalCostLabel,
      totalEarningsLabel: base.totalEarningsLabel,
      baseBudget: base.baseBudget,
      vatPercent: base.vatPercent,
      vatAmount: base.vatAmount,
      netPayableBudget: base.netPayableBudget,
      contentAssets: base.contentAssets,
      brandAssets: base.brandAssets,
      needToSendSample: base.needToSendSample,
      sampleGuidelinesConfirmed: base.sampleGuidelinesConfirmed,
      dosText: base.dosText,
      dontsText: base.dontsText,
      milestones: milestones,
    );
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  JobItem _mapInfluencerJobToJobItem(Map<String, dynamic> json) {
    final campaignId =
        json['id']?.toString() ?? json['assignmentId']?.toString();
    final campaignName = (json['campaignName'] as String?)?.trim();
    final campaignTypeRaw = json['campaignType']?.toString();
    final brandName = (json['brandName'] as String?)?.trim();
    final client = json['client'] as Map<String, dynamic>?;
    final clientName = client?['brandName']?.toString().trim();

    final offeredAmount = _numToDouble(json['offeredAmount']);
    final totalAmount = _numToDouble(json['totalAmount']);
    final budget = offeredAmount > 0 ? offeredAmount : totalAmount;

    final createdAt = json['createdAt']?.toString();
    final deadline = json['deadline']?.toString();
    final status = json['status']?.toString();

    return JobItem(
      id: campaignId,
      title: campaignName?.isNotEmpty == true
          ? campaignName!
          : 'Untitled Campaign',
      subTitle: _campaignTypeLabel(campaignTypeRaw),
      clientName: clientName?.isNotEmpty == true
          ? clientName!
          : (brandName?.isNotEmpty == true ? brandName! : '—'),
      campaignType: _parseCampaignType(campaignTypeRaw),
      dateLabel: _formatDateLabel(deadline ?? createdAt),
      budget: budget,
      sharePercent: 0,
      dueLabel: _buildDueLabel(deadline),
      progressPercent: _progressFromInfluencerStatus(status),
    );
  }

  // -------- INFLUENCER ACTIONS --------

  Future<void> acceptInfluencerOffer(JobItem job) async {
    final jobId = job.id;
    if (jobId == null || jobId.isEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _apiClient.dio.post('/campaign/influencer/job/$jobId/accept'),
    );

    if (result.isSuccess) {
      newOffers.removeWhere((e) => e.id == jobId);
      await fetchPendingPayments(reset: true);
      await fetchInfluencerCounts();
    }
  }

  Future<void> declineInfluencerOffer(JobItem job) async {
    final jobId = job.id;
    if (jobId == null || jobId.isEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _apiClient.dio.post('/campaign/influencer/job/$jobId/decline'),
    );

    if (result.isSuccess) {
      newOffers.removeWhere((e) => e.id == jobId);
      await fetchDeclinedJobs(reset: true);
      await fetchInfluencerCounts();
    }
  }

  Future<void> startInfluencerJob(JobItem job) async {
    final jobId = job.id;
    if (jobId == null || jobId.isEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _apiClient.dio.post('/campaign/influencer/job/$jobId/start'),
    );

    if (result.isSuccess) {
      await fetchActiveJobs(reset: true);
      await fetchInfluencerCounts();
    }
  }

  Future<void> completeInfluencerJob(JobItem job) async {
    final jobId = job.id;
    if (jobId == null || jobId.isEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _apiClient.dio.post(
        '/campaign/influencer/job/$jobId/complete',
        data: {'completionNotes': 'Job completed'},
      ),
    );

    if (result.isSuccess) {
      await fetchCompletedJobs(reset: true);
      await fetchInfluencerCounts();
    }
  }

  JobItem _mapCampaignToJob(
    Map<String, dynamic> json, {
    required String statusHint,
  }) {
    final campaignId = json['id']?.toString();
    final campaignName = (json['campaignName'] as String?)?.trim();
    final campaignTypeRaw = (json['campaignType'] as String?)?.trim();
    final budget = _numToDouble(json['totalBudget']);
    final createdAt = json['createdAt'] as String?;
    final deadline = json['deadline'] as String?;
    final progress = (json['progress'] as num?)?.toInt() ?? 0;

    final assignedTo = (json['assignedTo'] as List?) ?? const [];
    final clientName = _formatAssignedTo(assignedTo);

    final dueLabel = _buildDueLabel(deadline);
    final dateLabel = _formatDateLabel(deadline ?? createdAt);

    final negotiationRevisedTimes =
        (json['negotiationRevisedTimes'] as num?)?.toInt() ?? 0;
    final totalQuotations =
        (json['totalQuotationsReceived'] as num?)?.toInt() ?? 0;
    final budgetPending = _numToDouble(json['budgetPendingAmount']);

    final budgetStatus = _budgetStatusLabel(
      statusHint: statusHint,
      totalQuotationsReceived: totalQuotations,
    );

    final isQuotation = budgetStatus == 'Quotation Received';

    return JobItem(
      id: campaignId,
      title: campaignName?.isNotEmpty == true
          ? campaignName!
          : 'Untitled Campaign',
      subTitle: _campaignTypeLabel(campaignTypeRaw),
      clientName: clientName,
      campaignType: _parseCampaignType(campaignTypeRaw),
      dateLabel: dateLabel,
      budget: isQuotation
          ? budget
          : (budgetPending > 0 ? budgetPending : budget),
      sharePercent: 0,
      progressPercent: isQuotation ? totalQuotations : progress,
      dueLabel: dueLabel,
      profitLabel: budgetStatus,
      totalEarningsLabel: 'Revised: $negotiationRevisedTimes Times',
    );
  }

  CampaignType _parseCampaignType(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v == 'paid_ad' || v == 'paidad') return CampaignType.paidAd;
    return CampaignType.influencerPromotion;
  }

  String _campaignTypeLabel(String? raw) {
    final v = (raw ?? '').toLowerCase();
    return v == 'paid_ad' || v == 'paidad' ? 'Paid Ad' : 'Influencer Promotion';
  }

  String _budgetStatusLabel({
    required String statusHint,
    required int totalQuotationsReceived,
  }) {
    final hint = statusHint.toLowerCase();
    if (hint == 'quotation_received') return 'Quotation Received';
    if (hint == 'budget_pending' || hint == 'quoting') {
      return totalQuotationsReceived > 0
          ? 'Quotation Received'
          : 'Budget Pending';
    }
    return totalQuotationsReceived > 0
        ? 'Quotation Received'
        : 'Budget Pending';
  }

  String _formatAssignedTo(List<dynamic> assigned) {
    if (assigned.isEmpty) return '—';
    final names = assigned
        .map((e) => (e as Map?)?['name']?.toString() ?? '')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (names.isEmpty) return '—';
    if (names.length == 1) return names.first;
    return '${names.first}, +${names.length - 1}';
  }

  String _formatDateLabel(String? iso) {
    final date = _tryParseDate(iso);
    if (date == null) return '—';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String? _buildDueLabel(String? iso) {
    final date = _tryParseDate(iso);
    if (date == null) return null;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(date.year, date.month, date.day);
    final diff = end.difference(start).inDays;
    if (diff == 1) return 'Due: Tomorrow';
    if (diff > 1) return 'Due: $diff Days';
    if (diff == 0) return 'Due: Today';
    return null;
  }

  DateTime? _tryParseDate(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  double _numToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class _CampaignPage {
  final List<JobItem> items;
  final int totalPages;

  const _CampaignPage({required this.items, required this.totalPages});
}
