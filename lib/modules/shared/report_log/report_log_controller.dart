// report_log_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/report_model.dart';

class ReportLogController extends GetxController {
  // Search Text Controller
  final searchController = TextEditingController();

  // Observables
  var searchQuery = ''.obs;
  var selectedFilter =
      Rxn<ReportStatus>(); // Null means "All", otherwise specific status

  // Dummy Data
  final List<ReportModel> _allReports = [
    ReportModel(
      id: '1',
      campaignName: 'Summer Fashion Campaign',
      milestone: '1',
      timeAgo: '2',
      message: 'audio_issue', // Key for translation
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

  // Counts
  int get flaggedCount =>
      _allReports.where((e) => e.status == ReportStatus.flagged).length;
  int get pendingCount =>
      _allReports.where((e) => e.status == ReportStatus.pending).length;
  int get resolvedCount =>
      _allReports.where((e) => e.status == ReportStatus.resolved).length;

  // Filtered List
  List<ReportModel> get displayedReports {
    return _allReports.where((report) {
      // 1. Check Search
      bool matchesSearch = report.campaignName.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );

      // 2. Check Filter
      bool matchesFilter =
          selectedFilter.value == null || report.status == selectedFilter.value;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void toggleFilter(ReportStatus status) {
    if (selectedFilter.value == status) {
      selectedFilter.value = null; // Deselect if clicked again (Show All)
    } else {
      selectedFilter.value = status;
    }
  }
}
