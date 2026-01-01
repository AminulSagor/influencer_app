import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/transaction_model.dart';
import 'models/analytics_models.dart';
import 'services/analytics_mock_api.dart';

class AnalyticsController extends GetxController {
  final _api = AnalyticsMockApi();

  // Tabs
  final isAnalyticsTab = true.obs; // true=Analytics, false=Transactions

  // Search
  final searchCtrl = TextEditingController();
  Timer? _debounce;

  // Pagination
  final page = 1.obs;
  final totalPages = 30.obs;
  final pageSize = 5;

  // Loading
  final isLoading = false.obs;

  // Data
  final topCampaign = 'Summer Sale'.obs;
  final topInfluencer = 'Hania Amir'.obs;

  final influencers = <InfluencerRowModel>[].obs;
  final platforms = <PlatformStatModel>[].obs;

  final transactions = <TransactionModel>[].obs;

  int get showingCount =>
      isAnalyticsTab.value ? influencers.length : transactions.length;
  int get totalResults => 100;

  // Sort
  final isSortLowToHigh = true.obs;

  @override
  void onInit() {
    super.onInit();

    // load platforms & apply initial sort
    totalPages.value = (totalResults / pageSize).ceil();
    final p = _api.getPlatformStats();
    _sortPlatforms(p);
    platforms.assignAll(p);

    _fetch();

    searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        page.value = 1;
        _fetch();
      });
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  void onTabChanged(bool analytics) {
    if (isAnalyticsTab.value == analytics) return;
    isAnalyticsTab.value = analytics;
    page.value = 1;
    searchCtrl.clear();
    _fetch();
  }

  void nextPage() {
    if (page.value >= totalPages.value) return;
    page.value++;
    _fetch();
  }

  void prevPage() {
    if (page.value <= 1) return;
    page.value--;
    _fetch();
  }

  void toggleSort() {
    isSortLowToHigh.value = !isSortLowToHigh.value;
    _applySort();
  }

  Future<void> _fetch() async {
    isLoading.value = true;
    try {
      final query = searchCtrl.text.trim();

      if (isAnalyticsTab.value) {
        final res = await _api.fetchInfluencers(
          page: page.value,
          pageSize: pageSize,
          query: query,
        );

        final list = List<InfluencerRowModel>.from(res);
        _sortInfluencers(list);
        influencers.assignAll(list);

        // platforms are visible in analytics tab too -> keep them sorted
        final p = List<PlatformStatModel>.from(platforms);
        _sortPlatforms(p);
        platforms.assignAll(p);
      } else {
        final res = await _api.fetchTransactions(
          page: page.value,
          pageSize: pageSize,
          query: query,
        );

        final list = List<TransactionModel>.from(res);
        _sortTransactions(list);
        transactions.assignAll(list);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _applySort() {
    if (isAnalyticsTab.value) {
      final infl = List<InfluencerRowModel>.from(influencers);
      _sortInfluencers(infl);
      influencers.assignAll(infl);

      final p = List<PlatformStatModel>.from(platforms);
      _sortPlatforms(p);
      platforms.assignAll(p);
    } else {
      final tx = List<TransactionModel>.from(transactions);
      _sortTransactions(tx);
      transactions.assignAll(tx);
    }
  }

  void _sortInfluencers(List<InfluencerRowModel> list) {
    list.sort((a, b) {
      final cmp = a.campaignDone.compareTo(b.campaignDone);
      return isSortLowToHigh.value ? cmp : -cmp;
    });
  }

  void _sortPlatforms(List<PlatformStatModel> list) {
    list.sort((a, b) {
      final cmp = a.jobsCompleted.compareTo(b.jobsCompleted);
      return isSortLowToHigh.value ? cmp : -cmp;
    });
  }

  void _sortTransactions(List<TransactionModel> list) {
    list.sort((a, b) {
      final cmp = a.amount.compareTo(b.amount);
      return isSortLowToHigh.value ? cmp : -cmp;
    });
  }

  int _parseMoneyToInt(String input) {
    // "৳20,000" -> "20000"
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }
}
