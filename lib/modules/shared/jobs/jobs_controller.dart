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
  void toggleSort() => isSortLowToHigh.value = !isSortLowToHigh.value;

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
  final completedJobs = <JobItem>[].obs;
  final pendingPayments = <JobItem>[].obs;
  final declinedJobs = <JobItem>[].obs;

  final RxMap<String, int> influencerCounts = <String, int>{}.obs;

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

  final Map<int, ScrollController> _tabScrollControllers = {};

  @override
  void onInit() {
    super.onInit();
    _initLoad();
  }

  @override
  void onClose() {
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

    if (isAdAgency) {
      final result = await ApiErrorHandler.call(
        () => _fetchAgencyCampaigns(
          tab: _agencyTabParam(0),
          page: _newOffersPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreNewOffers.value = false;
        } else {
          newOffers.addAll(page.items);
          _newOffersPage++;
          if (_newOffersPage > page.totalPages) {
            hasMoreNewOffers.value = false;
          }
        }
      }
    } else {
      final result = await ApiErrorHandler.call(
        () => _fetchInfluencerJobs(
          status: _influencerTabParam(0),
          page: _newOffersPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreNewOffers.value = false;
        } else {
          newOffers.addAll(page.items);
          _newOffersPage++;
          if (_newOffersPage > page.totalPages) {
            hasMoreNewOffers.value = false;
          }
        }
      }
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

    if (isAdAgency) {
      final result = await ApiErrorHandler.call(
        () => _fetchAgencyCampaigns(
          tab: _agencyTabParam(1),
          page: _activeJobsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreActiveJobs.value = false;
        } else {
          activeJobs.addAll(page.items);
          _activeJobsPage++;
          if (_activeJobsPage > page.totalPages) {
            hasMoreActiveJobs.value = false;
          }
        }
      }
    } else {
      final result = await ApiErrorHandler.call(
        () => _fetchInfluencerJobs(
          status: _influencerTabParam(1),
          page: _activeJobsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreActiveJobs.value = false;
        } else {
          activeJobs.addAll(page.items);
          _activeJobsPage++;
          if (_activeJobsPage > page.totalPages) {
            hasMoreActiveJobs.value = false;
          }
        }
      }
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

    if (isAdAgency) {
      final result = await ApiErrorHandler.call(
        () => _fetchAgencyCampaigns(
          tab: _agencyTabParam(2),
          page: _completedJobsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreCompletedJobs.value = false;
        } else {
          completedJobs.addAll(page.items);
          _completedJobsPage++;
          if (_completedJobsPage > page.totalPages) {
            hasMoreCompletedJobs.value = false;
          }
        }
      }
    } else {
      final result = await ApiErrorHandler.call(
        () => _fetchInfluencerJobs(
          status: _influencerTabParam(2),
          page: _completedJobsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreCompletedJobs.value = false;
        } else {
          completedJobs.addAll(page.items);
          _completedJobsPage++;
          if (_completedJobsPage > page.totalPages) {
            hasMoreCompletedJobs.value = false;
          }
        }
      }
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

    if (isAdAgency) {
      final result = await ApiErrorHandler.call(
        () => _fetchAgencyCampaigns(
          tab: _agencyTabParam(3),
          page: _pendingPaymentsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMorePendingPayments.value = false;
        } else {
          pendingPayments.addAll(page.items);
          _pendingPaymentsPage++;
          if (_pendingPaymentsPage > page.totalPages) {
            hasMorePendingPayments.value = false;
          }
        }
      }
    } else {
      final result = await ApiErrorHandler.call(
        () => _fetchInfluencerJobs(
          status: _influencerTabParam(3),
          page: _pendingPaymentsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMorePendingPayments.value = false;
        } else {
          pendingPayments.addAll(page.items);
          _pendingPaymentsPage++;
          if (_pendingPaymentsPage > page.totalPages) {
            hasMorePendingPayments.value = false;
          }
        }
      }
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

    if (isAdAgency) {
      final result = await ApiErrorHandler.call(
        () => _fetchAgencyCampaigns(
          tab: _agencyTabParam(4),
          page: _declinedJobsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreDeclinedJobs.value = false;
        } else {
          declinedJobs.addAll(page.items);
          _declinedJobsPage++;
          if (_declinedJobsPage > page.totalPages) {
            hasMoreDeclinedJobs.value = false;
          }
        }
      }
    } else {
      final result = await ApiErrorHandler.call(
        () => _fetchInfluencerJobs(
          status: _influencerTabParam(4),
          page: _declinedJobsPage,
          pageSize: _pageSize,
        ),
      );

      if (result.isSuccess) {
        final page = result.data!;
        if (page.items.isEmpty) {
          hasMoreDeclinedJobs.value = false;
        } else {
          declinedJobs.addAll(page.items);
          _declinedJobsPage++;
          if (_declinedJobsPage > page.totalPages) {
            hasMoreDeclinedJobs.value = false;
          }
        }
      }
    }
    isLoadingDeclinedJobs.value = false;
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

  Future<void> fetchBrandActive({bool reset = false}) async {
    if (isLoadingBrandActive.value) return;
    if (!hasMoreBrandActive.value && !reset) return;

    isLoadingBrandActive.value = true;
    if (reset) {
      _brandActivePage = 1;
      hasMoreBrandActive.value = true;
      brandActive.clear();
    }

    final result = await ApiErrorHandler.call(
      () => _fetchBrandCampaigns(
        status: 'active',
        page: _brandActivePage,
        pageSize: _pageSize,
      ),
    );

    if (result.isSuccess) {
      final page = result.data!;
      if (page.items.isEmpty) {
        hasMoreBrandActive.value = false;
      } else {
        brandActive.addAll(page.items);
        _brandActivePage++;
        if (_brandActivePage > page.totalPages) {
          hasMoreBrandActive.value = false;
        }
      }
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

    final result = await ApiErrorHandler.call(
      () => _fetchBrandCampaigns(
        status: 'quoting',
        page: _brandBudgetingPage,
        pageSize: _pageSize,
      ),
    );

    if (result.isSuccess) {
      final page = result.data!;
      if (page.items.isEmpty) {
        hasMoreBrandBudgeting.value = false;
      } else {
        brandBudgeting.addAll(page.items);
        _brandBudgetingPage++;
        if (_brandBudgetingPage > page.totalPages) {
          hasMoreBrandBudgeting.value = false;
        }
      }
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

    final result = await ApiErrorHandler.call(
      () => _fetchBrandCampaigns(
        status: 'completed',
        page: _brandCompletedPage,
        pageSize: _pageSize,
      ),
    );

    if (result.isSuccess) {
      final page = result.data!;
      if (page.items.isEmpty) {
        hasMoreBrandCompleted.value = false;
      } else {
        brandCompleted.addAll(page.items);
        _brandCompletedPage++;
        if (_brandCompletedPage > page.totalPages) {
          hasMoreBrandCompleted.value = false;
        }
      }
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

    final result = await ApiErrorHandler.call(
      () => _fetchBrandCampaigns(
        status: 'draft',
        page: _brandDraftsPage,
        pageSize: _pageSize,
      ),
    );

    if (result.isSuccess) {
      final page = result.data!;
      if (page.items.isEmpty) {
        hasMoreBrandDrafts.value = false;
      } else {
        brandDrafts.addAll(page.items);
        _brandDraftsPage++;
        if (_brandDraftsPage > page.totalPages) {
          hasMoreBrandDrafts.value = false;
        }
      }
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

    final result = await ApiErrorHandler.call(
      () => _fetchBrandCampaigns(
        status: 'cancelled',
        page: _brandCanceledPage,
        pageSize: _pageSize,
      ),
    );

    if (result.isSuccess) {
      final page = result.data!;
      if (page.items.isEmpty) {
        hasMoreBrandCanceled.value = false;
      } else {
        brandCanceled.addAll(page.items);
        _brandCanceledPage++;
        if (_brandCanceledPage > page.totalPages) {
          hasMoreBrandCanceled.value = false;
        }
      }
    }
    isLoadingBrandCanceled.value = false;
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
    final totalPages = (meta?['totalPages'] as num?)?.toInt() ?? 1;

    return _CampaignPage(items: items, totalPages: totalPages);
  }

  // -------- AGENCY API --------

  String _agencyTabParam(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'pending';
      case 1:
        return 'active';
      case 2:
        return 'completed';
      case 3:
        return 'pending_payment';
      case 4:
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
    final totalPages = (meta?['totalPages'] as num?)?.toInt() ?? 1;

    return _CampaignPage(items: items, totalPages: totalPages);
  }

  Future<_CampaignPage> _fetchAgencyCampaigns({
    required String tab,
    required int page,
    required int pageSize,
  }) async {
    final res = await _apiClient.dio.get(
      '/campaign/agency/list',
      queryParameters: {
        'page': page,
        'limit': pageSize,
        if (tab.trim().isNotEmpty) 'tab': tab.trim(),
      },
    );

    final data = res.data as Map<String, dynamic>;
    final list = (data['data'] as List?) ?? const [];
    final items = list
        .whereType<Map>()
        .map((e) => _mapAgencyCampaignToJob(e.cast<String, dynamic>()))
        .toList();

    final meta = data['meta'] as Map<String, dynamic>?;
    final totalPages = (meta?['totalPages'] as num?)?.toInt() ?? 1;

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

class _CampaignPage {
  final List<JobItem> items;
  final int totalPages;

  const _CampaignPage({required this.items, required this.totalPages});
}
