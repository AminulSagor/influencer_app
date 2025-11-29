import 'package:get/get.dart';

import '../../../core/models/job_item.dart';
import '../../../routes/app_routes.dart';

class JobsController extends GetxController {
  /// 0: New Offers, 1: Active, 2: Completed, 3: Pending, 4: Declined
  final currentTabIndex = 0.obs;

  /// used by search bar
  final searchQuery = ''.obs;

  /// master data lists (already fetched pages)
  final newOffers = <JobItem>[].obs;
  final activeJobs = <JobItem>[].obs;
  final completedJobs = <JobItem>[].obs;
  final pendingPayments = <JobItem>[].obs;
  final declinedJobs = <JobItem>[].obs;

  /// loading state per tab
  final isLoadingNewOffers = false.obs;
  final isLoadingActiveJobs = false.obs;
  final isLoadingCompletedJobs = false.obs;
  final isLoadingPendingPayments = false.obs;
  final isLoadingDeclinedJobs = false.obs;

  /// pagination flags per tab
  final hasMoreNewOffers = true.obs;
  final hasMoreActiveJobs = true.obs;
  final hasMoreCompletedJobs = true.obs;
  final hasMorePendingPayments = true.obs;
  final hasMoreDeclinedJobs = true.obs;

  // current page index (1-based) per tab
  int _newOffersPage = 1;
  int _activeJobsPage = 1;
  int _completedJobsPage = 1;
  int _pendingPaymentsPage = 1;
  int _declinedJobsPage = 1;

  static const int _pageSize = 10;
  static const int _totalPerTab = 30; // mock total items per tab

  @override
  void onInit() {
    super.onInit();
    _initLoad();
  }

  Future<void> _initLoad() async {
    // First page for all tabs (you can limit to current tab if you want)
    await Future.wait([
      fetchNewOffers(reset: true),
      fetchActiveJobs(reset: true),
      fetchCompletedJobs(reset: true),
      fetchPendingPayments(reset: true),
      fetchDeclinedJobs(reset: true),
    ]);
  }

  // -------- PUBLIC API --------

  void changeTab(int index) {
    currentTabIndex.value = index;

    // lazy-load first page if list is empty
    switch (index) {
      case 0:
        if (newOffers.isEmpty) fetchNewOffers(reset: true);
        break;
      case 1:
        if (activeJobs.isEmpty) fetchActiveJobs(reset: true);
        break;
      case 2:
        if (completedJobs.isEmpty) fetchCompletedJobs(reset: true);
        break;
      case 3:
        if (pendingPayments.isEmpty) fetchPendingPayments(reset: true);
        break;
      case 4:
        if (declinedJobs.isEmpty) fetchDeclinedJobs(reset: true);
        break;
    }
  }

  /// Called from view when user scrolls near the bottom.
  Future<void> loadMoreForTab(int index) async {
    switch (index) {
      case 0:
        await fetchNewOffers();
        break;
      case 1:
        await fetchActiveJobs();
        break;
      case 2:
        await fetchCompletedJobs();
        break;
      case 3:
        await fetchPendingPayments();
        break;
      case 4:
        await fetchDeclinedJobs();
        break;
    }
  }

  int getCountForTab(int index) {
    // Count uses currently loaded items.
    switch (index) {
      case 0:
        return newOffers.length;
      case 1:
        return activeJobs.length;
      case 2:
        return completedJobs.length;
      case 3:
        return pendingPayments.length;
      case 4:
        return declinedJobs.length;
      default:
        return 0;
    }
  }

  // -------- FILTERED LISTS (used by UI) --------

  List<JobItem> _filterList(List<JobItem> source) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return source;

