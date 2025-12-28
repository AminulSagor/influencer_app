// report_model.dart
enum ReportStatus { flagged, pending, resolved }

class ReportModel {
  final String id;
  final String campaignName;
  final String milestone; // e.g., "Milestone 1"
  final String timeAgo;
  final String message;
  final String companyName;
  final String date;
  final ReportStatus status;

  ReportModel({
    required this.id,
    required this.campaignName,
    required this.milestone,
    required this.timeAgo,
    required this.message,
    required this.companyName,
    required this.date,
    required this.status,
  });
}
