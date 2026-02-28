import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/models/job_item.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/account_type_service.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/earnings_service.dart';
import '../../ad_agency/services/agency_dashboard_service.dart';
import '../../../routes/app_routes.dart';

class EarningsChartPoint {
  final String label; // e.g. "7/11"
  final int value; // amount in currency units

  const EarningsChartPoint({required this.label, required this.value});
}

class ClientItem {
  final String name;
  final int jobsCompleted;

  const ClientItem({required this.name, required this.jobsCompleted});
}

class PlatformItem {
  final String name;
  final int jobsCompleted;
  final String iconKey; // "facebook", "instagram", etc.

  const PlatformItem({
    required this.name,
    required this.jobsCompleted,
    required this.iconKey,
  });
}

class EarningsController extends GetxController {
  final AccountTypeService _accountTypeService = Get.find<AccountTypeService>();
  final EarningsService _earningsService = Get.find<EarningsService>();
  final AgencyDashboardService _agencyDashboardService =
      Get.find<AgencyDashboardService>();
  // ------------ Tabs ------------
  /// 0 = Earnings, 1 = Transactions
  final mainTabIndex = 0.obs;

  /// Under Earnings: 0 = Client List, 1 = Platform
  final earningsInnerTabIndex = 0.obs;

  // ------------ Overview values ------------
  final lifetimeEarnings = 0.obs;
  final pendingEarnings = 0.obs;

  final totalEarnings = 0.obs;
  final recentEarnings = 0.obs;
  final mostUsedPlatform = ''.obs;

  final selectedRangeLabel = '7_days'.tr.obs; // keep label translatable
  final chartPoints = <EarningsChartPoint>[].obs;
  final chartIsLoading = false.obs;

  // ------------ Client list (paginated) ------------
  final clientSearchQuery = ''.obs;
  final clientIsLoading = false.obs;
  final clientCurrentPage = 1.obs;
  final clientTotalPages = 1.obs;
  final clientTotalItems = 0.obs;
  final clientItems = <ClientItem>[].obs;

  // ------------ Platform stats ------------
  final platformIsLoading = false.obs;
  final platformItems = <PlatformItem>[].obs;

  // ------------ Transactions (paginated) ------------
  final transactionSortLowToHigh = true.obs;
  final transactionSearchQuery = ''.obs;
  final transactionIsLoading = false.obs;
  final transactionCurrentPage = 1.obs;
  final transactionTotalPages = 1.obs;
  final transactionTotalItems = 0.obs;
  final transactionItems = <TransactionModel>[].obs;

  final int _clientsPageSize = 4;
  final int _transactionsPageSize = 4;

  final List<ClientItem> _clientSource = [];
  final List<PlatformItem> _platformSource = [];

  @override
  void onInit() {
    super.onInit();
    _initReactions();
    _loadInitial();
  }

  // ------------ Public actions ------------

  void changeMainTab(int index) => mainTabIndex.value = index;

  void changeEarningsInnerTab(int index) => earningsInnerTabIndex.value = index;

  bool get hasNextClientPage =>
      clientCurrentPage.value < clientTotalPages.value;

  bool get hasNextTransactionPage =>
      transactionCurrentPage.value < transactionTotalPages.value;

  Future<void> goToNextClientPage() async {
    if (hasNextClientPage) {
      await fetchClientPage(clientCurrentPage.value + 1);
    }
  }

  Future<void> goToNextTransactionPage() async {
    if (hasNextTransactionPage) {
      await fetchTransactionPage(transactionCurrentPage.value + 1);
    }
  }

  void toggleTransactionSort() {
    transactionSortLowToHigh.value = !transactionSortLowToHigh.value;
    _sortVisibleTransactions();
  }

  // ------------ Init helpers ------------

  void _initReactions() {
    debounce<String>(
      transactionSearchQuery,
      (_) => fetchTransactionPage(1),
      time: const Duration(milliseconds: 250),
    );
  }

  Future<void> _loadInitial() async {
    await _loadOverview();
    await fetchTransactionPage(1);
  }

