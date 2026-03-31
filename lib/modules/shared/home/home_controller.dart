import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/utils/date_formatter.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_dashboard_service.dart';
import 'package:influencer_app/modules/brand/services/brand_dashboard_service.dart';
import 'package:influencer_app/modules/influencer/services/influencer_dashboard_service.dart';
import 'package:influencer_app/routes/app_routes.dart';
import '../../../core/services/api_client.dart';
import '../bottom_navbar/bottom_nav_controller.dart';
import '../jobs/jobs_controller.dart';
import 'models/home_dashboard_model.dart';

class HomeController extends GetxController {
  final _accountTypeService = Get.find<AccountTypeService>();
  final _brandDashboardService = Get.find<BrandDashboardService>();
  final _agencyDashboardService = Get.find<AgencyDashboardService>();
  final _influencerDashboardService = Get.find<InfluencerDashboardService>();
  final _apiClient = Get.find<ApiClient>();

  final dashboard = HomeDashboardModel.empty().obs;
  final RxBool isInitialLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final userType = _resolveUserType();
    dashboard.value = HomeDashboardModel.empty(userType: userType);
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    isInitialLoading.value = true;
    try {
      await refreshDashboard();
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    if (_accountTypeService.isBrand) {
      await _loadBrandDashboard();
      return;
    }

    if (_accountTypeService.isAdAgency) {
      await _loadAgencyDashboard();
      return;
    }

    if (_accountTypeService.isInfluencer) {
      await _loadInfluencerDashboard();
    }
  }

  HomeUserType _resolveUserType() {
    if (_accountTypeService.isBrand) return HomeUserType.brand;
    if (_accountTypeService.isInfluencer) return HomeUserType.influencer;
    if (_accountTypeService.isAdAgency) return HomeUserType.agency;
    return HomeUserType.unknown;
  }

  Future<void> _loadBrandDashboard() async {
    var current = dashboard.value;

    final activeJobsResult = await ApiErrorHandler.call(
      () => _brandDashboardService.fetchActiveJobs(page: 1, limit: 3),
      showError: false,
    );

    final quotingCountResult = await ApiErrorHandler.call(
      () => _fetchBrandQuotingCount(),
      showError: false,
    );

    final lifetimeResult = await ApiErrorHandler.call(
      () => _brandDashboardService.fetchLifetimeSummary(),
      showError: false,
    );

    if (activeJobsResult.isSuccess && activeJobsResult.data != null) {
      final items = activeJobsResult.data!.items;
      final total = activeJobsResult.data!.total > 0
          ? activeJobsResult.data!.total
          : items.length;

      current = current.copyWith(
        activeJobs: total,
        jobsInProgress: _mapJobs(items),
      );
    }

    if (quotingCountResult.isSuccess && quotingCountResult.data != null) {
      current = current.copyWith(newOffers: quotingCountResult.data!);
    }

    if (lifetimeResult.isSuccess && lifetimeResult.data != null) {
      current = _applyLifetimeSummary(current, lifetimeResult.data!);
    }

    dashboard.value = current;
  }

  Future<void> _loadAgencyDashboard() async {
    var current = dashboard.value;

    final summaryResult = await ApiErrorHandler.call(
      () => _agencyDashboardService.fetchSummary(),
      showError: false,
    );

    final workInProgressResult = await ApiErrorHandler.call(
      () => _agencyDashboardService.fetchWorkInProgress(page: 1, limit: 3),
      showError: false,
    );

    final lifetimeResult = await ApiErrorHandler.call(
      () => _agencyDashboardService.fetchLifetimeSummary(),
      showError: false,
    );

    if (summaryResult.isSuccess && summaryResult.data != null) {
      current = _applyAgencySummary(current, summaryResult.data!);
    }

    if (workInProgressResult.isSuccess && workInProgressResult.data != null) {
      if (workInProgressResult.data!.items.isNotEmpty) {
        current = current.copyWith(
          jobsInProgress: _mapJobs(workInProgressResult.data!.items),
        );
      }
    }

    if (lifetimeResult.isSuccess && lifetimeResult.data != null) {
      current = _applyLifetimeSummary(current, lifetimeResult.data!);
    }

    dashboard.value = current;
  }

