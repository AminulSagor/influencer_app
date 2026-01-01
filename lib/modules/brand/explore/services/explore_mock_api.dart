import 'dart:async';
import 'package:flutter/material.dart';
import '../models/explore_item.dart';

class ExploreMockApi {
  static const int _pageSize = 10;

  Future<ExplorePagedResponse> fetch({
    required ExploreType type,
    required String query,
    required int page, // 1-based
  }) async {
    await Future.delayed(const Duration(milliseconds: 700)); // mock loading

    final all = _seed(type);

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((e) {
            return e.name.toLowerCase().contains(q) ||
                e.subtitle.toLowerCase().contains(q);
          }).toList();

    final total = filtered.length;
    final totalPages = (total / _pageSize).ceil().clamp(1, 999);

    final safePage = page.clamp(1, totalPages);
    final start = (safePage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);

    final items = filtered.sublist(start, end);

    return ExplorePagedResponse(
      items: items,
      totalResults: total,
      totalPages: totalPages,
    );
  }

  List<ExploreItem> _seed(ExploreType type) {
    if (type == ExploreType.influencer) {
      const names = [
        'Hania Amir',
        'Salman Muktadir',
        'Rafsan The Chotobhai',
        'Nadir On The Go',
        'Nafis',
        'Mehjabin Chowdhury',
        'Tahsan Rahman',
        'Tawsif Mahbub',
        'Pori Moni',
        'Ayman Sadiq',
        'Sadman Sadik',
        'Raba Khan',
        'Ziaul Hoque Polash',
        'Mithila',
        'Shakib Khan',
        'Nusrat Faria',
        'Siam Ahmed',
        'Apurbo',
        'Sabila Nur',
        'Sunerah',
        'Farhan Ahmed Jovan',
        'Tanjin Tisha',
        'Tasnia Farin',
        'Riaz',
        'Moushumi',
        'Arefin Shuvo',
        'Sohana Saba',
        'Marzuk Russell',
        'Ayman & Team',
        'Tech Rider BD',
      ];

      return List.generate(names.length, (i) {
        final r = 3.5 + ((i % 5) * 0.3); // 3.5..4.7
        return ExploreItem(
          id: 'inf_$i',
          type: type,
          name: names[i],
          subtitle: (i % 2 == 0)
              ? 'Content Creator, Fashion'
              : 'Content Creator, Product Promo',
          rating: r.clamp(0, 5),
          icons: const [
            Icons.facebook_rounded,
            Icons.camera_alt_rounded, // insta-like
            Icons.play_circle_fill_rounded, // youtube-like
            Icons.music_note_rounded, // tiktok-like
          ],
        );
      });
    }

    // Ad Agencies
    return List.generate(30, (i) {
      final name = (i % 3 == 0) ? 'Trendy Ad' : 'Boosting Page';
      final r = 3.8 + ((i % 4) * 0.25);
      return ExploreItem(
        id: 'ag_$i',
        type: type,
        name: name,
        subtitle: 'Boosting Page',
        rating: r.clamp(0, 5),
        icons: const [
          Icons.facebook_rounded,
          Icons.camera_alt_rounded,
          Icons.public_rounded,
        ],
      );
    });
  }
}
