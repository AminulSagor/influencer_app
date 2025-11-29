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
  final String title;
  final String subtitle; // date/time label
  final int amount;
  final TransactionType type;
  final String detailsLabel;

  const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.detailsLabel,
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

  final selectedRangeLabel = '7 Days'.obs;
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
    // Re-fetch client list when search changes
    debounce<String>(
      clientSearchQuery,
      (_) => fetchClientPage(1),
      time: const Duration(milliseconds: 250),
    );

    // Re-fetch transactions when search changes
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
        title: 'Payment For “Summer Sale”',
        subtitle: 'Today, 2:30 PM',
        amount: 20000,
        type: TransactionType.inbound,
        detailsLabel: 'View Campaign Details',
      ),
      const TransactionItem(
        title: 'Withdrawal Request',
        subtitle: '3 Dec 2025, 2:30 PM',
        amount: 20000,
        type: TransactionType.outbound,
        detailsLabel: 'View Campaign Details',
      ),
      const TransactionItem(
        title: 'Payment For “Nike Air Max”',
        subtitle: 'Today, 2:30 PM',
        amount: 20000,
        type: TransactionType.inbound,
        detailsLabel: 'View Campaign Details',
      ),
      const TransactionItem(
        title: 'Withdrawal Request',
        subtitle: '3 Dec 2025, 2:30 PM',
        amount: 20000,
        type: TransactionType.outbound,
        detailsLabel: 'View Campaign Details',
      ),
      ...List.generate(
        60,
        (i) => TransactionItem(
          title: 'Payment For Campaign #${i + 5}',
          subtitle: '${i + 4} Dec 2025, 2:${30 + (i % 20)} PM',
          amount: 15000 + (i % 6) * 1000,
          type: i.isEven ? TransactionType.inbound : TransactionType.outbound,
          detailsLabel: 'View Campaign Details',
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
              .where((t) => t.title.toLowerCase().contains(query))
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
