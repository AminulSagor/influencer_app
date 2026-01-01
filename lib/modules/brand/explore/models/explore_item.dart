import 'package:flutter/material.dart';

enum ExploreType { influencer, adAgency }

class ExploreItem {
  final String id;
  final ExploreType type;
  final String name;
  final String subtitle;
  final double rating; // 0..5
  final List<IconData> icons; // small social icons

  const ExploreItem({
    required this.id,
    required this.type,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.icons,
  });
}

class ExplorePagedResponse {
  final List<ExploreItem> items;
  final int totalResults;
  final int totalPages;

  const ExplorePagedResponse({
    required this.items,
    required this.totalResults,
    required this.totalPages,
  });
}