  Future<void> _loadInfluencerDashboard() async {
    var current = dashboard.value;

    final summaryResult = await ApiErrorHandler.call(
      () => _influencerDashboardService.fetchSummary(),
      showError: false,
    );

    final workInProgressResult = await ApiErrorHandler.call(
      () => _influencerDashboardService.fetchWorkInProgress(page: 1, limit: 3),
      showError: false,
    );

    final lifetimeResult = await ApiErrorHandler.call(
      () => _influencerDashboardService.fetchLifetimeSummary(),
      showError: false,
    );

    if (summaryResult.isSuccess && summaryResult.data != null) {
      current = _applyInfluencerSummary(current, summaryResult.data!);
    }

    if (workInProgressResult.isSuccess && workInProgressResult.data != null) {
      if (workInProgressResult.data!.items.isNotEmpty) {
        current = current.copyWith(
          jobsInProgress: _mapJobs(workInProgressResult.data!.items),
        );
      }
    }

    if (lifetimeResult.isSuccess && lifetimeResult.data != null) {
      current = _applyLifetimeSummary(current, lifetimeResult.data!);
    }

    dashboard.value = current;
  }

  CampaignType _parseCampaignType(String? raw) {
    final v = (raw ?? '').trim().toLowerCase();
    if (v == 'paid_ad' || v == 'paidad' || v == 'paid-ad') {
      return CampaignType.paidAd;
    }
    return CampaignType.influencerPromotion;
  }

  List<JobItem> _mapJobs(List<Map<String, dynamic>> items) {
    return items.map((json) {
      final id = _stringFrom(json, [
        'jobId',
        'campaignId',
        'id',
        'assignmentId',
      ]);
      final title = _stringFrom(json, [
        'campaignName',
        'campaignTitle',
        'title',
        'jobName',
      ]);
      final rawCampaignType = _stringFrom(json, [
        'campaignType',
        'type',
        'subTitle',
      ]);
      final parsedCampaignType = _parseCampaignType(rawCampaignType);

      final subTitleTrKey =
          parsedCampaignType == CampaignType.influencerPromotion
          ? 'create_campaign_type_influencer_title'
          : 'create_campaign_type_paid_title';
      final assignedToName = json['assignedTo'] == null
          ? json['brandName'] ?? '—'
          : _formatAssignedTo(json['assignedTo']);
      final clientName = assignedToName ?? '—';

      final budget =
          _doubleFrom(json['budget']) ??
          _doubleFrom(json['amount']) ??
          _doubleFrom(json['totalBudget']) ??
          _doubleFrom(json['totalAmount']) ??
          _doubleFrom(json['price']) ??
          0.0;

      final sharePercent =
          _intFrom(json['sharePercent']) ?? _intFrom(json['serviceFee']) ?? 0;
      final progressPercent =
          _intFrom(json['progress']) ??
          _intFrom(json['progressPercent']) ??
          _intFrom(json['completion']) ??
          0;

      final displayDate = _parseDate(
        json['startedAt'] ??
            json['startingDate'] ??
            json['startDate'] ??
            json['date'] ??
            json['createdAt'] ??
            json['deadline'] ??
            json['dueDate'],
      );
      final duration = _intFrom(json['duration']);
      final dueDate = displayDate?.add(Duration(days: duration ?? 0));
      final dueInDays = _daysUntil(dueDate);

      final dateLabel =
          _stringFrom(json, ['dateLabel', 'deadlineLabel']) ??
          _formatDate(displayDate);

      return JobItem(
        id: id,
        title: title ?? '—',
        subTitle: subTitleTrKey,
        clientName: clientName ?? '—',
        campaignType: parsedCampaignType,
        dateLabel: dateLabel ?? '—',
        budget: budget,
        sharePercent: sharePercent,
        progressPercent: progressPercent,
        dueInDays: dueInDays,
        dueLabel: dueInDays.toString(),
      );
    }).toList();
  }

