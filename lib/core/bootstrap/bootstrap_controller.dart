import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/firebase_messaging_service.dart';
import 'package:influencer_app/core/services/notification_navigation_service.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/services/account_type_service.dart';
import '../../../core/services/token_service.dart';
import '../../../routes/app_routes.dart';

class BootstrapController extends GetxController {
  final token = RxnString();
  final isFirstTimeUser = true.obs;

  late final TokenService _tokenService;
  late final AccountTypeService _accountTypeService;
  late final AppUserSessionController _appUserSessionController;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _tokenService = Get.find<TokenService>();
    _accountTypeService = Get.find<AccountTypeService>();
    _appUserSessionController = Get.find<AppUserSessionController>();
    _authService = Get.find<AuthService>();
    debugPrint('[Bootstrap] onInit');
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    try {
      debugPrint('[Bootstrap] start');
      final storedToken = await _tokenService.getAccessToken();
      final firstTime = await _tokenService.isFirstTimeUser();

      debugPrint('[Bootstrap] token=${storedToken == null ? 'null' : '***'}');
      debugPrint('[Bootstrap] isFirstTimeUser=$firstTime');

      token.value = storedToken;
      isFirstTimeUser.value = firstTime;

      if (firstTime) {
        FirebaseMessagingService.clearPendingTapData();
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }

      if (storedToken != null && storedToken.isNotEmpty) {
        final isExpired = JwtDecoder.isExpired(storedToken);
        debugPrint('[Bootstrap] token expired=$isExpired');

        if (!isExpired) {
          final payload = JwtDecoder.decode(storedToken);

          final role =
              payload['role'] ??
              payload['accountType'] ??
              (payload['user'] is Map ? payload['user']['role'] : null);

          if (role == 'influencer') {
            _accountTypeService.setRole(AccountType.influencer);
          } else if (role == 'brand' || role == 'client') {
            _accountTypeService.setRole(AccountType.brand);
          } else if (role == 'agency') {
            _accountTypeService.setRole(AccountType.adAgency);
          }

          await _ensureDeviceFcmTokenRegistered();

          await _appUserSessionController.preloadUserData(forceRefresh: true);
          final isVerifiedByApi = _appUserSessionController.isUserVerified();

          debugPrint('[Bootstrap] isVerifiedByApi=$isVerifiedByApi');

          Get.offAllNamed(
            AppRoutes.bottomNav,
            arguments: {'isAccountVerified': isVerifiedByApi},
          );

          if (Get.isRegistered<NotificationNavigationService>()) {
            await Get.find<NotificationNavigationService>()
                .handlePendingTapAfterBootstrap();
          }

          return;
        }
      }

      FirebaseMessagingService.clearPendingTapData();
      Get.offAllNamed(AppRoutes.login);
    } catch (_, _) {
      FirebaseMessagingService.clearPendingTapData();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _ensureDeviceFcmTokenRegistered() async {
    try {
      final savedFcmToken = await _tokenService.getFcmToken();

      debugPrint(
        '[Bootstrap] savedFcmToken=${savedFcmToken == null ? 'null' : '***'}',
      );

      if (savedFcmToken != null && savedFcmToken.trim().isNotEmpty) {
        return;
      }

      final liveFcmToken = await FirebaseMessagingService.getCurrentFcmToken();

      debugPrint(
        '[Bootstrap] liveFcmToken=${liveFcmToken == null ? 'null' : '***'}',
      );

      if (liveFcmToken == null || liveFcmToken.isEmpty) {
        return;
      }

      await _authService.registerDeviceFcmToken(token: liveFcmToken);

      debugPrint('[Bootstrap] FCM token registered and saved');
    } catch (e, stack) {
      debugPrint('[Bootstrap] FCM registration skipped: $e');
      debugPrint(stack.toString());
    }
  }
}

class BootstrapBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('[Bootstrap] binding dependencies');
    Get.put<BootstrapController>(BootstrapController());
  }
}