    return source.where((job) {
      final title = job.title.toLowerCase();
      final client = job.clientName.toLowerCase();
      return title.contains(q) || client.contains(q);
    }).toList();
  }

  List<JobItem> get filteredNewOffers => _filterList(newOffers);
  List<JobItem> get filteredActiveJobs => _filterList(activeJobs);
  List<JobItem> get filteredCompletedJobs => _filterList(completedJobs);
  List<JobItem> get filteredPendingPayments => _filterList(pendingPayments);
  List<JobItem> get filteredDeclinedJobs => _filterList(declinedJobs);

  // -------- FETCH METHODS (mock API + pagination) --------

  Future<void> fetchNewOffers({bool reset = false}) async {
    if (isLoadingNewOffers.value) return;
    if (!hasMoreNewOffers.value && !reset) return;

    isLoadingNewOffers.value = true;

    if (reset) {
      _newOffersPage = 1;
      hasMoreNewOffers.value = true;
      newOffers.clear();
    }

    final page = _newOffersPage;
    final items = await _mockFetchJobs(
      tabIndex: 0,
      page: page,
      pageSize: _pageSize,
    );

    if (items.isEmpty) {
      hasMoreNewOffers.value = false;
    } else {
      newOffers.addAll(items);
      _newOffersPage++;
      if (items.length < _pageSize) {
        hasMoreNewOffers.value = false;
      }
    }

    isLoadingNewOffers.value = false;
  }

  Future<void> fetchActiveJobs({bool reset = false}) async {
    if (isLoadingActiveJobs.value) return;
    if (!hasMoreActiveJobs.value && !reset) return;

    isLoadingActiveJobs.value = true;

    if (reset) {
      _activeJobsPage = 1;
      hasMoreActiveJobs.value = true;
      activeJobs.clear();
    }

    final page = _activeJobsPage;
    final items = await _mockFetchJobs(
      tabIndex: 1,
      page: page,
      pageSize: _pageSize,
    );

    if (items.isEmpty) {
      hasMoreActiveJobs.value = false;
    } else {
      activeJobs.addAll(items);
      _activeJobsPage++;
      if (items.length < _pageSize) {
        hasMoreActiveJobs.value = false;
      }
    }

    isLoadingActiveJobs.value = false;
  }

  Future<void> fetchCompletedJobs({bool reset = false}) async {
    if (isLoadingCompletedJobs.value) return;
    if (!hasMoreCompletedJobs.value && !reset) return;

    isLoadingCompletedJobs.value = true;

    if (reset) {
      _completedJobsPage = 1;
      hasMoreCompletedJobs.value = true;
      completedJobs.clear();
    }

    final page = _completedJobsPage;
    final items = await _mockFetchJobs(
      tabIndex: 2,
      page: page,
      pageSize: _pageSize,
    );

    if (items.isEmpty) {
      hasMoreCompletedJobs.value = false;
    } else {
      completedJobs.addAll(items);
      _completedJobsPage++;
      if (items.length < _pageSize) {
        hasMoreCompletedJobs.value = false;
      }
    }

    isLoadingCompletedJobs.value = false;
  }

  Future<void> fetchPendingPayments({bool reset = false}) async {
    if (isLoadingPendingPayments.value) return;
    if (!hasMorePendingPayments.value && !reset) return;

    isLoadingPendingPayments.value = true;

    if (reset) {
      _pendingPaymentsPage = 1;
      hasMorePendingPayments.value = true;
      pendingPayments.clear();
    }

    final page = _pendingPaymentsPage;
    final items = await _mockFetchJobs(
      tabIndex: 3,
      page: page,
      pageSize: _pageSize,
    );

    if (items.isEmpty) {
      hasMorePendingPayments.value = false;
    } else {
      pendingPayments.addAll(items);
      _pendingPaymentsPage++;
      if (items.length < _pageSize) {
        hasMorePendingPayments.value = false;
      }
    }

    isLoadingPendingPayments.value = false;
  }

  Future<void> fetchDeclinedJobs({bool reset = false}) async {
    if (isLoadingDeclinedJobs.value) return;
    if (!hasMoreDeclinedJobs.value && !reset) return;

    isLoadingDeclinedJobs.value = true;

    if (reset) {
      _declinedJobsPage = 1;
      hasMoreDeclinedJobs.value = true;
      declinedJobs.clear();
    }

    final page = _declinedJobsPage;
    final items = await _mockFetchJobs(
      tabIndex: 4,
      page: page,
      pageSize: _pageSize,
    );

    if (items.isEmpty) {
      hasMoreDeclinedJobs.value = false;
    } else {
      declinedJobs.addAll(items);
      _declinedJobsPage++;
      if (items.length < _pageSize) {
        hasMoreDeclinedJobs.value = false;
      }
    }

    isLoadingDeclinedJobs.value = false;
  }

  void openJobDetails(JobItem job) {
    Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: job);
  }

  // -------- MOCK API --------

  Future<List<JobItem>> _mockFetchJobs({
    required int tabIndex,
    required int page,
    required int pageSize,
  }) async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    final start = (page - 1) * pageSize;
    if (start >= _totalPerTab) return [];

    final endExclusive = start + pageSize;
    final actualEnd = endExclusive > _totalPerTab ? _totalPerTab : endExclusive;
    final count = actualEnd - start;

    return List.generate(count, (i) {
      final globalIndex = start + i;
      return _buildMockJob(tabIndex: tabIndex, index: globalIndex);
    });
  }

  JobItem _buildMockJob({required int tabIndex, required int index}) {
    final pattern = index % 3;

    // Common fake milestones for the details screen
    List<Milestone> summerMilestones = const [
      Milestone(
        stepLabel: '1',
        title: 'Initial Brand Awareness',
        subtitle: '2 Instagram Posts + 2 Stories',
        amountLabel: '৳3,000',
        dayLabel: 'DAY 1',
        status: MilestoneStatus.declined,
      ),
      Milestone(
        stepLabel: '2',
        title: 'Lead Generation',
        subtitle: '1 Sponsored Video (60 sec)',
        amountLabel: '৳5,000',
        dayLabel: 'DAY 2',
        status: MilestoneStatus.paid,
      ),
      Milestone(
        stepLabel: '3',
        title: 'Sales Conversion',
        subtitle: '1 Sponsored Video (60 sec)',
        amountLabel: '৳2,000',
        dayLabel: 'DAY 3',
        status: MilestoneStatus.inReview,
      ),
      Milestone(
        stepLabel: '4',
        title: 'Campaign Wrap Up',
        subtitle: 'Final Report',
        amountLabel: '৳1,000',
        dayLabel: 'DAY 4',
        status: MilestoneStatus.todo,
      ),
    ];

    List<Milestone> techMilestones = const [
      Milestone(
        stepLabel: '1',
        title: 'Teaser Content',
        subtitle: 'Short launch teaser',
        amountLabel: '৳4,000',
        dayLabel: 'DAY 1',
      ),
      Milestone(
        stepLabel: '2',
        title: 'Launch Live Stream',
        subtitle: 'Launch day live session',
        amountLabel: '৳6,000',
        dayLabel: 'DAY 3',
      ),
    ];

    List<Milestone> fitnessMilestones = const [
      Milestone(
        stepLabel: '1',
        title: 'Workout Reel',
        subtitle: 'Product in daily routine',
        amountLabel: '৳3,500',
        dayLabel: 'DAY 1',
      ),
      Milestone(
        stepLabel: '2',
        title: 'Story Series',
        subtitle: 'Before & after stories',
        amountLabel: '৳4,500',
        dayLabel: 'DAY 2',
      ),
    ];

    switch (tabIndex) {
      // ---------------- NEW OFFERS ----------------
      case 0:
        switch (pattern) {
          case 0:
            return JobItem(
              title: 'Summer Fashion Campaign',
              clientName: 'StyleCo',
              dateLabel: 'Dec 15, 2025',
              budget: 111000,
              sharePercent: 10,
              profitLabel: '৳16,500',
              totalCostLabel: '৳111,000',
              milestones: summerMilestones,
            );
          case 1:
            return JobItem(
              title: 'Tech Product Launch',
              clientName: 'TechGuru',
              dateLabel: 'Dec 28, 2025',
              budget: 111000,
              sharePercent: 15,
              profitLabel: '৳18,000',
              totalCostLabel: '৳111,000',
              milestones: techMilestones,
            );
          default:
            return JobItem(
              title: 'Fitness Brand Partnership',
              clientName: 'FitLife',
              dateLabel: 'Dec 26, 2025',
              budget: 111000,
              sharePercent: 5,
              profitLabel: '৳8,000',
              totalCostLabel: '৳111,000',
              milestones: fitnessMilestones,
            );
        }

      // ---------------- ACTIVE JOBS ----------------
      case 1:
        switch (pattern) {
          case 0:
            return JobItem(
              title: 'Summer Fashion Campaign',
              clientName: 'StyleCo',
              dateLabel: 'Dec 15, 2025',
              budget: 111000,
              sharePercent: 10,
              progressPercent: 75,
              dueLabel: 'Due: 3 Days',
              profitLabel: '৳16,500',
              totalCostLabel: '৳111,000',
              milestones: summerMilestones,
            );
          case 1:
            return JobItem(
              title: 'Tech Product Launch',
              clientName: 'TechGuru',
              dateLabel: 'Dec 28, 2025',
              budget: 111000,
              sharePercent: 15,
              progressPercent: 40,
              dueLabel: 'Due: 4 Days',
              profitLabel: '৳18,000',
              totalCostLabel: '৳111,000',
              milestones: techMilestones,
            );
          default:
            return JobItem(
              title: 'Fitness Brand Partnership',
              clientName: 'FitLife',
              dateLabel: 'Dec 26, 2025',
              budget: 111000,
              sharePercent: 10,
              progressPercent: 90,
              dueLabel: 'Due: Tomorrow',
              profitLabel: '৳8,000',
              totalCostLabel: '৳111,000',
              milestones: fitnessMilestones,
            );
        }

      // ---------------- COMPLETED JOBS ----------------
      case 2:
        switch (pattern) {
          case 0:
            return JobItem(
              title: 'Summer Fashion Campaign',
              clientName: 'StyleCo',
              dateLabel: 'Dec 15, 2025',
              budget: 111000,
              sharePercent: 10,
              rating: 4,
              profitLabel: '৳16,500',
              totalCostLabel: '৳111,000',
              milestones: summerMilestones,
            );
          case 1:
            return JobItem(
              title: 'Tech Product Launch',
              clientName: 'TechGuru',
              dateLabel: 'Dec 28, 2025',
              budget: 111000,
              sharePercent: 15,
              rating: 3,
              profitLabel: '৳18,000',
              totalCostLabel: '৳111,000',
              milestones: techMilestones,
            );
          default:
            return JobItem(
              title: 'Fitness Brand Partnership',
              clientName: 'FitLife',
              dateLabel: 'Dec 26, 2025',
              budget: 111000,
              sharePercent: 10,
              rating: 5,
              profitLabel: '৳8,000',
              totalCostLabel: '৳111,000',
              milestones: fitnessMilestones,
            );
        }

      // ---------------- PENDING PAYMENTS ----------------
      case 3:
        switch (pattern) {
          case 0:
            return JobItem(
              title: 'Summer Fashion Campaign',
              clientName: 'StyleCo',
              dateLabel: 'Dec 15, 2025',
              budget: 111000,
              sharePercent: 10,
              profitLabel: '৳16,500',
              totalCostLabel: '৳111,000',
              milestones: summerMilestones,
            );
          case 1:
            return JobItem(
              title: 'Tech Product Launch',
              clientName: 'TechGuru',
              dateLabel: 'Dec 28, 2025',
              budget: 111000,
              sharePercent: 15,
              profitLabel: '৳18,000',
              totalCostLabel: '৳111,000',
              milestones: techMilestones,
            );
          default:
            return JobItem(
              title: 'Fitness Brand Partnership',
              clientName: 'FitLife',
              dateLabel: 'Dec 26, 2025',
              budget: 111000,
              sharePercent: 10,
              profitLabel: '৳8,000',
              totalCostLabel: '৳111,000',
              milestones: fitnessMilestones,
            );
        }

      // ---------------- DECLINED JOBS ----------------
      case 4:
      default:
        switch (pattern) {
          case 0:
            return JobItem(
              title: 'Summer Fashion Campaign',
              clientName: 'StyleCo',
              dateLabel: 'Dec 15, 2025',
              budget: 111000,
              sharePercent: 10,
              profitLabel: '৳16,500',
              totalCostLabel: '৳111,000',
              milestones: summerMilestones,
            );
          case 1:
            return JobItem(
              title: 'Tech Product Launch',
              clientName: 'TechGuru',
              dateLabel: 'Dec 28, 2025',
              budget: 111000,
              sharePercent: 15,
              profitLabel: '৳18,000',
              totalCostLabel: '৳111,000',
              milestones: techMilestones,
            );
          default:
            return JobItem(
              title: 'Fitness Brand Partnership',
              clientName: 'FitLife',
              dateLabel: 'Dec 26, 2025',
              budget: 111000,
              sharePercent: 10,
              profitLabel: '৳8,000',
              totalCostLabel: '৳111,000',
              milestones: fitnessMilestones,
            );
        }
    }
  }
}
