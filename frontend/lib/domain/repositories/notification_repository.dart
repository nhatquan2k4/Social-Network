import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationPageEntity> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  });

  Future<NotificationEntity> markAsRead(String notificationId);

  Future<int> markAllAsRead();
}
