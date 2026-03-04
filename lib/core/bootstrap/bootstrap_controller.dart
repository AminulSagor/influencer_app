import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';

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

  @override
  void onInit() {
    super.onInit();
    _tokenService = Get.find<TokenService>();
    _accountTypeService = Get.find<AccountTypeService>();
    _appUserSessionController = Get.find<AppUserSessionController>();
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
        debugPrint('[Bootstrap] routing -> onboarding');
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }

      if (storedToken != null && storedToken.isNotEmpty) {
        debugPrint('[Bootstrap] token present');
        final isExpired = JwtDecoder.isExpired(storedToken);
        debugPrint('[Bootstrap] token expired=$isExpired');
        if (!isExpired) {
          final payload = JwtDecoder.decode(storedToken);
          debugPrint('[Bootstrap] token decoded');
          final role =
              payload['role'] ??
              payload['accountType'] ??
              (payload['user'] is Map ? payload['user']['role'] : null);

          debugPrint('[Bootstrap] role=$role');

          if (role == 'influencer') {
            _accountTypeService.setRole(AccountType.influencer);
            debugPrint('[Bootstrap] set role -> influencer');
          } else if (role == 'brand' || role == 'client') {
            _accountTypeService.setRole(AccountType.brand);
            debugPrint('[Bootstrap] set role -> brand');
          } else if (role == 'agency') {
            _accountTypeService.setRole(AccountType.adAgency);
            debugPrint('[Bootstrap] set role -> adAgency');
          }

          final isVerifiedByAdmin = payload['isVerified'] as bool? ?? false;
          debugPrint('[Bootstrap] isVerifiedByAdmin=$isVerifiedByAdmin');

          await _appUserSessionController.preloadUserData();

          debugPrint('[Bootstrap] routing -> bottomNav');
          Get.offAllNamed(
            AppRoutes.bottomNav,
            arguments: {'isAccountVerified': isVerifiedByAdmin},
          );
          return;
        }
      }

      debugPrint('[Bootstrap] routing -> login');
      Get.offAllNamed(AppRoutes.login);
    } catch (e, stack) {
      debugPrint('[Bootstrap] error: $e');
      debugPrint(stack.toString());
      Get.offAllNamed(AppRoutes.login);
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
