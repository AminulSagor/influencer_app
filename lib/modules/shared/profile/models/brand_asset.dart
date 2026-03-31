import 'package:flutter/material.dart';

class BrandAssetItem {
  final String platform;
  final TextEditingController controller;

  BrandAssetItem({required this.platform, required this.controller});

  String get platformKey {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'brand_platform_facebook';
      case 'instagram':
        return 'brand_platform_instagram';
      case 'tiktok':
        return 'brand_platform_tiktok';
      case 'youtube':
        return 'brand_platform_youtube';
      case 'x':
      case 'twitter':
        return 'brand_platform_x';
      case 'linkedin':
        return 'brand_platform_linkedin';
      case 'website':
        return 'brand_platform_website';
      default:
        return platform;
    }
  }
}
