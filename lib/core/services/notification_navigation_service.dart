import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:influencer_app/modules/shared/bottom_navbar/bottom_nav_controller.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:influencer_app/core/services/firebase_messaging_service.dart';
import 'package:influencer_app/core/services/token_service.dart';
import 'package:influencer_app/modules/brand/brand_campaign_details/brand_campaign_details_controller.dart';
import 'package:influencer_app/routes/app_routes.dart';

import '../../modules/shared/jobs/jobs_controller.dart';

class NotificationNavigationService extends GetxService {
  StreamSubscription<Map<String, dynamic>>? _tapSubscription;
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  Future<NotificationNavigationService> init() async {
    _tapSubscription = FirebaseMessagingService.notificationTapStream.listen(
      _handleTap,
    );

    _dataSubscription = FirebaseMessagingService.notificationStream.listen(
      _handleForegroundData,
    );

    return this;
  }

  Future<void> handlePendingTapAfterBootstrap() async {
    final pending = FirebaseMessagingService.consumePendingTapData();
    if (pending == null) return;

    await _waitForNestedNavigatorReady();
    await _handleTap(pending);
  }

  Future<void> _handleForegroundData(Map<String, dynamic> data) async {
    final type = data['type']?.toString().trim() ?? '';

    if (!_isInvitationType(type)) return;

    if (_isOnJobsPage() && Get.isRegistered<JobsController>()) {
      final jobsController = Get.find<JobsController>();
      await jobsController.refreshInvitationJobs();
    }
  }

  Future<void> _handleTap(Map<String, dynamic> data) async {
    final type = data['type']?.toString().trim() ?? '';
    final campaignId = data['campaignId']?.toString().trim() ?? '';
    final milestoneId = data['milestoneId']?.toString().trim() ?? '';
    final assignmentId = data['assignmentId']?.toString().trim() ?? '';

    if (_isInvitationType(type)) {
      await _waitForNestedNavigatorReady();

      if (_isOnJobsPage() && Get.isRegistered<JobsController>()) {
        final jobsController = Get.find<JobsController>();
        jobsController.setTabFromExternal(0);
        await jobsController.refreshInvitationJobs();
        return;
      }

      Get.find<BottomNavController>().onTabChanged(1);
      return;
    }

    final hasCampaignId = campaignId.isNotEmpty;
    final hasMilestoneId = milestoneId.isNotEmpty;

    if (!hasCampaignId && !hasMilestoneId) {
      return;
    }

    final isBrand = await _isBrandUser();

    await _goToBaseTab(isBrand: isBrand);

    if (hasCampaignId && hasMilestoneId) {
      await _openCampaignDetails(isBrand: isBrand, campaignId: campaignId);

      await Future.delayed(const Duration(milliseconds: 180));

      await _openMilestoneDetails(
        milestoneId: milestoneId,
        campaignId: campaignId,
      );
      return;
    }

    if (hasMilestoneId) {
      await _openMilestoneDetails(
        milestoneId: milestoneId,
        campaignId: campaignId.isNotEmpty ? campaignId : null,
      );
      return;
    }

    if (hasCampaignId) {
      await _openCampaignDetails(isBrand: isBrand, campaignId: campaignId);
      return;
    }

    if (type == 'NEW_QUOTE' && campaignId.isNotEmpty) {
      await _openCampaignDetails(isBrand: isBrand, campaignId: campaignId);
      return;
    }
  }

  Future<void> _goToBaseTab({required bool isBrand}) async {
    await _waitForNestedNavigatorReady();

    final bottomNavController = Get.find<BottomNavController>();
    final targetIndex = 1;

    bottomNavController.onTabChanged(targetIndex);

    await Future.delayed(const Duration(milliseconds: 220));
    await _waitForNestedNavigatorReady();
  }

  Future<void> _openCampaignDetails({
    required bool isBrand,
    required String campaignId,
  }) async {
    if (campaignId.trim().isEmpty) return;

    final route = isBrand
        ? AppRoutes.brandCampaignDetails
        : AppRoutes.campaignDetails;

    if (isBrand &&
        _isOnBrandCampaignDetailsPage() &&
        Get.isRegistered<BrandCampaignDetailsController>()) {
      final controller = Get.find<BrandCampaignDetailsController>();

      final currentCampaignId =
          controller.job?.id?.trim() ??
          controller.arguments?['campaignId']?.toString().trim() ??
          '';

      if (currentCampaignId == campaignId.trim()) {
        await controller.refreshCampaignDetails();
        return;
      }
    }

    Get.offNamed(
      route,
      id: 1,
      arguments: {'campaignId': campaignId.trim(), 'fromNotification': true},
    );
  }

  Future<void> _openMilestoneDetails({
    required String milestoneId,
    String? campaignId,
  }) async {
    if (milestoneId.trim().isEmpty) return;

    Get.toNamed(
      AppRoutes.milestoneDetails,
      id: 1,
      arguments: {
        'milestoneId': milestoneId.trim(),
        if ((campaignId ?? '').trim().isNotEmpty)
          'campaignId': campaignId!.trim(),
        'fromNotification': true,
      },
    );
  }

  bool _isInvitationType(String type) {
    return type.toUpperCase().contains('INVITATION');
  }

  bool _isOnJobsPage() {
    return Get.currentRoute == AppRoutes.jobs;
  }

  bool _isOnBrandCampaignDetailsPage() {
    return Get.currentRoute == AppRoutes.brandCampaignDetails;
  }

  Future<void> _waitForNestedNavigatorReady() async {
    for (int i = 0; i < 20; i++) {
      final nav = Get.nestedKey(1)?.currentState;
      if (nav != null) {
        await Future.delayed(const Duration(milliseconds: 50));
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<bool> _isBrandUser() async {
    if (!Get.isRegistered<TokenService>()) return false;

    final tokenService = Get.find<TokenService>();
    final token = await tokenService.getAccessToken();

    if (token == null || token.trim().isEmpty) return false;
    if (JwtDecoder.isExpired(token)) return false;

    final payload = JwtDecoder.decode(token);
    final role =
        payload['role'] ??
        payload['accountType'] ??
        (payload['user'] is Map ? payload['user']['role'] : null);

    return role == 'brand' || role == 'client';
  }

  @override
  void onClose() {
    _tapSubscription?.cancel();
    _dataSubscription?.cancel();
    super.onClose();
  }
}
