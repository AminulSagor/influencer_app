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

  static Future<void> init() async {
    await Firebase.initializeApp();
    await LocalNotificationService.init();

    await _requestPermission();
    await _setupForegroundPresentation();
    await _logFcmToken();
    _listenTokenRefresh();
    _listenForegroundMessages();
    _listenOpenedMessages();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
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
    }
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
    });
  }
}
