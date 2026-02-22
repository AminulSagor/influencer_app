import 'package:get/get.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/services/notification_service.dart';

enum NotificationType { positive, negative, neutral }

class NotificationItem {
  final String id;
  final String title;
  final String timeLabel;
  final NotificationType type;
  final String iconPath;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.type,
    required this.iconPath,
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

  final newItems = <NotificationItem>[].obs;
  final earlierItems = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (_appUserSession.notificationsLoaded.value) {
      _hydrateFromAppSession();
    } else {
      loadNotifications();
    }
  }

  String get _basePath => _accountTypeService.isBrand
      ? '/client/notifications'
      : _accountTypeService.isInfluencer
      ? '/influencer/notifications'
      : '/notifications';

  Future<void> loadNotifications() async {
    isLoading.value = true;

    // 1) "New" from filter=new
    final newRes = await ApiErrorHandler.call(
      () => _service.fetchNotifications(
        basePath: _basePath,
        filter: 'new',
        page: 1,
        limit: 50,
      ),
      errorTitle: 'notifications_title'.tr,
    );

    List<NotificationDto> apiNew = const [];
    if (newRes.isSuccess && newRes.data != null) {
      apiNew = newRes.data!.data;
      newItems.assignAll(apiNew.map(_mapApiToUi).toList(growable: false));
    } else {
      // keep UI empty state if error
      newItems.clear();
    }

    // 2) Earlier (best-effort)
    final earlier = await _fetchEarlierBestEffort();
    earlierItems.assignAll(earlier.map(_mapApiToUi).toList(growable: false));
    _appUserSession.updateNotifications(
      newItems: apiNew,
      earlierItems: earlier,
    );

    isLoading.value = false;
  }

  Future<List<NotificationDto>> _fetchEarlierBestEffort() async {
    // try filter=earlier (NOT confirmed in Postman, so we suppress errors)
    try {
      final res = await _service.fetchNotifications(
        basePath: _basePath,
        filter: 'earlier',
        page: 1,
        limit: 50,
      );
      return res.data;
    } catch (_) {
      // fallback: fetch "all" (no filter) and split by isRead=true
      final allRes = await ApiErrorHandler.call(
        () => _service.fetchNotifications(
          basePath: _basePath,
          page: 1,
          limit: 100,
        ),
        showError: false,
      );

      if (!allRes.isSuccess || allRes.data == null) return const [];
      return allRes.data!.data.where((e) => e.isRead).toList(growable: false);
    }
  }

  void markAllAsRead() {
    ApiErrorHandler.call(
      () => _service.markAllAsRead(basePath: _basePath),
      showError: false,
    ).then((_) {
      earlierItems.addAll(newItems);
      _appUserSession.updateNotifications(
        newItems: const [],
        earlierItems: [
          ..._appUserSession.earlierNotifications,
          ..._appUserSession.newNotifications,
        ],
      );
      newItems.clear();
    });
  }

  void markSingleAsRead(NotificationItem item) {
    if (item.id.trim().isEmpty) return;

    ApiErrorHandler.call(
      () => _service.markSingleAsRead(id: item.id, basePath: _basePath),
      showError: false,
    ).then((_) {
      newItems.removeWhere((e) => e.id == item.id);
      if (!earlierItems.any((e) => e.id == item.id)) {
        earlierItems.insert(0, item);
      }
      _appUserSession.updateNotifications(
        newItems: _appUserSession.newNotifications
            .where((e) => e.id != item.id)
            .toList(growable: false),
        earlierItems: _moveSessionNotificationToEarlier(item.id),
      );
    });
  }

  void _hydrateFromAppSession() {
    newItems.assignAll(
      _appUserSession.newNotifications.map(_mapApiToUi).toList(growable: false),
    );
    earlierItems.assignAll(
      _appUserSession.earlierNotifications
          .map(_mapApiToUi)
          .toList(growable: false),
    );
  }

  List<NotificationDto> _moveSessionNotificationToEarlier(String id) {
    final currentEarlier = [..._appUserSession.earlierNotifications];
    NotificationDto? moved;
    for (final item in _appUserSession.newNotifications) {
      if (item.id == id) {
        moved = item;
        break;
      }
    }
    if (moved != null && !currentEarlier.any((e) => e.id == moved?.id)) {
      currentEarlier.insert(0, moved);
    }
    return currentEarlier;
  }

  // ---------------- mapping helpers ----------------

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
    // match your existing assets used in mock controller
    switch (type) {
      case NotificationType.positive:
        return 'assets/icons/done.png';
      case NotificationType.negative:
        return 'assets/icons/cancel.png';
      case NotificationType.neutral:
        // if it looks like money/payment, show taka
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

    // fallback: simple date
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
