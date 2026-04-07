import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'package:influencer_app/core/services/local_notification_service.dart';
import 'package:influencer_app/core/services/token_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  dev.log(
    'Background notification received',
    name: 'FirebaseMessagingService',
    error: {
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    },
  );
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final StreamController<Map<String, dynamic>>
  _notificationDataController =
      StreamController<Map<String, dynamic>>.broadcast();

  static final StreamController<Map<String, dynamic>>
  _notificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Map<String, dynamic>? _pendingTapData;

  static Stream<Map<String, dynamic>> get notificationStream =>
      _notificationDataController.stream;

  static Stream<Map<String, dynamic>> get notificationTapStream =>
      _notificationTapController.stream;

  static Map<String, dynamic>? consumePendingTapData() {
    if (_pendingTapData == null) return null;
    final data = Map<String, dynamic>.from(_pendingTapData!);
    _pendingTapData = null;
    return data;
  }

  static void clearPendingTapData() {
    _pendingTapData = null;
  }

  static Future<String?> getCurrentFcmToken() async {
    final token = await _messaging.getToken();
    final normalized = token?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static Future<void> init() async {
    await Firebase.initializeApp();

    // Always clear stale memory first.
    clearPendingTapData();

    await LocalNotificationService.init(
      onNotificationTap: (payload) {
        if (payload == null || payload.trim().isEmpty) return;

        try {
          final decoded = jsonDecode(payload);
          final map = _asMap(decoded);
          if (map == null) return;
          if (!_isNavigablePayload(map)) return;

          _emitNotificationTap(map);
        } catch (e) {
          dev.log(
            'Failed to parse local notification payload',
            name: 'FirebaseMessagingService',
            error: e,
          );
        }
      },
    );

    bool hasFreshLaunchTap = false;

    final launchPayload = LocalNotificationService.consumeLaunchPayload();
    if (launchPayload != null && launchPayload.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(launchPayload);
        final map = _asMap(decoded);

        if (map != null && _isNavigablePayload(map)) {
          hasFreshLaunchTap = true;
          _emitNotificationData(map);
          _emitNotificationTap(map);
        }
      } catch (e) {
        dev.log(
          'Failed to parse launch payload from local notification',
          name: 'FirebaseMessagingService',
          error: e,
        );
      }
    }

    await _requestPermission();
    await _setupForegroundPresentation();
    await _logFcmToken();
    _listenTokenRefresh();
    _listenForegroundMessages();
    _listenOpenedMessages();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && _isNavigablePayload(initialMessage.data)) {
      hasFreshLaunchTap = true;

      dev.log(
        'Notification opened from terminated state',
        name: 'FirebaseMessagingService',
        error: {
          'messageId': initialMessage.messageId,
          'title': initialMessage.notification?.title,
          'body': initialMessage.notification?.body,
          'data': initialMessage.data,
        },
      );

      _emitNotificationData(initialMessage.data);
      _emitNotificationTap(initialMessage.data);
    }

    if (!hasFreshLaunchTap) {
      clearPendingTapData();
    }
  }

  static Map<String, dynamic>? _asMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  static bool _isNavigablePayload(Map<String, dynamic> data) {
    final type = data['type']?.toString().trim().toUpperCase() ?? '';
    final campaignId = data['campaignId']?.toString().trim() ?? '';
    final milestoneId = data['milestoneId']?.toString().trim() ?? '';

    if (campaignId.isNotEmpty || milestoneId.isNotEmpty) return true;
    if (type.contains('INVITATION')) return true;

    return false;
  }

  static void _emitNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    _notificationDataController.add(Map<String, dynamic>.from(data));
  }

  static void _emitNotificationTap(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    _pendingTapData = Map<String, dynamic>.from(data);
    _notificationTapController.add(Map<String, dynamic>.from(data));
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    dev.log(
      'Notification permission status: ${settings.authorizationStatus.name}',
      name: 'FirebaseMessagingService',
    );
  }

  static Future<void> _setupForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _logFcmToken() async {
    final token = await _messaging.getToken();
    dev.log('FCM Token: ${token ?? 'null'}', name: 'FirebaseMessagingService');
  }

  static void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      dev.log(
        'FCM Token refreshed: $newToken',
        name: 'FirebaseMessagingService',
      );

      if (!Get.isRegistered<TokenService>()) return;

      final tokenService = Get.find<TokenService>();
      final authToken = await tokenService.getAccessToken();

      if (authToken == null || authToken.trim().isEmpty) {
        return;
      }

      if (!Get.isRegistered<AuthService>()) return;

      final authService = Get.find<AuthService>();
      final oldToken = await tokenService.getFcmToken();

      if (oldToken == newToken.trim()) {
        return;
      }

      if (oldToken != null && oldToken.trim().isNotEmpty) {
        await authService.deleteDeviceFcmToken(token: oldToken.trim());
      }

      await authService.registerDeviceFcmToken(token: newToken.trim());
    });
  }

  static void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      dev.log(
        'Foreground notification received',
        name: 'FirebaseMessagingService',
        error: {
          'messageId': message.messageId,
          'title': message.notification?.title,
          'body': message.notification?.body,
          'data': message.data,
        },
      );

      dev.log(
        'Full message = ${message.toMap()}',
        name: 'FirebaseMessagingService',
      );

      _emitNotificationData(message.data);

      final title =
          message.notification?.title ??
          message.data['title']?.toString() ??
          'Notification';

      final body =
          message.notification?.body ?? message.data['body']?.toString() ?? '';

      await LocalNotificationService.show(
        title: title,
        body: body,
        payload: message.data.isEmpty ? null : jsonEncode(message.data),
      );
    });
  }

  static void _listenOpenedMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log(
        'Notification clicked from background',
        name: 'FirebaseMessagingService',
        error: {
          'messageId': message.messageId,
          'title': message.notification?.title,
          'body': message.notification?.body,
          'data': message.data,
        },
      );

      if (!_isNavigablePayload(message.data)) return;

      _emitNotificationData(message.data);
      _emitNotificationTap(message.data);
    });
  }

  static Future<void> dispose() async {
    await _notificationDataController.close();
    await _notificationTapController.close();
  }
}
