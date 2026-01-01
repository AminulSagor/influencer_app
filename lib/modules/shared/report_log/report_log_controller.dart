import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/account_type_service.dart';
import 'models/report_model.dart';

class ReportLogController extends GetxController {
  final accountTypeService = Get.find<AccountTypeService>();

  bool get isBrand => accountTypeService.isBrand;

  // Search Text Controller
  final searchController = TextEditingController();

  // Observables
  var searchQuery = ''.obs;
  var selectedFilter = Rxn<ReportStatus>(); // null = All

  // Dummy Data
  final List<ReportModel> _allReports = [
    ReportModel(
      id: '1',
      campaignName: 'Summer Fashion Campaign',
      milestone: '1',
      timeAgo: '2',
      message: 'audio_issue',
      companyName: 'StyleCo',
      date: 'Dec 15, 2025',
      status: ReportStatus.flagged,
    ),
    ReportModel(
      id: '2',
      campaignName: 'Summer Fashion Campaign',
      milestone: '2',
      timeAgo: '2',
      message: 'audio_issue',
      companyName: 'StyleCo',
      date: 'Dec 15, 2025',
      status: ReportStatus.resolved,
    ),
    ReportModel(
      id: '3',
      campaignName: 'Winter Collection',
      milestone: '3',
      timeAgo: '5',
      message: 'audio_issue',
      companyName: 'StyleCo',
      date: 'Dec 15, 2025',
      status: ReportStatus.pending,
    ),
    ReportModel(
      id: '4',
      campaignName: 'Tech Review Ads',
      milestone: '1',
      timeAgo: '12',
      message: 'audio_issue',
      companyName: 'TechWorld',
      date: 'Dec 14, 2025',
      status: ReportStatus.flagged,
    ),
  ];

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

  // Filtered List
  List<ReportModel> get displayedReports {
    return _allReports.where((report) {
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
    }).toList();
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
}
