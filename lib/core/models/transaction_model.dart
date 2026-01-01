enum TransactionType { inbound, outbound }

class TransactionModel {
  /// Localized UI title
  final String titleKey; // e.g. 'earnings_payment_for'
  final Map<String, String> titleParams;

  /// Date/time label
  final String subtitle; // e.g. 'Today, 2:30 PM'

  /// Amount as number (sortable)
  final int amount;

  final TransactionType type;

  /// Right side label key
  final String detailsKey; // e.g. 'analytics_view_campaign_details'

  /// Search helper (campaign name / keywords)
  final String searchText;

  const TransactionModel({
    required this.titleKey,
    this.titleParams = const {},
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.detailsKey,
    required this.searchText,
  });
}