  Future<void> _loadOverview() async {
    chartIsLoading.value = true;

    if (_accountTypeService.isBrand) {
      lifetimeEarnings.value = 0;
      pendingEarnings.value = 0;
      totalEarnings.value = 0;
      chartPoints.clear();
      chartIsLoading.value = false;
      return;
    }

    if (_accountTypeService.isAdAgency) {
      selectedRangeLabel.value = '30d';

      final summaryResult = await ApiErrorHandler.call(
        () => _agencyDashboardService.fetchSummary(),
        showError: false,
      );
      if (summaryResult.isSuccess && summaryResult.data != null) {
        final summaryData = _extractData(summaryResult.data!);
        lifetimeEarnings.value = _intFrom(summaryData['lifetimeEarnings']) ?? 0;
        pendingEarnings.value = _intFrom(summaryData['pendingEarnings']) ?? 0;
        totalEarnings.value = lifetimeEarnings.value;
      }

      final overviewResult = await ApiErrorHandler.call(
        () => _agencyDashboardService.fetchEarningsOverview(range: '30d'),
        showError: false,
      );
      if (overviewResult.isSuccess && overviewResult.data != null) {
        _applyOverviewData(_extractData(overviewResult.data!));
      } else {
        chartPoints.clear();
      }

      chartIsLoading.value = false;
      return;
    }

    selectedRangeLabel.value = '7_days'.tr;

    final summaryResult = await ApiErrorHandler.call(
      () => _earningsService.fetchInfluencerSummary(),
      showError: false,
    );
    if (summaryResult.isSuccess && summaryResult.data != null) {
      final summaryData = _extractData(summaryResult.data!);
      lifetimeEarnings.value = _intFrom(summaryData['lifetimeEarnings']) ?? 0;
      pendingEarnings.value = _intFrom(summaryData['pendingEarnings']) ?? 0;
      totalEarnings.value = lifetimeEarnings.value;
    }

    final overviewResult = await ApiErrorHandler.call(
      () => _earningsService.fetchInfluencerEarningsOverview(range: '7d'),
      showError: false,
    );
    if (overviewResult.isSuccess && overviewResult.data != null) {
      _applyOverviewData(_extractData(overviewResult.data!));
    } else {
      chartPoints.clear();
    }

    chartIsLoading.value = false;
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    final nested = response['data'];
    if (nested is Map<String, dynamic>) return nested;
    return response;
  }

  void _applyOverviewData(Map<String, dynamic> data) {
    final breakdown = data['breakdown'];
    if (breakdown is List) {
      final points = breakdown
          .whereType<Map>()
          .map((entry) {
            final map = entry.cast<String, dynamic>();
            final rawDate = map['date']?.toString() ?? '';
            final amount = _intFrom(map['amount']) ?? 0;
            return EarningsChartPoint(
              label: _formatChartLabel(rawDate),
              value: amount,
            );
          })
          .toList(growable: false);

      chartPoints.assignAll(points);
    } else {
      chartPoints.clear();
    }
  }

  String _formatChartLabel(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return '${parsed.month}/${parsed.day}';
  }

  Future<void> fetchClientPage(int page) async {
    clientIsLoading.value = true;

    final query = clientSearchQuery.value.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _clientSource
        : _clientSource
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();

    clientTotalItems.value = filtered.length;
    final totalPages = (filtered.length / _clientsPageSize).ceil().clamp(
      1,
      999,
    );
    clientTotalPages.value = totalPages;

    final normalizedPage = page.clamp(1, totalPages);
    clientCurrentPage.value = normalizedPage;

    final start = (normalizedPage - 1) * _clientsPageSize;
    final pageItems = filtered
        .skip(start)
        .take(_clientsPageSize)
        .toList(growable: false);

    clientItems.assignAll(pageItems);
    clientIsLoading.value = false;
  }

  Future<void> fetchPlatforms() async {
    platformIsLoading.value = true;
    platformItems.assignAll(_platformSource);
    platformIsLoading.value = false;
  }

  Future<void> fetchTransactionPage(int page) async {
    transactionIsLoading.value = true;

    if (_accountTypeService.isBrand) {
      transactionItems.clear();
      transactionTotalItems.value = 0;
      transactionTotalPages.value = 1;
      transactionCurrentPage.value = 1;
      transactionIsLoading.value = false;
      return;
    }

    final query = transactionSearchQuery.value.trim();
    final res = await ApiErrorHandler.call(() {
      if (_accountTypeService.isAdAgency) {
        return _earningsService.fetchAgencyTransactions(
          page: page,
          limit: _transactionsPageSize,
          search: query.isEmpty ? null : query,
        );
      }
      return _earningsService.fetchInfluencerTransactions(
        page: page,
        limit: _transactionsPageSize,
        search: query.isEmpty ? null : query,
      );
    }, showError: false);

    if (res.isSuccess && res.data != null) {
      final data = res.data!;
      transactionTotalItems.value = data.total;
      final totalPages = (data.total / _transactionsPageSize).ceil().clamp(
        1,
        999,
      );
      transactionTotalPages.value = totalPages;
      transactionCurrentPage.value = page.clamp(1, totalPages);

      final items = data.items.map(_mapTransaction).toList();
      _sortTransactionModels(items);
      transactionItems.assignAll(items);

      recentEarnings.value = _mostRecentTransactionAmount(data.items);

      _refreshDerivedStatsFromTransactions(data.items);
    } else {
      transactionItems.clear();
      transactionTotalItems.value = 0;
      transactionTotalPages.value = 1;
      transactionCurrentPage.value = 1;
      _clientSource.clear();
      _platformSource.clear();
      clientItems.clear();
      platformItems.clear();
      recentEarnings.value = 0;
    }
    transactionIsLoading.value = false;
  }

