import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/campaign_service.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

import '../../../core/models/job_item.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/widgets/reason_bottom_sheet.dart';
import '../../../routes/app_routes.dart';
import 'widgets/delete_campaign_dialog.dart';

class JobsController extends GetxController {
  final currentTabIndex = 0.obs;
  final CampaignService _campaignService = Get.find<CampaignService>();

  /// used by search bar
  final searchQuery = ''.obs;

  /// sort toggle (used by the "Low to High" chip)
  final isSortLowToHigh = true.obs;

  void toggleSort() {
    isSortLowToHigh.value = !isSortLowToHigh.value;

    if (isAdAgency && !isBrand) {
      _refetchCurrentAgencyTab(reset: true);
      return;
    }

    if (isInfluencer && !isBrand) {
      _refetchCurrentInfluencerTab(reset: true);
      return;
    }

    if (isBrand) {
      _refetchCurrentBrandTab(reset: true);
      return;
    }
  }

  /// Brand: Budgeting & Quoting chip filter
  /// 0 = All, 1 = Budget Pending, 2 = Quotation Received
  final brandBudgetChipIndex = 0.obs;

  Future<void> setBrandBudgetChip(int index) async {
    if (brandBudgetChipIndex.value == index) return;

    brandBudgetChipIndex.value = index;
    _applySelectedBrandBudgetList();

    if (!isBrand || currentTabIndex.value != 1) return;

    if (!_selectedBrandBudgetLoaded) {
      await fetchBrandBudgeting(reset: true);
    }
  }

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
  final brandBudgetAll = <JobItem>[].obs;
  final brandBudgetPending = <JobItem>[].obs;
  final brandBudgetQuotation = <JobItem>[].obs;

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

  final RxMap<int, int> brandTabCounts = <int, int>{}.obs;
  final RxMap<int, int> agencyTabCounts = <int, int>{}.obs;
  final RxMap<int, int> influencerTabCounts = <int, int>{}.obs;
  final brandBudgetPendingTotal = 0.obs;
  final brandQuotationReceivedTotal = 0.obs;
  final RxBool isInitialLoading = false.obs;
  final RxString loadingJobId = ''.obs;

  final Map<int, int> _brandBudgetPageByChip = {0: 1, 1: 1, 2: 1};

  final Map<int, bool> _brandBudgetHasMoreByChip = {0: true, 1: true, 2: true};

  final Map<int, bool> _brandBudgetLoadedByChip = {
    0: false,
    1: false,
    2: false,
  };

  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      final rawIndex = args['initialTabIndex'];
      final parsedIndex = rawIndex is int
          ? rawIndex
          : int.tryParse(rawIndex?.toString() ?? '');

