import 'package:get/get.dart';

enum TransactionType { inbound, outbound }

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

class TransactionItem {
  /// Localized UI title
  final String titleKey; // e.g. 'earnings_payment_for'
  final Map<String, String> titleParams; // e.g. {'name': 'Summer Sale'}

  /// Subtitle is usually date/time from API (keep raw)
  final String subtitle;

  final int amount;
  final TransactionType type;

  /// Localized UI details label
  final String detailsKey; // e.g. 'earnings_view_campaign_details'

  /// Used for searching (campaign name / keywords)
  final String searchText;

  const TransactionItem({
    required this.titleKey,
    this.titleParams = const {},
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.detailsKey,
    required this.searchText,
  });
}

class EarningsController extends GetxController {
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
  final transactionSearchQuery = ''.obs;
  final transactionIsLoading = false.obs;
  final transactionCurrentPage = 1.obs;
  final transactionTotalPages = 1.obs;
  final transactionTotalItems = 0.obs;
  final transactionItems = <TransactionItem>[].obs;

  // ------------ Internal mock data ------------
  late final List<ClientItem> _allClients;
  late final List<PlatformItem> _allPlatforms;
  late final List<TransactionItem> _allTransactions;

  final int _clientsPageSize = 4;
  final int _transactionsPageSize = 4;

  @override
  void onInit() {
    super.onInit();
    _seedMockData();
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

  // ------------ Init helpers ------------

  void _initReactions() {
    debounce<String>(
      clientSearchQuery,
      (_) => fetchClientPage(1),
      time: const Duration(milliseconds: 250),
    );

    debounce<String>(
      transactionSearchQuery,
      (_) => fetchTransactionPage(1),
      time: const Duration(milliseconds: 250),
    );
  }

  Future<void> _loadInitial() async {
    await Future.wait([
      fetchOverview(),
      fetchClientPage(1),
      fetchPlatforms(),
      fetchTransactionPage(1),
    ]);
  }

  // ------------ Mock seeding ------------

  void _seedMockData() {
    _allClients = [
      const ClientItem(name: 'TechGuru', jobsCompleted: 12),
      const ClientItem(name: 'StyleCo', jobsCompleted: 3),
      const ClientItem(name: 'FitLife', jobsCompleted: 1),
      const ClientItem(name: 'GymMaster', jobsCompleted: 1),
      ...List.generate(
        40,
        (i) =>
            ClientItem(name: 'Client #${i + 5}', jobsCompleted: (i % 10) + 1),
      ),
    ];

    _allPlatforms = const [
      PlatformItem(name: 'Facebook', jobsCompleted: 34, iconKey: 'facebook'),
      PlatformItem(name: 'Instagram', jobsCompleted: 23, iconKey: 'instagram'),
      PlatformItem(name: 'Youtube', jobsCompleted: 12, iconKey: 'youtube'),
      PlatformItem(name: 'Tiktok', jobsCompleted: 7, iconKey: 'tiktok'),
    ];

    _allTransactions = [
      const TransactionItem(
        titleKey: 'earnings_payment_for',
        titleParams: {'name': 'Summer Sale'},
        subtitle: 'Today, 2:30 PM',
        amount: 20000,
        type: TransactionType.inbound,
        detailsKey: 'earnings_view_campaign_details',
        searchText: 'payment summer sale',
      ),
      const TransactionItem(
        titleKey: 'earnings_withdrawal_request',
        subtitle: '3 Dec 2025, 2:30 PM',
        amount: 20000,
        type: TransactionType.outbound,
        detailsKey: 'earnings_view_campaign_details',
        searchText: 'withdrawal request',
      ),
      const TransactionItem(
        titleKey: 'earnings_payment_for',
        titleParams: {'name': 'Nike Air Max'},
        subtitle: 'Today, 2:30 PM',
        amount: 20000,
        type: TransactionType.inbound,
        detailsKey: 'earnings_view_campaign_details',
        searchText: 'payment nike air max',
      ),
      const TransactionItem(
        titleKey: 'earnings_withdrawal_request',
        subtitle: '3 Dec 2025, 2:30 PM',
        amount: 20000,
        type: TransactionType.outbound,
        detailsKey: 'earnings_view_campaign_details',
        searchText: 'withdrawal request',
      ),
      ...List.generate(
        60,
        (i) => TransactionItem(
          titleKey: i.isEven
              ? 'earnings_payment_for'
              : 'earnings_withdrawal_request',
          titleParams: i.isEven ? {'name': 'Campaign #${i + 5}'} : const {},
          subtitle: '${i + 4} Dec 2025, 2:${30 + (i % 20)} PM',
          amount: 15000 + (i % 6) * 1000,
          type: i.isEven ? TransactionType.inbound : TransactionType.outbound,
          detailsKey: 'earnings_view_campaign_details',
          searchText: i.isEven
              ? 'payment campaign ${i + 5}'
              : 'withdrawal request',
        ),
      ),
    ];
  }

  // ------------ Mock API calls ------------

  Future<void> fetchOverview() async {
    await Future.delayed(const Duration(milliseconds: 400));

    lifetimeEarnings.value = 200000;
    pendingEarnings.value = 18000;

    totalEarnings.value = 700000;
    recentEarnings.value = 20000;
    mostUsedPlatform.value = 'Tiktok';

    chartPoints.assignAll(const [
      EarningsChartPoint(label: '7/11', value: 28000),
      EarningsChartPoint(label: '8/11', value: 45000),
      EarningsChartPoint(label: '9/11', value: 22000),
      EarningsChartPoint(label: '10/11', value: 18000),
      EarningsChartPoint(label: '11/11', value: 15000),
      EarningsChartPoint(label: '12/11', value: 13000),
      EarningsChartPoint(label: '13/11', value: 5000),
    ]);
  }

  Future<void> fetchClientPage(int page) async {
    clientIsLoading.value = true;

    final query = clientSearchQuery.value.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _allClients
        : _allClients
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();

    await Future.delayed(const Duration(milliseconds: 350));

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
    await Future.delayed(const Duration(milliseconds: 350));
    platformItems.assignAll(_allPlatforms);
    platformIsLoading.value = false;
  }

  Future<void> fetchTransactionPage(int page) async {
    transactionIsLoading.value = true;

    final query = transactionSearchQuery.value.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _allTransactions
        : _allTransactions
              .where((t) => t.searchText.toLowerCase().contains(query))
              .toList();

    await Future.delayed(const Duration(milliseconds: 350));

    transactionTotalItems.value = filtered.length;
    final totalPages = (filtered.length / _transactionsPageSize).ceil().clamp(
      1,
      999,
    );
    transactionTotalPages.value = totalPages;

    final normalizedPage = page.clamp(1, totalPages);
    transactionCurrentPage.value = normalizedPage;

    final start = (normalizedPage - 1) * _transactionsPageSize;
    final pageItems = filtered
        .skip(start)
        .take(_transactionsPageSize)
        .toList(growable: false);

    transactionItems.assignAll(pageItems);
    transactionIsLoading.value = false;
  }
}
