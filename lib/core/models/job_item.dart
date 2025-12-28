// lib/core/models/job_item.dart

enum CampaignType { paidAd, influencerPromotion }

class JobItem {
  final String title;
  final String? subTitle;
  final String clientName;

  final CampaignType campaignType;

  /// Display date text (e.g. "Dec 15, 2025")
  final String dateLabel;

  final double budget;
  final int sharePercent;

  /// Used in Home "work in progress"
  final int? progressPercent;
  final String? dosText;
  final String? dontsText;

  /// If you want to compute due label from days in UI (better for localization)
  final int? dueInDays;

  /// Optional preformatted due label (fallback)
  final String? dueLabel;

  final int? rating;

  final String? profitLabel;
  final String? vatLabel;
  final String? totalCostLabel;
  final String? totalEarningsLabel;

  /// ---- NEW (optional) budget breakdown for Step 4 ----
  final double? baseBudget;
  final double? vatPercent;
  final double? vatAmount;
  final double? netPayableBudget;

  /// ---- NEW (optional) Step 5 ----
  final List<JobAsset>? contentAssets; // uploaded campaign contents
  final List<BrandAsset>? brandAssets; // paidAd: page links etc.
  final bool? needToSendSample; // influencerPromotion
  final bool? sampleGuidelinesConfirmed; // influencerPromotion

  final List<Milestone>? milestones;

  const JobItem({
    required this.title,
    required this.clientName,
    required this.dateLabel,
    required this.budget,
    required this.sharePercent,
    required this.campaignType,
    this.progressPercent,
    this.dueInDays,
    this.dueLabel,
    this.rating,
    this.profitLabel,
    this.totalCostLabel,
    this.vatLabel,
    this.totalEarningsLabel,
    this.baseBudget,
    this.vatPercent,
    this.vatAmount,
    this.netPayableBudget,
    this.contentAssets,
    this.brandAssets,
    this.needToSendSample,
    this.sampleGuidelinesConfirmed,
    this.milestones,
    this.subTitle,
    this.dosText,
    this.dontsText,
  });
}

/// ---------------- STEP 5 MODELS ----------------

enum JobAssetKind { image, video, document, other }

class JobAsset {
  final String title; // e.g. "Brand Logo Pack"
  final String meta; // e.g. "PNG, SVG - 2.4 MB"
  final JobAssetKind kind;

  /// local path or remote url (optional for now)
  final String? pathOrUrl;

  const JobAsset({
    required this.title,
    required this.meta,
    required this.kind,
    this.pathOrUrl,
  });

  JobAsset copyWith({
    String? title,
    String? meta,
    JobAssetKind? kind,
    String? pathOrUrl,
  }) {
    return JobAsset(
      title: title ?? this.title,
      meta: meta ?? this.meta,
      kind: kind ?? this.kind,
      pathOrUrl: pathOrUrl ?? this.pathOrUrl,
    );
  }
}

class BrandAsset {
  final String title; // e.g. "Facebook Page"
  final String? value; // e.g. page link
  const BrandAsset({required this.title, this.value});

  BrandAsset copyWith({String? title, String? value}) {
    return BrandAsset(title: title ?? this.title, value: value ?? this.value);
  }
}

// ---------------- MILESTONE + SUBMISSION MODELS ----------------

enum MilestoneStatus { todo, inReview, paid, approved, partialPaid, declined }

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

  /// ✅ NEW (optional) - for Milestone Details screen
  /// If provided, you can show full metrics (reach/views/likes/comments)
  final PromotionTarget? achieved;

  /// ✅ NEW (optional) - for Milestone Details screen
  /// e.g. "Dec 15, 2025"
  final String? submittedDateLabel;

  const Submission({
    required this.index,
    required this.description,
    required this.amount,
    required this.liveLink,
    required this.metricLabel,
    required this.metricValue,
    required this.proofPaths,
    required this.status,
    this.achieved,
    this.submittedDateLabel,
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

    /// ✅ NEW (optional)
    PromotionTarget? achieved,

    /// ✅ NEW (optional)
    String? submittedDateLabel,
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
      achieved: achieved ?? this.achieved,
      submittedDateLabel: submittedDateLabel ?? this.submittedDateLabel,
    );
  }
}

/// NEW: Promotion Target (optional)
class PromotionTarget {
  final int? reach;
  final int? views;
  final int? likes;
  final int? comments;

  const PromotionTarget({this.reach, this.views, this.likes, this.comments});

  PromotionTarget copyWith({
    int? reach,
    int? views,
    int? likes,
    int? comments,
  }) {
    return PromotionTarget(
      reach: reach ?? this.reach,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}

class Milestone {
  final String stepLabel;
  final String title;
  final String? subtitle;

  /// safe default so Step 4 can omit
  final String amountLabel;

  final String? dayLabel;

  /// NEW (optional) fields for Step 4
  final int? dayIndex;
  final String? platform;
  final String? deliverable;
  final PromotionTarget? targets;

  /// ✅ NEW (optional) - for Milestone Details screen
  /// e.g. ["Final Report", "2 Stories"]
  final List<String>? contentRequirements;

  /// ✅ NEW (optional) - for Milestone Details screen
  /// e.g. "Samira"
  final String? influencerName;

  final MilestoneStatus status;
  final List<Submission> submissions;

  const Milestone({
    required this.stepLabel,
    required this.title,
    this.subtitle,
    this.amountLabel = '',
    this.dayLabel,
    this.dayIndex,
    this.platform,
    this.deliverable,
    this.targets,

    /// ✅ NEW (optional)
    this.contentRequirements,

    /// ✅ NEW (optional)
    this.influencerName,

    this.status = MilestoneStatus.todo,
    this.submissions = const [],
  });

  bool get isPaid =>
      status == MilestoneStatus.paid || status == MilestoneStatus.partialPaid;

  bool get isApproved => status == MilestoneStatus.approved;
  bool get isDeclined => status == MilestoneStatus.declined;

  int get declinedCount =>
      submissions.where((s) => s.status == SubmissionStatus.declined).length;

  int get approvedCount =>
      submissions.where((s) => s.status == SubmissionStatus.approved).length;

  int get totalSubmissions => submissions.length;

  int get approvedAmount => submissions
      .where((s) => s.status == SubmissionStatus.approved)
      .fold<int>(0, (sum, s) => sum + s.amount);

  Milestone copyWith({
    String? stepLabel,
    String? title,
    String? subtitle,
    String? amountLabel,
    String? dayLabel,
    int? dayIndex,
    String? platform,
    String? deliverable,
    PromotionTarget? targets,

    /// ✅ NEW (optional)
    List<String>? contentRequirements,

    /// ✅ NEW (optional)
    String? influencerName,

    MilestoneStatus? status,
    List<Submission>? submissions,
  }) {
    return Milestone(
      stepLabel: stepLabel ?? this.stepLabel,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amountLabel: amountLabel ?? this.amountLabel,
      dayLabel: dayLabel ?? this.dayLabel,
      dayIndex: dayIndex ?? this.dayIndex,
      platform: platform ?? this.platform,
      deliverable: deliverable ?? this.deliverable,
      targets: targets ?? this.targets,
      contentRequirements: contentRequirements ?? this.contentRequirements,
      influencerName: influencerName ?? this.influencerName,
      status: status ?? this.status,
      submissions: submissions ?? this.submissions,
    );
  }
}
