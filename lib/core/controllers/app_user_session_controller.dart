import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/services/notification_service.dart';
import 'package:influencer_app/core/services/token_service.dart';
import 'package:influencer_app/modules/ad_agency/services/agency_profile_service.dart';
import 'package:influencer_app/modules/brand/services/brand_onboarding_services.dart';
import 'package:influencer_app/modules/influencer/models/influencer_profile_model.dart';
import 'package:influencer_app/modules/influencer/services/influencer_profile_service.dart';

import '../../modules/shared/bottom_navbar/bottom_nav_controller.dart';
import '../../routes/app_routes.dart';
import '../models/location_models.dart';
import '../services/auth_services.dart';
import '../services/campaign_service.dart';
import '../services/location_service.dart';

class AppUserSessionController extends GetxService {
  final isLoading = false.obs;
  final isLoaded = false.obs;
  final notificationsLoaded = false.obs;

  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final displayName = ''.obs;
  final profileImageUrl = ''.obs;

  final Rxn<InfluencerProfile> influencerProfile = Rxn<InfluencerProfile>();
  final Rxn<Map<String, dynamic>> agencyProfileJson =
      Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> brandProfileJson =
      Rxn<Map<String, dynamic>>();

  final newNotifications = <NotificationDto>[].obs;
  final earlierNotifications = <NotificationDto>[].obs;

  int get unreadNotificationCount => newNotifications.length;

  final TokenService _tokenService = Get.find<TokenService>();
  final AccountTypeService _accountTypeService = Get.find<AccountTypeService>();
  final InfluencerProfileService _influencerProfileService =
      Get.find<InfluencerProfileService>();
  final AgencyProfileService _agencyProfileService =
      Get.find<AgencyProfileService>();
  final BrandOnboardingService _brandOnboardingService =
      Get.find<BrandOnboardingService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final LocationService _locationService = Get.find<LocationService>();
  final CampaignService _campaignService = Get.find<CampaignService>();

  final brandZillas = <ZillaModel>[].obs;
  final brandThanas = <ThanaModel>[].obs;
  final brandPlatforms = <String>[].obs;

  String get _notificationBasePath => _accountTypeService.isBrand
      ? '/client/notifications'
      : _accountTypeService.isInfluencer
      ? '/influencer/notifications'
      : '/notifications';

