import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/api_error_handler.dart';
import 'models/analytics_models.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _api = Get.find<AnalyticsService>();

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
  int totalResults = 0;

  // Sort
  final isSortLowToHigh = true.obs;

  @override
  void onInit() {
    super.onInit();

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
      final sortOrder = isSortLowToHigh.value ? 'low_to_high' : 'high_to_low';

      if (isAnalyticsTab.value) {
        final res = await ApiErrorHandler.call(
          () => _api.fetchClientAnalytics(
            page: page.value,
            limit: pageSize,
            search: query.isEmpty ? null : query,
            sortOrder: sortOrder,
          ),
          showError: false,
        );

        if (res.isSuccess && res.data != null) {
          final result = res.data!;
          totalResults = result.total;
          totalPages.value = (totalResults / pageSize).ceil().clamp(1, 9999);

          final list = result.items.map(_mapAnalyticsRow).toList();
          _sortInfluencers(list);
          influencers.assignAll(list);

          final platformStats = _buildPlatformStats(result.items);
          _sortPlatforms(platformStats);
          platforms.assignAll(platformStats);

          _applyTopStats(result.items, list);
        } else {
          influencers.clear();
          platforms.clear();
        }
      } else {
        final res = await ApiErrorHandler.call(
          () => _api.fetchClientReports(
            page: page.value,
            limit: pageSize,
            search: query.isEmpty ? null : query,
          ),
          showError: false,
        );

        if (res.isSuccess && res.data != null) {
          final result = res.data!;
          totalResults = result.total;
          totalPages.value = (totalResults / pageSize).ceil().clamp(1, 9999);

          final list = result.items.map(_mapReportToTransaction).toList();
          _sortTransactions(list);
          transactions.assignAll(list);
        } else {
          transactions.clear();
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  InfluencerRowModel _mapAnalyticsRow(Map<String, dynamic> json) {
    final name =
        _stringFrom(json, [
          'influencerName',
          'name',
          'fullName',
          'agencyName',
          'clientName',
          'brandName',
        ]) ??
        '—';

    final campaignDone =
        _intFrom(
          json['campaignsCompleted'] ??
              json['jobsCompleted'] ??
              json['campaignDone'] ??
              json['totalJobs'] ??
              json['completedJobs'],
        ) ??
        0;

    return InfluencerRowModel(name: name, campaignDone: campaignDone);
  }

  TransactionModel _mapReportToTransaction(Map<String, dynamic> json) {
    final campaign = _stringFrom(json, ['campaignName', 'campaignTitle']) ?? '';
    final milestone = _stringFrom(json, ['milestoneTitle', 'milestone']) ?? '';
    final name = campaign.isNotEmpty ? campaign : milestone;

    final date = _stringFrom(json, ['date', 'createdAt']) ?? '';
    final amount = _intFrom(json['amount'] ?? json['paidAmount'] ?? 0) ?? 0;

    return TransactionModel(
      titleKey: 'earnings_payment_for',
      titleParams: {'name': name.isNotEmpty ? name : 'Campaign'},
      subtitle: date.isNotEmpty ? date : '—',
      amount: amount,
      type: TransactionType.inbound,
      detailsKey: 'analytics_view_campaign_details',
      searchText: '$campaign $milestone'.trim(),
    );
  }

  void _applyTopStats(
    List<Map<String, dynamic>> rawItems,
    List<InfluencerRowModel> list,
  ) {
    if (list.isNotEmpty) {
      final sorted = List<InfluencerRowModel>.from(list)
        ..sort((a, b) => b.campaignDone.compareTo(a.campaignDone));
      topInfluencer.value = sorted.first.name;
    }

    for (final item in rawItems) {
      final campaign = _stringFrom(item, [
        'topCampaign',
        'campaignName',
        'campaignTitle',
      ]);
      if (campaign != null && campaign.isNotEmpty) {
        topCampaign.value = campaign;
        return;
      }
    }
  }

  List<PlatformStatModel> _buildPlatformStats(
    List<Map<String, dynamic>> items,
  ) {
    final counts = <String, int>{};

    for (final item in items) {
      final platforms = item['platforms'];
      if (platforms is List) {
        for (final p in platforms) {
          final key = p?.toString().toLowerCase().trim();
          if (key == null || key.isEmpty) continue;
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
    }

    if (counts.isEmpty) return const [];

    return counts.entries.map((entry) {
      final icon = _platformIcon(entry.key);
      return PlatformStatModel(
        platformName: _capitalize(entry.key),
        jobsCompleted: entry.value,
        iconAsset: icon,
      );
    }).toList();
  }

  String _platformIcon(String key) {
    switch (key.toLowerCase()) {
      case 'facebook':
        return 'assets/icons/facebook.png';
      case 'instagram':
        return 'assets/icons/instagram.png';
      case 'youtube':
        return 'assets/icons/youtube.png';
      case 'tiktok':
        return 'assets/icons/tiktok.png';
      default:
        return 'assets/icons/instagram.png';
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String? _stringFrom(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
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
