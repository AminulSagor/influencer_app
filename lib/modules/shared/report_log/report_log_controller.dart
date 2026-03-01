import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/account_type_service.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/report_service.dart';
import 'models/report_model.dart';

class ReportLogController extends GetxController {
  final accountTypeService = Get.find<AccountTypeService>();
  final ReportService _reportService = Get.find<ReportService>();

  bool get isBrand => accountTypeService.isBrand;

  // Search Text Controller
  final searchController = TextEditingController();

  // Observables
  var searchQuery = ''.obs;
  var selectedFilter = Rxn<ReportStatus>(); // null = All
  var isLoading = false.obs;

  final RxList<ReportModel> _allReports = <ReportModel>[].obs;
  final RxList<ReportModel> displayedReports = <ReportModel>[].obs;
  late final Worker _filterWorker;

  @override
  void onInit() {
    super.onInit();
    _filterWorker = everAll([
      _allReports,
      searchQuery,
      selectedFilter,
    ], (_) => _applyFilters());
    loadReports();
  }

  @override
  void onClose() {
    _filterWorker.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Only show these tabs in UI
  List<ReportStatus> get availableStatuses {
    if (isBrand) return [ReportStatus.pending, ReportStatus.resolved];
    return [ReportStatus.flagged, ReportStatus.pending, ReportStatus.resolved];
  }

  // Counts (Brand users don't need flagged count)
  int get flaggedCount => isBrand
      ? 0
      : _allReports.where((e) => e.status == ReportStatus.flagged).length;

  int get pendingCount =>
      _allReports.where((e) => e.status == ReportStatus.pending).length;

  int get resolvedCount =>
      _allReports.where((e) => e.status == ReportStatus.resolved).length;

  void _applyFilters() {
    final filtered = _allReports
        .where((report) {
          final matchesSearch = report.campaignName.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );

          // If brand, never allow flagged filter (even if some old state exists)
          final activeFilter =
              (isBrand && selectedFilter.value == ReportStatus.flagged)
              ? null
              : selectedFilter.value;

          final matchesFilter =
              activeFilter == null || report.status == activeFilter;

          return matchesSearch && matchesFilter;
        })
        .toList(growable: false);

    displayedReports.assignAll(filtered);
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void toggleFilter(ReportStatus status) {
    // Brand can't select flagged
    if (isBrand && status == ReportStatus.flagged) return;

    if (selectedFilter.value == status) {
      selectedFilter.value = null; // toggle off
    } else {
      selectedFilter.value = status;
    }
  }

  Future<void> loadReports({int page = 1, int limit = 10}) async {
    isLoading.value = true;

    final result = await ApiErrorHandler.call(() {
      if (accountTypeService.isBrand) {
        return _reportService.fetchClientReports(
          page: page,
          limit: limit,
          search: searchQuery.value.trim().isEmpty
              ? null
              : searchQuery.value.trim(),
        );
      }

      if (accountTypeService.isAdAgency) {
        return _reportService.fetchAgencyReports(
          page: page,
          limit: limit,
          search: searchQuery.value.trim().isEmpty
              ? null
              : searchQuery.value.trim(),
        );
      }

      return _reportService.fetchInfluencerReportLogs(page: page, limit: limit);
    }, showError: false);

    if (result.isSuccess && result.data != null) {
      final items = result.data!.items
          .map(_mapApiToReport)
          .toList(growable: false);
      _allReports.assignAll(items);
    } else {
      _allReports.clear();
    }

    isLoading.value = false;
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
        json['submissionDescription']?.toString() ??
        json['issueSummary']?.toString() ??
        json['details']?.toString() ??
        json['feedback']?.toString() ??
        json['message']?.toString() ??
        '—';
    final companyName =
        json['clientName']?.toString() ??
        json['brandName']?.toString() ??
        json['companyName']?.toString() ??
        campaignName;
    final date =
        json['submissionDate']?.toString() ??
        json['date']?.toString() ??
        json['createdAt']?.toString() ??
        '—';
    final statusRaw =
        json['status']?.toString() ??
        json['logStatus']?.toString() ??
        json['submissionStatus']?.toString() ??
        '';

    return ReportModel(
      id: id,
      campaignName: campaignName,
      milestone: milestone,
      timeAgo: _timeAgo(date),
      message: message,
      companyName: companyName,
      date: date,
      status: _mapStatus(statusRaw),
    );
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
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return '—';
    }
  }
}
