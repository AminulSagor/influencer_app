import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/services/firebase_messaging_service.dart';
import 'package:influencer_app/core/services/notification_service.dart';

enum NotificationType { positive, negative, neutral }

class NotificationItem {
  final String id;
  final String title;
  final String timeLabel;
  final NotificationType type;
  final String iconPath;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.type,
    required this.iconPath,
    required this.isRead,
  });
}

class NotificationsController extends GetxController {
  NotificationsController({required NotificationService service})
    : _service = service;

  final NotificationService _service;
  final AccountTypeService _accountTypeService = Get.find<AccountTypeService>();
  final AppUserSessionController _appUserSession =
      Get.find<AppUserSessionController>();

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isMarkingAllRead = false.obs;
  final isInitialLoaded = false.obs;

  final items = <NotificationItem>[].obs;
  final unreadCount = 0.obs;

  final scrollController = ScrollController();

  static const int _pageSize = 20;
  int _page = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  List<NotificationItem> get newItems =>
      items.where((e) => !e.isRead).toList(growable: false);

  List<NotificationItem> get earlierItems =>
      items.where((e) => e.isRead).toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _listenRealtimeNotifications();
    loadNotifications(reset: true);
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  String get _basePath => '/notifications';

  void _listenRealtimeNotifications() {
    _notificationSubscription?.cancel();

    _notificationSubscription = FirebaseMessagingService.notificationStream
        .listen((_) async {
          await loadNotifications(reset: true);
          await _appUserSession.refreshNotificationBadgeCount();
        });
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading.value || !_hasMore) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      loadNotifications();
    }
  }

  Future<void> refreshNotifications() async {
    isRefreshing.value = true;
    try {
      await loadNotifications(reset: true);
      await _appUserSession.refreshNotificationBadgeCount();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadNotifications({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      _page = 1;
      _totalPages = 1;
      _hasMore = true;
    } else {
      if (!_hasMore) return;
      _page += 1;
    }

    isLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _service.fetchNotifications(
        basePath: _basePath,
        page: _page,
        limit: _pageSize,
      ),
      errorTitle: 'notifications_title'.tr,
      showError: reset,
    );

    if (!result.isSuccess || result.data == null) {
      if (!reset) {
        _page = _page > 1 ? _page - 1 : 1;
      }
      isLoading.value = false;
      isInitialLoaded.value = true;
      return;
    }

    final res = result.data!;

    final fetched = res.data.map(_mapApiToUi).toList(growable: false);

    final nextUnreadCount = _extractUnreadCount(res);
    unreadCount.value = nextUnreadCount;
    _appUserSession.updateUnreadNotificationCount(nextUnreadCount);

    final nextTotalPages = _extractTotalPages(
      res,
      fallbackLength: fetched.length,
    );
    _totalPages = nextTotalPages;
    _hasMore = _page < _totalPages;

    if (reset) {
      items.assignAll(fetched);
    } else {
      final existingIds = items.map((e) => e.id).toSet();
      final merged = fetched.where((e) => !existingIds.contains(e.id)).toList();
      items.addAll(merged);
    }

    isLoading.value = false;
    isInitialLoaded.value = true;
  }

  int _extractUnreadCount(dynamic response) {
    try {
      final meta = (response.meta as dynamic);
      final unread = meta?.unreadCount;
      if (unread is num) return unread.toInt();
    } catch (_) {}

    try {
      final unread = response.unreadCount;
      if (unread is num) return unread.toInt();
    } catch (_) {}

    return items.where((e) => !e.isRead).length;
  }

  int _extractTotalPages(dynamic response, {required int fallbackLength}) {
    try {
      final meta = (response.meta as dynamic);
      final total = meta?.total;
      final limit = meta?.limit;

      if (total is num && limit is num && limit.toInt() > 0) {
        return (total.toInt() / limit.toInt()).ceil().clamp(1, 999999);
      }

      final totalPages = meta?.totalPages;
      if (totalPages is num && totalPages.toInt() > 0) {
        return totalPages.toInt();
      }
    } catch (_) {}

    return fallbackLength < _pageSize ? _page : _page + 1;
  }

  Future<void> markAllAsRead() async {
    if (isMarkingAllRead.value) return;

    isMarkingAllRead.value = true;
    final result = await ApiErrorHandler.call(
      () => _service.markAllAsRead(),
      showError: false,
    );

    if (result.isSuccess) {
      await loadNotifications(reset: true);
      _appUserSession.updateUnreadNotificationCount(0);
    }

    isMarkingAllRead.value = false;
  }

  Future<void> markSingleAsRead(NotificationItem item) async {
    if (item.id.trim().isEmpty || item.isRead) return;

    final result = await ApiErrorHandler.call(
      () => _service.markSingleAsRead(id: item.id),
      showError: false,
    );

    if (!result.isSuccess) return;

    final index = items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      final updated = NotificationItem(
        id: items[index].id,
        title: items[index].title,
        timeLabel: items[index].timeLabel,
        type: items[index].type,
        iconPath: items[index].iconPath,
        isRead: true,
      );
      items[index] = updated;
      items.refresh();
    }

    final nextUnread = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
    unreadCount.value = nextUnread;
    _appUserSession.updateUnreadNotificationCount(nextUnread);
  }

  NotificationItem _mapApiToUi(NotificationDto n) {
    final text = (n.title.trim().isNotEmpty ? n.title : n.message).trim();
    final type = _inferTypeFromText(text);
    final iconPath = _iconFor(type, text);

    return NotificationItem(
      id: n.id,
      title: text,
      timeLabel: _timeAgo(n.createdAt),
      type: type,
      iconPath: iconPath,
      isRead: n.isRead,
    );
  }

  NotificationType _inferTypeFromText(String text) {
    final s = text.toLowerCase();
    if (s.contains('reject') ||
        s.contains('rejected') ||
        s.contains('decline') ||
        s.contains('declined')) {
      return NotificationType.negative;
    }
    if (s.contains('approved') ||
        s.contains('verified') ||
        s.contains('received') ||
        s.contains('success')) {
      return NotificationType.positive;
    }
    return NotificationType.neutral;
  }

  String _iconFor(NotificationType type, String text) {
    switch (type) {
      case NotificationType.positive:
        return 'assets/icons/done.png';
      case NotificationType.negative:
        return 'assets/icons/cancel.png';
      case NotificationType.neutral:
        final s = text.toLowerCase();
        if (s.contains('payment') ||
            s.contains('taka') ||
            s.contains('tk') ||
            s.contains('৳')) {
          return 'assets/icons/taka.png';
        }
        return 'assets/icons/suitcase.png';
    }
  }

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