  Future<bool> preloadUserData({bool forceRefresh = false}) async {
    if (isLoading.value) {
      return isUserVerified();
    }

    if (!forceRefresh && isLoaded.value) {
      return isUserVerified();
    }

    isLoading.value = true;

    try {
      if (forceRefresh) {
        reset();
      }

      await _loadUserFromToken();

      if (_accountTypeService.isBrand) {
        await _preloadBrandLookupsBeforeProfile();
      }

      await _loadProfile();

      if (_accountTypeService.isBrand) {
        await _preloadBrandThanasAfterProfile();
      }

      await _loadNotifications();

      isLoaded.value = true;
      return isUserVerified();
    } catch (e) {
      debugPrint('[AppUserSession] preload failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _preloadBrandLookupsBeforeProfile() async {
    await Future.wait([_loadBrandZillas(), _loadBrandPlatforms()]);
  }

  Future<void> _loadBrandZillas() async {
    if (brandZillas.isNotEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _locationService.fetchAllZillas(),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      brandZillas.assignAll(result.data!);
    }
  }

  Future<void> _loadBrandPlatforms() async {
    if (brandPlatforms.isNotEmpty) return;

    final result = await ApiErrorHandler.call(
      () => _campaignService.fetchPlatforms(),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      final items = result.data!
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      brandPlatforms.assignAll(items);
    }
  }

  Future<void> _preloadBrandThanasAfterProfile() async {
    final json = brandProfileJson.value;
    if (json == null || json.isEmpty) return;

    final zillaName = (json['zilla'] ?? '').toString().trim();
    if (zillaName.isEmpty) return;

    if (brandZillas.isEmpty) {
      await _loadBrandZillas();
    }

    final matchedZilla = brandZillas.firstWhereOrNull(
      (e) => e.displayName.toLowerCase() == zillaName.toLowerCase(),
    );

    if (matchedZilla == null) {
      brandThanas.clear();
      return;
    }

    final result = await ApiErrorHandler.call(
      () => _locationService.fetchAllThanasByZilla(zillaId: matchedZilla.id),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      brandThanas.assignAll(result.data!);
    } else {
      brandThanas.clear();
    }
  }

  void updateNotifications({
    required List<NotificationDto> newItems,
    required List<NotificationDto> earlierItems,
  }) {
    newNotifications.assignAll(newItems);
    earlierNotifications.assignAll(earlierItems);
    notificationsLoaded.value = true;
  }

  Future<void> _loadProfile() async {
    if (_accountTypeService.isInfluencer) {
      await _loadInfluencerProfile();
      return;
    }

    if (_accountTypeService.isAdAgency) {
      await _loadAgencyProfile();
      return;
    }

    if (_accountTypeService.isBrand) {
      await _loadBrandProfile();
      return;
    }
  }

  Future<void> _loadInfluencerProfile() async {
    try {
      final result = await _influencerProfileService.getProfile();
      if (!result.isSuccess || result.data == null) return;

      final profile = result.data!;
      influencerProfile.value = profile;

      if (profile.fullName.trim().isNotEmpty) {
        displayName.value = profile.fullName.trim();
      }
      profileImageUrl.value = profile.displayImage?.trim() ?? '';
    } catch (e) {
      debugPrint('[AppUserSession] influencer profile load failed: $e');
    }
  }

  Future<void> _loadAgencyProfile() async {
    final result = await ApiErrorHandler.call(
      () => _agencyProfileService.fetchProfile(),
      showError: false,
    );
    if (!result.isSuccess || result.data == null) return;

    final json = result.data!;
    agencyProfileJson.value = json;

    _applyIdentityFromJson(
      json: json,
      preferredName: (json['agencyName'] ?? '').toString(),
    );
  }

  Future<void> _loadBrandProfile() async {
    final result = await ApiErrorHandler.call(
      () => _brandOnboardingService.fetchProfile(),
      showError: false,
    );
    if (!result.isSuccess || result.data == null) return;

    final json = result.data!;
    brandProfileJson.value = json;

    _applyIdentityFromJson(
      json: json,
      preferredName: (json['brandName'] ?? '').toString(),
    );
  }

  void _applyIdentityFromJson({
    required Map<String, dynamic> json,
    required String preferredName,
  }) {
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();
    final combined = '$firstName $lastName'.trim();

    if (preferredName.trim().isNotEmpty) {
      displayName.value = preferredName.trim();
    } else if (combined.isNotEmpty) {
      displayName.value = combined;
    }

    profileImageUrl.value =
        _stringOrNull(json['profileImg']) ??
        _stringOrNull(json['profileImage']) ??
        _stringOrNull(json['logo']) ??
        '';

    final email =
        _stringOrNull(json['email']) ??
        _stringOrNull((json['user'] as Map?)?['email']);
    final phone =
        _stringOrNull(json['phone']) ??
        _stringOrNull((json['user'] as Map?)?['phone']);

    if (email != null) userEmail.value = email;
    if (phone != null) userPhone.value = phone;
  }

  Future<void> _loadNotifications() async {
    try {
      final newRes = await _notificationService.fetchNotifications(
        basePath: _notificationBasePath,
        // filter: 'new',
        page: 1,
        limit: 50,
      );

      List<NotificationDto> earlier;
      try {
        final earlierRes = await _notificationService.fetchNotifications(
          basePath: _notificationBasePath,
          filter: 'earlier',
          page: 1,
          limit: 50,
        );
        earlier = earlierRes.data;
      } catch (_) {
        final allRes = await _notificationService.fetchNotifications(
          basePath: _notificationBasePath,
          page: 1,
          limit: 100,
        );
        earlier = allRes.data.where((n) => n.isRead).toList(growable: false);
      }

      updateNotifications(newItems: newRes.data, earlierItems: earlier);
    } catch (e) {
      debugPrint('[AppUserSession] notifications load failed: $e');
      updateNotifications(newItems: const [], earlierItems: const []);
    }
  }

  /// Extracts verification status from loaded profile data
  bool isUserVerified() {
    if (_accountTypeService.isInfluencer) {
      final profile = influencerProfile.value;
      return profile?.isVerified ?? false;
    }

    if (_accountTypeService.isAdAgency) {
      final json = agencyProfileJson.value;
      if (json == null) return false;

      return _toBool(json['isVerified']) ??
          _toBool((json['user'] as Map?)?['isVerified']) ??
          false;
    }

    if (_accountTypeService.isBrand) {
      final json = brandProfileJson.value;
      if (json == null) return false;

      return _toBool(json['isVerified']) ??
          _toBool((json['user'] as Map?)?['isVerified']) ??
          false;
    }

    return false;
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  void reset() {
    isLoading.value = false;
    isLoaded.value = false;
    notificationsLoaded.value = false;

    userEmail.value = '';
    userPhone.value = '';
    displayName.value = '';
    profileImageUrl.value = '';

    influencerProfile.value = null;
    agencyProfileJson.value = null;
    brandProfileJson.value = null;

    newNotifications.clear();
    earlierNotifications.clear();
  }

  Future<void> logout() async {
    try {
      final auth = Get.find<AuthService>();

      await auth.logout();

      _accountTypeService.setRole(null);
      reset();

      Get.offAllNamed(AppRoutes.login);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<BottomNavController>()) {
          Get.delete<BottomNavController>(force: true);
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Logout failed');
    }
  }

  Future<void> _loadUserFromToken() async {
    final token = await _tokenService.getAccessToken();
    if (token == null || token.trim().isEmpty) return;

    final payload = _decodeJwtPayload(token);
    if (payload == null) return;

    final email = _stringOrNull(payload['email']);
    final phone = _stringOrNull(payload['phone']);
    final name =
        _stringOrNull(payload['name']) ??
        _stringOrNull(payload['fullName']) ??
        _stringOrNull((payload['user'] as Map?)?['name']);

    if (email != null) userEmail.value = email;
    if (phone != null) userPhone.value = phone;
    if (name != null) displayName.value = name;
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalized);
      final payloadString = utf8.decode(payloadBytes);
      final payloadJson = jsonDecode(payloadString);
      if (payloadJson is Map<String, dynamic>) return payloadJson;
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