  Future<int> _fetchBrandQuotingCount() async {
    final res = await _apiClient.dio.get(
      '/campaign/my-campaigns',
      queryParameters: {'status': 'quoting', 'page': 1, 'limit': 1},
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) return 0;

    final meta = data['meta'];
    if (meta is Map<String, dynamic>) {
      final total = meta['total'];
      if (total is int) return total;
      if (total is num) return total.toInt();
      if (total is String) return int.tryParse(total) ?? 0;
    }

    return 0;
  }

  void openJobDetails(JobItem job) {
    if (_accountTypeService.isBrand) {
      Get.toNamed(AppRoutes.brandCampaignDetails, id: 1, arguments: job);
      return;
    }
    Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: job);
  }

  void openJobsTabByIndex(int targetTab) {
    Get.find<BottomNavController>().onTabChanged(1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<JobsController>()) {
        Get.find<JobsController>().setTabFromExternal(targetTab);
      }
    });
  }

  void openJobsTab({required bool isActiveJobs}) {
    final accountTypeService = Get.find<AccountTypeService>();

    final targetTab = isActiveJobs
        ? (accountTypeService.isBrand ? 0 : 1)
        : (accountTypeService.isBrand ? 1 : 0);

    openJobsTabByIndex(targetTab);
  }

  void openCompletedJobs() {
    final accountTypeService = Get.find<AccountTypeService>();
    final targetTab = accountTypeService.isBrand ? 2 : 2;
    openJobsTabByIndex(targetTab);
  }

  void openDeclinedJobs() {
    final accountTypeService = Get.find<AccountTypeService>();
    final targetTab = accountTypeService.isBrand ? 4 : 4;
    openJobsTabByIndex(targetTab);
  }

  void openEarningsPage() {
    // Replace this index if your earnings tab is in a different bottom-nav position.
    const earningsTabIndex = 2;
    Get.find<BottomNavController>().onTabChanged(earningsTabIndex);
  }

  HomeDashboardModel _applyLifetimeSummary(
    HomeDashboardModel current,
    Map<String, dynamic> json,
  ) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final topEntity = _extractTopLifetimeEntity(data);

    final topName = _stringFrom(topEntity ?? const {}, ['name']);
    final topJobs = _intFrom(
      topEntity?['jobsCompleted'] ??
          topEntity?['totalJobsCompleted'] ??
          data['topInfluencerJobsCompleted'] ??
          data['topClientJobsCompleted'] ??
          data['topJobsCompleted'],
    );

    final completedJobs = _intFrom(
      data['totalCompleted'] ??
          data['totalCompletedJobs'] ??
          data['completedJobs'] ??
          data['totalJobsCompleted'],
    );

    final declinedJobs = _intFrom(
      data['totalDeclined'] ??
          data['totalDeclinedJobs'] ??
          data['declinedJobs'] ??
          data['totalJobsDeclined'],
    );

    final totalEarnings = _doubleFrom(
      data['totalSpent'] ?? data['totalEarnings'] ?? data['lifetimeEarnings'],
    );

    final platform = _stringFrom(data, ['mostUsedPlatform', 'topPlatform']);

    final rawLastCompletedDate =
        topEntity?['lastCompletedJob']?['completedAt'] ??
        topEntity?['lastCompletedJobDate'];

    final formattedLastCompletedDate = _formatLifetimeSummaryDate(
      _parseDate(rawLastCompletedDate),
    );

    return current.copyWith(
      topClientName: topName != null && topName.isNotEmpty
          ? topName
          : current.topClientName,
      topClientJobsCompleted: topJobs ?? current.topClientJobsCompleted,
      totalJobsCompleted: completedJobs ?? current.totalJobsCompleted,
      totalJobsDeclined: declinedJobs ?? current.totalJobsDeclined,
      totalEarningsK: totalEarnings != null
          ? _toThousands(totalEarnings)
          : current.totalEarningsK,
      mostUsedPlatform: platform != null && platform.isNotEmpty
          ? platform
          : current.mostUsedPlatform,
      lastCompletedJobDateLabel: formattedLastCompletedDate,
    );
  }

  Map<String, dynamic>? _extractTopLifetimeEntity(Map<String, dynamic> data) {
    final topClient = data['topClient'];
    if (topClient is Map<String, dynamic>) return topClient;

    if (topClient is Map) {
      return Map<String, dynamic>.from(topClient);
    }

    final topInfluencer = data['topInfluencer'];
    if (topInfluencer is Map<String, dynamic>) return topInfluencer;

    if (topInfluencer is Map) {
      return Map<String, dynamic>.from(topInfluencer);
    }

    return null;
  }

  String _formatLifetimeSummaryDate(DateTime? date) {
    return DateFormatter.format(
      date: date,
      pattern: 'dd MMM yyyy',
      fallback: '-',
    );
  }

  HomeDashboardModel _applyAgencySummary(
    HomeDashboardModel current,
    Map<String, dynamic> json,
  ) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final lifetime = _doubleFrom(data['lifetimeEarnings']);
    final pending = _doubleFrom(data['pendingEarnings']);
    final active = _intFrom(data['activeJobs']);
    final offers = _intFrom(data['newOffers'] ?? data['newOffersCount']);

    return current.copyWith(
      lifetimeEarnings: lifetime?.round() ?? current.lifetimeEarnings,
      pendingEarnings: pending?.round() ?? current.pendingEarnings,
      activeJobs: active ?? current.activeJobs,
      newOffers: offers ?? current.newOffers,
    );
  }

  HomeDashboardModel _applyInfluencerSummary(
    HomeDashboardModel current,
    Map<String, dynamic> json,
  ) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final lifetime = _doubleFrom(
      data['lifetimeEarnings'] ?? data['totalEarnings'],
    );
    final pending = _doubleFrom(data['pendingEarnings']);
    final active = _intFrom(data['activeJobs'] ?? data['ongoingJobs']);
    final offers = _intFrom(data['newOffers'] ?? data['newOffersCount']);

    return current.copyWith(
      lifetimeEarnings: lifetime?.round() ?? current.lifetimeEarnings,
      pendingEarnings: pending?.round() ?? current.pendingEarnings,
      activeJobs: active ?? current.activeJobs,
      newOffers: offers ?? current.newOffers,
    );
  }

  int? _extractCount(Map<String, dynamic> json) {
    if (json['count'] is int) return json['count'] as int;
    if (json['total'] is int) return json['total'] as int;
    final data = json['data'];
    if (data is List) return data.length;
    if (data is Map && data['count'] is int) return data['count'] as int;
    return null;
  }

  bool _hasNewOffersField(Map<String, dynamic> json) {
    if (json.containsKey('newOffers') || json.containsKey('newOffersCount')) {
      return true;
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data.containsKey('newOffers') ||
          data.containsKey('newOffersCount');
    }

    return false;
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _doubleFrom(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? _stringFrom(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  String _formatAssignedTo(List<dynamic> assigned) {
    if (assigned.isEmpty) return '—';
    final names = assigned
        .map((e) => (e as Map?)?['name']?.toString() ?? '')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (names.isEmpty) return '—';
    if (names.length == 1) return names.first;
    return '${names.first}, +${names.length - 1}';
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  int? _daysUntil(DateTime? date) {
    if (date == null) return null;
    final diff = date.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;

    return DateFormatter.format(
      date: date,
      pattern: 'MMM dd, yyyy',
      fallback: '-',
    );
  }

  int _toThousands(double amount) {
    final value = amount / 1000;
    return value.round();
  }
}
