// lib/core/models/job_item.dart

class JobItem {
  final String title;
  final String clientName;
  final String dateLabel;
  final double budget;
  final int sharePercent;

  final int? progressPercent;
  final String? dueLabel;

  final int? rating;

  final String? profitLabel;
  final String? vatLabel;
  final String? totalCostLabel;
  final String? totalEarningsLabel;
  final List<Milestone>? milestones;

  const JobItem({
    required this.title,
    required this.clientName,
    required this.dateLabel,
    required this.budget,
    required this.sharePercent,
    this.progressPercent,
    this.dueLabel,
    this.rating,
    this.profitLabel,
    this.totalCostLabel,
    this.vatLabel,
    this.totalEarningsLabel,
    this.milestones,
  });
}

// ---------------- MILSTONE + SUBMISSION MODELS ----------------

enum MilestoneStatus { todo, inReview, paid, partialPaid, declined }

enum SubmissionStatus { inReview, approved, declined }

class Submission {
  final int index;
  final String description;
  final int amount; // in your main currency unit
  final String liveLink;
  final String metricLabel;
  final String metricValue;
  final List<String> proofPaths; // local paths / urls to files
  final SubmissionStatus status;

  const Submission({
    required this.index,
    required this.description,
    required this.amount,
    required this.liveLink,
    required this.metricLabel,
    required this.metricValue,
    required this.proofPaths,
    required this.status,
  });

  Submission copyWith({
    int? index,
    String? description,
    int? amount,
    String? liveLink,
    String? metricLabel,
    String? metricValue,
    List<String>? proofPaths,
    SubmissionStatus? status,
  }) {
    return Submission(
      index: index ?? this.index,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      liveLink: liveLink ?? this.liveLink,
      metricLabel: metricLabel ?? this.metricLabel,
      metricValue: metricValue ?? this.metricValue,
      proofPaths: proofPaths ?? this.proofPaths,
      status: status ?? this.status,
    );
  }
}

class Milestone {
  final String stepLabel;
  final String title;
  final String? subtitle;
  final String amountLabel; // e.g. "৳3,000"
  final String? dayLabel;
  final MilestoneStatus status;
  final List<Submission> submissions;

  const Milestone({
    required this.stepLabel,
    required this.title,
    this.subtitle,
    required this.amountLabel,
    this.dayLabel,
    this.status = MilestoneStatus.todo,
    this.submissions = const [],
  });

  /// Used by main campaign page
  bool get isPaid =>
      status == MilestoneStatus.paid || status == MilestoneStatus.partialPaid;

  bool get isDeclined => status == MilestoneStatus.declined;

  int get declinedCount =>
      submissions.where((s) => s.status == SubmissionStatus.declined).length;

  int get approvedCount =>
      submissions.where((s) => s.status == SubmissionStatus.approved).length;

  int get totalSubmissions => submissions.length;

  /// Sum of approved amounts (for progress)
  int get approvedAmount => submissions
      .where((s) => s.status == SubmissionStatus.approved)
      .fold<int>(0, (sum, s) => sum + s.amount);

  Milestone copyWith({
    String? stepLabel,
    String? title,
    String? subtitle,
    String? amountLabel,
    String? dayLabel,
    MilestoneStatus? status,
    List<Submission>? submissions,
  }) {
    return Milestone(
      stepLabel: stepLabel ?? this.stepLabel,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amountLabel: amountLabel ?? this.amountLabel,
      dayLabel: dayLabel ?? this.dayLabel,
      status: status ?? this.status,
      submissions: submissions ?? this.submissions,
    );
  }
}