      if (parsedIndex != null) {
        currentTabIndex.value = parsedIndex;
      }
    }

    _searchWorker = debounce<String>(searchQuery, (_) {
      if (isAdAgency && !isBrand) {
        _refetchCurrentAgencyTab(reset: true);
        return;
      }

      if (isInfluencer && !isBrand) {
        _refetchCurrentInfluencerTab(reset: true);
        return;
      }

      if (isBrand) {
        _refetchCurrentBrandTab(reset: true);
        return;
      }
    }, time: const Duration(milliseconds: 450));

    _listenJobNotifications();
    _initLoad();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    _searchWorker?.dispose();

    for (final controller in _tabScrollControllers.values) {
      controller.dispose();
    }
    _tabScrollControllers.clear();
    super.onClose();
  }

  void setTabFromExternal(int index) {
    currentTabIndex.value = index;

    final c = _tabScrollControllers[index];
    if (c != null && c.hasClients) {
      c.jumpTo(0);
    }

    refreshCurrentTab();
  }

  void _listenJobNotifications() {
    _notificationSubscription?.cancel();

    _notificationSubscription = FirebaseMessagingService.notificationStream.listen((
      data,
    ) async {
      if (isBrand) return;

      final rawType = data['type']?.toString().trim() ?? '';
      if (rawType.isEmpty) return;
      if (!rawType.toUpperCase().contains('INVITATION')) return;

      dev.log(
        'JobsController matched invitation notification. Reloading new offers.',
        name: 'JobsController',
        error: {'type': rawType, 'currentTabIndex': currentTabIndex.value},
      );

      await fetchNewOffers(reset: true);
    });
  }

  DateTime? _tryParseJobDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  DateTime? _resolveFinalJobDate({
    String? deadline,
    String? startingDate,
    int? duration,
  }) {
    final parsedDeadline = _tryParseJobDate(deadline);
    if (parsedDeadline != null) return parsedDeadline;

    final parsedStart = _tryParseJobDate(startingDate);
    if (parsedStart != null && duration != null && duration > 0) {
      return parsedStart.add(Duration(days: duration));
    }

    return null;
  }

  String _resolveJobDateLabel({
    required bool useStartingDate,
    String? startingDate,
    String? deadline,
    int? duration,
    String? fallbackDate,
  }) {
    final DateTime? resolved = useStartingDate
        ? _tryParseJobDate(startingDate)
        : _resolveFinalJobDate(
            deadline: deadline,
            startingDate: startingDate,
            duration: duration,
          );

    if (resolved != null) {
      return _formatDateLabel(resolved.toIso8601String());
    }

    return _formatDateLabel(startingDate ?? deadline ?? fallbackDate);
  }

  String _resolveJobDueLabel({
    String? deadline,
    String? startingDate,
    int? duration,
  }) {
    final resolved = _resolveFinalJobDate(
      deadline: deadline,
      startingDate: startingDate,
      duration: duration,
    );

    if (resolved == null) return '';
    return _buildDueLabel(resolved.toIso8601String()) ?? '';
  }

  bool _shouldUseStartDateForAgencyTab(String tab) {
    final v = tab.trim().toLowerCase();
    return v == 'new_offer' || v == 'quoted';
  }

  bool _shouldUseStartDateForInfluencerStatus(String status) {
    final v = status.trim().toLowerCase();
    return v == 'new_offer' || v == 'new';
  }

  bool _shouldUseStartDateForBrandStatus(String statusHint) {
    final v = statusHint.trim().toLowerCase();
    return v == 'quoting' || v == 'budget_pending' || v == 'quotation_received';
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

  Future<void> refreshCurrentTab() async {
    if (isInfluencer) {
      await fetchInfluencerCounts();
    }

    if (isBrand) {
      await _refreshBrandTab();
      return;
    }

    if (isAdAgency) {
      await _refreshAgencyTab();
      return;
    }

    await _refreshInfluencerTab();
  }

  Future<void> _refreshAgencyTab() async {
    switch (currentTabIndex.value) {
      case 0:
        await fetchNewOffers(reset: true);
        break;
      case 1:
        await fetchQuotedJobs(reset: true);
        break;
      case 2:
        await fetchActiveJobs(reset: true);
        break;
      case 3:
        await fetchCompletedJobs(reset: true);
        break;
      case 4:
        await fetchPendingPayments(reset: true);
        break;
      case 5:
        await fetchDeclinedJobs(reset: true);
        break;
    }
  }

  Future<void> _refreshInfluencerTab() async {
    switch (currentTabIndex.value) {
      case 0:
        await fetchNewOffers(reset: true);
        break;
      case 1:
        await fetchActiveJobs(reset: true);
        break;
      case 2:
        await fetchCompletedJobs(reset: true);
        break;
      case 3:
        await fetchPendingPayments(reset: true);
        break;
      case 4:
        await fetchDeclinedJobs(reset: true);
        break;
    }
  }

  Future<void> _refreshBrandTab() async {
    switch (currentTabIndex.value) {
      case 0:
        await fetchBrandActive(reset: true);
        break;
      case 1:
        await fetchBrandBudgeting(reset: true);
        break;
      case 2:
        await fetchBrandCompleted(reset: true);
        break;
      case 3:
        await fetchBrandDrafts(reset: true);
        break;
      case 4:
        await fetchBrandCanceled(reset: true);
        break;
    }
  }

  bool _canLoadMoreForTab(int index) {
    if (isBrand) {
      switch (index) {
        case 0:
          return hasMoreBrandActive.value && !isLoadingBrandActive.value;
        case 1:
          return _selectedBrandBudgetHasMore && !isLoadingBrandBudgeting.value;
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
    isInitialLoading.value = true;
    try {
      if (isBrand) {
        if (isBrand) {
          await Future.wait([
            fetchBrandActive(reset: true),
            fetchBrandCompleted(reset: true),
            fetchBrandDrafts(reset: true),
            fetchBrandCanceled(reset: true),
          ]);

          await fetchBrandBudgeting(reset: true);
        }
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
    } finally {
      isInitialLoading.value = false;
    }
  }

  RxList<JobItem> _brandBudgetListByChip(int chipIndex) {
    switch (chipIndex) {
      case 1:
        return brandBudgetPending;
      case 2:
        return brandBudgetQuotation;
      case 0:
      default:
        return brandBudgetAll;
    }
  }

  String _brandBudgetStatusParamByChip(int chipIndex) {
    switch (chipIndex) {
      case 1:
        return 'budget_pending';
      case 2:
        return 'quotation_received';
      case 0:
      default:
        return 'quoting';
    }
  }

  void _resetBrandBudgetChipState(int chipIndex) {
    _brandBudgetPageByChip[chipIndex] = 1;
    _brandBudgetHasMoreByChip[chipIndex] = true;
    _brandBudgetLoadedByChip[chipIndex] = false;
    _brandBudgetListByChip(chipIndex).clear();
  }

  void _resetAllBrandBudgetChipStates() {
    _resetBrandBudgetChipState(0);
    _resetBrandBudgetChipState(1);
    _resetBrandBudgetChipState(2);
  }

  void _applySelectedBrandBudgetList() {
    final selectedList = _brandBudgetListByChip(brandBudgetChipIndex.value);
    brandBudgeting.assignAll(selectedList);
  }

  bool get _selectedBrandBudgetHasMore =>
      _brandBudgetHasMoreByChip[brandBudgetChipIndex.value] ?? true;

  set _selectedBrandBudgetHasMore(bool value) {
    _brandBudgetHasMoreByChip[brandBudgetChipIndex.value] = value;
  }

  int get _selectedBrandBudgetPage =>
      _brandBudgetPageByChip[brandBudgetChipIndex.value] ?? 1;

  set _selectedBrandBudgetPage(int value) {
    _brandBudgetPageByChip[brandBudgetChipIndex.value] = value;
  }

  bool get _selectedBrandBudgetLoaded =>
      _brandBudgetLoadedByChip[brandBudgetChipIndex.value] ?? false;

  set _selectedBrandBudgetLoaded(bool value) {
    _brandBudgetLoadedByChip[brandBudgetChipIndex.value] = value;
  }

  String _brandBudgetStatusParam() {
    switch (brandBudgetChipIndex.value) {
      case 1:
        return 'budget_pending';
      case 2:
        return 'quotation_received';
      default:
        return 'quoting';
    }
  }

  Future<void> _refreshBrandBudgetCounts() async {
    final search = searchQuery.value.trim();
    final sort = _brandSortParam();

    final pendingResult = await ApiErrorHandler.call(
      () => _fetchBrandCampaigns(
        status: 'budget_pending',
        page: 1,
        pageSize: 1,
        search: search,
        sort: sort,
      ),
      showError: false,
    );

    final quotationResult = await ApiErrorHandler.call(
      () => _fetchBrandCampaigns(
        status: 'quotation_received',
        page: 1,
        pageSize: 1,
        search: search,
        sort: sort,
      ),
      showError: false,
    );

    final pendingTotal = pendingResult.isSuccess && pendingResult.data != null
        ? pendingResult.data!.totalItems
        : 0;

    final quotationTotal =
        quotationResult.isSuccess && quotationResult.data != null
        ? quotationResult.data!.totalItems
        : 0;

    brandBudgetPendingTotal.value = pendingTotal;
    brandQuotationReceivedTotal.value = quotationTotal;

    brandTabCounts[1] = pendingTotal + quotationTotal;
  }

  // -------- PUBLIC API --------

  String _agencySortParam() {
    return isSortLowToHigh.value ? 'low_budget' : 'high_budget';
  }

  String _influencerSortParam() {
    return _agencySortParam();
  }

  String _brandSortParam() {
    return isSortLowToHigh.value ? 'ASC' : 'DESC';
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

  void _refetchCurrentInfluencerTab({required bool reset}) {
    switch (currentTabIndex.value) {
      case 0:
        fetchNewOffers(reset: reset);
        break;
      case 1:
        fetchActiveJobs(reset: reset);
        break;
      case 2:
        fetchCompletedJobs(reset: reset);
        break;
      case 3:
        fetchPendingPayments(reset: reset);
        break;
      case 4:
        fetchDeclinedJobs(reset: reset);
        break;
    }
  }

  void _refetchCurrentBrandTab({required bool reset}) {
    switch (currentTabIndex.value) {
      case 0:
        fetchBrandActive(reset: reset);
        break;
      case 1:
        fetchBrandBudgeting(reset: reset);
        break;
      case 2:
        fetchBrandCompleted(reset: reset);
        break;
      case 3:
        fetchBrandDrafts(reset: reset);
        break;
      case 4:
        fetchBrandCanceled(reset: reset);
        break;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;

    final c = _tabScrollControllers[index];
    if (c != null && c.hasClients) {
      c.jumpTo(0);
    }

    final hasSearch = searchQuery.value.trim().isNotEmpty;

    if (isBrand) {
      switch (index) {
        case 0:
          if (hasSearch || brandActive.isEmpty) {
            fetchBrandActive(reset: true);
          }
          break;
        case 1:
          _applySelectedBrandBudgetList();
          if (hasSearch || !_selectedBrandBudgetLoaded) {
            fetchBrandBudgeting(reset: true);
          }
          break;
        case 2:
          if (hasSearch || brandCompleted.isEmpty) {
            fetchBrandCompleted(reset: true);
          }
          break;
        case 3:
          if (hasSearch || brandDrafts.isEmpty) {
            fetchBrandDrafts(reset: true);
          }
          break;
        case 4:
          if (hasSearch || brandCanceled.isEmpty) {
            fetchBrandCanceled(reset: true);
          }
          break;
      }
      return;
    }

    if (isAdAgency) {
      switch (index) {
        case 0:
          if (hasSearch || newOffers.isEmpty) {
            fetchNewOffers(reset: true);
          }
          break;
        case 1:
          if (hasSearch || quotedJobs.isEmpty) {
            fetchQuotedJobs(reset: true);
          }
          break;
        case 2:
          if (hasSearch || activeJobs.isEmpty) {
            fetchActiveJobs(reset: true);
          }
          break;
        case 3:
          if (hasSearch || completedJobs.isEmpty) {
            fetchCompletedJobs(reset: true);
          }
          break;
        case 4:
          if (hasSearch || pendingPayments.isEmpty) {
            fetchPendingPayments(reset: true);
          }
          break;
        case 5:
          if (hasSearch || declinedJobs.isEmpty) {
            fetchDeclinedJobs(reset: true);
          }
          break;
      }
      return;
    }

    switch (index) {
      case 0:
        if (hasSearch || newOffers.isEmpty) {
          fetchNewOffers(reset: true);
        }
        break;
      case 1:
        if (hasSearch || activeJobs.isEmpty) {
          fetchActiveJobs(reset: true);
        }
        break;
      case 2:
        if (hasSearch || completedJobs.isEmpty) {
          fetchCompletedJobs(reset: true);
        }
        break;
      case 3:
        if (hasSearch || pendingPayments.isEmpty) {
          fetchPendingPayments(reset: true);
        }
        break;
      case 4:
        if (hasSearch || declinedJobs.isEmpty) {
          fetchDeclinedJobs(reset: true);
        }
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
      return brandTabCounts[index] ?? _fallbackCountForTab(index);
    }

    if (isAdAgency) {
      return agencyTabCounts[index] ?? _fallbackCountForTab(index);
    }

    final apiCount = influencerTabCounts[index];
    if (apiCount != null) return apiCount;

    final hasCounts = influencerCounts.isNotEmpty;

    int byKey(String key, int fallback) {
      if (!hasCounts) return fallback;
      return influencerCounts[key] ?? fallback;
    }

    switch (index) {
      case 0:
        return byKey('new_offer', _fallbackCountForTab(index));
      case 1:
        return byKey('active', _fallbackCountForTab(index));
      case 2:
        return byKey('completed', _fallbackCountForTab(index));
      case 3:
        return byKey('pending', _fallbackCountForTab(index));
      case 4:
        return byKey('declined', _fallbackCountForTab(index));
      default:
        return 0;
    }
  }

  void _setTabCount({required int tabIndex, required int total}) {
    if (isBrand) {
      brandTabCounts[tabIndex] = total;
      return;
    }

    if (isAdAgency) {
      agencyTabCounts[tabIndex] = total;
      return;
    }

    influencerTabCounts[tabIndex] = total;
  }

  int _fallbackCountForTab(int index) {
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
    if (_accountTypeService.isBrand) {
      Get.toNamed(AppRoutes.brandCampaignDetails, id: 1, arguments: job);
      return;
    }

    _openInfluencerOrAgencyJobDetails(job);
  }

  void editDraftCampaign(JobItem job) {
    if (!isBrand) return;

    final campaignId = job.id;
    if (campaignId == null || campaignId.trim().isEmpty) return;

    // Jump directly to step 2, pass campaignId
    Get.toNamed(
      AppRoutes.createCampaignStep2,
      id: 1,
      arguments: {'campaignId': campaignId},
    );
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

  // Influencer/Agency
  List<JobItem> get filteredNewOffers => List<JobItem>.from(newOffers);
  List<JobItem> get filteredQuotedJobs => List<JobItem>.from(quotedJobs);
  List<JobItem> get filteredActiveJobs => List<JobItem>.from(activeJobs);
  List<JobItem> get filteredCompletedJobs => List<JobItem>.from(completedJobs);
  List<JobItem> get filteredPendingPayments =>
      List<JobItem>.from(pendingPayments);
  List<JobItem> get filteredDeclinedJobs => List<JobItem>.from(declinedJobs);

  // Brand
  List<JobItem> get filteredBrandActive => List<JobItem>.from(brandActive);
  List<JobItem> get filteredBrandCompleted =>
      List<JobItem>.from(brandCompleted);
  List<JobItem> get filteredBrandDrafts => List<JobItem>.from(brandDrafts);
  List<JobItem> get filteredBrandCanceled => List<JobItem>.from(brandCanceled);

  int get brandBudgetPendingCount => brandBudgetPendingTotal.value;
  int get brandQuotationReceivedCount => brandQuotationReceivedTotal.value;

  List<JobItem> get filteredBrandBudgeting =>
      List<JobItem>.from(brandBudgeting);

  // -------- INFLUENCER/AGENCY FETCH (same as before) --------

  Future<void> fetchNewOffers({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: 0,
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
          search: searchQuery.value.trim(),
          sort: _influencerSortParam(),
        );
      },
    );
  }

  Future<void> fetchQuotedJobs({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: 1,
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
      tabIndex: isAdAgency ? 2 : 1,
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
          search: searchQuery.value.trim(),
          sort: _influencerSortParam(),
        );
      },
    );
  }

  Future<void> fetchCompletedJobs({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: isAdAgency ? 3 : 2,
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
          search: searchQuery.value.trim(),
          sort: _influencerSortParam(),
        );
      },
    );
  }

  Future<void> fetchPendingPayments({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: isAdAgency ? 4 : 3,
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
          search: searchQuery.value.trim(),
          sort: _influencerSortParam(),
        );
      },
    );
  }

  Future<void> fetchDeclinedJobs({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: isAdAgency ? 5 : 4,
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
          search: searchQuery.value.trim(),
          sort: _influencerSortParam(),
        );
      },
    );
  }

  // -------- AGENCY ACTIONS --------

  Future<void> acceptAgencyOffer(JobItem job) async {
    final campaignId = job.id;
    if (campaignId == null || campaignId.isEmpty) return;

    loadingJobId.value = campaignId;
    try {
      final result = await ApiErrorHandler.call(
        () => _apiClient.dio.post('/campaign/agency/$campaignId/accept'),
      );

      if (result.isSuccess) {
        newOffers.removeWhere((e) => e.id == campaignId);
        await fetchActiveJobs(reset: true);
      }
    } finally {
      loadingJobId.value = '';
    }
  }

  Future<void> declineAgencyOffer(JobItem job) async {
    final campaignId = job.id;
    if (campaignId == null || campaignId.isEmpty) return;

    loadingJobId.value = campaignId;
    try {
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
    } finally {
      loadingJobId.value = '';
    }
  }

  Future<void> refreshInvitationJobs() async {
    if (isInfluencer) {
      await fetchInfluencerCounts();
    }

    await fetchNewOffers(reset: true);
  }

  // -------- BRAND FETCH --------

  Future<void> _fetchPagedJobs({
    required bool reset,
    required int tabIndex,
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

      _setTabCount(tabIndex: tabIndex, total: page.totalItems);

      if (items.isEmpty) {
        hasMore.value = false;
        return;
      }

      target.addAll(items);

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
      tabIndex: 0,
      isLoading: isLoadingBrandActive,
      hasMore: hasMoreBrandActive,
      target: brandActive,
      getPage: () => _brandActivePage,
      setPage: (v) => _brandActivePage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'active',
        page: page,
        pageSize: _pageSize,
        search: searchQuery.value.trim(),
        sort: _brandSortParam(),
      ),
    );
  }

  Future<void> fetchBrandBudgeting({bool reset = false}) async {
    if (isLoadingBrandBudgeting.value) return;
    if (!_selectedBrandBudgetHasMore && !reset) return;

    isLoadingBrandBudgeting.value = true;

    try {
      final chipIndex = brandBudgetChipIndex.value;
      final targetList = _brandBudgetListByChip(chipIndex);

      if (reset) {
        _brandBudgetPageByChip[chipIndex] = 1;
        _brandBudgetHasMoreByChip[chipIndex] = true;
        _brandBudgetLoadedByChip[chipIndex] = false;
        targetList.clear();
        brandBudgeting.clear();
      }

      await _refreshBrandBudgetCounts();

      final currentPage = _brandBudgetPageByChip[chipIndex] ?? 1;
      final status = _brandBudgetStatusParamByChip(chipIndex);

      final result = await ApiErrorHandler.call(
        () => _fetchBrandCampaigns(
          status: status,
          page: currentPage,
          pageSize: _pageSize,
          search: searchQuery.value.trim(),
          sort: _brandSortParam(),
        ),
        showError: false,
      );

      if (!result.isSuccess || result.data == null) return;

      final page = result.data!;
      final items = page.items;

      if (items.isEmpty) {
        _brandBudgetHasMoreByChip[chipIndex] = false;
        _brandBudgetLoadedByChip[chipIndex] = true;
        _applySelectedBrandBudgetList();
        return;
      }

      targetList.addAll(items);

      final nextPage = currentPage + 1;
      _brandBudgetPageByChip[chipIndex] = nextPage;

      final endBySize = items.length < _pageSize;
      final endByTotalPages = nextPage > page.totalPages;

      _brandBudgetHasMoreByChip[chipIndex] = !(endBySize || endByTotalPages);
      _brandBudgetLoadedByChip[chipIndex] = true;

      _applySelectedBrandBudgetList();
    } finally {
      isLoadingBrandBudgeting.value = false;
    }
  }

  Future<void> fetchBrandCompleted({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: 2,
      isLoading: isLoadingBrandCompleted,
      hasMore: hasMoreBrandCompleted,
      target: brandCompleted,
      getPage: () => _brandCompletedPage,
      setPage: (v) => _brandCompletedPage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'completed',
        page: page,
        pageSize: _pageSize,
        search: searchQuery.value.trim(),
        sort: _brandSortParam(),
      ),
    );
  }

  Future<void> fetchBrandDrafts({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: 3,
      isLoading: isLoadingBrandDrafts,
      hasMore: hasMoreBrandDrafts,
      target: brandDrafts,
      getPage: () => _brandDraftsPage,
      setPage: (v) => _brandDraftsPage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'draft',
        page: page,
        pageSize: _pageSize,
        search: searchQuery.value.trim(),
        sort: _brandSortParam(),
      ),
    );
  }

  Future<void> fetchBrandCanceled({bool reset = false}) async {
    await _fetchPagedJobs(
      reset: reset,
      tabIndex: 4,
      isLoading: isLoadingBrandCanceled,
      hasMore: hasMoreBrandCanceled,
      target: brandCanceled,
      getPage: () => _brandCanceledPage,
      setPage: (v) => _brandCanceledPage = v,
      requestPage: (page) => _fetchBrandCampaigns(
        status: 'cancelled',
        page: page,
        pageSize: _pageSize,
        search: searchQuery.value.trim(),
        sort: _brandSortParam(),
      ),
    );
  }

  // -------- BRAND API --------

  Future<_CampaignPage> _fetchBrandCampaigns({
    required String status,
    required int page,
    required int pageSize,
    String? search,
    String? sort,
  }) async {
    final res = await _apiClient.dio.get(
      '/campaign/my-campaigns',
      queryParameters: {
        'status': status,
        'page': page,
        'limit': pageSize,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
      },
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
    final totalItems = (meta?['total'] as num?)?.toInt() ?? list.length;
    final limit = (meta?['limit'] as num?)?.toInt() ?? pageSize;
    final totalPages = totalItems <= 0 ? 1 : (totalItems / limit).ceil();

    return _CampaignPage(
      items: items,
      totalPages: totalPages,
      totalItems: totalItems,
    );
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

    final base = _mapInfluencerJobToJobItem(raw, statusHint: '');

    final milestonesRaw = (raw['milestones'] as List?) ?? const [];
    final milestones = milestonesRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
        .asMap()
        .entries
        .map((entry) => _mapInfluencerMilestone(entry.value, entry.key))
        .toList(growable: false);

    return _copyJobWithMilestones(base, milestones);
  }

  Future<_CampaignPage> _fetchInfluencerJobs({
    required String status,
    required int page,
    required int pageSize,
    String? search,
    String? sort,
  }) async {
    final res = await _apiClient.dio.get(
      '/campaign/influencer/jobs',
      queryParameters: {
        'page': page,
        'limit': pageSize,
        if (status.trim().isNotEmpty) 'status': status.trim(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
      },
    );

    final data = res.data as Map<String, dynamic>;
    final list = (data['data'] as List?) ?? const [];
    final items = list
        .whereType<Map>()
        .map(
          (e) => _mapInfluencerJobToJobItem(
            e.cast<String, dynamic>(),
            statusHint: status,
          ),
        )
        .toList();

    final meta = (data['pagination'] ?? data['meta']) as Map<String, dynamic>?;
    final totalItems = (meta?['total'] as num?)?.toInt() ?? list.length;
    final limit = (meta?['limit'] as num?)?.toInt() ?? pageSize;
    final totalPages = totalItems <= 0 ? 1 : (totalItems / limit).ceil();

    return _CampaignPage(
      items: items,
      totalPages: totalPages,
      totalItems: totalItems,
    );
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
        .map(
          (e) => _mapAgencyCampaignToJob(e.cast<String, dynamic>(), tab: tab),
        )
        .toList();

    final meta = data['meta'] as Map<String, dynamic>?;
    final totalItems = (meta?['total'] as num?)?.toInt() ?? list.length;
    final limit = (meta?['limit'] as num?)?.toInt() ?? pageSize;
    final totalPages = totalItems <= 0 ? 1 : (totalItems / limit).ceil();

    return _CampaignPage(
      items: items,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }

  JobItem _mapAgencyCampaignToJob(
    Map<String, dynamic> json, {
    required String tab,
  }) {
    final campaignId = json['id']?.toString();
    final campaignName = (json['campaignName'])?.toString().trim();

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
    final duration = _intFrom(schedule?['duration'] ?? json['duration']);

    final campaignTypeRaw = json['campaignType']?.toString();

    final budget = totalBudget > 0 ? totalBudget : availableBudget;
    final timeLeftToRequoteMinutes = _intFrom(json['timeLeftToRequoteMinutes']);
    final progress = _intFrom(json['progressPercent']);

    final useStartingDate = _shouldUseStartDateForAgencyTab(tab);

    return JobItem(
      id: campaignId,
      title: campaignName?.isNotEmpty == true
          ? campaignName!
          : 'Untitled Campaign',
      clientName: clientName?.isNotEmpty == true ? clientName! : '—',
      campaignType: _parseCampaignType(campaignTypeRaw),
      dateLabel: _resolveJobDateLabel(
        useStartingDate: useStartingDate,
        startingDate: startingDate,
        deadline: deadline,
        duration: duration,
      ),
      budget: budget,
      sharePercent: serviceFee.round(),
      dueLabel: _resolveJobDueLabel(
        deadline: deadline,
        startingDate: startingDate,
        duration: duration,
      ),
      progressPercent: progress,
      timeLeftToRequoteMinutes: timeLeftToRequoteMinutes,
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
    if (value is String) return (double.tryParse(value) ?? 0.0).toInt();
    return null;
  }

  JobItem _mapInfluencerJobToJobItem(
    Map<String, dynamic> json, {
    required String statusHint,
  }) {
    final campaignId =
        json['id']?.toString() ?? json['assignmentId']?.toString();
    final campaignName = (json['campaignName'])?.toString().trim();
    final campaignTypeRaw = json['campaignType']?.toString();
    final brandName = (json['brandName'])?.toString().trim();
    final client = json['client'] as Map<String, dynamic>?;
    final clientName = client?['brandName']?.toString().trim();

    final offeredAmount = _numToDouble(json['offeredAmount']);
    final totalAmount = _numToDouble(json['totalAmount']);
    final budget = offeredAmount > 0 ? offeredAmount : totalAmount;

    final startingDate = json['startingDate']?.toString();
    final deadline = json['deadline']?.toString();
    final createdAt = json['createdAt']?.toString();
    final progress = json['progress'];
    final duration = _intFrom(json['duration']);
    final needSampleProduct = json['needSampleProduct'] == true;

    final useStartingDate = _shouldUseStartDateForInfluencerStatus(statusHint);

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
      dateLabel: _resolveJobDateLabel(
        useStartingDate: useStartingDate,
        startingDate: startingDate,
        deadline: deadline,
        duration: duration,
        fallbackDate: createdAt,
      ),
      budget: budget,
      dueLabel: _resolveJobDueLabel(
        deadline: deadline,
        startingDate: startingDate,
        duration: duration,
      ),
      progressPercent: _intFrom(progress),
      needToSendSample: needSampleProduct,
      sharePercent: 0,
    );
  }

  // -------- INFLUENCER ACTIONS --------

  Future<void> acceptInfluencerOffer(JobItem job) async {
    final jobId = job.id?.trim();
    if (jobId == null || jobId.isEmpty) return;

    if (job.needToSendSample == true) {
      await Get.toNamed(AppRoutes.campaignShipping, id: 1, arguments: job);
      return;
    }

    loadingJobId.value = jobId;
    try {
      final result = await ApiErrorHandler.call(
        () => _campaignService.acceptInfluencerJobOffer(jobId: jobId),
      );

      if (result.isSuccess) {
        newOffers.removeWhere((e) => e.id == jobId);
        await fetchActiveJobs(reset: true);
        await fetchPendingPayments(reset: true);
        await fetchInfluencerCounts();
      }
    } finally {
      loadingJobId.value = '';
    }
  }

  Future<void> declineInfluencerOffer(JobItem job) async {
    final jobId = job.id?.trim();
    if (jobId == null || jobId.isEmpty) return;

    final reason = await showReasonBottomSheet(
      title: 'jobs_decline_reason_title'.tr,
      hintText: 'jobs_decline_reason_hint'.tr,
      submitText: 'jobs_decline_submit'.tr,
    );

    if (reason == null || reason.trim().isEmpty) return;

    loadingJobId.value = jobId;
    try {
      final result = await ApiErrorHandler.call(
        () => _campaignService.declineInfluencerJobOffer(
          jobId: jobId,
          reason: reason,
        ),
      );

      if (result.isSuccess) {
        newOffers.removeWhere((e) => e.id == jobId);
        await fetchDeclinedJobs(reset: true);
        await fetchInfluencerCounts();
      }
    } finally {
      loadingJobId.value = '';
    }
  }

  Future<void> completeInfluencerJob(JobItem job) async {
    final jobId = job.id;
    if (jobId == null || jobId.isEmpty) return;

    loadingJobId.value = jobId;
    try {
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
    } finally {
      loadingJobId.value = '';
    }
  }

  JobItem _mapCampaignToJob(
    Map<String, dynamic> json, {
    required String statusHint,
  }) {
    final campaignId = json['id']?.toString();
    final campaignName = (json['campaignName'])?.trim();
    final campaignTypeRaw = (json['campaignType'])?.trim();
    final budget = _numToDouble(json['totalBudget']);
    final createdAt = json['createdAt'];
    final deadline = json['deadline'];
    final rating = double.tryParse(json['rating']?.toString() ?? '');
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

    final budgetStatus = _budgetStatusLabel(statusHint: statusHint);
    final isQuotation = statusHint.toLowerCase() == 'quotation_received';

    return JobItem(
      id: campaignId,
      title: campaignName?.isNotEmpty == true
          ? campaignName!
          : 'Untitled Campaign',
      subTitle: _campaignTypeLabel(campaignTypeRaw),
      clientName: clientName,
      campaignType: _parseCampaignType(campaignTypeRaw),
      dateLabel: dateLabel,
      rating: rating,
      budget: isQuotation
          ? budget
          : (budgetPending > 0 ? budgetPending : budget),
      sharePercent: 0,
      progressPercent: progress,
      dueLabel: dueLabel,
      profitLabel: budgetStatus,
      totalEarningsLabel: 'Revised: $negotiationRevisedTimes Times',
      negotiationRevisedTimes: negotiationRevisedTimes,
      totalQuotationsReceived: totalQuotations,
    );
  }

  Future<void> deleteDraftCampaign(JobItem job) async {
    if (!isBrand) return;

    final campaignId = job.id?.trim() ?? '';
    if (campaignId.isEmpty) return;

    final confirmed = await DeleteCampaignDialog.show();
    if (!confirmed) return;

    final result = await ApiErrorHandler.call(
      () => _campaignService.deleteCampaignById(campaignId: campaignId),
    );

    if (!result.isSuccess) return;

    brandDrafts.removeWhere((e) => (e.id?.trim() ?? '') == campaignId);

    final currentCount = brandTabCounts[3] ?? brandDrafts.length;
    brandTabCounts[3] = currentCount > 0 ? currentCount - 1 : 0;

    AppSnackbar.showSuccessSnackbar(
      title: 'Success',
      message: 'Campaign deleted successfully.',
    );

    await fetchBrandDrafts(reset: true);
  }

  CampaignType _parseCampaignType(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v == 'paid_ad' || v == 'paidad') return CampaignType.paidAd;
    return CampaignType.influencerPromotion;
  }

  String _campaignTypeLabel(String? raw) {
    final v = (raw ?? '').toLowerCase();
    return v == 'paid_ad' || v == 'paidad'
        ? 'create_campaign_type_paid_title'
        : 'create_campaign_type_influencer_title';
  }

  String _budgetStatusLabel({required String statusHint}) {
    final hint = statusHint.toLowerCase();

    if (hint == 'quotation_received') return 'Quotation Received';
    if (hint == 'budget_pending') return 'Budget Pending';
    return 'Budgeting & Quoting';
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
  final int totalItems;

  const _CampaignPage({
    required this.items,
    required this.totalPages,
    required this.totalItems,
  });
}
