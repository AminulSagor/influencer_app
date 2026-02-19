import 'package:get/get.dart';
import '../../../core/models/job_item.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';

class BrandMilestoneDetailsController extends GetxController {
  late final JobItem job;
  late final Milestone milestone;

  final ApiClient _apiClient = Get.find<ApiClient>();

  final selectedSubmissionIndex = 0.obs;
  final submissionStatus = SubmissionStatus.inReview.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      job = (args['job'] as JobItem);
      milestone = (args['milestone'] as Milestone);
    } else {
      // minimal fallback (won't crash)
      job = const JobItem(
        title: 'Campaign',
        clientName: 'Client',
        dateLabel: '—',
        budget: 0,
        sharePercent: 0,
        campaignType: CampaignType.influencerPromotion,
      );
      milestone = const Milestone(stepLabel: '1', title: 'Milestone');
    }

    _loadBrandMilestoneDetails();
  }

  Submission? get currentSubmission {
    if (milestone.submissions.isEmpty) {
      return null;
    }
    final i = selectedSubmissionIndex.value.clamp(
      0,
      milestone.submissions.length - 1,
    );
    return milestone.submissions[i];
  }

  List<String> get requirements {
    final r = milestone.contentRequirements;
    if (r != null && r.isNotEmpty) return r;

    // fallback: try from subtitle "A + B"
    final sub = (milestone.subtitle ?? '').trim();
    if (sub.contains('+')) {
      return sub
          .split('+')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (sub.isNotEmpty) return [sub];

    return const [];
  }

  PromotionTarget get targets => milestone.targets ?? const PromotionTarget();

  PromotionTarget get achieved =>
      currentSubmission?.achieved ?? const PromotionTarget();

  String get submittedDateLabel {
    final s = currentSubmission;
    if (s != null && (s.submittedDateLabel ?? '').trim().isNotEmpty) {
      return s.submittedDateLabel!.trim();
    }
    return job.dateLabel;
  }

  void reportAdmin() {
    Get.snackbar('Report', 'Reported to admin.');
  }

  Future<void> approve() async {
    final submissionId = currentSubmission?.id?.trim();
    if (submissionId == null || submissionId.isEmpty) {
      Get.snackbar('Missing data', 'Submission id not found.');
      return;
    }

    final ok = await _reviewClientSubmission(
      submissionId: submissionId,
      approve: true,
    );

    if (!ok) return;

    submissionStatus.value = SubmissionStatus.approved;
    Get.snackbar('Approved', 'Submission approved.');
  }

  Future<void> decline({String? reason}) async {
    final submissionId = currentSubmission?.id?.trim();
    if (submissionId == null || submissionId.isEmpty) {
      Get.snackbar('Missing data', 'Submission id not found.');
      return;
    }

    final ok = await _reviewClientSubmission(
      submissionId: submissionId,
      approve: false,
      reason: reason,
    );

    if (!ok) return;

    submissionStatus.value = SubmissionStatus.declined;
    Get.snackbar('Declined', 'Submission declined.');
  }

  Future<bool> _reviewClientSubmission({
    required String submissionId,
    required bool approve,
    String? reason,
  }) async {
    final payload = approve
        ? {'action': 'approve', 'report': 'Approved'}
        : {
            'action': 'decline',
            'reason': (reason ?? 'Declined by client.').trim(),
          };

    final result = await ApiErrorHandler.call(() {
      return _apiClient.dio.post(
        '/campaign/client/submission/$submissionId/review',
        data: payload,
      );
    });

    return result.isSuccess;
  }

  Future<void> _loadBrandMilestoneDetails() async {
    final milestoneId = milestone.id?.trim();
    if (milestoneId == null || milestoneId.isEmpty) {
      if (milestone.submissions.isNotEmpty) {
        submissionStatus.value = milestone.submissions.first.status;
      }
      return;
    }

    // Try milestone details first (may contain submissions)
    final milestoneDetails = await _fetchMilestoneDetails(milestoneId);
    if (milestoneDetails != null) {
      milestone = milestone.copyWith(
        id: milestoneDetails['id']?.toString() ?? milestone.id,
        title: milestoneDetails['contentTitle']?.toString() ?? milestone.title,
        platform:
            milestoneDetails['platform']?.toString() ?? milestone.platform,
        deliverable:
            milestoneDetails['contentQuantity']?.toString() ??
            milestone.deliverable,
        dayIndex:
            _intFrom(milestoneDetails['deliveryDays']) ?? milestone.dayIndex,
        amountLabel:
            _amountLabelFrom(milestoneDetails['amount']) ??
            milestone.amountLabel,
        targets: PromotionTarget(
          reach: _intFrom(milestoneDetails['expectedReach']),
          views: _intFrom(milestoneDetails['expectedViews']),
          likes: _intFrom(milestoneDetails['expectedLikes']),
          comments: _intFrom(milestoneDetails['expectedComments']),
        ),
        status: _parseMilestoneStatus(milestoneDetails['status']?.toString()),
      );
    }

    final submissionIds = await _fetchSubmissionIdsForMilestone(
      campaignId: job.id?.trim(),
      milestoneId: milestoneId,
      fallback: milestoneDetails,
    );

    if (submissionIds.isEmpty) {
      if (milestone.submissions.isNotEmpty) {
        submissionStatus.value = milestone.submissions.first.status;
      }
      return;
    }

    final List<Submission> mapped = [];
    int index = 1;
    for (final id in submissionIds) {
      final details = await _fetchClientSubmissionDetails(id);
      if (details == null) continue;

      mapped.add(_mapBrandSubmissionDetails(details, index, id));
      index++;
    }

    if (mapped.isNotEmpty) {
      milestone = milestone.copyWith(submissions: mapped);
      submissionStatus.value = mapped.first.status;
      selectedSubmissionIndex.value = 0;
    }
  }

  Future<Map<String, dynamic>?> _fetchMilestoneDetails(
    String milestoneId,
  ) async {
    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get('/campaign/milestone/$milestoneId');
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return null;
    final data = result.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    if (raw['id'] != null) return raw;
    if (raw['milestone'] is Map<String, dynamic>) {
      return raw['milestone'] as Map<String, dynamic>;
    }

    return null;
  }

  Future<List<String>> _fetchSubmissionIdsForMilestone({
    required String? campaignId,
    required String milestoneId,
    Map<String, dynamic>? fallback,
  }) async {
    final ids = <String>[];

    if (fallback != null && fallback['submissions'] is List) {
      for (final s in (fallback['submissions'] as List)) {
        if (s is Map && (s['id']?.toString() ?? '').trim().isNotEmpty) {
          ids.add(s['id'].toString());
        }
      }
    }

    if (ids.isNotEmpty || campaignId == null || campaignId.isEmpty) {
      return ids;
    }

    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get('/campaign/milestones/$campaignId');
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return ids;
    final data = result.data as Map<String, dynamic>;
    final list = data['data'] as List? ?? const [];

    for (final m in list) {
      if (m is! Map) continue;
      if ((m['id']?.toString() ?? '') != milestoneId) continue;
      final subs = m['submissions'] as List? ?? const [];
      for (final s in subs) {
        if (s is Map && (s['id']?.toString() ?? '').trim().isNotEmpty) {
          ids.add(s['id'].toString());
        }
      }
      break;
    }

    if (ids.isNotEmpty) return ids;

    final fallbackIds = await _fetchClientSubmissionIdsByMilestone(
      milestoneId: milestoneId,
    );
    ids.addAll(fallbackIds);
    return ids;
  }

  Future<List<String>> _fetchClientSubmissionIdsByMilestone({
    required String milestoneId,
  }) async {
    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get('/campaign/client/submissions');
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return const [];
    final data = result.data as Map<String, dynamic>;
    final list = data['data'] as List? ?? const [];

    final ids = <String>[];
    for (final item in list) {
      if (item is! Map) continue;
      final id = item['id']?.toString() ?? '';
      if (id.trim().isEmpty) continue;

      final mid = item['milestoneId']?.toString() ?? '';
      if (mid == milestoneId) {
        ids.add(id);
        continue;
      }

      final title = item['milestoneTitle']?.toString().trim() ?? '';
      if (title.isNotEmpty && title == milestone.title) {
        ids.add(id);
      }
    }

    return ids;
  }

  Future<Map<String, dynamic>?> _fetchClientSubmissionDetails(
    String submissionId,
  ) async {
    final result = await ApiErrorHandler.call(() async {
      final res = await _apiClient.dio.get(
        '/campaign/client/submissions/$submissionId',
      );
      return res.data;
    }, showError: false);

    if (!result.isSuccess || result.data == null) return null;
    final data = result.data as Map<String, dynamic>;
    final raw = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    return raw is Map<String, dynamic> ? raw : null;
  }

  Submission _mapBrandSubmissionDetails(
    Map<String, dynamic> json,
    int index,
    String id,
  ) {
    final metric = _preferredMetricValue(
      reach: _intFrom(json['achievedReach']),
      views: _intFrom(json['achievedViews']),
      likes: _intFrom(json['achievedLikes']),
      comments: _intFrom(json['achievedComments']),
    );

    return Submission(
      id: id,
      index: index,
      description: json['description']?.toString() ?? '',
      amount: _intFrom(json['amount']) ?? 0,
      liveLink: _firstString(json['liveLinks']) ?? '',
      metricLabel: metric.label,
      metricValue: metric.value.toString(),
      proofPaths: _stringList(json['attachments']),
      status: _parseSubmissionStatus(json['status']?.toString()),
      achieved: PromotionTarget(
        reach: _intFrom(json['achievedReach']),
        views: _intFrom(json['achievedViews']),
        likes: _intFrom(json['achievedLikes']),
        comments: _intFrom(json['achievedComments']),
      ),
      submittedDateLabel: json['createdAt']?.toString(),
    );
  }

  MilestoneStatus _parseMilestoneStatus(String? raw) {
    final v = (raw ?? '').toLowerCase();
    switch (v) {
      case 'in_review':
      case 'inreview':
        return MilestoneStatus.inReview;
      case 'paid':
        return MilestoneStatus.paid;
      case 'approved':
      case 'completed':
        return MilestoneStatus.approved;
      case 'partial_paid':
      case 'partialpaid':
        return MilestoneStatus.partialPaid;
      case 'declined':
        return MilestoneStatus.declined;
      case 'to_do':
      case 'todo':
      default:
        return MilestoneStatus.todo;
    }
  }

  SubmissionStatus _parseSubmissionStatus(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v.contains('declined') || v.contains('rejected')) {
      return SubmissionStatus.declined;
    }
    if (v.contains('approved') || v.contains('completed')) {
      return SubmissionStatus.approved;
    }
    return SubmissionStatus.inReview;
  }

  String _amountLabelFrom(dynamic value) {
    final v = _intFrom(value);
    if (v != null) return '৳$v';
    if (value is String && value.trim().isNotEmpty) return value;
    return '—';
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  String? _firstString(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first?.toString();
    }
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  _MetricValue _preferredMetricValue({
    int? reach,
    int? views,
    int? likes,
    int? comments,
  }) {
    if (reach != null && reach > 0) return _MetricValue('Reach', reach);
    if (views != null && views > 0) return _MetricValue('Views', views);
    if (likes != null && likes > 0) return _MetricValue('Likes', likes);
    if (comments != null && comments > 0) {
      return _MetricValue('Comments', comments);
    }
    return const _MetricValue('Reach', 0);
  }
}

class _MetricValue {
  final String label;
  final int value;

  const _MetricValue(this.label, this.value);
}
