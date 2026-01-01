import 'package:flutter/material.dart';

enum BrandHandlePlatform {
  facebook,
  instagram,
  tiktok,
  youtube,
  x,
  linkedin,
  website,
}

class BrandAssetItem {
  final BrandHandlePlatform platform;
  final TextEditingController controller;

  BrandAssetItem({required this.platform, required this.controller});

  String get platformKey {
    switch (platform) {
      case BrandHandlePlatform.facebook:
        return 'brand_platform_facebook';
      case BrandHandlePlatform.instagram:
        return 'brand_platform_instagram';
      case BrandHandlePlatform.tiktok:
        return 'brand_platform_tiktok';
      case BrandHandlePlatform.youtube:
        return 'brand_platform_youtube';
      case BrandHandlePlatform.x:
        return 'brand_platform_x';
      case BrandHandlePlatform.linkedin:
        return 'brand_platform_linkedin';
      case BrandHandlePlatform.website:
        return 'brand_platform_website';
    }
  }
}
