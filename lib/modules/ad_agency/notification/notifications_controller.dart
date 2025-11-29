import 'package:get/get.dart';

enum NotificationType { positive, negative, neutral }

class NotificationItem {
  final String title;
  final String timeLabel;
  final NotificationType type;
  final String iconPath;

  const NotificationItem({
    required this.title,
    required this.timeLabel,
    required this.type,
    required this.iconPath,
  });
}

class NotificationsController extends GetxController {
  final newItems = <NotificationItem>[].obs;
  final earlierItems = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Mock data (kept only in controller – nothing hard-coded in UI)
    newItems.assignAll(const [
      NotificationItem(
        title: "New Offer 'Summer Sale' added",
        timeLabel: '28min ago',
        type: NotificationType.neutral,
        iconPath: 'assets/icons/suitcase.png',
      ),
      NotificationItem(
        title: "'Summer Sale' – Milestone 4 declined",
        timeLabel: 'Yesterday, 4:30pm',
        type: NotificationType.negative,
        iconPath: 'assets/icons/cancel.png',
      ),
      NotificationItem(
        title: "'Summer Sale' – Milestone 4 payment received",
        timeLabel: 'Yesterday, 4:30pm',
        type: NotificationType.positive,
        iconPath: 'assets/icons/taka.png',
      ),
    ]);

    earlierItems.assignAll(const [
      NotificationItem(
        title: 'NID Document Approved',
        timeLabel: '4h ago',
        type: NotificationType.positive,
        iconPath: 'assets/icons/done.png',
      ),
      NotificationItem(
        title: 'New Payout Method Approved',
        timeLabel: '9h ago',
        type: NotificationType.positive,
        iconPath: 'assets/icons/done.png',
      ),
      NotificationItem(
        title: 'Name Change Declined',
        timeLabel: 'Yesterday, 4:30pm',
        type: NotificationType.negative,
        iconPath: 'assets/icons/cancel.png',
      ),
    ]);
  }

  void markAllAsRead() {
    earlierItems.addAll(newItems);
    newItems.clear();
  }
}
