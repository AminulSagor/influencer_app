import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/account_type_service.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/report_service.dart';
import 'models/report_model.dart';

class ReportLogController extends GetxController {
  final accountTypeService = Get.find<AccountTypeService>();
  final ReportService _reportService = Get.find<ReportService>();

  bool get isBrand => accountTypeService.isBrand;
  bool get isAgency => accountTypeService.isAdAgency;
  bool get isInfluencer => accountTypeService.isInfluencer;

  final searchController = TextEditingController();
  final scrollController = ScrollController();

  final searchQuery = ''.obs;
  final selectedFilter = Rxn<ReportStatus>();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isInitializingCounts = false.obs;

  final RxList<ReportModel> displayedReports = <ReportModel>[].obs;

  final currentPage = 1.obs;
  final limit = 10.obs;
  final totalItems = 0.obs;
  final totalPages = 1.obs;
  final hasMore = true.obs;

  final flaggedCount = 0.obs;
  final pendingCount = 0.obs;
  final resolvedCount = 0.obs;

  final Set<int> _loadedPages = <int>{};
  final Set<String> _loadedReportIds = <String>{};
  int? _inFlightPage;

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_onScroll);

    _initFilterCounts();
    loadReports(page: 1, reset: true);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  List<ReportStatus> get availableStatuses {
    if (isBrand) return [ReportStatus.pending, ReportStatus.resolved];
    return [ReportStatus.flagged, ReportStatus.pending, ReportStatus.resolved];
  }

  String? get selectedStatusLabel => selectedFilter.value?.name;

  String? get selectedStatusParam {
    final status = selectedFilter.value;
    if (status == null) return null;

    switch (status) {
      case ReportStatus.flagged:
        return 'Flagged';
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.resolved:
        return 'Resolved';
    }
  }

  String _statusParamFromStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.flagged:
        return 'Flagged';
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.resolved:
        return 'Resolved';
    }
  }

  void _resetPagingState() {
    _loadedPages.clear();
    _loadedReportIds.clear();
    _inFlightPage = null;
    currentPage.value = 1;
    totalItems.value = 0;
    totalPages.value = 1;
    hasMore.value = true;
    displayedReports.clear();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadNextPage();
    }
  }

  Future<void> _initFilterCounts() async {
    isInitializingCounts.value = true;

    for (final status in availableStatuses) {
      final result = await _fetchReportsRaw(
        page: 1,
        limitValue: 1,
        status: _statusParamFromStatus(status),
        search: null,
      );

      final total = result?.total ?? 0;

      switch (status) {
        case ReportStatus.flagged:
          flaggedCount.value = total;
          break;
        case ReportStatus.pending:
          pendingCount.value = total;
          break;
        case ReportStatus.resolved:
          resolvedCount.value = total;
          break;
      }
    }

    isInitializingCounts.value = false;
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      await _initFilterCounts();
      await loadReports(page: 1, reset: true);
    });
  }

  Future<void> toggleFilter(ReportStatus status) async {
    if (isBrand && status == ReportStatus.flagged) return;

    if (selectedFilter.value == status) {
      selectedFilter.value = null;
    } else {
      selectedFilter.value = status;
    }

    await loadReports(page: 1, reset: true);
  }

  Future<void> loadNextPage() async {
    if (!hasMore.value) return;

    final nextPage = currentPage.value + 1;

    if (nextPage > totalPages.value) {
      hasMore.value = false;
      return;
    }

    if (_inFlightPage == nextPage) return;
    if (_loadedPages.contains(nextPage)) return;

    await loadReports(page: nextPage, reset: false);
  }

  Future<void> loadReports({int page = 1, bool reset = false}) async {
    final trimmedSearch = searchQuery.value.trim();
    final statusParam = selectedStatusParam;

    if (reset) {
      _resetPagingState();
      isLoading.value = true;
    } else {
      if (_inFlightPage == page || _loadedPages.contains(page)) return;
      isLoadingMore.value = true;
    }

    _inFlightPage = page;

    final result = await _fetchReportsRaw(
      page: page,
      limitValue: limit.value,
      status: statusParam,
      search: trimmedSearch.isEmpty ? null : trimmedSearch,
    );

    if (result != null) {
      final items = result.items.map(_mapApiToReport).toList(growable: false);

      if (reset) {
        displayedReports.assignAll(items);
        _loadedReportIds
          ..clear()
          ..addAll(items.map((e) => e.id));
      } else {
        final newItems = items
            .where((item) {
              if (item.id.trim().isEmpty) return true;
              return !_loadedReportIds.contains(item.id);
            })
            .toList(growable: false);

        displayedReports.addAll(newItems);
        _loadedReportIds.addAll(
          newItems.where((e) => e.id.trim().isNotEmpty).map((e) => e.id),
        );
      }

      _loadedPages.add(result.page);

      totalItems.value = result.total;
      currentPage.value = result.page;
      limit.value = result.limit;
      totalPages.value = result.totalPages;
      hasMore.value =
          result.page < result.totalPages &&
          displayedReports.length < result.total;
    } else {
      if (reset) {
        _resetPagingState();
        hasMore.value = false;
      }
    }

    _inFlightPage = null;
    isLoading.value = false;
    isLoadingMore.value = false;
  }

  Future<PagedResult<Map<String, dynamic>>?> _fetchReportsRaw({
    required int page,
    required int limitValue,
    String? status,
    String? search,
  }) async {
    final result = await ApiErrorHandler.call(() {
      if (accountTypeService.isBrand) {
        return _reportService.fetchClientReports(
          page: page,
          limit: limitValue,
          status: status,
          search: search,
        );
      }

      if (accountTypeService.isAdAgency) {
        return _reportService.fetchAgencyReports(
          page: page,
          limit: limitValue,
          status: status,
          search: search,
        );
      }

      return _reportService.fetchInfluencerReportLogs(
        page: page,
        limit: limitValue,
        status: status,
        search: search,
      );
    }, showError: false);

    if (result.isSuccess && result.data != null) {
      return result.data!;
    }

    return null;
  }

  ReportModel _mapApiToReport(Map<String, dynamic> json) {
    final id = json['reportId']?.toString() ?? json['id']?.toString() ?? '';
    final campaignName =
        json['campaignName']?.toString() ??
        json['campaignTitle']?.toString() ??
        '—';
    final milestone =
        json['milestoneTitle']?.toString() ??
        json['milestone']?.toString() ??
        '—';
    final message =
        json['issueSummary']?.toString() ??
        json['submissionDescription']?.toString() ??
        json['details']?.toString() ??
        json['feedback']?.toString() ??
        json['message']?.toString() ??
        '—';
    final companyName =
        json['clientName']?.toString() ??
        json['brandName']?.toString() ??
        json['companyName']?.toString() ??
        campaignName;
    final rawDate =
        json['reportedAt']?.toString() ??
        json['submissionDate']?.toString() ??
        json['date']?.toString() ??
        json['createdAt']?.toString() ??
        '—';

    final formattedDate = _formatDate(rawDate);
    final statusRaw =
        json['status']?.toString() ??
        json['logStatus']?.toString() ??
        json['submissionStatus']?.toString() ??
        '';

    return ReportModel(
      id: id,
      campaignName: campaignName,
      milestone: milestone,
      timeAgo: _timeAgo(rawDate),
      message: message,
      companyName: companyName,
      date: formattedDate,
      status: _mapStatus(statusRaw),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null) return '—';

    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return '—';
    }
  }

  ReportStatus _mapStatus(String raw) {
    final value = raw.toLowerCase();

    if (value.contains('resolve') ||
        value.contains('approve') ||
        value.contains('complete')) {
      return ReportStatus.resolved;
    }

    if (value.contains('pending') || value.contains('review')) {
      return ReportStatus.pending;
    }

    if (value.contains('flag') ||
        value.contains('reject') ||
        value.contains('declin')) {
      return ReportStatus.flagged;
    }

    return ReportStatus.pending;
  }

  String _timeAgo(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return '—';
    }
  }
}
