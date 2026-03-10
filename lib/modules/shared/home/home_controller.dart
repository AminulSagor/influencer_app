import 'package:get/get.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_dashboard_service.dart';
import 'package:influencer_app/modules/brand/services/brand_dashboard_service.dart';
import 'package:influencer_app/modules/influencer/services/influencer_dashboard_service.dart';
import 'package:influencer_app/routes/app_routes.dart';
import 'models/home_dashboard_model.dart';

class HomeController extends GetxController {
  final _accountTypeService = Get.find<AccountTypeService>();
  final _brandDashboardService = Get.find<BrandDashboardService>();
  final _agencyDashboardService = Get.find<AgencyDashboardService>();
  final _influencerDashboardService = Get.find<InfluencerDashboardService>();

  final dashboard = HomeDashboardModel.empty().obs;

  @override
  void onInit() {
    super.onInit();
    final userType = _resolveUserType();
    dashboard.value = HomeDashboardModel.empty(userType: userType);
    if (_accountTypeService.isBrand) {
      _loadBrandDashboard();
    } else if (_accountTypeService.isAdAgency) {
      _loadAgencyDashboard();
    } else if (_accountTypeService.isInfluencer) {
      _loadInfluencerDashboard();
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
      () => _brandDashboardService.fetchActiveJobs(page: 1, limit: 5),
      showError: false,
    );

    final upcomingResult = await ApiErrorHandler.call(
      () => _brandDashboardService.fetchUpcomingDeadlines(limit: 5),
      showError: false,
    );

    final actionRequiredResult = await ApiErrorHandler.call(
      () => _brandDashboardService.fetchActionRequired(),
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

    if (upcomingResult.isSuccess && upcomingResult.data != null) {
      if (upcomingResult.data!.isNotEmpty) {
        current = current.copyWith(
          jobsInProgress: _mapJobs(upcomingResult.data!),
        );
      }
    }

    if (actionRequiredResult.isSuccess && actionRequiredResult.data != null) {
      final count = _extractCount(actionRequiredResult.data!);
      if (count != null) {
        current = current.copyWith(newOffers: count);
      }
    }

    if (lifetimeResult.isSuccess && lifetimeResult.data != null) {
      current = _applyLifetimeSummary(current, lifetimeResult.data!);
    }

    dashboard.value = current;
  }

  Future<void> _loadAgencyDashboard() async {
    var current = dashboard.value;
    var summaryIncludesOffers = false;

    final summaryResult = await ApiErrorHandler.call(
      () => _agencyDashboardService.fetchSummary(),
      showError: false,
    );

    final actionRequiredResult = await ApiErrorHandler.call(
      () => _agencyDashboardService.fetchActionRequired(page: 1, limit: 5),
      showError: false,
    );

    final deadlinesResult = await ApiErrorHandler.call(
      () => _agencyDashboardService.fetchUpcomingDeadlines(page: 1, limit: 5),
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
      summaryIncludesOffers = _hasNewOffersField(summaryResult.data!);
      current = _applyAgencySummary(current, summaryResult.data!);
    }

    if (actionRequiredResult.isSuccess && actionRequiredResult.data != null) {
      final count = actionRequiredResult.data!.total > 0
          ? actionRequiredResult.data!.total
          : actionRequiredResult.data!.items.length;
      if (!summaryIncludesOffers && count > 0 && current.newOffers == 0) {
        current = current.copyWith(newOffers: count);
      }
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

    if (current.jobsInProgress.isEmpty &&
        deadlinesResult.isSuccess &&
        deadlinesResult.data != null &&
        deadlinesResult.data!.items.isNotEmpty) {
      current = current.copyWith(
        jobsInProgress: _mapJobs(deadlinesResult.data!.items),
      );
    }

    dashboard.value = current;
  }

  Future<void> _loadInfluencerDashboard() async {
    var current = dashboard.value;
    var summaryIncludesOffers = false;

    final summaryResult = await ApiErrorHandler.call(
      () => _influencerDashboardService.fetchSummary(),
      showError: false,
    );

    final actionRequiredResult = await ApiErrorHandler.call(
      () => _influencerDashboardService.fetchActionRequired(page: 1, limit: 5),
      showError: false,
    );

    final deadlinesResult = await ApiErrorHandler.call(
      () =>
          _influencerDashboardService.fetchUpcomingDeadlines(page: 1, limit: 5),
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
      summaryIncludesOffers = _hasNewOffersField(summaryResult.data!);
      current = _applyInfluencerSummary(current, summaryResult.data!);
    }

    if (actionRequiredResult.isSuccess && actionRequiredResult.data != null) {
      final count = actionRequiredResult.data!.total > 0
          ? actionRequiredResult.data!.total
          : actionRequiredResult.data!.items.length;
      if (!summaryIncludesOffers && count > 0 && current.newOffers == 0) {
        current = current.copyWith(newOffers: count);
      }
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

    if (current.jobsInProgress.isEmpty &&
        deadlinesResult.isSuccess &&
        deadlinesResult.data != null &&
        deadlinesResult.data!.items.isNotEmpty) {
      current = current.copyWith(
        jobsInProgress: _mapJobs(deadlinesResult.data!.items),
      );
    }

    dashboard.value = current;
  }

  List<JobItem> _mapJobs(List<Map<String, dynamic>> items) {
    return items.map((json) {
      final id = _stringFrom(json, [
        'campaignId',
        'id',
        'jobId',
        'assignmentId',
      ]);
      final title = _stringFrom(json, [
        'campaignName',
        'campaignTitle',
        'title',
        'jobName',
      ]);
      final subTitle = _stringFrom(json, ['campaignType', 'type', 'subTitle']);
      final assignedToName = _assignedToLabel(json['assignedTo']);
      final clientName =
          assignedToName ??
          _stringFrom(json, [
            'clientName',
            'brandName',
            'influencerName',
            'name',
          ]);

      final budget =
          _doubleFrom(json['budget']) ??
          _doubleFrom(json['amount']) ??
          _doubleFrom(json['totalBudget']) ??
          _doubleFrom(json['price']) ??
          0.0;

      final sharePercent =
          _intFrom(json['sharePercent']) ?? _intFrom(json['serviceFee']) ?? 0;
      final progressPercent =
          _intFrom(json['progress']) ??
          _intFrom(json['progressPercent']) ??
          _intFrom(json['completion']) ??
          0;

      final dueDate = _parseDate(json['deadline'] ?? json['dueDate']);
      final displayDate = _parseDate(
        json['startedAt'] ??
            json['startingDate'] ??
            json['startDate'] ??
            json['date'] ??
            json['createdAt'] ??
            json['deadline'] ??
            json['dueDate'],
      );

      final dueInDays = _intFrom(json['dueInDays']) ?? _daysUntil(dueDate);

      final dateLabel =
          _stringFrom(json, ['dateLabel', 'deadlineLabel']) ??
          _formatDate(displayDate);

      return JobItem(
        id: id,
        title: title ?? '—',
        subTitle: subTitle,
        clientName: clientName ?? '—',
        campaignType: CampaignType.paidAd,
        dateLabel: dateLabel ?? '—',
        budget: budget,
        sharePercent: sharePercent,
        progressPercent: progressPercent,
        dueInDays: dueInDays,
      );
    }).toList();
  }

  void openJobDetails(JobItem job) {
    if (_accountTypeService.isBrand) {
      Get.toNamed(AppRoutes.brandCampaignDetails, id: 1, arguments: job);
      return;
    }
    Get.toNamed(AppRoutes.campaignDetails, id: 1, arguments: job);
  }

  HomeDashboardModel _applyLifetimeSummary(
    HomeDashboardModel current,
    Map<String, dynamic> json,
  ) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final topName = _stringFrom(data, [
      'topInfluencer',
      'topInfluencerName',
      'topClientName',
      'topClient',
    ]);
    final topJobs = _intFrom(
      data['topInfluencerJobsCompleted'] ??
          data['topClientJobsCompleted'] ??
          data['topJobsCompleted'],
    );

    final completedJobs = _intFrom(
      data['totalCompletedJobs'] ??
          data['completedJobs'] ??
          data['totalJobsCompleted'],
    );

    final declinedJobs = _intFrom(
      data['totalDeclinedJobs'] ??
          data['declinedJobs'] ??
          data['totalJobsDeclined'],
    );

    final totalEarnings = _doubleFrom(
      data['totalSpent'] ?? data['totalEarnings'] ?? data['lifetimeEarnings'],
    );

    final platform = _stringFrom(data, ['mostUsedPlatform', 'topPlatform']);

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

  String? _assignedToLabel(dynamic value) {
    if (value is! List || value.isEmpty) return null;

    final names = <String>[];
    for (final item in value) {
      if (item is Map) {
        final name = item['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          names.add(name);
        }
        continue;
      }

      if (item is String) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) {
          names.add(trimmed);
        }
      }
    }

    if (names.isEmpty) return null;
    return names.join(', ');
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[date.month - 1];
    return '$m ${date.day}, ${date.year}';
  }

  int _toThousands(double amount) {
    final value = amount / 1000;
    return value.round();
  }
}
