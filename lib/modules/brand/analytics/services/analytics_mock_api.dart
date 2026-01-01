import 'dart:async';
import '../../../../core/models/transaction_model.dart';
import '../models/analytics_models.dart';

class AnalyticsMockApi {
  // mock master lists (100)
  final List<InfluencerRowModel> _allInfluencers = List.generate(100, (i) {
    final names = [
      'Hania Amir',
      'Salman Khan',
      'John Smith',
      'Steve Jobs',
      'Nadir On The Go',
      'Rafsan The Chotobhai',
      'Nafis',
      'Salman Muktadir',
      'Trendy Ad',
      'Grow Big',
    ];
    final name = names[i % names.length];
    return InfluencerRowModel(name: name, campaignDone: (i % 13) + 1);
  });

  final List<TransactionModel> _allTx = List.generate(100, (i) {
    final campaigns = [
      'Summer Sale',
      'Nike Air Max',
      'Winter Blast',
      'Eid Offer',
      'Flash Deal',
    ];
    final c = campaigns[i % campaigns.length];

    final inbound = i.isEven;
    final amount = 10000 + (i % 20) * 1000;

    return TransactionModel(
      titleKey: inbound
          ? 'earnings_payment_for'
          : 'earnings_withdrawal_request',
      titleParams: inbound ? {'name': c} : const {},
      subtitle: 'Today, 2:${10 + (i % 40)} PM',
      amount: amount,
      type: inbound ? TransactionType.inbound : TransactionType.outbound,
      detailsKey: 'analytics_view_campaign_details',
      searchText: '$c ${inbound ? "payment" : "withdrawal"}',
    );
  });

  Future<List<InfluencerRowModel>> fetchInfluencers({
    required int page,
    required int pageSize,
    required String query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));

    final filtered = _filterInfluencers(query);
    return _paginate(filtered, page, pageSize);
  }

  Future<List<TransactionModel>> fetchTransactions({
    required int page,
    required int pageSize,
    required String query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));
    final filtered = _filterTx(query);
    return _paginate(filtered, page, pageSize);
  }

  List<PlatformStatModel> getPlatformStats() {
    return [
      PlatformStatModel(
        platformName: 'Facebook',
        jobsCompleted: 34,
        iconAsset: 'assets/icons/facebook.png',
      ),
      PlatformStatModel(
        platformName: 'Instagram',
        jobsCompleted: 23,
        iconAsset: 'assets/icons/instagram.png',
      ),
      PlatformStatModel(
        platformName: 'Youtube',
        jobsCompleted: 12,
        iconAsset: 'assets/icons/youTube.png',
      ),
      PlatformStatModel(
        platformName: 'Tiktok',
        jobsCompleted: 7,
        iconAsset: 'assets/icons/tikTok.png',
      ),
    ];
  }

  List<InfluencerRowModel> _filterInfluencers(String query) {
    if (query.isEmpty) return _allInfluencers;
    final q = query.toLowerCase();
    return _allInfluencers
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
  }

  List<TransactionModel> _filterTx(String query) {
    if (query.isEmpty) return _allTx;
    final q = query.toLowerCase();
    return _allTx.where((e) => e.searchText.toLowerCase().contains(q)).toList();
  }

  List<T> _paginate<T>(List<T> list, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }
}