  void _sortVisibleTransactions() {
    final sorted = transactionItems.toList();
    _sortTransactionModels(sorted);
    transactionItems.assignAll(sorted);
  }

  void _sortTransactionModels(List<TransactionModel> items) {
    items.sort((a, b) {
      final compare = a.amount.compareTo(b.amount);
      return transactionSortLowToHigh.value ? compare : -compare;
    });
  }

  int _mostRecentTransactionAmount(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 0;

    DateTime? mostRecentDate;
    int mostRecentAmount = 0;

    for (final item in items) {
      final rawDate = item['date']?.toString() ?? item['createdAt']?.toString();
      final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;
      final amount = _intFrom(item['amount'] ?? item['paidAmount']) ?? 0;

      if (parsedDate == null) {
        continue;
      }

      if (mostRecentDate == null || parsedDate.isAfter(mostRecentDate)) {
        mostRecentDate = parsedDate;
        mostRecentAmount = amount;
      }
    }

    if (mostRecentDate == null) {
      return _intFrom(items.first['amount'] ?? items.first['paidAmount']) ?? 0;
    }

    return mostRecentAmount;
  }

  bool get hasPrevClientPage => clientCurrentPage.value > 1;
  bool get hasPrevTransactionPage => transactionCurrentPage.value > 1;

  Future<void> goToPrevClientPage() async {
    if (hasPrevClientPage) await fetchClientPage(clientCurrentPage.value - 1);
  }

  Future<void> goToPrevTransactionPage() async {
    if (hasPrevTransactionPage)
      await fetchTransactionPage(transactionCurrentPage.value - 1);
  }

  TransactionModel _mapTransaction(Map<String, dynamic> json) {
    final jobName =
        json['jobName']?.toString() ??
        json['campaignName']?.toString() ??
        'Campaign';
    final clientName =
        json['clientName']?.toString() ?? json['brandName']?.toString() ?? '';
    final amount = _intFrom(json['amount'] ?? json['paidAmount']) ?? 0;
    final date =
        json['date']?.toString() ?? json['createdAt']?.toString() ?? '';
    final campaignId =
        json['campaignId']?.toString() ?? json['jobId']?.toString();

    return TransactionModel(
      titleKey: 'earnings_payment_for',
      titleParams: {'name': jobName},
      subtitle: _formatTransactionDate(date),
      amount: amount,
      type: TransactionType.inbound,
      detailsKey: 'earnings_view_campaign_details',
      searchText: '$jobName $clientName',
      campaignId: campaignId,
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

  void openTransactionCampaignDetails(TransactionModel item) {
    final campaignId = item.campaignId?.trim();
    if (campaignId == null || campaignId.isEmpty) return;

    final fallbackJob = JobItem(
      id: campaignId,
      title: item.titleParams['name']?.trim().isNotEmpty == true
          ? item.titleParams['name']!.trim()
          : 'Campaign',
      clientName: 'Client',
      dateLabel: item.subtitle,
      budget: item.amount.toDouble(),
      sharePercent: 0,
      campaignType: CampaignType.paidAd,
    );

    Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: fallbackJob);
  }

  void _refreshDerivedStatsFromTransactions(List<Map<String, dynamic>> items) {
    final clientCounts = <String, int>{};
    final platformCounts = <String, int>{};

    for (final item in items) {
      final client =
          item['clientName']?.toString() ??
          item['brandName']?.toString() ??
          'Client';
      clientCounts[client] = (clientCounts[client] ?? 0) + 1;

      final platform =
          item['paymentMethod']?.toString() ??
          item['platform']?.toString() ??
          'Platform';
      platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
    }

    _clientSource
      ..clear()
      ..addAll(
        clientCounts.entries.map(
          (e) => ClientItem(name: e.key, jobsCompleted: e.value),
        ),
      );

    _platformSource
      ..clear()
      ..addAll(
        platformCounts.entries.map(
          (e) => PlatformItem(
            name: e.key,
            jobsCompleted: e.value,
            iconKey: _platformIconKey(e.key),
          ),
        ),
      );

    fetchClientPage(1);
    fetchPlatforms();
  }

  String _platformIconKey(String name) {
    final key = name.toLowerCase();
    if (key.contains('facebook')) return 'facebook';
    if (key.contains('instagram')) return 'instagram';
    if (key.contains('youtube')) return 'youtube';
    if (key.contains('tiktok')) return 'tiktok';
    return 'facebook';
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return num.tryParse(value)?.toInt();
    return null;
  }
}
