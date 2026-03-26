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
      // Get.offNamed(
      //   AppRoutes.jobs,
      //   id: 1,
      //   arguments: {
      //     'initialTabIndex': 0,
      //     'campaignId': campaignId,
      //     'assignmentId': assignmentId,
      //     'fromNotification': true,
      //   },
      // );
      return;
    }

    if (type == 'NEW_QUOTE') {
      if (campaignId.isEmpty) return;

      final isBrand = await _isBrandUser();
      if (!isBrand) return;

      await _waitForNestedNavigatorReady();

      if (_isOnBrandCampaignDetailsPage() &&
          Get.isRegistered<BrandCampaignDetailsController>()) {
        final controller = Get.find<BrandCampaignDetailsController>();

        final currentCampaignId =
            controller.job?.id?.trim() ??
            controller.arguments?['campaignId']?.toString().trim() ??
            '';

        if (currentCampaignId == campaignId) {
          await controller.refreshCampaignDetails();
          return;
        }

        Get.offNamed(
          AppRoutes.brandCampaignDetails,
          id: 1,
          arguments: {'campaignId': campaignId},
        );
        return;
      }

      Get.offNamed(
        AppRoutes.brandCampaignDetails,
        id: 1,
        arguments: {'campaignId': campaignId},
      );
    }
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
