import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/api_error_handler.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _api = Get.find<AnalyticsService>();

  final topCampaign = '—'.obs;
  final topInfluencer = '—'.obs;

  // Search
  final searchCtrl = TextEditingController();
  Timer? _debounce;

  // Pagination
  final page = 1.obs;
  final totalPages = 30.obs;
  final pageSize = 5;

  // Loading
  final isLoading = false.obs;

  final transactions = <TransactionModel>[].obs;

  int get showingCount => transactions.length;
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
    page.value = 1;
    _fetch();
  }

  Future<void> _fetch() async {
    isLoading.value = true;
    try {
      final query = searchCtrl.text.trim();
      final sortOrder = isSortLowToHigh.value ? 'low_to_high' : 'high_to_low';

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
        topCampaign.value =
            (result.topCampaignTitle != null &&
                result.topCampaignTitle!.trim().isNotEmpty)
            ? result.topCampaignTitle!
            : '—';
        topInfluencer.value =
            (result.topInfluencer != null &&
                result.topInfluencer!.trim().isNotEmpty)
            ? result.topInfluencer!
            : '—';

        totalResults = result.transactions.total;
        totalPages.value = (totalResults / pageSize).ceil().clamp(1, 9999);

        final list = result.transactions.items.map(_mapApiTransaction).toList();
        transactions.assignAll(list);
      } else {
        topCampaign.value = '—';
        topInfluencer.value = '—';
        transactions.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  TransactionModel _mapApiTransaction(Map<String, dynamic> json) {
    final campaign = _stringFrom(json, ['campaignName']) ?? '';
    final transactionId = _stringFrom(json, ['transactionId']) ?? '';
    final status = _stringFrom(json, ['status']) ?? '';
    final name = campaign.isNotEmpty ? campaign : 'Campaign';

    final date = _stringFrom(json, ['date']) ?? '';
    final amount = _amountFrom(json['amount']);

    return TransactionModel(
      titleKey: 'earnings_payment_for',
      titleParams: {'name': name},
      subtitle: _formatTransactionDate(date),
      amount: amount,
      type: TransactionType.inbound,
      detailsKey: 'analytics_view_campaign_details',
      searchText: '$campaign $status $transactionId'.trim(),
      campaignId: transactionId.isEmpty ? null : transactionId,
    );
  }

  String _formatTransactionDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '—';

    final trimmed = rawDate.trim();
    final parsed = DateTime.tryParse(trimmed) ?? _tryParseEpoch(trimmed);
    if (parsed == null) return trimmed;

    return DateFormat('yyyy-MM-dd hh:mm a').format(parsed.toLocal());
  }

  DateTime? _tryParseEpoch(String value) {
    final number = int.tryParse(value);
    if (number == null) return null;

    final isSeconds = value.length <= 10;
    final millis = isSeconds ? number * 1000 : number;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  int _amountFrom(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      return parsed?.round() ?? 0;
    }
    return 0;
  }

  String? _stringFrom(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}
